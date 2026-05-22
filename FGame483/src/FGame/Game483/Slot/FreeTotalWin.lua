local FreeTotalWin = Class("FreeTotalWin")
local Utils = Import(".Utils")
local FountainPool      = require("FGame.Common.Logic.Effect.FountainPool")
local MusicCfg = Import(".MusicCfg")
function FreeTotalWin:ctor(render)
    self.render = render
    self.render.visible = false
    self:InitUI() 

end

function FreeTotalWin:__delete()
    self.fountainPool:Delete()
    if self.tweener then
        self.tweener:Kill(false)
        self.tweener = nil
    end
    APIGateway.StopParticleEffect(self.fsw)
    self.onClickFunc = nil
    self.render = nil
    self:StopBGM()
end

function FreeTotalWin:InitUI()
    local collectBtn = self.render:GetChild("collectBtn")
    collectBtn:AddEventListener(FGUIEventKey.onClick, function()
        self:OnClick()
    end)
    self.win = self.render:GetChild("win")

    local stopBtn = self.render:GetChild("stopBtn")
    stopBtn:AddEventListener(FGUIEventKey.onClick, function()
        self:OnRunNumberComplete()
    end)

    self.particle = self.render:GetChild("particle")
    self.fsw = APIGateway.PlayParticleEffect("Game483/particle/483_freegame_backdd",self.particle)

    self.fountainPool = FountainPool.New(self.render:GetChild("coin"))
end

function FreeTotalWin:OnClick()
    print("FreeTotalWin:OnClick ")
    FToolSet.PlayFGUISound(MusicCfg.free_collect)
    self.render:GetTransition("click"):Play(function ()
        self.particle.visible = false
        self.fountainPool:Stop()
        self:StopBGM()
        if self.onClickFunc then
            self.onClickFunc()
            self.onClickFunc = nil
        end
    end)
end

function FreeTotalWin:Play(win,callback)
    self:PlayBGM()
    self.onClickFunc = callback
    self.win.text = ""
    self.winNum = win
    self.render.visible = true
    self.particle.visible = true
    APIGateway.ReplayParticleEffect(self.fsw)
    self.fountainPool:Play({
        -- 普通金币
        {
            url = "ui://Game483/coinAnim",
            widget = 95,            -- 权重
            rotation = {-180, 180}, -- 旋转角度随机范围
            height = {500, 800},    -- 抛起高度范围
            width = {400, 700},     -- 抛起范围
            speed = 250,            -- 速度
            scale = {0.8, 0.8},
        },
    })
    print("FreeTotalWin:Play ")
    self.render:GetTransition("play"):Play(function () 
        self:RunNumber()
        self.runNumberCallback = function()
            self.render:GetTransition("btnShow"):Play(function ()
                Utils.Delay(self.render,2,function ()
                    self:OnClick()
                end)
            end)
        end
    end)
end

function FreeTotalWin:RunNumber()
    local isConvertInteger = FToolSet.GetDecimalPlaces(FToolSet.NumToStr(self.winNum)) == 0
    self.tweener = FairyGUI.GTween.ToDouble(0, self.winNum, 5)
    :OnUpdate(function(tweener)
        self.win.text = Utils.DelectDot(tweener.value.d,isConvertInteger)
    end)
    :OnComplete(function()
       self:OnRunNumberComplete()
    end)
end

function FreeTotalWin:OnRunNumberComplete()
    if self.tweener then
        self.tweener:Kill(false)
        self.tweener = nil
    end
    local isConvertInteger = FToolSet.GetDecimalPlaces(FToolSet.NumToStr(self.winNum)) == 0
    self.win.text = Utils.DelectDot(self.winNum,isConvertInteger)
    if self.runNumberCallback then
        self.runNumberCallback()
        self.runNumberCallback = nil
    end
end

function FreeTotalWin:PlayBGM()
    self.bgm = FToolSet.PlayFGUISound(MusicCfg.free_end,true)
end

function FreeTotalWin:StopBGM()
    if self.bgm then
        APIGateway.StopSound(self.bgm)
        self.bgm = nil
    end
end

return FreeTotalWin