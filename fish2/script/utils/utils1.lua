-- utils/utils1.lua
local root = ...

unpack = unpack or table.unpack

string.endsWith = string.endsWith or function(s, suffix)
    return s:sub(-string.len(suffix)) == suffix
end

FF_G.LoadLuaFunc = function(fileName, ...)
    local funcName = root:LoadLuaFile(fileName)
    local func = _G[funcName]
    assert(func ~= nil)
    return function(...)
        local rets = { pcall(func, ...) }
        local status = rets[1]
        --print("status:", status)
        assert(status, rets[2])
        return unpack(rets, 2)
    end
end

FF_G.MergeTables = function(...)
    local tabs = {...}
    if not tabs then
        return {}
    end
    local origin = tabs[1]
    for i = 2, #tabs do
        if origin then
            if tabs[i] then
                for k, v in pairs(tabs[i]) do
                    --table.insert(origin, k, v)
                    origin[k] = v
                end
            end
        else
            origin = tabs[i]
        end
    end
    return origin
end

FF_G.IsCSGame = function(gameId)
    return gameId >= 109 and gameId < 140
end