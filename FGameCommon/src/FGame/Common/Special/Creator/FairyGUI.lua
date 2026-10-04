FairyGUI = {}
local FGUI = CREATOR.FGUI

setmetatable(FairyGUI,{
	__index = function(table,key)
		return FGUI[key]
	end
})

FairyGUI.GComponent = function()
	return FGUI.UIObjectFactory.NewObject(9)
end

FairyGUI.GLoader = function()
	return FGUI.UIObjectFactory.NewObject(4)
end

FairyGUI.GLoader3D = function ()
	return FGUI.UIObjectFactory.NewObject(18)
end

require("FGame.Common.Functions.Compatible")

-- 设置音效回调
FairyGUI.UIConfig.onMusicCallback = function(path, volumnScale)
	APIGateway.PlaySound(path,false);
	--gSound:playEffect(path, false)
	return true;
end

local fairyRoot = nil

-- @brief 创建fairyRoot
function CreateFairyRoot()
	assert(fairyRoot == nil)
    fairyRoot = FairyGUI.GRoot.create();
    -- fairyRoot:retain()
	APIGateway.OnEnter()
	return fairyRoot
end

-- @brief 销毁fairyRoot
function DestroyFairyRoot()
	if fairyRoot then
		APIGateway.OnDestroy(fairyRoot)
		local root = fairyRoot
		local handle

		fairyRoot = nil

		-- 延迟一帧删除
		handle = StartOnceTimer(function()
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handle)

			root.displayObject:removeFromParent()
			root:release()
			FairyGUI.HtmlObject:ClearStaticPools()
			FairyGUI.DragDropManager:DestroyInstance()
			FairyGUI.GCache.Destroy()
			-- 清理所有 Tween 动画
			FairyGUI.GTween.Clean()
		end, 0)
	end
end

function GetFairyRoot()
	return fairyRoot
end
