---@class FairyGUI table
FairyGUI = fairygui

if not FairyGUI.GTween.KillAllTweens then
	FairyGUI.GTween.KillAllTweens = function() end
end

----------------------------------------------------- fix begin -----------------------------------------------------

if FGUI_GTween_ToDouble_Raw == nil then
	FGUI_GTween_ToDouble_Raw = FairyGUI.GTween.ToDouble

	local toFunc = FGUI_GTween_ToDouble_Raw
	FairyGUI.GTween.ToDouble = function(v1, v2, v3)
		if v3 <= 0 then
			v3 = 1 / 100
		end
		return toFunc(v1, v2, v3)
	end
end

if FGUI_GTween_To_Raw == nil then
	FGUI_GTween_To_Raw = FairyGUI.GTween.To

	local toFunc = FGUI_GTween_To_Raw
	FairyGUI.GTween.To = function(v1, v2, v3)
		if v3 <= 0 then
			v3 = 1 / 100
		end
		return toFunc(v1, v2, v3)
	end
end

----------------------------------------------------- fix end -----------------------------------------------------

-- 设置音效回调
FairyGUI.UIConfig.onMusicCallback = function(path, volumnScale)
	gSound:playEffect(path, false)
end

local fairyRoot = nil

-- @brief 创建fairyRoot
function CreateFairyRoot()
	assert(fairyRoot == nil)
    fairyRoot = FairyGUI.GRoot(cc.Director:getInstance():getRunningScene(), 10)
    fairyRoot:retain()
	APIGateway.OnEnter()
	return fairyRoot
end

-- @brief 销毁fairyRoot
function DestroyFairyRoot()
	if fairyRoot then
		-- 停止所有声音
		gSound:stopAll()

		-- 清理所有 Tween 动画
		FairyGUI.GTween.Clean()
		FairyGUI.GTween.KillAllTweens()
		-- 清理webm缓存
		ax.Webm:cancelAllAsync()
		ax.Webm:removeAllWebmTexture()
		
		APIGateway.OnDestroy(fairyRoot)
		local root = fairyRoot
		local handle

		fairyRoot = nil

		root.displayObject:setVisible(false)
		-- 延迟一帧删除
		handle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handle)

			root.displayObject:removeFromParent()
			root:release()
			FairyGUI.HtmlObject:ClearStaticPools()
			FairyGUI.DragDropManager:DestroyInstance()
			FairyGUI.GCache.Destroy()
		end, 0, false)
	end
end

function GetFairyRoot()
	return fairyRoot
end
