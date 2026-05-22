-- fish/base.lua
local this, lua, root = ...

local t = {
    --enableScaleIn = false,      -- 从小变大进场
    --enableFadeIn = false,       -- 淡入
    --enableFadeOut = false,      -- 淡出
    --disableDeathEffect = false,
    --hasShowComeTips = false,
    --scaleInSec = 0,             -- 从小变大持续时间
    --fadeInSecs = 0,             -- 淡入持续时间
    --fadeOutStartTime = 0,       -- 淡出开始
    --fadeOutSecs = 0,            -- 淡出持续时间
    -- mustPlayDeathEffect = false, -- 必放死亡音效
    time = 0,
}
local funcs = {}

local UpdateProps = function()
    if FF_G.IsServer then
        if t.enableFadeOut and  t.time > t.fadeOutStartTime then
            local opacity = 255 - math.max(0, math.min(255, (t.time - t.fadeOutStartTime) / t.fadeOutSecs * 255))
            if opacity == 0 then
                this:SetState(FF_G.kState_Clean)
            end
        end
    end
    if not FF_G.IsServer then
        if t.enableFadeIn then
            local opacity = math.max(0, math.min(255, t.time / t.fadeInSecs * 255))
            this:SetOpacity(opacity)
            this:SetAttackalbe(opacity == 255)
        end
        if t.enableFadeOut and t.time > t.fadeOutStartTime then
            local opacity = 255 - math.max(0, math.min(255, (t.time - t.fadeOutStartTime) / t.fadeOutSecs * 255))
            this:SetOpacity(opacity)
            if opacity == 0 then
                this:SetState(FF_G.kState_Clean)
            end
            this:SetAttackalbe(false)
        end
        if t.enableScaleIn and this:GetState() == FF_G.kState_Normal then
            local scale = math.max(0, math.min(1, t.time / t.scaleInSec)) * t.destScale
            this:SetScale(scale, scale)
        end
    end
end

local actions = {}

funcs.OnInit = function()
    local typeId = this:GetTypeId()
    local info = FF_G.TypeIdToFishCreator[typeId]
    t.mustPlayDeathEffect = info.mustPlayDeathEffect == true
    if FF_PRAMS then
        local prams = FF_PRAMS.createPrams
        if type(prams) == "table" then
            for k, v in pairs(prams) do
                t[k] = v
            end
            t.enableFadeIn = t.fadeInSecs and t.fadeInSecs > 0
            t.enableFadeOut = t.fadeOutSecs and t.fadeOutSecs > 0
            t.enableScaleIn = t.scaleInSec and t.scaleInSec > 0
            if t.enableScaleIn then
                local scale = info.scale or 1
                t.destScale = scale
            end
        end
    end
    if not FF_G.IsServer then
        if info.extRes then
            local frameCache = cc.SpriteFrameCache:getInstance()
            for _, res in pairs(info.extRes) do
                print(res, string.endsWith(res, ".plist"))
                if string.endsWith(res, ".plist") then
                    frameCache:addSpriteFrames(res)
                end
            end
        end
        local bgInfo = info.bgInfo
        if bgInfo then
            local scale = bgInfo.scale or 1
            local bg = cc.Sprite:createWithSpriteFrameName(bgInfo.sprite)
            bg:setLocalZOrder(-1)
            bg:setScale(scale)
            if bgInfo.rotation then
                bg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))
            end
            local action = this:GetActionNode()
            local node = FF_G_Client.GetActionRootNode(action)
            node:addChild(bg)
        end
        if this:GetWaitTime() <= 0 then
            UpdateProps()
        end
        if not t.hasShowComeTips and t.time < 1 then
            --local info = FF_G.TypeIdToFishCreator[this:GetTypeId()]
            if info.BornTipsInfo then
                FF_G_Client.ShowFishCome(info.BornTipsInfo)
                t.hasShowComeTips = true
            end
            local bornMusic = info.bornMusic
            if bornMusic then
                if math.random() <= bornMusic.probability then
                    local fishId = this:GetId()
                    local path = bornMusic.paths[math.random(1, #bornMusic.paths)]
                    FF_G.AddTimerTask(bornMusic.delayTime, function()
                        local fish = root:FindFish(fishId)
                        if not fish:IsNull() and fish:GetState() == FF_G.kState_Normal then
                            FF_G.playEffect(path)
                        end
                    end)
                end
            end
        end
        -- init particle
        if info.particles then
            local root = FF_G_Client.GetActionRootNode(this:GetActionNode())
            for _, pInfo in ipairs(info.particles) do
                local particle = cc.ParticleSystemQuad:create(pInfo.path)
                local x, y, z = pInfo.x or 0, pInfo.y or 0, pInfo.z or 0
                particle:setPosition(x, y)
                particle:stop()
                particle:runAction(cc.Sequence:create(
                        cc.DelayTime:create(1.5),
                        cc.CallFunc:create(function()
                            particle:start()
                        end)
                ))
                root:addChild(particle, z)
            end
        end
        if info.upwards then
            this:Forward(0.001)
            local angle = this:GetAngle()
            local isRotation = root:IsRotate()
            local anim = this:GetAnimNode()
            --print("angle:", angle, isRotation)
            local node = FF_G_Client.GetAnimDrawNode(anim)
            local needFlipY = false
            if isRotation then
                if angle < math.pi / 2 and angle > -math.pi / 2 then
                    --node:setScaleY(-1)
                    needFlipY = true
                end
            else
                if angle > math.pi / 2 or angle < -math.pi / 2 then
                    --node:setScaleY(-1)
                    needFlipY = true
                end
            end
            if needFlipY then
                node:setScaleY(-1)
                if info.upwardsFlipX then
                    node:setScaleX(-1)
                end
            end
        end
        if info.beatless then
            t.beatless = true
            this:SetBeatable(false)
        end
        local cycloneSKin = info.cycloneSKin
        if info.isCycleFish and cycloneSKin then
            local typeId = cycloneSKin.type
            local offset = cycloneSKin.offset
            local ret, effect =  root:ShowEffect(
                    string.format("actions/cs/cyclone/fish_%d.actions", typeId),
                    "show", "", FF_G.kNodeIndex_Fishnet, offset.x, offset.y, false)
            assert(ret)
            local node = FF_G_Client.GetActionRootNode(effect)
            local root = FF_G_Client.GetActionRootNode(this:GetActionNode())
            if cycloneSKin.rotation then
                local drawNode = FF_G_Client.GetActionDrawNode(effect)
                drawNode:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))
            end
            effect:GetAnim():SetZ(-1)
            FF_G_Client.SwitchParentTo(node, root)
            table.insert(actions, effect)
        end
    end
end

funcs.OnUnInit = function()
    for _, action in pairs(actions) do
        action:SetClean(true)
    end
    actions = {}
end

funcs.OnUpdate = function(dt)
    --if this:GetWaitTime() > 0 then return 0 end
    t.time = t.time + dt
    UpdateProps()
    --if not FF_G.IsServer then
    --    UpdateProps()
    --end
    return 0
end

funcs.ShowDeathEffect = function()
    local player = this:GetKillPlayer()
    local playerId = -1
    if not player:IsNull() then
        playerId = player:GetId()
    end
    FF_G_Client.ShowFishDeathEffect(playerId, this:GetTypeId(), this:GetValue())
end

lua:Set_onInit(funcs.OnInit)
lua:Set_onUnInit(funcs.OnUnInit)
lua:Set_onUpdate(funcs.OnUpdate)

if not FF_G.IsServer then
    funcs.PlayDeathEffect = function()
        local typeId = this:GetTypeId()
        local info = FF_G.TypeIdToFishCreator[typeId]
        assert(info)
        if t.mustPlayDeathEffect or (math.random() <= FF_G.GameConfig.PlayDeathTalkMusicProbability) then
            local music = info.deathMusic
            if music then
                FF_G.playEffect(music)
            end
        end
    end
    funcs.OnDeath = function(player, cannonId, bulletId, ratio, coin)
        local typeId = this:GetTypeId()
        funcs.PlayDeathEffect()
        local value = ratio * coin
        local x, y = this:GetPos()
        if not t.disableDeathEffect then
            FF_G_Client.ShowFishDeathEffect(player:GetId(), typeId, value)
        end
        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_CoinMoveToPlayer, {
            playerId = player:GetId(),
            src = {x = x, y = y},
            coin = value,
        })
        if t.beatless then
            this:SetMoveable(false)
        end
        return 0
    end

    lua:Set_onDeath(funcs.OnDeath)

    lua:Set_onEvent(function(eventId)
        --print("onEvent:", eventId)
        if eventId == 1100 then
            root:ShakeScreen(0.20, 6)
        elseif eventId == 1200 then
            --  蛮荒凶兽奔跑时候的音效
            FF_G.playEffect("Buffalo_Move")
        end
    end)
end

lua:Set_onSerialize(function()
    GT = t
end)

lua:Set_onDeserialize(function()
    local t_ = GT
    for k, v in pairs(t_) do
        t[k] = v
    end
end)

return t, funcs
