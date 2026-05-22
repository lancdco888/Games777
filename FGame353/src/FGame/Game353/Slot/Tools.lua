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
    -- value = value / FCasinoCtx.commonPanel:GetCurBetCValue()
    -- return ToolSet.NumToStr(value)
    return Tools.NumberConversion(FToolSet.NumToStr(value))
end
--测试新加需求 数字显示加kmb
Tools.NumberConversion = function (number, charK, charM, charB, isOther)
    charK = charK or "k"
    charM = charM or "m"
    charB = charB or "b"
	--转 k m b
	local sNumber = tostring(number)
    local length = #sNumber
	if length < 5 then
		return sNumber
	else
		local km = ""
		if length >= 10 then
			km = charB
			sNumber = tostring(number / 1000000000)
        elseif length >= 7 then
			km = charM
			sNumber = tostring(number / 1000000)
		elseif length >= 5 then
			km = charK
			sNumber = tostring(number / 1000)
		end
		--
		if isOther ~= nil then
			local format = string.format("%df", isOther)
			sNumber = string.format("%0." .. format, sNumber)
			return sNumber .. km
		end
		--
		local rStr = ""
		local count = 0
        local dot = false
		for i = 1, length do
			local c = string.sub(sNumber, i, i)
            if dot and count >= 3 then
                break
            end
			if c == '.' then
                dot = true
            else
				count = count + 1
			end
            rStr = rStr .. c
		end
		--
		local iNum = tonumber(rStr)
		rStr = tostring(iNum)
        local last = string.sub(rStr, #rStr, #rStr)
        local prior = string.sub(rStr, #rStr-1, #rStr-1)
		if last == "." then
			rStr = string.sub(rStr, 1, #rStr - 1)
        elseif last == "0" and prior == "." then
			rStr = string.sub(rStr, 1, #rStr - 2)
		end
		--
		return rStr .. km
	end
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
--freeicon,wildicon,jpicon = 13,12,14
function Tools.IsJpCard(icon)
    return icon == 14
end

function Tools.IsWiCard(icon)
    return icon == 12
end

function Tools.IsScCard(icon)
    return icon == 13
end

function Tools.IsFreeGameMode(obj)
    return obj.curGameType == 2
end

return Tools
