local Facebook = {}

--获取一个facebook token, 需要在协程环境使用
function Facebook.GetToken()
    local token = nil
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_WINDOWS == targetPlatform then
		token = "fake_token"
    elseif cc.PLATFORM_OS_ANDROID == targetPlatform then
		local callbackLua = function(str)
			token = str
		end
		local luaj = require "cocos.cocos2d.luaj"
		local className = "org/cocos2dx/lua/AppActivity"
		local args = {"facebookLogin",callbackLua}
		local sigs = "(Ljava/lang/String;I)V"
		local ok,ret = luaj.callStaticMethod(className, "facebookLogin", args, sigs)
	elseif cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
		local IOS_ClassName =  "PlatBridge"
		--str是一个table，里面只有一个名字叫str的token
        local callback = function(str) 
			token = str.str
        end
        local appargs = {
			callback = callback
        }
        local luaoc = require("cocos.cocos2d.luaoc")
        luaoc.callStaticMethod(IOS_ClassName, "LoginFB", appargs)
    end
    
    --安静的等待token
    while token == nil do
        yield()
    end
    if token == "cancel" then
        UIManager.ShowMsgBox(TR("你取消了该操作，请重试"))
        return false, ""
    elseif token == "error" then
        UIManager.ShowMsgBox(TR("你需先安装facebook，如果没有，请取消服务。"))
        return false, ""
    end
    return true, token
end

function Facebook.HandleBind(onOk)
    go(function()
        UIManager.ShowWaiting()
        local result,token = Facebook.GetToken()
        UIManager.HideWaiting()
        if not result then
            return    
        end
        local data_ = PKG_Client_Lobby_ClientVerificationFacebook.Create()
        data_.token = token
        UIManager.ShowWaiting()
        while not gNet:Alive() do
            yield()
        end
        local rlt_ = nil
        for i = 1, 20 do
            rlt_ = gNet_SendRequest(data_)
            if rlt_ and getmetatable(rlt_) == PKG_Lobby_Client_VerificationFacebook_Success then
                break
            else
                SleepSecs(0.3)
            end
        end
        UIManager.HideWaiting()
        if rlt_ and getmetatable(rlt_) == PKG_Lobby_Client_VerificationFacebook_Success then
            UserData.money = rlt_.money
            UserData.is_system_gift_money = rlt_.is_system_gift_money
            LoginData:ModifyAccDatas("fbid",rlt_.facebook)
            LoginData:SaveAccDatas()
            Dispatcher:Dispatch(UserData)
            UIManager.ShowMsgBox(TR("绑定号码成功"))
            if onOk then
                onOk()
            end
        elseif(getmetatable(rlt_) == PKG_Generic_Error)then
            local num = Int64ToNumber(rlt_.number)
            if (num == Def.Net_FacebookIsbulid) then
                UIManager.ShowMsgBox(TR("本Facebook账号已经绑定"))
            else
                UIManager.ShowMsgBox(TR("绑定失败"))
            end
        end
    end)
end

return Facebook
