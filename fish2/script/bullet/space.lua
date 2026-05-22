-- bullet/space.lua
local this, lua, root = ...

if not FF_G.IsServer then
    lua:Set_onCreate(function()
        local anim = root:CreateAnimNode("actions/other/space.anims")
        anim:SetAnimIndex(0)
        anim:Hide()
        anim:SetScale(0, 0)
        this:SetAnim(anim)
        return 0
    end)
end
