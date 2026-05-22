local SymbolDetails = Class("SymbolDetails")
local TipsConfig = Import(".TipsConfig")
local Utils = Import(".Utils")

function SymbolDetails:ctor(render)
    self.render = render
    self.render.visible = true
    self:InitUI()
end

function SymbolDetails:__delete()
    self:_runStop()
    self.cfg = nil
    self.onShowEndCallback = nil
end

function SymbolDetails:InitUI()
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
    
    -- self.wintext = self.render:GetChild("wintext")
    -- self.scrollNum = self.render:GetChild("scrollNum")
    -- ]
end

-- type: 1 = normal; 2 = free
function SymbolDetails:PlayTips(type)
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
function SymbolDetails:ShowFreeTimes(times)
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

function SymbolDetails:HideFreeTimes()
    self.freeTimes.visible = false
    self.rfs.visible = false
    self.lfs.visible = false
end
-- 循环提示
function SymbolDetails:_runTips(cfg)
    self.tipsMask.visible = true
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

function SymbolDetails:_runStart()
    if not self.cfg then
        return
    end
    self.playIndex = self.playIndex + 1
    if self.playIndex > #self.cfg then
        self.playIndex = 1
    end
    self:_runTips(self.cfg[self.playIndex])
end

function SymbolDetails:_runStop()
    self.tipsText.x = self.tipsTextX
    FTween.KillTweens(self.tipsText)
end
return SymbolDetails