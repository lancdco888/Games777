local Singular = class("Singular")

local className = "org/cocos2dx/lua/AppActivity"

------------------------------------------------------------------------------------------
--    to jni level

function Singular:initSDK(apiKey, secret)
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local luaj = require "cocos.cocos2d.luaj"
        local args = { apiKey, secret }
        local signs = "(Ljava/lang/String;Ljava/lang/String;)Z"

        if not luaj.checkStaticMethod(className,"singular_initSDK", signs) then
            print("Singular: old apk, dont support singular_initSDK")
            return
        end
        print("Singular:initSDK()" .. apiKey .. secret)
        local ok, ret = luaj.callStaticMethod(className, "singular_initSDK", args, signs)
        if not ok then return false end
        return ret
    end
end

function Singular:setCustomUserId(custom_user_id)
    custom_user_id = tostring(custom_user_id)
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local luaj = require "cocos.cocos2d.luaj"
        local args = { custom_user_id }
        local signs = "(Ljava/lang/String;)V"

        if not luaj.checkStaticMethod(className,"singular_setCustomUserId", signs) then
            print("Singular: old apk, dont support singular_setCustomUserId")
            return
        end
        print("Singular:setCustomUserId()" .. custom_user_id)
        local ok, ret = luaj.callStaticMethod(className, "singular_setCustomUserId", args, signs)
        if not ok then return false end
        return ret
    end
end

function Singular:unsetCustomUserId()
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local luaj = require "cocos.cocos2d.luaj"
        local args = {}
        local signs = "()V"

        if not luaj.checkStaticMethod(className,"singular_unsetCustomUserId", signs) then
            print("Singular: old apk, dont support singular_unsetCustomUserId")
            return
        end
        print("Singular:unsetCustomUserId()")
        local ok, ret = luaj.callStaticMethod(className, "singular_unsetCustomUserId", args, signs)
        if not ok then return false end
        return ret
    end
end

function Singular:event(eventName)
    eventName = tostring(eventName)
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local luaj = require "cocos.cocos2d.luaj"
        local args = { eventName }
        local signs = "(Ljava/lang/String;)Z"

        if not luaj.checkStaticMethod(className,"singular_event", signs) then
            print("Singular: old apk, dont support singular_event")
            return
        end
        print("Singular:event()" .. tostring(eventName))
        local ok, ret = luaj.callStaticMethod(className, "singular_event", args, signs)
        if not ok then return false end
        return ret
    end
end

function Singular:eventJSON(eventName, eventArgs)
	dump({
		eventName = eventName,
		eventArgs = eventArgs
	}, "Singular:eventJSON")

    eventName = tostring(eventName)
	if eventArgs == nil or not next(eventArgs) then
		eventArgs = "{}"
	else
    	eventArgs = json.encode(eventArgs) or "{}"
	end

    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local luaj = require "cocos.cocos2d.luaj"
        local args = { eventName, eventArgs }
        local signs = "(Ljava/lang/String;Ljava/lang/String;)Z"

        if not luaj.checkStaticMethod(className,"singular_eventJSON", signs) then
            print("Singular: old apk, dont support singular_eventJSON")
            return
        end
        print("Singular:eventJSON()" .. tostring(eventName) .. "," .. tostring(eventArgs))
        local ok, ret = luaj.callStaticMethod(className, "singular_eventJSON", args, signs)
        if not ok then return false end
        return ret
    end
end

-- Singular:customRevenue("MyCustomRevenue", "USD", 5.50);
function Singular:customRevenue(eventName, currency, amount)
    eventName = tostring(eventName)
    currency = tostring(currency)
    amount = amount or 0.0

    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local luaj = require "cocos.cocos2d.luaj"
        local args = { eventName, currency, amount }
        local signs = "(Ljava/lang/String;Ljava/lang/String;F)Z"

        if not luaj.checkStaticMethod(className,"singular_customRevenue", signs) then
            print("Singular: old apk, dont support singular_customRevenue")
            return
        end
        print("Singular:customRevenue()" .. tostring(eventName) .. "," .. tostring(currency) .. "," .. tostring(amount))
        local ok, ret = luaj.callStaticMethod(className, "singular_customRevenue", args, signs)
        if not ok then return false end
        return ret
    end
end

------------------------------------------------------------------------------------------
--    high level api

function Singular:login(user_id)
    self.user_id = tostring(user_id)

    local eventName = "sng_login"   -- Events.sngLogin
    local attributs = { }
    attributs.sng_attr_content = self.user_id  -- Attributes.sngAttrContent
    return self:eventJSON(eventName, attributs)
end

function Singular:registerCompleted()
    local eventName = "sng_complete_registration"   -- Events.sngCompleteRegistration
    local attributs = { }
    -- attributs.sng_attr_content = self.user_id  -- Attributes.sngAttrContent
    return self:eventJSON(eventName, attributs)
end

function Singular:firstPurchase(amount)
    local eventName = "sng_ecommerce_purchase"   -- Events.sngEcommercePurchase
    local attributs = { }
    -- attributs.sng_attr_content = "itemName"  -- Attributes.sngAttrContent itemName
    -- attributs.sng_attr_content_id = "itemId"  -- Attributes.sngAttrContentId itemId
    -- attributs.sng_attr_content_type = "itemCategory"  -- Attributes.sngAttrContentType itemCategory
    attributs.sng_attr_item_price = tostring(amount)  -- Attributes.sngAttrItemPrice purchaseAmount
	attributs.user_id = tostring(self.user_id)
    return self:eventJSON(eventName, attributs) 
end

function Singular:purchase(amount)
    local eventName = "all_deposit"
    local attributs = { }
	attributs.user_id = self.user_id
	attributs.deposit_amount = tostring(amount)
    return self:eventJSON(eventName, attributs) 
end

-- 首次打开
function Singular:firstOpen()
    local eventName = "first_open"
    local attributs = { }
    -- attributs.user_id = "unknown"
    return self:eventJSON(eventName, attributs)
end

-- 提现到卡
function Singular:refund(amount)
    local eventName = "refund"
    local attributs = { }
    -- attributs.content_name = "contentName"
    -- attributs.content_id = "contentId"
    -- attributs.content_type = "contentType"
    attributs.refund_amount = tostring(amount)
    return self:eventJSON(eventName, attributs)
end

-- 保险箱提款
function Singular:safeWithdraw(amount)
    local eventName = "safe_withdrawal"
    local attributs = { }
    attributs.user_id = self.user_id
    attributs.withdrawal_amount = tostring(amount)
    -- attributs.withdrawal_method = "method"
    return self:eventJSON(eventName, attributs)
end

-- 保险箱存款
function Singular:safeDeposit(amount)
    local eventName = "safe_deposit"
    local attributs = { }
    attributs.user_id = self.user_id
    attributs.deposit_amount = tostring(amount)
    -- attributs.deposit_method = "method"
    return self:eventJSON(eventName, attributs)
end

-- 首次进入游戏SPIN界面
function Singular:startTrial()
    local eventName = "sng_start_trial"
    local attributs = { }

    attributs.user_id = self.user_id
    return self:eventJSON(eventName, attributs)
end

return Singular
