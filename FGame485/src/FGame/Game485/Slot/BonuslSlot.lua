-- 老虎机追加模式（落地牌模式），每个格子单独转动

local Reel = Import(".Reel")
local Utils = Import(".Utils")
local BaseSlot = Import(".BaseSlot")
local BonuslSlot = Class("BonuslSlot", BaseSlot)

function BonuslSlot:ctor()
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local xNum = reelCfg.xCellNumberBouns
    local yNum = reelCfg.yCellNumberBouns

    self.reelCfg = reelCfg

    local index = 0
    for i = 1, yNum do
        for j = 1, xNum do
            index = index + 1

            local reel = Reel.New(self.bottomContainer, index, 1)
            -- 修改转轴配置高度
            reel.cfg.reelHeight = reel.cfg.reelHeight / reelCfg.yCellNumber
            reel.cfg.rollSymbolMinNum = 5
            
            -- 在落地牌中
            reel.inTopupBouns = true
            reel:InitSymbol()
            reel.reelContainer:SetupOverflowHidden(true)
            reel.reelContainer.x = (j - 1) * (reelCfg.reelWidth + reelCfg.reelSpace)
            reel.reelContainer.y = (i - 1) * reel.cfg.symbolHeight
            self.reels[index] = reel
        end
    end

    self:Reset()
end

function BonuslSlot:__delete()
    self:Reset()
end

function BonuslSlot:Reset()
    -- -- 移除所有顶部图案
    self:RemoveTopSymbol()
    -- self.scrollReels = {}
    self.lastKeepSymbolInfo = {}

    -- -- 显示底部图案
    for k, v in pairs(self.reels) do
        for i = 1, v.symbolNum do
            v.arraySymbolDisplays[i].render.visible = true
        end
    end
end

-- @brief 滚动开始
function BonuslSlot:SpinStart()
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    -- self:SetFreeCount(self.freeCount - 1)
    -- self:StopCumulativeAnimation()

    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        if not self.lastKeepSymbolInfo[k] then
            local topSymbol = self.topSymbols[k]
            if topSymbol then topSymbol:SetVisible(false) end
            v:SpinForever()
        end
    end
end

-- @brief 设置图案数据
function BonuslSlot:SetReelSymbolData(spinData, callback, isReconnect)
    self.onFinishCallback = callback
    self.spinData     = spinData
    self.grids        = spinData.grids
    self.totalCount   = spinData.lottyGameRestCount
    -- 整理服务器数据
    local reelDatas = {}
    for k, v in pairs(self.grids) do
        reelDatas[k] = {{
            icon = v.icon,
            value = v.symbolValue,
            type = v.symbolType,
            ishide = 0,             --v.ishide
        }}
    end

    -- 断线重连
    if isReconnect then
        self:Reset()
        -- 直接设置图案
        for k, v in pairs(self.reels) do
            v:Recovery(reelDatas[k])
            self:OnReelScrollStop(k, isReconnect)
        end
        self:OnSpinOver(self.grids, isReconnect)
        return
    end

    -- 筛选需要刷新的图案
    local needUpdateReels = {}
    for k, v in pairs(self.reels) do
        if self.lastKeepSymbolInfo[k] then
            self.lastKeepSymbolInfo[k].isNewAdd = false
        else
            table.insert(needUpdateReels, {index = k, reel = v})
        end
    end

    -- table.sort(needUpdateReels, function(a, b) return Utils.ConvertIndex(a.index) < Utils.ConvertIndex(b.index) end)

    -- 设置最终停止数据
    local count = 0
    for k, v in pairs(needUpdateReels) do
        v.reel:Stop(reelDatas[v.index], function()
            count = count + 1
            self:OnReelScrollStop(v.index, isReconnect)
            if count >= #needUpdateReels then
                self:OnSpinOver(self.grids, isReconnect)
            end
        end, 0.06 * (k - 1))
    end
end

-- @brief 转轴滚动结束
-- @param isReconnect 断线重连，跳过动画
function BonuslSlot:OnReelScrollStop(index, isReconnect)
    -- 替换动画到顶层显示
    local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
    -- 如果显示顶层图案则隐藏底部转轴图案
    local data = arraySymbolDisplays[1].data
    arraySymbolDisplays[1].render.visible = false
    local topSymbol = self:GetOrCreateTopSymbol(index,"bonus")
    topSymbol:SetIcon(index,data,true,self.isReconnect)
    if not Utils.IsBonus(data.icon) then
        arraySymbolDisplays[1].render.visible = true
        topSymbol:SetVisible(false)
    end

    local soundStopUrl = "ui://Game485/reelstop"

    -- 是否需要在落地牌中常驻
    if Utils.IsBonus(data.icon) then
        if FCasinoCtx:GetGame():CheckBonusIconLock(index) then
            soundStopUrl = "ui://Game485/UFCS_HAP_FBTally_Level1_A"
        else
            soundStopUrl = "ui://Game485/UFCS_HAP_Fireball_Ant_Locked"
        end

        self.lastKeepSymbolInfo[index] = {index = index,isNewAdd = true, data = data}
        topSymbol:ShowAnim()
    end

    if not isReconnect then
        FToolSet.PlayFGUISound( soundStopUrl )
    end
end

-- @brief 全部滚动完毕
function BonuslSlot:OnSpinOver(grids, isReconnect)
    FCasinoCtx:GetGame():SetCollectCnt(grids)
    -- 不播放动画，直接回调
    if self.totalCount == 0 and not isReconnect then
        self.jackpotValue = 0
        local bJackpot,totalWin = Utils.IsGrandJackpot(self.grids)
        print("BonuslSlot:OnSpinOver:",bJackpot,totalWin)
        if bJackpot then
            -- self.jackpotValue = self.spinData.bonusWinCoin - totalWin
            -- FCasinoCtx:GetGame():SetCharWin(self.jackpotValue)
            -- FCasinoCtx:GetGame():ShowJackpot(FToolSet.NumToStr(self.jackpotValue),function()
            --     FCasinoCtx:GetGame():HideJackpot()
            --     self:PlayMoneySettlement()
            -- end)
            print("TODO Jackpot ??")
            self:PlayMoneySettlement()
        else
            self:PlayMoneySettlement()
        end
    else
        self:DispatchFinishCallback()
    end
end

function BonuslSlot:PlayMoneySettlement()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)

    FCasinoCtx:GetGame():StopBgm()
    FToolSet.PlayFGUISound( "ui://Game485/UFCS_HAP_TransOut" )

    FCasinoCtx:GetGame():DelayFunc( 1.5, function ()
        FCasinoCtx:GetGame().uiBonusLock:GetTransition("complete_show"):Play()
        FCasinoCtx:GetGame():SetBonusCnt( 0, true )
        FToolSet.PlayFGUISound( "ui://Game485/UFCS_HAP_FBTally_TransOut" )
    end)
    
    FCasinoCtx:GetGame():DelayFunc( 1.5+6, function ()
        FCasinoCtx:GetGame().uiBonusLock:GetTransition("complete_hide"):Play()

        self.flyTweeners = {}
        local idx,totalWin = 0,0
    
        local keepSymbolInfo = FCasinoCtx:GetGame():SiftUnlockIcon( self.lastKeepSymbolInfo )
    
        FCasinoCtx:GetGame().uiBonusWinNum.text = 0
        FCasinoCtx:GetGame().render:GetController("c1").selectedPage = "bonus_win"
        
        local maxKey = #keepSymbolInfo
        for k,v in pairs(keepSymbolInfo) do
            if  Utils.IsBonus(v.data.icon) then
                local render = self.topSymbols[v.index]
                if render then
                    idx = idx + 1
                    FTween.Start(self.bottomContainer,FTween.Delay(1 * idx,function()
                        local xy = render:GetRootPos()
                        totalWin = totalWin + v.data.value
                        local tween = self:CreateFly(xy,totalWin,maxKey == k,render)
                        table.insert(self.flyTweeners,tween)
                    end))
                else
                    print("not find render",k)
                end
            end
        end
    end)
end

local CfgFlySound = {
    "ui://Game485/UFCS_HAP_FBTally_Level1_A",
    "ui://Game485/UFCS_HAP_FBTally_Level1_B",
    "ui://Game485/UFCS_HAP_FBTally_Level1_C",
    "ui://Game485/UFCS_HAP_FBTally_Level1_D",
}

function BonuslSlot:CreateFly(xy,win,bEnd,topSymbol)
    local fly = FairyGUI.UIPackage.CreateObject("Game485", "Fly")
    if not fly then
        print("not found Game485 Fly")
        return
    end

    FToolSet.PlayFGUISound( CfgFlySound[math.random(1,#CfgFlySound)] )

    local container =  FCasinoCtx:GetGame().effect_layer
    local posT = container:RootToLocal(xy)

    local uiBonusWin = FCasinoCtx:GetGame().uiBonusWin

    fly.pivot = vec2(0.5,0.5)
    fly.pivotAsAnchor = true
    fly.sortingOrder = 1000
    fly.xy = posT
    container:AddChild(fly)

    local pos = vec2(uiBonusWin.x-200+math.random(1,400), uiBonusWin.y-20)

    -- fly:GetTransition("enter"):Play()
    topSymbol.loader_icon.component:GetTransition("fly_enter"):Play()

    local tween = FTween.Start(fly,
        FTween.Delay(0.2,function()
            fly:GetTransition("fly"):Play()
        end),
        FTween.To(FairyGUI.TweenPropType.Position, fly.xy, pos, 0.1),
        FTween.CallFunc(function()
            fly:GetTransition("bomb"):Play()

            FCasinoCtx:GetGame():ShowBonusWin( win + self.jackpotValue )
            if bEnd then
                FToolSet.PlayFGUISound( "ui://Game485/UFCS_HAP_FBTally_Fanfare" )
                FCasinoCtx:GetGame():DelayFunc( 4, function ()
                    self:DispatchFinishCallback()
                end)                
            end

        end),
        FTween.Delay( 1,function() end),
        FTween.RemoveSelf()
    )
    return tween
end

function BonuslSlot:StopShowLine()
    if self.flyTweeners and #self.flyTweeners > 0 then
        for _, v in pairs(self.flyTweeners) do
            v.Kill()
        end
        self.flyTweeners = {}
    end
end


function BonuslSlot:DispatchFinishCallback()
    if self.onFinishCallback then
        self.onFinishCallback()
        self.onFinishCallback = nil
    end
end

return BonuslSlot
