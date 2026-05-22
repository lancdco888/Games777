--[[
    四种类型：
]]
local RebateLayer = class("RebateLayer", function()
    return Tools.CreateLayer("csb/lobby/RebateLayer.csb")
end)

function RebateLayer:onEnter()
    self:UpdateTips()
	self:InitUI()
    self:showCenterTitle(false)
end

function RebateLayer:UpdateTips()
    local tips_2 = self:findChild("tips_2")
    if not tips_2 then
        return
    end
    if not self.rebate_id then
        tips_2:setString("")
        return
    end

    local tips = {
        ["HOUR"] = TR("小时"),
        ["DAY"] = TR("天"),
        ["WEEK"] = TR("周"),
        ["MONTH"] = TR("月"),
    }
    local cfg = activity.logic:GetActivityCfg(self.rebate_id)
    local rebate_type = activity.logic:GetRebateType(self.rebate_id)
    local tip = tips[rebate_type]
    local av = cfg.activity_value
    if rebate_type == "WEEK" then
        av = av/7
    end
    
    if tip then
        tips_2:setString(string.format(TR("%d%s发放一次奖励，奖励保存%d小时，限时未领取作废。"), av, tip, cfg.reward_timeout))
    else
        tips_2:setString("")
    end
end

function RebateLayer:showCenterTitle(show)
    local title_center = self:findChild("title_center")
    if title_center then
        title_center:setVisible(show)
    end
    local title = self:findChild("title")
    if show then
        title:setVisible(false)
    end
end

function RebateLayer:SetCloseFunc(isClose,closefunc)
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
    local quyouxi = self:findChild("_lang_quyouxi")
    quyouxi:setVisible(not isClose)
    Tools.AddClickEvent(quyouxi, function()
        self:Close()
    end, true)
end

function RebateLayer:InitUI()
    local can_give = activity.logic:CanGiveByID(self.rebate_id)
    local cfg = activity.logic:GetActivityCfg(self.rebate_id)

    local btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:Close()
    end, true)

	local btn_quyouxi = self:findChild("_lang_quyouxi")
    if can_give then
        btn_quyouxi:setVisible(false)
    else
        if btn_close:isVisible() then
            btn_quyouxi:setVisible(false)
        else
            btn_quyouxi:setVisible(true)
        end
    end

    local time = self:findChild("time")
    time:setString(cfg.time)

    local vip = self:findChild("vip")
    local cfg_vip = cfg.vip
    if vip then
        if cfg_vip and cfg_vip > 0 then
            local str_ = string.format(
                TR("VIP%d以上"),
                cfg_vip
            )
            vip:setString(str_)
        else
            vip:setString(TR("所有玩家"))
        end
    end

    local _lang_tips = self:findChild("_lang_tips")
    local isbj = UserData.activity_give_type == 0
    if not isbj then
        _lang_tips:setString(TR("游戏时间越多，返利越多。"))
    end

    self:InitAward()
end

function RebateLayer:setRebateId(rebate_id)
    self.rebate_id = rebate_id
    self:UpdateTips()
	self:InitUI()
end

-- 初始化领取界面
function RebateLayer:InitAward()
    -- 宝箱 和 领取动画
    local baoxiang = self:findChild("baoxiang")
    local btn_award = baoxiang:findChild("btn_award")
    local empty = baoxiang:findChild("empty")
    local full_ani_node = baoxiang:findChild("full_ani_node")
    local can_give = activity.logic:CanGiveByID(self.rebate_id)

    if can_give then
        -- 有奖励可领取, 显示宝箱动画 和 领取 按钮
        btn_award:setVisible(true)
        full_ani_node:setVisible(true)
        empty:setVisible(false)

        full_ani_node:removeAllChildren()
        local eft = self:MakeEffect(
            "hall/res/effect/hall_baoxiang/hall_baoxiang.json",
            "hall/res/effect/hall_baoxiang/hall_baoxiang.atlas",
            "hall_baoxiang_1",
            true
        )
        eft:setName("eft")
        full_ani_node:addChild(eft)
    else
        -- 无奖励领取, 显示空宝箱
        btn_award:setVisible(false)
        full_ani_node:setVisible(false)
        empty:setVisible(true)
    end

    Tools.AddClickEvent(btn_award, function()
        go(
            function ()
                Dispatcher:Pause()  --暂停消息投递
                local isok, data = activity.logic:ReceiveWashcodeActivity(self.rebate_id)
                if isok then
                    btn_award:setVisible(false)
                    local btn_close = self:findChild("btn_close")
                    local is_visible = btn_close:isVisible()
                    local layer = PopLayer:Pop(activity.AwardPopLayer)
                    layer:RunToSafeBoxNum(data.reward_value, false)
                    if data.reward_type == 0 then
                        UserData.money_gift_safe = UserData.money_gift_safe + data.reward_value
                    else
                        UserData.money_safe = UserData.money_safe + data.reward_value
                    end
                    Dispatcher:Dispatch(activity.logic)
                    Dispatcher:Dispatch(UserData) 
                    self:InitUI()
                    Dispatcher:Resume()
                end
            end
        )
        end,
    true)
end

function RebateLayer:MakeEffect(jsonPath, atlasPath, ani_name, isloop, ondone)
    local eft = sp.SkeletonAnimation:createWithJsonFile(jsonPath, atlasPath)
	eft:setAnchorPoint(cc.p(0.5, 0.5))
	eft:setOpacityModifyRGB(false)
	local success = eft:setAnimation(0, ani_name, isloop)
    if not isloop then
        eft:registerSpineEventHandler(function(obj)
            -- 移除该动画
            eft:runAction(
                cc.RemoveSelf:create()
            )
            if ondone then
                ondone()
            end
        end, 3)
    end

	return eft
end

return RebateLayer
