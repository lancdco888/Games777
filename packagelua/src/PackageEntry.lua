function gUpdate()
	gNet:Update()
	coroutine.resume(gNetCoro)
    gUpdates_Exec()
	goexec()
	gNet:Update()
end

function InitRequires()
    require("packagelua.src.BuildConfig")

    -- 原生相关函数
    Device = require("packagelua.src.base.Device")
    Device:setScreenType(Device.H_Screen_Type)

    require("packagelua.src.const_def")
    --
    Dispatcher = require("packagelua.src.base.Dispatcher")
    -- 网络组件
    require "packagelua.src.base.g_net"
    -- 延迟函数
    require "packagelua.src.base.g_funcs"
    -- 界面状态
    require "packagelua.src.base.g_states"
    -- 定时器
    require "packagelua.src.base.g_updates"
    -- 设置相关类
    SettingData = require("packagelua.src.data.SettingData")
    -- 基础Tools 自己用
    Tools_Base      = require("packagelua.src.base.Tools_Base")
    -- 需要做 bootstrap 兼容的部分
    require("packagelua.src.bootstrap.init")

    -- 声音组件
    require "packagelua.src.base.g_sound"
    -- 弹窗管理
    BottomLayer     = require("packagelua.src.base.BottomLayer").new()
    -- 登录和选择语言界面
    LanguageLayer   = require("packagelua.src.login.LanguageLayer")

    require "packagelua.src.downloader.init"
    sDownloadMgr.Init()
    hotfixJson = require("packagelua.src.downloader.hotfixJson").new()
end

function add_debug_button()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()

    local texture = "packagelua/res/studio/common/btn_1.png"
    local debugBtn = ccui.Button:create(texture, texture)
    debugBtn:setScale9Enabled(true)
    -- debugBtn:setContentSize(cc.size(200, 40))

    local margin = 20
    debugBtn:setPosition(
        origin.x + debugBtn:getContentSize().width / 2 + margin,  -- 左边
        origin.y + debugBtn:getContentSize().height / 2 + 120  -- 下边
    )
    debugBtn:setTitleText("DEBUG")
    debugBtn:setTitleFontSize(20)
    debugBtn:setTitleColor(cc.c3b(255, 255, 255))

    Tools_Base.AddClickEvent(debugBtn, function()
        local DebugLayer = require("packagelua.src.msg.DebugLayer").new()
        DebugLayer:Show()
    end)

    cc.Director:getInstance():getRunningScene():addChild(debugBtn, 9999)
end

local function main()
    -- 把定时器提前
	mainLoopCallback(gUpdate)

    InitRequires()

    start_log()

    if BuildConfig and BuildConfig.Debug == "TRUE" then
        pcall(add_debug_button)
    end

    -- 兼容旧生成物代码
    List_Int32_ = {
        Create = function() return {} end
    }

    go(function()
        PreSetLanguage()
        if not NOT_NEED_DOWNLOAD then
            PackageluaAddSearchPath()
			if not DownloadLogin() then
				Tools_Base.ShowMsgBox(TR("版本更新失败"),
					function()
						cc.Director:getInstance():endToLua()
					end
				)
				return
			end
        end

    	ResetTranslator()

        ChooseLanguage()
        PackageluaAddSearchPath()

        -- 基础PKG
        require "packagelua.src.base.generic"
        require "packagelua.src.base.class_def"
        require "packagelua.src.base.client_login"

        -- 登录数据
        LoginData = require("packagelua.src.data.LoginData").new()

        -- facebook
        FacebookSingle = require("packagelua.src.login.FacebookSingle").new()

        LoginLayer      = require("packagelua.src.login.LoginLayer")
        BottomLayer:Show(LoginLayer)
    end)
end

function DownloadLogin()
    require("packagelua.src.login.DownloadingPackageLua")

    if not DownloadingPackageLua() then
        return false
    end

    return true
end

-- 更新资源之后重新刷新 packagelua 模块
function ReLoadPackageLua()
    local chunkFile = cc.FileUtils:getInstance():fullPathForFilename("src/packagelua/src.chunk.zip")

    if LoadChunksFromZIP and chunkFile ~= "" then
        LoadChunksFromZIP(chunkFile)
        print("Loading Chunk:" .. chunkFile)
    end

    for path_,__ in pairs(package.loaded) do
        if string.find(path_, "packagelua.src.") then
            package.loaded[path_] = nil
        end
    end

    require "packagelua.src.base.generic"
    require "packagelua.src.base.class_def"
    require "packagelua.src.base.client_login"
    require("packagelua.src.const_def")
    Device = require("packagelua.src.base.Device")
    Tools_Base      = require("packagelua.src.base.Tools_Base")

    require "packagelua.src.downloader.init"
    sDownloadMgr.Init()
    hotfixJson = require("packagelua.src.downloader.hotfixJson").new()
    return true
end

function PreSetLanguage()
    if #ConfigParam.Language <= 1 then
        SettingData.language = Tools_Base.Name2Id(ConfigParam.Language[1] or "en")
        if not SettingData.language then
            SettingData.language = Tools_Base.Name2Id("en")
        end
        cc.UserDefault:getInstance():setIntegerForKey("language", SettingData.language)
    else
        SettingData.language = cc.UserDefault:getInstance():getIntegerForKey("language", 0)
    end
end

--选择语言界面
function ChooseLanguage()
    if SettingData.language == 0 then
        local layer = BottomLayer:Show(LanguageLayer)
        local done = false
        layer:SetDoneCbk(function()
            done = true
        end)
        while not done do
            yield()

        end
        local lang = layer:GetSelLangId()

        SettingData.language = lang
        cc.UserDefault:getInstance():setIntegerForKey("language", lang)
    end
end

function PackageluaAddSearchPath()
    local fileUtils = cc.FileUtils:getInstance()
    fileUtils:purgeCachedEntries()

    local lang = "en"
    local langInfo = Tools_Base.Languages[SettingData.language]
    if langInfo then lang = langInfo.name or "en" end

    lang = lang == "cn" and "" or  lang .. "/"
    -- 大厅路径
	fileUtils:addSearchPath(const_def.DefaultPath .. "src/hall/res/" .. lang, true)
	fileUtils:addSearchPath(const_def.WritablePath .. "src/hall/res/" .. lang, true)
	fileUtils:addSearchPath(const_def.DefaultPath .. "src/hall/res/studio/" .. lang, true)
	fileUtils:addSearchPath(const_def.WritablePath .. "src/hall/res/studio/" .. lang, true)

	-- package路径
	fileUtils:addSearchPath(const_def.DefaultPath .. "src/packagelua/res/" .. lang, true)
	fileUtils:addSearchPath(const_def.WritablePath .. "src/packagelua/res/" .. lang, true)
	fileUtils:addSearchPath(const_def.DefaultPath .. "src/packagelua/res/studio/" .. lang, true)
	fileUtils:addSearchPath(const_def.WritablePath .. "src/packagelua/res/studio/" .. lang, true)
    if G_SetExchangeSearchPaths then
        G_SetExchangeSearchPaths()
    end
    ResetTranslator()
	TR_Node(cc.Director:getInstance():getRunningScene())

    SettingData:Dispatch()
end

cclog = function(...)
    print(string.format(...))
end

local old_print = print

-- 最后几行日志
last_logs = {}
local log_queue = {}
print = function (...)
    if not ... then return end
    local time = os.date("[%Y/%m/%d %H:%M:%S]", os.time())

    local args = {...}
    local s = ""
    for __ , v in ipairs(args) do
        s = s .. tostring(v)
    end

    table.insert(last_logs, s)
    if #last_logs > 1000 then
        table.remove(last_logs, 1)
    end
    table.insert(log_queue, s)

    s = time .. s
    old_print(s)
end

function get_log_path()
    Device = require("packagelua.src.base.Device")
    if Device:HasStoragePermission() then
        local sdcard_dir =  Device:GetExternalPath()
        local pkg_name = GetPackageName()
        return string.format(
            "%s/%s_GAME_LOG.txt",
            sdcard_dir,
            tostring(pkg_name)
        )
    else
        return cc.FileUtils:getInstance():getWritablePath().."/GAME_LOG.txt"
    end
end

function start_log()
    go(function()
        local log_file_name = get_log_path()
        local size = io.filesize(log_file_name)
        local log_fp = nil
        local max = 5 * 1024 * 1024
        if size and size > max then
            log_fp = io.open(log_file_name,'w+')
        else
            log_fp = io.open(log_file_name,'a+')
        end

        if log_fp == nil then return end

        while true do
            local written = false
            for __,str_ in ipairs(log_queue) do
                log_fp:write(tostring(str_).."\n")
                written = true
            end
            log_queue = {}
            if written then
                log_fp:flush()
            end
            SleepSecs(0.05)
        end
    end)
end

xpcall(main, __G__TRACKBACK__)
