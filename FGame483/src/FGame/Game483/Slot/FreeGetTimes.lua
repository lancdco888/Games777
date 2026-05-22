local FreeGetTimes = Class("FreeGetTimes")
local GameDefine = Import("..GameDefine")
local MusicCfg = Import(".MusicCfg")
local Utils = Import(".Utils")
function FreeGetTimes:ctor(render)
    self.render = render
    self.render.visible = false
    self:InitUI()
    self.render.visible = false
end

function FreeGetTimes:__delete()
    if self.tweener then
        self.tweener:Kill(false)
        self.tweener = nil
    end
    FTween.KillTweens(self.render)
    self.render = nil
    APIGateway.StopParticleEffect(self.fssp)
end

function FreeGetTimes:InitUI()
    self.times = self.render:GetChild("times")
    self.particle = self.render:GetChild("483_freespinswondd")
    self.fssp = APIGateway.PlayParticleEffect("Game483/particle/483_freespinswondd",self.particle)
end



function FreeGetTimes:Show(number,callback)
    self.render.visible = true
    APIGateway.ReplayParticleEffect(self.fssp)
    -- FToolSet.PlayFGUISound(MusicCfg.vocals_mjhl)
    self.render:GetTransition("show"):Play()
    self.times.text = number
    Utils.Delay(self.render,2,function ()
        self.render.visible = false
        if callback then
            callback()
        end
    end)
end


return FreeGetTimes