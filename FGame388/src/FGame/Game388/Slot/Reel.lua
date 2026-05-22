local SymbolConfig = Import(".SymbolConfig")
local Tools = Import(".Tools")
local ConstCfg = Import(".ConstCfg")
local MusicCfg = Import(".MusicCfg")
local LuodiSymbolItem = Import(".LuodiSymbolItem")

local Reel = Class("Reel", BaseReel)

-- Reel.isLuodiReel = false
Reel.candidateRates = {1,2,3,5,10}
function Reel:ctor(...)
    Reel.super.ctor(self, ...)
end

-- @interface
-- @brief 返回随机图案数据
function Reel:RandomSymbolData()
    local randomIcon
    if FCasinoCtx.curGameMode == FGameMode.FREE or Tools.IsInFreeLuodiMode() then
        randomIcon = math.random(2, 8) 
    else
        randomIcon = math.random(2, 13) 
    end
    
    local data = {
        icon = randomIcon,
        value = 0,
        type = 0,
        isRandom = true
    }
    local candidateRates = self.candidateRates 
    if data.icon == 2 then
        data.type = math.random() > 0.8 and math.random(1, 3) or 10
        if data.type == 10 then
            local numbers = ConstCfg.TopupBonusNumbers
            -- data.value = numbers[math.random(1, #numbers)] * FCasinoCtx.commonPanel:GetCurrentBetConfig().betMoney
            local rateByC = candidateRates[FCasinoCtx.commonPanel:GetCurCValueIndex()] or 1
            -- data.value = 70 * FCasinoCtx.lobbyData.gameExchangeRate * numbers[math.random(1, #numbers)] * rateByC * FCasinoCtx.commonPanel:GetBetMoney()/68
            data.value = 70 * numbers[math.random(1, #numbers)] * rateByC * FCasinoCtx.commonPanel:GetBetMoney()/68
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
    return FairyGUI.UIPackage.CreateObject("Game388", "Symbol")
end

function Reel:UpdateSymbol(render, data, index, isLuodi)
    self.isLuodi = isLuodi

    local icon = data.icon
    local cfg = SymbolConfig[data.icon]
    
    local loader_normal = render:GetChild("loader-normal")
    local loader_special = render:GetChild("loader-special")
    local loader_sc = render:GetChild("loader-sc")
    local loader_nvxia = render:GetChild("loader-nvxia")
    local ani_free = render:GetChild("ani-free")
    local luodiItemObj = render:GetChild("luodi")
    
    loader_normal.visible = false
    loader_special.visible = false
    loader_sc.visible = false
    loader_nvxia.visible = false
    ani_free.visible = false
    luodiItemObj.visible = false

    if Tools.IsInLuodiMode() and self.isLuodiReel then
        render:GetController("c1").selectedPage = "luodi"
    else
        render:GetController("c1").selectedPage = "normal"
    end

    if icon >= 9 then
        loader_normal.visible = true
        loader_normal.url = cfg.icon
    elseif icon == 4 then
        loader_nvxia.visible = true
        loader_nvxia.url = cfg.icon
    elseif icon == 3 then
        loader_sc.visible = true
        -- loader_nvxia.url = cfg.icon
    elseif icon == 2 then
        local luodiItemComp = LuodiSymbolItem.New(luodiItemObj)
        luodiItemComp:StopClassTracking()
        local luodiType = data.type
        local shouldShowLight = not data.isRandom
        if luodiType == 10 then
            local val = data.value
            luodiItemComp:showNormal(val, shouldShowLight)
        else
            luodiItemComp:showJackPot(luodiType, shouldShowLight)
        end
        luodiItemObj.visible = true
    else
        -- 花牌
        loader_special.visible = true
        loader_special.url = cfg.icon
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
    -- self.isOpen = false
end

function Reel:SetMask(isShow)
    self.showMask = isShow
end

function Reel:SetOpen()
    -- self.isOpen = isOpen
    for i = 1, self.symbolNum do
        local render = self.arraySymbolDisplays[i].render
        if render then
            render.visible = true
        end
    end
end

function BaseReel:OnBounceStart()
    if self.topupPlayCb ~= nil then
        self.topupPlayCb()
        self.topupPlayCb = nil
    end
    
    if self.isBouncePlay ~= nil and not self.isLuodi then
        print("BaseReel:OnBounceStart>>>>>>>>>>>>>>>>>>>>>>>>>>> play reel stop")
        FToolSet.PlayFGUISound(MusicCfg.REELSTOP)
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

function Reel:UpdateSymbolsDraw()
    for i = 0, self.symbolNum + 1 do
        local symbol = self.arraySymbolDisplays[i]
        if symbol.data ~= self.arraySymbolDatas[i] then
            symbol.data = self.arraySymbolDatas[i]

            self:UpdateSymbol(symbol.render, symbol.data, i)
        end
    end
end

return Reel
