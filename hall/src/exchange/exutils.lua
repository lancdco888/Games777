local exutils = {}

--获取手机号长度配置
function exutils.GetPhoneLenth()
	if ConfigParam.Region == "ind" then
		return 12
	elseif ConfigParam.Region == "ms" then
		return 10,12
	elseif ConfigParam.Region == "vn" then
		return 8,15
	elseif ConfigParam.Region == "tha" then
		return 5,15
	else
		return 10
	end
end

--------------------------------------------------------
-- True Money 电子钱包

function exutils.GetTrueMoneyLength()
    return 3, 18
end

function exutils.GetTrueMoneyInputTips()
    local min, max = exutils.GetTrueMoneyLength()
    local str = TR("请输入AAA-BBB位的 TrueMoney 账号")
    str = string.gsub(str, "AAA", tostring(min))
    str = string.gsub(str, "BBB", tostring(max))
    return str
end

function exutils.CheckTrueMoneyAccount(account)
    if account == nil then
        return false
    end

    -- 3-18 位字母数字和特殊字符, 特殊字符可以是 ()_-
    local min, max = exutils.GetTrueMoneyLength()
    local len = string.len(account)
    if len > max or len < min then
        -- 长度不合法
        return false
    end
    local ret = string.match(account, "[a-zA-Z0-9()_-]*")
    -- 是否匹配
    return ret == account
end

--- 字符串是否纯空格
function exutils.strIsBlank(str)
	local t = ""
	for s in string.gmatch(str,"[ ]") do
		t = t .. s
	end
	if str == t then -- 只包含空格
		return true
	end
	return false
end

--手机号位数判断(或者其他账号判断momo，zalo等)
function exutils.CheckPhone(len_)
	if ConfigParam.Region == "ind" then
		if len_ ~= 12 then
			return true
		end
		return false
	elseif ConfigParam.Region == "ms" then
		if len_ >= 10 and len_ <= 12 then
			return false
		end
		return true
	elseif ConfigParam.Region == "vn" then
		if len_ >= 8 and len_ <= 15 then
			return false
		end
		return true
	else
		if len_ ~= 10 then
			return true
		end
		return false
	end
end

--获取手机号长度配置
function exutils.GetPhoneLenth()
	if ConfigParam.Region == "ind" then
		return 12
	elseif ConfigParam.Region == "ms" then
		return 10,12
	elseif ConfigParam.Region == "vn" then
		return 8,15
	elseif ConfigParam.Region == "tha" then
		return 5,15
	else
		return 10
	end
end

--------------------------------------------------------

return exutils
