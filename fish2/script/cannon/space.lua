-- cannon/space.lua
local this, lua, root = ...

local t = {}

if not FF_G.IsServer then
    local cannonBg
    local srcX, srcY = this:GetPos()

    local function InitUi()
        cannonBg = cc.Sprite:createWithSpriteFrameName("paotaijizuo.png")
        cannonBg:setPosition(srcX, srcY)
        FF_G_Client.AddNodeTo(cannonBg, FF_G.kNodeIndex_Top)
    end

    lua:Set_onInit(function()
        InitUi();
        return 0
    end)

    lua:Set_onUnInit(function()
        if cannonBg ~= nil then
            cannonBg:removeFromParent()
            cannonBg = nil
        end
    end)

    lua:Set_onDraw(function()
        local enable = this:IsEnable()
        cannonBg:setVisible(enable)
    end)
end
