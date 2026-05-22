
function __G__TRACKBACK__(msg)
    local message = ""
    message = message .. "----------------------------------------\n"
    message = message .. "LUA ERROR: " .. tostring(msg) .. "\n"
    message = message .. debug.traceback()
    message = message .. "\n----------------------------------------\n"
    print(message)
    cclog(message)
end
