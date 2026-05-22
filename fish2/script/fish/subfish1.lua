-- subfish1.lua
local this, lua, root = ...

local t = {
    angle = 0,
    r = 0,
}

local function Update()
    local x, y = root:Rotate(t.r, 0, t.angle)
    local px, py = this:GetParent():GetPos()

    this:SetPos(x + px, y + py)
    this:SetRotation(t.angle + math.pi / 2)
    this:SetOffset(x, y)
end

if not FF_G.IsServer then
    lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
        FF_G_Client.ShowFishDeathEffect(player:GetId(), this:GetTypeId(), ratio * coin)
        return 0
    end)
end

lua:Set_onInit(function()
    return 0
end)

lua:Set_onUpdate(function(dt)
    t.angle = t.angle + dt
    Update(t)
    return 0
end)

lua:Set_onSerialize(function()
    GT = t
end)

lua:Set_onDeserialize(function()
    local t_ = GT
    for k, v in pairs(t_) do
        t[k] = v
    end
    Update(this, t)
end)

lua:Set_onToStringCore(function()
    return ",\"lua_t\":{\"angle\":"..t.angle.."}"
end)
