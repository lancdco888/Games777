local PlayerActionLimiter = class("PlayerActionLimiter")

function PlayerActionLimiter:ctor(duaration, limit)
    self.window = duaration or 60           -- 时间窗口
    self.max = limit or 5                   -- 一最多几次
    self.actions = {}       -- 时间戳队列
end

function PlayerActionLimiter:canDo()
    local now = os.time()

    -- 移除超出时间窗的记录
    local new = {}
    for _, t in ipairs(self.actions) do
        if now - t < self.window then
            table.insert(new, t)
        end
    end
    self.actions = new

    -- 检查是否超出限制
    if #self.actions >= self.max then
        return false
    end

    table.insert(self.actions, now)
    return true
end

return PlayerActionLimiter
