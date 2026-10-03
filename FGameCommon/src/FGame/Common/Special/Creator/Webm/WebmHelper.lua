local WebmHelper = {}

local WebmAnimationApi = require("FGame.Common.Special.Creator.Webm.WebmAnimationApi")


function WebmHelper.CreateWebmAndBindToGImage(gImage, webmName)
    print("webm path:", webmName)

    local userData = gImage.data
    local component = nil
    if userData or webmName then
        local node = gImage.node
        component = node:getComponent("WebmComponent")
        if not component then
            component = node:addComponent("WebmComponent")
        end
        component:init(webmName)
    end

    return component
end

function WebmHelper.CreateAllWebmWithRObject(gObject)
    CREATOR.initAllWebmComponents(gObject.node)
end

return WebmHelper
