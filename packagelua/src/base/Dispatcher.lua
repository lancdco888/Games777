local Dispatcher = class("Dispatcher")

function Dispatcher:ctor()
    self.paused = false
    self.cached = {}        --{evName, data, reset}
    self.listeners = {}     --{evName, method, _self}
end
--first:是否插入到队首
function Dispatcher:Register(evName, method, _self,first)
    if evName == nil or evName == "" or method == nil then
        print("invliad param,traceback = ", debug.traceback("", 2))
        assert(false)
    end

    if _self == nil then
        print("Warning: Subscription flag not set '_self'")
    end

    for _,l in ipairs(self.listeners) do
        if evName == l.evName
            and method == l.method
            and _self == l._self
        then
            return 
        end
    end
    if first then
        table.insert(self.listeners,1, {
            evName = evName,
            method = method,
            _self = _self
        })
        return
    end
    table.insert(self.listeners, {
        evName = evName,
        method = method,
        _self = _self
    })
end

function Dispatcher:Remove(_self)
    if _self == nil  then return end
    local listeners = self.listeners
    local size = #listeners
    for i=size,1,-1 do
        local listener = listeners[i]
        if listener._self == _self then
            table.remove(listeners, i)
        end
    end
end
--onlyFirst:是否吞没后续事件，仅队首响应
function Dispatcher:Dispatch(evName, data, reset, onlyFirst)
    if self.paused then
        table.insert(self.cached, {evName=evName, data=data, reset=reset})
        return
    end
    --收集关注该事件的所有监听者,再集体调用回调,可以避免回调里面调用register 或 remove 修改 listeners的情况
    local listeners = {}
    for index, listener in ipairs(self.listeners) do
        if evName == listener.evName then
            table.insert(listeners, listener)
        end
    end
    --处理所有监听者的回调
    --注意:如果在回调中用户调用 pause 可能会出现意料之外的情况
    for index,listener in ipairs(listeners) do
        local _self = listener._self
        local status, result
        if _self then
            status, result = pcall(listener.method, _self, data)
        else
            status, result = pcall(listener.method, data)
        end
        if not status then
            __G__TRACKBACK__(result)
        end
        if reset then
            reset()
        end
        if onlyFirst then
            break
        end
    end
end

function Dispatcher:Pause()
    self.paused = true
end

function Dispatcher:Resume()
    self.paused = false
    --注意:如果在回调中用户调用 pause 可能会出现意料之外的情况
    for index,cache in ipairs(self.cached) do
        self:Dispatch(cache.evName, cache.data, cache.reset)
    end
    self.cached = {}
end

return Dispatcher.new()
