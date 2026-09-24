-- 游戏界面左侧悬浮菜单

local HoverMenu = Class("HoverMenu")

function HoverMenu:ctor()
    local render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "HoverMenu")
    render:SetPivot(0, 0.5, true)
    render.y = GetFairyRoot().height * 0.5
    render.opaque = false
    GetFairyRoot():AddChild(render)

    self.render = render

    self.btn_arrow = render:GetChild("btn_arrow")
    FToolSet.AddClickListener(self.btn_arrow, handler(self, self.OnClickArrow), false)
    
    local left = render:GetChild("left")
    self.btns = {}
    self.btns.btn_service    = left:GetChild("btn_service")
    self.btns.btn_money      = left:GetChild("btn_money")
    self.btns.btn_bind_money = left:GetChild("btn_bind_money")
    self.btns.btn_recharge   = left:GetChild("btn_recharge")

    FToolSet.AddClickListener(self.btns.btn_service, handler(self, self.OnClickService), false)
    FToolSet.AddClickListener(self.btns.btn_money, handler(self, self.OnClickMoney), false)
    FToolSet.AddClickListener(self.btns.btn_bind_money, handler(self, self.OnClickBindMoney), false)
    FToolSet.AddClickListener(self.btns.btn_recharge, handler(self, self.OnClickRecharge), false)

    self:UpdateBtnStatus()

    local showButtonNames = {"btn_service"}

    -- 绑金功能开启
    if FTheme.curThemName ~= "CrimsonCartoon" and FCasinoCtx.lobbyData.bindGoldCoinEnabled then
        table.insert(showButtonNames, "btn_money")
        table.insert(showButtonNames, "btn_bind_money")
    end
    -- 充值按钮
    if APIGateway.OpenRechargePanel then
        table.insert(showButtonNames, "btn_recharge")
    end


    -- 隐藏不需要的按钮
    for name, btn in pairs(self.btns) do
        local show = false
        for _, v in pairs(showButtonNames) do
            if v == name then
                show = true
                break
            end
        end

        btn.visible = show
    end

    local btnRealHalfHeight = 74 / 2
    local btnHeight = 70
    local arrPosy = {}
    local centerY = left.height * 0.5
    if #showButtonNames % 2 == 0 then
        centerY = centerY + btnHeight * 0.5
    end
    
    -- 重置背景高度
    left:GetChild("img_bg").height = 20 + #showButtonNames * btnHeight

    -- 计算按钮位置
    for i = 1, math.floor(#showButtonNames / 2) do
        table.insert(arrPosy, centerY + i * btnHeight)
        table.insert(arrPosy, centerY - i * btnHeight)
    end
    table.insert(arrPosy, centerY)
    table.sort(arrPosy, function(a, b) return a < b end)

    -- 重置按钮位置
    for i, name in pairs(showButtonNames) do
        self.btns[name].x = 0
        self.btns[name].y = arrPosy[i] - btnRealHalfHeight
    end


    -- 客服红点
    self.service_red_dot = left:GetChild("service_red_dot")
    self.service_red_dot.visible = false
    -- 箭头红点
    self.arrow_red_dot = self.btn_arrow:GetChild("red_dot")
    self.arrow_red_dot.visible = false

    FSysEventEmitter:AddListener(FSysEvent.ON_UPDATE_SERVICE_RED_DOT, function(visible)
        self.service_red_dot.visible = visible
        self.arrow_red_dot.visible = visible
    end, self)
end

function HoverMenu:__delete()
    if self.timer then
        StopTimer(self.timer)
        self.timer = nil
    end
    self.render:RemoveFromParent(true)
    FSysEventEmitter:RemoveListenersByTag(self)
end

function HoverMenu:UpdateBtnStatus()
    local moneyType = FCasinoCtx.commonPanel:GetMoneyType()

    if moneyType == FPlayerMoneyType.NORMAL_MONEY then
        self.btns.btn_money:GetController("c1").selectedIndex = 1
        self.btns.btn_bind_money:GetController("c1").selectedIndex = 0
    else
        self.btns.btn_money:GetController("c1").selectedIndex = 0
        self.btns.btn_bind_money:GetController("c1").selectedIndex = 1        
    end
end

function HoverMenu:OnClickService()
    APIGateway.OpenServicePanel()
end

function HoverMenu:OnClickRecharge()
    APIGateway.OpenRechargePanel()
end

function HoverMenu:OnClickMoney()
    -- 当前不允许更改押注相关信息
    if FCasinoCtx.commonPanel.isLockBetStatus then
        return
    end
    if FCasinoCtx.commonPanel:GetMoneyType() == FPlayerMoneyType.NORMAL_MONEY then
        return
    end
    FCasinoCtx.commonPanel:SetMoneyType(FPlayerMoneyType.NORMAL_MONEY)
    self:UpdateBtnStatus()
end

function HoverMenu:OnClickBindMoney()
    -- 当前不允许更改押注相关信息
    if FCasinoCtx.commonPanel.isLockBetStatus then
        return
    end
    if FCasinoCtx.commonPanel:GetMoneyType() == FPlayerMoneyType.BIND_MONEY then
        return
    end
    FCasinoCtx.commonPanel:SetMoneyType(FPlayerMoneyType.BIND_MONEY)
    self:UpdateBtnStatus()
end

-- @brief 点击右侧导航按钮
function HoverMenu:OnClickArrow()
    if self.timer then
        StopTimer(self.timer)
        self.timer = nil
    end

    local c1 = self.render:GetController("c1")    
    if c1.selectedIndex == 0 then
        c1.selectedIndex = 1
        self.btn_arrow:GetController("c1").selectedIndex = 1
    else
        c1.selectedIndex = 0
        self.btn_arrow:GetController("c1").selectedIndex = 0

        self.timer = StartOnceTimer(function()
            self.timer = nil
            self:OnClickArrow()
        end, 5)
    end
end

return HoverMenu

