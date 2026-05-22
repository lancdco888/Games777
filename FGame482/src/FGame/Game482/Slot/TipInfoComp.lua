local TipInfoComp = Class("TipInfoComp")
local Utils = Import(".Utils")

function TipInfoComp:ctor(render)

    self.render = render

    self.winLabel = render:GetChild("label-score")
    self.winLabelInMulti = render:GetChild("label-score-in-multi")

    self.tipOrderNum = 1
end

function TipInfoComp:AddScrollTipScoreViewTo(score,duration)
    local addScore = tonumber(Utils.ConvertScoreToRealVisual(score))
    local curViewScore = tonumber(self.winLabel.text) 
    local toScore = curViewScore + addScore
    self.scoreTween = Utils.TweenNumber(curViewScore,toScore,duration,nil,function(updatingScore)
        self:SetTipScoreView(math.floor(updatingScore))
    end,nil)
end

function TipInfoComp:SetTipScoreView(score)
    self.winLabel.text = tostring(score)
    self.winLabelInMulti.text = tostring(score)
end

function TipInfoComp:SwitchController(isTip)
    local controller = self.render:GetController("c1")
    if isTip then
        controller.selectedPage = "tip"
        self:SetTipScoreView(0)
    else
        controller.selectedPage = "score"
    end
end


function TipInfoComp:RandomNormalSpinTipAndAni()

    local tipsTransitionNames = {"random-tip-1", "random-tip-2", "random-tip-3", "random-tip-4"}

    local index = self.tipOrderNum
    local tipName = tipsTransitionNames[index]
    self.tipTransition = self.render:GetTransition(tipName):Play(function()
        self:RandomNormalSpinTipAndAni()
    end)

    self.tipOrderNum = self.tipOrderNum + 1
    if self.tipOrderNum > 4 then
        self.tipOrderNum = 1
    end

end


return TipInfoComp