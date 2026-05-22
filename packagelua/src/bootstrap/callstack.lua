local url = "http://47.236.131.154:91/post-event"

function UploadEvent(data, onsuccess)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("POST", url)

    local json = require("json")
    local data_str = json.encode(data)

    xhr:registerScriptHandler(function()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then -- 成功
            print("UploadEvent: success")
            dump(xhr.response, "xhr.response")
            if onsuccess then onsuccess() end
        end
    end)

    xhr:setRequestHeader("Accept", "application/json")
    xhr:send(data_str)
end

require("packagelua.src.bootstrap.ErrorTrack")
function __G__TRACKBACK__(msg)
    local message = ""
    message = message .. "LUA ERROR: " .. tostring(msg) .. "\n"
    message = message .. debug.traceback()

    local ok, err = pcall(LuaErrorReportSend, message, nil, true)
    if not ok then
        print("LuaErrorReportSend error:", err)
    end
    print(message)

    if BuildConfig and BuildConfig.Debug == "TRUE" then
        go(function()
            SleepSecs(0.3)
            local DebugLayer = require("packagelua.src.msg.DebugLayer").new()
            DebugLayer:Show()
        end)
    end
end
