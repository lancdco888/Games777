
local Utils = Import(".Utils")
local TopSymbol = Class("TopSymbol")
local SymbolConfig = Import(".SymbolConfig")

function TopSymbol:ctor(parent, index, mode)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local logicX = Utils.GetReelIndex(index,mode)
    local logicY = Utils.GetCellIndex(index,mode)
    self.render = FairyGUI.UIPackage.CreateObject("Game485", "Symbol")
    self.render.x = logicX * (reelCfg.reelWidth + reelCfg.reelSpace)

    if mode == "bonus" then
        self.render.y = logicY * (reelCfg.reelHeightBouns / reelCfg.yCellNumberBouns)
    else
        self.render.y = logicY * (reelCfg.reelHeight / reelCfg.yCellNumber)
    end

    parent:AddChild(self.render)

    -- icon loader
    self.loader_icon = self.render:GetChild("icon")
    self.loader_kuang = self.render:GetChild("hit")
    self.loader_mask = self.render:GetChild("mask")
end

function TopSymbol:__delete()
    self.render:RemoveFromParent(true)
end

function TopSymbol:Reset()
    self.render.visible = true
    self.loader_kuang.visible = false
    self.loader_mask.visible = false
end

-- @brief 设置当前图标动画
function TopSymbol:SetIcon(index, data, mask,isReconnect)
    self.data = data
    -- 重置一些属性
    local cfg  = SymbolConfig[data.icon]
    self.render.sortingOrder = cfg.zorder + index
    -- 显示图标,有动画则显示动画

    if not isReconnect then
        if data.ishide ~= 1 then
            self.loader_icon.url = cfg.animation
        else --偷梁换柱 1
            self.loader_icon.url = SymbolConfig[113].animation
        end
    else
        self.loader_icon.url = cfg.icon
    end

    self.loader_mask.visible = false

    if Utils.IsBonus(data.icon) and data.ishide ~= 1 then
        Utils.SetBonusNum(self.loader_icon,data)
    else
        if mask then
            self.loader_mask.visible = true
        end
    end
    return cfg, isReconnect
end

function TopSymbol:SetVisible(value)
    self.render.visible = value
end

function TopSymbol:GetRootPos()
    return self.render:LocalToRoot(vec2(self.render.width * 0.5, self.render.height * 0.5))
end

function TopSymbol:Blink()
    self.blinkTweener = FTween.Start(self.render,
        FTween.RepeatForever({
            FTween.Delay(0.5, function()
                self.loader_icon.visible = not self.loader_icon.visible
            end),
        })
    )
end
--偷梁换柱 2
function TopSymbol:ShowBoom()
    local cfg = SymbolConfig[self.data.icon]
    local component = self.loader_icon.component
    if component then
        component:GetTransition("win"):Play(function()
            self.loader_icon.url = cfg.animation
        end)
    end
    self.loader_icon.visible = true
end

function TopSymbol:ShowAnim()
    local cfg  = SymbolConfig[self.data.icon]    
    if not cfg.isBlink then
        local component = self.loader_icon.component
        if component then
            component:GetTransition("win"):Play()
        end
    else
        if not self.blinkTweener then
            self:Blink()
        end
    end
    self.loader_icon.visible = true
end

function TopSymbol:ShowLine()
    self.loader_kuang.visible   = true
    -- self.loader_kuang.url = "ui://Game485/Hit"
end

function TopSymbol:ClearLine()
    self.loader_kuang.visible   = false
    self.loader_kuang.url = ""
    self.loader_icon.visible = true

    if self.blinkTweener then
        self.blinkTweener.Kill()
        self.blinkTweener = nil
    end
end

return TopSymbol