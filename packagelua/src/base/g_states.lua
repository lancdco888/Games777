-- 状态机集合
gStates = {}

-- 设状态( 会自动 Close 相同 state.stateGroupName 下的旧状态, 接着 Open 新状态 ), 设置完后返回
function gStates_Set(state,...)
	local yield = coroutine.yield
	local s = gStates[state.stateGroupName]
	if s ~= nil then
		xpcall(s.Close, __G__TRACKBACK__)
	end
	gStates[state.stateGroupName] = state
	local func = handler(..., state.Open)
	xpcall(func, __G__TRACKBACK__, s)
end

-- 关状态, 关完后返回
-- 适合在 coro 环境使用
function gStates_CloseByGroupName(gn)
	local yield = coroutine.yield
	yield()
	local s = gStates[gn]
	if s ~= nil then
		xpcall(s.Close, __G__TRACKBACK__)
	end
	gStates[gn] = nil
end

-- 关状态, 关完后返回
-- 适合在 coro 环境使用
function gStates_Close(state)
	gStates_CloseByGroupName(state.stateGroupName)
end

-- 开始设状态(异步非阻塞)
function gStates_SetAsync(state,...)
	local args = {state, ...}
	local protected = function() xpcall(gStates_Set, __G__TRACKBACK__, unpack(args)) end
	local co = coroutine.create(protected)
	local ok, msg = coroutine.resume(co)
	if not ok then
		print("resume error:", msg)
		return
	end
	gCoros_PushCo(co)
end

-- 开始关状态(异步非阻塞)
function gStates_CloseAsync(state)
	local protected = function() xpcall(gStates_Close, __G__TRACKBACK__, state) end
	local co = coroutine.create(protected)
	local ok, msg = coroutine.resume(co, state)
	if not ok then
		print("resume error:", msg)
		return
	end
	gCoros_PushCo(co)
end

--找到对应的状态
function gStates_GetState(name)
	local t = gStates
	for _, s in pairs(t) do
		if s.stateName == name then
			return s
		end
	end
	return nil
end

-- 根据状态名查找是否存在
function gStates_Exists(name)
	local t = gStates
	for _, s in pairs(t) do
		if s.stateName == name then
			return true
		end
	end
	return false
end

-- 等 state 出现
-- 适合在 coro 环境使用
gStates_WaitAppear = function(state)
	local yield = coroutine.yield
	while not gStates_Exists(state.stateName) do
		yield()
	end
end

-- 等 state 消失
-- 适合在 coro 环境使用
gStates_WaitDisappear = function(state)
	local yield = coroutine.yield
	while gStates_Exists(state.stateName) do
		yield()
	end
end

--[[

state 基础示例:

local this = {}

this.stateName = "Xxxxxx"	-- 状态名
this.stateGroupName = "scene"	-- 类似 Login, Lobby, GameXxx 这种全屏切换状态, 分组名都是一致的, 以便实现互顶
this.opened = false

this.Open = function()
	assert(not this.opened)

	-- 绘制/创建逻辑( 相关对象放入 this )

	-- 注册事件/Update 啥的

	this.opening = true
	-- 开始动画后设置 this.opening = nil

	-- 等动画完成
	while this.opening do coroutine.yield() end

	this.opened = true
end

this.Close = function()
	assert(this.opened)

	-- 反注册事件/Update 啥的

	this.closing = true
	-- 关闭动画后设置 this.closing = nil

	-- 等动画完成
	while this.closing do coroutine.yield() end

	-- 回收绘制/创建资源并置nil( 类似下面的代码 )
	this.Xxxxx:removeFromParent()
	this.Xxxxx = nil

	this.opened = false
end

return this

]]
