-- Minimal Cocos2d-x API stubs for headless Lua module testing.
-- Used by scripts/dev/validate.lua; not part of the game runtime.

local workspace = os.getenv("WORKSPACE") or (function()
    local dir = debug.getinfo(1, "S").source:match("@(.+)/")
    return dir:gsub("/scripts/dev$", "")
end)()

package.path = table.concat({
    workspace .. "/?.lua",
    workspace .. "/?/init.lua",
    workspace .. "/cocos/?.lua",
    workspace .. "/cocos/?/init.lua",
    workspace .. "/cocos/cocos2d/?.lua",
    package.path,
}, ";")

-- Cocos runtime globals expected by game code
function cclog(msg)
    io.write(tostring(msg) .. "\n")
end

cc = cc or {}
ccui = ccui or {}

cc.XMLHTTPREQUEST_RESPONSE_JSON = 0

local file_utils = {
    _writable = "/tmp/games777-dev/",
    _files = {},
}

function file_utils:getWritablePath()
    return self._writable
end

function file_utils:isFileExist(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return self._files[path] ~= nil
end

function file_utils:getStringFromFile(path)
    local f = io.open(path, "r")
    if f then
        local data = f:read("*a")
        f:close()
        return data or ""
    end
    return self._files[path] or ""
end

function file_utils:isDirectoryExist(path)
    local ok = os.rename(path, path)
    return ok == true
end

function file_utils:createDirectory(path)
    os.execute('mkdir -p "' .. path .. '"')
    return true
end

function file_utils:removeFile(path)
    os.remove(path)
end

function file_utils:getDefaultResourceRootPath()
    return workspace .. "/"
end

function file_utils:addSearchPath(_path, _front)
end

function file_utils:removeSearchPath(_path)
end

function file_utils:fullPathForFilename(name)
    if file_utils:isFileExist(workspace .. "/" .. name) then
        return workspace .. "/" .. name
    end
    return ""
end

function file_utils:renameFile(from, to)
    return os.rename(from, to) ~= nil
end

cc.FileUtils = {
    getInstance = function()
        return file_utils
    end,
}

cc.Director = {
    getInstance = function()
        return {
            runWithScene = function() end,
            getRunningScene = function()
                return { addChild = function() end }
            end,
            getScheduler = function()
                return {
                    scheduleScriptFunc = function(_, fn)
                        return fn
                    end,
                    unscheduleScriptEntry = function() end,
                }
            end,
            endToLua = function() end,
        }
    end,
}

cc.Scene = {
    create = function()
        return {
            enableNodeEvents = function() end,
            onEnter = nil,
        }
    end,
}

cc.XMLHttpRequest = {
    new = function()
        return {
            responseType = 0,
            timeout = 0,
            readyState = 0,
            status = 0,
            response = "",
            open = function() end,
            registerScriptHandler = function() end,
            send = function() end,
        }
    end,
}

require("cocos.cocos2d.functions")

return {
    workspace = workspace,
    file_utils = file_utils,
}
