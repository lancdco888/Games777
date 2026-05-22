-- once_shake.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

local funcs = {}
FF_G.CloneFuncs(super, funcs)

funcs.OnInit = function()
    super.OnInit()
    this:GetActionNode():SetLoop(1)
    this:Forward(0.001)
    this:SetPos(0, 0)
    this:SetMoveable(false)
    if not FF_G.IsServer then
        this:SetBeatable(false)
        t.disableDeathEffect = true
        this:SetDeathType(FF_G_Client.kFishDeathType_Shake2)
    end
end

lua:Set_onInit(funcs.OnInit)

--lua:Set_onUpdate(function(dt)
--    return 0
--end)

if not FF_G.IsServer then
    funcs.OnUnInit = function()
        super.OnUnInit()
        super.ShowDeathEffect()
    end
    lua:Set_onUnInit(funcs.OnUnInit)
end

return t, funcs