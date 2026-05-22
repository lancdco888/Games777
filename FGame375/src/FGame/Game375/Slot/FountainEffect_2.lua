-- 喷泉特效

local FountainEffect_2 = Class("FountainEffect_2")

FountainEffect_2.Anims = {
    "ui://Game375/coin_yanhua"
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

local function randomRange(range)
    local min = range[1]
    local max = range[2]
    if min > max then
        min, max = max, min
    end
    return math.random(math.floor(min), math.floor(max))
end

function FountainEffect_2:ctor(parent,posx)
    -- 金币根节点
    self.rootNode = FairyGUI.GComponent()
    self.rootNode.xy =  vec2(parent.width * 0.5 + posx, parent.height)
    parent:AddChild(self.rootNode)
    
    self.objectPool = {}
    self.activeCount = 0
    self.activeObjects = {}

    -- 动画间隔
    self.interval = 1/60
end

function FountainEffect_2:__delete()
    self:Stop()
    for _, object in pairs(self.activeObjects) do
        FTween.KillTweens(object, nil, false)
    end
    self:Clear()
    self.rootNode:RemoveFromParent(true)
end

function FountainEffect_2:SetSortingOrder(value)
    self.rootNode.sortingOrder = value
end

function FountainEffect_2:Play(allnumber)
    self:Stop()
    local function doPlay()
        self.activeCount = self.activeCount + 1

        -- 旋转角度随机范围
        local rotationRange = {-180, 180}
        -- 抛起高度随机范围
        local yRange = {100, 250}
        -- 抛起宽度随机范围
        local xRange = {0, 500}
        -- 速度
        local speed = 250
        -- 掉落距离
        local dropValue = randomRange({100,20})
        --起始点偏移
        local start_Offset = randomRange({-50,50})

        local coin = self:Fetch(self.Anims[1])
        coin.rotation = randomRange(rotationRange)
        coin.xy = vec2(start_Offset,0)
        
        local deltaX     = randomRange(xRange)
        local jumpHeight = -randomRange(yRange)
        local duration   = math.abs(jumpHeight) / speed

        if math.random(1,100)  <= 50 then 
            deltaX = -deltaX
        end

        table.insert(self.activeObjects, coin)

        -- 抛物线动画
        deltaX = deltaX / 2
        jumpHeight = jumpHeight * 2
        local P0 = vec2(start_Offset,0)
        local P2 = vec2(deltaX, dropValue)
        local P1 = vec2(deltaX / 2, jumpHeight)
        local curve = createBezierCurve(P0, P1, P2)
        local updateLogic = function(t)
            local x, y = curve(t)
            coin.xy = vec2(x, y)
        end

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

            self:Put(coin, self.Anims[1])
            self.activeCount = self.activeCount - 1
            if self.activeCount <= 0 then
                self:Clear()
            end
        end)
        :SetTarget(coin)
        :SetEase(FairyGUI.EaseType.QuadOut)
    end
    local number = 0
    self.runningTween = FTween.Start(self.rootNode,FTween.RepeatForever({
        FTween.Delay(self.interval, function()
            if number < allnumber then
                for i = 1, 5 do
                    number = number + 1
                    doPlay()
                end
                
            else
                self:Stop()
            end
        end),
    }))
end

function FountainEffect_2:Stop()
    if self.runningTween then
        self.runningTween.Kill()
        self.runningTween = nil
    end
end

--------------------------------------------------- private ---------------------------------------------------

function FountainEffect_2:Fetch(url)
    if not self.objectPool[url] then self.objectPool[url] = {} end

    local obj = nil
    if #self.objectPool[url] > 0 then
        obj = table.remove(self.objectPool[url])
        obj.visible = true
        obj.playing = true
        return obj        
    end

    obj = FairyGUI.UIPackage.CreateObjectFromURL(url)
    obj.pivot = vec2(0.5,0.5)
    obj.scale = vec2(0.5,0.5)
    obj.pivotAsAnchor = true
    self.rootNode:AddChild(obj)
    
    local item = FairyGUI.UIPackage.GetItemByURL(url)
    -- 开始帧动画播放
    if item.type == FairyGUI.PackageItemType.MovieClip then
        obj:SetPlaySettings()
    end

    return obj
end

function FountainEffect_2:Put(obj, url)
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

function FountainEffect_2:Clear()
    for _, pool in pairs(self.objectPool) do
        for __, obj in pairs(pool) do
            FTween.KillTweens(obj)
            obj:RemoveFromParent(true)
        end
    end
    self.objectPool = {}
end

return FountainEffect_2
