---@type Array<{time:number,callback:function,left:number}>
local timeHander = {}

local timeid = 0

local deleteKey = {}

---@param aTime number 时间间隔
---creator每帧调用此方法
function creatorOnTick(aTime)
    for key, value in pairs(timeHander) do
        -- body
        if value.valide then
            value.left = value.left - aTime
            if value.left <= 0 then
                value.left = value.time
                value.callback(aTime)
            end
        end
    end

    local count = #deleteKey
    if count > 0 then
        for i = count,1,-1 do
            timeHander[deleteKey[i]] = nil
            deleteKey[i] = nil
        end
    end
end

local registerTimer = function(aCallback, aInterval)
    timeid = timeid + 1
    timeHander[timeid] = { time = aInterval, callback = aCallback, left = aInterval, valide = true }
    return timeid
end

local unregisterTimer = function(aHander)
    if aHander and timeHander[aHander] then
        timeHander[aHander].valide = false
        table.insert(deleteKey, aHander)
    end
end



------------------------------


local allTimer = {}

-- @brief 开启一个定时器
-- @return 返回定时器句柄
function StartTimer(call, interval)
    if interval == nil or interval < 0 then
        interval = 0
    end

    if not call then
        __G__TRACKBACK__("call func is nil")
        return;
    end

    local handle = registerTimer(call, interval) --   CREATOR.startTimer(call, interval)
    allTimer[handle] = true
    return handle
end

-- @brief 停止一个计时器
function StopTimer(handle)
    if handle == nil then return end
    --CREATOR.clearTimer(handle)
    unregisterTimer(handle)
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
