-- 喷金币效果

local FountainPool = Class("FountainPool")

local math_pow = math.pow

local function createBezierCurve(P0, P1, P2)
    return function(t)
        local x = math_pow(1 - t, 2) * P0.x
                + 2 * (1 - t) * t * P1.x
                + math_pow(t, 2) * P2.x
        local y = math_pow(1 - t, 2) * P0.y
                + 2 * (1 - t) * t * P1.y
                + math_pow(t, 2) * P2.y

        return x, y
    end
end

local function lerp(p1, p2, alpha)
    return p1 * (1 - alpha) + p2 * alpha
end


local function randomRange(range)
    local min = range[1]
    local max = range[2]
    if min > max then
        min, max = max, min
    end
    return math.random(min, max)
end

function FountainPool:ctor(parent)
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
end

function FountainPool:__delete()
    self:Stop()
    for _, object in pairs(self.activeObjects) do
        FTween.KillTweens(object, nil, false)
    end
    self:Clear()
    self.rootNode:RemoveFromParent(true)
end

function FountainPool:SetSortingOrder(value)
    self.rootNode.sortingOrder = value
end

-- @brief 设置动画间隔
function FountainPool:SetAnimationInterval(value)
    self.interval = value
end

-- @brief
-- @param cfgs 动画资源配置
-- 参数示例: 
-- {
--  {
--     url = "ui://Game324/mini_bonus",
--     widget = 10,            -- 权重(可选, 默认为1)
--     rotation = {-180, 180}, -- 旋转角度随机范围(可选)
--     height = {300, 650},    -- 抛起高度范围(可选)
--     width = {200, 300},     -- 抛起范围(可选)
--     scale = {1, 1},         -- 起始到结束的缩放值
--     speed = 200,            -- 速度(可选)
--     dropValue = 0,          -- 向下掉落距离(可选，默认0)
--     offset = {x = 0,y = 0}, -- 金币实例偏移值
--  },
--  {
--     url = "ui://Game324/mini_bonus"
--  }
-- }
function FountainPool:Play(cfgs)
    self:Stop()

    assert(#cfgs > 0)
    self.cfgs = clone(cfgs)


    local function doPlay()
        self.activeCount = self.activeCount + 1
        local cfg = self:RandomCfg()

        -- 位置偏移
        local posOffset = cfg.offset or vec2()
        -- 旋转角度随机范围
        local rotationRange = cfg.rotation or {-180, 180}
        -- 抛起高度随机范围
        local yRange = cfg.height or {300, 650}
        -- 抛起宽度随机范围
        local xRange = cfg.width or {200, 300}
        -- 速度
        local speed = cfg.speed or 250
        -- 掉落距离
        local dropValue = cfg.dropValue or 0
        -- 起始到结束的缩放值
        local scale = cfg.scale


        local coin = self:Fetch(cfg.url)
        coin.rotation = randomRange(rotationRange)
        coin.xy = posOffset
        if scale then
            coin.scaleX = scale[1]
            coin.scaleY = scale[1]
        end

        local deltaX     = randomRange(xRange)
        local jumpHeight = -randomRange(yRange)
        local duration   = (math.abs(jumpHeight) + math.abs(dropValue)) / speed

        if math.random(1, 100) <= 50 then deltaX = -deltaX end

        table.insert(self.activeObjects, coin)

        local updateLogic

        if dropValue == 0 then
            -- jump动画
            updateLogic = function(t)
                local frac = t
                local y    = jumpHeight * 4 * frac * (1 - frac)
                coin.xy = vec2(posOffset.x + deltaX * t, posOffset.y + y)
                if scale then
                    local value = lerp(scale[1], scale[2], t)
                    coin.scaleX = value
                    coin.scaleY = value
                end
            end
        else
            -- 抛物线动画
            deltaX = deltaX / 2
            jumpHeight = jumpHeight * 2
            local P0 = vec2()
            local P2 = vec2(deltaX, dropValue)
            local P1 = vec2(deltaX / 2, jumpHeight)

            local curve = createBezierCurve(P0, P1, P2)

            updateLogic = function(t)
                local x, y = curve(t)
                coin.xy = vec2(posOffset.x + x, posOffset.y + y)
                if scale then
                    local value = lerp(scale[1], scale[2], t)
                    coin.scaleX = value
                    coin.scaleY = value
                end
            end
        end

        -- 模拟抛物线
        FairyGUI.GTween.ToDouble(0, 1, duration)
        :OnUpdate(function(tweener)
            updateLogic(tweener.value.d)
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
        FTween.Delay(self.interval, doPlay),
    }))
end

function FountainPool:Stop()
    FTween.KillTweens(self.rootNode)
end

--------------------------------------------------- private ---------------------------------------------------

function FountainPool:RandomCfg()
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


function FountainPool:Fetch(url)
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

function FountainPool:Put(obj, url)
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

function FountainPool:Clear()
    for _, pool in pairs(self.objectPool) do
        for __, obj in pairs(pool) do
            FTween.KillTweens(obj)
            obj:RemoveFromParent(true)
        end
    end
    self.objectPool = {}
end

return FountainPool
