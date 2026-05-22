local Utils             = Import(".Slot.Utils")
local Reel              = Import(".Slot.Reel")
local LotteryPanel      = Import(".LotteryPanel")
local NormalSlot        = Import(".Slot.NormalSlot")
local BonuslSlot        = Import(".Slot.BonuslSlot")
local FreeSelect        = Import(".Slot.FreeSelect")
local FreePanel        = Import(".Slot.FreePanel")
local CoinFountain      = require("FGame.Common.Logic.Effect.CoinFountain")
local MusicCfg = Import(".Slot.MusicCfg")
local Game485 = Class("Game485", BaseGame)

function Game485:ctor(render)
    self.cfgCard = {
        [0] = {node="card_20", mode="card20", enterAnim="c20_enter", seleAnim="c5_sele", notSeleAim="c5_not_sele", openiAim="c20_openi", openiiAim="c20_openii" },
        [1] = {node="card_15", mode="card15", enterAnim="c15_enter", seleAnim="c5_sele", notSeleAim="c5_not_sele", openiAim="c15_openi", openiiAim="c15_openii" },
        [2] = {node="card_10", mode="card10", enterAnim="c10_enter", seleAnim="c5_sele", notSeleAim="c5_not_sele", openiAim="c10_openi", openiiAim="c10_openii" },
        [3] = {node="card_7",  mode="card7",  enterAnim="c7_enter",  seleAnim="c5_sele", notSeleAim="c5_not_sele", openiAim="c7_openi",  openiiAim="c7_openii"  },
        [4] = {node="card_5",  mode="card5",  enterAnim="c5_enter",  seleAnim="c5_sele", notSeleAim="c5_not_sele", openiAim="c5_openi",  openiiAim="c5_openii"  },
        [5] = {node="card_random", mode="cardrandom", enterAnim="crd_enter", seleAnim="c5_sele", notSeleAim="c5_not_sele", openiAim="crd_openi", openiiAim="crd_openii" },
    }
    
    self.render = render
    self.slot = self.render:GetChild("slot")
    self.slotContainer = {}
    self.slotContainer[FGameMode.NORMAL] = NormalSlot.New(self.slot:GetChild("normalContainer"),false)
    self.slotContainer[FGameMode.FREE] = NormalSlot.New(self.slot:GetChild("freeContainer"),true)
    self.slotContainer[FGameMode.SPECIAL] = BonuslSlot.New(self.slot:GetChild("bonusContainer"),false)
    --特效层
    self.effect_layer = self.render:GetChild("effect_layer")

    --落地牌
    self.uiBonusLock = self.slot:GetChild("bouns_lock")
    self.uiBonusLock.visible = false
    self.uiCellLocks = {}
    --从下向上
    self.CfgUnlockNums = { 0,0,0,0, 8,12,16,20 }
    for i = 1, 4 do
        local info = {}
        info.render = self.uiBonusLock:GetChild("cell_lock_"..i)
        info.uiNum = info.render:GetChild("num")
        info.lockTotal = self.CfgUnlockNums[4+i]
        info.isShow = true
        self.uiCellLocks[i] = info
    end
    self.lastUnlockCount = 0

    self.lastCellData = {}

    --免费选择
    self.freeSelectType = nil

    self.charTip = {
        root = self.render:GetChild("charTip")
    }
    self.charTip.tip_top = self.charTip.root:GetChild("tip_top")
    self.charTip.tip_title = self.charTip.root:GetChild("title")
    self.charTip.free_current = self.charTip.root:GetChild("free_current")
    self.charTip.free_total = self.charTip.root:GetChild("free_total")

    self.jackpot = self.render:GetChild("jackpot")
    self.collectTip = self.render:GetChild("collectTip")

    self.jackpot.visible = false

    self.level = 1
    self.bottomWinValue = 0

    -- 喷金币管理
    self.coinFountain = CoinFountain.New()
    self.coinFountain:SetSortingOrder(5)

    self.coinfire = self.render:GetChild("coinfire")
    self.coinfire:GetTransition("def"):Play()
    self.isCoinfireStop = false

    -- 彩金面板
    self.botteryPanel = LotteryPanel.New(render:GetChild("lottery"))

    self.uiFreePanel = FreePanel.New( render:GetChild("free_panel") )

    self.uiBonusWin = render:GetChild("bonus_win")
    self.uiBonusWinNum = self.uiBonusWin:GetChild("num")

    self:SetGameMode(FGameMode.NORMAL)
    self:SetSloteMode(FGameMode.NORMAL)

    -- 监听网络断开事件
    FSysEventEmitter:AddListener(FSysEvent.ON_NET_DISCONNECT, function()
        self.curNormalSpinResult = nil
        self.curFreeSpinResult = nil
        self.curSpecialSpinResult = nil
        print( "Game485:ctor FSysEvent.ON_NET_DISCONNECT" )
    end, self)

    self.ngBgm = nil

    self.uiEfStar = self.render:GetChild("particle_star")
    self.efStar = APIGateway.PlayParticleEffect("Game485/particle/311_yuanlizi",self.uiEfStar)
    APIGateway.StopParticleEffect( self.efStar )
    self.uiEfStar.sortingOrder = 100

    self.render:GetChild("ef_fireball").sortingOrder = 150

    self.render:GetChild("ef_white").sortingOrder = 200

    self:ShowFlyFireball()
end

function Game485:__delete()
    self:Clear()

    if self.tipInfoTweener then
        self.tipInfoTweener.Kill()
        self.tipInfoTweener = nil
    end
    
    for k, v in pairs(self.slotContainer) do
        v:Delete()
    end

    self.coinFountain:Delete()
    if self.BigWinAnim then
        self.BigWinAnim:Delete()
    end
    self.botteryPanel:Delete()

    self.uiFreePanel:Delete()
end

-- @interface
-- @brief update
function Game485:Update(dt)
    Game485.super.Update(self, dt)

    for k, v in pairs(self.slotContainer) do
        v:Update(dt)
    end

    self.uiFreePanel:Update(dt)
end

function Game485:Clear()
    FCasinoCtx.commonPanel:ShowTop(true, false)
    self:StopDelayCallSpin()
end

function Game485:ShowFlyFireball()
    self.flyFireBall = self.render:GetChild("fly_fireball")
    local balls = {}
    for i = 1,3 do
        balls[i] = self.flyFireBall:GetChild("ball_"..i)
        balls[i].visible = false
    end

    local callFlyI = nil
    callFlyI = function ( index, finish )
        self:DelayFunc( math.random(0,3), function ()
            local ball = balls[index]
            ball.visible = true
            local rotate = math.random(65,75)
            rotate = math.random(1,100)>50 and rotate or -rotate
            ball.rotation = rotate
            ball:GetTransition("fly").timeScale = math.random(10,30)/100
            ball:GetTransition("fly"):Play( function ()
                if index == 3 then
                    callFlyI( 3 )
                else
                    local new = index+1>2 and 1 or index+1
                    callFlyI( new, finish )    
                end
            end)                
        end )
    end
    callFlyI( 1 )
    self:DelayFunc( 2, function ()
        callFlyI( 3 )
    end)

end

function Game485:ShowEfStar( value )
    if value ~= false then
        self.uiEfStar.visible = true
        APIGateway.ReplayParticleEffect( self.efStar )
    else
        APIGateway.StopParticleEffect( self.efStar )
        self:DelayFunc( 1.5, function ()
            self.uiEfStar.visible = false
        end)
    end
end

function Game485:GetTipPos()
    return self.charTip.root:LocalToRoot(vec2(0,0))
end

function Game485:SetTotalWin(value)
    self.bottomWinValue = value
    FCasinoCtx.commonPanel:SetWinMoney(value,false)
end

function Game485:SetGameMode(mode)
    FCasinoCtx:SetGameMode(mode)
    self.curSlotType = mode
    print("SetGameMode",mode)
end

function Game485:SetSloteMode(mode)
    self.render:GetController("c1").selectedIndex = mode - 1
    self.slot:GetController("c1").selectedIndex = mode - 1
end

-- @brief 播放赢钱动画
function Game485:PlaySettlementAnimation(curWinCoin,callBack,settlement,showWinValue)
    print("Game485:PlaySettlementAnimation curWinCoin:",curWinCoin)

    if not settlement then
        self.bottomWinValue = self.bottomWinValue + curWinCoin
    else
        FCasinoCtx.commonPanel:StopScrollWinMoney(0)
        curWinCoin = self.bottomWinValue
    end

    self.bottomWinValue = showWinValue or self.bottomWinValue
    
    local cfgSound = MusicCfg:GetWinChipCfg( curWinCoin )

    -- 喷金币
    -- if cfgSound.isOpenFire then
    --     self.coinFountain:Play()
    -- end

    --碰金币 先检查显示bigwin
    local delayShow = 0
    if cfgSound.isOpenFire and cfgSound.playFire then
        delayShow = 4
    end
    if delayShow > 0 then
        self.isShowBigwin = true
        self.coinfire:GetTransition("bigwinanim"):Play()
        FToolSet.PlayFGUISound( "ui://Game485/BigWin" )
        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    end

    --在延时碰金币
    self:DelayFunc( delayShow, function ()
        self.isShowBigwin = false
        if cfgSound.isOpenFire and cfgSound.playFire then
            self.isCoinfireStop = false
            self:PlayBigWinFire( cfgSound.playFire )
        end

        if self.settlementSound then
            APIGateway.StopSound(self.settlementSound)
        end
    
        if FCasinoCtx.curGameMode == FGameMode.FREE and self.curFreeSpinResult and
           self.curFreeSpinResult.freeGameCurCount < self.curFreeSpinResult.freeGameTotalCount  then
            self.settlementSound = FToolSet.PlayFGUISound( cfgSound.urlSc )
        else
            self.settlementSound = FToolSet.PlayFGUISound( cfgSound.url )
        end
        
        self.lastCfgSound = cfgSound
    
        FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
        --累积赢
        FCasinoCtx.commonPanel:ScrollWinMoneyTo(self.bottomWinValue, cfgSound.time, function()
            self:StopSettlement()
            if callBack then
                callBack()
            end
        end)            
    end)

end

function Game485:PlayBigWinFire( playName )
    self.coinfire:GetTransition( playName ):Play( function ()
        if self.isCoinfireStop == true then
            if not self.isShowBigwin then
                self.coinfire:GetTransition( "def" ):Play()
            end
        else
            self:PlayBigWinFire( playName )
        end
    end)
end

function Game485:StopSettlement()
    self.coinFountain:Stop()
    self.isCoinfireStop = true
    if self.settlementSound then
        APIGateway.StopSound(self.settlementSound)
        self.settlementSound = nil
        if FCasinoCtx.curGameMode == FGameMode.FREE and self.lastCfgSound and self.curFreeSpinResult and
           self.curFreeSpinResult.freeGameCurCount < self.curFreeSpinResult.freeGameTotalCount then
            FToolSet.PlayFGUISound( self.lastCfgSound.urlScStop )
        end    
    end
end

function Game485:SetEnterBonusTip()
    self.charTip.root:GetController("c1").selectedPage = "bonus_num3"
end

function Game485:SetFreeCnt(curcnt,totalcnt)
    self.charTip.root.visible = true
    self.charTip.root:GetController("c1").selectedPage = "free"
    self.charTip.free_current.text = curcnt
    self.charTip.free_total.text = totalcnt
end

function Game485:SetBonusCnt(leftcnt, isHide)
    print("Game485:SetBonusCnt:"..leftcnt)

    self.charTip.root.visible = not isHide
    
    self.BonusCnt = leftcnt
    local num = (leftcnt>=0 and leftcnt<=3) and leftcnt or 3
    self.charTip.root:GetController("c1").selectedPage = "bonus_num" .. num

    if not isHide and num == 3 then
        self.charTip.root:GetTransition("reset"):Play()
    end
end

--检查bonus图标是否锁住
function Game485:CheckBonusIconLock( logicIndex )
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local row = math.floor((logicIndex-1)/reelCfg.xCellNumberBouns)+1
    local lockNum = self.CfgUnlockNums[#self.CfgUnlockNums-row+1]
    local isLock = self.lastUnlockCount>lockNum
    return isLock
end

--筛选解锁的落地牌
function Game485:SiftUnlockIcon( lastKeepSymbolInfo )
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local data = {}
    for logicIndex = 1, reelCfg.xCellNumberBouns * reelCfg.yCellNumberBouns do
        local row = math.floor((logicIndex-1)/reelCfg.xCellNumberBouns)+1
        local lockTotal = self.CfgUnlockNums[ #self.CfgUnlockNums-row+1 ]
        local symbol = lastKeepSymbolInfo[logicIndex]
        if symbol and lockTotal <= self.lastUnlockCount then
            table.insert( data, symbol )
        end
    end
    return data
end

--落地牌锁刷新
function Game485:RefreshBounsLock( showuUnlock )
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local lockCount = 0
    local topSymbols = self.slotContainer[FGameMode.SPECIAL].topSymbols
    --从下向上 8-1
    for logicIndex = reelCfg.xCellNumberBouns * reelCfg.yCellNumberBouns, 1, -1 do
        local topSymbol = topSymbols[logicIndex]
        local row = math.floor((logicIndex-1)/reelCfg.xCellNumberBouns)+1
        local lockTotal = self.CfgUnlockNums[ #self.CfgUnlockNums-row+1 ]
        -- print( "row:",row,"logicIndex:",logicIndex,"lockTotal:",lockTotal )
        if topSymbol and Utils.IsBonus(topSymbol.data.icon) then
            if lockTotal <= lockCount then
                lockCount = lockCount + 1
            else
                break
            end
        end
    end
    --锁状态
    for _, cellLock in pairs( self.uiCellLocks ) do
        if cellLock.lockTotal <= lockCount then
            if showuUnlock and cellLock.isShow then
                FToolSet.PlayFGUISound( "ui://Game485/UFCS_HAP_Unlock" )
                cellLock.render:GetTransition("destory"):Play( function ()
                    cellLock.render:GetTransition("hide"):Play()
                    cellLock.isShow = false
                end )
            else
                cellLock.render:GetTransition("hide"):Play()
                cellLock.isShow = false
            end
        else
            cellLock.uiNum.text = cellLock.lockTotal - lockCount
        end
    end
    self.lastUnlockCount = lockCount
    print("Game485:RefreshBounsLock lastUnlockCount:",self.lastUnlockCount)
end

function Game485:ResetBonusCnt( showuUnlock )
    self:SetBonusCnt(3)
    self:RefreshBounsLock( showuUnlock )
end


function Game485:SetCharTip(str)
    self.charTip.root:GetController("c1").selectedPage = "char"
    self.charTip.tip_top.text = str
end

function Game485:SetCharWin(value)
    self.charTip.root:GetController("c1").selectedPage = "win"
    self.charTip.root.title = FToolSet.NumToStr(value)
    self.bottomWinValue = value
end

function Game485:ShowBonusWin( value )
    self.uiBonusWin:GetTransition("ef_show"):Play()
    self.uiBonusWinNum.text = FToolSet.NumToStr(value)
    self.bottomWinValue = value
end

function Game485:SetCollectCnt(grids)
    local count = 0
    for _,v in pairs(grids) do
        if Utils.IsBonus(v.icon) then
            count = count + 1
        end
    end
    self.collectTip.title = count
end

--免费数据选择
function Game485:ShowFreeSelectType( msgSelectType )
    if table.equals(self.freeSelectType, msgSelectType) then
        return
    end
    self.freeSelectType = msgSelectType
    local mode = self.cfgCard[self.freeSelectType.type] and 
                self.cfgCard[self.freeSelectType.type].mode or "card_5"
    self.uiFreePanel:ShowCard( mode, self.freeSelectType )
end

function Game485:ShowGameTip(modeStr,value,callback)
    print( "Game485:ShowGameTip:", modeStr )

    if modeStr == "freeEnter" then
        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
        self.freeSelectType = nil
        if self.uiFreeSelect then
            self.uiFreeSelect:Delete()
            self.uiFreeSelect = nil
        end
        self.uiFreeSelect = FreeSelect.New( self.render, self.slot.xy )
        self.slot:GetChild("normalContainer").visible = false
        self.uiFreeSelect:SetCardCoverCallback( function ( selectType )
            self.slot:GetChild("normalContainer").visible = true
            self.uiFreePanel:Init()
            self:SetSloteMode(FGameMode.FREE)
            self:SetFreeCnt(0, selectType.times)
        end)
        self.uiFreeSelect:SetCardDownCallback( function ( _, msgSelectType )
            self:ShowFreeSelectType( msgSelectType )
            self:DelayFunc( 0.5, callback )
        end)
    elseif modeStr == "freeEnterNew" then
        self:DelayFunc( 0.5, callback )
    elseif modeStr == "gameSettle" then
        local delay = 3
        if FCasinoCtx.curGameMode == FGameMode.FREE then
            self.uiFreePanel:ShowTotalWin()
            delay = 5
        end
        self:DelayFunc( delay, function ()
            self.render:GetTransition("white_show"):Play( callback )
        end )
    elseif modeStr == "bonusEnter" then
        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)

        self.uiBonusLock:GetTransition("complete_hide"):Play()
        self.render:GetTransition("fireball_show"):Play()
        self.uiBonusLock.visible = false
        self.lastUnlockCount = 0

        --全部遮盖
        self:DelayFunc( 4, function ()
            self:SetGameMode(FGameMode.SPECIAL)
            self:SetSloteMode(FGameMode.SPECIAL)

            self.slot:GetController("c1").selectedPage = "bouns_anim"
            self.slotContainer[FGameMode.SPECIAL].parent.visible = false
        end  )

        --火球结束 拉高 走火格子
        FToolSet.PlayFGUISound("ui://Game485/UFCS_HAP_TransIn")
        self.animBouns = self.animBouns or self.slot:GetChild("bouns_anim")
        self.animBouns:GetTransition("init"):Play()
        self:DelayFunc( 4, function ()
            self.animBounsGrid = self.animBouns:GetChild("grid")
            if self.animBounsEfs == nil then
                self.animBounsEfs = {}
                for i = 1, 2 do
                    self.animBounsEfs[100+i] = self.animBounsGrid:GetChild("sp_1_"..i)
                end
                for i = 1, 4 do
                    self.animBounsEfs[200+i] = self.animBounsGrid:GetChild("sp_2_"..i)
                end
                for i = 1, 7 do
                    self.animBounsEfs[300+i] = self.animBounsGrid:GetChild("sp_3_"..i)
                end
                for _, ef in pairs( self.animBounsEfs ) do
                    APIGateway.PlayParticleEffect("Game485/particle/311_ldp_fire1",ef)
                end
            end
            self.animBouns:GetTransition("show"):Play( function ()
                self.animBounsGrid:GetTransition("show").timeScale = 0.7
                self.animBounsGrid:GetTransition("show"):Play( function ()
                    self:SetBonusCnt( 3 )
                end)
            end )
        end  )

        --显示锁 点击继续
        for _, cellLock in ipairs( self.uiCellLocks ) do
            cellLock.render:GetTransition("init"):Play()
            cellLock.isShow = true
        end
        self:DelayFunc( 4+3+2, function ()
            self:SetSloteMode(FGameMode.SPECIAL)
            self.slotContainer[FGameMode.SPECIAL].parent.visible = true
            self:RefreshBounsLock()
            self.uiBonusLock.visible = true
            for i = 1,4 do
                self:DelayFunc( i*0.5, function ()
                    FToolSet.PlayFGUISound("ui://Game485/UFCS_HAP_TransIn_LockRow"..i)
                end )
            end
            self.uiBonusLock:GetTransition("enter"):Play( function ()
                self:StopBgm()
                local waitLoop = FToolSet.PlayFGUISound("ui://Game485/UFCS_HAP_WaitLoop")
                
                local _callPrass = function ()
                    APIGateway.StopSound( waitLoop )
                    FToolSet.PlayBGM("ui://Game485/UFCS_HAP_Loop")
                    self.uiBonusLock:GetTransition("passed"):Play()
                    if callback then callback() end
                end
                APIGateway.AddEventListener( self.uiBonusLock:GetChild("btn_press"), FGUIEventKey.onClick, function()
                    if _callPrass then _callPrass() end
                    _callPrass = nil
                end, true )
                self:DelayFunc( 13, function ()
                    if _callPrass then _callPrass() end
                    _callPrass = nil
                end )
            end)
        end )        
    end
end

function Game485:ShowJackpot(value,callback)
    self.jackpot.visible = true
    self.jackpot.title = value
    FTween.Start(self.jackpot, FTween.Delay(4.0,callback))
end

function Game485:HideJackpot()
    self.jackpot.visible = false
end

function Game485:EnterFree(spinData)
    --设置免费格子数据
    self.slotContainer[FGameMode.NORMAL]:StopShowLine()
    self.slotContainer[FGameMode.FREE]:SetReelSymbolData(spinData,nil,true)
    --提示进入免费
    self:ShowGameTip("freeEnter",6,function()
        self:StopBgm()
        FToolSet.PlayBGM("ui://Game485/UFCS_FG_Loop")
        
        self:DelayFunc( 0.5, function ()
            --断线重连时 可能修改状态
            if self.curSlotType ~= FGameMode.FREE then
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                self:SetGameMode(FGameMode.FREE)
                self:AutoClick()
            end
        end )
    end)
end

function Game485:EnterBonus(spinData)
    local _spinData = clone( spinData )

    --格子数据加工
    local _grids = {}
    for i = 1, 20 do
        local data = {
            icon  = math.random(1, 8),
            index = i-1,
            symbolType  = 0,
            symbolValue = 0
        }
        table.insert(_grids,data)
    end
    for _, info in ipairs( _spinData.grids ) do
        info.index = info.index + 20
        table.insert(_grids,info)
    end
    _spinData.grids = _grids

    --线数据加工
    for _, line in ipairs( _spinData.lines ) do
        for _, cell in ipairs(line.lineCells) do
            cell.index = cell.index + 20
        end
    end

    self:SetBonusCnt( 3, true )
    self:SetCollectCnt(_spinData.grids)
    self.slotContainer[FGameMode.NORMAL]:StopShowLine()
    self.slotContainer[FGameMode.SPECIAL]:SetReelSymbolData(_spinData,nil,true)
    --进入落地牌提示
    self:ShowGameTip("bonusEnter",3,
        function()
            --动画结束
            self:SetGameMode(FGameMode.SPECIAL)
            self:SetSloteMode(FGameMode.SPECIAL)
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:AutoClick()
        end
    )
end

--showWinValue:直接显示设置分数
function Game485:ExitSpecial(spinData,isReconnect,showWinValue)
    print("Game485:ExitSpecial showWinValue:"..showWinValue)
    
    self.slotContainer[self.curSlotType]:StopShowLine()
    --检查免费自动
    local function nextStep()
        --落地牌结束需要重置数据
        self.slotContainer[FGameMode.SPECIAL]:Reset()
        --关闭中线逻辑
        self:StopBgm()
        FCasinoCtx:SetPlayerMoneyInfo(spinData)
        FCasinoCtx:SyncPlayerMoneyDisplay(2)
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        self:SetGameMode(FGameMode.NORMAL)
        self.slotContainer[FGameMode.NORMAL].parent.visible = true
        self:AutoClick()
    end

    --断线重连 跳过动画流程
    if isReconnect then
        local win = showWinValue or 0
        self:SetTotalWin( win )
        self:SetLastCellData(nil,FGameMode.NORMAL)
        self:SetSloteMode(FGameMode.NORMAL)
        nextStep()
    else
        --结算提示
        self:ShowGameTip("gameSettle", FToolSet.NumToStr(self.bottomWinValue), function()
            self.uiBonusLock.visible = false
            self.render:GetTransition("white_hide"):Play()
            self:SetLastCellData(nil,FGameMode.NORMAL)
            self:SetSloteMode(FGameMode.NORMAL)
            self:PlaySettlementAnimation( 
                self.bottomWinValue,
                function()
                    nextStep()
                end,
                self.curSlotType ~= FGameMode.NORMAL,
                showWinValue
            )
        end)
    end
end

function Game485:SetLastCellData(spinData,mode)
    spinData = spinData or self.lastCellData[mode]
    if spinData == nil then return end
    self.slotContainer[mode]:SetReelSymbolData(spinData,nil, true)
    self.lastCellData[mode] = nil
end

-- @interface
-- @brief 在游戏中断线重连恢复游戏
-- @param msg 断线重连数据
function Game485:ReconnectRecoveryGame(msg, isInitialize)
    -- 断线重连标记
    self.isReconnect = true

    -- 最后一次回复玩家的消息类型
    -- 0 玩家刚进入房间时的默认状态。resumedXXX系列数据都为空
    -- 1 normal游戏状态
    -- 2 已发送类型选择包，但是还没发送FreeSpin或SpecialSpin来获取结果
    -- 3 免费游戏
    -- 4 落地牌游戏

    dump( msg,"Game485:ReconnectRecoveryGame isInitialize:"..tostring(isInitialize)..
              " msg.lastMsgType:"..msg.lastMsgType, 2 )

    if msg.lastMsgType == 1 then
        print("普通 断线重连")
        local spinData = msg.resumedNormal.normalSpin
        if spinData.intoFree == 1 then
            print("中免费 免费选择")
            if isInitialize then
                self:SetLastCellData( spinData, FGameMode.NORMAL )
                self:SetTotalWin( spinData.winCoin )
                self.curNormalSpinResultII = spinData
                self.slotContainer[FGameMode.NORMAL]:SetReelSymbolData(spinData, nil, true)
                self:EnterFree( spinData )
            else
                self:OnNormalSpinResult(spinData)
            end
        elseif spinData.intoSpecial >= 1 then
            print("中落地牌")
            if isInitialize then
                self:SetTotalWin( spinData.winCoin )
                self.curNormalSpinResultII = spinData
                self.slotContainer[FGameMode.NORMAL]:SetReelSymbolData(spinData, nil, true)
                self:EnterBonus(spinData)
            else
                if self.isRequestSpecial then
                    print("第一个落地牌包不发")
                    self:RequestSpecial()
                else
                    self:OnNormalSpinResult(spinData)
                end
            end
        else
            -- 普通断线重连 状态错误 auto 停止
            -- self:SetLastCellData( spinData, FGameMode.NORMAL )
            if table.equals(spinData, self.curNormalSpinResultII) and self.isRequestNormal then
                self:RequestNormal()
                --??
                -- self.curNormalSpinResultII = nil
                -- self:OnNormalSpinResult(spinData)
            else
                self:OnNormalSpinResult(spinData)
            end
        end
    elseif msg.lastMsgType == 2 then
        print("中免费 已发送类型选择包, 但是还没发送FreeSpin或SpecialSpin来获取结果")
        local selectType = msg.resumedSelect.selectType
        if isInitialize then
            self:SetTotalWin( msg.resumedNormal.normalSpin.winCoin )
            self:SetLastCellData(msg.resumedNormal.normalSpin,FGameMode.NORMAL)
            self:SetFreeCnt(0, selectType.times)
            self:SetGameMode(FGameMode.FREE)
            self:SetSloteMode(FGameMode.FREE)
            self.slotContainer[FGameMode.FREE]:SetReelSymbolData(msg.resumedNormal.normalSpin,nil, true)
            FToolSet.PlayBGM("ui://Game485/UFCS_FG_Loop")
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:AutoClick()
            self:ShowFreeSelectType( selectType )
        else
            print("中免费 选择中 断线 已选")
            --bug 重连 到选择 发包断线
            if self.isRequestFree then
                print("发送第一个免费发包断线")
                self:RequestFree()
            elseif self.uiFreeSelect and 
               not APIGateway.IsInvalidObject( self.uiFreeSelect.render ) then
                print("选择回包时断线")
                self.uiFreeSelect:ShowPickOne( selectType.type, selectType )
            else
                print("发送第一个免费发包断线 ??")
                self:RequestFree()
            end
        end

    elseif msg.lastMsgType == 3 then
        print("中免费 免费期间")
        self:SetTotalWin( msg.resumedFree.freeSpin.totalWinCoin )

        local selectType = msg.resumedSelect.selectType
        self:ShowFreeSelectType( selectType )
        
        --设置正常转轮数据防止切换游戏模式时候断线重连 该数据异常导致转轮状态问题
        -- self:SetLastCellData(msg.resumedNormal.normalSpin,FGameMode.NORMAL)
        self.lastCellData[FGameMode.NORMAL] = msg.resumedNormal.normalSpin

        self:OnFreeSpinResult(msg.resumedFree.freeSpin)
        
        if msg.resumedFree.freeSpin.freeGameCurCount < msg.resumedFree.freeSpin.freeGameTotalCount then
            FToolSet.PlayBGM("ui://Game485/UFCS_FG_Loop")
        end

    elseif msg.lastMsgType == 4 then
        print("中落地牌 落地牌期间")
        local spinData = msg.resumedSpecial.specialSpin

        -- 会打乱状态 结算收分时断线重连 收分会停下
        -- local curSpinStatus = clone(FCasinoCtx.curSpinStatus)
        -- self:SetLastCellData(msg.resumedNormal.normalSpin,FGameMode.NORMAL)
        -- FCasinoCtx:SetSpinStatus( curSpinStatus )
        self.lastCellData[FGameMode.NORMAL] = msg.resumedNormal.normalSpin

        self.uiBonusLock:GetTransition("complete_hide"):Play()

        self:SetBonusCnt(spinData.lottyGameRestCount)
        self:OnSpecialSpinResult(spinData)

        if spinData.lottyGameRestCount == 0 then
            if isInitialize then
                self:SetTotalWin( 0 )
            -- else
            --     self:SetTotalWin( msg.resumedSpecial.specialSpin.totalWinCoin )
            end
        else
            FToolSet.PlayBGM("ui://Game485/UFCS_HAP_Loop")
            self:SetTotalWin( msg.resumedNormal.normalSpin.winCoin )
            if isInitialize then
                self:RefreshBounsLock()
                self.uiBonusLock.visible = true
                self.uiBonusLock:GetTransition("passed"):Play()
            end
        end
    elseif msg.lastMsgType == 0 then
        if not isInitialize and self.isRequestNormal then
            self:RequestNormal()
        end
    end
    self.isReconnect = false
end

-- @interface
-- @brief 点击开始按钮
function Game485:OnClickSpin()
    FToolSet.PlayFGUISound("ui://Game485/click_spin")
    self:StopDelayCallSpin()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        if not FCasinoCtx:PlayerSpinConsumption() then
            return
        end
        self:SetTotalWin(0)
        self.slotContainer[self.curSlotType]:StopShowLine()
        self.slotContainer[self.curSlotType]:SpinStart()
        --随机一个提示
        self:RequestNormal()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.slotContainer[self.curSlotType]:StopShowLine()
        self.slotContainer[self.curSlotType]:SpinStart()
        self:RequestFree()
        self.uiFreePanel:HideDouble()
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        --自动减一次
        self.BonusCnt = self.BonusCnt - 1
        self:SetBonusCnt(self.BonusCnt)

        self.slotContainer[self.curSlotType]:StopShowLine()
        self.slotContainer[self.curSlotType]:SpinStart()
        self:RequestSpecial()
    end
end

function Game485:RequestNormal()
    self.isRequestNormal = true
    self:SendNormalSpin("PB.Client_Slots.FireLinkNormalSpin",
    "PB.Slots_Client.FireLinkNormalRet", function(ok, result)
        if not ok then return end
        self.isRequestNormal = false
        self:OnNormalSpinResult(result.normalSpin)
    end)
end

function Game485:RequestFree()
    if self.uiFreeSelect then
        self.uiFreeSelect:Delete()
        self.uiFreeSelect = nil
    end
    local request = {
        _msgName_ = "PB.Client_Slots.FireLinkFreeSpin"
    }
    --true:更多情况表示正在旋转
    self.isRequestFree = true
    APIGateway.SendExactRequest(request, "PB.Slots_Client.FireLinkFreeRet", function(ok, result)
        if not ok then return end
        self.isRequestFree = false
        self:OnFreeSpinResult(result.freeSpin)
    end)
end

function Game485:RequestSpecial()
    local request = {
        _msgName_ = "PB.Client_Slots.FireLinkSpecialSpin"
    }
    self.isRequestSpecial = true
    APIGateway.SendExactRequest(request, "PB.Slots_Client.FireLinkSpecialRet", function(ok, result)
        if not ok then return end
        self.isRequestSpecial = false
        self:OnSpecialSpinResult(result.specialSpin)
    end)
end

function Game485:OnClickStop()
    -- 普通游戏状态点击停止按钮
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.slotContainer[self.curSlotType]:QuickStop()
        self:StopSettlement()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.slotContainer[self.curSlotType]:QuickStop()
        self:StopSettlement()
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        FCasinoCtx.commonPanel:StopScrollWinMoney(nil, true)
        self:StopSettlement()
    end
end

-- @brief 处理普通旋转结果
-- @param clickIndexs 12选3 点击过的位置
function Game485:OnNormalSpinResult(spinData)
    dump(spinData,"Game485:OnNormalSpinResult",1)

    local isReconnect = self.isReconnect
    -- 当前正在运行的数据和断线重连下发的数据一样，直接忽略
    print("1 self.curNormalSpinResultII:"..tostring(self.curNormalSpinResultII))
    if isReconnect and table.equals(spinData, self.curNormalSpinResultII) then
        print("Game485:OnNormalSpinResult: 断线重连 相同数据")
        return
    end
    self.curNormalSpinResultII = clone(spinData)

    print("2 self.curNormalSpinResultII:"..tostring(self.curNormalSpinResultII))
    -- 清理所有界面
    self:Clear()
    self:SetGameMode(FGameMode.NORMAL)
    self:SetSloteMode(FGameMode.NORMAL)

    self.slotContainer[self.curSlotType]:SetReelSymbolData(spinData, function()
        -- 弹出模式选择界面
        if isReconnect then
            if spinData.intoFree == 1 then
                self:EnterFree(spinData)
                return
            elseif spinData.intoSpecial >= 1 then
                self:EnterBonus(spinData)
                return
            else
                FCasinoCtx:SetPlayerMoneyInfo(spinData)
                FCasinoCtx:SyncPlayerMoneyDisplay(2)
            end
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:AutoClick()
        else
            if spinData.intoFree == 1 then
                self:EnterFree(spinData)
            elseif spinData.intoSpecial >= 1 then
                self:EnterBonus(spinData)
            else
                self:FadeOutBgm()
                FCasinoCtx:SetPlayerMoneyInfo(spinData)
                FCasinoCtx:SyncPlayerMoneyDisplay(2)
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                self:AutoClick()
            end
        end
    end, isReconnect)
end

-- @brief 处理免费游戏旋转结果
function Game485:OnFreeSpinResult(spinData)
    dump(spinData,"Game485:OnFreeSpinResult",1)

    local isReconnect = self.isReconnect
    -- 当前正在运行的数据和断线重连下发的数据一样，直接忽略
    if isReconnect and table.equals(spinData, self.curFreeSpinResult) then
        return
    end
    self.curFreeSpinResult = clone(spinData)
    self.IsBoot = false

    print("Game485:OnFreeSpinResult isReconnect:",isReconnect)

    local wildScale = spinData.scale or 1

    -- 清理所有界面
    self:Clear()
    self:SetGameMode(FGameMode.FREE)
    self:SetSloteMode(FGameMode.FREE)
    self:SetFreeCnt(spinData.freeGameCurCount , spinData.freeGameTotalCount - spinData.intoFree)

    self.slotContainer[self.curSlotType]:SetAllReelStopCall( function ()
        --翻倍
        if wildScale > 1 then
            self.uiFreePanel:ShowDouble( wildScale )
        end        
    end)

    self.slotContainer[self.curSlotType]:SetReelSymbolData(spinData, function()
        -- 免费结束
        if spinData.freeGameCurCount >= spinData.freeGameTotalCount then
            if not isReconnect then
                self:StopBgm()
                FToolSet.PlayFGUISound( "ui://Game485/UFCS_FG_TransOut" )                    
            end
            self:ExitSpecial(spinData,isReconnect,spinData.totalWinCoin)
            self.freeSelectType = nil
        else
            if spinData.intoFree > 0 and not isReconnect then
                self:ShowGameTip("freeEnterNew",spinData.intoFree,function()
                    self:SetFreeCnt(spinData.freeGameCurCount , spinData.freeGameTotalCount)
                    self:AutoClick()
                end)
            else
                self:AutoClick()
            end
        end
    end, isReconnect)
end

-- @brief 处理特殊游戏旋转结果
function Game485:OnSpecialSpinResult(spinData)
    dump(spinData,"Game485:OnSpecialSpinResult",1)

    local isReconnect = self.isReconnect
    -- 当前正在运行的数据和断线重连下发的数据一样，直接忽略
    if isReconnect and table.equals(spinData, self.curSpecialSpinResult) then
        return
    end
    self.curSpecialSpinResult = clone(spinData)

    print("Game485:OnSpecialSpinResult Reconnect:", isReconnect)

    -- 清理所有界面
    self:Clear()
    self:SetGameMode(FGameMode.SPECIAL)
    self:SetSloteMode(FGameMode.SPECIAL)
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    -- 剩余免费次数(这个字段是特殊含义 会在0-3切换)
    local totalCount = spinData.lottyGameRestCount or 3

    self.slotContainer[self.curSlotType]:SetReelSymbolData(spinData, function()
        -- 落地牌游戏结束
        if totalCount <= 0 then
            self:ExitSpecial(spinData,isReconnect,spinData.totalWinCoin)
        else
            if totalCount == 3 then
                FToolSet.PlayFGUISound("ui://Game485/UFCS_HAP_ResetSpins")
                self:ResetBonusCnt( true )
            else
                self:SetBonusCnt(totalCount)
            end
            self:SetCollectCnt(spinData.grids)
            print("落地牌滚动结束")
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:AutoClick()
        end
    end, isReconnect)
end

function Game485:StopDelayCallSpin()
    if self.callSpinTimer then
        StopTimer(self.callSpinTimer)
        self.callSpinTimer = nil
    end
end

function Game485:AutoClick()
    -- self.curNormalSpinResultII = nil
    -- self.curFreeSpinResult = nil
    -- self.curSpecialSpinResult = nil
    
    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)

    local interval = FConfig.Common.AutoSpinInterval[FCasinoCtx.curGameMode]
    -- 普通游戏状态点击停止按钮
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        if FCasinoCtx.isAutoSpin then
            self:DelayCallSpin(interval)
        end
    else
        -- 特殊游戏，自动点击
        self:DelayCallSpin(interval)
    end
end

function Game485:DelayCallSpin(delay)
    self:StopDelayCallSpin()
    self.callSpinTimer = StartOnceTimer(function()
        FCasinoCtx:SimulateSpinClick()
    end, delay)
end

function Game485:FadeOutBgm()
    if self.ngBgm then
        self.ngBgmTweener = FairyGUI.GTween.ToDouble(1, 0, 2)
        :OnUpdate(function(tweener)
            APIGateway.SetSoundVolume(self.ngBgm,tweener.value.d)
        end)
        :OnComplete(function()
            self:StopBgm()
        end)
    end
end

function Game485:StopBgm()
    if self.ngBgm then
        self.ngBgmTweener = nil
        APIGateway.StopSound(self.ngBgm)
        self.ngBgm = nil

    end
    FToolSet.PlayBGM("")
end

function Game485:DelayFunc( time, call, node )
    node = self.render or node
    FTween.Start( node, FTween.Delay( time, call ) )
end

return Game485