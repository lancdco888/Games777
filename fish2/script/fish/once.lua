-- fish/once.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

lua:Set_onInit(function()
    super.OnInit()
    this:GetActionNode():SetLoop(1)
    this:Forward(0.001)
    this:SetPos(0, 0)
    this:SetMoveable(false)
    return 0
end)

--lua:Set_onUpdate(function(dt)
--    this:SetPos(0, 0)
--    return 0
--end)
