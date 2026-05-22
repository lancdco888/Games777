local hotfixJson = class("hotfixJson")
local fileUtils = cc.FileUtils:getInstance()

function hotfixJson:ctor()
    -- 当前起始 url, 包含 RESOURCE_BRANCH 的路径, / 结尾
    self.assets_url = ""

    -- 本地热更新配置
    self.local_infos = {}

    -- 服务器传来的热更新配置
    self.server_infos = {}

    -- hotfix.json 存储路径
    self.hotfixJsonPath = fileUtils:getWritablePath() .. "/hotfix.json"

    self:LoadLocalInfos()
end

-- 本地更新配置读取到内存
function hotfixJson:LoadLocalInfos()
    self.local_infos = {}

    if fileUtils:isFileExist(self.hotfixJsonPath) then
        local hotfixJson = fileUtils:getStringFromFile(self.hotfixJsonPath)
        self.local_infos = json.decode(hotfixJson) or {}
    end
end

-- 服务器配置缓存到内存
function hotfixJson:LoadServerJson(json_)
    if not json_ then
        print("服务器热更配置错误")
        return
    end

    local data_ = json.decode(json_)
    local branch_data = self:GetBranchData(data_)
    self:UpdateServerModules(branch_data)
end

function hotfixJson:AddPackageLuaInfo(url, version)
    self:SetAssetsUrl(url)

    self.server_infos["packagelua"] = {
        url = self.assets_url,
        version = version,
        downloadpath = "src/packagelua",
        is_zip = true,
        zip_dir_name = "first_packagelua",
        dir_name = "packagelua"
    }

    self.server_infos["first_packagelua"] = {
        url = self.assets_url,
        version = "1.0.1"
    }

    dump(self.server_infos, "AddPackageLuaInfo")
end

-- 更新本地更新配置
function hotfixJson:SaveLocalInfo()
    local file = io.open(self.hotfixJsonPath, "w+")
	if (file ~= nil) then
		file:write(json.encode(self.local_infos))
		file:close()
	end
end

-- 更新内存中的本地配置表
-- module_: 模块名  例如 hall,x86_soUpdate
function hotfixJson:UpdateLocalInfos(module_)
    local local_info = self.local_infos[module_]
    if not local_info then
        local_info = {}
        self.local_infos[module_] = local_info
    end

    for k,v in pairs(self.server_infos[module_]) do
        local_info[k] = v

        if k == "version" then
            local hotfix_version = v
            local manifest_version = self:GetLocalVersionForModule(module_)
            if manifest_version then
                if manifest_version ~= hotfix_version then
                    release_print(
                        string.format("not the same version for %s: hotfix %s, manifest %s", module_, hotfix_version, manifest_version))
                end
                local_info.version = manifest_version
            end
        end
    end

    self:SaveLocalInfo()
end

function hotfixJson:GetLocalVersionForModule(module_)
    local info = self.server_infos[module_]
    if not info then
        return nil
    end

	local path = downloader_def.WritablePath .. info.downloadpath .. "/"
	local pr_manifest = path .. "project.manifest"
	if not cc.FileUtils:getInstance():isFileExist(pr_manifest) then
		print("hotfixJson:GetLocalVersionForModule() module is not exists:" .. tostring(module_))
        return nil
    end

	local data_ = cc.FileUtils:getInstance():getStringFromFile(pr_manifest)
	local jsondata = json.decode(data_)

    if jsondata and jsondata.version ~= nil then
        return jsondata.version
    else
        return "0.0.9"
    end
end

-- 更新本地更新配置
function hotfixJson:UpdateHotfixJson()
    local file = io.open(self.hotfixJsonPath,"w+")
	if (file ~= nil) then
		file:write(json.encode(self.local_infos))
		file:close()
	end
end

-- 通过模块名拿到对应模块的本地配置
-- module_: 模块名
function hotfixJson:GetLocalInfosByModule(module_)
    local moduleInfos = self.local_infos[module_] or {}
    return moduleInfos
end

-- 通过模块名拿到对应模块的服务器配置
-- module_: 模块名
function hotfixJson:GetServerInfosByModule(module_)
    local moduleInfos = self.server_infos[module_] or {}
    return moduleInfos
end

function hotfixJson:GetCheckedMd5(module_)
    local info = self:GetLocalInfosByModule(module_)
    if info and info.is_checked_md5 then
        return true
    else
        return false
    end
end

function hotfixJson:GetIsZipDone(module_)
    local info = self:GetLocalInfosByModule(module_)
    if info and info.is_zipdone then
        return true
    else
        return false
    end
end

function hotfixJson:SetZipDone(module_)
    self.server_infos[module_].is_zipdone = true
    self:SaveLocalInfo()
end

function hotfixJson:ClearZipDone(module_)
    if self.local_infos[module_] then
        if self.local_infos[module_].is_zipdone ~= false then
            self.local_infos[module_].is_zipdone = false
            self:SaveLocalInfo()
        else
            print("hotfixJson: no need ClearZipDone.")
        end
    end
end

function  hotfixJson:SetCheckedMd5(module_, bChecked)
    local info = self:GetLocalInfosByModule(module_)
    if info then
        info.is_checked_md5 = bChecked
        self:SaveLocalInfo()
    end
end

function hotfixJson:UpdateServerModules(data)
    self:CheckAssetsUrl()

    local modules = data.modules or {}
    for name_,module in pairs(modules) do
        self:UpdateServerModule(name_, module.version)
    end
end

function hotfixJson:UpdateServerModule(name_, version)
    local new_modules = {}

    local url = self.assets_url
    local module = {}
    module.url = url
    module.version = version or "1.0.1"
    if not string.find(name_, "first_") then
        if name_ == "fish_common" then
            module.downloadpath = "src/fish2/res"
        else
            module.downloadpath = "src/" .. name_
        end

        module.is_zip = true
        module.zip_dir_name = "first_" .. name_
        module.dir_name = name_
        new_modules["first_" .. name_] = {
            url = url,
            version = "1.0.1"
        }
    end
    new_modules[name_] = module
    for k, v in pairs(new_modules) do
        self.server_infos[k] = v
    end
end

-- 检查模块更新
function hotfixJson:CheckModule(module_)
	if NOT_NEED_DOWNLOAD then
		return false
	end

    local s = tostring(module_)
    if  s:match("^fish_10[9]$")      -- 109
        or s:match("^fish_11[0-9]$")    -- 110–119
        or s:match("^fish_12[0-4]$")    -- 120–124
    then
        print("match 109 - 124, 不更新")
        return false
    end

	local localInfo = self:GetLocalInfosByModule(module_)
	local serverInfo = self:GetServerInfosByModule(module_)
	if next(localInfo) == nil and next(serverInfo) == nil then
		print(string.format( "\n---->>>>还没有这个配置:%s", module_))
        return true
	end

    if localInfo and serverInfo and localInfo.version and serverInfo.version then
        local num_local = string.match(localInfo.version, "%d+$")
        local num_server = string.match(serverInfo.version, "%d+$")
        if num_local and num_server and tonumber(num_local) > tonumber(num_server) then
            -- 本地版本领先，不需要更新
            return false
        end
    end

	if (not localInfo.version and serverInfo.version)
		or localInfo.version ~= serverInfo.version then
		return true
	else
		if not self:GetCheckedMd5(module_) then
			print("md5码对比尚未完成，需要再次更新:", module_)
			return true
		else
			return false
		end
	end
end

----------------------------------------------------------------------------

_G.last_assets_url = ""

function hotfixJson:SetAssetsUrl(url)
    local assets_url
    if BuildConfig and BuildConfig.RESOURCE_BRANCH and BuildConfig.RESOURCE_BRANCH ~= "" then
        assets_url = url .. BuildConfig.RESOURCE_BRANCH .. "/"
    else
        assets_url = url
    end
    self.assets_url = assets_url

    _G.last_assets_url = assets_url
end

function hotfixJson:CheckAssetsUrl()
    if self.assets_url and self.assets_url ~= "" then return end

    if _G.last_assets_url and _G.last_assets_url ~= "" then
        self.assets_url = _G.last_assets_url
        return
    end

    local packagelua = self.server_infos["packagelua"]
    if packagelua and packagelua.url and packagelua.url ~= "" then
        self.assets_url = packagelua.url
        return
    end

    if ConfigParam.AssetsUrl and ConfigParam.AssetsUrl ~= "" then
        self:SetAssetsUrl(ConfigParam.AssetsUrl)
        return
    end
end

function hotfixJson:GetBranchData(data)
    local modules = nil
    if BuildConfig and BuildConfig.RESOURCE_BRANCH and BuildConfig.RESOURCE_BRANCH ~= "" then
        if not data.branches then
            return {}
        end

        local branch_data = data.branches[BuildConfig.RESOURCE_BRANCH]
        return branch_data or {}
    end

    return data or {}
end

----------------------------------------------------------------------------

return hotfixJson
