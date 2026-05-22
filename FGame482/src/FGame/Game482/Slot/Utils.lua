
local GameDefine = Import("..GameDefine")
local Utils = {}

local TweenerType = {
    SCROLL_STAIRS_WIN_MONEY = 1,
    SCROLL_BIG_WIN_MONEY = 2,
}
-- @brief 落地牌数字转字符串
-- 259,317,318 落地牌显示规则:
-- 显示=得分/当前押注“C等级” 如{1,5,10,20,50) 3等级就是 /10
function Utils.TopupBounsScoreToStr(value)
    value = value / FCasinoCtx.commonPanel:GetCurBetCValue()
    return FToolSet.NumToStr(value)
end

-- @brief 获取转轴下标
-- @return [0,5]
function Utils.GetReelIndex(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    return index % reelCfg.xCellNumber
end

-- @brief 获取Y轴格子下标
-- @return [0,3]
function Utils.GetCellIndex(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    return math.floor(index / reelCfg.xCellNumber)
end


-- @brief 刷新当前EachWins（所有红色圆圈数字相加）
function Utils.GetEachWins(grids)
    local value = 0
    for k, v in pairs(grids) do
        if v.icon == GameDefine.ICON_CIRCLE_RED then
            value = value + v.SymbolValue
        end
    end
    return value
end

-- @brief 将服务器图案下标转换为收分下标
function Utils.ConvertIndex(index)    
    -- 服务器图案下标
    -- 1  2  3  4  5
    -- 6  7  8  9  10
    -- 11 12 13 14 15

    -- 收分顺序
    -- 1  4  7 10 13
    -- 2  5  8 11 14
    -- 3  6  9 12 15

    local indexMap = {
        1, 4, 7, 10, 13,
        2, 5, 8, 11, 14,
        3, 6, 9, 12, 15,
    }
    return indexMap[index]
end

function Utils.itemExists(table, item)
    for idx, value in pairs(table) do
        if value == item then
            return idx
        end
    end
    return -1
end

-- @brief 是否需要播放抛金币动画
function Utils.isPlayCoinFountain(value)
    return value / FCasinoCtx.commonPanel:GetBetMoney() >= GameDefine.PlayCoinFountainMinBet
end

function Utils.getLogicPosInSlotContainer(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    -- 位于x轴的下标 [0,4]
    local logicX = Utils.GetReelIndex(index)
    -- 位于Y轴的下标 [0,2]
    local logicY = Utils.GetCellIndex(index)
    local x = logicX * (reelCfg.reelWidth + reelCfg.reelSpace)
    local y = logicY * (reelCfg.reelHeight / reelCfg.yCellNumber)
    return vec2(x,y)
end

function Utils.bind(func, param)
    return function()
        func(param)
    end
end

function Utils.SetTransitionToTimePoint(transition,time)
    transition:Play(1,0,time,time,function()end)
end

function Utils.ConvertScoreToRealVisual(score)
    return FToolSet.NumToStr(score)
end

-- Utils.tweeners = {}
-- @brief 将赢分滚动到某个值
-- function Utils:ScrollSpecificScoreTextTo(textObj,value, duration, onCompleteCallback,type)
--     duration = duration or 1
--     self:StopScrollWinMoney(nil,false,type)
--     value = math.floor(value / APIGateway.GetLobbyData().gameExchangeRate)
--     local tweener = FairyGUI.GTween.ToDouble(tonumber(textObj.text), value, duration)
--     :OnUpdate(function(tweener)
--         textObj.text = tostring(math.floor(tweener.value.d))
--     end)
--     :OnComplete(function()
--         self.tweeners[type] = nil
--         textObj.text = tostring(math.floor(value))
--         if onCompleteCallback then
--             onCompleteCallback()
--         end
--     end)

--     self.tweeners[type] = tweener
-- end

-- function Utils:StopScrollWinMoney(value, complete,type)
--     if complete == nil then complete = false end

--     self:KillTweener(type, complete)
-- end

-- function Utils:KillTweener(tweenerType, complete)
--     if self.tweeners[tweenerType] then
--         self.tweeners[tweenerType]:Kill(complete)
--         self.tweeners[tweenerType] = nil
--     end
-- end

Utils.timerPlayScoreSound = 0
Utils.scoreSoundID = 0
function Utils:PlayScoreSound(url,duration)
    StopTimer(Utils.timerPlayScoreSound)
    Utils.timerPlayScoreSound = nil
    
    Utils.scoreSoundID = Utils.PlaySound(url,false)
    Utils.timerPlayScoreSound = StartOnceTimer(
        function()
            Utils.timerPlayScoreSound = nil
            APIGateway.StopSound(Utils.scoreSoundID)
        end
    ,duration)
    return Utils.scoreSoundID
end

function Utils:StopScoreSound()
    StopTimer(Utils.timerPlayScoreSound)
    APIGateway.StopSound(Utils.scoreSoundID)
end

function Utils:GetAudioData(winMoney)
    if winMoney == 0 then
        return {
            time=0,
            url=""
        }
    end
    local ratio = winMoney / FCasinoCtx.commonPanel:GetBetMoney()
    local len = #FConfig.Common.FaFaFaAudioData

    local curCfg = FConfig.Common.FaFaFaAudioData[1]
    curCfg.url = "ui://Game339/Rollup1"
    if ratio < FConfig.Common.FaFaFaAudioData[1].ratio then
        curCfg = FConfig.Common.FaFaFaAudioData[1]
        curCfg.url = "ui://Game339/Rollup1"
    else
        for i = len, 1,-1 do
            curCfg  = FConfig.Common.FaFaFaAudioData[i]
            if ratio >= curCfg.ratio then

                local part = 0.25
                local location = i/len
                local val = nil
                if location <= part*1 then
                    val = 1
                elseif location <= part*2 then
                    val = 2
                elseif location <= part*3 then
                    val = 3
                else
                    val = 4
                end
                
                curCfg.url = "ui://Game339/Rollup"..val
                break
            end
        end
    end    
    return curCfg
end

function Utils:SetScoreLabel(labelObj,score)
    local status, err = pcall(function()
        -- labelObj.text = ""..(score // APIGateway.GetLobbyData().gameExchangeRate) 
        labelObj.text = ""..math.floor(score / APIGateway.GetLobbyData().gameExchangeRate) 
        end)
    if not status then
        print("Error: " .. err)
    end
end

function Utils.LogNoticeFlag(isBegin)
    local noticeStr
    if isBegin then
        noticeStr = [[
        "======================================================================="
        "======================================="
        "============="
        "==="
        ]]
    else
        noticeStr = [[
        "==="
        "============="
        "======================================="
        "======================================================================="
        ]]
    end
    print(noticeStr)
end

function Utils.LogNotice(logFun)
    Utils.LogNoticeFlag(true)
    logFun()
    Utils.LogNoticeFlag(false)
end

function Utils.PlaySound(url, isLoop)
    local handler = FToolSet.PlayFGUISound(url, isLoop)
    return handler
end

function Utils.StopSound(soundHandler)
    APIGateway.StopSound(soundHandler)
end

function Utils.StopBGM()
    FToolSet.StopBGM()
end

function Utils.PlayBGM(url)
    FToolSet.PlayBGM(url)
end

Utils.TimerTargets = {}
function Utils.SetTimeout(callback, delayTime, target)

    if target then
        local exists = false
        for _, existingTarget in ipairs(Utils.TimerTargets) do
            if existingTarget == target then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(Utils.TimerTargets, target)
        end
    end

    FTween.Start(target,FTween.Delay(delayTime, function()
        callback()
    end))

end

function Utils.ClearTimeout(target,property,shouldCallback)
    FTween.StopTweens(target,property,shouldCallback)
end

function Utils.ClearAllTimeouts()
    for _, target in pairs(Utils.TimerTargets) do
        Utils.ClearTimeout(target)
    end
end

function Utils.StopSound(soundID)
    if soundID then
        APIGateway.StopSound(soundID)
    end
end

function Utils.SyncTopCoin(spinData)
    FCasinoCtx:SetPlayerMoneyInfo(spinData)
end

function Utils.SyncBottomCoin(duration)
    FCasinoCtx:SyncPlayerMoneyDisplay(duration)
end

function Utils.ScrollBottomWinMoneyTo(value, duration, onCompleteCallback)
    FCasinoCtx.commonPanel:ScrollWinMoneyTo(value, duration, onCompleteCallback)
end

--[[ 
    FSpinStatus = {
    SPIN    = 1,      -- 普通状态（此时按钮应该为spine状态）
    WAITING = 2,      -- 等待状态（此时按钮应该显示stop或auto且不可点击）
    STOP    = 3,      -- 停止状态（此时按钮应该显示stop且可以点击）
} ]]
function Utils.SetSpinStatus(status)
    FCasinoCtx:SetSpinStatus(status)
end

function Utils.AddToTopEffectLayerAndMakeFullScreen(obj)
    FCasinoCtx.commonPanel.topEffectLayer:AddChild(obj)
    obj:MakeFullScreen()
end

function Utils.AddClickEvent(obj, callback)
    obj:AddEventListener(FGUIEventKey.onClick, callback)
end

function Utils.TweenNumber(fromNum, toNum, duration, easeType, onUpdateCallback, callback)
    local t = FairyGUI.GTween.ToDouble(fromNum, toNum, duration)
    :OnUpdate(function(tweener)
        if onUpdateCallback then onUpdateCallback(tweener.value.d) end
    end)
    :OnComplete(function()

        if callback then
            callback()
        end
    end)
    :SetEase(easeType or FairyGUI.EaseType.Custom)

    return t
end

function Utils.GetTableMemberCount(t_table)
    local count = 0
    for _ in pairs(t_table) do
        count = count + 1
    end
    return count
end

return Utils