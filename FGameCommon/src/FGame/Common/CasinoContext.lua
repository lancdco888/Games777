local GlobalMsgHandle = Import(".Logic.GlobalMsgHandle")
---@class CasinoContext
local CasinoContext = Class("CasinoContext")


-- @param enterData 类型应该为 PB.Slots_Client.Enter_Success
-- @param reconnectData 类型应该为 PB.Client_Slots.Enter 请求返回的游戏断线重连类型
function CasinoContext:ctor(gameId, enterData, reconnectData)
    self.gameId = gameId
    
    self.enterData = enterData
    self.reconnectData = reconnectData

    -- 大厅数据
    self.lobbyData = APIGateway.GetLobbyData()

    --调试 进入游戏
    if DebugSlots then
        self.enterData, self.reconnectData, self.lobbyData = 
        DebugSlots:EnterSlots( self.enterData, self.reconnectData, self.lobbyData, self.gameId )
    end

    -- 玩家金币信息
    self.playerMoney = self.enterData.enterMoney
    self.playerBindMoney = self.enterData.enterMoneyGift

    -- 当前游戏模式
    self.curGameMode = FGameMode.NORMAL
    self.curSpinStatus = FSpinStatus.SPIN
    self.isAutoSpin = false

    self.runningTime = 0
end

function CasinoContext:Init()
    -- 加载游戏配置
    self.gameCfg = {
        Reel = require(string.format("FGame.Game%d.Cfgs.Reel", self.gameId)),
        Rule = require(string.format("FGame.Game%d.Cfgs.Rule", self.gameId)),
        Theme = require(string.format("FGame.Game%d.Cfgs.Theme", self.gameId)),
    }

    if RUNTIME_IN_CREATOR or RUNTIME_IN_COCOS_H5 then
        local ok, ret = pcall(require, string.format("FGame.Game%d.Cfgs_Creator.Reel", self.gameId))
        if ok and ret then
            self.gameCfg.Reel = ret
        end
    end

    -- 设置当前主题
    FTheme.SetThemeCfg(self.gameCfg.Theme)
    
    -- 加载游戏包
    local pkgName = string.format("Game%d/Game%d", self.gameId, self.gameId)
    FairyGUI.UIPackage.AddPackage(pkgName)
    
    self.commonPanel = FTheme.Require("CommonPanel").New(self)
    
    -- 初始化
    self.commonPanel:InitData()
    self.commonPanel:SetPlayerMoney(self.playerMoney, FPlayerMoneyType.NORMAL_MONEY)
    self.commonPanel:SetPlayerMoney(self.playerBindMoney, FPlayerMoneyType.BIND_MONEY)
    self.commonPanel:SetMoneyType(self.enterData.moneyType)
    self.commonPanel:InitGame(self.gameId)

    BaseReel.ClearAllRunningReels()

    -- 加载游戏脚本
    self.game = require(string.format("FGame.Game%d.Game%d", self.gameId, self.gameId)).New(self.commonPanel:GetGameRender())

    -- 全局消息注册
    self.globalMsgHandle = GlobalMsgHandle.New()

    -- 断线重连恢复
    if self.reconnectData then
        self.game.lastNormalSpinResult = clone(self.reconnectData.resumedNormal)
        self.game:ReconnectRecoveryGame(self.reconnectData, true)
        self.reconnectData = nil
    end

    -- 开启游戏定时器
    -- Unity平台在APIGateway.OnEnter()中驱动
    
    if RUNTIME_IN_CREATOR or RUNTIME_IN_COCOS then
        self.updateTimer = StartTimer(handler(self, self.Update), 0)
    end
end

function CasinoContext:__delete()
    self.isDestroyed = true
    StopTimer(self.updateTimer)

    self.globalMsgHandle:Delete()
    self.commonPanel:Delete()
    self.game:Delete()

    -- 卸载所有的FGUI包
    FairyGUI.UIPackage.RemoveAllPackages()
end

-- @brief 获取当前游戏的实例化对象
function CasinoContext:GetGame()
    return self.game
end

function CasinoContext:Update(dt)
    if self.isDestroyed then return end
    -- 在游戏中断线重连恢复游戏
    local data = APIGateway.GetGameReconnectData()
    if data then
        self.game.lastNormalSpinResult = clone(data.resumedNormal)
        self.game:ReconnectRecoveryGame(data, false)
    end
    
    self.game:Update(dt)
    APIGateway.OnUpdate(dt)

    -- VIP升级动画
    if self.game.lastNormalSpinResult and self.curGameMode == FGameMode.NORMAL and self.curSpinStatus == FSpinStatus.SPIN then
        if self.game.lastNormalSpinResult.normalSpin then
            APIGateway.ShowVipUpInSlots(self.game.lastNormalSpinResult.normalSpin)
        end
        self.game.lastNormalSpinResult = nil
    end

    FSysEventEmitter:Emit(FSysEvent.ON_LOGIC_UPDATE, dt)
    self.runningTime = self.runningTime + dt
end

-- @brief 设置当前游戏模式
function CasinoContext:SetGameMode(value)
    self.curGameMode = value
    self:SetSpinStatus(self.curSpinStatus)
end

-- @brief 设置spine按钮状态
function CasinoContext:SetSpinStatus(value)
    -- print("value ",value)
    -- print(debug.traceback())
    self.curSpinStatus = value
    self.commonPanel:OnChangeSpinStatus(value)
end

-- @brief 设置当前是否自动游戏
function CasinoContext:SetAutoSpin(value)
    -- print("value ",value)
    -- print("SetAutoSpin ",debug.traceback())
    self.isAutoSpin = value
    self:SetSpinStatus(self.curSpinStatus)
end

-- @brief 模拟spin点击
function CasinoContext:SimulateSpinClick()
    -- 普通状态时，如果已经关闭了自动spin则不自动旋转
    if self.curGameMode == FGameMode.NORMAL and not self.isAutoSpin then
        return false
    end
    self.commonPanel:OnSimulateSpinClick()
    return true
end

-- @brief 设置金币信息(界面不刷新，只保存值)
function CasinoContext:SetPlayerMoneyInfo(spinResult)
    local oldMoney = self.playerMoney
    local oldBindMoney = self.playerBindMoney

    self.playerMoney = spinResult.slotMoney.money
    self.playerBindMoney = spinResult.slotMoneyGift.money_gift

    self.lastSpinResult = spinResult

    print("设置玩家金币:", FToolSet.FmtLogMoney(self.playerMoney), "变化值:", FToolSet.FmtLogMoney(self.playerMoney - oldMoney))
    print("设置玩家绑定金币:", FToolSet.FmtLogMoney(self.playerBindMoney), "变化值:", FToolSet.FmtLogMoney(self.playerBindMoney - oldBindMoney))
end

-- @brief 玩家spin消耗金币
-- @return 是否消耗成功
function CasinoContext:PlayerSpinConsumption()
    -- 消耗自动旋转次数
    if not self.commonPanel:OnConsumptionAutoSpinNum() then
        return false
    end

    local betMoney = self.commonPanel:GetBetMoney() * self.commonPanel:GetBetMoneyScale()
    if self.commonPanel:GetMoneyType() == FPlayerMoneyType.NORMAL_MONEY then
        if self.playerMoney < betMoney then
            self.commonPanel:OnInsufficientMoney(FPlayerMoneyType.NORMAL_MONEY)
            return false
        end
        
        self.playerMoney = self.playerMoney - betMoney
        print("扣除玩家金币:", FToolSet.FmtLogMoney(betMoney), "扣除后剩余金币:", FToolSet.FmtLogMoney(self.playerMoney))
    else
        -- 需求: 金币不足时也不让玩家旋转
        if self.lobbyData.washCodeMode == 1 and self.playerMoney < betMoney then
            self.commonPanel:OnInsufficientMoney(FPlayerMoneyType.NORMAL_MONEY)
            return false
        end

        if self.playerBindMoney < betMoney then
            self.commonPanel:OnInsufficientMoney(FPlayerMoneyType.BIND_MONEY)
            return false
        end
        self.playerBindMoney = self.playerBindMoney - betMoney
        print("扣除玩家绑定金币:", FToolSet.FmtLogMoney(betMoney), "扣除后剩余绑定金币:", FToolSet.FmtLogMoney(self.playerBindMoney))
    end
    self:SyncPlayerMoneyDisplay()
    return true
end

-- @brief 同步玩家金币信息显示
-- @param animationTime 动画时间，为nil则不播放动画
function CasinoContext:SyncPlayerMoneyDisplay(animationTime)
    -- 停止金币滚动且不回调结束函数
    self.commonPanel:StopScrollMoney(FPlayerMoneyType.NORMAL_MONEY, false)
    self.commonPanel:StopScrollMoney(FPlayerMoneyType.BIND_MONEY, false)
    if animationTime then
        self.commonPanel:ScrollMoneyTo(self.playerMoney, animationTime, nil, FPlayerMoneyType.NORMAL_MONEY)
        self.commonPanel:ScrollMoneyTo(self.playerBindMoney, animationTime, nil, FPlayerMoneyType.BIND_MONEY)
    else
        self.commonPanel:SetPlayerMoney(self.playerMoney, FPlayerMoneyType.NORMAL_MONEY)
        self.commonPanel:SetPlayerMoney(self.playerBindMoney, FPlayerMoneyType.BIND_MONEY)
    end    
end

return CasinoContext