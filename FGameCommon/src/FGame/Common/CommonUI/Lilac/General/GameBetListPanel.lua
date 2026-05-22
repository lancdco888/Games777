-- 底部选C列表

local GameBetListPanel = Class("GameBetListPanel")

function GameBetListPanel:ctor()
    self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "BetListPanel")
    self.render:MakeFullScreen()
    GetFairyRoot():AddChild(self.render)

    local config = FCasinoCtx.commonPanel.betCValues
    local itemNum = #config

    local loader = self.render:GetChild("n1")
    local list = loader.component:GetChild("list")
    list.itemRenderer = function(index, obj)
        -- 降序显示
        index = itemNum - index

        obj.title = config[index] .. "C"
        
        local enabled = FCasinoCtx.commonPanel.betCfg[index][1].enabled
        if enabled then
            FToolSet.AddClickListener(obj, function()
                self:OnClickItem(index)
            end)
        end
        -- 置灰
        obj:GetChild("img_normal").grayed = not enabled
        obj:GetChild("img_selected").grayed = not enabled
        obj:GetChild("img_disable").grayed = not enabled

        if FCasinoCtx.commonPanel.curCIndex == index then
            obj:GetChild("img_normal").url    = string.format("ui://%s/btn_iii_1", FTheme.curPkgName)
            obj:GetChild("img_selected").url  = string.format("ui://%s/btn_iii_2", FTheme.curPkgName)
            obj:GetChild("img_disable").url   = string.format("ui://%s/btn_iii_3", FTheme.curPkgName)
        else
            obj:GetChild("img_normal").url    = string.format("ui://%s/btn_iv_1", FTheme.curPkgName)
            obj:GetChild("img_selected").url  = string.format("ui://%s/btn_iv_2", FTheme.curPkgName)
            obj:GetChild("img_disable").url   = string.format("ui://%s/btn_iv_3", FTheme.curPkgName)
        end
    end
    list.numItems = itemNum
    list.height = 72 * itemNum

    -- 空白区域
    self.render:AddEventListener(FGUIEventKey.onClick, handler(self, self.OnClickClose))


    -- 定位到底部选C按钮位置
    local btn_betlvID = FCasinoCtx.commonPanel.bottomPanel.btn_betlvID
    local xy = btn_betlvID:LocalToRoot(vec2(0, 0))
    loader.xy = self.render:RootToLocal(xy)
    loader.scale = btn_betlvID.parent.scale
end

function GameBetListPanel:__delete()
    self.render:RemoveFromParent(true)
end

-- @brief 点击空白区域
function GameBetListPanel:OnClickClose()
    self:Close()
end

-- @brief 关闭弹窗
function GameBetListPanel:Close()
    if self.bPlayClose then return end
    self.bPlayClose = true
    
    if self.onDestroyCallback then
        self.onDestroyCallback()
        self.onDestroyCallback = nil
    end
end

function GameBetListPanel:OnClickItem(index)
    FCasinoCtx.commonPanel:SetCurCValueIndex(index)
end

function GameBetListPanel:SetDestroyCallback(call)
    self.onDestroyCallback = call
end

function GameBetListPanel:disableBlankClick()
    self.render.opaque = false
end

return GameBetListPanel