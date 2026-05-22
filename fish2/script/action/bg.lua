-- action/bg.lua
local this, lua, root = ...

local t = {
    time = 0,
    hasAction = false,
    open = false,
    close = false,
    inited = false,
    type = -1,
    -- 章鱼背景插槽
    slots = {},
}

local observer = {
    onReceive = function(_, data)
        local msg = data.msg
        --print("play:", msg, ",", data.loops)
        this:SetAction(msg)
        this:SetLoops(data.loops == true)
        --if msg == "open" then
        --    print("play bg open anim.")
        --    this:SetAction("open")
        --elseif msg == "close" then
        --    print("play bg close anim.")
        --    this:SetAction("close")
        --end
    end
}

--  前景图片(客户端用)
local nodeFg

lua:Set_onInit(function()
    local filename = this:GetActionsFileName()
    local index = string.match(filename, "actions/bg/bg(%d+).actions")
    --print("bg filename:", filename, index)
    if filename == "actions/bg/bg3.actions" then
        t.hasAction = true
    end
    if not t.inited and index then
        t.type = index
        this:SetLoops(false)
        local fgAction = string.format("actions/bg/bg%s_fg.actions", index)
        --print("fg action:", fgAction)
        --local ret, action = root:ShowEffect(fgAction, "enter",
        --        "", FF_G.kNodeIndex_FishFront, 0, 0, true)
        local ret, action = root:ShowEffect(fgAction, "enter",
                "", FF_G.kNodeIndex_Bg2, 0, 0, true)
        if ret then
            local anim = action:GetAnim()
            anim:SetZ(2)
            this:PushEffect(action)
            action:SetLoops(false)
        end
        t.inited = true
    end
    if not FF_G.IsServer then
        -- 章鱼前景
        if index == '11' then
            local node = cc.Sprite:create("ui/base/by_cj_shenhaibazhua_06.png")
            FF_G_Client.AddNodeTo(node, FF_G.kNodeIndex_Bg2)
            FF_G_Client.PushNode(node)
            local anim = this:GetAnim()
            anim:BindBone("top")
            nodeFg = node
            local ret, action = root:ShowEffect("actions/bg/bg11_zy.actions", "bg11_zy",
                    "", FF_G.kNodeIndex_Bg0, 0, 0, false)
            assert(ret)
            this:PushEffect(action)
            anim:BindAnimToBone("zy", action:GetAnim())
        end
    end
    FF_G.Broadcast.register("bgPlayAnimEvent", observer)
    FF_G.CurrentBg = {
        this = this,
        lua = lua,
        userData = t,
        getNextSlot = function(lock)
            local slots = {}
            for i = 1, 4 do
                if t.slots[i] ~= true then
                    table.insert(slots, i)
                end
            end
            local len = #slots
            assert(len > 0, "no unused slot.")
            local index = slots[math.random(1, len)]
            if lock then
                t.slots[index] = true
            end
            return index
        end,
        lock = function(index)
            assert(t.slots[index] ~= true)
            t.slots[index] = true
        end,
        unlock = function(index)
            --assert(t.slots[index] == true)
            t.slots[index] = false
        end,
    }
end)

lua:Set_onUnInit(function()
    --print("bg UnInit.")
    FF_G.Broadcast.unRegister("bgPlayAnimEvent", observer)
    if FF_G.CurrentBg and FF_G.CurrentBg.this == this then
        FF_G.CurrentBg = nil
    end
    if nodeFg then
        nodeFg:removeFromParent()
    end
end)

lua:Set_onUpdate(function(dt)
    if not t.hasAction then return 0 end
    t.time = t.time + dt

    --if t.time >= 3 and not t.open then
    --    print("open")
    --    this:SetAction("open")
    --    t.open = true
    --end
    --if t.time >= 8 and not t.close then
    --    print("close")
    --    this:SetAction("close")
    --    t.close = true
    --end
    return 0
end)

lua:Set_onCall(function(msg)
    --print("onCall:" .. msg)
    if msg == "exit" then
        this:SetAction("exit")
        local effects = this:GetRelationEffects()
        --print(type(effects))
        for _, effect in ipairs(effects) do
            effect:SetAction("exit")
        end
    end

    if t.hasAction then
        if msg == "open" then
            --print("play bg open anim.")
            this:SetAction("open")
        elseif msg == "close" then
            --print("play bg close anim.")
            this:SetAction("close")
        end
    end
end)

lua:Set_onSerialize(function()
    GT = t
end)

lua:Set_onDeserialize(function()
    local t_ = GT
    for k, v in pairs(t_) do
        t[k] = v
    end
end)
