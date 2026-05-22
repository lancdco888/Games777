-- dragon_red.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/once_shake.lua")(this, lua, root)

local funcs = {}

funcs.OnInit = function()
    super.OnInit()
    if not FF_G.IsServer then
        FF_G_Client.ShowDragonRedEdgeFireEffect()
    end
end

lua:Set_onInit(funcs.OnInit)

if not FF_G.IsServer then
    funcs.OnUnInit = function()
        super.OnUnInit()
        FF_G_Client.CloseDragonRedEdgeFireEffect()
    end
    lua:Set_onUnInit(funcs.OnUnInit)
end

return t, funcs