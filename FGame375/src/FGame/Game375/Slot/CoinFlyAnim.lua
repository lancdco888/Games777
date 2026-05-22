local CoinFlyAnim = Class("CoinFlyAnim")

CoinFlyAnim.Anims = {
    {url = "ui://Game375/Blue_ZS",},
    {url = "ui://Game375/Green_ZS",},
    {url = "ui://Game375/Red_ZS",},
    {url = "ui://Game375/Yellow_ZS",},
}

CoinFlyAnim.GoldBars = {
    {url = "ui://Game375/gold_bar_1"},
    {url = "ui://Game375/gold_bar_2"},
    {url = "ui://Game375/boom_lan"},
    {url = "ui://Game375/boom_zi"},
    {url = "ui://Game375/boom_lv"},
}

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
    return math.random(math.floor(min), math.floor(max))
end

function CoinFlyAnim:ctor(parent,pos,interval)
    if parent == nil then
        parent = FCasinoCtx.commonPanel:GetEffectLayer()
    end

    self.rootNode = FairyGUI.GComponent()
    if pos then
        self.rootNode.xy = pos
    else
        self.rootNode.xy = vec2(parent.width * 0.5, parent.height)
    end
    parent:AddChild(self.rootNode)
    self.maxheight = parent.height

    self.objectPool = {}
    self.activeCount = 0
    self.activeObjects = {}
    self.interval = interval    -- 动画间隔
end

function CoinFlyAnim:__delete()
    self:Stop()
    for _, object in pairs(self.activeObjects) do
        FTween.KillTweens(object)
    end
    self:Clear()
    self.rootNode:RemoveFromParent(true)
end

function CoinFlyAnim:SetSortingOrder(value)
    self.rootNode.sortingOrder = value
end

-- 金块
function CoinFlyAnim:PlayGoldBar(no_boom)
    self:Stop()
    local cfgs = {}
    if no_boom then
        cfgs = {self.GoldBars[1],self.GoldBars[2]}
    else
        cfgs = self.GoldBars
    end
    self.cfgs = cfgs

    local function doPlay()
        self.activeCount = self.activeCount + 1
        local cfg = self:RandomCfg(self.cfgs)

        -- 位置偏移
        local posOffset = cfg.offset or vec2()
        -- 旋转角度随机范围
        local rotationRange = cfg.rotation or {-180, 180}
        -- 抛起高度随机范围
        local yRange = cfg.height or {self.maxheight * 0.5, self.maxheight * 0.6}
        -- 抛起宽度随机范围
        local xRange = cfg.width or {100, 300}
        -- 速度
        local speed = cfg.speed or 180
        -- 掉落距离
        local dropValue = cfg.dropValue or 0
        -- 随机大小范围
        local scale_ = randomRange({0.8,1.2})

        local coin = self:Fetch(cfg.url)
        coin.rotation = randomRange(rotationRange)
        coin.xy = vec2()
        coin.scale = vec2(scale_,scale_)

        local deltaX     = randomRange(xRange)
        local jumpHeight = -randomRange(yRange)
        -- 抛起耗时
        local time_   = (math.abs(jumpHeight) + math.abs(dropValue)) / speed

        if math.random(1, 100) <= 50 then deltaX = -deltaX end

        table.insert(self.activeObjects, coin)
        -- 模拟抛飞线
        local updateLogic = function(t)
            local frac = t
            local y    = jumpHeight * 4 * frac * (1 - frac)
            coin.xy = vec2(posOffset.x + deltaX * t, posOffset.y + y)
        end

        -- 模拟抛物线
        FairyGUI.GTween.ToDouble(0, 1, time_)
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

    self.tween = FTween.Start(self.rootNode,FTween.RepeatForever({
            FTween.Delay(self.interval, doPlay),
        })
    )
end

--钻石
function CoinFlyAnim:PlayZS(bool_leftorright)
    self:Stop()

    self.cfgs = self.Anims

    local function doPlay()
        self.activeCount = self.activeCount + 1
        local cfg = self:RandomCfg(self.cfgs)
        -- 左起还是右起
        local start_direction = 1
        if not bool_leftorright then
            start_direction = -1
        end
        -- 位置偏移
        local posOffset = cfg.offset or vec2()
        -- 旋转角度随机范围
        local rotationRange = cfg.rotation or {-180, 180}
        -- 抛起高度随机范围
        local yRange = {150,200}
        -- 抛起宽度
        local xRange = 900
        -- 速度
        local speed = cfg.speed or 180
        -- 掉落距离
        local dropValue = cfg.dropValue or 0
        -- 随机大小范围
        local scale_ = 0.75 + (0.85 - 0.75) * math.random()

        local coin = self:Fetch(cfg.url)
        coin.rotation = randomRange(rotationRange)
        coin.xy = vec2()
        coin.scale = vec2(scale_,scale_)

        local deltaX     = xRange * start_direction
        local jumpHeight = -randomRange(yRange)
        -- 抛起耗时
        local time_   = (math.abs(jumpHeight) + math.abs(dropValue)) / speed

        table.insert(self.activeObjects, coin)
        -- 模拟抛飞线
        local updateLogic = function(t)
            local frac = t
            local y    = jumpHeight * 4 * frac * (1 - frac)
            coin.xy = vec2(posOffset.x + deltaX * t, posOffset.y + y)
        end

        -- 模拟抛物线
        FairyGUI.GTween.ToDouble(0, 1, time_)
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

    self.tween = FTween.Start(self.rootNode,FTween.RepeatForever({
            FTween.Delay(self.interval, doPlay),
        })
    )
end

function CoinFlyAnim:Stop()
    if self.tween then
        self.tween.Kill()
        self.tween = nil
    end
end

--------------------------------------------------- private ---------------------------------------------------
function CoinFlyAnim:RandomCfg(cfg)
    if #cfg == 1 then
        return cfg[1]
    end

    -- 根据权重随机
    local totalWidget = 0
    for _, v in pairs(cfg) do
        if not v.widget then v.widget = 1 end

        -- 起始值
        v.startWidget = totalWidget

        totalWidget = totalWidget + v.widget

        -- 结束值
        v.endWidget = totalWidget
    end

    local rand = math.random(1, totalWidget)
    for _, v in pairs(cfg) do
        if v.widget > 0 and rand >= v.startWidget and rand <= v.endWidget then
            return v
        end
    end
    assert(false)
end

function CoinFlyAnim:Fetch(url)
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

function CoinFlyAnim:Put(obj, url)
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

function CoinFlyAnim:Clear()
    for _, pool in pairs(self.objectPool) do
        for __, obj in pairs(pool) do
            FTween.KillTweens(obj)
            obj:RemoveFromParent(true)
        end
    end
    self.objectPool = {}
end

return CoinFlyAnim