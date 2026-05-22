local BigWinCoin = Class("BigWinCoin")
function BigWinCoin:ctor(render)    
    self.render = render
end

function BigWinCoin:__delete()
    self:Stop()
end

function BigWinCoin:PlayOnceAnim()
    local cell = self:_create(self.render)
    local endPos = self:RandomXY(vec2(self.render.width*0.5,self.render.height*0.5))
    FTween.Start(cell,
        FTween.Parallel({
            FTween.To(FairyGUI.TweenPropType.Scale, vec2(0.4,0.4), vec2(0.8,0.8), 1.2),
            FTween.To(FairyGUI.TweenPropType.Position, vec2(self.render.width*0.5,self.render.height*0.5), endPos, 1.2),
            FTween.To(FairyGUI.TweenPropType.Alpha, 0, 1, 1.2),
        }),
        FTween.RemoveSelf()
    )
end

function BigWinCoin:_create(parent)
    local obj = FairyGUI.UIPackage.CreateObjectFromURL("ui://Game483/coinAnim")
    parent:AddChild(obj)
    obj:SetPivot(0.5, 0.5, true)
    obj.sortingOrder = 1
    obj.scale = vec2(0.8,0.8)
    obj.rotation = math.random(0,360)
    obj.xy = vec2(10000,10000)
    return obj
end

function BigWinCoin:Play()
    self.tweenr = FTween.Start(self.render,
        FTween.RepeatForever(
            {
                FTween.Delay(0.02, function()
                    for i = 1, 3, 1 do
                        self:PlayOnceAnim()
                    end
                end)
            }
        )
    )
end

function BigWinCoin:Stop()
    if self.tweenr then
        self.tweenr.Kill(false)
        self.tweenr = nil
    end
end
function BigWinCoin:RandomXY(center)
    local r = 750
    local a0 = math.random(0,360)
    local x = center.x + r * math.cos(a0*3.14/180) 
    local y = center.y + r * math.sin(a0*3.14/180) 
    return vec2(x,y)
end

return BigWinCoin