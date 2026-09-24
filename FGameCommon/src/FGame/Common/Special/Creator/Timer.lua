-- Creator timer adapter (Special/Init.lua RUNTIME_IN_CREATOR).

local allTimer = {}
local nextId = 1

local function schedule(call, interval)
    local id = nextId
    nextId = nextId + 1
    allTimer[id] = true

    local function tick()
        if not allTimer[id] then return end
        call()
        if allTimer[id] then
            -- Creator / host should replace with engine scheduler; setTimeout for hybrid shell.
            if type(setTimeout) == "function" then
                setTimeout(tick, math.floor((interval or 0) * 1000))
            end
        end
    end

    if type(setTimeout) == "function" then
        setTimeout(tick, math.floor((interval or 0) * 1000))
    else
        -- Immediate fallback for environments without timers
        call()
        allTimer[id] = nil
    end
    return id
end

function StartTimer(call, interval)
    if interval == nil or interval < 0 then
        interval = 0
    end
    return schedule(call, interval)
end

function StopTimer(handle)
    if handle == nil then return end
    allTimer[handle] = nil
end

function StartOnceTimer(call, delay)
    local handler = nil
    handler = StartTimer(function()
        StopTimer(handler)
        call()
    end, delay)
    return handler
end

function StopAllTimer()
    allTimer = {}
end
