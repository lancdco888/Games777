-- panel/player_info_self.lua
local this, lua, root = ...

local ret = {}

local root = cc.Node:create()
root:setScale(0.85)

-- 普通金币根结点
local coinNode = cc.Node:create()
-- 绑定金币根结点
local bindCoinNode = cc.Node:create()

-- 背景亮框
local bgLightBound
-- 普通金币
local coinText
-- 绑定金币
local bindCoinText
-- Vip等级
local vipLevelText = FF_G_Client.CreateNumText("no2_%s.png", 29, 40)

-- 切换到普通金币
local switchToNormalCoin = ccui.Button:create("money_type_switch.png", "", "", ccui.TextureResType.plistType)
-- 切换到绑定金币
local switchToBindCoin = ccui.Button:create("money_type_switch.png", "", "", ccui.TextureResType.plistType)

local vipBg = cc.Sprite:createWithSpriteFrameName("vip_bg.png")

FF_G_Client.AddNodeTo(root, FF_G.kNodeIndex_Ui)

local moneyType
local vipLevel

local function CreateAvatar(avatarId)
    if avatarId <= 0 or avatarId > 12 then
        return cc.Sprite:create()
    end
    local fn = string.format("txd_%d.png", this:GetAvatarId())
    return cc.Sprite:createWithSpriteFrameName(fn)
end

local function GetCoinRootScale()
    return (moneyType == 0) and 1.0 or 0.85
end

local function GetBindCoinRootScale()
    return (moneyType ~= 0) and 1.0 or 0.85
end

local function UpdateUiState()
    local isNormal = moneyType == 0

    switchToNormalCoin:setVisible(not isNormal)
    switchToBindCoin:setVisible(isNormal)

    coinNode:setScale(GetCoinRootScale())
    bindCoinNode:setScale(GetBindCoinRootScale())

    coinText.node:setColor(isNormal and cc.c3b(255,255,255) or cc.c3b(0x80, 0x80, 0x80))
    bindCoinText.node:setColor((not isNormal) and cc.c3b(255,255,255) or cc.c3b(0x80, 0x80, 0x80))

    coinNode:stopActionByTag(1024)
    bindCoinNode:stopActionByTag(1024)
end

local function SetMoneyType(newMoneyType)
    --print("set money type:" .. newMoneyType)
    assert(newMoneyType == 0 or newMoneyType == 1)
    if moneyType == newMoneyType then
        return
    end
    moneyType = newMoneyType
    UpdateUiState()
end

local function UpdateVipUiState()
    vipLevelText.SetString(tostring(vipLevel))
    vipBg:setVisible(vipLevel > 0 and (not FF_G.MaskVipLv))
end

local function SetVipLevel(newVipLevel)
    if vipLevel == newVipLevel then
        return
    end
    vipLevel = newVipLevel
    UpdateVipUiState()
    --print("set vip lv:" .. newVipLevel)
end

local function SwitchMoneyType(moneyType)
    if sGameManager.GetMyVipLevel() < 0 then
        local fn = "guest_ues_bindcoin_tips.png"
        local sprite = cc.Sprite:createWithSpriteFrameName(fn)
        sprite:setScale(0)
        sprite:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.25, 1, 1.5),
                cc.ScaleTo:create(0.15, 1, 1),
                cc.DelayTime:create(2.5),
                cc.ScaleTo:create(0.15, 1, 1.5),
                cc.ScaleTo:create(0.25, 1, 0),
                cc.RemoveSelf:create()
        ))
        FF_G_Client.AddNodeTo(sprite, FF_G.kNodeIndex_UiTop)
    else
        SetMoneyType(moneyType)
        if ret.OnSwitchMoneyType then
            ret.OnSwitchMoneyType(moneyType)
        end
    end
end

local function UpdateCoin(text, coin)
    local showCoin = coin / FF_G.ExchangeRate
    text.SetString(FF_G_Client.FormatPlayerCoin(showCoin))
    local width = text.node:getContentSize().width
    local scale = math.min(0.65, math.max(0, 150 / width))
    text.node:setScale(scale)
    text.scale = scale
end

local function SetCoin(coin)
    UpdateCoin(coinText, coin)
end

local function SetBindCoin(coin)
    UpdateCoin(bindCoinText, coin)
end

-- 获取金币效果
local function AddCoinEffect()
    local coinScale = GetCoinRootScale()
    local bindCoinScale = GetBindCoinRootScale()

    local action = cc.Sequence:create(
            cc.ScaleTo:create(0.15, 1.25 * coinScale),
            cc.ScaleTo:create(0.15, coinScale)
    )
    local action1 = cc.Sequence:create(
            cc.ScaleTo:create(0.15, 1.25 * bindCoinScale),
            cc.ScaleTo:create(0.15, bindCoinScale)
    )
    action:setTag(1024)
    action1:setTag(1024)

    coinNode:stopActionByTag(1024)
    bindCoinNode:stopActionByTag(1024)
    coinNode:runAction(action)
    bindCoinNode:runAction(action1)
end

local function SetPosition(isSelf, inBottom, x, y)
    if not isSelf then
        if inBottom then
            y = y - 10
        else
            y = y + 10
        end
    end
    root:setPosition(x, y)
end

local function SplashBgLightBound(times)
    local action = cc.Sequence:create(
            cc.Repeat:create(
                    cc.Sequence:create(
                            cc.FadeOut:create(0.25),
                            cc.FadeIn:create(0.25)
                    ),
                    times
            )
    )
    action:setTag(1024)
    bgLightBound:stopActionByTag(1024)
    bgLightBound:runAction(action)
end

local function Init(isSelf, inBottom, avatarId, nickname)
    if FF_G.MaskBindCoin then
        isSelf = false
    end
    local function InitPlayerInfo(offY)
        local avatar = CreateAvatar(avatarId)
        avatar:setPosition(-95, offY)
        avatar:setScale(1.25)
        root:addChild(avatar)

        local nicknameTxt = ccui.Text:create()
        nicknameTxt:enableOutline(cc.c4b(0x0, 0x0, 0x0, 0xff), 2)
        nicknameTxt:setColor(cc.c3b(0x75, 0xfb, 0xc1, 0xff))
        nicknameTxt:setFontSize(20)
        nicknameTxt:setText(nickname)
        nicknameTxt:setPosition(-75, offY)
        nicknameTxt:setAnchorPoint(0, 0.5)
        root:addChild(nicknameTxt)

        --local vipOffY = offY + 5
        --if not isSelf and not inBottom then
        --    vipOffY = vipOffY - 6
        --end
        vipBg:setScale(1.15)
        vipBg:setPosition(95, offY)
        vipLevelText.node:setScale(0.3)
        vipLevelText.node:setPosition(34, 14)
        vipLevelText.SetString("0")
        vipBg:addChild(vipLevelText.node)
        root:addChild(vipBg)
    end

    local function InitCoinPanel(offY)
        --coinNode:setPosition(0, 18)
        coinNode:setPosition(0, offY)

        local coinIcon = cc.Sprite:createWithSpriteFrameName("player_coin.png")
        coinIcon:setPosition(-95, 0)
        coinIcon:setScale(0.5)

        coinText.node:setPosition(-8, 0)
        coinText.node:setScale(0.75)
        coinText.node:setCascadeColorEnabled(true)
        --coinText.SetString("12345.6")

        coinNode:addChild(coinIcon)
        coinNode:addChild(coinText.node)
        root:addChild(coinNode)
    end

    local function InitBindCoinPanel(offY)
        -- init bind coin ui
        do
            --bindCoinNode:setPosition(0, -15)
            bindCoinNode:setPosition(0, offY)

            local coinIcon = cc.Sprite:createWithSpriteFrameName("player_bind_coin.png")
            coinIcon:setPosition(-95, 0)
            coinIcon:setScale(0.5)

            bindCoinText.node:setPosition(-8, 0)
            bindCoinText.node:setScale(0.75)
            bindCoinText.node:setCascadeColorEnabled(true)
            --bindCoinText.SetString("12345.6")

            bindCoinNode:addChild(coinIcon)
            bindCoinNode:addChild(bindCoinText.node)
            root:addChild(bindCoinNode)
        end
    end

    local fn = isSelf and "no2_%s.png" or "no7_%s.png"
    coinText = FF_G_Client.CreateNumText(fn, 29, 40)
    bindCoinText = FF_G_Client.CreateNumText(fn, 29, 40)

    -- init bg
    do
        -- 背景框
        local bg = ccui.Scale9Sprite:createWithSpriteFrameName("jinbikuang_02.png")
        local size = { width = 232, height = 40}
        local infoBg

        if isSelf then
            infoBg = cc.Sprite:createWithSpriteFrameName("player_bg_self.png")
            size = infoBg:getContentSize()
            root:addChild(bg)
            root:addChild(infoBg)
        else
            infoBg = ccui.Scale9Sprite:createWithSpriteFrameName("jinbixianshibeijing.png")
            infoBg:setPreferredSize(size)
            infoBg:setPosition(0, 0)

            root:addChild(bg)
            root:addChild(infoBg)
        end

        if isSelf then
            local panel = ccui.Layout:create()
            panel:setAnchorPoint(0.5, 0.5)
            panel:setContentSize(size)
            panel:setTouchEnabled(true)
            panel:addTouchEventListener(function(_, type)
                if type ~= ccui.TouchEventType.ended then return end
                local newMoneyType = moneyType == 0 and 1 or 0
                SwitchMoneyType(newMoneyType)
            end)
            root:addChild(panel, -1)
        end

        size.width = size.width + 28
        size.height = size.height + 28
        bg:setPreferredSize(size)
        bgLightBound = bg
    end

    -- init normal coin ui
    if isSelf then
        InitCoinPanel(18)
        InitBindCoinPanel(-15)
        InitPlayerInfo(70)
    else
        InitCoinPanel(0)
        InitBindCoinPanel(-15)
        local offY = (inBottom == true) and 50 or -55
        InitPlayerInfo(offY)
        bindCoinNode:setVisible(false)
    end

    -- init money type switch buttons
    if isSelf then
        switchToNormalCoin:addTouchEventListener(function(_, type)
            if type ~= ccui.TouchEventType.ended then return end
            SwitchMoneyType(0)
        end)
        switchToNormalCoin:setTouchEnabled(true)
        switchToNormalCoin:setPosition(100, -18)
        root:addChild(switchToNormalCoin, 0)

        switchToBindCoin:addTouchEventListener(function(_, type)
            if type ~= ccui.TouchEventType.ended then return end
            SwitchMoneyType(1)
        end)
        switchToBindCoin:setTouchEnabled(true)
        switchToBindCoin:setPosition(100, 15)
        root:addChild(switchToBindCoin, 1)
    end
end

local function UnInit()
    if root then
        root:removeFromParent()
        root = nil
    end
end

ret.Init = Init
ret.UnInit = UnInit
ret.SetCoin = SetCoin
ret.SetBindCoin = SetBindCoin
ret.SetMoneyType = SetMoneyType
ret.SetVipLevel = SetVipLevel
ret.AddCoinEffect = AddCoinEffect
ret.SetPosition = SetPosition
ret.SplashBgLightBound = SplashBgLightBound

return ret
