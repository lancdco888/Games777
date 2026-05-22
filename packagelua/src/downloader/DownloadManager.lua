-- 用于下载处理以及文件损坏对比
--------------新建一个下载用的_localManifest(考虑要不要放在C++里面)----------------

function _G.saveManifest()
	_G.TEMPMANIFEST = cc.FileUtils:getInstance():getWritablePath().."/temp.manifest"
	if not cc.FileUtils:getInstance():isFileExist(TEMPMANIFEST) then
		cc.FileUtils:getInstance():writeStringToFile('{"version" : "0.0.9"}',TEMPMANIFEST)
	end
end

saveManifest()

require("json")
sDownloadMgr ={}

sDownloadMgr.Init = function()
	sDownloadMgr.updateTask = {}					--下载对象集合
	sDownloadMgr.updateState = {}					--下载状态集合
	sDownloadMgr.updateFailTime = {}				--下载失败次数集合
	sDownloadMgr.MD5FailTime = {}					--MD5检测失败次数集合
	sDownloadMgr.updateRecord = {}					--已经检测过或者更新过的游戏记录列表

	sDownloadMgr.isReconnect = false				--后台下载公共资源

	sDownloadMgr.StartCallBack = {}					--回调函数：开始热更新，热更新中，结束热更新
	sDownloadMgr.UpdatingCallBack = {}
	sDownloadMgr.EndCallBack = {}
	sDownloadMgr.FailedCallBack = {}

	sDownloadMgr.ScheduleID = -1					--更新大厅时所用计时器
	sDownloadMgr.reStartApp = false					-- 是否需要重启
	sDownloadMgr.needreload = false					-- 是否需要重载

	sDownloadMgr.InitDownLoad(true)
end

--初始化热更新参数：大厅资源在登录之前进行下载，第一次热更新会走本地相关配置
sDownloadMgr.InitDownLoad = function(isHall)
	if isHall then
		sDownloadMgr.ScheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(sDownloadMgr.GameUpdate, 0.05, false)
	else
		gUpdates_Set("DownloadManager", sDownloadMgr.GameUpdate)
	end
end

sDownloadMgr.ReleaseDownload = function()
	for module_,task in pairs(sDownloadMgr.updateTask)do
		sDownloadMgr.ReleaseDownloadTask(module_)
	end
end

--释放热更新对象
sDownloadMgr.ReleaseDownloadTask = function(module_)
	if sDownloadMgr.updateTask[module_] == nil then
		return
	end
	sDownloadMgr.updateTask[module_]:Exit()
	sDownloadMgr.updateTask[module_] = nil
	sDownloadMgr.updateState[module_] = nil
end

--热更新主循环
sDownloadMgr.GameUpdate = function()
	local state = -1
	for module_, task in pairs(sDownloadMgr.updateTask) do
		if sDownloadMgr.updateState[module_] ~= nil then
			state = sDownloadMgr.updateState[module_]
			sDownloadMgr.HandleUpdateState(task, state)
		end
	end
end

--热更新界面状态处理
sDownloadMgr.HandleUpdateState = function(task, state)
	if task == nil or task.tag == nil then
		return
	end

	local module_ = task.tag
	if sDownloadMgr.updateState[module_] == nil then
		printf("updateState is nil, tag : %d",module_)
		return
	end

	if state == downloader_def.Check_Download then
		if(task.errorCode == downloader_def.Update_NoManifest or task.errorCode == downloader_def.Update_ErrorDlMF or task.errorCode == downloader_def.Update_ErrorPMF)then
			sDownloadMgr.HandleCheckFailed(task)
		elseif(task.errorCode == downloader_def.Update_NewVersion)then
			sDownloadMgr.HandleNewUpdate(task)
		elseif(task.errorCode == downloader_def.Update_NoUpdate)then
			sDownloadMgr.HandleNoUpdate(task)
		end
	elseif state == downloader_def.Update_Download then
		sDownloadMgr.HandleUpdating(task)
	elseif state == downloader_def.Finish_Download then
		sDownloadMgr.HandleUpdateSuccess(task)
	elseif state == downloader_def.Fail_Download then
		sDownloadMgr.HandleUpdateFailed(task)
	elseif state == downloader_def.CheckMD5_Update_File then
		if sDownloadMgr.HandleMD5UpdateFile(task) then
			sDownloadMgr.HandleMD5FileFailed(task)
		else
			sDownloadMgr.HandleMD5FileSuccess(task)
		end
	elseif state == downloader_def.CheckMD5_All_File then
		if sDownloadMgr.HandleMD5AllFile(task) then
			sDownloadMgr.HandleMD5FileFailed(task)
		else
			sDownloadMgr.HandleMD5FileSuccess(task)
		end
	end
end

--处理检测更新失败
sDownloadMgr.HandleCheckFailed = function(task)
	task.errorCode = -1
	local module_ = task.tag

	local times = sDownloadMgr.updateFailTime[module_] or 0
	if times < downloader_def.DownloadTimeout then
		task:CheckUpdate()
		sDownloadMgr.updateFailTime[module_] = times + 1
	else
		release_print("HandleCheckFailed")
		sDownloadMgr.OnDownloadFailed(module_)
	end
end

sDownloadMgr.OnDownloadFailed = function(module_)
	local cbk = sDownloadMgr.FailedCallBack[module_]

    sDownloadMgr.ReleaseDownloadTask(module_)
	if cbk then
		cbk(module_)
    else
		Tools_Base.ShowMsgBox(TR("更新模块失败"))
	end
end

--处理检测到有更新
sDownloadMgr.HandleNewUpdate = function(task)
	local module_ = task.tag

	local func = sDownloadMgr.StartCallBack[module_]
	if func ~= nil then
		func(module_)
	end
	task:Update()
	sDownloadMgr.updateState[module_] = downloader_def.Update_Download
end

--处理无更新,判断是否已经检测过MD5码
sDownloadMgr.HandleNoUpdate = function(task)
	local module_ = task.tag

	local bChecked = hotfixJson:GetCheckedMd5(module_)
	if bChecked then
		local func = sDownloadMgr.EndCallBack[module_]
		if func ~= nil then
			func(module_)
		end
		sDownloadMgr.ReleaseDownloadTask(module_)
	else
		sDownloadMgr.updateState[module_] = downloader_def.CheckMD5_All_File
	end
end

--处理正在更新中
sDownloadMgr.HandleUpdating = function(task)
	local module_ = task.tag
	local func = sDownloadMgr.UpdatingCallBack[module_]
	if func ~= nil then
		func(module_)
	end

	if(task.errorCode == downloader_def.Update_Finished)then
		sDownloadMgr.updateState[module_] = downloader_def.Finish_Download
	elseif(task.errorCode == downloader_def.Update_Failed)then
		sDownloadMgr.updateState[module_] = downloader_def.Fail_Download
	--更新过程中发现无更新、manifest文件出错
	elseif(task.errorCode == downloader_def.Update_NoUpdate or
			task.errorCode == downloader_def.Update_NoManifest or
			task.errorCode == downloader_def.Update_ErrorDlMF or
			task.errorCode == downloader_def.Update_ErrorPMF)then
		sDownloadMgr.updateState[module_] = downloader_def.Check_Download
	end
end

--处理更新失败
sDownloadMgr.HandleUpdateFailed = function(task)
	local module_ = task.tag

	local times = sDownloadMgr.updateFailTime[module_] or 0
	if times < downloader_def.DownloadTimeout then
		sDownloadMgr.updateFailTime[module_] = times + 1
		task:Update()
		sDownloadMgr.updateState[module_] = downloader_def.Update_Download
	else
		sDownloadMgr.updateState[module_] = -1
		release_print("HandleUpdateFailed")
		sDownloadMgr.OnDownloadFailed(module_)
		return
	end
end

--处理更新成功
sDownloadMgr.HandleUpdateSuccess = function(task)
	local module_ = task.tag
	local info = hotfixJson:GetServerInfosByModule(module_)

	if info.is_zip then
		if hotfixJson:GetIsZipDone(module_) then
			print("*************增量更新完成")
			sDownloadMgr.StartCheckFile(module_)
		else
			print("************zip下载完成，开始增量下载")
			hotfixJson:SetZipDone(module_)
			hotfixJson:UpdateLocalInfos(module_)
			hotfixJson:UpdateHotfixJson()
			sDownloadMgr.ReleaseDownloadTask(module_)
			sDownloadMgr.StartDownloadTask(module_)
		end
	else
		sDownloadMgr.StartCheckFile(module_)
	end
end

sDownloadMgr.StartCheckFile = function (module_)
	sDownloadMgr.updateState[module_] = downloader_def.CheckMD5_All_File
end

--处理所有文件MD5对比
sDownloadMgr.HandleMD5AllFile = function(task)
	local module_ = task.tag
	local info = hotfixJson:GetServerInfosByModule(module_)

	local fileUtils = cc.FileUtils:getInstance()
	local pr_manifest, pr_data, jsondata, path = nil
	local path = downloader_def.WritablePath .. info.downloadpath .. "/"

	pr_manifest = path .. "project.manifest"
	local pr_data = fileUtils:getStringFromFile(pr_manifest)
	local jsondata = json.decode(pr_data)

	if jsondata == nil or jsondata.assets == nil then
		if fileUtils:isFileExist(pr_manifest) then
			fileUtils:removeFile(pr_manifest)
		end
		return true
	end

	return sDownloadMgr.CheckAllFileMD5(module_, path, jsondata)
end

--检测所有文件MD5对比
sDownloadMgr.CheckAllFileMD5 = function(module_, path, jsondata)
	local again = false

	--对比下载下来的project.manifest里面的MD5和下载下来的资源生成MD5
	for k,v in pairs(jsondata.assets) do
		local oldMD5 = jsondata.assets[k].md5
		local filePath = string.sub(k, 1,(k:len()-32)) -- 去掉末尾的32位 MD5

		local info = hotfixJson:GetServerInfosByModule(module_)
		local downloadPath = downloader_def.WritablePath .. info.downloadpath .. "/"
		local local_fullpath = downloadPath .. filePath
		local newMD5 = ToLuaFileMD5(local_fullpath)

		if (oldMD5 ~= newMD5) then
			-- 由于文件名加了MD5后缀改成直接删除该条记录
			jsondata.assets[k] = nil
			print(module_ .. ", md5 compare failed:" .. k .. "," .. local_fullpath)
			again = true
		else -- 该文件下载没问题检测
		end
	end
	--对比MD5发现有文件损坏等
	if again then
		sDownloadMgr.RefreshManifest(path, jsondata)
	end
	return again
end

--处理对比MD5码成功
sDownloadMgr.HandleMD5FileSuccess = function(task)
	local module_ = task.tag
	-- 更新本地配置hotfix.json
	hotfixJson:SetCheckedMd5(module_,true)
	hotfixJson:UpdateLocalInfos(module_)
	hotfixJson:UpdateHotfixJson()
	local func = sDownloadMgr.EndCallBack[module_]
	if func ~= nil then
		func(module_)
	end
	sDownloadMgr.ReleaseDownloadTask(module_)
end

--处理对比MD5码失败
sDownloadMgr.HandleMD5FileFailed = function(task)
	local module_ = task.tag
	sDownloadMgr.ReleaseDownloadTask(module_)

	local times = sDownloadMgr.MD5FailTime[module_] or 0
	if times < downloader_def.CheackMD5Time then
		sDownloadMgr.StartDownloadTask(module_)
		sDownloadMgr.MD5FailTime[module_] = times + 1
	else
		sDownloadMgr.OnDownloadFailed(module_)
	end
end

--处理增量更新文件MD5对比
sDownloadMgr.HandleMD5UpdateFile = function(task)
	local module_ = task.tag

	local pr_manifest,pr_data, jsondata, updatedata = nil
	updatedata = task:getDownloadUnits()
	hotfixJson:SetCheckedMd5(module_, false)

	local info = hotfixJson:GetServerInfosByModule(module_)
	local path = downloader_def.WritablePath .. info.downloadpath .. "/"
	local fileUtils = cc.FileUtils:getInstance()

	pr_manifest = path .. "project.manifest"
	local pr_data = fileUtils:getStringFromFile(pr_manifest)
	local jsondata = json.decode(pr_data)

	if jsondata == nil or jsondata.assets == nil then
		if fileUtils:isFileExist(pr_manifest) then
			fileUtils:removeFile(pr_manifest)
		end
		return true
	end

	return sDownloadMgr.CheckUpdateFileMD5(module_, path, jsondata, updatedata)
end

--检测增量更新的文件MD5码
sDownloadMgr.CheckUpdateFileMD5 = function(module_, path, jsondata, updatedata)
	local again = false
	local updatedata_ = json.decode(updatedata) or {}
	if not next(updatedata_) then
		return false
	end
	--对比project.manifest里面的MD5和本地生成MD5
	for k,v in pairs(jsondata.assets) do
		for id,str_path in pairs(updatedata_) do
			if (k == str_path) then
				local oldMD5 = jsondata.assets[k].md5
				local filePath = string.sub(k, 1,(k:len()-32)) -- 去掉末尾的32位MD5

				local newMD5 = ToLuaFileMD5(filePath)
				if (oldMD5 ~= newMD5) then
					--有文件在下载过程中损坏
					-- 由于文件名加了MD5后缀改成直接删除该条记录
					jsondata.assets[k] = nil
					print("Resource download error path:" .. k)
					again = true
				else-- 该文件下载没问题检测
				end
			end
		end
	end

	--对比MD5发现有文件损坏等
	if again then
		sDownloadMgr.RefreshManifest(path,jsondata)
	end

	return again
end

--刷新manifest文件，重新下载
--非zip包第一次下载文件损坏，这个时候只有project.manifest和src下面对应的manifest，需要调低版本，如果版本一样，会继续走src下面的manifest
--ZIP包第一次下载文件损坏，需要修改download目录下对应的manifest
sDownloadMgr.RefreshManifest = function(path, jsondata)
	--重写下载下来生成project.manifest
	local pr_manifest = path .. "project.manifest"
	print(pr_manifest, "pr_manifest")
	local file = io.open(pr_manifest, "w+")
	if (file ~= nil) then
		jsondata.version = "1.0.0"
		file:write(json.encode(jsondata))
		file:close()
	end
end

sDownloadMgr.StartDownloadTask = function(module_)
	if sDownloadMgr.updateTask[module_] ~= nil then
		print("updateTask is updating:" .. module_)
		return false
	end

	local info = hotfixJson:GetServerInfosByModule(module_)
	if not info then
		print("invalid module when StartDownloadTask:" .. module_)
		return false
	end

	return sDownloadMgr.CreateDownLoadTask(module_)
end

--创建热更新对象
sDownloadMgr.CreateDownLoadTask = function(module_)
	if sDownloadMgr.updateTask[module_] ~= nil then
		sDownloadMgr.updateTask[module_]:Exit()
		sDownloadMgr.updateTask[module_] = nil
	end

	local dirname = nil
	local info = hotfixJson:GetServerInfosByModule(module_)
	if not info then
		print("invalid module when CreateDownLoadTask:" .. module_)
		return false
	end

	--zip包没有下载完成
	if info.is_zip and not hotfixJson:GetIsZipDone(module_) then
		os.remove(downloader_def.WritablePath .. info.downloadpath .. "_temp/project.manifest.temp")
		dirname = info.zip_dir_name
	--无需下载zip包或者zip包下载完成
	else
		dirname = info.dir_name
	end

	local downloadArgs = sDownloadMgr.MakeDownloadInfo(dirname)
	if not downloadArgs then
		print("make download args failed.")
		return false
	end

	local manifest = TEMPMANIFEST
	local downloadPath = downloader_def.WritablePath .. info.downloadpath .. "/"
	local code = nil
	local DownloadTask = require "packagelua.src.downloader.DownloadTask"
	sDownloadMgr.updateTask[module_] = DownloadTask:create(manifest, downloadPath, code, module_, downloadArgs)

	-- 由于lua有了更新所以会直接检测到更新
	local func = sDownloadMgr.StartCallBack[module_]
	if func ~= nil then
		func(module_)
	end
	sDownloadMgr.updateTask[module_]:Update()
	sDownloadMgr.updateState[module_] = downloader_def.Update_Download
	return true
end

sDownloadMgr.MakeDownloadInfo = function (dirname)
	local info = hotfixJson:GetServerInfosByModule(dirname)

	local url = info.url
	if not info or not url then
		print("服务器热更新配置没有这个模块:", dirname)
		return nil
	end

	if url:sub(-1) ~= "/" then
		url = url.."/"
	end
    if dirname:sub(-1) == "/" then
        dirname = string.sub(dirname, 1, -2)
    end

    local astc = ""
    if Device and Device.IsAstcSupported and Device:IsAstcSupported() then
        astc = "_astc"
    end

    local _remoteVersionUrl = url .. dirname .. astc ..  "/version.manifest"
	local _remoteManifestUrl = url .. dirname .. astc .. "/project.manifest"
	local _packageUrl = url .. dirname .. astc .. "/assets/"
	local tab = {
		_remoteVersionUrl = _remoteVersionUrl,
		_remoteManifestUrl = _remoteManifestUrl,
		_packageUrl = _packageUrl,
		_dirName = dirname
	}
	return tab
end

-- 检查模块更新
sDownloadMgr.CheckModule = function(module_)
    return hotfixJson:CheckModule(module_)
end
