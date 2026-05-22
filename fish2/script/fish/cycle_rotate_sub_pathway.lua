-- cycle_rotate_sub_pathway.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/cycle.lua")(this, lua, root)

-- 声明用户数据
t.speed = math.pi / 2

lua:Set_onInit(function()
    if not t.init then
        if FF_PRAMS and FF_PRAMS.speed then
            t.speed = FF_PRAMS.speed
        end
    end
    super.OnInit()
    --print("cycle_rotate_sub_pathway speed:" .. t.speed)
    return 0
end)

lua:Set_onSubPathwayMove(function(subPathway, dt)
    local angle = subPathway:GetAngle() + dt * t.speed
    subPathway:SetAngle(angle)
    return 0
end)
