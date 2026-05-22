-- 使用这个特性之前一定要记得先加载这个脚本
local FileUtils = cc.FileUtils:getInstance()
local defaultSearchPath = FileUtils:getSearchPaths()

-- 添加一个搜索路径
-- 优化了搜索文件和文件夹的缓存问题(添加前clear)
-- 优化了添加重复路径,会将路径提到最优先
local add_searchPath = cc.FileUtils:getInstance().addSearchPath
function FileUtils:addSearchPath(path,_bool)
    -- print(path,debug.traceback())
    FileUtils:purgeCachedEntries()
    if path:sub(-1) ~= "/" and path:sub(-1) ~= "\\" then
        path = path .. "/"
    end
    add_searchPath(self,path,_bool)
end

-- 删除一个搜索路径
-- 遍历删除所有跟path 一样的路径
local remove_searchPath = cc.FileUtils:getInstance().removeSearchPath
function FileUtils:removeSearchPath(path)
    if path:sub(-1) ~= "/" and path:sub(-1) ~= "\\" then
        path = path .. "/"
    end
	remove_searchPath(self,path)
end

-- 设置为默认搜索路径
function FileUtils:lua_setDefaultSearchPath()
    FileUtils:setSearchPaths(defaultSearchPath)
end