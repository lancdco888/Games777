local Device = class("Device")

-------------------------------------------------------------------
-- patch for luaj.

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_ANDROID == targetPlatform then
	local luaj = require "cocos.cocos2d.luaj"
	local checkJavaStaticMethod = LuaJavaBridge.checkStaticMethod
	function luaj.checkStaticMethod(className, methodName, sig)
		if not checkJavaStaticMethod then
			print("no checkStaticMethod in c++ runtime!")
			return false
		end
		return checkJavaStaticMethod(className, methodName, sig)
	end
end

-------------------------------------------------------------------

-- 未知
Device.Unknown_Screen_Type = 0
--横屏
Device.H_Screen_Type = 1
--竖屏
Device.V_Screen_Type = 2

function Device:ctor()
	self.platform = nil
	self.deviceID = nil
	self.pkg_name_ = ""
	self.currentScreenType = Device.Unknown_Screen_Type -- const_game.Unknown_Screen_Type

	self:GetSystemModel()

	local utils = require("bootstrap.src.utils")
	utils.go(function()
		self.pkg_name_ = GetPackageName()
	end)
	self:GetDeviceID()

    self.gl_exts = {}
    if gl.getSupportedExtensions then
        self.gl_exts = gl.getSupportedExtensions()
        -- dump(self.gl_exts, " ** Device.gl_exts ** ")
    end
end

function Device:CheckGlExtensions(key)
    local gl_exts = self.gl_exts
    for __, ext in pairs(gl_exts) do
        if string.find(ext, key) then
            return true
        end
    end
    return false
end

function Device:IsAstcSupported()
    local astc = BuildConfig and BuildConfig.IsAstcSupported
    local glAstc = self:CheckGlExtensions("GL_KHR_texture_compression_astc_ldr")
    if astc and glAstc then
        return true
    end

    return false
end

--退出游戏
function Device:ExitApp()
	cc.Director:getInstance():endToLua()
end

function Device:GetdatasFromClipboard(callback)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if(cc.PLATFORM_OS_WINDOWS == targetPlatform)then
		if GetClipBoardString then
			local str = GetClipBoardString()
			if callback then callback(str) end
		else
			if callback then callback("") end
		end
	elseif(cc.PLATFORM_OS_ANDROID == targetPlatform)then
		local luaj = require "cocos.cocos2d.luaj"
		local className = "org/cocos2dx/lua/AppActivity"
		local args = {}
		local sigs = "()Ljava/lang/String;"
		local ok,ret = luaj.callStaticMethod(className, "GetdatasFromClipboard", args, sigs)
		if ret == "未复制内容" then
			ret = ""
        end
        if callback then callback(ret) end
	elseif(cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform)then
        local IOS_ClassName =  "PlatBridge"
        local iOSTexts = {
            text = function(str)
                if str ~= nil then
                    str = str.iOStext
                else
                    str = "error"
                end
                if callback then callback(str) end
            end
        }
        local luaoc = require("cocos.cocos2d.luaoc")
        luaoc.callStaticMethod(IOS_ClassName, "ClipboardText", iOSTexts)
	end
end

function Device:CopyString(str)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if(cc.PLATFORM_OS_WINDOWS == targetPlatform)then
		printf("********CopyString on windows")
		if SetClipBoardString then
			return SetClipBoardString(str)
		else
			return false
		end
	elseif(cc.PLATFORM_OS_ANDROID == targetPlatform)then
		local luaj = require "cocos.cocos2d.luaj"
		local className = "org/cocos2dx/lua/AppActivity"
		local args = {str,callbackLua}
		local sigs = "(Ljava/lang/String;I)V"
		local ok,ret = luaj.callStaticMethod(className, "copyString", args, sigs)
		return ok
	elseif(cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform)then
		return true
	end
end

--设置屏幕类型 gCasino_Common_Func脚本移来的
function Device:setScreenType(screen_type_)
	if screen_type_ == self.currentScreenType then return end
	self.currentScreenType = screen_type_

	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if(cc.PLATFORM_OS_WINDOWS == targetPlatform)then
		local width, height
		local resolutionW, resolutionH
		if screen_type_ == Device.H_Screen_Type then
			width = 1280
			height = 720
			resolutionW = 1280
			resolutionH = 720
		else
			height = 1280 * 0.64
			width = 720 * 0.64
			resolutionW = 720
			resolutionH = 1280
		end
		local glview = cc.Director:getInstance():getOpenGLView()
		glview:setFrameSize(width,height)
		glview:setDesignResolutionSize(resolutionW, resolutionH,cc.ResolutionPolicy.NO_BORDER)
	elseif(cc.PLATFORM_OS_ANDROID == targetPlatform)then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {screen_type_}
		local sigs = "(I)V"
		local ok,ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "setOrientation", args, sigs)

		local glview    = cc.Director:getInstance():getOpenGLView()
		local frameSize = glview:getFrameSize()
		local winSize   = cc.Director:getInstance():getWinSize()

		print("size", frameSize.width, frameSize.height)
		print("winSize", winSize.width, winSize.height)

		local frameW = math.max(frameSize.width, frameSize.height)
		local frameH = math.min(frameSize.width, frameSize.height)

		local sizeW = math.max(winSize.width, winSize.height)
		local sizeH = math.min(winSize.width, winSize.height)

		local adaptiveDesignedX = 1280
		local adaptiveDesignedY = 720

		if screen_type_ ~= Device.H_Screen_Type then
			frameW, frameH = frameH, frameW
			sizeW, sizeH = sizeH, sizeW
			adaptiveDesignedX, adaptiveDesignedY = adaptiveDesignedY, adaptiveDesignedX
		end

		-- 限制高分辨率
		local scale = math.max(adaptiveDesignedX / sizeW, adaptiveDesignedY / sizeH)
		sizeW = math.floor(sizeW * scale)
		sizeH = math.floor(sizeH * scale)

		glview:setFrameSize(frameW, frameH)
		glview:setDesignResolutionSize(sizeW, sizeH, cc.ResolutionPolicy.NO_BORDER)
	elseif(cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform)then
	end
end

function Device:PushFacebookEvent(type_)
    print("Device:PushFacebookEvent()," .. tostring(type_))
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if(cc.PLATFORM_OS_WINDOWS == targetPlatform or cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform)then
	elseif(cc.PLATFORM_OS_ANDROID == targetPlatform)then
		local luaj = require "cocos.cocos2d.luaj"
		local className = "org/cocos2dx/lua/AppActivity"
		local args = {type_} --推送事件类型:"1" 首次获得账号，"2" 充值成功
		local sigs = "(Ljava/lang/String;)V"
		luaj.callStaticMethod(className, "PushFacebookEvent", args, sigs)
	end
end

function Device:GetSystemModel()
	if self.platform == nil then
		local targetPlatform = cc.Application:getInstance():getTargetPlatform()
		if(cc.PLATFORM_OS_WINDOWS == targetPlatform)then
			self.platform = "windows"
		elseif(cc.PLATFORM_OS_MAC == targetPlatform)then
			self.platform = "windows"
		elseif(cc.PLATFORM_OS_ANDROID == targetPlatform)then
			local callbackLua = function(str)
				self.platform = str
			end
			local luaj = require "cocos.cocos2d.luaj"
			local className = "org/cocos2dx/lua/AppActivity"
			local args = {"getSystemModel",callbackLua}
			local sigs = "(Ljava/lang/String;I)V"
			local ok,ret = luaj.callStaticMethod(className, "getSystemModel", args, sigs)
		elseif(cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform)then
			local IOS_ClassName =  "PlatBridge"
			local callback = function(str)
				self.platform = str.model
			end
			local appargs = {
				model = callback
			}
			local luaoc = require("cocos.cocos2d.luaoc")
			luaoc.callStaticMethod(IOS_ClassName,"getSystemModel",appargs)
		end
	end
	return self.platform
end

function Device:GetDeviceID()
	if self.deviceID == nil then
		local targetPlatform = cc.Application:getInstance():getTargetPlatform()
		if cc.PLATFORM_OS_WINDOWS == targetPlatform then
			self.deviceID = ""
		elseif cc.PLATFORM_OS_MAC == targetPlatform then
			self.deviceID = "mac-dddd311"
		elseif cc.PLATFORM_OS_ANDROID == targetPlatform then
			local callbackLua = function(str)
				-- 新的需求是把deviceID 进行一次MD5
				local MD5 = require("packagelua.src.base.md5")
				self.deviceID = (str == "") and "" or MD5.sumhexa(str)
			end
			local luaj = require "cocos.cocos2d.luaj"
			local className = "org/cocos2dx/lua/AppActivity"
			local args = {"getDeviceID",callbackLua}
			local sigs = "(Ljava/lang/String;I)V"
			local funcname = "getDeviceIDInd"
			local ok,ret = luaj.callStaticMethod(className, funcname, args, sigs)
		elseif cc.PLATFORM_OS_IPHONE == targetPlatform
			or cc.PLATFORM_OS_IPAD == targetPlatform then
			self.deviceID = ""
		end
	end
	return self.deviceID
end

function Device:GetPhoneType()
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if(cc.PLATFORM_OS_WINDOWS == targetPlatform or cc.PLATFORM_OS_MAC == targetPlatform)then
		return 3
	elseif(cc.PLATFORM_OS_ANDROID == targetPlatform)then
		return 1
	elseif(cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform)then
		return 2
	end

	return -1
end

--获取包名
function Device:GetPackageName()
	return self.pkg_name_
end

function Device:OpenAlbum()
	local permission = Device:HasStoragePermission()
    if not permission then
        Device:RequestStoragePermission(function(rlt)
            if rlt == "success" then
				Device:OpenAlbumIternal()
            else
				-- 申请权限失败，什么都不做
            end
        end)
    else
		Device:OpenAlbumIternal()
	end
end

--打开相册
function Device:OpenAlbumIternal()
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_WINDOWS == targetPlatform then
		sGameManager.Image = require("bas64StrPng")
		sGameManager.ImageSize = #sGameManager.Image
	elseif cc.PLATFORM_OS_ANDROID == targetPlatform then
		local luaj = require "cocos.cocos2d.luaj"
		local className = "org/cocos2dx/lua/AppActivity"
		local args = {
			"goPhotoAlbum",
			function(str)		--str 为 base64 字符串
				if str == "null" then -- 这是因为用户取消选择图片返回的"null"字符串
					sGameManager.Image = "null"
				else
					sGameManager.Image = str
				end
			end,
			function(size_str)
				sGameManager.ImageSize = size_str
			end,
		}
		local sigs = "(Ljava/lang/String;II)V"
		local ok,ret = luaj.callStaticMethod(className, "goPhotoAlbum", args, sigs)
	elseif cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
		local function ios_callbak(str)
			if str.baseoc ~= nil then
				if str.baseoc == "null" then -- 这是因为用户取消选择图片返回的"null"字符串
					sGameManager.Image = "null"
				else
					sGameManager.Image = str.baseoc
				end
			end
			if str.sizeoc ~= nil then
				if tonumber(str.sizeoc) > 5*1024*1024 then -- 大于5M的图片不能上传
					sGameManager.ImageSize = "false"
				else
					sGameManager.ImageSize = str.sizeoc
				end
			end
		end
		local IOS_ClassName =  "PlatBridge"
        local picsite = {
            base64  = ios_callbak,
            picsize = ios_callbak
        }
        local luaoc = require("cocos.cocos2d.luaoc")
        luaoc.callStaticMethod(IOS_ClassName,"openPIC",picsite)
	end
end

-- 是否存在 "保存图片到相册" 调用
function Device:Has_SaveImageToGallery()
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local luaj = require "cocos.cocos2d.luaj"
		local className = "org/cocos2dx/lua/AppActivity"
        local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;"
		return luaj.checkStaticMethod(
			className,
			"SaveImageToGallery",
			sigs
		)
	elseif cc.PLATFORM_OS_WINDOWS == targetPlatform then
		return true
    elseif cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
        -- iOS 目前已支持该接口
        return true
	else
		return false
	end
end

-- 保存图片到相册
-- String SaveImageToGallery(String imagePath, String title, String description)
function Device:SaveImageToGallery(imagePath, title, description)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local luaj = require "cocos.cocos2d.luaj"
		local className = "org/cocos2dx/lua/AppActivity"
        local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;"
		local ok, ret = luaj.callStaticMethod(className,
			"SaveImageToGallery",
			{ imagePath, title, description },
			sigs
		)
		if not ok then
			return false
		end
		return ret == "success"
    elseif cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
        local IOS_ClassName =  "PlatBridge"
        local saveimage = {
            _imagepath = imagePath
        }
        local luaoc = require("cocos.cocos2d.luaoc")
        luaoc.callStaticMethod(IOS_ClassName,"saveimage",saveimage)
        return true
	elseif cc.PLATFORM_OS_WINDOWS == targetPlatform then
		local fu = cc.FileUtils:getInstance()
		local photo_dir_ = fu:getWritablePath() .. "device/photo/"
		if not fu:isDirectoryExist(photo_dir_) then
			fu:createDirectory(photo_dir_)
		end

		-- 读取文件
		local fpread = io.open(imagePath, "rb")
		if not fpread then
			print("SaveImageToGallery: file not found, " .. imagePath)
			return false
		end
		local data_ = fpread:read("*a")
		fpread:close()

		-- 写入文件
		local photo_n = photo_dir_ .. "photo.png"
		local fpwrite = io.open(photo_n, "wb")
		if not fpwrite then
			print("SaveImageToGallery: file open failed, " .. photo_n)
			return false
		end
		local result, __ = fpwrite:write(data_)
		fpwrite:close()

		if result == nil then
			print("SaveImageToGallery: write file failed, " .. photo_n)
			return false
		end
		print("收藏成功, 文件已保存至:" .. photo_n)
		return true
	else
		print("not support")
		return false
	end
end

-- 该函数已废弃, 等线上 所有 PackageLua 更新到最新版本即可删除
function Device:isArch64()
	return false
end

-------------------------------------------------------------------------
function Device:GetSDKVersion()
	local luaj = require "cocos.cocos2d.luaj"
	local className = "org/cocos2dx/lua/AppActivity"
	local sigs = "()I"
	local ok, ret = luaj.callStaticMethod(className, "GetSDKVersion", nil, sigs)
	if not ok then
		return 30
	else
		return ret
	end
end

-- 权限
function Device:HasPermission(permission)
	local luaj = require "cocos.cocos2d.luaj"
	local className = "org/cocos2dx/lua/AppActivity"
	local args = { permission }
	local sigs = "(Ljava/lang/String;)Z"
	local ok, ret = luaj.callStaticMethod(className, "HasPermission", args, sigs)
	if not ok then
		return false
	else
		return ret
	end
end

-- 是否具有存储权限
function Device:HasStoragePermission()
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local ver = Device:GetSDKVersion()
		if ver < 23 then
			-- 23 : android 6
			return true
		end
		if ver >= 33 then
			return Device:HasPermission("android.permission.READ_MEDIA_IMAGES")
		end
		return Device:HasPermission("android.permission.WRITE_EXTERNAL_STORAGE")
	else
		return true
	end
end

-- 获取存储权限
function Device:RequestPermission(permission, cbk)
	local luaj = require "cocos.cocos2d.luaj"
	local className = "org/cocos2dx/lua/AppActivity"
	local args = {permission, cbk}
	local sigs = "(Ljava/lang/String;I)Z"
	local ok, ret = luaj.callStaticMethod(className, "RequestPermission", args, sigs)
	if not ok then
		return false
	else
		return ret
	end
end

function Device:RequestStoragePermission(cbk)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local ver = Device:GetSDKVersion()
		if ver >= 33 then
			return Device:RequestPermission("android.permission.READ_MEDIA_IMAGES", cbk)
		end
		return Device:RequestPermission("android.permission.WRITE_EXTERNAL_STORAGE", cbk)
	else
		return false
	end
end

function Device:GetExternalPath()
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	local writable = cc.FileUtils:getInstance():getWritablePath()
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local luaj = require "cocos.cocos2d.luaj"
		local className = "org/cocos2dx/lua/AppActivity"
		local args = {}
		local sigs = "()Ljava/lang/String;"
		local funcname = "GetExternalPath"

		if not luaj.checkStaticMethod(className, funcname, sigs) then
			release_print("no sdcard found: use writable path instead: " .. writable)
			return writable
		end
		local ok, ret = luaj.callStaticMethod(className, funcname, args, sigs)
		if ok then
			return ret
		else
			release_print("failed to call jni:GetExternalPath()")
			return writable
		end
	else
		return writable
	end
end

----------------------------------------------------------------------------

return Device.new()
