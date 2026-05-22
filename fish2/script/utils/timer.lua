-- utils/timer.lua
local root = ...

local tasks = {}

FF_G.AddTimerTask = function(time, callback, params)
    table.insert(tasks, {
        time = time,
        callback = callback,
        params = params,
    })
end

FF_G.UpdateTimer = function(dt)
    if #tasks == 0 then return end
    local tasks1 = {}
    for _, task in ipairs(tasks) do
        task.time = task.time - dt
        if task.time <= 0 then
            task.callback(task.params)
        else
            table.insert(tasks1, task)
        end
    end
    tasks = tasks1
end

