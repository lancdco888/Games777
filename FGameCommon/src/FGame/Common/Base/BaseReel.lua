--[[
    转轴基类
]]
---@class BaseReel
local BaseReel = Class("BaseReel")

local allRunningReels = {}

-- 当前转轴状态
local State = {
    Waiting     = 1,    -- 等待延迟时间结束
    Lifting     = 2,    -- 正在执行抬起动画
    Scrolling   = 3,    -- 正在执行滚动动画
    Bouncing    = 4,    -- 正在执行回弹动画
    None        = 5,    -- 静止状态
}
BaseReel.State = State

-- 缓动类型
local EaseType = {
    QuadIn   = 1,
    QuadOut  = 2,
}

local function EaseFunc(easeType, time, duration)
    if duration <= 0 then return 1 end
    if easeType == EaseType.QuadIn then
        time = time / duration
        return time * time
    elseif easeType == EaseType.QuadOut then
        time = time / duration
        return -time * (time - 2)
    else
        assert(false)
    end
end

local function lerp(p1, p2, alpha)
    return p1 * (1 - alpha) + p2 * alpha
end


-- @param parent 
-- @param idx 当前列下标
-- @param symbolNum 图标数量
function BaseReel:ctor(parent, idx, symbolNum)
    self.cfg = clone(FCasinoCtx.gameCfg.Reel)

    self.idx = idx
    -- 图标数量
    self.symbolNum = symbolNum
    -- 当前状态
    self.curState = State.None
    -- 当前状态运行时间
    self.curTime = 0
    -- 滚动状态累计滚动格子数量
    self.rollSymbolNum = 0
    -- 偏移值
    self.offset = 0

    self.deltaTime = 0
    self.timeScale = 1

    -- 容器
    ---@type FairyGUI.GComponent
    self.reelContainer = FairyGUI.GComponent()
    self.reelContainer.opaque = false
    parent:AddChild(self.reelContainer)

    local data = setmetatable({}, {__mode = "kv"})
    data.reel = self
    table.insert(allRunningReels, data)
end

function BaseReel:__delete()
    self.reelContainer:RemoveFromParent(true)
end

-- @brief 初始化显示图案
-- @param data 初始化数据（可选）
function BaseReel:InitSymbol(data)
    -- 计算单个图案高度
    self.cfg.symbolWidth  = self.cfg.reelWidth
    self.cfg.symbolHeight = self.cfg.reelHeight / self.symbolNum
    self.reelContainer.width = self.cfg.reelWidth
    self.reelContainer.height = self.cfg.reelHeight
    -- 图案数据
    self.arraySymbolDatas = {}
    for i = 0, self.symbolNum + 1 do
        if data and data[i] then
            self.arraySymbolDatas[i] = data[i]
        else
            self.arraySymbolDatas[i] = self:RandomSymbolData()
        end
    end
    -- 图案显示
    self.arraySymbolDisplays = {}
    for i = 0, self.symbolNum + 1 do
        self:NewSymbolRenderComponent(i)
    end

    -- 触发渲染刷新
    self:SetOffset(0)
end

function BaseReel:IsFreeState()
    return self.curState == State.None
end

-- @brief 旋转
-- @param speed 滚动速度(可选)
-- @param delay 延迟时间(可选)
function BaseReel:SpinForever(speed, delay)
    if self.curState ~= State.None and not RUNTIME_IN_CREATOR then
        FSysEventEmitter:Emit(FSysEvent.ON_GAME_REEL_STATE_ERROR)
    end
    assert(self.curState == State.None, "self.curState:" .. tostring(self.curState).." FCasinoCtx.curSpinStatus:" .. FCasinoCtx.curSpinStatus)

    self:SetOffset(0)
    -- 重置滚动数量
    self.rollSymbolNum = 0
    self.bShowResult = false
    self.delayTime = delay or 0
    self.isClickQuickStop = false

    if self:IsQuickMode() then
        self.delayTime = 0
    end

    speed = speed or self.cfg.scrollSpeed

    self.scrollSpeed = speed * self.cfg.symbolHeight * 60

    self:OnScrollBegin()
    self:SetState(State.Waiting)
end

-- @brief 停止旋转
-- @param lastSymbols 图案数据
-- @param callback 回调函数
-- @param delayTime 延迟时间
function BaseReel:Stop(lastSymbols, callback, delayTime)
    assert(#lastSymbols >= self.symbolNum, "#lastSymbols:" .. tostring(#lastSymbols) .. ", self.symbolNum:" .. tostring(self.symbolNum))
    self.onStopCallback = callback
    lastSymbols = clone(lastSymbols)

    -- 处于静止状态或回弹状态，直接展示结果
    if self.curState == State.None or self.curState == State.Bouncing then
        self:OnShowSymbolStart(true)
        self:OnShowSymbolEnd(true)
        self:Recovery(lastSymbols)
        if self.onStopCallback then
            self.onStopCallback()
        end
    else
        self.bShowResult = true
        self.lastSymbols = lastSymbols
        self.showResultDelayTime = delayTime or 0
    end
end

-- @brief 恢复图案，直接展示结果
function BaseReel:Recovery(lastSymbols)
    if lastSymbols == nil then
        lastSymbols = {}
        for i = 1, self.symbolNum do
            lastSymbols[i] = self:RandomSymbolData()
        end
    end

    assert(#lastSymbols == self.symbolNum)
    for k, v in pairs(lastSymbols) do
        self.arraySymbolDatas[k] = v
    end

    self:SetOffset(0)
    self:SetState(State.None)
    self.bShowResult = false
    self:OnScrollEnd()
end

-- @brief 快速停止
function BaseReel:QuickStop()
    if self.bShowResult then
        self.rollSymbolNum = self.cfg.rollSymbolMinNum
        self.showResultDelayTime = 0
        self.isClickQuickStop = true
    end
end

-- @brief 当前是否处于加速模式
function BaseReel:IsQuickMode()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        return FCasinoCtx.commonPanel:IsAccelerationMode() or self.isClickQuickStop
    else
        return false
    end
end

-- @interface
-- @brief 返回随机图案数据
-- @return any 自定义数据结构
function BaseReel:RandomSymbolData()
    assert(false, "not implemented")
end

-- @interface
-- @brief 刷新图案
-- @param render : FairyGUI.GComponent
-- @param data : any  RandomSymbolData 函数返回的数据
-- @param index: number
function BaseReel:UpdateSymbol(render, data, index)
    assert(false, "not implemented")
end

-- @interface
-- @brief 刷新背景图案
-- @param render : FairyGUI.GComponent
-- @param data : any  RandomSymbolData 函数返回的数据
-- @param index: number
function BaseReel:UpdateSymbolBackground(render, data, index)
    assert(false, "not implemented")
end

-- @interface 
-- @brief 开始旋转回调函数
function BaseReel:OnScrollBegin()
end

-- @interface 
-- @brief 旋转结束回调函数
function BaseReel:OnScrollEnd()
end

-- @interface
-- @brief 开始展示结果数据
function BaseReel:OnShowSymbolStart(isQuickMode)
end

-- @interface
-- @brief 开始展示结果数据
function BaseReel:OnShowSymbolEnd(isQuickMode)
end

-- @interface
-- @brief 回弹开始回调函数
function BaseReel:OnBounceStart()
end

-- @interface
-- @brief 创建渲染组件背景接口
function BaseReel:OnCreateSymbolBackgroundRenderComponent()
end

-- @interface
-- @brief 创建渲染组件接口
function BaseReel:OnCreateSymbolRenderComponent()
    local render = FairyGUI.GComponent()
    render.width = self.cfg.symbolWidth
    render.height = self.cfg.symbolHeight
    return render
end

-- @interface
-- @brief 图标排序接口
function BaseReel:OnUpdateSymbolZorder(render, data, index)
    render.sortingOrder = index
end

-- @interface
-- @brief 背景图标排序接口
function BaseReel:OnUpdateSymbolBackgroundZorder(render, data, index)
    render.sortingOrder = -1
end

-- @brief 延迟时间是否受快速模式影响 为true则不受快速模式影响
function BaseReel:SetDelayTimeIgnoreQuickMode(value)
    self.bDelayIgnoreQuickMode = value
end

------------------------------------------------------------------- private -------------------------------------------------------------------
-- @brief 创建新的渲染组件
function BaseReel:NewSymbolRenderComponent(i)
    local background = self:OnCreateSymbolBackgroundRenderComponent(i)
    if background then
        background.opaque = false
        background:SetPivot(0.5, 0.5, true)
        background.x = self.cfg.reelWidth * 0.5
        background.y = self.cfg.symbolHeight * (i - 0.5)
        self.reelContainer:AddChild(background)
    end
    

    local render = self:OnCreateSymbolRenderComponent(i)
    render.opaque = false
    render:SetPivot(0.5, 0.5, true)
    render.x = self.cfg.reelWidth * 0.5
    render.y = self.cfg.symbolHeight * (i - 0.5)
    self.reelContainer:AddChild(render)
    self.arraySymbolDisplays[i] = {render = render, data = nil, background = background}
end

-- @brief 设置当前状态
function BaseReel:SetState(state)
    self.curTime  = 0
    self.curState = state
end


-- @brief update
function BaseReel:Update(dt)
    if self.curState == State.None then
        return
    end
    dt = dt * self.timeScale
    self.curTime = self.curTime + dt
    self.deltaTime = dt

    if self.curState == State.Waiting then
        -- 延迟时间结束
        if self.curTime >= self.delayTime then
            if self.cfg.liftDuration > 0 then
                self:SetState(State.Lifting)
            else
                -- 没有抬起动画直接进入滚动阶段
                self:SetState(State.Scrolling)
            end
        end
    -- 抬起动画
    elseif self.curState == State.Lifting then
        local percent  = 0
        local halfDuration = self.cfg.liftDuration * 0.5

        if self.curTime <= halfDuration then
            percent = EaseFunc(EaseType.QuadOut, self.curTime, halfDuration)
        else
            percent = 1 - EaseFunc(EaseType.QuadIn, self.curTime - halfDuration, halfDuration)
        end

        -- 抬起结束
        if self.curTime >= self.cfg.liftDuration then
            self:SetOffset(0)
            self:SetState(State.Scrolling)
        else
            self:SetOffset(lerp(0, self.cfg.liftDistance, percent))
        end
    elseif self.curState == State.Scrolling then
        self:SetOffset(self.offset + self.scrollSpeed * dt)
    -- 回弹动画
    elseif self.curState == State.Bouncing then
        local percent  = 0
        local bounceDuration = self.cfg.bounceDuration
        local halfDuration = bounceDuration * 0.5

        -- 需求：快速模式不要回弹
        if self:IsQuickMode() then
            halfDuration = 0
            bounceDuration = 0
        end

        if self.curTime <= halfDuration then
            percent = EaseFunc(EaseType.QuadOut, self.curTime, halfDuration)
        else
            percent = 1 - EaseFunc(EaseType.QuadIn, self.curTime - halfDuration, halfDuration)
        end

        -- 回弹结束
        if self.curTime >= bounceDuration then
            self:SetOffset(0)
            self:SetState(State.None)
            -- 旋转结束
            self.bShowResult = false
            self:OnScrollEnd()
            if self.onStopCallback then
                self.onStopCallback()
            end
        else
            self:SetOffset(lerp(0, self.cfg.bounceDistance, percent))
        end
    else
        assert(false, "unknown state:" .. tostring(self.curState))
    end
end

-- @brief 设置当前偏移值
function BaseReel:SetOffset(value)
    local space = self.cfg.symbolHeight

    if self.curState == State.Scrolling then
        while value >= space do
            value = value - space
            -- 滚动格子数量+1
            self.rollSymbolNum = self.rollSymbolNum + 1
            if not self.bShowResult and self.rollSymbolNum >= self.cfg.rollSymbolMinNum then
                self.rollSymbolNum = self.cfg.rollSymbolMinNum
            end

            -- 保存最后一个图案渲染信息
            local lastRender = self.arraySymbolDisplays[self.symbolNum + 1]

            for i = self.symbolNum + 1, 1, -1 do
                -- 数据交换
                self.arraySymbolDatas[i] = self.arraySymbolDatas[i - 1]
                -- 渲染交换,减少图案刷新次数
                self.arraySymbolDisplays[i] = self.arraySymbolDisplays[i - 1]
            end

            local needRandom = true

            -- 结果返回了
            if self.bShowResult then
                -- 最小滚动数量
                local minNum = self.cfg.rollSymbolMinNum

                -- 加速模式，只要结果回来立即显示
                if self:IsQuickMode() or self.rollSymbolNum >= minNum then
                    if self.showResultDelayTime <= 0 or (self:IsQuickMode() and not self.bDelayIgnoreQuickMode) then
                        needRandom = false
                        -- 展示最终结果图案
                        if next(self.lastSymbols) then
                            if #self.lastSymbols == self.symbolNum then
                                self:OnShowSymbolStart(false)
                            end
                            self.arraySymbolDatas[0] = table.remove(self.lastSymbols)
                        else
                            self:OnShowSymbolEnd(false)
                            value = 0
                            self.arraySymbolDatas[0] = self:RandomSymbolData()
                            -- 旋转结束,进入回弹模式
                            self:SetState(State.Bouncing)
                            self:OnBounceStart()
                        end
                    end
                end
            end

            -- 结果未知或显示结果条件不达标，填充随机图案
            if needRandom then
                self.arraySymbolDatas[0] = self:RandomSymbolData()
            end

            -- 交换渲染信息
            lastRender.data = nil
            self.arraySymbolDisplays[0] = lastRender
        end

        if self.bShowResult and self.showResultDelayTime > 0 then
            if self:IsQuickMode() or self.rollSymbolNum >= self.cfg.rollSymbolMinNum then
                -- 延迟显示结果
                self.showResultDelayTime = self.showResultDelayTime - self.deltaTime
            end
        end
    end

    self.offset = value
    self:UpdateDraw()
end

-- @brief 绘制刷新
function BaseReel:UpdateDraw()
    for i = 0, self.symbolNum + 1 do
        local symbol = self.arraySymbolDisplays[i]
        if symbol.data ~= self.arraySymbolDatas[i] then
            symbol.data = self.arraySymbolDatas[i]

            self:UpdateSymbol(symbol.render, symbol.data, i)
            if symbol.background then
                self:UpdateSymbolBackground(symbol.background, symbol.data, i)
            end
        end

        -- 位置更新
        symbol.render.y = (i - 0.5) * self.cfg.symbolHeight + self.offset
        self:OnUpdateSymbolZorder(symbol.render, symbol.data, i)

        if symbol.background then
            symbol.background.y = (i - 0.5) * self.cfg.symbolHeight + self.offset
            self:OnUpdateSymbolBackgroundZorder(symbol.background, symbol.data, i)
        end
    end
end

function BaseReel:UpdateBounsValue()
    for i = 0, self.symbolNum + 1 do
        local symbol = self.arraySymbolDisplays[i]
        self:UpdateSymbol(symbol.render, symbol.data, i)
    end
end
----------------------------------------------------------------- Utils -----------------------------------------------------------------

-- @brief 
function BaseReel.ClearAllRunningReels()
    allRunningReels = {}
end

-- @brief 所有转轴都处于静止状态?
function BaseReel.IsAllInNoneState()
    local ok = true

    local reel
    for _, v in pairs(allRunningReels) do
        reel = v.reel
        if reel and reel.curState ~= State.None then
            ok = false
            break
        end
    end
    return ok
end

return BaseReel
