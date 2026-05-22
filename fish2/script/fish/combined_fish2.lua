-- combined_fish2.lua
-- 组合鱼2 -> 鲨鱼*1 + 旗鱼*4
local this, lua, root = ...

local t = {
    inited = false
}

local Init = function()
    if FF_G_Client then
        FF_G_Client.AddCombinedBg(this, 1.15)
        for _, fish in ipairs(this:GetChildren()) do
            FF_G_Client.AddCombinedBg(fish, 0.7)
        end
    end
end

lua:Set_onInit(function()
    if not t.inited then
        local offsets = {
            {-90, 90},
            {-90, -90},
            {90, 90},
            {90, -90}
        }
        for _, offset in ipairs(offsets) do
            local childFish = root:CreateFish("actions/general/qiyu.actions", "fish0.lua")
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
