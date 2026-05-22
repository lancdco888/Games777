
local SymbolConfig  = Import(".SymbolConfig")
local ConstCfg      = Import(".ConstCfg")
local Tools         = Import(".Tools")
local Reel          = Class("Reel", BaseReel)

function Reel:InitSymbol(data)
    Reel.super.InitSymbol(self,data)
end

function Reel:SetGame(game)
    self.game_ = game
end

-- @interface
-- @brief 返回随机图案数据
function Reel:RandomSymbolData()
    local data = {}
    local random_list = {1,2,3,4,5,6,7,8,9,10,11,12}
    local random_ = math.random(1, 100)
    if random_ >= 5 then
        random_list = {1,2,3,4,5,6,7,8,9,10,11}
    end
    data.icon = random_list[math.random(1, #random_list)]
    if self.idx <= 1 and Tools.IsWildCard(data.icon) then
        data.icon = 1
    elseif self.idx == 3 and self.game_.PlayGameType == FGameMode.FREE then
        local free_random = math.random(1, 100)
        data.icon = Tools.WildIconID
        if free_random > 95 then
            data.icon = Tools.SCIconID
        end
    end
    data.value = 0
    data.type = 0
    if Tools.IsJpCard(data.icon) then
        local type_random = math.random(1,50)
        if type_random > 5 then
            data.type = 1
        else
            data.type = math.random(2, 5)
        end
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
    local zorder = SymbolConfig.Icon[data.icon].zorder
    render.sortingOrder = zorder + index
end

-- @interface
-- @brief 创建渲染组件接口
function Reel:OnCreateSymbolRenderComponent()
    return FairyGUI.UIPackage.CreateObject("Game375", "Symbol_" .. self.str_Symbol)
end

function Reel:Set_Str_Symbol(str_)
    self.str_Symbol = str_
end

-- @interface
-- @brief 刷新图案
-- @param render : FairyGUI.GComponent
-- @param data : any
-- @param index: number
function Reel:UpdateSymbol(render, data, index)
    local node = render:GetChild("node")
    local real_render = render
    --3x7格子用的node作为主节点
    if node then
        real_render = node
    end
    local big_cfg = SymbolConfig.Icon[data.icon]
    -- 加载图标
    local image = real_render:GetChild("icon")
    image.url = big_cfg.icon
    if big_cfg.Scale then
        image.scale = big_cfg.Scale
    end
    if big_cfg.Pos then
        image.xy = big_cfg.Pos
    end
    -- 遮罩(只有落地牌并且不是心的时候才显示遮罩)
    local mask = real_render:GetChild("mask")
    if not Tools.IsJpCard(data.icon) then
        mask.visible = self.showMask or false
    end
end

-- @interface 
-- @brief 开始旋转回调函数
function Reel:OnScrollBegin()
    self:ShowSymbolDisplays()
    self.isclickStop = false
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

function Reel:SetReelVisible(isOpen)
    self.reelContainer.visible = isOpen
end

function Reel:ShowSymbolDisplays()
    for i = 1, self.symbolNum do
        local render = self.arraySymbolDisplays[i].render
        if render then
            render.visible = true
        end
    end
end

function Reel:QuickStop()
    Reel.super.QuickStop(self)
    self.isclickStop = true
end

return Reel