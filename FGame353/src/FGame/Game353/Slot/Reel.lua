
local SymbolConfig = Import(".SymbolConfig")
local Tools = Import(".Tools")
local Utils = Import(".Utils")
local Reel = Class("Reel", BaseReel)
local BaseSlot = Import(".BaseSlot")
Reel.isspecial = false
Reel.isInfree = false
Reel.freeicotype = 0 -- 1普通模式， 2 红色模式 3 黄色模式
Reel.bgrender = {}
Reel.iswildtype = 0
Reel.loopicon = {}
Reel.columnfive = 0
Reel.fouricon = {0,0,0,0}
-- @interface
-- @brief 返回随机图案数据
function Reel:RandomSymbolData()
    local data = {
        icon  = math.random(1, 14),
        type = 0
    }
    --在免费旋转中 不出jp图标
    if Reel.isInfree then
        data.icon = math.random(1, 13)
        data.type = 0
        if data.icon == 12 and (self.idx == 5 or self.idx == 1) then
            data.icon = math.random(1,10)
        end
        return data
    end
    if Reel.isspecial then
        local specialreel = {1,2,6,7,8,9,10,11,12,13,14}
        data.icon = specialreel[math.random(1, #specialreel)]
        data.type = 0
    end
    --第五列出现jp 如果是初次出现Reel.columnfive == 0 ,切换成火车图标类型
    --如果不是初次出现 则切换成普通图标
    if data.icon == 14 then
        data.type = math.random(1,2) == 1 and math.random(11,14) or 1
        if Reel.isspecial and Reel.fouricon[self.idx] == 0 then
            Reel.fouricon[self.idx] = 1
        end
        if self.idx == 5 then
            if Reel.columnfive == 0  then
                data.type =  99 
                Reel.columnfive = 1
            else
                data.icon  = math.random(1, 10)
                data.type =  0
            end
        end
    end
     --第5列有金星，金火车间隔3个空 叠加到3次之后 图标切换成星星图标类型
     if self.idx == 5 and Reel.columnfive > 0  then
        Reel.columnfive = Reel.columnfive + 1
        if Reel.columnfive == 6 then
            data.icon = 14
            data.type = 88
        elseif Reel.columnfive == 10 then
            Reel.columnfive = 0
        end
    end
    --连续播放4个jp图标
    if Reel.isspecial and self.idx < 5 and Reel.fouricon[self.idx] > 0 and Reel.fouricon[self.idx] < 5 then
        if Reel.fouricon[self.idx] == 4 then
            data.type = math.random(1,4) == 1 and math.random(11,14) or 1
        else
            data.type = 1
        end
        data.icon = 14
    end
    if Reel.isspecial and self.idx < 5  and Reel.fouricon[self.idx] > 0 then
        if Reel.fouricon[self.idx] > 5 then
            data.icon = math.random(1, 10)
            data.type = 0
        end
        Reel.fouricon[self.idx]  = Reel.fouricon[self.idx] + 1
        if Reel.fouricon[self.idx] == 9 then
            Reel.fouricon[self.idx]  = 0
        end
    end
    --刷新jptype上的数据
    local numbers = {25,50,75,100,125,150,175,200}
    if data.type == 1 then
        data.value = numbers[math.random(1, #numbers)] * FCasinoCtx.commonPanel:GetCurrentBetConfig().betMoney/100
    end
    if data.icon == 12 and (self.idx == 5 or self.idx == 1) then
        data.icon = math.random(1,10)
    end
    return data
end

-- @interface
-- @brief 图标排序接口
function Reel:OnUpdateSymbolZorder(render, data, index)
    if Reel.isspecial then
        if  (data.icon == 5 or data.icon == 3 or data.icon == 13  ) then
            render.sortingOrder  = -index
            return
        end
    end
    render.sortingOrder = SymbolConfig[data.icon].zorder + index
end

-- @interface
-- @brief 创建渲染组件接口
function Reel:OnCreateSymbolRenderComponent()
   return FairyGUI.UIPackage.CreateObject("Game353", "Symbol")
end
function Reel:SetMask(isShow)
    self.showMask = isShow
end

-- @interface
-- @brief 刷新图案
-- @param render : FairyGUI.GComponent
-- @param data : any
-- @param index: number
function Reel:UpdateSymbol(render, data, index)
    local cfg = SymbolConfig[data.icon]
    render.visible = true
    -- 加载图标
    local loader = render:GetChild("loader")
    loader.visible = true
    loader.url = cfg.icon
    -- 数字
    local num = render:GetChild("num")
    -- 遮罩 -- todo
    local mask = render:GetChild("mask")
    mask.visible =  false
    if Reel.isspecial and not cfg.LDRes then
        mask.visible =  true
    end
    if cfg.ssc and Reel.isInfree then
        loader.url = cfg.icon.."free"
    end
    if cfg.LDRes and data.type ~= nil and data.type ~= 0 then
        local res = cfg.LDRes[data.type]
        num.visible = res.numShow
        if res.numShow then
            num.text = Tools.TopupBounsScoreToStr(data.value)
        end
        if data.type > 1 then
            loader.url = cfg.icon..data.type
        end
       
        -- mask.visible = false
    else
        num.visible = false
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