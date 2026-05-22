
local EventEmitter = require("FGame.Common.Utils.EventEmitter")
local SpinButton = Class("SpinButton")

function SpinButton:ctor(loader)
    loader.url = FTheme.curThemCfg.spinButtonUrl

    self.render = loader.component
    self.icon = self.render:GetChild("icon")
    self.spine_render = self.render:GetChild("spine_render")

    FSysEventEmitter:AddListener(FSysEvent.ON_LOGIC_UPDATE, handler(self, self.OnUpdate), self)

    self.render:AddEventListener(FGUIEventKey.onClick, function() self:OnClickSpin(false) end)

    self.stateController = self.render:GetController("c_icon")

    -- 是否加速旋转
    self.bAcceleration = false
    -- 是否置灰图案
    self.bGrey = false
    -- 是否停止旋转
    self.bFreeze = false
    -- 老虎机所有转轴是否滚动完毕
    self.bRellScrollEnd = true

    self.eventEmitter = EventEmitter.New()

    self:UpdateIconURL()
end

function SpinButton:__delete()
    self.eventEmitter:Delete()
    FSysEventEmitter:RemoveListenersByTag(self)
end

function SpinButton:OnUpdate(dt)
    if self.bFreeze then return end

    if self.bAcceleration then
        self.icon.rotation = self.icon.rotation + dt * 800
    else
        self.icon.rotation = self.icon.rotation + dt * 80
    end
end

-- @brief 设置是否加速旋转
function SpinButton:EnableAcceleration(value)
    self.bAcceleration = value
    self:UpdateIconURL()
end

-- @brief 设置按钮是否置灰
function SpinButton:SetGrey(value)
    self.bGrey = value
    self:UpdateIconURL()
end

-- @breif 设置是否停止旋转
function SpinButton:SetFreeze(value)
    self.bFreeze = value
    self.eventEmitter:Emit("Event_UpdateSpin", self.bGrey, self.bAcceleration, self.bFreeze)
end

function SpinButton:UpdateIconURL()
    if self.stateController then
        if self.bGrey then
            if self.bAcceleration then
                self.stateController.selectedPage = "grey_blur"
            else
                self.stateController.selectedPage = "grey"
            end
        else
            if self.bAcceleration then
                self.stateController.selectedPage = "blur"
            else
                self.stateController.selectedPage = "normal"
            end
        end
    end

    self.eventEmitter:Emit("Event_UpdateSpin", self.bGrey, self.bAcceleration, self.bFreeze)
end

function SpinButton:OnClickSpin(isSimulation)
    if self.bGrey then return end

    if FCasinoCtx.curSpinStatus == FSpinStatus.SPIN then
        if not FCasinoCtx:GetGame():SpinFaultToleranceProtection() then
            FCasinoCtx:GetGame():OnClickSpin(isSimulation)
        else
            return
        end

        -- 是自动旋转模拟的点击，不显示点击动效
        if isSimulation then return end
        
        if FCasinoCtx.curSpinStatus ~= FSpinStatus.SPIN then
            self.render:GetTransition("click"):Play()
        end
    elseif FCasinoCtx.curSpinStatus == FSpinStatus.STOP then
        FCasinoCtx:GetGame():OnClickStop()
    end
end

function SpinButton:UpdateSpinButton()
    local spinStatus = FCasinoCtx.curSpinStatus

    self:EnableAcceleration(spinStatus == FSpinStatus.STOP)
    self:SetFreeze(spinStatus == FSpinStatus.WAITING)
    self:SetGrey(spinStatus == FSpinStatus.WAITING)
end

return SpinButton