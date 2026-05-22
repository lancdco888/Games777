local BezierAction = Class("BezierAction")

local math_pow = math.pow

function BezierAction:ctor()
    self.t = nil
    self.P0,self.P1,self.P2 = vec2(),vec2(),vec2()
end

function BezierAction:__delete()
    if self.t then
        self.t:Kill()
    end
    self.t = nil
end

function BezierAction:udpate(t)
    local x = math_pow(1 - t, 2) * self.P0.x + 2 * (1 - t) * t * self.P1.x + math_pow(t, 2) * self.P2.x
    local y = math_pow(1 - t, 2) * self.P0.y + 2 * (1 - t) * t * self.P1.y + math_pow(t, 2) * self.P2.y
    return x, y
end

function BezierAction:create(target,duration, P1, P2)
    local oldPos = target.xy
    self.P1 = vec2(P1.x - oldPos.x,P1.y - oldPos.y)
    self.P2 = vec2(P2.x - oldPos.x,P2.y - oldPos.y)
    -- 模拟抛物线
    self.t = FairyGUI.GTween.ToDouble(0, 1, duration)
    :OnUpdate(function(tweener)
        local offset = self:udpate(tweener.value.d)
        target.x = oldPos.x + offset.x
        target.y = oldPos.y + offset.y
    end)
    :OnComplete(function()
        target.x = self.P2.x
        target.y = self.P2.y
        self.t = nil
    end)
    :SetTarget(target)
    :SetEase(FairyGUI.EaseType.SineOut)
end

return BezierAction

