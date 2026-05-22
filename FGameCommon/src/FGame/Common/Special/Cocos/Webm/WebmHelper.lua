local WebmHelper = {}

local WebmAnimationApi = require("FGame.Common.Special.Cocos.Webm.WebmAnimationApi")

local function GetWebmPath(webmName)
    local webmPath = string.format("Game%d/Webm/%s.webm", FCasinoCtx.gameId, webmName)
    if not cc.FileUtils:getInstance():isFileExist(webmPath) then
        return string.format("Basics/Webm/%s.webm", webmName)
    end
    return webmPath
end

local function ParseKeyValuePairs(text)
    local keyValuePairs = {}
    if text == nil then return keyValuePairs end

    for key, value in string.gmatch(text, "(%w+)%s*[:=]%s*([%w_-]+)") do
        keyValuePairs[key] = value
    end

    keyValuePairs.GetString = function(key, default)
        return keyValuePairs[key] or default
    end
    keyValuePairs.GetBool = function(key, default)
        local value = keyValuePairs[key]
        if value ~= nil then return value == "true" end
        return default
    end
    keyValuePairs.GetNumber = function(key, default)
        local value = keyValuePairs[key]
        if value ~= nil then return tonumber(value) end
        return default
    end

    return keyValuePairs
end

function WebmHelper.CreateWebmAndBindToGImage(gImage, webmName)
    local webmPath = GetWebmPath(webmName)
    -- print("webm path:", webmPath)

    local userData = gImage.data
    local pairs = ParseKeyValuePairs(userData)
    local loop = pairs.GetNumber("loop", -1)
    local autoPlay = pairs.GetBool("autoPlay", false)
    local visible = pairs.GetBool("visible", gImage.visible)
    local frame = pairs.GetNumber("frame", -1)
    -- print("webm parameters: ", loop, autoPlay, visible, frame)

    local displayObject = gImage.displayObject
    displayObject:setKeepContentSize(true)
    displayObject:initWithWebmAsync(webmPath)

    if autoPlay then
        displayObject:play(loop)
    end
    -- gImage.visible = visible
    if frame ~= -1 then displayObject:setFrame(frame) end

    local animApi = WebmAnimationApi:new(displayObject, gImage)
    gImage.webmAnimation = animApi
    return animApi
end

function WebmHelper.CreateAllWebmWithRObject(gObject)
    local gImage = gObject
    local userData = gObject.data
    --print("user data:", userData)
    if gImage ~= nil and userData ~= nil then
        local _, _, webmName = string.find(userData, "webm%s*[:=]%s*([a-zA-Z0-9_-]+)")
        if webmName ~= nil then
            APIGateway.CreateWebmAndBindToGImage(gImage, webmName)
        end
    end

    if gObject.numChildren == nil then return end

    for i = 0, gObject.numChildren - 1 do
        local child = gObject:GetChildAt(i)
        APIGateway.CreateAllWebmWithRObject(child)
    end
end

return WebmHelper