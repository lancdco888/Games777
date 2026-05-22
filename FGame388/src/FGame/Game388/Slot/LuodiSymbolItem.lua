local Tools = Import(".Tools")

local LuodiSymbolItem = Class("LuodiSymbolItem")


function LuodiSymbolItem:ctor(render)
    self.render = render

    self.sprBg = render:GetChild("bg")
    self.sprLight = render:GetChild("light")
    self.labelVal = render:GetChild("valLabel")

    self.sprMini = render:GetChild("mini")
    self.sprMinor = render:GetChild("minor")
    self.sprMaxi = render:GetChild("maxi")
    self.sprMajor = render:GetChild("major")
    self.sprGrand = render:GetChild("grand")

    self.sprLight.visible = false
    self.labelVal.visible = false
    
    self.sprMini.visible = false
    self.sprMinor.visible = false
    self.sprMaxi.visible = false
    self.sprMajor.visible = false
    self.sprGrand.visible = false
    
    self.uiJackpotRewards = {
        [1] = self.sprMini,
        [2] = self.sprMinor,
        [3] = self.sprMaxi,
        [4] = self.sprMajor,
        [5] = self.sprGrand
    }
end

function LuodiSymbolItem:showJackPot(jackType, shouldShowLight)
    if shouldShowLight == nil then shouldShowLight = true end
    self.shouldShowLight = shouldShowLight
    
    for _type, jackpotSpr in ipairs(self.uiJackpotRewards) do
        if _type == jackType then jackpotSpr.visible = true end
    end
    
    self:showEndAni()
end

LuodiSymbolItem.luodiScale = { 1, 1, 1, 0.74, 0.7, 0.6 }
function LuodiSymbolItem:showNormal(val, shouldShowLight)
    if shouldShowLight == nil then shouldShowLight = true end
    self.shouldShowLight = shouldShowLight
    if val then
        local showTextStr = Tools.TopupBounsScoreToStr(val)
        local strLen = #showTextStr
        local scale = self.luodiScale[strLen] or 0.6
        self.labelVal.scaleX = scale 
        self.labelVal.scaleY = scale
        self.labelVal.text = showTextStr
    else
        print("LuodiSymbolItem:showNormal>>>>>>>>>>val>>>>nil")
    end
    self.labelVal.visible = true
    self:showEndAni()
end

function LuodiSymbolItem:showEndAni()
    if self.shouldShowLight then self.sprLight.visible = true end
end

function LuodiSymbolItem:__delete()
end

return LuodiSymbolItem