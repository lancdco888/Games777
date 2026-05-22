local SymbolConfig = Import(".SymbolConfig")
local Reel = Class("Reel", BaseReel)
local Tools = Import(".Tools")
local ConstCfg = Import(".ConstCfg")
local MusicCfg = Import(".MusicCfg")
local Defined = Import("..Cfgs.Defined")
local Help = Import(".Help")

function Reel:ctor()
    self.bigSymbol = false
end

function Reel:isSpecial(special)
    self.IsSpecial = special
end

function Reel:isFree(free)
    self.IsFree = free
end

-- @interface
-- @brief 返回随机图案数据
function Reel:RandomSymbolData()
    local icons = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }

    if self.IsFree then
        -- 如果是免费中且是第一列,不能有Sc和wi
        if self.idx == 1 then
            icons = { 4, 5, 6, 7, 8, 9, 10, 11, 12 }
        elseif self.idx == 3 then
            icons = { 1, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
        end
    end

    local index = math.random(1, #icons)

    local data = {
        icon = icons[index],
        value = 0,
        type = 0
    }

    if Tools.IsJpCard(data.icon) then
        data.type = math.random(1, 4)
        if data.type == 1 then
            local numbers = ConstCfg.TopupBonusNumbers
            data.value = numbers[math.random(1, #numbers)] * FCasinoCtx.commonPanel:GetCurrentBetConfig().betMoney
        end
    end
    return data
end

function Reel:IsBigSymbol(state)
    self.bigSymbol = state
end

-- @interface
-- @brief 图标排序接口
function Reel:OnUpdateSymbolZorder(render, data, index)
    render.sortingOrder = SymbolConfig[data.icon].zorder + index
end

-- @interface
-- @brief 创建渲染组件接口
function Reel:OnCreateSymbolRenderComponent()
    if self.bigSymbol or false then
        return FairyGUI.UIPackage.CreateObject(Defined.GameName, "BigSymbol")
    else
        return FairyGUI.UIPackage.CreateObject(Defined.GameName, "Symbol")
    end
end

-- @interface
-- @brief 刷新图案
-- @param render : FairyGUI.GComponent
-- @param data : any
-- @param index: number
function Reel:UpdateSymbol(render, data, index)
    local cfg = SymbolConfig[data.icon]

    Tools.HideSymbolChildren(render)
    if cfg.icon:sub(1, 5) ~= "ui://" then
        local node = render:GetChild(cfg.icon)
        node.visible = true
    else
        local loader = render:GetChild("loader")
        loader.url = cfg.icon
        loader.visible = true
    end
    render:GetChild("TopupBounsbg").visible = Tools.IsJpCard(data.icon)
    render:GetChild("DragonCircle").visible = false

    -- loader.scale = cfg.loaderScale
    -- 数字
    local num = render:GetChild("num")
    -- 遮罩 -- todo
    local mask = render:GetChild("mask")
    -- sprite1
    local sprite1 = render:GetChild("sprite1")
    -- sprite2
    local sprite2 = render:GetChild("sprite2")
    mask.visible = self.showMask or false

    if cfg.LDRes and data.type ~= nil and data.type ~= 0 then
        local res = cfg.LDRes[data.type]
        num.visible = res.numShow
        sprite1.visible = res.spriteFontShow
        sprite2.visible = res.spriteFontShow
        if res.numShow then
            num.text = Tools.TopupBounsScoreToStr(data.value)
            Help.SetJpNumberTransform(num, self.bigSymbol)
        end
        if res.sprite1Url and res.sprite1Url ~= "" then
            sprite1.url = res.sprite1Url
        end
        if res.sprite2Url and res.sprite2Url ~= "" then
            sprite2.url = res.sprite2Url
        end
        mask.visible = false
    else
        num.visible = false
        sprite1.visible = false
        sprite2.visible = false
    end
end

-- @interface
-- @brief 开始旋转回调函数
function Reel:OnScrollBegin()
    self:ShowSymbolDisplays()
end

-- @interface
-- @brief 旋转结束回调函数
function Reel:OnScrollEnd()
    self.isOpen = false
end

function Reel:SetMask(isShow)
    self.showMask = isShow
end

function Reel:SetOpen(isOpen)
    self.isOpen = isOpen
    for i = 1, self.symbolNum do
        local render = self.arraySymbolDisplays[i].render
        if render then
            render.visible = true
        end
    end
end

function BaseReel:OnBounceStart()
    if self.OnBounceStartCallBack then
        self.OnBounceStartCallBack()
    end

    if self.isBouncePlay ~= nil then
        FToolSet.PlayFGUISound(MusicCfg.slots_321_reelstop)
    end
end

function Reel:ShowSymbolDisplays()
    for i = 1, self.symbolNum do
        local render = self.arraySymbolDisplays[i].render
        if render then
            render.visible = true
        end
    end
end

return Reel
