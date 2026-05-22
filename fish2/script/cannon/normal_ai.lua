-- cannon/normal_ai.lua
local this, lua, root = ...
-- 普通炮台逻辑

local t, super = FF_G.LoadLuaFunc("script/cannon/normal.lua")(this, lua, root)

--local player = this:GetPlayer()

lua:Set_onFireSimpleBullet(function(bulletId, waitTime, dt)
    local bullet = super.FireBullet(false, bulletId, dt, waitTime)
    if bullet == nil then return root:CreateNullSimpleBullet() end
    bullet:SetEnableCollisionCheck(true)
    return bullet
end)

lua:Set_onFireTrackBullet(function(bulletId, waitTime, dt)
    local bullet = super.FireBullet(true, bulletId, dt, waitTime)
    if bullet == nil then return root:CreateNullTrackBullet() end
    bullet:SetEnableCollisionCheck(true)
    return bullet
end)

--if FF_G.IsServer then
--    local waitTime = math.random() * 3 + 3
--    local nextSwitchAngleTime = math.random(3, 6)
--    local isBottomSit = FF_G.IsInBottomSit(player:GetSitId())
--    lua:Set_onUpdate(function(dt)
--        if waitTime > 0 then
--            waitTime = waitTime - dt
--            return 0
--        end
--        local enable = this:IsEnable()
--        if not enable then return 0 end
--        player:Fire()
--        if nextSwitchAngleTime > 0 then
--            nextSwitchAngleTime = nextSwitchAngleTime - dt
--        else
--            nextSwitchAngleTime = math.random(5, 50)
--            local angle = FF_G.GetRandomCannonAngle(isBottomSit)
--            --print("switch angle:", angle)
--            this:SetAngle(angle)
--            this:NotifySyncAngleMsg()
--        end
--        return 0
--    end)
--end