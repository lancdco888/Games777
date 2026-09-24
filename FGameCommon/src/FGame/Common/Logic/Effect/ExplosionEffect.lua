-- 爆炸效果

local ExplosionEffect = Class("ExplosionEffect")

local function lerp(p1, p2, alpha)
    return p1 * (1 - alpha) + p2 * alpha
end

local function clamp01(value)
    return math.min(1, math.max(0, value))
end

local function randomRange(range)
    if type(range) == "function" then
        return range()
    end
    local min = range[1]
    local max = range[2]
    if min > max then
        min, max = max, min
    end
    return math.random(min, max)
end

function ExplosionEffect:ctor(parent)
    -- dump(parent,"parent",10)
    if parent == nil then
        parent = FCasinoCtx.commonPanel:GetEffectLayer()
    end

    self.rootNode = FairyGUI.GComponent()
    self.rootNode.xy = vec2(parent.width * 0.5, parent.height)
    parent:AddChild(self.rootNode)

    self.objectPool = {}
    self.activeCount = 0
    self.activeObjects = {}

    -- 动画间隔
    self.interval = 1 / 20

    self.spawnCount = 1
end

function ExplosionEffect:__delete()
    self:Stop()
    for _, object in pairs(self.activeObjects) do
        FTween.KillTweens(object, nil, false)
    end
    self:Clear()
    self.rootNode:RemoveFromParent(true)
end

function ExplosionEffect:SetSortingOrder(value)
    self.rootNode.sortingOrder = value
end

-- @brief 设置动画间隔
function ExplosionEffect:SetAnimationInterval(value)
    self.interval = value
end

-- @brief
-- @param cfgs 动画资源配置
-- 参数示例: 
-- {
--  {
--     url = "ui://Game324/mini_bonus",
--     speed = {5, 10},
--     gravity = -9.8,      -- 重力加速度
--     damping = 0.5,       -- 空气阻力系数（每秒速度保留的比例）
--     lifeTime = 1.5,      -- 金币存活时间
--     rotation = {0, 360}, -- 旋转角度随机范围
--     rotationSpeed = {360, 360}, -- 旋转速度（度/秒）
--     offset = vec2(0, 0), -- 位置偏移
--     scale = {1, 1},    -- 起始到结束的缩放值
--  },
-- }
function ExplosionEffect:Play(cfgs, play_duration)
    self:Stop()

    assert(#cfgs > 0)
    self.cfgs = clone(cfgs)


    local function doPlay()
        self.activeCount = self.activeCount + 1
        local cfg = self:RandomCfg()


        -- 速度
        local speed = randomRange(cfg.speed or {5, 10})
        -- 重力加速度
        local gravity = cfg.gravity or -9.8
        -- 空气阻力系数（每秒速度保留的比例）
        local damping = cfg.damping or 0.5
        -- 金币存活时间
        local lifeTime = cfg.lifeTime or 1.5
        -- 旋转角度
        local rotation = randomRange(cfg.rotation or {0, 360})
        -- 旋转速度（度/秒）
        local rotationSpeed = randomRange(cfg.rotationSpeed or {300, 360})
        -- 位置偏移
        local offset = cfg.offset or vec2()
        -- 起始到结束的缩放值
        local scale = cfg.scale or {1, 1}


        local coin = self:Fetch(cfg.url)
        coin.rotation = rotation
        coin.xy = offset
        if scale then
            coin.scaleX = scale[1]
            coin.scaleY = scale[1]
        end

        table.insert(self.activeObjects, coin)

        -- 将角度转换为方向向量
        local deg2Rad = math.pi / 180
        local radian = math.random(0, 360) * deg2Rad
        local  direction = {x = math.cos(radian), y = math.sin(radian)}
        local velocity = { x = direction.x * speed, y = direction.y * speed}

        -- 模拟抛物线
        FairyGUI.GTween.ToDouble(0, 1, lifeTime)
        :OnUpdate(function(tweener)
            local deltaTime = tweener.deltaValue.d
            
            -- 应用重力
            velocity.y = velocity.y + gravity * deltaTime
            
            -- 应用空气阻力（线性衰减）
            velocity.x = velocity.x * clamp01(1 - damping * deltaTime)
            velocity.y = velocity.y * clamp01(1 - damping * deltaTime)

            --  更新位置
            coin.x = coin.x + velocity.x * deltaTime
            coin.y = coin.y + velocity.y * deltaTime

            -- 旋转效果
            coin.rotation = coin.rotation + rotationSpeed * deltaTime

            
            if scale[1] ~= scale[2] then
                local t = tweener.value.d
                local value = lerp(scale[1], scale[2], t)
                coin.scaleX = value
                coin.scaleY = value
            end
        end)
        :OnComplete(function()
            for key, value in pairs(self.activeObjects) do
                if value == coin then
                    table.remove(self.activeObjects, key)
                    break
                end
            end

            self:Put(coin, cfg.url)
            self.activeCount = self.activeCount - 1
            if self.activeCount <= 0 then
                self:Clear()
            end
        end)
        :SetTarget(coin)
        :SetEase(FairyGUI.EaseType.SineOut)
    end

    FTween.Start(self.rootNode, FTween.RepeatForever({
        FTween.Delay(self.interval, function()
            for i = 1, self.spawnCount do
                doPlay()
            end
        end),
    }))
    
    if play_duration then
        FTween.Start(self.rootNode, FTween.Delay(play_duration, function()
            self:Stop()
        end))
    end
end

function ExplosionEffect:Stop()
    FTween.KillTweens(self.rootNode)
end

function ExplosionEffect:SetSpawnCount(value)
    self.spawnCount = value
end

--------------------------------------------------- private ---------------------------------------------------

function ExplosionEffect:RandomCfg()
    if #self.cfgs == 1 then
        return self.cfgs[1]
    end

    -- 根据权重随机
    local totalWidget = 0
    for _, v in pairs(self.cfgs) do
        if not v.widget then v.widget = 1 end

        -- 起始值
        v.startWidget = totalWidget

        totalWidget = totalWidget + v.widget

        -- 结束值
        v.endWidget = totalWidget
    end

    local rand = math.random(1, totalWidget)
    for _, v in pairs(self.cfgs) do
        if v.widget > 0 and rand >= v.startWidget and rand <= v.endWidget then
            return v
        end
    end
    assert(false)
end


function ExplosionEffect:Fetch(url)
    if not self.objectPool[url] then self.objectPool[url] = {} end

    local obj = nil
    if #self.objectPool[url] > 0 then
        obj = table.remove(self.objectPool[url])
        obj.visible = true
        obj.playing = true
        return obj        
    end

    obj = FairyGUI.UIPackage.CreateObjectFromURL(url)
    self.rootNode:AddChild(obj)
    
    local item = FairyGUI.UIPackage.GetItemByURL(url)
    -- 开始帧动画播放
    if item.type == FairyGUI.PackageItemType.MovieClip then
        obj:SetPlaySettings()
    end

    return obj
end

function ExplosionEffect:Put(obj, url)
    if not self.objectPool[url] then self.objectPool[url] = {} end

    local pool = self.objectPool[url]
    for _, value in pairs(pool) do
        if value == obj then
            return
        end
    end

    local item = FairyGUI.UIPackage.GetItemByURL(url)
    assert(item ~= nil, "bad item url:" .. tostring(url))

    -- 帧动画暂停播放
    if item.type == FairyGUI.PackageItemType.MovieClip then
        obj.playing = false
    end
    
    obj.visible = false
    FTween.KillTweens(obj)
    table.insert(self.objectPool[url], obj)
end

function ExplosionEffect:Clear()
    for _, pool in pairs(self.objectPool) do
        for __, obj in pairs(pool) do
            FTween.KillTweens(obj)
            obj:RemoveFromParent(true)
        end
    end
    self.objectPool = {}
end

return ExplosionEffect
