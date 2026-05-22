
local DownloadTask = class("DownloadTask")

function DownloadTask:ctor(manifest,downloadPath,codejson, tag, downloadArgs)
	self.fileOlnyOne = false
	-- todo 加一个单个文件的标识
	
	if (string.find(downloadArgs._dirName,"first") ~= nil
		or string.find(manifest, "first") ~= nil
		or string.find(downloadArgs._dirName,"soUpdate") ~= nil) then
		self.fileOlnyOne = true
	end
	dump(downloadArgs,"downloadArgs")
	
    if downloadArgs then
		self.assetM = cc.AssetsManagerEx:create(manifest, downloadPath, downloadArgs._packageUrl,downloadArgs._remoteManifestUrl,downloadArgs._remoteVersionUrl)
	else
		self.assetM = cc.AssetsManagerEx:create(manifest, downloadPath)
	end
	self.codejson = codejson
	self.tag = tag
	self.assetM:retain()
	
	self.assetMListener = cc.EventListenerAssetsManagerEx:create(self.assetM, function(...)
							self:OnAssetsMEvent(...)
						end)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.assetMListener, -1)
	
	self.downloadFailTime = 0
	self.state = downloader_def.UpdateInit
	self.percent = -1
	self.errorCode = -1
end

function DownloadTask:CheckUpdate()
	self.state = downloader_def.Checking
	self.assetM:checkUpdate()
end

function DownloadTask:Update()
	self.state = downloader_def.Updating
	self.assetM:update()
end

function DownloadTask:getDownloadUnits()
	return self.assetM:getDownloadUnits()
end

function DownloadTask:Exit()
	if self.assetM then
		self.assetM:release()
		self.assetM = nil
	end
	
	if self.assetMListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.assetMListener)
		self.assetMListener = nil
	end
end

function DownloadTask:OnAssetsMEvent(event)
	local evtCode = event:getEventCode()
	if(evtCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST)then
		self.errorCode = downloader_def.Update_NoManifest
	elseif(evtCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST)then
		self.errorCode = downloader_def.Update_ErrorDlMF
	elseif(evtCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST)then
		self.errorCode = downloader_def.Update_ErrorPMF
	elseif(evtCode == cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND)then
		self.errorCode = downloader_def.Update_NewVersion
	elseif(evtCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE)then
		self.errorCode = downloader_def.Update_NoUpdate
	elseif(evtCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION)then
		local custonID = event:getAssetId()
		if(custonID ~= "@version" and custonID ~= "@manifest")then
			if (not self.fileOlnyOne) then
				self.percent = event:getPercentByFile()
			else
				self.percent = event:getPercent()
			end
			-- print("percent:", self.percent)
		end
	elseif(evtCode == cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED)then

	elseif(evtCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING)then

	elseif(evtCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED)then
		self.errorCode = downloader_def.Update_Finished
	elseif(evtCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED)then
		if(self.downloadFailTime < 3)then
			self.downloadFailTime = self.downloadFailTime + 1
			self.assetM:downloadFailedAssets()
		else
			self.downloadFailTime = 0
			self.errorCode = downloader_def.Update_Failed
		end
	elseif(evtCode == cc.EventAssetsManagerEx.EventCode.ERROR_DECOMPRESS)then
		self.errorCode = downloader_def.Update_FailedExplode
	elseif (evtCode == cc.EventAssetsManagerEx.EventCode.ERROR_SUCCEEDEXPLODE)then
		
	elseif (evtCode == cc.EventAssetsManagerEx.EventCode.ERROR_STARTEXPLODE) then
		
	end
end

function DownloadTask:ReFreshLua()
	local filePath = cc.FileUtils:getInstance():fullPathForFilename(self.codejson)
	local file = io.open(filePath, "r")
	if (file == nil) then
		return
	end
	local t = file:read("*all")
	file.close()
	local jsonData = json.decode(t)
	local tb = {}
	for k,v in pairs(jsonData) do
		local str = string.sub(k, 5, #k)
		local s = string.gsub(str,"/", ".")
		tb[s] = true
		printf("**********tb:%s",s)
	end
	
	for name,t in pairs(package.loaded)do
		if(tb[name])then
			package.loaded[name] = nil
		end
	end
	
end

return DownloadTask