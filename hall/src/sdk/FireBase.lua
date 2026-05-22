local FireBase = class("FireBase")

local className = "org/cocos2dx/lua/AppActivity"

------------------------------------------------------------------------------------------
--    to jni level

function FireBase:eventJSON(eventName, eventArgs)
	dump({
		eventName = eventName,
		eventArgs = eventArgs
	}, "FireBase:eventJSON")

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

        if not luaj.checkStaticMethod(className,"firebase_eventJSON", signs) then
            print("FireBase: old apk, dont support firebase_eventJSON")
            return
        end
        print("FireBase:eventJSON()" .. tostring(eventName) .. "," .. tostring(eventArgs))
        local ok, ret = luaj.callStaticMethod(className, "firebase_eventJSON", args, signs)
        if not ok then return false end
        return ret
    end
end

------------------------------------------------------------------------------------------
--    high level api

function FireBase:login(user_id)
    self.user_id = tostring(user_id)

    local eventName = "login"
    local attributs = { }
    attributs.method = "email"
    return self:eventJSON(eventName, attributs)
end

function FireBase:registerCompleted()
    local eventName = "register"
    local attributs = { }
	-- attributs.register = self.user_id
    return self:eventJSON(eventName, attributs)
end

function FireBase:firstPurchase(amount)
    local eventName = "ftd"
    local attributs = { }
    attributs.value = amount
	attributs.user_id = self.user_id
    return self:eventJSON(eventName, attributs)
end

function FireBase:purchase(amount)
    local eventName eventName = "all_deposit"
    local attributs = { }
	attributs.user_id = self.user_id
    attributs.deposit_amount = amount
    return self:eventJSON(eventName, attributs) 
end

-- 首次打开
function FireBase:firstOpen()
    local eventName = "app_first_open"
    local attributs = { }
    attributs.event_type = "first_open"
    return self:eventJSON(eventName, attributs)
end

-- 提现到卡
function FireBase:refund(amount)
    local eventName = "refund"
    local attributs = { }
    attributs.user_id = self.user_id
    attributs.refund_amount = amount
    return self:eventJSON(eventName, attributs)
end

-- 保险箱提款
function FireBase:safeWithdraw(amount)
    local eventName = "safe_withdrawal"
    local attributs = { }
    attributs.user_id = self.user_id
    attributs.withdrawal_amount = amount
    return self:eventJSON(eventName, attributs)
end

-- 保险箱存款
function FireBase:safeDeposit(amount)
    local eventName = "safe_deposit"
    local attributs = { }
    attributs.user_id = self.user_id
    attributs.deposit_amount = amount
    return self:eventJSON(eventName, attributs)
end

-- 首次进入游戏SPIN界面
function FireBase:startTrial()
	print("FireBase: no StartTrial")
end

return FireBase
