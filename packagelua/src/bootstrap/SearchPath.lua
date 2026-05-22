search_paths = {}

function AddBootStrapSearchPath()
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

function RemoveBootStrapSearchPath()
    for _,p in ipairs(search_paths) do
        cc.FileUtils:getInstance():removeSearchPath(p)
    end
end
