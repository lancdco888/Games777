
local Utils = {}

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
-- @return [0,2]
function Utils.GetCellIndex(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    return math.floor((index - 1) / reelCfg.xCellNumber)
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

-- @brief 是否需要播放抛金币动画
function Utils.isPlayCoinFountain(value, minBetMulti)
    return value / FCasinoCtx.commonPanel:GetBetMoney() >= minBetMulti
end

function Utils.itemExists(table, item)
    for _, value in pairs(table) do
        if value == item then
            return true
        end
    end
    return false
end

function Utils.convertNumberWithKM(number)
    number = tonumber(FToolSet.NumToStr(number)) 
    number = math.floor(number)
    local formattedStr
    if number >= 1000000 then
        local millions = number / 1000000
        formattedStr = string.format(millions % 1 == 0 and "%.0fm" or "%.1fm", millions)
    elseif number >= 1000 then
        local thousands = number / 1000
        formattedStr = string.format(thousands % 1 == 0 and "%.0fk" or "%.1fk", thousands)
    else
        formattedStr = tostring(number)
    end
    return formattedStr
end

function Utils.cloneTable(t)
    local function clone(t, seen)
        if type(t) ~= 'table' then
            return t
        end
        if seen[t] then
            return seen[t]
        end

        local copy = {}
        seen[t] = copy
        for k, v in pairs(t) do
            copy[clone(k, seen)] = clone(v, seen)
        end
        return setmetatable(copy, getmetatable(t))
    end

    return clone(t, {})
end


function Utils.LogNoticeFlag(isBegin)
    local noticeStr
    if isBegin then
        noticeStr = 
        [["======================================================================="
            "======================================="
            "============="
            "==="]]
    else
        noticeStr = 
        [["==="
            "============="
            "======================================="
            "======================================================================="]]
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

function Utils.StopSound(soundHamdler)
    APIGateway.StopSound(soundHamdler)
end

function Utils.StopBGM()
    FToolSet.StopBGM()
end

function Utils.PlayBGM(url)
    FToolSet.PlayBGM(url)
end

function Utils.SetTimeout(callback, delayTime, target)
    FTween.Start(target,FTween.Delay(delayTime, function()
        callback()
    end))
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

--[[ 
    FSpinStatus = {
    SPIN    = 1,      -- 普通状态（此时按钮应该为spine状态）
    WAITING = 2,      -- 等待状态（此时按钮应该显示stop或auto且不可点击）
    STOP    = 3,      -- 停止状态（此时按钮应该显示stop且可以点击）
} ]]
function Utils.SetSpinStatus(status)
    FCasinoCtx:SetSpinStatus(status)
end

--[[
    从start帧开始，播放到end帧（-1表示结尾），重复times次（0表示无限循环），循环结束后，停止在endAt帧（-1表示参数end）
]]
function Utils.PlayMovieClip(movieClip, start, endFrame, times, endAt, callback)
    movieClip:SetPlaySettings(start, endFrame, times, endAt, callback)
    movieClip.playing = true
end

return Utils