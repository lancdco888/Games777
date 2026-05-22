-- rotate_sub_pathway.lua
local this, lua, root = ...

local t = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

-- 声明用户数据
t.speed = math.pi / 2

--local t = {
--    init = false,
--    speed = math.pi / 2,
--}
--
lua:Set_onInit(function()
    if not t.init then
        if FF_PRAMS and FF_PRAMS.speed then
            t.speed = FF_PRAMS.speed
        end
        t.init = true
    end
    --print("rotate_sub_pathway speed:" .. t.speed)
    return 0
end)
--
--if not FF_G.IsServer then
--    lua:Set_onDeath(function(player, _, _,ratio, coin)
--        FF_G_Client.ShowFishDeathEffect(player:GetId(), this:GetTypeId(), ratio * coin)
--        return 0
--    end)
--end
--
lua:Set_onSubPathwayMove(function(subPathway, dt)
    --print("onSubPathwayMove")
    local angle = subPathway:GetAngle() + dt * t.speed
    subPathway:SetAngle(angle)
    return 0
end)
--
--lua:Set_onSerialize(function()
--    GT = t
--end)
--
--lua:Set_onDeserialize(function()
--    local t_ = GT
--    for k, v in pairs(t_) do
--        t[k] = v
--    end
--end)