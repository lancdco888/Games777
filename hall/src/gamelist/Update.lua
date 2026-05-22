local Update = class("Update")

Update.State = {
	Error = 0,					-- 没有这个游戏的配置
	Updated = 1,				-- 已最新,无需更新
	NeedUpdate = 2,				-- 需要更新，但是未开始更新
	Updating = 3				-- 更新中
}

function Update:ctor()
	-- 总是认为 modules 的配置是最新的，如果该模块不存在，就去底层获取最新数据
	self.modules = { --[[
		-- [ moduleName ] = {
			state
			percent
		}
		]]
	}

	self.callbacks = {
		--[[
		-- [ game_id ] = {
			onSuccess
			onFailed
			onPercent
		}
		]]
	}
end

function Update:getModuleName(gameId)
	local resGameId = GameData:GetGameID(gameId)

	local moduleName
	if not resGameId then
		return
	elseif resGameId < 200 then
		moduleName = "fish_" .. resGameId
	else
		local fguiRunTimeSupport = Tools.IsFGUIRuntimeSupport()
		if fguiRunTimeSupport and GameData:IsFGUIReleaseGame(resGameId) then
			moduleName = "FGame" .. resGameId
		elseif GameData:IsCocosSupportGame(resGameId) then
			moduleName = "casino" .. resGameId
		else
		end
	end

	return moduleName
end

----------------------------------------------------------------------------

function Update:checkGameStatus(gameId)
    -- 昌盛捕鱼不检查这个更新
    if gameId >= 109 and gameId <= 124 then
        return Update.State.Updated
    end

	local moduleName = self:getModuleName(gameId)
	if not moduleName then
		return Update.State.Error
	end

	local module = self.modules[moduleName]
	if module then
		-- 本地有配置就认为是最新的
		return module.state or Update.State.Error
	end

	-- 新建 module
	module = {
		state = Update.State.Error,
		percent = 0
	}
	self.modules[moduleName] = module

	-- 无需更新
	local bNeedUpdate = sDownloadMgr.CheckModule(moduleName)
	if bNeedUpdate then
		module.state = Update.State.NeedUpdate
	else
		module.state = Update.State.Updated
	end
	return module.state
end

---------------------------------------------------------------------------------------

function Update:getCallback(moduleName)
	local callbacks = self.callbacks
	local all = {}
	for gameId, cbk in pairs(callbacks) do
		local name = self:getModuleName(gameId)
		if name == moduleName then
			if ( not cbk.onSuccess ) or ( not cbk.onFailed ) or ( not cbk.onPercent ) then
				print("Update.getAllCbks(), bad callback, ignore.")
			end
			table.insert(all, cbk)
		end
	end
	return all
end

function Update:startUpdate(moduleName)
	local module = self.modules[moduleName]
	if not module or module.state ~= Update.State.NeedUpdate then
		print("start update failed, bad state for :" .. tostring(moduleName))
		return false
	end

	-- 底层更新逻辑
	local updateFunc = function(module_)
		module.percent = sDownloadMgr.updateTask[module_].percent
		local cbks = self:getCallback(module_)
		for __, cbk in ipairs(cbks) do
			if cbk.onPercent then cbk.onPercent(module.percent) end
		end
	end

	sDownloadMgr.UpdatingCallBack[moduleName] = updateFunc
	local endFunc = function(module_)  -- success
		module.state = Update.State.Updated
		local cbks = self:getCallback(module_)
		for __, cbk in ipairs(cbks) do
			if cbk.onSuccess then cbk.onSuccess() end
		end
	end
	sDownloadMgr.EndCallBack[moduleName] = endFunc

	local failedFunc = function(module_)
		module.state = Update.State.NeedUpdate
		local cbks = self:getCallback(module_)
		for __, cbk in ipairs(cbks) do
			if cbk.onFailed then cbk.onFailed() end
		end
    end
    if sDownloadMgr.FailedCallBack then
        sDownloadMgr.FailedCallBack[moduleName] = failedFunc
    end

	sDownloadMgr.StartDownloadTask(moduleName)
	module.state = Update.State.Updating
	module.percent = 0
	return true
end

---------------------------------------------------------------------------------------
-- 简单一点，一个游戏只有一组回调

function Update:register(gameId, onSuccess, onFailed, onPercent)
	local cbk = {
		onSuccess = onSuccess,
		onFailed = onFailed,
		onPercent = onPercent
	}
	self.callbacks[gameId] = cbk
end

function Update:unregister(gameId)
	self.callbacks[gameId] = nil
end

function Update:update(gameId)
	local moduleName = self:getModuleName(gameId)
	if not moduleName then
		print("no such module name for :" .. tostring(gameId))
		return false
	end

	local module = self.modules[moduleName]
	if not module then
		print("no such module for :" .. moduleName)
		return false
	end

	local state = module.state
	if state == Update.State.Error then
		print("Update:update() state error :" .. moduleName)
		return false
	elseif state == Update.State.Updated then
		return true
	elseif state == Update.State.NeedUpdate then
		return self:startUpdate(moduleName)
	elseif state == Update.State.Updating then
		return true
	else
		print("Update:update() state error :" .. tostring(state))
		return false
	end

	return true
end

function Update:getUpdatingCount()
	local cnt = 0
	for moduleName, module in pairs(self.modules) do
		if module.state == Update.State.Updating then
			cnt = cnt + 1
		end
	end
	return cnt
end

function Update:destroy()
	self.modules = {}
	self.callbacks = {}
end

return Update.new()
