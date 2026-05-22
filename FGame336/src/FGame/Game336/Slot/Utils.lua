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


return Utils