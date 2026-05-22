-- 游戏规则界面

local GameRulePanel = Class("GameRulePanel")

function GameRulePanel:ctor(frameUrl, itemUrls)
    if APIGateway.IsDeviceOrientationPortrai() then
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "GameRulePanel_V")
    else
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "GameRulePanel")
    end
    self.render:MakeFullScreen()
    self.render:GetTransition("open"):Play()
    GetFairyRoot():AddChild(self.render)
    
    -- 加载frame
    self.loader = self.render:GetChild("loader")
    self.loader.url = frameUrl

    -- 
    self.frame = self.loader.component
    -- self.frame:MakeFullScreen()


    -- fame里面必须要有这些接口
    local bottomPanel = self.frame:GetChild("bottomPanel")
    FToolSet.AddClickListener(bottomPanel:GetChild("btn_close"), handler(self, self.OnClickClose))
    FToolSet.AddClickListener(bottomPanel:GetChild("btn_pre"), handler(self, self.OnClickPre))
    FToolSet.AddClickListener(bottomPanel:GetChild("btn_next"), handler(self, self.OnClickNext))

    self.bScrollEnd = true

    self.list = self.frame:GetChild("list")
    self.list.touchable = false
    self.list.itemRenderer = function(index, obj)
        obj.icon = itemUrls[index + 1]
    end
    -- -- 设置为循环列表
    self.list:SetVirtualAndLoop()

    -- 监听滚动完毕事件
    if RUNTIME_IN_COCOS or RUNTIME_IN_CREATOR then
        self.list:AddEventListener(FGUIEventKey.onScrollEnd, handler(self, self.OnScrollEnd))
    else
        -- unity在scrollPane上派发的事件
        self.list.scrollPane:AddEventListener(FGUIEventKey.onScrollEnd, handler(self, self.OnScrollEnd))
    end

    -- 设置页数
    self.list.numItems = #itemUrls
    -- 滚动到第一页
    self.list:ScrollToView(0)
end

function GameRulePanel:__delete()
    self.render:RemoveFromParent(true)
end

function GameRulePanel:OnClickPre()
    if not self.bScrollEnd then return end
    self.bScrollEnd = false
    self.list.scrollPane:ScrollLeft(1, true)
end

function GameRulePanel:OnClickNext()
    if not self.bScrollEnd then return end
    self.bScrollEnd = false
    self.list.scrollPane:ScrollRight(1, true)
end

-- @brief 点击关闭按钮
function GameRulePanel:OnClickClose()
    if self.bPlayClose then return end
    self.bPlayClose = true
    self.render:GetTransition("close"):Play(self.onDestroyCallback)
end

function GameRulePanel:OnScrollEnd()
    self.bScrollEnd = true
end

function GameRulePanel:SetDestroyCallback(cb)
    self.onDestroyCallback = cb
end

return GameRulePanel