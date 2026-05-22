-- combined_fish5.lua
-- 组合鱼6 -> 黄金碟鱼*1 + 巨大碟鱼*2
local this, lua, root = ...

local t = {
    inited = false
}

local Init = function()
    if FF_G_Client then
        FF_G_Client.AddCombinedBg(this, 1.25)
        for _, fish in ipairs(this:GetChildren()) do
            FF_G_Client.AddCombinedBg(fish, 1.25)
        end
    end
end

lua:Set_onInit(function()
    if not t.inited then
        local offsets = {
            {-125, 100},
            {-125, -100},
        }
        for _, offset in ipairs(offsets) do
            local childFish = root:CreateFish("actions/general/judadieyu.actions", "fish0.lua")
            childFish:SetOffset(offset[1], offset[2])
            this:AddChildFish(childFish)
        end
        t.inited = true
    end
    Init()
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
