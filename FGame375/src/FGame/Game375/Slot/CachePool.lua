-- 定义一个带上限的缓存队列
local CacheQueue = Class("CacheQueue")

function CacheQueue:ctor(maxSize, shouldRemoveFunc, resetFunc,cleanFunc)
    self.items = {}
    self.maxSize = maxSize or 100  -- 默认上限为100
    self.nextKey = 1  -- 下一个插入的键
    self.firstKey = 1  -- 队列中第一个键
    self.shouldRemove = shouldRemoveFunc  -- 判断是否移除的函数
    self.reset = resetFunc  -- 重置数据的函数
    self.clean = cleanFunc -- 外部提供的针对受保护字段的清理函数
    self.count = 0  -- 追踪队列中实际元素的数量
end

function CacheQueue:__delete()
    
end

-- 获取池最大长度
function CacheQueue:GetMaxSize()
    return self.maxSize
end

-- 检查最后一个元素是否有受保护的元素
function CacheQueue:checkProtectedAtCurrentPosition(name)
    if not next(self.items) then
        return false, nil
    end
    local lastItemIndex = (self.nextKey - 1 + self.maxSize - 1) % self.maxSize + 1  -- 计算最后一个元素的索引
    local item = self.items[lastItemIndex]
    if item and item[name] then
        return true, item[name]
    end
    return false, nil
end


-- 插入元素
function CacheQueue:put(value, protectedFields)
    protectedFields = protectedFields or {}
    if self:getSize() >= self.maxSize then
        if self.shouldRemove(self.items[self.firstKey]) then
            self:_reset_()
        else
            return false  -- 如果不满足条件，返回池满
        end
    end

    local key = self.nextKey
    if self.items[key] then
        -- 更新现有元素的部分字段，跳过受保护的字段
        for k, v in pairs(value) do
            if not protectedFields[k] then
                self.items[key][k] = v
            end
        end
    else
        -- 插入新的值
        self.items[key] = value
    end

    self.count = self.count + 1
    self.nextKey = (self.nextKey % self.maxSize) + 1  -- 更新nextKey，考虑循环队列
    return self.items[key]
end

--组件内部重置
function CacheQueue:_reset_()
    self:reset(self.items[self.firstKey])
    local key = self.firstKey  -- 重用被重置的元素的位置
    self.firstKey = (self.firstKey % self.maxSize) + 1
    self.count = self.count - 1
    return key
end

-- 获取元素
function CacheQueue:get(index)
    if index < 1 or index > self.maxSize then
        return nil
    end
    return self.items[index]
end

-- 获取当前当前可插入实际位置的数据
function CacheQueue:getCurrent()
    local key = self.nextKey - 1
    if key < 1 then
        key = self.maxSize
    end
    return self.items[key]
end

-- 获取当前可插入位置的上一个位置的数据
function CacheQueue:getPrevious()
    -- 检查队列是否为空，如果是，则返回nil
    if (self.firstKey == self.nextKey) and (self.count == 0) then
        return nil
    end
    -- 计算上一个位置的索引，考虑到循环队列的特性
    local previousKey = ((self.nextKey - 1) + self.maxSize - 1) % self.maxSize + 1
    -- 返回上一个位置的数据
    return self.items[previousKey]
end

-- 获取队列大小
function CacheQueue:getSize()
    return self.count
end

-- 移除元素前调用清理函数
function CacheQueue:remove(key)
    local item = self.items[key]
    if item then
        -- 调用清理函数处理受保护的字段
        if self.clean then
            self.clean(item)
        end
        self.items[key] = nil
        -- 更新firstKey和nextKey适应移除
        if key == self.firstKey then
            self.firstKey = self.firstKey + 1
        end
        if key == self.nextKey - 1 then
            self.nextKey = self.nextKey - 1
        end
        self.count = self.count - 1
        return true
    end
    return false
end

-- 清空缓存前调用清理函数
function CacheQueue:clear()
    if self.clean then
        for _, item in pairs(self.items) do
            self.clean(item)
        end
    end
    self.items = {}
    self.nextKey = 1
    self.firstKey = 1
    self.count = 0
end

return CacheQueue
