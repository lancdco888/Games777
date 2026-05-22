local Tips = Class("Tips")
local TipsConfig = Import(".TipsConfig")
local Utils = Import(".Utils")

function Tips:ctor(render)
    self.render = render
    self.render.visible = true
    self:InitUI()
    self:HideWin()
end

function Tips:__delete()
    self:_runStop()
    self.cfg = nil
    self.onShowEndCallback = nil
    APIGateway.StopParticleEffect(self.fssps)
end

function Tips:InitUI()
    self.tipsMask = self.render:GetChild("tipsMask")
    self.needScrollWidth = self.tipsMask.width
    self.tipsText = self.tipsMask:GetChild("tipsText")
    self.tipsTextX = self.tipsText.x

    self.rfs = self.render:GetChild("rfs")
    self.rfs.visible = false
    self.lfs = self.render:GetChild("lfs")
    self.lfs.visible = false
    self.freeTimes = self.render:GetChild("freeTimes")
    self.freeTimes.visible = false
    
    self.wintext = self.render:GetChild("wintext")
    self.win = self.wintext:GetChild("win")
    self.twin = self.wintext:GetChild("twin")
    -- self.scrollNum = self.render:GetChild("scrollNum")
    -- ]
    self.particle = self.render:GetChild("483_freespinswondd_small")
    self.fssps = APIGateway.PlayParticleEffect("Game483/particle/483_freespinswondd_small",self.particle)
    self.freeTimesAddBg = self.render:GetChild("freeTimesAddBg")
    self.change = self.render:GetChild("change")
    
end

-- type: 1 = normal; 2 = free
function Tips:PlayTips(type)
    if self.type == type then
        return
    end
    self:_runStop()
    self.cfg = nil
    if type == 1 then
        self.cfg = TipsConfig.NormalTips
    elseif type == 2 then
        self.cfg = TipsConfig.FreeTips
    end
    if self.cfg then
        self.playIndex = 0
        self:_runStart()
    end
    self.type = type
end

--times : 0 显示last time
function Tips:ShowFreeTimes(times)
    if not times then
        return
    end
    if times == 0 then
        self.rfs.visible = false
        self.lfs.visible = true
        self.freeTimes.visible = false
    else
        self.rfs.visible = true
        self.lfs.visible = false
        self.freeTimes.visible = true
    end
    self.freeTimes.text = times
end

function Tips:HideFreeTimes()
    self.freeTimes.visible = false
    self.rfs.visible = false
    self.lfs.visible = false
end

function Tips:ShowWin(isTotal,num,callback)
    local isConvertInteger = FToolSet.GetDecimalPlaces(FToolSet.NumToStr(num)) == 0
    self.wintext.text = Utils.DelectDot(num,isConvertInteger)
    if isTotal then
        self.twin.visible = true
        self.win.visible = false
    else
        self.twin.visible = false
        self.win.visible = true
    end
    local ratio = num / FCasinoCtx.commonPanel:GetBetMoney()
    local transAnimName = "win1"
    if ratio > 10 then
        transAnimName = "win3"
    elseif ratio > 5 then
        transAnimName = "win2"
    end
    self.render:GetTransition(transAnimName):Play(function ()
        if callback then
            callback()
        end
    end)
end

function Tips:HideWin()
    self.render:GetTransition("toText"):Play()
end

-- 循环提示
function Tips:_runTips(cfg)
    self.tipsText.url = cfg.url
    if self.tipsText.width * self.tipsText.scale.x > (self.needScrollWidth - 20) then
        self.tipsText.x = self.tipsTextX
        FTween.Start(self.tipsText,
            FTween.Delay(2, function() end),
            FTween.To(FairyGUI.TweenPropType.X, self.tipsTextX, self.tipsTextX - self.tipsText.width * self.tipsText.scale.x - 50, 10),
            FTween.CallFunc(function()
                self:_runStart()
            end)
        )
    else
        self.tipsText.x = self.tipsMask.width/2 - self.tipsText.width * self.tipsText.scale.x/2
        Utils.Delay(self.tipsText,5,function ()
            self:_runStart()
        end)
    end
end

function Tips:_runStart()
    if not self.cfg then
        return
    end
    self.playIndex = self.playIndex + 1
    if self.playIndex > #self.cfg then
        self.playIndex = 1
    end
    self:_runTips(self.cfg[self.playIndex])
end

function Tips:_runStop()
    self.tipsText.x = self.tipsTextX
    FTween.KillTweens(self.tipsText)
end

function Tips:WonFreeTimes(startTimes,endTimes)
    local temp = endTimes - startTimes
    self.particle.visible = true
    self.freeTimesAddBg.visible = true
    self.change.visible = true
    APIGateway.ReplayParticleEffect(self.fssps)

    self.tween = FTween.Start(self.render,
        FTween.Repeat({
            FTween.Delay(0.05, function()
            end),
            FTween.CallFunc(function()  
                if startTimes >= endTimes then
                    return
                end
                startTimes = startTimes + 1
                if startTimes == 1 then
                    self:ShowFreeTimes(1)
                else
                    self.freeTimes.text = startTimes
                end
                self.change.alpha = 1
            end),
            FTween.Delay(0.05, function()
                self.change.alpha = 0.5
            end),
        }, temp)
    )
end
function Tips:HideWon()
    self.particle.visible = false
    self.freeTimesAddBg.visible = false
    self.change.visible = false
    self.change.alpha = 1
end
return Tips