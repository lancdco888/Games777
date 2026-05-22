local FreeLoading = Class("FreeLoading")
local Utils = Import(".Utils")
local MusicCfg = Import(".MusicCfg")
function FreeLoading:ctor(render)
    self.render = render
    self.render.visible = false
    self:InitUI() 

end

function FreeLoading:__delete()
    self.onClickFunc = nil
    self.render = nil
end

function FreeLoading:InitUI()
    local startBtn = self.render:GetChild("startBtn")
    startBtn:AddEventListener(FGUIEventKey.onClick, function()
        self:OnClick()
    end)
    self.times = self.render:GetChild("times")
end

function FreeLoading:OnClick()
    FToolSet.PlayFGUISound(MusicCfg.free_start)
    self.render:GetTransition("click"):Play(function ()
        if self.onClickFunc then
            self.onClickFunc()
            self.onClickFunc = nil
        end
    end)
end

function FreeLoading:StartLoading(freeTimes,callback)
    FToolSet.PlayFGUISound(MusicCfg.free_loading)
    self.onClickFunc = callback
    self.times.text = freeTimes
    self.render.visible = true
    self.render:GetTransition("play"):Play(function ()
        Utils.Delay(self.render,2,function ()
            self:OnClick()
        end)
    end)
    self.render:GetTransition("play2"):Play()
end

return FreeLoading