
local AdjustSDK = class("AdjustSDK")

AdjustSDK.EventName = {
    StartTrial           = "StartTrial",
    Purchase             = "Purchase",
    CompleteRegistration = "CompleteRegistration"
}

local EventNameMap
if BuildConfig then
    EventNameMap = {
        [AdjustSDK.EventName.StartTrial]           = BuildConfig["AdjustSDKEventToken_StartTrial"] or "",
        [AdjustSDK.EventName.Purchase]             = BuildConfig["AdjustSDKEventToken_Purchase"] or "",
        [AdjustSDK.EventName.CompleteRegistration] = BuildConfig["AdjustSDKEventToken_CompleteRegistration"] or ""
    }
else
    EventNameMap = {}
end

function AdjustSDK:PushAdjustEvent(eventName)
    print("[AdjustSDK] lua 调用 AdjustSDK:PushAdjustEvent 函数", eventName)

    local eventToken = EventNameMap[eventName]
    if eventToken == nil or eventToken == "" then
        print("[AdjustSDK] 未知事件类型:", eventName)
        return
    end

    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local luaj = require "cocos.cocos2d.luaj"
        local className = "org/cocos2dx/lua/AppActivity"

        if luaj.checkStaticMethod(className, "ClearAdjustPartnerParameter", "()V") then
            luaj.callStaticMethod(className, "ClearAdjustPartnerParameter", {}, "()V")

            local userId = "null"
            if UserData and UserData.id then
                userId = tostring(UserData.id)
            end

            local md5 = require("hall.src.common.md5")
            userId = md5.sumhexa(userId)

            luaj.callStaticMethod(className, "AddAdjustPartnerParameter", {"email", userId}, "(Ljava/lang/String;Ljava/lang/String;)V")
            luaj.callStaticMethod(className, "AddAdjustPartnerParameter", {"phone", userId}, "(Ljava/lang/String;Ljava/lang/String;)V")
            luaj.callStaticMethod(className, "AddAdjustPartnerParameter", {"user", userId}, "(Ljava/lang/String;Ljava/lang/String;)V")
        else
            print("[AdjustSDK] 没有 luaj.AddAdjustPartnerParameter 函数")
        end

        -- 充值事件
        local hasRevenue = eventName == AdjustSDK.EventName.Purchase

        local args = { 
            eventToken, -- 事件token
            hasRevenue, -- 充值事件
            1.0,        -- 充值金额
            "USD",      -- 币种编码
            "",         -- 事件唯一识别码
        }

        local signs = "(Ljava/lang/String;ZFLjava/lang/String;Ljava/lang/String;)V"
        if not luaj.checkStaticMethod(className, "PushAdjustEvent", signs) then
            print("[AdjustSDK] 没有 luaj.PushAdjustEvent 函数")
            return
        end

        print("[AdjustSDK] luaj 调用 luaj.PushAdjustEvent 函数", eventName)
        luaj.callStaticMethod(className, "PushAdjustEvent", args, signs)
    end
end

function OnAdjustEventTrackingFailedListener(adjustEventFailure)
    local data = json.decode(adjustEventFailure, true)
    dump(data, "[AdjustSDK] OnAdjustEventTrackingFailedListener")
end

function OnAdjustEventTrackingSucceededListener(adjustEventSuccess)
    local data = json.decode(adjustEventSuccess)
    dump(data, "[AdjustSDK] OnAdjustEventTrackingSucceededListener")
end

return AdjustSDK
