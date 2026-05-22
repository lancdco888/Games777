
local SymbolConfig = Import(".SymbolConfig")
local Reel = Class("Reel", BaseReel)
local Tools = Import(".Tools")
local ConstCfg = Import(".ConstCfg")
local Utils = Import(".Utils")
-- @interface
-- @brief 返回随机图案数据
function Reel:RandomSymbolData()
    local data = {
        icon  = math.random(2, 12),
        value = 0,
        isHide = 0,
        type = 0
    }
    if data.icon == 2 then
        data.type = math.random(1, 4)
        if data.type == 1 then
            local numbers = ConstCfg.TopupBonusNumbers
            data.value = numbers[math.random(1, #numbers)] * FCasinoCtx.commonPanel:GetCurrentBetConfig().betMoney
        end
    end
    return data
end

-- @interface
-- @brief 图标排序接口
function Reel:OnUpdateSymbolZorder(render, data, index)
    render.sortingOrder = SymbolConfig[data.icon].zorder + index
end

-- @interface
-- @brief 创建渲染组件接口
function Reel:OnCreateSymbolRenderComponent()
    return FairyGUI.UIPackage.CreateObject("Game475", "Symbol")
end

-- @interface
-- @brief 刷新图案
-- @param render : FairyGUI.GComponent
-- @param data : any
-- @param index: number
function Reel:UpdateSymbol(render, data, index)
    local cfg = SymbolConfig[data.icon]

    if data.isHide == 1 and not self.isOpen  then
        cfg = SymbolConfig[13]
    end
    -- 加载图标
    local loader = render:GetChild("loader")
    loader.url = cfg.icon
    -- loader.scale = cfg.loaderScale
    -- 数字
    local num = render:GetChild("num")
    -- 遮罩 -- todo
    local mask = render:GetChild("mask")
    -- sprite1 
    local sprite1 = render:GetChild("sprite1")
    mask.visible = self.showMask or false
    local TopupBounsbg = render:GetChild("TopupBounsbg")
    if cfg.LDRes then
        local res = cfg.LDRes[data.type]
        num.visible = res.numShow
        sprite1.visible = res.spriteFontShow
        if res.numShow then
            num.text = Tools.TopupBounsScoreToStr(data.value) 
        end
        if res.sprite1Url and res.sprite1Url ~= "" then
            sprite1.url = res.sprite1Url
        end
        mask.visible = false
        TopupBounsbg.visible = true
    else
        num.visible = false
        sprite1.visible = false
        TopupBounsbg.visible = false
        local DragonCircle = render:GetChild("DragonCircle")
        DragonCircle.visible = false
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

function Reel:ShowSymbolDisplays()
    for i = 1, self.symbolNum do
        local render = self.arraySymbolDisplays[i].render
        if render then
            render.visible = true
        end
    end
end

return Reel