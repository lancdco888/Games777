--local a = {
--    1,
--    2,
--    3,
--    4,
--    false,
--    true,
--    false,
--    100
--}
--a[2] = nil
--a[100] = 10000
--a["cb"] = 3
--a["abc"] = 2
--a["ab"] = 3
--
--for k, v in pairsByOrder(a) do
--    print(k, v)
--end
--print("----------------")
--
--for k, v in pairsByOrder(a, true) do
--    print(k, v)
--end
--print("----------------")
--
--
--for k, v in ipairsArr(a) do
--    print(k, v)
--end
--print("----------------")
--
--for k, v in ipairsArr(a, true) do
--    print(k, v)
--end
--print("----------------")

local PRIORITY_THREAD 	= 8
local PRIORITY_USERDATA = 7
local PRIORITY_TABLE	= 6
local PRIORITY_FUNCTION	= 5
local PRIORITY_NIL		= 4
local PRIORITY_STRING	= 3
local PRIORITY_BOOLEAN	= 2
local PRIORITY_NUMBER	= 1

local priority = {
    ["thread"]      = PRIORITY_THREAD,
    ["userdata"]    = PRIORITY_USERDATA,
    ["table"] 		= PRIORITY_TABLE,
    ["function"]	= PRIORITY_FUNCTION,
    ["nil"]			= PRIORITY_NIL,
    ["string"] 		= PRIORITY_STRING,
    ["boolean"]		= PRIORITY_BOOLEAN,
    ["number"] 		= PRIORITY_NUMBER,
}

local function sort(left, right)
    local typeLeft = type(left)
    local typeRight = type(right)

    local priorityLeft = priority[typeLeft]
    local priorityRight = priority[typeRight]

    -- print("key:", left, right)
    -- print("p:", priorityLeft, priorityRight)

    if priorityLeft ~= priorityRight then
        return priorityLeft < priorityRight
    end

    if priorityLeft == PRIORITY_NUMBER then
        return left < right
    end

    if priorityLeft == PRIORITY_BOOLEAN then
        local leftVal = left and 1 or 0
        local rightVal = right and 1 or 0
        -- print("b:", leftVal, rightVal)
        return leftVal < rightVal
    end

    if priorityLeft == PRIORITY_STRING then
        local leftLen = #left
        local rightLen = #right
        local len = math.min(leftLen, rightLen)

        for i = 1, len do
            local leftByte = string.byte(left, i)
            local rightByte = string.byte(right, i)

            -- print(leftByte, rightByte)

            if leftByte ~= rightByte then
                return leftByte < rightByte
            end

            return leftLen < rightLen
        end

        return leftLen < rightLen
    end

    return false
end

local function genIter(t, keys, isDesc)
    local len = #keys
    local index = isDesc and len or 1
    local indexDelta = isDesc and -1 or 1

    return function()
        if isDesc and index > 0 or index <= len then
            local key = keys[index]
            index = index + indexDelta
            return key, t[key]
        end
    end
end

---按照key值排序遍历table.
---@param t table 需要遍历的table对象
---@param isDesc boolean 是否降序(默认为false)
---@return function 排序后的[key, value]迭代器
function pairsByOrder(t, isDesc)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end

    table.sort(keys, sort)

    return genIter(t, keys, isDesc)
end

---按照key值排序遍历table(忽略非number类型的key值, 不会被不连续的key值中断), 效率高于pairsByOrder.
---@param t table 需要遍历的table对象
---@param isDesc boolean 是否降序(默认为false)
---@return function 排序后的[key, value]迭代器
function ipairsArr(t, isDesc)
    local keys = {}
    for k, _ in pairs(t) do
        if type(k) == "number" then
            table.insert(keys, k)
        end
    end

    table.sort(keys)

    return genIter(t, keys, isDesc)
end
