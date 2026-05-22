local BigWin = Class("BigWin")
local Utils = Import(".Utils")
local GameDefine = Import("..GameDefine")
local FountainPool = require("FGame.Common.Logic.Effect.FountainPool")

function BigWin:ctor(game)
    self.game = game
    self.render = FairyGUI.UIPackage.CreateObject("Game482", "BigWin")
    self.scoreLabel = self.render:GetChild("score-label")
    Utils.AddToTopEffectLayerAndMakeFullScreen(self.render)
    self.render.visible = false

    self.coinBg_1 = self.render:GetChild("coinbg-1")
    self.coinBg_2 = self.render:GetChild("coinbg-2")

    self.transitionBaseNames = {
        "nicewin",
        "megawin",
        "superbwin",
        "sensationalwin"
    }

    self.coinFountain1 = FountainPool.New(self.coinBg_1)
    self.coinFountain2 = FountainPool.New(self.coinBg_2)
end

function BigWin:__delete()
    self.coinFountain1:Delete()
    self.coinFountain2:Delete()
end


function BigWin:OnComplete(curTransitionName,bigWinAudioName)

    --清理所有
    if self.currentTween then
        self.currentTween:Kill()
        self.currentTween = nil
    end
        
        
    Utils.PlaySound("ui://Game482/"..bigWinAudioName.."_end")
    self.coinFountain1:Stop()
    self.coinFountain2:Stop()
    Utils.SetTimeout(function()
        self.coinBg_1.visible = false
        self.coinBg_2.visible = false
        self.scoreLabel.text = ""
        -- Utils.PlaySound("ui://Game482/bgm_bigwin_end")
        self.render:GetTransition(curTransitionName.."-out"):Play(function()
            Utils.StopSound(self.scoreSoundHandler)

            self.render.visible = false
            print("BigWin:OnComplete >>> " .. curTransitionName.. "-out >>> Complete")
            Utils.SetTimeout(function() 
                print("BigWin:OnComplete >>> Utils.SetTimeout >>> Complete")
                if self.callback then
                    self.callback()
                end
            end,2,self.render)


        end)
    end,2)

    self.scoreLabel.text = FToolSet.NumToStr(self.curWinCoin)

end


function BigWin:PlayScoreAnim(curWinCoin, callback)
    self.scoreLabel.text = ""
    self.render.visible = true
    self.callback = callback
    local winRate = curWinCoin / FCasinoCtx.commonPanel:GetBetMoney()
    self.curWinCoin = curWinCoin

    
    local playAnimRates = GameDefine.PlayAnimRates
    local maxRateIdx = 1
    for i = 1, #playAnimRates do
        if winRate >= playAnimRates[i] then
            maxRateIdx = i
        else
            break
        end
    end
    local curTransitionName = self.transitionBaseNames[maxRateIdx]
    self.render:GetTransition(curTransitionName.."-in"):Play(function()
            if maxRateIdx == 1 or maxRateIdx == 2 then
                self.coinBg_1.visible = true
                self.coinBg_2.visible = false
                self.coinFountain1:Play({
                    {
                        url = "ui://Game482/coin482",
                        height = {80, 100},
                        width = {100, 800},
                        dropValue = 400,
                        speed = 300,
                        scale = {.75, .75}
                    }
                })
            else
                self.coinBg_1.visible = false
                self.coinBg_2.visible = true
                self.coinFountain2:SetAnimationInterval(1/60)
                self.coinFountain2:Play({
                    {
                        url = "ui://Game482/coin482",
                        height = {10, 20},
                        width = {300, 1100},
                        dropValue = 900,
                        speed = 600,
                        scale = {.75, .75}
                    }
                })
            end
            Utils.PlaySound("ui://Game482/win_applause")
        local scorePlayDuration = math.ceil(winRate / 5)
        scorePlayDuration = math.min(scorePlayDuration, 60)
        -- 播放收分动画,收分音效
        local bigWinAudioNames = {
            "win_7",
            "win_8",
            "win_9",
            "win_10"
        }
        local bigWinAudioName = bigWinAudioNames[math.random(1,#bigWinAudioNames)]
        self.scoreSoundHandler = Utils.PlaySound("ui://Game482/"..bigWinAudioName,true)
        
        -- Start the tween and store the reference
        self.currentTween = Utils.TweenNumber(0, self.curWinCoin, scorePlayDuration, FTween.Linear,
            function(val)
                self.scoreLabel.text = FToolSet.NumToStr(val)
            end,
            function()
                self:OnComplete(curTransitionName,bigWinAudioName)
            end
        )

        self.hasClick = false
        Utils.AddClickEvent(self.render, function()
            if self.hasClick then return end
            self.hasClick = true
            self:OnComplete(curTransitionName,bigWinAudioName)
        end)
    end)

end


return BigWin