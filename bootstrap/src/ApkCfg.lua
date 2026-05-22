local ApkCfg = class("ApkCfg")

function ApkCfg:ctor()
    local dir = cc.FileUtils:getInstance():getWritablePath() .. "/download/"
    self.local_cfg_name = dir .. "apk.cfg"
    if not cc.FileUtils:getInstance():isDirectoryExist(dir) then
        cc.FileUtils:getInstance():createDirectory(dir)
    end
    self.remote_urls = {
        BuildConfig.DomainUrl or ""
    }

    local backups = BuildConfig.BackupNavUrls or {}
    for __,url in pairs(backups) do
        table.insert(self.remote_urls, url)
    end

    for key,url in pairs(self.remote_urls) do
        if string.sub(url, -1) ~= "/" then
            self.remote_urls[key] = url .. "/"
        end
    end
end

function ApkCfg:has_local_cfg()
    return cc.FileUtils:getInstance():isFileExist(self.local_cfg_name)
end

function ApkCfg:clear()
    if self:has_local_cfg() then
        cc.FileUtils:getInstance():removeFile(self.local_cfg_name)
    end
end

function ApkCfg:get_local_cfg()
    if not self:has_local_cfg() then
        return nil
    else
        local file_name = self.local_cfg_name
        local fp = io.open(file_name, "rt")
        if not fp then
            print("open file failed:" .. file_name)
            return nil
        end
        local data_ = fp:read("*a")
        if not data_ then
            print("read file failed:" .. file_name)
            fp:close()
            return nil
        end
        local json = require("json")
        local cfg_ = json.decode(data_)
        fp:close()
        return cfg_
    end
end

local utils = require("bootstrap.src.utils")
function ApkCfg:fetch_remote_cfg(on_success, on_failed)
    utils.go(function()
        local success = self:_fetch(
            self.remote_urls
        )
        if success then
            on_success()
        else
            on_failed()
        end
    end)
end

-- 这个函数是协程方式调用
function ApkCfg:_fetch(urls)
    dump(urls, " ********* urls ********* ")
    for _,url in ipairs(urls) do
        local success = self:_fetch_url(url)
        if success then
            print("fetch apk cfg success")
            return true
        end
    end
    -- 全部没获取到，返回失败
    print("fetch apk cfg failed")
    return false
end

-- 获取某个 url 对应的配置，这个函数是协程方式调用
require("bootstrap.src.package_name")
local utils = require("bootstrap.src.utils")
function ApkCfg:_fetch_url(url)
    local pkg_name = GetPackageName()
    assert(pkg_name ~= nil and pkg_name ~= "")
    local full_url = url .. pkg_name

    local done = false
    local result = true
    do  -- http request 版本
        utils.req_http_data(full_url,
            function(data_) -- on success
                -- 空字符串代表没找到
                --下载成功
                print("download success:" .. data_)
                done = true
                
                -- 简单检测返回的数据结构
                local json = require("json")
                local ok, obj = pcall(json.decode, data_)
                if not ok or type(obj) ~= "table" then
                    print("invalid data for apkcfg:" .. tostring(data_))
                    result = false
                    return
                end

                if not obj.login_ip or not obj.port or not obj.login_download_url or not obj.default_language then
                    print("invalid data for apkcfg:" .. tostring(data_))
                    result = false
                    return
                end
                -------------------------------------------------------------------------------------------------
                
                local fp = io.open(self.local_cfg_name, "wb")
                if not fp then
                    print("open file failed:" .. self.local_cfg_name)
                    result = false
                    return
                end

                fp:write(data_)
                fp:close()
                result = true
            end,
            function()  -- on failed
                print("download failed:" .. full_url)
                done = true
                result = false
            end
        )
    end

    while not done do
        coroutine.yield()
    end
    return result
end

-- cfg 为 pkg_cfg 格式，见 顶部
function ApkCfg:domain_to_config_param(cfg)
    local param = {}
    param.loginIp = cfg.login_ip
    param.port = cfg.port
    param.AssetsUrl = cfg.login_download_url
    param.default_Language = cfg.default_language
    param.desc = cfg.desc
    param.Region = cfg.region
    param.Language = string.split(cfg.language, ",")
    param.IsGoogle = ( tostring(cfg.class) == "1" )
    return param
end

return ApkCfg
