
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

    require("packagelua.src.base.generic")
    require("packagelua.src.base.class_def")
    require("packagelua.src.base.client_login")
    require("packagelua.src.bootstrap.callstack")
    require("packagelua.src.const_def")

    Device = require("packagelua.src.base.Device")
    Tools_Base      = require("packagelua.src.base.Tools_Base")

    require("packagelua.src.downloader.init")
    sDownloadMgr.Init()
    hotfixJson = require("packagelua.src.downloader.hotfixJson").new()
    return true
end
