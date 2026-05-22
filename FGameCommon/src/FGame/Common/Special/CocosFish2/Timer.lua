
local allTimer = {}

-- @brief 开启一个定时器
-- @return 返回定时器句柄
function StartTimer(call , interval)
    if interval == nil or interval < 0 then
        interval = 0
    end
    
    local handle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(call, interval, false)
    allTimer[handle] = true
    return handle
end

-- @brief 停止一个计时器
function StopTimer(handle)
    if handle == nil then return end
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handle)
    allTimer[handle] = nil
end

-- @brief 开启一个只执行一次的定时器
function StartOnceTimer(call, delay)
    local handler = nil
    
    handler = StartTimer(function()
        StopTimer(handler)
        call()
    end, delay)

    return handler
end

function StopAllTimer()
    local timers = {}
    for k, _ in pairs(allTimer) do
        table.insert(timers, k)
    end
    for _, v in pairs(timers) do
        StopTimer(v)
    end
    allTimer = {}
end