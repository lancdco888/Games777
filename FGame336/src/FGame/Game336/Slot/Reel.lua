
local SymbolConfig = Import(".SymbolConfig")
local Utils = Import(".Utils")
local Reel = Class("Reel", BaseReel)

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
        data.type = math.random(1, 1)
        if data.type == 1 then
            local bases = {1, 2, 3, 4, 5,10,15,20,50,100,200,250}
            local base = bases[math.random(1, #bases)]
            local severNum =  base *  FCasinoCtx.commonPanel:GetBetMoney()--服务器值基数*当前押注值
            data.value = severNum
        end
    end

    -- if self.inTopupBouns then
    --     data.icon = math.random(1, 12)
    -- end

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
    return FairyGUI.UIPackage.CreateObject("Game336", "Symbol")
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
    render.visible = true
    -- 加载图标
    local loader = render:GetChild("loader")
    loader.url = cfg.icon
    if cfg.loaderScale then
        loader.scale = cfg.loaderScale
    else
        loader.scale = vec2(1,1)
    end
    loader.y ,loader.x = 0,0
    if cfg.loaderpositionY then
        loader.y = loader.y + cfg.loaderpositionY
    end
    --数字图片大小位置优化
    if data.icon > 7 then
        loader.x = 194 * (1 - loader.scale.x) /2
        loader.y = 144 * (1 - loader.scale.y) /2
    end
    -- loader.scale = cfg.loaderScale
    -- 数字
    local num = render:GetChild("num")
    -- 遮罩 -- todo
    local mask = render:GetChild("mask")
    -- sprite1 
    local sprite1 = render:GetChild("sprite1")
    -- sprite2 
    local sprite2 = render:GetChild("sprite2")
    --wildbet2
    local sprite3 = render:GetChild("sprite3")
    local TopupBounsbg =  render:GetChild("TopupBounsbg")
    --再免费游戏中 并且是百搭动画
    if FCasinoCtx.curGameMode == FGameMode.FREE and data.icon == 1 then
        sprite3.visible = true
    else
        sprite3.visible = false
    end
    if self.showMask then
        mask.visible = true
    end
    --灯笼高亮
    if  data.icon == 2 then
        mask.visible = false
    end
    if cfg.LDRes then
        local res = cfg.LDRes[data.type]
        num.visible = res.numShow
        sprite1.visible = res.spriteFontShow
        sprite2.visible = res.spriteFontShow
        if res.numShow then
            num.text =  Utils.TopupBounsScoreToStr(data.value)
            --num.text = FToolSet.NumToStr(data.value)
        end
        if res.sprite1Url and res.sprite1Url ~= "" then
            sprite1.url = res.sprite1Url
        end
        if res.sprite2Url and res.sprite2Url ~= "" then
            sprite2.url = res.sprite2Url
        end
        TopupBounsbg.visible = true
    else
        TopupBounsbg.visible = false
        num.visible = false
        sprite1.visible = false
        sprite2.visible = false
    end
end
-- @interface 
-- @brief 开始旋转回调函数
function Reel:OnScrollBegin()
    for i = 1, self.symbolNum do
        local render = self.arraySymbolDisplays[i].render
        if render then
            render.visible = true
        end
    end
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
end
return Reel