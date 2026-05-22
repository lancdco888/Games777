-- 用于注册更新函数. 直接往里面放函数或移除. 每帧将逻辑无序遍历执行.
gUpdates = {}

-- 比自己直接在表上赋值安全点
gUpdates_Set = function(key, func)
	if gUpdates[key] ~= nil then
		print("warning: gUpdates_Set key = "..key.." exists.")
	else
		gUpdates[key] = func
	end
end

gUpdates_Close = function(key)
	if(gUpdates[key] ~= nil)then
		gUpdates[key] = nil
	end
end

-- 执行所有 update 函数
gUpdates_Exec = function()
	local t = gUpdates
	for k, f in pairs(t) do
		-- f()
		xpcall(f, __G__TRACKBACK__)
	end
end
