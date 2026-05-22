-- 游戏押注选项界面

local AutoSpin = Class("AutoSpin")

local AutoNums = { 10, 30, 50, 80, 1000 }
local OptionTextNormalColor = {r = 91, g = 90, b = 90}

function AutoSpin:ctor()
    if APIGateway.IsDeviceOrientationPortrai() then
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "AutoSpin_V")
    else
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "AutoSpin")
    end
    self.render:MakeFullScreen()
    self.render:GetTransition("open"):Play(function()
        self.bOpenFinish = true
        self:OnOpenFinish()
    end)
    GetFairyRoot():AddChild(self.render)
end

function AutoSpin:OnOpenFinish()
    local frame = self.render:GetChild("frame")

    local title             = frame:GetChild("title")
    local btn_confirm       = frame:GetChild("btn_confirm")
    local text_option_title = frame:GetChild("text_option_title")
    local text_game_money   = frame:GetChild("text_game_money")
    local text_bet          = frame:GetChild("text_bet")
    local text_win          = frame:GetChild("text_win")

    -- 文本设置
    title.text             = APIGateway.GetLangText("fgame_crimson_cartoon_title_10")
    btn_confirm.text       = APIGateway.GetLangText("fgame_crimson_cartoon_title_11")
    text_option_title.text = APIGateway.GetLangText("fgame_crimson_cartoon_title_12")
    text_game_money.text   = FCasinoCtx.commonPanel.bottomPanel.text_game_money.text
    text_bet.text          = FCasinoCtx.commonPanel.bottomPanel.text_bet.text
    text_win.text          = FCasinoCtx.commonPanel.bottomPanel.text_win.text

    -- 变色
    btn_confirm:GetChild("icon").color      = FTheme.curThemCfg.textColor
    text_game_money:GetChild("icon").color  = FTheme.curThemCfg.textColor
    text_bet:GetChild("icon").color         = FTheme.curThemCfg.textColor
    text_win:GetChild("icon").color         = FTheme.curThemCfg.textColor
    
    -- 次数选项
    self.btn_options = {}
    for k, v in pairs(AutoNums) do
        self.btn_options[k] = frame:GetChild(string.format("btn_option_%d", k))
        self.btn_options[k].text = string.format("%d", v)
        self.btn_options[k]:GetChild("title").color = OptionTextNormalColor
        FToolSet.AddClickListener(self.btn_options[k], function()
            self:OnClickOption(k)
        end)
    end

    self.render:GetTransition("fadein"):Play()

    self.btn_confirm = btn_confirm
    btn_confirm.grayed = true
    -- 按钮回调绑定
    FToolSet.AddClickListener(frame:GetChild("btn_close"), handler(self, self.OnClickClose))
    FToolSet.AddClickListener(self.render:GetChild("mask"), handler(self, self.OnClickClose))
    FToolSet.AddClickListener(self.btn_confirm, handler(self, self.OnClickConfirm))
end

function AutoSpin:__delete()
    self.render:RemoveFromParent(true)
    self.onDestroyCallback = nil
end

-- @brief 点击关闭按钮
function AutoSpin:OnClickClose()
    if not self.bOpenFinish then return end
    if self.bPlayClose then return end
    self.bPlayClose = true
    self.render:GetTransition("close"):Play(function()
        if self.bSelected then
            -- 沿用之前的格式
            local mode = {
                mode = "num",
                num = AutoNums[self.curSelectIndex]
            }

            if self.onSelectCallback then
                self.onSelectCallback(mode)
                self.onSelectCallback = nil
            end
        end

        if self.onDestroyCallback then
            self.onDestroyCallback()
            self.onDestroyCallback = nil
        end
    end)
end

function AutoSpin:OnClickConfirm()
    if self.bPlayClose then return end

    if self.curSelectIndex ~= nil then
        self.bSelected = true
        self:OnClickClose()
    end
end

function AutoSpin:OnClickOption(index)
    for k, v in pairs(self.btn_options) do
        if k == index then
            v:GetChild("title").color = FTheme.curThemCfg.textColor
        else
            v:GetChild("title").color = OptionTextNormalColor
        end
    end
    self.curSelectIndex = index
    self.btn_confirm.grayed = false
end

function AutoSpin:SetDestroyCallback(cb)
    self.onDestroyCallback = cb
end

function AutoSpin:SetSelectCallback(call)
    self.onSelectCallback = call
end

return AutoSpin