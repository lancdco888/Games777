-- action/bg.lua
local this, lua, root = ...

local t = {
    time = 0,
    hasAction = false,
    open = false,
    close = false,
    inited = false,
    type = -1,
}

local observer = {
    onReceive = function(_, data)
        local msg = data.msg
        this:SetAction(msg)
        this:SetLoops(data.loops == true)
    end
}

lua:Set_onInit(function()
    FF_G.Broadcast.register("bgPlayAnimEvent", observer)
    this:SetLoops(false)
end)

lua:Set_onUnInit(function()
    FF_G.Broadcast.unRegister("bgPlayAnimEvent", observer)
end)

lua:Set_onUpdate(function(dt)
    if not t.hasAction then return 0 end
    t.time = t.time + dt
    return 0
end)

lua:Set_onCall(function(msg)
    if msg == "exit" then
        this:SetAction("exit")
        local effects = this:GetRelationEffects()
        for _, effect in ipairs(effects) do
            effect:SetAction("exit")
        end
    end

    if t.hasAction then
        if msg == "open" then
            this:SetAction("open")
        elseif msg == "close" then
            this:SetAction("close")
        end
    end
end)

lua:Set_onSerialize(function()
    GT = t
end)

lua:Set_onDeserialize(function()
    local t_ = GT
    for k, v in pairs(t_) do
        t[k] = v
    end
end)
