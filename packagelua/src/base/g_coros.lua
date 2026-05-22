-- 全局协程池( 乱序 )
local gCoros = {}

-- 压入一个协程函数. 有参数就跟在后面. 有延迟执行的效果. 报错时带 name 显示
go_ = function(name, func, ...)
	local args = {...}
	local p
	if #args == 0 then
		p = function() xpcall(func, __G__TRACKBACK__) end
	else
		p = function() xpcall(func, __G__TRACKBACK__, table.unpack(args)) end
	end
	local co = coroutine.create(p)
	table.insert(gCoros, co)
	return co
end
-- 压入一个协程函数. 有参数就跟在后面. 有延迟执行的效果
go = function(func, ...)
	if func == nil then
		__G__TRACKBACK__("go(), func == nil")
		return
	end

	return go_("", func, ...)
end
gCoros_PushCo = function(co)

	table.insert(gCoros, co)
end
-- 压入一个协程函数 并立刻 resume 一次. 有参数就跟在后面
gorun  = function(func, ...)
	local co = go(func, ...)
	local ok, msg = coroutine.resume(co)
	if not ok then
		print("coroutine.resume error:", msg)
	end
	return co
end

local socket = require("socket")

-- 核心帧回调. 执行所有 coros
goexec = function()
	local cs = coroutine.status
	local cr = coroutine.resume
	local t = gCoros
	if #t == 0 then return end
	-- print("############## co - count ############### :" .. #t)
	for i = #t, 1, -1 do
		local co = t[i]
		if cs(co) == "dead" then
			t[i] = t[#t]
			t[#t] = nil
		else
			local ok, msg = cr(co)
			if not ok then
				print("coroutine.resume error:", msg)
			end
		end
	end
end

yield = coroutine.yield
