-- panel/mermaid.lua
local this, lua, root = ...

if not FF_G.IsServer then
    local ret = {}
    local rootPanel = cc.Node:create()

    local valueText
    local valueBg
    local timesText
    local timesBg

    local function Init(panel, fishType)
        do
            cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/mermaid/mermaid_ui.plist")

            local bgFn = fishType == FF_G.FishInfo.Mermaid.typeId and "mermaid_txk.png" or "mermaid_txk_2.png"
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

        do
            local bgImg = cc.Sprite:createWithSpriteFrameName("lianhuanzhadanxie_baozhacishuxianshi.png")
            local size = bgImg:getContentSize()
            bgImg:setPosition(0, 100)

            local text = FF_G_Client.CreateNumText("lianhuanzhadanxie_shuzi_%d.png", 25, 32)
            text.SetString("1")
            text.node:setPosition(size.width / 2, size.height / 2)
            text.node:setScale(2, 2)

            bgImg:addChild(text.node)
            bgImg:setScale(0.5)
            rootPanel:addChild(bgImg)
            timesText = text
            timesBg = bgImg
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

    local lastValue
    ret.SetValue = function(value)
        if lastValue ~= value then
            valueBg:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.2, 1.25),
                    cc.DelayTime:create(0.25),
                    cc.ScaleTo:create(0.2, 1)
            ))
            valueText.SetString("" .. value, true)
            lastValue = value
        end
    end

    ret.SetTimes = function(times)
        timesText.SetString("" .. times, false)
    end

    ret.ShowScaleEffect = function()
        timesBg:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.2, 0.75),
                --cc.DelayTime:create(0.25),
                cc.ScaleTo:create(0.2, 0.5)
        ))
    end

    return ret
end
