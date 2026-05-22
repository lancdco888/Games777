local MailDetailLayer = class("MailDetailLayer", function()
    return Tools.CreateLayer("csb/serviceMail/MailDetailLayer.csb")
end)

function MailDetailLayer:onEnter()
    self:InitUI()
end

function MailDetailLayer:InitUI()
    --关闭按钮
    self.ui_close_btn = self:findChild("btn_close")
    Tools.AddClickEvent(self.ui_close_btn, function()
        self:Close()
    end, true)

    self.ui_gm = self:findChild("gm")
    self.ui_msg = self:findChild("msg")
    self.ui_msg:setString("")
    self.ui_gm:setVisible(false)

    self.ui_gm:setString(TR("发件人:系统"))
end

function MailDetailLayer:SetDetailInfo(info)
    self.ui_gm:setVisible(true)
    local msg = ""
    if not info.template_key or info.template_key == "" then
        msg = info.content
    else
        --需要做转换
        local dict = {}
        if info.content ~= "" then
            local json = require("json")
            dict = json.decode(info.content).content
        end
        msg = service.MailTemplates:FormatContent(info.template_key, dict)
    end
    self.ui_msg:setString(msg)
end

return MailDetailLayer
