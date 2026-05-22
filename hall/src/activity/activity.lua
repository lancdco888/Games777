local activity = class("activity")

function activity:ctor()
    Tools.AddDelayField( self,
        "logic",
        function() return require("hall.src.activity.ActivityLogic").new() end,
        nil
    )

    Tools.AddDelayField( self,
        "SpreadLogic",
        function() return require("hall.src.activity.SpreadLogic").new() end,
        nil
    )

    local classes = {
        "ActivityCenterLayer",
        "AwardPopLayer",
        "RebateLayer",
        "RechargeFirstLayer",
        "SpreadLayer",
        "TurntableLayer",
        "AccountBindAdLayer",
    }
    for _,cls in pairs(classes) do
        Tools.AddDelayField( self,
            cls,
            require,
            "hall.src.activity." .. cls
        )
    end
end

return activity.new()
