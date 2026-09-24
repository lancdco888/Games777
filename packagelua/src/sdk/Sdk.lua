local Sdk = class("Sdk")

function Sdk:ctor()
    require("packagelua.src.sdk.MetaPixel")

    -- Singular
    local apiKey
    local secret
    if BuildConfig then 
        apiKey = BuildConfig["SingularApiKey"]
        secret = BuildConfig["SingularSecret"]
    end
    if apiKey ~=nil and apiKey ~= "" and secret ~= nil  and secret ~= "" then
        self.singular = require("packagelua.src.sdk.Singular").new()
        self.singular:initSDK(apiKey, secret)
    else
        self.singular = nil
    end

	self.firebase = require("packagelua.src.sdk.FireBase").new()
end

function Sdk:unload()
	for k,v in pairs(package.loaded) do
		if string.find(k, "packagelua.src.sdk.") == 1 then
			package.loaded[k] = nil
		end
	end
end

---------------------------------------------------------------------

function Sdk:login(user_id)
	if self.singular then
		self.singular:login(user_id)
	end

	self.firebase:login(user_id)
end

function Sdk:registerCompleted()
	if self.singular then
		self.singular:registerCompleted()
	end

	self.firebase:registerCompleted()

	if MetaPixelEvent then
		MetaPixelEvent("CompleteRegistration")
	end
end

function Sdk:firstPurchase(amount)
	if self.singular then
		self.singular:firstPurchase(amount)
	end

	self.firebase:firstPurchase(amount)

	self:purchase(amount)
end

function Sdk:purchase(amount)
	if self.singular then
		self.singular:purchase(amount)
	end

	self.firebase:purchase(amount)

	if MetaPixelEvent then
		MetaPixelEvent("Purchase")
	end
end

-- 首次打开
function Sdk:firstOpen()
    if cc.UserDefault:getInstance():getBoolForKey("FIRST_OPEN_SENT", false) then
		return
    end
	cc.UserDefault:getInstance():setBoolForKey("FIRST_OPEN_SENT", true) 

	if self.singular then
		self.singular:firstOpen()
	end

	self.firebase:firstOpen()
end

-- 提现到卡
function Sdk:refund(amount)
	if self.singular then
		self.singular:refund(amount)
	end
	
	self.firebase:refund(amount)
end

-- 保险箱提款
function Sdk:safeWithdraw(amount)
	if self.singular then
		self.singular:safeWithdraw(amount)
	end

	self.firebase:safeWithdraw(amount)
end

-- 保险箱存款
function Sdk:safeDeposit(amount)
	if self.singular then
		self.singular:safeDeposit(amount)
	end

	self.firebase:safeDeposit(amount)
end

-- 首次进入游戏SPIN界面
function Sdk:startTrial()
    if cc.UserDefault:getInstance():getBoolForKey("StartTrial_Sent", false) then
		return
    end
	cc.UserDefault:getInstance():setBoolForKey("StartTrial_Sent", true) 

	if self.singular then
		self.singular:startTrial()
	end

	self.firebase:startTrial()

	if MetaPixelEvent then
		MetaPixelEvent("StartTrial")
	end
end

return Sdk
