FairyGUI = CS.FairyGUI

local fairyRoot = nil

-- @brief 创建fairyRoot
function CreateFairyRoot()
	assert(fairyRoot == nil)
	
	fairyRoot = FairyGUI.GRoot.inst
	-- 设置设计分辨率
	if APIGateway.IsDeviceOrientationPortrai() then
		fairyRoot:SetContentScaleFactor(720, 1280)
	else
		fairyRoot:SetContentScaleFactor(1280, 720)
	end
	APIGateway.OnEnter()
	return fairyRoot
end

-- @brief 销毁fairyRoot
function DestroyFairyRoot()
	if fairyRoot ~= nil then
		APIGateway.OnDestroy(fairyRoot)
	end
	-- 清理所有 Tween 动画
	FairyGUI.GTween.Clean()
	fairyRoot = nil
end

function GetFairyRoot()
	return fairyRoot
end
