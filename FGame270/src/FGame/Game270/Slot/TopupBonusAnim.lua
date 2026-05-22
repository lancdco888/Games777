local cls = Class("TopupBonusAnim")
local MusicCfg = Import(".MusicCfg")
function cls:ctor(render)
    self.render = render
    self.render.visible = false
    self:InitUI()
end

function cls:__delete()
    if self.timer1 then
        StopTimer(self.timer1)
        self.timer1 = nil
    end
    if self.timer2 then
        StopTimer(self.timer2)
        self.timer2 = nil
    end
    if self.timer3 then
        StopTimer(self.timer3)
        self.timer3 = nil
    end
    self.callback = nil
end

function cls:InitUI()
    self.CenterCorona = self.render:GetChild("CenterCorona")
    self.CenterCorona_bg = self.render:GetChild("CenterCorona_bg")
    self.n4 = self.render:GetChild("n4")
    self.n5 = self.render:GetChild("n5")
    self.c15 = self.render:GetChild("c15")
end

function cls:PlayTopupBonusAnim(cb)
    self.callback = cb
    FToolSet.PlayFGUISound(MusicCfg.SND_FeatureTrigger)
    self.render.visible = true
    self.render:GetTransition("animScale"):Play(function()
        if self.callback then
            self.callback()
            self.callback = nil
            self.render.visible = false
        end
    end)
    self.timer3 = StartOnceTimer(
            function()
                self.timer = nil
            end
    , 1)
end

return cls
