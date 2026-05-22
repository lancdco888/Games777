-- 自动spin选择列表

local AutoSpinListPanel = Class("AutoSpinListPanel")

local SlotsAutoModes = {
    { mode = "inf", desc = "i"},
    { mode = "inf_fast", desc = "i+f"},
    { mode = "num", desc = "500", num = 500 },
    { mode = "num", desc = "100", num = 100 },
    { mode = "num", desc = "50" , num = 50  },
    { mode = "num", desc = "20" , num = 20  },
}

function AutoSpinListPanel:ctor()
    self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "AutoListPanel")
    self.render:MakeFullScreen()
    GetFairyRoot():AddChild(self.render)


    local list = self.render:GetChild("list")
    for k, v in pairs(SlotsAutoModes) do
        local item = list:GetChild("n" .. k)
        item.text = v.desc
        item:AddEventListener(FGUIEventKey.onClick, function()
            self:OnClickItem(k)
        end)
    end

    -- 空白区域
    self.render:AddEventListener(FGUIEventKey.onClick, handler(self, self.OnClickClose))

    -- 定位到底部spin按钮位置
    local btn_spin = FCasinoCtx.commonPanel.bottomPanel.btn_spin

    local xy = btn_spin:LocalToRoot(vec2(btn_spin.width * 0.5, 0))
    list.xy = self.render:RootToLocal(xy)
    list.scale = list.parent.scale
end

function AutoSpinListPanel:__delete()
    self.render:RemoveFromParent(true)
    FCasinoCtx.commonPanel.bottomPanel:CloseBetListPanel()
end

-- @brief 点击空白区域
function AutoSpinListPanel:OnClickClose()
    self:Close()
end

-- @brief 关闭弹窗
function AutoSpinListPanel:Close()
    if self.bPlayClose then return end
    self.bPlayClose = true
    
    if self.onDestroyCallback then
        self.onDestroyCallback()
        self.onDestroyCallback = nil
    end
end

function AutoSpinListPanel:OnClickItem(index)
    if self.onSelectCallback then
        self.onSelectCallback(SlotsAutoModes[index])
        self.onSelectCallback = nil
    end
    self:Close()
end

function AutoSpinListPanel:SetSelectCallback(call)
    self.onSelectCallback = call
end

function AutoSpinListPanel:SetDestroyCallback(call)
    self.onDestroyCallback = call
end

return AutoSpinListPanel
