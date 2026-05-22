local Tools = {}

Tools.game = nil

Tools.InitUIBox2Symbol = function (datas)
    local retDatas = nil
    if datas and #datas == 5 then
        retDatas = {}
        for _, data in ipairs(datas) do
            local reelCellData = {}
            for _, icon in ipairs(data) do
                local cellData = {
                    icon  = icon,
                    value = 0,
                    type = 0
                }
                table.insert(reelCellData,cellData)
            end
            table.insert(retDatas,reelCellData)
        end
    end
    return retDatas
end

function Tools.IsInLuodiMode()
    if Tools.game ~= nil then
        return Tools.game:IsInLuodiMode()
    else
        return false
    end
end
function Tools.IsInFreeLuodiMode()
    if Tools.game ~= nil then
        return Tools.game:IsInFreeLuodiMode()
    else
        return false
    end
end

-- @brief 落地牌数字转字符串
-- 259,317,318 落地牌显示规则:
-- 显示=得分/当前押注“C等级” 如{1,5,10,20,50) 3等级就是 /10
function Tools.TopupBounsScoreToStr(value)
    value = value / FCasinoCtx.commonPanel:GetCurBetCValue()
    return FToolSet.NumToStr(value)
end

-- table  元素数量
function Tools.CheckTabCount(tab)
    local count = 0
    for _, v in pairs(tab) do
        if v then
            count = count + 1
        end
    end
    return count
end

function Tools.IsNodeConfig(str)
    return str:sub(1,5) ~= "ui://"
end

function Tools.StopAndSetScrollWinMoney(finalCoin)
    FCasinoCtx.commonPanel:StopScrollWinMoney(finalCoin)
end

-- 是否是灯笼线
function Tools.IsScLine(lineIndex)
    return lineIndex == 103
end

function Tools.Filter(src,filter)
    local filtered = {}
    for _,item in ipairs(src) do
        if filter(item) then
            table.insert(filtered,item)
        end
    end
    return filtered
end

function Tools.IsFreeGameMode(obj)
    return obj.curGameType == 2
end

function Tools.itemExists(table, item)
    for _, value in pairs(table) do
        if value == item then
            return true
        end
    end
    return false
end



return Tools