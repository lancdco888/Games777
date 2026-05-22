
table.removevalue = table.removevalue or function(t, value)
    for i = #t, 1, -1 do
        if t[i] == value then
            table.remove(t, i)
        end
    end
end

-- @brief 用于判断两个table数据是否相等
function table.equals(t1, t2)
    local compare
    compare = function(src, tmp, _reverse)
        if (type(src) ~= "table" or type(tmp) ~= "table") then
            return src == tmp
        end

        for k, v in next, src do
            if type(v) == "table" then
                if type(tmp[k]) ~= "table" or not compare(v, tmp[k]) then
                    return false
                end
            else
                if tmp[k] ~= v then
                    return false
                end
            end
        end
        return _reverse and true or compare(tmp, src, true)
    end

    return compare(t1, t2)
end