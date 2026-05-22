-- combined_fish1.lua
-- 组合鱼1 -> 灯笼鱼*5
local this, lua, root = ...

local t = {
    inited = false
}

local Init = function()
    if FF_G_Client then
        FF_G_Client.AddCombinedBg(this, 1.15)
        for _, fish in ipairs(this:GetChildren()) do
            FF_G_Client.AddCombinedBg(fish, 1.15)
        end
    end
end

lua:Set_onInit(function()
    if not t.inited then
        local offsets = {
            {-100, 80},
            {-100, -80},
            {-220, 80},
            {-220, -80}
        }
        for _, offset in ipairs(offsets) do
            local childFish = root:CreateFish("actions/general/lantern.actions", "fish0.lua")
            childFish:SetOffset(offset[1], offset[2])
            this:AddChildFish(childFish)
        end
        t.inited = true
    end
    Init();
    return 0
end)

if not FF_G.IsServer then
    lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
        FF_G_Client.ShowFishDeathEffect(player:GetId(), this:GetTypeId(), ratio * coin)
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
