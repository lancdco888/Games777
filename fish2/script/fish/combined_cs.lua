-- combined_cs.lua
-- 组合鱼1 -> 昌盛
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

local t = {
    inited = false
}

local AddCombinedBg = function(fish, info)
    if info == nil then return end
    local action = fish:GetActionNode()
    local anim = action:GetAnim()
    local node = FF_G_Client.GetActionRootNode(action)
    local bgStyle = info.bgStyle
    local fishScale = info.fishScale or 1
    local z = info.z or 0
    if bgStyle then
        local bg
        local offset = info.offset
        local bgScale = info.scale or 1
        if bgStyle == 100 then
            bg = FF_G_Client.CreateFrameAnim("fish_turntable100_%d.png", 1, 12, 1 / 15)
        else
            local bgName = string.format("fish_turntable%d.png", bgStyle)
            bg = cc.Sprite:createWithSpriteFrameName(bgName)
        end
        bg:setPosition(offset.x, offset.y)
        bg:setLocalZOrder(-1)
        bg:setScale(bgScale)
        if info.rotation then
            bg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))
        end
        node:addChild(bg)
    end
    anim:SetScale(fishScale, fishScale)
    if info.hideFish == true then
        local drawNode = FF_G_Client.GetActionDrawNode(action)
        drawNode:setVisible(false)
    end
    anim:SetZ(z)
end

local rootNode

lua:Set_onInit(function()
    super.OnInit()

    local info = FF_G.TypeIdToFishCreator[this:GetTypeId()]
    if not t.inited then
        for _, fishInfo in ipairs(info.subFish) do
            local offset = fishInfo.offset
            local childFish = root:CreateFish(fishInfo.actionFile, "sub_fish.lua")
            childFish:SetOffset(offset.x, offset.y)
            this:AddChildFish(childFish)
        end
        t.inited = true
    end

    if not FF_G.IsServer then
        do
            local action = this:GetActionNode()
            --local anim = action:GetAnim()
            local node = FF_G_Client.GetActionRootNode(action)
            local parent = node:getParent()
            local root = cc.Node:create()
            local z = (info.z * 10) or 0
            root:setLocalZOrder(z)
            parent:addChild(root)
            FF_G_Client.SwitchParentTo(node, root)
            rootNode = root
        end
        local combinedInfo = info.combinedInfo
        AddCombinedBg(this, combinedInfo)
        local idx = 1
        local children = this:GetChildren()
        local subFish = info.subFish
        for _, fish in ipairs(children) do
            local combinedInfo = subFish[idx].combinedInfo
            AddCombinedBg(fish, combinedInfo)
            local action = fish:GetActionNode()
            local node = FF_G_Client.GetActionRootNode(action)
            FF_G_Client.SwitchParentTo(node, rootNode)
            idx = idx + 1
        end
    end
    return 0
end)

if not FF_G.IsServer then
    lua:Set_onUnInit(function()
        super.OnUnInit()
        rootNode:runAction(cc.RemoveSelf:create())
    end)
end

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
