local Tracker = {}

Tracker.__index = Tracker

local function string_split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function Tracker.New(name, stackLevel)
    return setmetatable({
        name = name,
        records = {},
        stackLevel = stackLevel or 0,
        callLeakAddNum = 0,
    }, Tracker)
end

-- @brief 添加追踪
function Tracker:LeakAdd(ud, stackLevel)
    if not FConfig.Debug then return end

    stackLevel = stackLevel or self.stackLevel

    -- 重复追踪
    for k, v in pairs(self.records) do
        if v.ud == ud then
            assert(false)
        end
    end
    
    local traceback = debug.traceback()
    local lines = string_split(traceback, "\n")
    if lines[4 + stackLevel] then
        traceback = lines[4 + stackLevel]
    end

    local record = setmetatable({}, {__mode = "kv"})
    record.ud = ud
    record.where = traceback
    table.insert(self.records, record)

    self.callLeakAddNum = self.callLeakAddNum + 1
    if self.callLeakAddNum > 100 then
        self.callLeakAddNum = 0
        local records = {}
        for _, v in pairs(self.records) do
            if v.ud ~= nil then
                table.insert(records, v)
            end
        end
        self.records = records
    end
end

-- @brief 移除追踪
function Tracker:LeakRemove(ud)
    if not FConfig.Debug then return end

    for k, v in pairs(self.records) do
        if v.ud == ud then
            table.remove(self.records, k)
            return
        end
    end
end

-- @brief 
function Tracker:Dump()
    if next(self.records) == nil then return end

    print("\n\n\n内存泄漏:")
    print("<<<<<<<<<<<<<", "dump " .. self.name, ">>>>>>>>>>>>>")    
    print("#####################################################")

    for _, v in pairs(self.records) do
        if v.ud ~= nil then
            print(v.where, v.ud)
        end
    end
    
    print("#####################################################")
    print("\n\n\n")
end

function Tracker:Clear()
    self.records = {}
end

return Tracker