local Tools = {}

Tools.InitUIBox2Symbol = function(datas)
    local retDatas = nil
    if datas and #datas == 5 then
        retDatas = {}
        for _, data in ipairs(datas) do
            local reelCellData = {}
            for _, icon in ipairs(data) do
                local cellData = {
                    icon = icon,
                    value = 0,
                    type = 0
                }
                table.insert(reelCellData, cellData)
            end
            table.insert(retDatas, reelCellData)
        end
    end
    return retDatas
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
    return str:sub(1, 5) ~= "ui://"
end

function Tools.HideSymbolChildren(render)
    render:GetChild("loader").visible = false
    render:GetChild("pic1").visible = false
    render:GetChild("pic1_loop").visible = false
    render:GetChild("pic2").visible = false
    render:GetChild("pic2_loop").visible = false
    render:GetChild("pic3").visible = false
    render:GetChild("pic3_loop").visible = false
    render:GetChild("pic4").visible = false
    render:GetChild("pic4_loop").visible = false
    render:GetChild("scatter").visible = false
    render:GetChild("scatter_loop").visible = false
    render:GetChild("wild").visible = false
end

-- 是否是灯笼线
function Tools.IsScLine(lineIndex)
    return lineIndex == 103
end

-- @param array
function Tools.Includes(slice, data)
    for _, v in pairs(slice) do
        if v == data then
            return true
        end
    end
    return false
end

function Tools.Filter(slice, filter)
    local filtered = {}
    for _, item in pairs(slice) do
        if filter(item) then
            table.insert(filtered, item)
        end
    end
    return filtered
end

function Tools.IndexOf(slice, val)
    for key, item in pairs(slice) do
        if item == val then
            return key
        end
    end
    return -1
end

function Tools.IsFreeGameMode(obj)
    return obj.curGameType == 2
end

function Tools.IsJpCard(icon)
    return icon == 3
end

function Tools.IsWiCard(icon)
    return icon == 1
end

function Tools.IsScCard(icon)
    return icon == 2
end

function Tools.IsFreeGameMode(obj)
    return obj.curGameType == 2
end

return Tools
