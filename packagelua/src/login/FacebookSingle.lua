-- FacebookSingle
local FacebookSingle = class("FacebookSingle")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
function FacebookSingle:ctor()
    self.currentFbid = nil
    local fbid = LoginData.accDatas.fbid
    if LoginData.accDatas.fbid and LoginData.accDatas.fbid ~= "" then
        self:setCurrentFbid(fbid)
    end
end
-----------------------------------------
---当前的facebookid
function FacebookSingle:setCurrentFbid(id)
    self.currentFbid = id
end

function FacebookSingle:getCurrentFbid()
    return self.currentFbid
end
-----------------------------------------
-- 协程获取token
function FacebookSingle:getFBToken()
    local token = nil
    if(cc.PLATFORM_OS_WINDOWS == targetPlatform)then
        token = "fake_token"
    elseif(cc.PLATFORM_OS_ANDROID == targetPlatform)then
        local callbackLua = function(str)
            token = str
        end
        local luaj = require "cocos.cocos2d.luaj"
        local className = "org/cocos2dx/lua/AppActivity"
        local args = {"facebookLogin",callbackLua}
        local sigs = "(Ljava/lang/String;I)V"
        local ok,ret = luaj.callStaticMethod(className, "facebookLogin", args, sigs)
    elseif(cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform)then
        local IOS_ClassName =  "PlatBridge"
        --str是一个table，里面只有一个名字叫str的token
        local callback = function(str) 
            token = str.str
        end
        local appargs = {
            callback = callback
        }
        local luaoc = require("cocos.cocos2d.luaoc")
        luaoc.callStaticMethod(IOS_ClassName,"LoginFB",appargs)
    end
    while not token do
        yield()
    end
    return token
end

-- 从服务器那根据token拿一个fbid，协程 
-- 确保网络畅通老铁
function FacebookSingle:getFBIDByToken(token)
    local fbid = nil
    if token == "cancel" then
        print("用户错误")
        Tools_Base.ShowMsgBox(TR("你取消了该操作，请重试"))
    elseif token == "error" then
        print("sdk错误")
        Tools_Base.ShowMsgBox(TR("你需先安装facebook，如果没有，请取消服务。"))
    else
        local data_ = PKG_Client_Login_ClientVerificationFacebook.Create()
        data_.token = token
        -- todo 因为 获取token切换了Activity，cocos的主线程挂起，容易断线，等待网络恢复发送token
        local rlt_ = gNet_SendRequest(data_)
        if rlt_ then
            if(getmetatable(rlt_) == PKG_Login_Client_ReceivedVerificationFacebook) then
                if (rlt_.state == 1) then
                    fbid = rlt_.facebook_id
                else
                    Tools_Base.ShowMsgBox(TR("绑定失败"))
                    print("服务器返回fbid错误 登录失败")
                end	
            elseif(getmetatable(rlt_) == PKG_Generic_Error)then
                print("服务器返回fbid错误")
                Tools_Base.ShowMsgBox(TR("绑定失败"))
            end
        end
    end
    return fbid
end
return FacebookSingle
