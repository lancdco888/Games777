local user = class("user")

function user:ctor()
    local classes = {
        "ChangeHeadLayer",
        "SelfInfoLayer",
        "ModifyNameLayer",
        "SetUpLayer",
        "VipBenefitLayer",
        "VIPLevelUpLayer",
        "AccountBindingLayer",
        "AccountEmailBindingLayer",
        "EmailBindingLayer",
        "SafeBoxLayer",
    }
    for _,cls in pairs(classes) do
        Tools.AddDelayField( self,
            cls,
            require,
            "hall.src.user." .. cls
        )
    end

    -- 兼容
    SetUpLayer = self.SetUpLayer
end

return user.new()
