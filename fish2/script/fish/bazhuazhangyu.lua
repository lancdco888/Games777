-- bazhuazhangyu.lua
local this, lua, root = ...
local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

-- 声明用户数据
t.dt = 0
t.slotIndex = 0

if FF_G.IsStandalone then
    local last = FF_G.last_stlotIndex or 1
    t.slotIndex = last % 4 + 1
    FF_G.last_stlotIndex = t.slotIndex
end

-- 锁定点(客户端)
local lockPoint
local animNode = this:GetAnimNode()

lua:Set_onInit(function()
    --print("init")
    super.OnInit()
    this:SetMoveable(false)
    if FF_G.IsServer then
        assert(FF_G.CurrentBg)
        t.slotIndex = FF_G.CurrentBg.getNextSlot(true)
    end
    assert(t.slotIndex >= 1 and t.slotIndex <= 4)
    if not FF_G.IsServer then
        --print("King octopus init slot index:", t.slotIndex)
        assert(t.slotIndex >= 1 and t.slotIndex <= 4)
        animNode:Hide()
        this:SetBeatable(false)
        this:SetDeathType(FF_G_Client.kFishDeathType_Shake)
    end
    return 0
end)

lua:Set_onUnInit(function()
    super.OnUnInit()
    if FF_G.IsServer then
        assert(FF_G.CurrentBg)
        FF_G.CurrentBg.unlock(t.slotIndex)
    end
    if not FF_G.IsServer then
        local curBg = FF_G.CurrentBg
        if curBg then
            local action = curBg.this
            assert(action)
            local bgT = curBg.userData
            assert(bgT.type == "11", "bg is invalid:" .. bgT.type)
            local anim = action:GetAnim()
            anim:UnbindAnimToBone("" .. t.slotIndex)
            print("unbind bone")
        end
        if lockPoint then
            lockPoint:removeFromParent()
        end
    end
end)

if not FF_G.IsServer then
    local inited = false

    local Init = function()
        if inited then
            if not lockPoint then
                animNode:Show()
                lockPoint = cc.Sprite:createWithSpriteFrameName("zhangyu_suodingquan.png")
                lockPoint:setScale(2, 2)
                lockPoint:runAction(cc.RepeatForever:create(cc.RotateBy:create(2.5, -360)))
                FF_G_Client.AddNodeTo(lockPoint, FF_G.kNodeIndex_Lock)
            end
            return
        end
        local curBg = FF_G.CurrentBg
        if curBg then
            local action = curBg.this
            assert(action)
            local bgT = curBg.userData
            assert(bgT.type == "11", "bg is invalid:" .. bgT.type)
            local anim = action:GetAnim()
            local anim1 = this:GetAnimNode()
            local root = FF_G_Client.GetAnimRootNode(anim1)
            FF_G_Client.SwitchParentToNodeIndex(root, FF_G.kNodeIndex_BgMid)
            --anim1:PushRootNode()
            --anim:BindBone("" .. t.slotIndex)
            anim:BindAnimToBone("" .. t.slotIndex, anim1)
            inited = true
            --print("bind bone")
        end
    end

    lua:Set_onUpdate(function(dt)
        Init()
        if lockPoint then
            local x, y = this:GetCurrentLockPoint()
            lockPoint:setPosition(x, y)
            lockPoint:setVisible(not this:IsDeath())
        end
        return 0
    end)

    --lua:Set_onDeath(function(player, _, _,ratio, coin)
    --    FF_G_Client.ShowFishDeathEffect(player:GetId(), this:GetTypeId(), ratio * coin)
    --    super.PlayDeathEffect()
    --    return 0
    --end)
end
