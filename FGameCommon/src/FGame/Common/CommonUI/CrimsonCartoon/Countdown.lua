-- 倒计时提示界面

local Countdown = Class("Countdown")

function Countdown:ctor()
    self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "Countdown")
    self.render:MakeFullScreen()
    GetFairyRoot():AddChild(self.render)
    
    self.render:AddEventListener(FGUIEventKey.onClick, handler(self, self.OnClickClose))

    local fmt = APIGateway.GetLangText("fgame_4")
    local count = 60

    local function updateText()
        local s = string.format("%d", count)
        self.render.text = string.format(fmt, s)

        count = math.max(count - 1, 0)        
        if count <= 0 then
            FCasinoCtx:GetGame():DoExitGame()
        end
    end
    self.timer = StartTimer(updateText, 1)
    updateText()
end

function Countdown:__delete()
    if self.timer then
        StopTimer(self.timer)
        self.timer = nil
    end
    self.render:RemoveFromParent(true)
end

function Countdown:OnClickClose()
    self:Close()
end

-- @brief 关闭弹窗
function Countdown:Close()
    if self.bPlayClose then return end
    self.bPlayClose = true
    self.render:GetTransition("fadeout"):Play(self.onDestroyCallback)
end

function Countdown:SetDestroyCallback(cb)
    self.onDestroyCallback = cb
end

return Countdown
