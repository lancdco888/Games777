-- 一些unity或cocos没有的函数


if not handler then
    -- @brief
    function handler(obj, method)
        return function(...)
            return method(obj, ...)
        end
    end
end

if not clone then
    -- @brief table clone
    function clone(object)
        local lookup_table = {}
        local function _copy(object)
            if type(object) ~= "table" then
                return object
            elseif lookup_table[object] then
                return lookup_table[object]
            end
            local newObject = {}
            lookup_table[object] = newObject
            for key, value in pairs(object) do
                newObject[_copy(key)] = _copy(value)
            end
            return setmetatable(newObject, getmetatable(object))
        end
        return _copy(object)
    end
end

if not table.keys then
    function table.keys(hashtable)
        local keys = {}
        for k, v in pairs(hashtable) do
            keys[#keys + 1] = k
        end
        return keys
    end
end

