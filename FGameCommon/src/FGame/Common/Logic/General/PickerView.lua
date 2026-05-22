local PickerViewNode = Import(".PickerViewNode")
local PickerView = Class("PickerView")

local function lerp(p1, p2, alpha)
    return p1 * (1 - alpha) + p2 * alpha
end
local abs = math.abs

function PickerView:ctor(render)
    self.render = render
    self.nodes = {}
    self.deltaTime = 0

    -- 顶部留白
    self.topPadding = 0
    -- 底部留白
    self.bottomPadding = 0

    self.container = FairyGUI.GComponent()
    self.render:AddChild(self.container)

    render:AddEventListener(FGUIEventKey.onTouchBegin, function(context) self:OnTouchBegin(context) end)
    render:AddEventListener(FGUIEventKey.onTouchMove, function(context) self:OnTouchMove(context) end)
    render:AddEventListener(FGUIEventKey.onTouchEnd, function(context) self:OnTouchEnd(context) end)
    FSysEventEmitter:AddListener(FSysEvent.ON_LOGIC_UPDATE, handler(self, self.OnUpdate), self)

    -- 滑动相关变量
    self._autoScrolling = false
    self._touchMoveDisplacements = {}
    self._touchMoveTimeDeltas = {}
    self._touchMovePreviousTimestamp = self.deltaTime

    self:Reload(0)
end

function PickerView:__delete()
    FSysEventEmitter:RemoveListenersByTag(self)
    for k, v in pairs(self.nodes) do
        v:Delete()
    end
    self.nodes = {}
    self.container:RemoveFromParent(true)
    self.container = nil
    self._autoScrolling = false
end

function PickerView:OnCellSize(index)
    return self.onCellSizeCallback(self, index)
end

function PickerView:OnLoadCell(index)
    local cell =  self.onLoadCellCallback(self, index)
    self.container:AddChild(cell)
    return cell
end

function PickerView:Reload(num)
    for k, v in pairs(self.nodes) do
        v:Delete()
    end
    self.nodes = {}

    local y = self.topPadding
    for i = 1, num do
        local node = PickerViewNode.New(i, self)
        node:SetPositionY(y)
        node.width, node.height = self:OnCellSize(i)
        self.nodes[i] = node

        y = y + node.height
    end
    y = y + self.bottomPadding

    self.container.height = math.max(y, self.render.height)
    self.container.y = 0

    self.minContainerPosy = self.render.height - self.container.height
    self.maxContainerPosy = 0
    self.curContainerPosy = 0
    self.viewHeight = self.render.height

    self:UpdateItems()
end

-- @brief
function PickerView:ScrollToCenter(index, speed, maxDuration)
    self:StoppedAnimatedScroll()
    local viewHeight = self.viewHeight
    local containerPosy = self.curContainerPosy

    local minNode, minOffset
    -- 查找距离中心最短的cell
    for k, v in pairs(self.nodes) do
        if v.index == index then
            local posYInView = v.y + containerPosy + v.height * 0.5
            local offset = posYInView - viewHeight * 0.5

            -- 不需要播放滚动动画，直接跳转
            if speed == nil then
                self:OnChangePosy(-offset)
            else
                self:Holding()

                local endPosy = containerPosy - offset
                local time = 0
                local duration = abs(offset) / speed

                if maxDuration ~= nil and duration > maxDuration then
                    duration = maxDuration
                end

                self._onUpdateCallback = function(dt)
                    time = time + dt
                    local percent = time / duration
                    local posy = endPosy

                    if percent >= 1.0 then
                        self:UnHolding()
                        self:StoppedAnimatedScroll()
                    else
                        posy = lerp(containerPosy, endPosy, percent)
                    end
                    self:OnChangePosy(posy - self.curContainerPosy)
                end
            end
            break
        end
    end
end

function PickerView:StoppedAnimatedScroll()
    self._onUpdateCallback = nil
    self._autoScrolling = false
    self._touchMoveDisplacements = {}
    self._touchMoveTimeDeltas = {}
end

-- @brief 判断是否处于触摸中状态
function PickerView:IsTouching()
    return self.previousPoint ~= nil
end

-- @brief 判断是否处于自动滚动中
function PickerView:IsAutoRolling()
    return self._autoScrolling
end

-- @brief 判断是否处于滚动动画中
function PickerView:IsAnimatedScroll()
    return self._onUpdateCallback ~= nil
end

--@brief 屏蔽触摸事件
function PickerView:Holding()
    self.isHolding = true
end

--@brief 启用触摸事件
function PickerView:UnHolding()
    self.isHolding = false
end

function PickerView:OnTouchBegin(context)
    if self.isHolding then
        return
    end
    if self.onTouchPreJudgment and not self.onTouchPreJudgment() then
        return
    end

    context:CaptureTouch()
    
    local pt = nil
    if RUNTIME_IN_CREATOR then
        local pos = context.pos
        pt = self.render:GlobalToLocal(pos.x,pos.y)
        pt = {x = pos.x , y = pos.y}
    else
        pt = self.render:GlobalToLocal(context.inputEvent.position)
    end
    self.previousPoint = pt
    
    self:StoppedAnimatedScroll()
    self._touchMovePreviousTimestamp = self.deltaTime
end

function PickerView:OnTouchMove(context)
    local pt = nil
    if RUNTIME_IN_CREATOR then
        local pos = context.pos
        pt = self.render:GlobalToLocal(pos.x,pos.y)
        pt = {x = pos.x , y = pos.y}
    else
        pt = self.render:GlobalToLocal(context.inputEvent.position)
    end

    if self.previousPoint then
        local deltaPosy = pt.y - self.previousPoint.y
        self:gatherTouchMove(vec2(0, deltaPosy))
        self:OnChangePosy(deltaPosy)
    end

    self.previousPoint = pt
end

function PickerView:OnTouchEnd(context)
    local pt = nil
    if RUNTIME_IN_CREATOR then
        local pos = context.pos
        pt = self.render:GlobalToLocal(pos.x,pos.y)
        pt = {x = pos.x , y = pos.y}
    else
        pt = self.render:GlobalToLocal(context.inputEvent.position)
    end
    
    if self.previousPoint then
        local deltaPosy = pt.y - self.previousPoint.y
        self:gatherTouchMove(vec2(0, deltaPosy))
        self.previousPoint = nil
    end
    
    local touchMoveVelocity = self:calculateTouchMoveVelocity()
    self:startInertiaScroll(touchMoveVelocity)

    
    -- 滑动太慢了，将时间缩短点
    local factor = 0.5
    self._autoScrollTotalTime = self._autoScrollTotalTime * factor
    self._autoScrollTargetDelta.x = self._autoScrollTargetDelta.x * factor
    self._autoScrollTargetDelta.y = self._autoScrollTargetDelta.y * factor

    ------------------------ 
    -- 限制滚动距离，让最后滚动完毕一定是将某个cell停靠在视图中间
    ------------------------ 
    local maxDeltay = self.maxContainerPosy - self.curContainerPosy
    local minDeltay = self.minContainerPosy - self.curContainerPosy
    
    local scrollTargetDeltay = self._autoScrollTargetDelta.y
    if scrollTargetDeltay > maxDeltay then scrollTargetDeltay = maxDeltay end
    if scrollTargetDeltay < minDeltay then scrollTargetDeltay = minDeltay end

    -- 保存之前的偏移值
    local oldContainerPosy = self.curContainerPosy

    -- 模拟滚动结束后,获取距离视图中央最近的cell
    self.curContainerPosy = self.curContainerPosy + scrollTargetDeltay
    local minNode, minOffset = self:getCenterNode()

    -- 新的偏移量
    scrollTargetDeltay = scrollTargetDeltay - minOffset

    -- 重新计算自动滚动时间
    if abs(self._autoScrollTargetDelta.y) > 0.0001 then
        self._autoScrollTotalTime = self._autoScrollTotalTime * (abs(scrollTargetDeltay) / abs(self._autoScrollTargetDelta.y))
    else
        self._autoScrollTotalTime = 0.1
    end
    self._autoScrollTargetDelta.y = scrollTargetDeltay

    -- 还原偏移值
    self.curContainerPosy = oldContainerPosy
end

function PickerView:OnUpdate(dt)
    self.deltaTime = self.deltaTime + dt
    if self._autoScrolling then
        self:processAutoScrolling(dt)
    end

    if self._onUpdateCallback then
        self._onUpdateCallback(dt)
    end
end

function PickerView:OnChangePosy(value)
    local ok = false
    local y = self.container.y + value
    if y > self.maxContainerPosy then 
        y = self.maxContainerPosy
        ok = true
    end
    if y < self.minContainerPosy then
        y = self.minContainerPosy
        ok = true
    end

    self.curContainerPosy = y
    self.container.y = y

    self:UpdateItems()

    return ok
end

function PickerView:UpdateItems()
    local offsety = self.curContainerPosy
    local viewHeight = self.viewHeight
    
    for k, v in pairs(self.nodes) do
        if v.y + offsety >= -v.height and v.y + offsety <= viewHeight then
            v:OnShow()
        else
            v:OnHide()
        end
    end
end

function PickerView:GetCurIndex()
    local node = self:getCenterNode()
    if node then
        return node.index
    end
    return 0
end

--------------------------------------------------------  惯性滚动逻辑 --------------------------------------------------------
-- 以下划线开头的变量都是惯性滚动相关变量


local NUMBER_OF_GATHERED_TOUCHES_FOR_MOVE_SPEED = 5

local function calculateAutoScrollTimeByInitialSpeed(initialSpeed)
    --  Calculate the time from the initial speed according to quintic polynomial.
    local time = math.sqrt(math.sqrt(initialSpeed / 5))
    return time
end

local function quintEaseOut(time)
    time = time - 1
    return (time * time * time * time * time + 1)
end

local function vec2GetLength(pt)
    return math.sqrt( pt.x * pt.x + pt.y * pt.y )
end

function PickerView:gatherTouchMove(delta)
    while (#self._touchMoveDisplacements >= NUMBER_OF_GATHERED_TOUCHES_FOR_MOVE_SPEED) do
        table.remove(self._touchMoveDisplacements, 1)
        table.remove(self._touchMoveTimeDeltas, 1)
    end
    table.insert(self._touchMoveDisplacements, delta)
    
    local timestamp = self.deltaTime
    table.insert(self._touchMoveTimeDeltas, timestamp - self._touchMovePreviousTimestamp)
    self._touchMovePreviousTimestamp = timestamp
end

function PickerView:calculateTouchMoveVelocity()
    local totalTime = 0

    for k, v in pairs(self._touchMoveTimeDeltas) do
        totalTime = totalTime + v
    end

    if totalTime == 0 or totalTime >= 0.5 then
        return vec2(0, 0)
    end

    local totalMovement = vec2(0, 0)
    for k, v in pairs(self._touchMoveDisplacements) do
        totalMovement.x = totalMovement.x + v.x
        totalMovement.y = totalMovement.y + v.y
    end

    return vec2(totalMovement.x / totalTime, totalMovement.y / totalTime)
end

function PickerView:startInertiaScroll(touchMoveVelocity)
    local MOVEMENT_FACTOR = 0.7
    local inertiaTotalMovement  = vec2(touchMoveVelocity.x * MOVEMENT_FACTOR, touchMoveVelocity.y * MOVEMENT_FACTOR)
    self:startAttenuatingAutoScroll(inertiaTotalMovement, touchMoveVelocity)
end

function PickerView:startAttenuatingAutoScroll(deltaMove, initialVelocity)
    local time = calculateAutoScrollTimeByInitialSpeed(vec2GetLength(initialVelocity))
    
    self._autoScrolling                  = true
    self._autoScrollTargetDelta          = deltaMove
    self._autoScrollStartPosition        = self.container.xy
    self._autoScrollTotalTime            = time
    self._autoScrollAccumulatedTime      = 0
end

function PickerView:processAutoScrolling(deltaTime)
    -- Elapsed time
    self._autoScrollAccumulatedTime = self._autoScrollAccumulatedTime + deltaTime

    -- Calculate the progress percentage
    local percentage = math.min(1, self._autoScrollAccumulatedTime / self._autoScrollTotalTime)

    percentage = quintEaseOut(percentage)

    -- Calculate the new position
    -- local newPositionX = self._autoScrollStartPosition.x + self._autoScrollTargetDelta.x * percentage
    local newPositionY = self._autoScrollStartPosition.y + self._autoScrollTargetDelta.y * percentage
    local reachedEnd  = abs(percentage - 1) <= 0.001 or abs(newPositionY - self.curContainerPosy) <= 0.1

    if reachedEnd then
        -- newPositionX = self._autoScrollStartPosition.x + self._autoScrollTargetDelta.x
        newPositionY = self._autoScrollStartPosition.y + self._autoScrollTargetDelta.y
    end

    -- Finish auto scroll if it ended
    if reachedEnd then
        self._autoScrolling = false
        -- print("滚动完成================>>")
    end

    -- -- 自动滚动到中心位置
    local moveDeltay = newPositionY - self.curContainerPosy
    
    self:OnChangePosy(moveDeltay)

    if not self._autoScrolling and self.onScrollEndCallback then
        self.onScrollEndCallback()
    end
end

function PickerView:getCenterNode()
    local viewHeight = self.viewHeight
    local offsety = self.curContainerPosy

    local minNode, minOffset
    -- 查找距离中心最近的cell
    for k, v in pairs(self.nodes) do
        if v.visible then
            local posYInView = v.y + offsety + v.height * 0.5
            local offset = posYInView - viewHeight * 0.5
            if minOffset == nil or abs(offset) < abs(minOffset) then
                minOffset = offset
                minNode = v
            end
        end
    end

    return minNode, minOffset
end

return PickerView