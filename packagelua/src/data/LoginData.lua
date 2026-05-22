-- 登录相关的数据
local LoginData = class("LoginData")
local ud = cc.UserDefault:getInstance()
local json = require("json")
LoginData.TYPE = {
    -- 0=游客 1=facebook 2=用户名密码
    GUEST = 0,
    FACKBOOK = 1,
    PWD = 2
}

function LoginData:ctor()
    self.current_type = ud:getIntegerForKey("login_type", LoginData.TYPE.GUEST)
    self.current_account = ""
    self.current_password = ""
    self.isSavePwd = true -- 账号密码登录是否记住密码
    self.accDatas = LoginData:InitAccDatas()
    self.is_auto_login = ud:getBoolForKey("auto_login", false)
end

----------------------------------------

-- 是否自动登录
function LoginData:IsAutoLogin()
    return self.is_auto_login
end

-- 设置自动登录
function LoginData:SetAutoLogin(bAuto)
    self.is_auto_login = bAuto
    ud:setBoolForKey("auto_login", bAuto)
end

----------------------------------------

-- 是否保存账号密码
function LoginData:GetIsSavePwd()
    return self.isSavePwd
end

function LoginData:SetIsSavePwd(bool_)
    self.isSavePwd = bool_
end
----------------------------------------
----------------------------------------
-- 登录类型
function LoginData:GetType()
    return self.current_type
end

function LoginData:SetType(type)
    self.current_type = type
    ud:setIntegerForKey("login_type", type)
end
----------------------------------------
----------------------------------------
-- 账号
function LoginData:GetAccount()
    return self.current_account
end

function LoginData:SetAccount(account)
    self.current_account = account
end
----------------------------------------
----------------------------------------
-- 密码
function LoginData:GetPassword()
    return self.current_password
end

function LoginData:SetPassword(password)
    self.current_password = password
end
----------------------------------------
----------------------------------------
-- 本地账号相关数据
-- username
-- account_id
-- fbid
-- acc_name
-- pwd_name
function LoginData:InitAccDatas()
    local accJson = ud:getStringForKey("Account")
    if not accJson or accJson == "" then
        local username_ = self:GetOldUserName()
        local returndate_ = {}
        if username_ and username_ ~= "" then
            returndate_["username"]     = username_
            returndate_["account_id"]   = self:GetOldAccountID()
            returndate_["fbid"]         = self:GetOldFacebookID()
            returndate_["acc_name"]     = self:GetOldAccName()
            returndate_["pwd_name"]     = self:GetOldPwd()
            local file = cc.UserDefault:getXMLFilePath()
            local str_ = string.sub(file,1,#file - 4)
            os.rename(file,str_ .. "_bf.xml")
        end
		self.accDatas = returndate_
		self:SaveAccDatas()
        return returndate_
    end
    return json.decode(accJson)
end

--username,旧平台升级用
function LoginData:GetOldUserName()
    local str = string.format("%s%d", "UserName_", 1) 
	local username = cc.UserDefault:getInstance():getStringForKey(str)
	return username
end

--account_id,旧平台升级用
function LoginData:GetOldAccountID()
    local str = string.format("%s%d","UserID_", 1)
	local accID = cc.UserDefault:getInstance():getStringForKey(str)
	return accID
end

--fbid,旧平台升级用
function LoginData:GetOldFacebookID()
    local str = string.format("%s%d", "facebookID_", 1)
	local facebookID = cc.UserDefault:getInstance():getStringForKey(str)
	return facebookID
end

--acc_name,旧平台升级用
function LoginData:GetOldAccName()
    local acc = cc.UserDefault:getInstance():getStringForKey("acc_name")
	return acc
end

--pwd_name,旧平台升级用
function LoginData:GetOldPwd()
    local pwd = cc.UserDefault:getInstance():getStringForKey("pwd_name")
	return pwd
end

function LoginData:SaveAccDatas()
    if not next(self.accDatas) then
        return
    end
    local str_ = json.encode(self.accDatas)
    ud:setStringForKey("Account", str_)
end

function LoginData:ModifyAccDatas(k,v)
    self.accDatas[k] = v
end
------------------------------------------
return LoginData
