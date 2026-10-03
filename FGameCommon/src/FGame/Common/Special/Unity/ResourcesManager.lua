local ResourcesManager = {}

local abc = CS.AssetBundleUtils.AssetBundlesConfig.GetInstance()

function ResourcesManager.GetPath(path)
    local prefixed = CS.FairyGUI.UIPackage.GetPathPrefixes()
    for i = 0, prefixed.Count - 1 do
        local path1 = prefixed[i] .. "/" .. path
        if abc:ContainsAsset(path1) then
            return path1
        end
    end
end

function ResourcesManager.GetWebmPath(webmName)
    local webmPath = ResourcesManager.GetPath(string.format("Webm/Src/%s.webm.txt", webmName))
    return webmPath
end

function ResourcesManager.PreloadWebm(webmNames)
    if type(webmNames) == "string" then
        webmNames = {webmNames}
    end
    local webmConverter = CS.Codec.Webm.WebmConverter.GetInstance()
    for _, webmName in ipairs(webmNames) do
        local path = ResourcesManager.GetWebmPath(webmName)
        webmConverter:ConvertToTextures(path, null, true, 0)
    end
end

return ResourcesManager
