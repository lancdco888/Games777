-- fish/seaweed.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)


if not FF_G.IsServer then
    local seaweedAction
    lua:Set_onInit(function()
        super.OnInit()
        local action = this:GetActionNode();
        FF_G_Client.GetActionDrawNode(action):setVisible(false)
        local info = FF_G.TypeIdToFishCreator[this:GetTypeId()]

        local ret, seaweed =  root:ShowEffect(
                string.format("actions/cs/seaweed/fish_%d.actions", info.seaweedType),
                "show", "", FF_G.kNodeIndex_Fishnet, 0, 0, false)
        assert(ret)

        local node = FF_G_Client.GetActionRootNode(seaweed)
        local root = FF_G_Client.GetActionRootNode(action)
        FF_G_Client.SwitchParentTo(node, root)
        this:PushEffect(seaweed)

        seaweedAction = seaweed
        return 0
    end)

    --lua:Set_onUnInit(function()
    --    super.OnUnInit()
    --    if seaweedAction then
    --        seaweedAction:SetClean(true)
    --        seaweedAction = nil
    --    end
    --end)

    lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
        if seaweedAction then
            seaweedAction:SetClean(true)
            seaweedAction = nil
        end
        local action = this:GetActionNode();
        FF_G_Client.GetActionDrawNode(action):setVisible(true)
        return super.OnDeath(player, cannonId, bulletId, ratio, coin)
    end)
end

return t, funcs