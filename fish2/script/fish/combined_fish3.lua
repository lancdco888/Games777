-- combined_fish3.lua
-- 组合鱼3 -> 蝠鲼*3
local this, lua, root = ...

local t = {
    inited = false
}

local Init = function()
    if FF_G_Client then
        FF_G_Client.AddCombinedBg(this, 1.15)
        local children = this:GetChildren()
        for _, fish in ipairs(children) do
            FF_G_Client.AddCombinedBg(fish, 1.15)
        end
        local z = this:GetAnimNode():GetZ()
        children[1]:GetAnimNode():SetZ(z - 1)
        children[2]:GetAnimNode():SetZ(z + 1)
        ---- 切换z
        --local rootNode = FF_G_Client.GetAnimRootNode(this:GetAnimNode())
        --FF_G_Client.ReAddToParent(rootNode)
        --if lastFish then
        --    lastFish:GetAnimNode():PushRootNode()
        --    local rootNode = FF_G_Client.GetAnimRootNode(lastFish:GetAnimNode())
        --    FF_G_Client.ReAddToParent(rootNode)
        --end
    end
end

lua:Set_onInit(function()
    if not t.inited then
        local offsets = {
            {140, 0},
            {-140, 0},
        }
        for _, offset in ipairs(offsets) do
            local childFish = root:CreateFish("actions/general/fuyu.actions", "fish0.lua")
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
