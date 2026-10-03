
local target = {}
local allTimer = {}

-- @brief 开启一个定时器
-- @return 返回定时器句柄
function StartTimer(call, interval, delay)
    if interval == nil or interval <= 0 then
        interval = 1 / 60
    end
    delay = delay or interval

    --local delegate = FairyGUI.TimerCallback(function() call(interval) end)
    --FairyGUI.Timers.inst:Add(interval, 0, delegate)
    --
    --return delegate    
    local prevTime = CS.UnityEngine.Time.time
    local timer = Timer:schedule(interval, target, function()
        local time = CS.UnityEngine.Time.time
        local dt = time - prevTime
        prevTime = time
        
        call(dt)
    end, delay)

    allTimer[timer] = true

    return timer
end

-- @brief 停止一个计时器
function StopTimer(delegate)
    if delegate == nil then return end
    --FairyGUI.Timers.inst:Remove(delegate)
    Timer:unSchedule(delegate, true)
    allTimer[delegate] = nil
end

-- @brief 开启一个只执行一次的定时器
function StartOnceTimer(call, delay)
    local handler = nil

    handler = StartTimer(function()
        StopTimer(handler)
        call()
    end, delay, delay)

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
