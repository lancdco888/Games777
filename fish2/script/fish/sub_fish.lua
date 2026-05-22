-- fish/sub_fish.lua
local this, lua, root = ...

local t = {
}
local funcs = {}

funcs.OnInit = function()
end

funcs.OnUnInit = function()
end

funcs.OnUpdate = function(dt)
    return 0
end

funcs.ShowDeathEffect = function()
    local player = this:GetKillPlayer()
    local playerId = -1
    if not player:IsNull() then
        playerId = player:GetId()
    end
    FF_G_Client.ShowFishDeathEffect(playerId, this:GetTypeId(), this:GetValue())
end

lua:Set_onInit(funcs.OnInit)
lua:Set_onUnInit(funcs.OnUnInit)
lua:Set_onUpdate(funcs.OnUpdate)

if not FF_G.IsServer then
    funcs.PlayDeathEffect = function()
    end
    funcs.OnDeath = function(player, cannonId, bulletId, ratio, coin)
        return 0
    end

    lua:Set_onDeath(funcs.OnDeath)
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

return t, funcs
