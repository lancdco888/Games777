local upload_url = ""
local ip = nil

-- 获取自己的 ip 地址
function GetMyIp(on_success)
    local url = "http://ip-api.com/json/?fields=61439"
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("GET", url)

    xhr:registerScriptHandler(function()
        dump(xhr.response, " ** response ** ")
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then -- 成功
            if xhr.response and xhr.response ~= "" then
                local json = require("json")
                local data_ = json.decode(xhr.response)
                if data_ and data_.query then
                    ip = data_.query
                    release_print("get ip success:" .. tostring(ip))
                    if on_success then
                        on_success()
                    end
                end
            end
        else
            release_print("get my ip failed.")
        end
    end)

    xhr:setRequestHeader("Accept", "application/json")
    xhr:send()
end

function MetaPixelEvent(type_, action_source)
    if upload_url == "" then
        return
    end

    if not ip then
        release_print("unkown ip, start fetch ip")
        GetMyIp(function()
            MetaPixelEvent(type_)
        end)
        return
    end

    local event = {}
    local payload = { event }

    event.event_name = type_
    event.event_time = os.time()

    action_source = action_source or "app"
    event.action_source = action_source

    if type_ == "Purchase" then
        event.custom_data = {}
        local custom_data = event.custom_data
        custom_data.currency = "USD"
        custom_data.value = 0.5
    end

    -- 用户数据
    local user_data = {}
    event.user_data = user_data
    user_data.em = {
        ""
    }
    user_data.ph = {
        ""
    }
    user_data.client_ip_address = ip

    ---------------------------------------------------------

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("POST", upload_url)

    local json = require("json")
    local data_str = json.encode(payload)
    dump(payload, " ** MetaPixelEvent ** ")

    -- 上传成功之后再删除缓存的事件文件
    xhr:registerScriptHandler(function()
        dump(xhr.response, " ** response ** ")
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then -- 成功
            release_print("MetaPixelEvent, upload success:" .. data_str)
        else
            if action_source == "app" then
                release_print("MetaPixelEvent, upload failed, try website again。" .. data_str)
                action_source = "website"
                MetaPixelEvent(type_, action_source)
            else
                release_print("MetaPixelEvent, upload failed" .. data_str)
            end
        end
    end)

    xhr:setRequestHeader("Accept", "application/json")
    xhr:send("data=" .. data_str)
end

--------------------------------------------------------------------------------------

local function start()
    local url = "https://graph.facebook.com/v14.0/<PIXEL_ID>/events?access_token=<ACCESS_TOKEN>"

    local build_json = "bootstrap/src/BuildConfig.json"
    local BuildConfig = {}
    if cc.FileUtils:getInstance():isFileExist(build_json) then
        local str_ = cc.FileUtils:getInstance():getStringFromFile(build_json)
        local json = require("json")
        local data_ = json.decode(str_)
        BuildConfig = data_
    else
        upload_url = ""
        return
    end

    local pixel_id = BuildConfig.PIXEL_ID
    local access_token = BuildConfig.PIXEL_ACCESS_TOKEN

    if not pixel_id or pixel_id == "" then
        upload_url = ""
        return
    end
    if not access_token or access_token == "" then
        upload_url = ""
        return
    end

    url = string.gsub(url, "<PIXEL_ID>", pixel_id)
    url = string.gsub(url, "<ACCESS_TOKEN>", access_token)

    upload_url = url
end

start()
