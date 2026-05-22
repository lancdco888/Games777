-- 错误日志上传

local httpCount = 0
local logMap = {}

local httpPost
httpPost = function(postData, callback, retryCount)
    retryCount = retryCount or 0

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("POST", "http://8.222.247.238:85/api/upload_log")
    xhr:registerScriptHandler(function()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then -- 成功
            if callback then callback(true) end
        else
            if retryCount <= 0 then
                if callback then callback(false) end
            else
                httpPost(postData, callback, retryCount - 1)
            end
        end
    end)
    xhr:setRequestHeader("Content-Type", "application/json")
    xhr:setRequestHeader("Accept", "application/json")
    xhr:send(postData)
end

local  function compat_get_pkg_name()
    if GetPackageName then
        return tostring(GetPackageName())
    end

    if Device and Device.GetPackageName then
        return tostring(Device:GetPackageName())
    end

    if BuildConfig and BuildConfig.PKG_NAME then
        return tostring(BuildConfig.PKG_NAME)
    end

    return "legacy_unknown_pkg_name"
end

function LuaErrorReportSend(errMsg, callback, debugModeDisableReporting, errMsgDetails)
    -- 同一错误只上传一次
    if logMap[errMsg] then
        if callback then callback() end
        return
    end
    logMap[errMsg] = true

    -- 限制最大请求数量
    if httpCount > 5 then
        if callback then callback() end
        return
    end

    httpCount = httpCount + 1

    local versionInfo = {
        hotfix = tostring(ConfigParam.AssetsUrl),
        branch = "main",
        patch_time = "2000-01-01",
    }

    local data = {
        log_type = "error_20",
        message = errMsg,
        user = "no login",
        package = tostring(compat_get_pkg_name()),
        nav_url = tostring(BuildConfig and BuildConfig.DomainUrl or "unknown"),
        version = "1.0.1",
        logs = "",
    }

    if UserData then
        data.user = tostring(UserData.id or 0)
    end

    httpPost(require("json").encode(data), function(ok)
        httpCount = httpCount - 1
        if not ok then
            logMap[errMsg] = nil
        end
        if callback then callback(true) end
    end, 3)
end
