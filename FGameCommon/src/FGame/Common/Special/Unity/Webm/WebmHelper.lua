local WebmHelper = {}

local ResourcesManager = require("FGame.Common.Special.Unity.ResourcesManager")
local GetPath = ResourcesManager.GetPath
local GetWebmPath = ResourcesManager.GetWebmPath

local WebmAnimationApi = require("FGame.Common.Special.Unity.Webm.WebmAnimationApi")

-- deprecated
function WebmHelper.CreateWebm(obj, webmFile)
    --local prefabUrl = "ModSlots321/Webm/webm1.prefab"
    local loader3D = obj.asLoader3D

    local oldTarget = loader3D.wrapTarget
    if oldTarget ~= nil then
        CS.UnityEngine.Object.Destroy(oldTarget)
    end

    local prefabUrl = GetPath(string.format("Webm/Prefab/%s.prefab", webmFile))
    local webm = ResMgr:getAssetCacheByType(prefabUrl, typeof(CS.UnityEngine.Object))
    local webmIns = CSUtils.GameObject.Instantiate(webm)
    loader3D:SetWrapTarget(webmIns, false)
    webmIns.transform.localPosition = CS.UnityEngine.Vector3.zero
    local anim = webmIns:GetComponentInChildren(typeof(CS.Components.WebmAnimation))
    local rect = anim.transform:GetComponent(typeof(CS.UnityEngine.RectTransform))
    rect.sizeDelta = CS.UnityEngine.Vector2(obj.width,obj.height) -- 尺寸
    -- anim.transform.localScale = CS.UnityEngine.Vector3(obj.scaleX,obj.scaleY,1) -- 缩放 --[不好搞建议不要缩放]
    local rectP = anim.transform.parent:GetComponent(typeof(CS.UnityEngine.RectTransform))
    rectP.sizeDelta = CS.UnityEngine.Vector2(obj.width,obj.height) -- 尺寸
    -- anim.transform.parent.localScale = CS.UnityEngine.Vector3(obj.scaleX,obj.scaleY,1) -- 缩放--[不好搞建议不要缩放]
    anim:SetFrame(0)
    if obj.playing then -- 播放默认就是循环播放
        anim:RePlay(-1)
    else
        anim:Stop()
    end
    return {
        gameObject = webmIns,
        SetOnPlayEndCallback = function(callback)
            anim.OnPlayEnd = callback
        end,
        Play = function(times, callback)
            if callback ~= nil then anim.OnPlayEnd = callback end
            anim:Play(times)
        end,
        RePlay = function(times, callback)
            if callback ~= nil then anim.OnPlayEnd = callback end
            anim:RePlay(times)
        end,
        Pause = function()
            anim:Pause()
        end,
        Stop = function()
            anim:Stop()
        end,
        SetFrame = function(frameIndex)
            anim:SetFrame(frameIndex)
        end,
        SetPlayScale = function(playScale)
            anim.playScale = playScale
        end,
        GetPlayScale = function()
            return anim.playScale
        end,
        SetVisible = function(visible)-- 设置visible
            -- print("设置visible ",anim.transform.parent.parent.gameObject.name)
            obj.visible = visible
            -- anim.transform.parent.parent.gameObject:SetActive(visible)
        end,
        IsVisible = function()
            return obj.visible --anim.transform.parent.parent.gameObject.activeSelf
        end,
    }
end

-- deprecated
function WebmHelper.BindWebmMask(webmAnim, maskGObject, rootGObject, loader3D)
    local gameObject = webmAnim.gameObject
    local binder = gameObject:GetComponentInChildren(typeof(CS.Components.FairyGUIMaskBinder))
    binder.FairyGUIMaskGObject = maskGObject
    binder.RootGObject = rootGObject
    binder.DestGObject = loader3D
    binder.enabled = true;
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
    print("webm path:", webmPath)

    local userData = gImage.data
    local pairs = ParseKeyValuePairs(userData)
    local loop = pairs.GetNumber("loop", -1)
    local autoPlay = pairs.GetBool("autoPlay", false)
    local visible = pairs.GetBool("visible", true)
    local frame = pairs.GetNumber("frame", 0)
    print("webm parameters: ", loop, autoPlay, visible, frame)

    local displayObject = gImage.displayObject.gameObject
    local oldAnim = displayObject:GetComponent(typeof(CS.Components.WebmAnimation))
    if oldAnim ~= nil then
        CS.UnityEngine.Object.Destroy(oldAnim)
    end
    local anim = displayObject:AddComponent(typeof(CS.Components.WebmAnimation))
    anim.loop = loop
    anim.playOnLoaded = autoPlay
    anim.webmPath = webmPath
    anim.GImage = gImage
    -- gImage.visible = visible
    if frame ~= -1 then anim:SetFrame(frame) end

    local animApi = WebmAnimationApi:new(anim, gImage)
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

    local gComponent = gObject.asCom
    if gComponent == nil then return end

    for i = 0, gComponent.numChildren - 1 do
        local child = gComponent:GetChildAt(i)
        APIGateway.CreateAllWebmWithRObject(child)
    end
end

return WebmHelper
