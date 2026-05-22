local RechargeFirstLayer = class("RechargeFirstLayer", function()
    return Tools.CreateLayer("csb/lobby/RechargeFirstLayer.csb")
end)

function RechargeFirstLayer:onEnter()
	self:InitUI()
	self:showCenterTitle(false)
end

function RechargeFirstLayer:showCenterTitle(show)
    local title_center = self:findChild("title_center")
    if title_center then
        title_center:setVisible(show)
    end
    local title = self:findChild("title")
    if title then
        title:setVisible(not show)
    end
end

function RechargeFirstLayer:SetCloseFunc(isClose,closefunc)
	local btn_close = self:findChild("btn_close")
	btn_close:setVisible(isClose)
    if closefunc then
        local func = self.Close
        self.Close = function ()
			if func then
                func()
            end 
            closefunc()
        end
    end
end

function RechargeFirstLayer:InitUI()
    local btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:Close()
    end, true)

	self:InitPanel()

	local _lang_recharge = self:findChild("_lang_recharge")
    Tools.AddClickEvent(_lang_recharge, function()
        sGameManager.PopRecharge()
    end, true)
end

function RechargeFirstLayer:InitPanel()
    local Image_10 = self:findChild("Image_10")
    local Image_10_0 = self:findChild("Image_10_0")
    local isbj = UserData.activity_give_type == 0
    Image_10:setVisible(isbj)
    Image_10_0:setVisible(not isbj)
    local bg = self:findChild("bg")
    local bg_0 = self:findChild("bg_0")
    bg:setVisible(isbj)
    bg_0:setVisible(not isbj)

	local money = self:findChild("money")
	local num = self:findChild("num")

	local info = activity.logic:GetFirstRechargeInfo()
	money:setString(tostring(
		info.recharge / sGameManager.exchangerate)
	)
	num:setString(tostring(
		info.gift / sGameManager.exchangerate)
	)
end

return RechargeFirstLayer
