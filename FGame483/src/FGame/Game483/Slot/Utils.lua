
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
-- @return [0,4]
function Utils.GetReelIndex(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    return (index - 1) % reelCfg.xCellNumber
end

-- @brief 获取Y轴格子下标
-- @return [0,3]
function Utils.GetCellIndex(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    return math.floor((index - 1) / reelCfg.xCellNumber)
end

-- @brief 获取data下标 [4,3]
function Utils.GetDataIndex(reelIndex,cellIndex)
    local reelCfg = FCasinoCtx.gameCfg.Reel -- 5
    local reelIndex = reelIndex -- 5
    local cellIndex = cellIndex -- 4
    return reelCfg.xCellNumber * (cellIndex - 1) + reelIndex
end


--------------------
-- 删除table的
-- table.removeByIndexs = function (tab,deleIndexs)
--     table.sort(deleIndexs,function (a,b)
--         return a > b
--     end)
--     for _, index in ipairs(deleIndexs) do
--         table.remove(tab,index)
--     end
-- end


---------------

function Utils.itemExists(table, item)
    for _, value in pairs(table) do
        if value == item then
            return true
        end
    end
    return false
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

function Utils.SetTransitionToTime(transition,time)
    transition:Play(1,0,time,time,function()end)
end

Utils.tweeners = {}
-- @brief 将赢分滚动到某个值
function Utils:ScrollWinMoneyTo(textObj,value, duration, onCompleteCallback,type)
    duration = duration or 1
    self:StopScrollWinMoney(nil,false,type)
    -- value = value // APIGateway.GetLobbyData().gameExchangeRate
    value = math.floor(value / APIGateway.GetLobbyData().gameExchangeRate)
    local tweener = FairyGUI.GTween.ToDouble(tonumber(textObj.text), value, duration)
    :OnUpdate(function(tweener)
        -- self:SetWinMoney(tweener.value.d, true, value)
        self:SetMoney(textObj,tweener.value.d, true, value)
    end)
    :OnComplete(function()
        self.tweeners[type] = nil
        -- self:SetWinMoney(value)
        self:SetMoney(textObj,value)
        if onCompleteCallback then
            onCompleteCallback()
        end
    end)

    self.tweeners[type] = tweener
end


function Utils:StopScrollWinMoney(value, complete,type)
    if complete == nil then complete = false end

    self:KillTweener(type, complete)
end

function Utils:KillTweener(tweenerType, complete)
    if self.tweeners[tweenerType] then
        self.tweeners[tweenerType]:Kill(complete)
        self.tweeners[tweenerType] = nil
    end
end

Utils.timerPlayScoreSound = 0
Utils.scoreSoundID = 0
function Utils:PlayScoreSound(url,duration)
    StopTimer(Utils.timerPlayScoreSound)
    Utils.timerPlayScoreSound = nil
    
    Utils.scoreSoundID = FToolSet.PlayFGUISound(url,false)
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


function Utils:SetScoreLabel(labelObj,score)
    local status, err = pcall(function()
        -- labelObj.text = ""..(score // APIGateway.GetLobbyData().gameExchangeRate) 
        labelObj.text = ""..math.floor(score / APIGateway.GetLobbyData().gameExchangeRate) 
        end)
    if not status then
        print("Error: " .. err)
    end
end


function Utils.Delay(node,timer,callback)
    FTween.Start(node,
        FTween.Delay(timer, function()
            if callback then
                callback()
            end
        end)
    )
end

function Utils.Dot2Comma(str)
    return str -- string.gsub(str, "%.", ",")
end

function Utils.MoveTo(node,from,to,time,callback)
    local function onTweenerCreate(tweener)
        tweener:SetEase(FairyGUI.EaseType.BounceOut)
    end
    FTween.Start(node,
        FTween.To(FairyGUI.TweenPropType.Position, from, to, time, nil, onTweenerCreate),
        FTween.CallFunc(function()
            if callback then
                callback()
            end
        end)
    )
end

-- 
function Utils.DumpGrid(datas,name,xNum,yNum,disPlayKeys)
    local str = name.."\n"
    local line = 1
    str = str .. line .. "-- "
    
    for index, data in ipairs(datas) do
        for k, v in pairs(data) do
            if (not disPlayKeys) or (not next(disPlayKeys)) or (not Utils.itemExists(disPlayKeys, k)) then
                str = str .. k..":"..v.."-"
            end
        end
        str = str .."   "
        if index%xNum == 0 then -- 换行
            line = line + 1
            str = str .."\n".. line .. "-- "
        end
    end
    print(str)
end

function Utils.RandomSymbolData(index,needRandom)
    local data = {
        icon  = math.random(0, 7),
        golden = math.random(0, 1),
        isRandom = true
    }
    if index == 1 or index == 5 then
        data.golden = 0
    end
    if needRandom then
        data.isRandom = nil
    end
    return data
end

-- 有小数保留两位，没小数取整 -- isConvertInteger强制取整
function Utils.DelectDot(num,isConvertInteger)
    if isConvertInteger then
        return Utils.Dot2Comma(FToolSet.NumToStr(num,true))
    end
    if FToolSet.GetDecimalPlaces(FToolSet.NumToStr(num)) == 0 then
        return Utils.Dot2Comma(FToolSet.FixedDecimalPlaces(FToolSet.NumToStr(num), 2))
    else
        return Utils.Dot2Comma(FToolSet.NumToStr(num,true))
    end
end
return Utils