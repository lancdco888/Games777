
local SymbolConfig = Import(".SymbolConfig")
local Reel = Class("Reel", BaseReel)
local Tools = Import(".Tools")
local ConstCfg = Import(".ConstCfg")
-- @interface
-- @brief 返回随机图案数据
function Reel:RandomSymbolData()
    local data = {
        icon = 0,
        value = 0,
        isHide = 0,
        type = 0
    }

    if self.idx == 1 then
        data.icon = math.random(2, 12)
    else
        data.icon = math.random(1, 12)
    end
    local curGameType = 1
    if FCasinoCtx:GetGame() then
        curGameType = FCasinoCtx:GetGame().curGameType
    end
    if curGameType == 2 or curGameType == 4 then
        if data.icon > 7 then
            data.icon = math.random(2, 7)
        end
    end
    if data.icon == ConstCfg.TopupBounsIndex then
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
    return FairyGUI.UIPackage.CreateObject("Game341", "Symbol")
end

-- @interface
-- @brief 刷新图案
-- @param render : FairyGUI.GComponent
-- @param data : any
-- @param index: number
function Reel:UpdateSymbol(render, data, index)
    local cfg = SymbolConfig[data.icon]
    -- 加载图标
    local loader = render:GetChild("loader")
    if cfg.url then
        loader.url = cfg.url
        loader.visible = true
    else
        loader.visible = false
    end
    if cfg.scale then
        loader.scale = cfg.scale 
    else
        loader.scale = vec2(1,1)
    end
    -- 数字
    local num = render:GetChild("num")
    -- 遮罩 -- todo
    local mask = render:GetChild("mask")
    -- sprite1 
    local sprite1 = render:GetChild("sprite1")
    -- sprite2 
    local sprite2 = render:GetChild("sprite2")
    mask.visible = self.showMask or false
    if cfg.LDRes then
        local res = cfg.LDRes[data.type]
        num.visible = res.numShow
        sprite1.visible = res.spriteFontShow
        sprite2.visible = res.spriteFontShow
        if res.numShow then
            num.text = Tools.TopupBounsScoreToStr(data.value) 
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

    for _, name in pairs(SymbolConfig.name) do
        local node = render:GetChild(name)
        node.visible = false
    end
    if cfg.nodeNames then
        local node = render:GetChild(cfg.nodeNames.Intro)
        node.visible = true
        node.frame = 0
        node.playing = false
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
    local data = self:RandomSymbolData()
    if self.showMask then
        data.icon = math.random(4, 7)
        self:UpdateSymbol(self.arraySymbolDisplays[0].render, data, 0)
        self:UpdateSymbol(self.arraySymbolDisplays[self.symbolNum + 1].render, data, self.symbolNum + 1)
    end
end

function Reel:SetMask(isShow)
    self.showMask = isShow
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