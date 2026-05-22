local BigWin = Class("BigWin")
local GameDefine = Import("..GameDefine")
local MusicCfg = Import(".MusicCfg")
local Utils = Import(".Utils")
local BigWinCoin = Import(".BigWinCoin")
function BigWin:ctor(render,game)
    self.render = render
    self.render.visible = false
    self.game = game
    self:InitUI()
end

function BigWin:__delete()
    if self.tweener then
        self.tweener:Kill(false)
        self.tweener = nil
    end
    FTween.KillTweens(self.render)
    self.render = nil
    self.onScrollEndCallback = nil
    self.game = nil
    APIGateway.StopParticleEffect(self.bw3dp)
    -- self:StopBgm()
    self.bigWinCoin:Delete()
end

function BigWin:InitUI()
    self.win = self.render:GetChild("win")

    self.stopBtn = self.render:GetChild("stopBtn")
    self.stopBtn:AddEventListener(FGUIEventKey.onClick, function()
        self.stopBtn.visible = false
        self:OnComplete(true)
    end)
    self.stopBtn.visible = false
    self.bigWinCoin = BigWinCoin.New(self.render:GetChild("coin"))
    self.particle = self.render:GetChild("particle")
    self.bw3dp = APIGateway.PlayParticleEffect("Game483/particle/483_bigwin3d",self.particle)

end

function BigWin:ResetState()
    self.win.text = ""
    self.up2Playing = false
    self.up3Playing = false
end


function BigWin:Show(number,callback)
    self.onScrollEndCallback = callback
    self:ResetState()
    self.bgm = FToolSet.PlayFGUISound(MusicCfg.bigwin,true)
    self.render.visible = true
    self.bigWinCoin:Play()
    self.particle.visible =true
    APIGateway.ReplayParticleEffect(self.bw3dp)
    self.render:GetTransition("show1"):Play()
    Utils.Delay(self.render,0.5,function ()
        self.stopBtn.visible = true
        self:Start(number)
    end)
end

function BigWin:Start(number)
    self.winNum = number
    self.level = 1
    local betMoney = FCasinoCtx.commonPanel:GetBetMoney()
    local ratio = number / betMoney 
    local time = 0
    local targetNum = 0
    if ratio <= 65 then
        time = ratio / GameDefine.BigWinNormalSpeed
        targetNum = self.winNum
    else
        time = 50 / GameDefine.BigWinNormalSpeed
        targetNum = betMoney*50
    end
    self:StartScrollTweener(0,targetNum,time,FairyGUI.EaseType.Custom,function ()
        if ratio > 65 then
            local time2 = GameDefine.BigWinTotalTime - time
            local targetNum2 = self.winNum
            self:StartScrollTweener(targetNum,targetNum2,time2,FairyGUI.EaseType.SineIn,function ()
                self:OnComplete()
            end)
        else
            self:OnComplete()
        end
    end)
end

function BigWin:StartScrollTweener(startNum,endNum,time,easeType,callback)
    local isConvertInteger = (FToolSet.GetDecimalPlaces(FToolSet.NumToStr(startNum)) == 0) and (FToolSet.GetDecimalPlaces(FToolSet.NumToStr(endNum)) == 0) 
    self.tweener = FairyGUI.GTween.ToDouble(startNum, endNum, time)
    :OnUpdate(function(tweener)
        self.win.text = Utils.DelectDot(tweener.value.d, isConvertInteger)
        self:CheckUpLevel(tweener.value.d)
    end)
    :OnComplete(function()
        if callback then
            callback()
        end
    end)
    :SetEase(easeType)
end

function BigWin:OnComplete(quickSet)
    self.stopBtn.visible = false
    local isConvertInteger = FToolSet.GetDecimalPlaces(FToolSet.NumToStr(self.winNum)) == 0
    self.win.text = Utils.DelectDot(self.winNum,isConvertInteger) 
    if self.tweener then
        self.tweener:Kill(false)
        self.tweener = nil
    end
    if self.level == 1 then
        self.render:GetTransition("show1"):Stop()
    end
    if self.level == 2 then
        self.render:GetTransition("show2"):Stop()
    end
    self:CheckUpLevel(self.winNum,quickSet)
    self:StopBgm()
    self.bgm = FToolSet.PlayFGUISound(MusicCfg.bigwin_end)
    Utils.Delay(self.render,6,function ()
        self.bigWinCoin:Stop()
        self.particle.visible = false
        self:StopBgm()
        if self.onScrollEndCallback then
            self.onScrollEndCallback()
            self.onScrollEndCallback = nil
        end
    end)
end

function BigWin:CheckUpLevel(number,quickSet)
    local ratio = number / FCasinoCtx.commonPanel:GetBetMoney()
    if ratio >= GameDefine.MEGAWIN then
        if self.level == 1 then
            self.level = 2
            self:UpLevel(quickSet)
        end
    end
    if ratio >= GameDefine.SUPERMEGAWIN then
        if self.level == 2 then
            self.level = 3
            self:UpLevel(quickSet)
        end
    end
end

function BigWin:UpLevel(quickSet)
    if self.level == 2 then
        if quickSet and self.up2Playing then
            self.render:GetTransition("show2"):Stop()
            return
        end
        self.render:GetTransition("show2"):Play()
        self.up2Playing = true
    elseif self.level == 3 then
    
        if quickSet and self.up3Playing then
            self.render:GetTransition("show3"):Stop()
      
            return
        end
        self.render:GetTransition("show3"):Play()
        self.up3Playing = true
    end
end

function BigWin:StopBgm()
    if self.bgm then
        APIGateway.StopSound(self.bgm)
        self.bgm = nil
    end
end
return BigWin