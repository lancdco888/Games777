-- fish/cycle.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)
local funcs = {}

-- 声明用户数据
t.inited = false

local cycleBornInfo = {
    avatar = "texiao_xuanfengyu.png",
    tips = "yuzhonglaixi_xuanfengyulaile.png",
    scale = 0.5,
}

funcs.OnInit = function()
    if not FF_G.IsServer then
        local info = FF_G.TypeIdToFishCreator[this:GetTypeId()]
        if info.hideHWCycleBg ~= true then
            local scale = info.cycleBgScale or 1
            local offset = info.cycleBgOffset or {0, 0}
            --local scale = FF_PRAMS and FF_PRAMS.cycleBgScale or 1
            --local offset = FF_PRAMS and FF_PRAMS.cycleBgOffset or {0, 0}
            local bg = cc.Sprite:createWithSpriteFrameName("xuanfengyu_xuanzhuan.png")
            bg:setScale(scale, scale)
            bg:setPosition(offset[1], offset[2])
            bg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))
            local rootNode = FF_G_Client.GetAnimRootNode(this:GetAnimNode())
            rootNode:addChild(bg, -1)
        end
    end
    this:SetWhirlwind(true)
    if not t.inited then
        local action = this:GetActionNode()
        action:SetAction("light")
        if not FF_G.IsServer then
            FF_G_Client.ShowFishCome(cycleBornInfo)
        end
    end
    t.inited = true
end

funcs.OnDeath = function(player, cannonId, bulletId, ratio, coin)
    --print("cycle death.")
    local relationFishId = this:relationFishId()
    table.insert(relationFishId, this:GetId())
    if FF_G.IsServer then
        for fishId in ipairs(relationFishId) do
            local fish = root:FindFish(fishId)
            if not fish:IsNull() then
                fish:SetState(FF_G.kState_Clean)
            end
        end
    end
    if not FF_G.IsServer then
        GT = {
            fishType = this:GetTypeId(),
            relationFishId = relationFishId
        }
        local cannon = player:GetNormalCannon()
        local bullet = cannon:CreateLuaBullet()
        bullet:SetRatio(ratio)
        bullet:SetLuaName("xuanfeng.lua")
        bullet:GetLua():SaveLuaDataFromGT()
        cannon:SendLuaBullet(bullet, 0)
        super.PlayDeathEffect()
    end
    return 1
end

lua:Set_onInit(function()
    super.OnInit()
    funcs.OnInit()
    return 0
end)

lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
    return funcs.OnDeath(player, cannonId, bulletId, ratio, coin)
end)

return t, funcs