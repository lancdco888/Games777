local BezierAction = {}

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

local function forAngle(a)
    return {x = math.cos(a), y = math.sin(a)}
end

BezierAction.createBezierCurve = createBezierCurve
BezierAction.forAngle = forAngle


function BezierAction.BezierTo(target, duration, bezierConfig, callback)
    local P0, P1, P2 = bezierConfig[1], bezierConfig[2], bezierConfig[3]
    local curve = createBezierCurve(P0, P1, P2)
    
    target.x, target.y = P0.x, P0.y

    local tweener = FairyGUI.GTween.ToDouble(0, 1, duration)
    :OnUpdate(function(tweener)
        target.x, target.y = curve(tweener.value.d)
    end)
    :OnComplete(function()
        target.x, target.y = P2.x, P2.y

        if callback then
            callback()
        end
    end)
    :SetTarget(target)

    return tweener
end

-- @brief 格子里面的图标飞行到格子顶部中间
function BezierAction.ReelSymbolFlyToToCenter(target, customConfig, callback)
    local toPos = customConfig.toPos
    local duration = customConfig.duration
    
    -- 如果没有设置duration,则根据飞行速度计算duration
    if duration == nil and customConfig.speed then
        local distance = math.sqrt((toPos.x - target.x) ^ 2 + (toPos.y - target.y) ^ 2)
        duration = distance / customConfig.speed

        if type(customConfig.minDuration) == "number" then
            duration = math.max(duration, customConfig.minDuration)
        end
    end

    print("duration", duration)

    local P0 = vec2(target.x, target.y)
    local P1 = vec2(0, 0)
    local P2 = vec2(toPos.x, toPos.y)

    -- 自定义配置里面有横向偏移量和竖向偏移量,默认0
    local offsetX = customConfig.offsetX or 0
    local offsetY = customConfig.offsetY or 0

    -- 
    local angle = 0
    -- 根据飞行方向确定随机角度象限
    if P2.x - P0.x > 0 then
        if P2.y - P0.y > 0 then
            -- 左下象限
            angle = math.random(180, 225) * math.pi / 180
        else
            -- 左上象限
            angle = math.random(135, 180) * math.pi / 180
        end
    else
        if P2.y - P0.y > 0 then
            -- 右下象限
            angle = math.random(315, 360) * math.pi / 180
        else
            -- 右上象限
            angle = math.random(0, 45) * math.pi / 180
        end
    end

    local de = forAngle(angle)
    P1.x = P0.x + de.x * offsetX
    P1.y = P0.y + de.y * offsetY

    local tweener = BezierAction.BezierTo(target, duration, {P0, P1, P2}, callback)

    if customConfig.easeType then
        tweener:SetEase(customConfig.easeType)
    end

    return tweener
end

return BezierAction