
local Utils = Import(".Utils")
local SymbolConfig = Import(".SymbolConfig")
local GameDefine = Import("..GameDefine")
local Reel = Class("Reel", BaseReel)


function Reel:ctor(parent, idx)
    self.cfg = clone(FCasinoCtx.gameCfg.Reel)

    self.idx = idx
    -- 当前状态
    self.curState = BaseReel.State.None
    -- 当前状态运行时间
    self.curTime = 0
    -- 滚动状态累计滚动格子数量
    self.rollSymbolNum = 0
    -- 偏移值
    self.offset = 0

    self.deltaTime = 0
    self.timeScale = 1

    -- 容器
    self.reelContainer = FairyGUI.GComponent()
    self.reelContainer:SetupOverflowHidden(false)
    
    self.reelContainer.opaque = false
    parent:AddChild(self.reelContainer)
    self.reelContainer.sortingOrder = 10 - idx

    self.stopZoreIndexData = {}
end

-- @interface
-- @brief 返回随机图案数据
function Reel:RandomSymbolData()
    local data = Utils.RandomSymbolData(self.idx)
    return data
end

-- @interface
-- @brief 图标排序接口
function Reel:OnUpdateSymbolZorder(render, data, index)
    if SymbolConfig[data.icon] ~= nil then 
        render.sortingOrder = SymbolConfig[data.icon].zorder + index
    end
end

-- @interface
-- @brief 创建渲染组件接口
function Reel:OnCreateSymbolRenderComponent()
    return FairyGUI.UIPackage.CreateObject("Game483", "Symbol")
end

-- @interface
-- @brief 刷新图案
-- @param render : FairyGUI.GComponent
-- @param data : any
-- @param index: number
function Reel:UpdateSymbol(render, data, index)
    if data == nil then return end
    local cfg = SymbolConfig[data.icon]
    if not cfg then return end

    local whiteBG = render:GetChild("whiteBG")
    local goldBG = render:GetChild("goldBG")
    local isGolden = data.golden == 1 
    goldBG.visible = isGolden
    whiteBG.visible = not isGolden
    local icon = render:GetChild("icon")
    local swEffect = render:GetChild("swEffect")
   
    for _, nodeName in pairs(SymbolConfig.nodes) do
        local node = render:GetChild(nodeName)
        node.visible = false
    end
    
    if cfg.icon then
        icon.url = data.isRandom and cfg.blur or cfg.icon
        icon.visible = true
        swEffect.visible = false
    elseif cfg.node then
        goldBG.visible = false
        whiteBG.visible = false
        local node = render:GetChild(cfg.node)
        node.visible = true
        swEffect.visible = true
        icon.visible = false
    end
    local click = render:GetChild("click")
    APIGateway.AddEventListener(click,FGUIEventKey.onClick, function()
        self:OnClick(index)
    end,true)
end


-- @interface 
-- @brief 开始旋转回调函数
function Reel:OnScrollBegin()
    for i = 1, self.symbolNum do
        local render = self.arraySymbolDisplays[i].render
        if render then
            render.visible = true
            -- render:GetChild("icon").visible = true
        end
    end
end

-- @interface 
-- @brief 旋转结束回调函数
function Reel:OnScrollEnd()
    if self.stopZoreIndexData and next(self.stopZoreIndexData) ~= nil then
        self:UpdateSymbol(self.arraySymbolDisplays[0].render, self.stopZoreIndexData, 0)
    end
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local arraySymbolDisplays = self.arraySymbolDisplays
    for i = 1, reelCfg.yCellNumber do
        local display = arraySymbolDisplays[i]
        -- self:UpdateSymbol(display.render, display.data, i)
        local click = display.render:GetChild("click")
        APIGateway.AddEventListener(click,FGUIEventKey.onClick, function()
            self:OnClick(i)
        end,true)
    end
end

-- @brief 创建新的渲染组件
function Reel:NewSymbolRenderComponent(i)
    local render = self:OnCreateSymbolRenderComponent(i)
    render.opaque = false
    render:SetPivot(0.5, 0.5, true)

    render.x = self.cfg.reelWidth * 0.5
    render.y = self.cfg.symbolHeight * (i - 0.5)
    self.reelContainer:AddChild(render)
    self.arraySymbolDisplays[i] = {render = render, data = nil}
end

function Reel:SetEnabled(enabled)
    for i = 0, self.symbolNum + 1 do
        local render = self.arraySymbolDisplays[i].render
        if render then
            local click = render:GetChild("click")
            click.touchable = enabled
        end
    end
end

function Reel:SetOnClickCallBack(node,callback)
    self.OnClickCallback = callback
    self.OnClickCallbackNode = node
end

function Reel:OnClick(index)
    if index == 0 or index > 4 then
        return
    end
    if self.OnClickCallback then
        local logicIndex = (index - 1) * self.cfg.xCellNumber + self.idx
        self.OnClickCallback(self.OnClickCallbackNode,logicIndex,self.arraySymbolDisplays[index].data.icon)
    end
end

return Reel