
local GameDefine = Import("..GameDefine")
local SymbolConfig = Import(".SymbolConfig")
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
function Utils.GetReelIndex(index,mode)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    if mode == "bonus" then
        return (index - 1) % reelCfg.xCellNumberBouns 
    end
    return (index - 1) % reelCfg.xCellNumber
end

-- @brief 获取Y轴格子下标
-- @return [0,2]
function Utils.GetCellIndex(index,mode)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    if mode == "bonus" then
        return math.floor((index - 1) / reelCfg.xCellNumberBouns)
    end
    return math.floor((index - 1) / reelCfg.xCellNumber)
end

-- @brief 获取服务器icon值 c++ 0开始 lua 1 开始 （老游戏 沿用以前的 1开始）
-- @return [0,2]
function Utils.GetIconIndex(icon)
    return icon
end

-- @brief 获取服务器icon值 c++ 0开始 lua 1 开始 （老游戏 沿用以前的 1开始）
-- @return [0,2]
function Utils.GetIndex(index)
    return index
end

-- @brief 是否需要播放抛金币动画
function Utils.isPlayCoinFountain(value)
    return value / FCasinoCtx.commonPanel:GetBetMoney() >= GameDefine.PlayCoinFountainMinBet
end

local indexMap = {
    1, 4, 7, 10, 10,
    2, 5, 8, 11, 14,
    3, 6, 9, 12, 15,
}
-- @brief 将服务器图案下标转换为收分下标
function Utils.ConvertIndex(index)
    return indexMap[index]
end

function Utils.SortTable(tableS)
    local tableT = {}
    for _,v in pairs(tableS) do
        table.insert(tableT, v)
    end
    for i = 1 ,#tableT do
        for j = i + 1 ,#tableT do
            if Utils.ConvertIndex(tableT[i].index) > Utils.ConvertIndex(tableT[j].index) then
                local temp = tableT[i]
                tableT[i] = tableT[j]
                tableT[j] = temp
            end
        end
    end
    return tableT
end

function Utils.IsGrandJackpot(tb)
    local totalwin = 0
    for _,v in pairs(tb) do
        if not Utils.IsBonus(v.icon) then
            return false,0
        else
            totalwin = totalwin + v.symbolValue
        end
    end
    return true,totalwin
end

function Utils.IsWild(icon)
    return icon == GameDefine.WILD_ICON
end

function Utils.IsBonus(icon)
    return icon == GameDefine.BONUS_ICON
end

function Utils.IsScatter(icon)
    return icon == GameDefine.SCATTER_ICON
end

function Utils.IsBonusLine(lineIndex)
    return lineIndex == GameDefine.BONUS_LINE_INDEX
end

function Utils.IsScatterLine(lineIndex)
    return lineIndex == GameDefine.SCATTER_LINE_INDEX
end

function Utils.GetWinLevel(value)
    local winRate = value / FCasinoCtx.commonPanel:GetBetMoney()
    if winRate > 30 then
        return 3,9
    elseif winRate > 15 then
        return 2,6
    end
    return 1,3
end

function Utils.SetBonusNum(loader,data)
    local component = loader.component
    component:GetController("c1").selectedIndex = data.type
    component:GetChild("icon_ef").visible = false
    component.title = Utils.TopupBounsScoreToStr(data.value)
end

function Utils.SetIcon(render,data)
    local cfg = SymbolConfig[data.icon]
    local icon = render:GetChild("icon")
    icon.url = cfg.icon
end

function Utils.GetBonusScore(grids)
    local total_win = 0
    for _, v in pairs(grids) do
        if Utils.IsBonus(v.icon) then
            total_win = total_win + v.symbolValue
        end
    end
    return total_win
end

function Utils.GetChildrenList(obj)
    local num = obj.numChildren
    local childs = {}
    for i = 0, num-1 do
        table.insert(childs,obj:GetChildAt(i))
    end
    return childs
end

return Utils