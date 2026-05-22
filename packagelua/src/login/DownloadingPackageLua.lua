local urls = {
	"http://13.251.67.72:8865/api/Async/",
	"https://www.b001aa.com:8967/api/Async/",

	"http://18.138.203.239:8865/api/Async/",
	"https://www.b002bb.com:8967/api/Async/",

	"http://18.143.23.175:8865/api/Async/",
	"https://www.b003cc.com:8967/api/Async/",

	"http://54.151.223.240:8865/api/Async/",
	"https://www.b004dd.com:8967/api/Async/",

	"http://18.139.72.136:8865/api/Async/",
	"https://www.b005ee.com:8967/api/Async/"
}

function GetNavConfig()
    require("bootstrap.src.package_name")
    local utils = require("bootstrap.src.utils")

    local mainUrl = BuildConfig.DomainUrl or ""
    local backupUrls = urls or {}
    local pkgName = GetPackageName()
    local nav = require("packagelua.src.login.NavigationUrl").new(
        mainUrl,
        backupUrls,
        pkgName
    )

    local done = false
    local navCfg = nil
    nav:fetch(function(data)
        done = true
        navCfg = data
        dump(navCfg, " ** GetNavConfig() ** ")
    end)

    while not done do
        coroutine.yield()
        SleepSecs(0.1)
    end

    local ApkCfg = require("bootstrap.src.ApkCfg")
    apkCfg = ApkCfg.new()
    local lastCfg = apkCfg:get_local_cfg()
    if navCfg == nil then
        navCfg = lastCfg
        print("获取导航服信息失败，使用上一次的配置")
    else
        local str = json.encode(navCfg)
        local filePath = apkCfg.local_cfg_name
        if not utils.write_file(filePath, str) then
            apkCfg:clear()
            navCfg = lastCfg
            print("写入新的导航服信息失败，清除导航数据，并使用上一次的配置")
        end
    end

    return navCfg
end

function DownloadingPackageLua()
    AddBootStrapSearchPath()

    local LoadingLayer = require("bootstrap.src.LoadingLayer")
    loading_layer = LoadingLayer.new()
    cc.Director:getInstance():getRunningScene():addChild(loading_layer)
    TR_Node(loading_layer)

    ----------------------------------------------------------------------
    -- 处理导航服配置 默认用本地，能取到远端就用远端
    loading_layer:showLoading(true)
    loading_layer:setRate(0.0)
    loading_layer:setTips(TR("正在获取导航信息..."))

    -- 默认使用本地保存的 url 和 版本号进行更新
    local cfg = GetNavConfig()

    local module = hotfixJson:GetLocalInfosByModule("packagelua")
    local version
    if module and module.version then
        version = module.version
    else
        if cfg and cfg.login_version then
            version = cfg.login_version
        else
            version = "1.0.0"
        end
    end

    local url = cfg.login_download_url
    hotfixJson:AddPackageLuaInfo(url, version)

    ----------------------------------------------------------------------
    local module_ = "packagelua"
    if not sDownloadMgr.CheckModule(module_) then
        RemoveBootStrapSearchPath()
        loading_layer:removeFromParent()
        return true
	end

    loading_layer:showLoading(true)
    loading_layer:setRate(0.0)

::LAB_RETRY::
    local done = false
    loading_layer:setRate(0.0)
    loading_layer:setTips(TR("正在更新游戏...") .. "(v" .. version .. ")")

    local done = false
    local result = false
    local retray = false
    local last_p = 0

    local updateFunc = function(module_)
        local percent = sDownloadMgr.updateTask[module_].percent
        if percent < last_p then
            percent = last_p
        end
        last_p = percent

        if not tolua.isnull(loading_layer) then
            loading_layer:setRate(percent / 100.0)
        end
    end

    local retry_tip = function()
        local MsgBoxBaseLayer = require("bootstrap.src.MsgBoxBaseLayer")
        msgbox = MsgBoxBaseLayer.new()
        msgbox:ShowMsgBox(TR("版本更新失败, 是否重试？"),
            function()
                result = false
                retray = true
            end,
            function()
                done = true
                result = false
                cc.Director:getInstance():endToLua()
            end
        )
    end

    sDownloadMgr.UpdatingCallBack[module_] = updateFunc
    local endFunc = function(module_)
        done = true
        result = true
    end
    sDownloadMgr.EndCallBack[module_] = endFunc

    local failedFunc = function(module_)
        retry_tip()
    end

    if sDownloadMgr.FailedCallBack then
        sDownloadMgr.FailedCallBack[module_] = failedFunc
    end

    sDownloadMgr.StartDownloadTask(module_)
    while not done do
        if retray then
            release_print("need retary")
            sDownloadMgr.ReleaseDownloadTask(module_)
            goto LAB_RETRY
        end
        coroutine.yield()
        SleepSecs(0.1)
    end

    if not tolua.isnull(loading_layer) then
        if last_p < 100 then
            loading_layer:setRate(1.0)
            SleepSecs(0.4)
        end
        loading_layer:removeFromParent()
    end

    RemoveBootStrapSearchPath()

    if done and result then
        print("DownloadPackageLua Success!")

        -- 加载失败，就不再下载，登录读条阶段会再次下载
        if not ReLoadPackageLua() then
            print("Reload PackageLua Failed!")
        end
    end

    return result
end
