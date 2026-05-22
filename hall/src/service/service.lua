local service = class("service")

function service:ctor()
    Tools.AddDelayField( self,
        "ServiceLogic",
        function()
            return require("hall.src.service.ServiceLogic").new()
        end,
        nil
    )

    local classes = {
        "MailLayer",
        "QuestionLayer",
        "ServiceLayer",
        "SugguestLayer",
        "ServiceMailLayer",
        "ImageViewLayer",
        "MailDetailLayer",
        "MailTemplates",

        "Panel_ServiceMail",
    }

    for _,cls in pairs(classes) do
        Tools.AddDelayField( self,
            cls,
            require,
            "hall.src.service." .. cls
        )
    end

    -- 兼容
    package.loaded["hall.src.hallnew.layers.lobby.service.Panel_ServiceMail"] = self.Panel_ServiceMail

    -- 兼容
    ServiceMailLogic = self.ServiceLogic
end

return service.new()
