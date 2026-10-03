local AnimApi = {}

function AnimApi:new(webmAnim, gImage)
    local o = {
        anim = webmAnim,
        gImage = gImage,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function AnimApi:SetOnPlayEndCallback(callback)
    self.anim.OnPlayEnd = callback
end

function AnimApi:Play(times, callback)
    if callback ~= nil then self.anim.OnPlayEnd = callback end
    times = times or self.anim.loop
    anim:Play(times)
end

function AnimApi:RePlay (times, callback)
    if callback ~= nil then self.anim.OnPlayEnd = callback end
    times = times or self.anim.loop
    self.anim:RePlay(times)
end

function AnimApi:Pause()
    self.anim:Pause()
end

function AnimApi:Stop()
    self.anim:Stop()
end

function AnimApi:SetFrame(frameIndex)
    self.anim:SetFrame(frameIndex)
end

function AnimApi:SetPlayScale(playScale)
    self.anim.playScale = playScale
end

function AnimApi:GetPlayScale()
    return self.anim.playScale
end

-- 设置visible
function AnimApi:SetVisible(isVisible)
    -- print("设置visible ",anim.transform.parent.parent.gameObject.name)
    self.gImage.visible = isVisible
    -- anim.transform.parent.parent.gameObject:SetActive(visible)
end

function AnimApi:IsVisible()
    --anim.transform.parent.parent.gameObject.activeSelf
    return self.gImage.visible
end

return AnimApi
