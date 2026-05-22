
local Utils = Import(".Utils")
local SymbolConfig = Import(".SymbolConfig")
local GameDefine = Import("..GameDefine")
local Reel = Class("Reel", BaseReel)


Reel.renderCount = 5
Reel.DropDownSpeed = 1800
Reel.symbolChildNames = {
    "normal-icon",
    "ws-icon",
    "jp-icon",
    "jp-diamond-icon",
    "icon-effect-huangguan",
    "icon-effect-shengbei",
    "icon-effect-jiezhi",
    "icon-effect-red",
    "icon-effect-purple",
    "icon-effect-yellow",
    "icon-effect-green",
    "icon-effect-blue",
    "icon-effect-sc",
    "icon-effect-jp",
    "icon-effect-jp-diamond",
    "light-effect",
    "bomb-effect",
    "multiCount"
}

Reel.symbolChildTransitionNames = {
    "award-effect",
    "icon-ani-0",
    "icon-ani-1",
    "icon-ani-2",
    "icon-ani-3",
    "icon-ani-4",
    "icon-ani-5",
    "icon-ani-6",
    "icon-ani-7",
    "icon-ani-8",
    "icon-ani-9",
    "line-score",
    "sc-ani-land",
    "sc-ani-win",
    "thunder-1",
    "thunder-2",
    "thunder-3",
    "thunder-4",
    "jp-ani-land-1",
    "jp-ani-land-2",
    "jp-ani-land-3",
    "jp-ani-land-4",
    "jp-ani-land-5",
    "jp-ani-award-1",
    "jp-ani-award-2",
    "jp-ani-award-3",
    "jp-ani-award-4",
    "jp-ani-award-5"
}
Reel.BasePosYTable = {60,180,300,420,540}

function Reel:ctor(parent, idx)
    self.idx = idx
    self.tweenCount = 0
    self.cfg = clone(FCasinoCtx.gameCfg.Reel)
    self.renders = {
        parent:GetChild("i1"),
        parent:GetChild("i2"),
        parent:GetChild("i3"),
        parent:GetChild("i4"),
        parent:GetChild("i5")
    }

    self.originalPositions = {}
    for i = 1, Reel.renderCount do
        self.originalPositions[i] = self.renders[i].y
    end

    self:InitChildren()
end

function Reel:InitChildren()

    local childNames = Reel.symbolChildNames
    for idx, render in ipairs(self.renders) do
        for _, componentName in ipairs(childNames) do
            local component = render:GetChild(componentName)
            if componentName ~= "normal-icon" and component then
                component.visible = false
            end
        end
    end
    
end

function Reel:PlayJPThunderAnims(jpRenders)
    local hasJP = false
    if jpRenders == nil then
        for idx, render in ipairs(self.renders) do
            if render["jpType"] ~= nil and render["jpType"]  ~= -1 then
                hasJP = true
                local jpType = render["jpType"] == 5 and 4 or render["jpType"]
                render:GetTransition("thunder-" .. jpType):Play()
            end
        end
    else
        for key, render in pairs(jpRenders) do
            if render["jpType"] ~= nil and render["jpType"]  ~= -1 then
                hasJP = true
                local jpType = render["jpType"] == 5 and 4 or render["jpType"]
                render:GetTransition("thunder-" .. jpType):Play()
            end
        end
    end
    if hasJP then 
        Utils.PlaySound("ui://Game481/multiple_thunder_"..math.random(1,2))
    end
end

function Reel:ResetChildren()
    local childNames = Reel.symbolChildNames
    for idx, render in ipairs(self.renders) do
        
        for _, transitionName in ipairs(Reel.symbolChildTransitionNames) do
            render:GetTransition(transitionName):Stop()
        end

        for _, componentName in ipairs(childNames) do
            local component = render:GetChild(componentName)
            if componentName ~= "normal-icon" and 
                componentName ~= "ws-icon" and 
                componentName ~= "jp-icon" and 
                componentName ~= "jp-diamond-icon" and
                componentName ~= "multiCount" and
                component
            then
                component.visible = false
            end
        end
    end
end


function Reel:UpdateSymbol(render, data, rowIdx)

    local childNames = Reel.symbolChildNames
    for _, componentName in ipairs(childNames) do
        render:GetChild(componentName).visible = false
    end
    if data == nil then return end

    local icon = data.icon
    local value = data.value
    local cfg = SymbolConfig[icon]
    if not cfg then return end


    local loader 
    render["isSC"] = false    
    render["jpType"] = -1    
    render["value"] = -1    
    render.sortingOrder = 1
    if icon == GameDefine.ICON_SCATTER then

        loader = render:GetChild("ws-icon")
        render["isSC"] = true  
        render.sortingOrder = 10
        
    elseif icon == GameDefine.ICON_JP then
        render.sortingOrder = 10
        
        multiCountLabel = render:GetChild("multiCount")
        multiCountLabel.text = tostring(value).."x"
        multiCountLabel.visible = true
        render["value"] = value
        loader = render:GetChild("jp-icon")
        if value < 10 then
            loader.url = cfg.icon[1]
            render["jpType"] = 1
        elseif value < 20 then
            loader.url = cfg.icon[2]
            render["jpType"] = 2
        elseif value < 100 then
            loader.url = cfg.icon[3]
            render["jpType"] = 3
        elseif value < 1000 then
            loader.url = cfg.icon[4]
            render["jpType"] = 4
        else
            loader = render:GetChild("jp-diamond-icon")
            render["jpType"] = 5
        end

    else

        loader = render:GetChild("normal-icon")
        loader.url = cfg.icon

    end

    loader.visible = true

end

function Reel:ShowSymbols(idx)
    local tweenShowCount = 0
    local len = Reel.renderCount
    for i = 1, len do
        local child = self.renders[i]
        local fromY = child.y - child.height * (len - i - 2) 
        local targetY = self.originalPositions[i]
        local distance = targetY - child.y
        local duration = distance / Reel.DropDownSpeed  -- Assuming a speed of 1100 pixels per second
        local delayTime = (len - i)* 0.1

        child.y = fromY
        self.TweenChildDown(child, delayTime, fromY, targetY, duration, function()
            if tweenShowCount == 0 then
                Utils.PlaySound("ui://Game481/elasticity_"..idx)
            end
            tweenShowCount = tweenShowCount + 1
            if tweenShowCount >= len then
                self.showCallback()

                if Utils.itemExists(self.audioSCReelIdxs, idx) ~= -1 then
                    Utils.PlaySound("ui://Game481/scatter_"..idx)
                end
            end
        end)
    end
end

function Reel:HideSymbols()
    local tweenHideCount = 0
    local sampleChild = self.renders[1]
    local childHeight = sampleChild.height 
    local targetY = self.originalPositions[Reel.renderCount] + childHeight * 1.5
    local firstChildY = self.originalPositions[1]
    for i = Reel.renderCount, 1, -1 do
        local child = self.renders[i]
        local distance = targetY - child.y
        local duration = distance / Reel.DropDownSpeed  -- Assuming a speed of 500 pixels per second
        -- local delayTime = (Reel.renderCount - i) * .04
        local delayTime = distance / childHeight  * .04
        local fromY = child.y
        FTween.Start(
            child,
            FTween.Delay(delayTime),
            FTween.To(FairyGUI.TweenPropType.Y, fromY, targetY, duration),  -- Tween to target Y position with calculated duration
            FTween.CallFunc(function()

                -- 显示结果图案
                if self.reelData then
                    self:UpdateSymbol(child, self.reelData[i], i)
                end

                tweenHideCount = tweenHideCount + 1
                if tweenHideCount == Reel.renderCount then
                    for i = 1, Reel.renderCount do
                        local child = self.renders[i]
                        child.y = firstChildY - sampleChild.height * (i + 1)
                    end

                    self.hideCallback()
                end
            end)
        )
    end
end

function Reel.TweenChildDown(obj, delayTime, fromY, targetY, duration, callback, isRefill)
    local overshootY = targetY + 32
    FTween.Start(
        obj,
        FTween.Delay(delayTime),
        FTween.To(FairyGUI.TweenPropType.Y, fromY, overshootY, duration * 0.7),  -- Overshoot
        FTween.To(FairyGUI.TweenPropType.Y, overshootY, targetY, duration * 0.3),  -- Move back
        FTween.CallFunc(function()
            local jpType = obj["jpType"]
            if obj["isSC"] then
                obj:GetTransition("sc-ani-land"):Play()
                callback()
            elseif jpType ~= nil and jpType ~= -1 then
                obj:GetTransition("jp-ani-land-" .. jpType):Play(function()
                    if isRefill then
                        if jpType == 5 then jpType = 4 end
                        obj:GetTransition("thunder-"..jpType):Play(function()
                            callback()
                        end)
                    else
                        callback()
                    end
                end)
            else
                callback()
            end
        end)
    )
end

function Reel:Recovery(reelData)
    for i = 1, Reel.renderCount do
        local child = self.renders[i]
        self:UpdateSymbol(child, reelData[i], i)
        child.y = Reel.BasePosYTable[i]
    end
end

function Reel:SetShowResultData(reelData, audioSCReelIdxs, hideCallback, showCallback)

    self.reelData = reelData
    self.hideCallback = hideCallback
    self.showCallback = showCallback
    self.audioSCReelIdxs = audioSCReelIdxs

end


return Reel