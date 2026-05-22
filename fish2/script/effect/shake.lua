-- effect/shake.lua
local root, lua = ...

local t = {
    shakeEventIndex = 0,
}

if not FF_G.IsServer then
    lua:Set_onUpdate(function(dt)
        --print("shake update:", dt, ",idx:", t.shakeEventIndex)
        local shakes = FF_G.shakesCache[t.shakeEventIndex]
        assert(shakes)
        for _, shake in ipairs(shakes) do
            print(shake.startTime, shake.continueTime, shake.strength)
            if shake.startTime >= dt then
                FF_G.AddTimerTask(shake.startTime - dt, function()
                    root:ShakeScreen(shake.continueTime, shake.strength)
                end)
            end
        end
        return 0
    end)
end

lua:Set_onSerialize(function()
    GT = t
end)

lua:Set_onDeserialize(function()
    local t_ = GT
    for k, v in pairs(t_) do
        t[k] = v
    end
end)
