local isUseDebugMode = false
local isOverwrite = false
local local_print = print


PrintJson = function(detail, jsonTable, nesting)
    if RUNTIME_IN_CREATOR then
        local_print("RUNTIME_IN_CREATOR", isOverwrite)
        if isOverwrite then
            print({ func = "JSON", params = { detail, cjson.encode(jsonTable) } })
        else
            if not nesting then nesting = 3 end
            dump(detail, jsonTable, nesting)
        end
    else
        dump(detail, jsonTable, nesting)
    end
end

local function overwriteDebugRuntime()
    if isUseDebugMode then
        if not isOverwrite then
            isOverwrite = true
            local_print("RUNTIME_IN_CREATOR")
            if RUNTIME_IN_CREATOR then
                function print(...)
                    local isObj = (...)
                    if type(isObj) == "table" then
                        if isObj.func then
                            if not isObj.params then
                                isObj.params = {}
                            end
                            local funcs = isObj.func .. "[f(@@@@)f]"
                            local params = ""
                            for k, v in ipairs(isObj.params) do
                                local p = v
                                if type(v) ~= "string" then
                                    p = tostring(v)
                                end

                                if k == #isObj.params then
                                    params = params .. p
                                else
                                    params = params .. p .. "[-###-]"
                                end
                            end
                            funcs = funcs .. params
                            local_print(funcs)
                        else
                            local_print(...)
                        end
                    else
                        local_print(...)
                    end
                end
            end
        end
    else
        print = local_print
        isOverwrite = false
    end
end



OpenDebug = function()
    -- isUseDebugMode = true
    -- overwriteDebugRuntime()
end

CloseDebug = function()
    isUseDebugMode = false
    overwriteDebugRuntime()
end


return {}
