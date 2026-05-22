-- panel/speedboat.lua
local this, lua, root = ...

if not FF_G.IsServer then
    local ret = {}
    local rootPanel = cc.Node:create()

    local valueText
    local valueBg

    local function Init(panel)
        do
            -- 和美人鱼资源放在一起了
            cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/mermaid/mermaid_ui.plist")
            local bgFn = "speedboat_score_panel_bg.png"
            local bg = cc.Sprite:createWithSpriteFrameName(bgFn)
            bg:setPosition(0, -100)
            local size = bg:getContentSize()

            local text = FF_G_Client.CreateNumText("mermaid_%s.png", 25, 31)
            text.node:setPosition(size.width / 2 + 15, size.height / 2 - 7)
            text.SetString("0", true)

            bg:addChild(text.node)

            rootPanel:addChild(bg)
            valueText = text
            valueBg = bg
        end

        rootPanel:setLocalZOrder(1)
        panel:addChild(rootPanel)
    end

    local function UnInit()
        if rootPanel then
            rootPanel:removeFromParent()
            rootPanel = nil
        end
    end

    ret.Init = Init
    ret.UnInit = UnInit

    ret.Show = function()
        rootPanel:setVisible(true)
    end

    ret.Hide = function()
        rootPanel:setVisible(false)
    end

    ret.SetVisible = function(visible)
        rootPanel:setVisible(visible)
    end

    local destValue
    local currentValue = 0
    ret.SetValue = function(value)
        if destValue ~= value then
            if value > 0 then
                valueBg:runAction(cc.Sequence:create(
                        cc.ScaleTo:create(0.2, 1.25),
                        cc.DelayTime:create(0.25),
                        cc.ScaleTo:create(0.2, 1)
                ))
            end
            --valueText.SetString("" .. value, true)
            destValue = value
        end
    end

    local deltaNumber = 100
    -- 设置滚动显示每帧增加的数量
    ret.SetDeltaNumber = function(number)
        deltaNumber = number
    end

    ret.Update = function(dt)
        --print("update:", currentValue, ",", destValue)
        if currentValue ~= destValue then
            local num = math.floor((destValue - currentValue) / 30)
            local delta = deltaNumber
            if num > delta then
                delta = math.max(num - num % delta, delta)
            end
            local value = math.min(destValue, currentValue + delta)
            valueText.SetString("" .. value, true)
            currentValue = value
        end
    end

    --ret.ShowScaleEffect = function()
    --    timesBg:runAction(cc.Sequence:create(
    --            cc.ScaleTo:create(0.2, 0.75),
    --            --cc.DelayTime:create(0.25),
    --            cc.ScaleTo:create(0.2, 0.5)
    --    ))
    --end

    return ret
end
