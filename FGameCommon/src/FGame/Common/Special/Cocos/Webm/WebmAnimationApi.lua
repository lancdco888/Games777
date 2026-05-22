local AnimApi = {}

local hasSuspendFunc = cc.Webm.suspend ~= nil

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
    self.anim:setOnPlayEnd(callback)
end

function AnimApi:Play(times, callback)
    if callback ~= nil then self.anim:setOnPlayEnd(callback) end
    times = times or self.anim:getLoop()
    self.anim:play(times)
end

function AnimApi:RePlay (times, callback)
    if callback ~= nil then self.anim:setOnPlayEnd(callback) end
    times = times or self.anim:getLoop()
    self.anim:rePlay(times)
end

function AnimApi:Pause()
    if hasSuspendFunc then
        self.anim:suspend()
    else
        self.anim:pause()
    end
end

function AnimApi:Stop()
    self.anim:stop()
end

function AnimApi:SetFrame(frameIndex)
    self.anim:setFrame(frameIndex)
end

function AnimApi:SetPlayScale(playScale)
    self.anim:setPlayScale(playScale)
end

function AnimApi:GetPlayScale()
    return self.anim:getPlayScale()
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