
local bootstrap = class("bootstrap")
local utils = require("bootstrap.src.utils")
require("bootstrap.src.LuajEntry")
require("bootstrap.src.json_patch")
import(".callstack")

function bootstrap:ctor()
    self.loading_layer = nil
end

function bootstrap:main()
    require("bootstrap.src.Translator.init")
    ResetTranslator()
    self:add_search_paths()
    self:game_main()
end

local utils = require("bootstrap.src.utils")
function bootstrap:game_main()
    local scene = cc.Scene:create()
    _G.root_scene = scene
    cc.Director:getInstance():runWithScene(scene)

    --启动场景
    scene:enableNodeEvents()
    scene.onEnter = function()
        utils.go(
            function()
                self:start()
            end
        )
    end
end

local ApkCfg = require("bootstrap.src.ApkCfg")
function bootstrap:start()
    -- 使用打包工具生成的配置信息，统一都到这一个 json
    BuildConfig = {}
    local cfg_path_ = "bootstrap/src/BuildConfig.json"
    if cc.FileUtils:getInstance():isFileExist(cfg_path_) then
        local str_ = cc.FileUtils:getInstance():getStringFromFile(cfg_path_)
        local json = require("json")
        BuildConfig = json.decode(str_)
    end

    local apk_cfg = ApkCfg.new()
    
    -- 本地无包配置
    local done = false
    if not apk_cfg:has_local_cfg() then
        print("本地无 apkcfg, 从远端获取...")
        -- 显示 loading
        self:show_loading_layer()
        self.loading_layer:showLoading(true)
        self.loading_layer:setRate(0.0)
        self.loading_layer:setTips(TR("正在获取导航信息..."))

        local start_time = os.time()
        apk_cfg:fetch_remote_cfg(
            function()      -- success
                done = true
            end,
            function()      -- failed
                self.loading_layer:setTips(TR("获取导航信息失败"))
                self:tip_retry(TR("获取导航信息失败, 是否重试？"))
            end
        )
    else
        done = true
    end
    
    -- 等待获取完成
    while not done do
        coroutine.yield()        
    end

    local cfg = apk_cfg:get_local_cfg()
    if not cfg then
        -- 清除本地记录重新开始
        apk_cfg:clear()
        self:show_loading_layer()
        self.loading_layer:setTips(TR("获取导航信息失败"))
        self:tip_retry(TR("获取导航信息失败, 是否重试？"))
        return
    end
    dump(cfg, " ************* ApkCfg ***************** ")

    -- 转换成本地使用的
    ConfigParam = apk_cfg:domain_to_config_param(cfg)

    self:remove_loading_layer()

    -- 更新成当前语言
    self:remove_search_paths()
    self:add_search_paths()
    ResetTranslator()


    -- 添加下载的基础搜索路径，热更新的package里面的lua优先加载
    local basicPath = cc.FileUtils:getInstance():getWritablePath() .. "download/"
    cc.FileUtils:getInstance():addSearchPath(basicPath .. "src/", true)
    self:remove_search_paths()

    local chunkFile = cc.FileUtils:getInstance():fullPathForFilename("src/packagelua/src.chunk.zip")
    if LoadChunksFromZIP and chunkFile ~= "" then
        LoadChunksFromZIP(chunkFile)
        print("Loading Chunk:" .. chunkFile)
    end

    require("packagelua.src.PackageMain")
end

function bootstrap:show_loading_layer()
    if self.loading_layer then return end
    local LoadingLayer = require("bootstrap.src.LoadingLayer")
    self.loading_layer = LoadingLayer.new()
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(self.loading_layer)
end

function bootstrap:remove_loading_layer()
    if not self.loading_layer then return end
    self.loading_layer:removeFromParent()
    self.loading_layer = nil
end

-- 重试策略，简单的全部步骤重试
function bootstrap:tip_retry(msg)
    utils.show_msgbox(
        msg,
        function()
            utils.go(
                function()
                    self:start()
                end
            )
        end,
        function()
            cc.Director:getInstance():endToLua()
        end
    )
end

local search_paths = {}
function bootstrap:add_search_paths()
    search_paths = {}
    local df = cc.FileUtils:getInstance():getDefaultResourceRootPath()
    table.insert(search_paths, df .. "src/bootstrap/res/")
    local basicPath = cc.FileUtils:getInstance():getWritablePath() .. "download/"
    table.insert(search_paths, basicPath .. "src/bootstrap/res/")
    local lang_ = GetLang()
    table.insert(search_paths, df .. "src/bootstrap/res/" .. lang_ .. "/")
    table.insert(search_paths, basicPath .. "src/bootstrap/res/" .. lang_ .. "/")

    for _,p in ipairs(search_paths) do
        cc.FileUtils:getInstance():addSearchPath(p, true)
    end
end

function bootstrap:remove_search_paths()
    -- 清理多余的serch path
    for _,p in ipairs(search_paths) do
        cc.FileUtils:getInstance():removeSearchPath(p)
    end
end

xpcall(
    function()
        bootstrap.new():main()
    end,
    __G__TRACKBACK__
)
