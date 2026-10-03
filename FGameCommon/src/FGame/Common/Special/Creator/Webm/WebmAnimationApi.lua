---@class AnimApi
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
    self.anim:addListener(callback)
end

function AnimApi:Play(times, callback)
    times = times or self.anim:getLoop()
    self:Resume()
    if callback ~= nil or times > 0 then
        self.SetOnPlayEndCallback(function () 
            times= times - 1;
            if times == 0 then
                self:Stop()
                if callback then
                    callback()
                end
            end
        end)
    end
end

function AnimApi:RePlay (times, callback)
    self.anim:reset()
    self:Play(times,callback)
end

function AnimApi:Pause()
    self.anim:pause()
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
