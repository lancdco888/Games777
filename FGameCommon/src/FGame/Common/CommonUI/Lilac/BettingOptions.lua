-- 游戏押注选项界面

local BettingOptions = Class("BettingOptions")

function BettingOptions:ctor()
    if APIGateway.IsDeviceOrientationPortrai() then
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "BettingOptions_V")
    else
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "BettingOptions")
    end
    self.render:MakeFullScreen()
    self.render:GetTransition("open"):Play(function()
        self.bOpenFinish = true
        self:OnOpenFinish()
    end)
    GetFairyRoot():AddChild(self.render)

    self:InitUI()
end

function BettingOptions:InitUI()
    local frame = self.render:GetChild("frame")
    self.frame = frame

    local iconUrlSuffix = ""
    if APIGateway.IsDeviceOrientationPortrai() then
        iconUrlSuffix = "_V"
    end

    local iconIndex = 0
    self.selectedIndex = FCasinoCtx.commonPanel.curCIndex
    self.items = {}
    local list = frame:GetChild("list")
    list.itemRenderer = function(index, obj)
        index = index + 1
        iconIndex = iconIndex + 1
        if iconIndex > 6 then iconIndex = 6 end

        local enabled = FCasinoCtx.commonPanel.betCfg[index][1].enabled
        obj.grayed = not enabled
        obj.touchable = enabled
        obj.title = FCasinoCtx.commonPanel.betCValues[index] .. "C"
        obj.selected = self.selectedIndex == index
        obj.icon = string.format("ui://%s/BettingOptions_btn_bg_%d", FTheme.curPkgName, iconIndex) .. iconUrlSuffix
        self.items[index] = obj
        
        FToolSet.AddClickListener(obj, function()
            self:OnClickItem(index)
        end)
    end

    if #FCasinoCtx.commonPanel.betCValues > 5 then
        if APIGateway.IsDeviceOrientationPortrai() then
            list.lineGap = 10
        else
            list.width = 1013
            list.scaleX = 0.85
        end
    end

    list.numItems = #FCasinoCtx.commonPanel.betCValues
end

function BettingOptions:OnOpenFinish()
end

function BettingOptions:__delete()
    self.render:RemoveFromParent(true)
end

function BettingOptions:OnClickItem(index)
    self.selectedIndex = index
    for k, v in pairs(self.items) do
        v.selected = self.selectedIndex == k
    end
    self:OnClickClose()
end

-- @brief 点击关闭按钮
function BettingOptions:OnClickClose()
    if not self.bOpenFinish then return end
    if self.bPlayClose then return end
    self.bPlayClose = true
    self.render:GetTransition("close"):Play(function()
        FCasinoCtx.commonPanel:SetCurCValueIndex(self.selectedIndex)
        self.onDestroyCallback()
    end)
end

function BettingOptions:SetDestroyCallback(cb)
    self.onDestroyCallback = cb
end

function BettingOptions:disableBlankClick()
end

return BettingOptions