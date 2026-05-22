--用户本地设置相关数据以及服务器首次返回的数据存储
local SettingData = {}

SettingData.language 	= 1

function SettingData:GetNetworkIP()
    return ConfigParam.loginIp or ""
end

function SettingData:GetNetworkPort()
    return ConfigParam.port or "0"
end

function SettingData:SetNetworkParam(ip, port)
    if ip == nil or ip == "" or port == nil or port == "" or tonumber(port) == nil then
        return false
    end

    ConfigParam.loginIp = tostring(ip)
    ConfigParam.port = tonumber(port) or 0
    return true
end

function SettingData:Dispatch()
	local nodes = {}

	local root_scene = cc.Director:getInstance():getRunningScene()
	root_scene:getChildrenByType("ccui.Button",nodes)
	for _, button in pairs(nodes) do
		local datas = button:getTexturesPath()
		local normalFile = datas[1].file == "" and nil or datas[1].file
		local pressedFile = datas[2].file == "" and nil or datas[2].file
		local disabledFile = datas[3].file == "" and nil or datas[3].file
		button:loadTextures(normalFile,pressedFile,disabledFile)
	end

	nodes = {}
	root_scene:getChildrenByType("ccui.ImageView",nodes)
	for _, image in pairs(nodes) do
		local datas = image:getTexturesPath()
		local file = datas[1].file == "" and nil or datas[1].file
		image:loadTexture(file)
	end

	nodes = {}
	Dispatcher:Dispatch(self)
end

return SettingData
