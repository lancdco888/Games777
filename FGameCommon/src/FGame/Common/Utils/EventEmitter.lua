-- 事件派发器

local EventEmitter = Class("EventEmitter")

function EventEmitter:ctor()
    self.listeners = {}
end

function EventEmitter:__delete()
    self:RemoveAllListeners()
end

function EventEmitter:AddListener(eventName, func, tag)
    assert(tag, "Tag must not be nil")
    local listeners = self.listeners
    if not listeners[eventName] then
        listeners[eventName] = {}
    end
    
    local eventListeners = listeners[eventName]

    -- 去除重复订阅判断
    -- for i = 1, #eventListeners do
    --     if tag == eventListeners[i][2] then
    --         print("重复添加:", eventName, tag)
    --         return
    --     end
    -- end
    table.insert(eventListeners, {func, tag})
end

function EventEmitter:RemoveListener(func)
    local listeners = self.listeners
    for eventName, eventListeners in pairs(listeners) do
        for i = 1, #eventListeners do
            if eventListeners[i][1] == func then
                table.remove(eventListeners, i)
                if 0 == #listeners[eventName] then
                    listeners[eventName] = nil
                end
                return
            end
        end
    end
end

function EventEmitter:RemoveListenerByNameAndTag(eventName, tag)
    assert(tag, "Tag must not be nil")
    local listeners = self.listeners
    local eventListeners = listeners[eventName]
    if not eventListeners then return end

    for i = #eventListeners, 1, -1 do
        if eventListeners[i][2] == tag then
            table.remove(eventListeners, i)
            break
        end
    end
    if 0 == #eventListeners then
        listeners[eventName] = nil
    end
end

function EventEmitter:RemoveListenersByTag(tag)
    assert(tag, "Tag must not be nil")
    local listeners = self.listeners
    for eventName, eventListeners in pairs(listeners) do
        self:RemoveListenerByNameAndTag(eventName, tag)
    end
end

function EventEmitter:RemoveAllListeners()
    self.listeners = {}
end

function EventEmitter:Emit(eventName, ...)
    local listeners = self.listeners
    local eventListeners = listeners[eventName]
    if not eventListeners then
        return
    end

    local tmp = {}
    for index, listeners in ipairs(eventListeners) do
        tmp[index] = listeners
    end
    for _, listeners in ipairs(tmp) do
        listeners[1](...)
    end
end

return EventEmitter