-- 游戏规则界面

local MessageBox = Class("MessageBox")

function MessageBox:ctor(title, content, onConfirmCall, onCancelCall)
    self.onConfirmCall = onConfirmCall
    self.onCancelCall = onCancelCall
    if APIGateway.IsDeviceOrientationPortrai() then
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "MessageBox_V")
    else
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "MessageBox")
    end
    self.render:MakeFullScreen()
    GetFairyRoot():AddChild(self.render)
    
    self.render:GetTransition("open"):Play(function()
        self.bOpenFinish = true
    end)
    
    local frame = self.render:GetChild("frame")

    frame:GetChild("text_title").text = title
    frame:GetChild("text_content").text = content

    local btn_cancel = frame:GetChild("btn_cancel")
    local btn_confirm = frame:GetChild("btn_confirm")
    
    btn_cancel:GetChild("icon").color  = FTheme.curThemCfg.textColor
    btn_confirm:GetChild("icon").color = FTheme.curThemCfg.textColor
    btn_cancel.text = APIGateway.GetLangText("fgame_crimson_cartoon_title_13")
    btn_confirm.text = APIGateway.GetLangText("fgame_crimson_cartoon_title_14")

    FToolSet.AddClickListener(btn_cancel, handler(self, self.OnClickCancel), false)
    FToolSet.AddClickListener(btn_confirm, handler(self, self.OnClickConfirm), false)
end

function MessageBox:__delete()
    self.render:RemoveFromParent(true)
end

function MessageBox:OnClickCancel()
    self.onConfirmCall = nil
    self:Close(true)
end

function MessageBox:OnClickConfirm()
    self.onCancelCall = nil
    self:Close(true)
end

-- @brief 
function MessageBox:Close(dispatchCallback)
    if not self.bOpenFinish then return end
    if self.bPlayClose then return end
    self.bPlayClose = true
    self.render:GetTransition("close"):Play(function()
        if dispatchCallback and self.onConfirmCall then
            self.onConfirmCall()
        end
        if dispatchCallback and self.onCancelCall then
            self.onCancelCall()
        end

        if self.onDestroyCallback then
            self.onDestroyCallback()
            self.onDestroyCallback = nil
        end
    end)
end

function MessageBox:SetDestroyCallback(cb)
    self.onDestroyCallback = cb
end

return MessageBox