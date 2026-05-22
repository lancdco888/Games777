-- fish/cs_cycle.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)
local funcs = {}

funcs.OnInit = function()
    super.OnInit()
    this:SetWhirlwind(true)
end

funcs.OnDeath = function(player, cannonId, bulletId, ratio, coin)
    local relationFishId = this:relationFishId()
    --table.insert(relationFishId, this:GetId())
    for fishId in ipairs(relationFishId) do
        local fish = root:FindFish(fishId)
        if not fish:IsNull() then
            if FF_G.IsServer then
                this:SetState(FF_G.kState_Clean)
            else
                fish:Death(player, cannonId, bulletId, ratio, 0, 0)
            end
        end
    end
    if FF_G.IsServer then
        this:SetState(FF_G.kState_Clean)
    else
        return super.OnDeath(player, cannonId, bulletId, ratio, coin)
    end
    return 1
end

lua:Set_onInit(function()
    funcs.OnInit()
    return 0
end)

lua:Set_onDeath(function(...)
    return funcs.OnDeath(...)
end)

return t, funcs