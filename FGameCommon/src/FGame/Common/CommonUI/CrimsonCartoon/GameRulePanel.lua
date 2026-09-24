-- 游戏规则界面

local GameRulePanel = Class("GameRulePanel")

function GameRulePanel:ctor(frameUrl, itemUrls, isOdds)
    self.itemUrls = itemUrls

    if APIGateway.IsDeviceOrientationPortrai() then
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "GameRulePanel_V")
    else
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "GameRulePanel")
    end
    self.render:MakeFullScreen()
    GetFairyRoot():AddChild(self.render)
    
    self.render:GetTransition("open"):Play(function()
        self.bOpenFinish = true
        self:OnOpenFinish()
    end)
    
    local frame = self.render:GetChild("frame")
    self.frame = frame

    -- 顶部标题栏
    local top_title = frame:GetChild("top_title")
    -- 标题文本
    local title = top_title:GetChild("title")
    title.color = FTheme.curThemCfg.textColor
    if isOdds then
        title.text  = APIGateway.GetLangText("fgame_crimson_cartoon_title_1")
    else
        title.text  = APIGateway.GetLangText("fgame_crimson_cartoon_title_2")
    end
    -- 关闭回调
    FToolSet.AddClickListener(top_title:GetChild("btn_close"), handler(self, self.OnClickClose), false)
end

function GameRulePanel:__delete()
    self.render:RemoveFromParent(true)
end

function GameRulePanel:OnOpenFinish()
    local frame = self.frame
    -- 规则列表
    local list = frame:GetChild("list")
    list.itemRenderer = function(index, obj)
        obj.icon = self.itemUrls[index + 1]
    end
    -- 设置页数
    list.numItems = #self.itemUrls

    frame:GetTransition("fadein"):Play()
end

-- @brief 点击关闭按钮
function GameRulePanel:OnClickClose()
    if not self.bOpenFinish then return end
    if self.bPlayClose then return end
    self.bPlayClose = true
    self.render:GetTransition("close"):Play(self.onDestroyCallback)
end

function GameRulePanel:SetDestroyCallback(cb)
    self.onDestroyCallback = cb
end

return GameRulePanel