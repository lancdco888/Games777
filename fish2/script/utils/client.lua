-- utils/client.lua
local root = ...

FF_G_Client = FF_G_Client or {}

FF_G_Client.kFishDeathType_Normal               = 0
FF_G_Client.kFishDeathType_RotationAndFadeOut   = 1000
FF_G_Client.kFishDeathType_Shake                = 1001
FF_G_Client.kFishDeathType_Shake2               = 1002

-- 全局工具函数(客户端)

local sfCache = cc.SpriteFrameCache:getInstance()

-- 创建桢动画
FF_G_Client.CreateFrameAnim = function(imageName, s, e, unit, once)
    unit = unit or 0.01666667
    local sprite = cc.Sprite:create()
    local animation = cc.Animation:create()
    animation:setDelayPerUnit(unit)
    for i = s, e do
        local name = string.format(imageName, i)
        --print(name)
        animation:addSpriteFrame(sfCache:getSpriteFrame(name))
    end
    if once == true then
        sprite:runAction(cc.Sequence:create(
                cc.Animate:create(animation),
                cc.RemoveSelf:create()
        ))
    else
        sprite:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
    end
    return sprite
end

FF_G_Client.CreateNumText = function(imageName, itemW, itemH)
    local Text = {}
    --Text.node = cc.Node:create()
    local lastText = nil
    Text.node = cc.Node:create()
    Text.node:setAnchorPoint(0.5, 0.5)
    -- TODO auto append comma
    Text.SetString = function(text, appendComma)
        if text == lastText then return end
        --print("text:" .. text)
        lastText = text
        local node = Text.node
        node:removeAllChildren()
        local index = 0
        local offX = 0
        for i = 1, string.len(text) do
            local code = string.byte(text, i)
            -- ',' -> 44
            -- '-' -> 45
            -- '.' -> 46
            -- '+' -> 43
            if (code >= 48 and code < 58) or (code >= 43 and code <= 46) or
                    (code >= 65 and code <= 90) or (code >= 97 and code <= 122) then
                local name
                if code == 43 then
                    name = "jiahao"
                elseif code == 44 then
                    name = "d"
                elseif code == 45 then
                    name = "jianhao"
                elseif code == 46 then
                    name = "d"
                elseif code >= 65 and code <= 90 then   -- 'A' - 'Z'
                    name = string.char(code)
                elseif code >= 97 and code <= 122 then  -- 'a' - 'z'
                    name = string.char(code)
                else
                    name = string.sub(text, i, i)
                end
                --print("name:" .. name)
                local sprite = cc.Sprite:createWithSpriteFrameName(string.format(imageName, name))
                sprite:setAnchorPoint(0, 0.5)
                sprite:setPosition(offX, itemH / 2)
                offX = offX + sprite:getContentSize().width
                node:addChild(sprite)
                index = index + 1
            end
        end
        node:setContentSize(offX, itemH)
    end
    return Text
end

local rootNode = nil
FF_G_Client.GetRootNode = function()
    --return mainFishScene
    if not rootNode then
        root:PushGScene()
        rootNode = cc.Director:getInstance():popNode()
    end
    return rootNode
end

local isRotate = root:IsRotate()
local director = cc.Director:getInstance()
local scene = FF_G_Client.GetRootNode()
--local nodeRoot = scene:getChildByName("root")
--local nodeEffectTop = nodeRoot:getChildByName("nodeEffectTop")
--local nodeTop = nodeRoot:getChildByName("nodeTop")
local nodeUiRoot = scene:getChildByName("uiRoot")
local nodeUi = nodeUiRoot:getChildByName("nodeUi")
local nodeUiTop = nodeUiRoot:getChildByName("nodeUiTop")

FF_G_Client.ShowUiEffect = function(node, x, y, time)
    if isRotate then x, y = -x, -y end
    node:setPosition(x, y)
    nodeUi:addChild(node)
    if time ~= nil then
        node:runAction(cc.Sequence:create(
            cc.DelayTime:create(time),
            cc.RemoveSelf:create()
        ))
    end
end

FF_G_Client.ShowFishDeathCoin = function(isSelf, x, y, value)
    if value <= 0 then
        return
    end
    value = value / FF_G.ExchangeRate
    local filename = isSelf and "no2_%s.png" or "no7_%s.png"
    local txt = FF_G_Client.CreateNumText(filename, 29, 40)
    txt.SetString("" .. value)
    local node = txt.node
    node:setCascadeOpacityEnabled(true)
    node:setScale(0)
    node:runAction(cc.Sequence:create(
            cc.EaseElasticInOut:create(cc.ScaleTo:create(0.25, 1), 1.5),
            cc.DelayTime:create(0.5),
            cc.FadeOut:create(0.25),
            cc.RemoveSelf:create()
    ))
    FF_G_Client.ShowUiEffect(txt.node, x, y)
end

-- 金币特效(特殊鱼、boos)
FF_G_Client.ShowFishDeathCoinEffect = function(fishBannerFile, fishFile, coinNum, pos)
    local ret, action = root:ShowEffect("actions/common/zhuanpan/zhuanpan.actions", "zhuanpanzhuandong",
            "", FF_G.kNodeIndex_UiTop, 0, 0, false)
    if ret then
        action:SetLoop(1)
        local anim = action:GetAnim()
        anim:PushRootNode()
        local root = director:popNode()
        local name = cc.Sprite:createWithSpriteFrameName(fishBannerFile)
        local fish = cc.Sprite:createWithSpriteFrameName(fishFile)
        local coin = FF_G_Client.CreateNumText("texiao_suzi_%s.png", 67, 113)

        if isRotate then
            anim:SetPos(-pos.x, -pos.y)
        else
            anim:SetPos(pos.x, pos.y)
        end

        director:pushNode(name)
        director:pushNode(fish)
        director:pushNode(coin.node)

        anim:BindBone("shuzi")
        anim:BindBone("yu")
        anim:BindBone("wenzi")

        local coinNum = coinNum / FF_G.ExchangeRate
        coin.SetString("" .. coinNum)

        root:addChild(name)
        root:addChild(fish)
        root:addChild(coin.node)
        root:setScale(0.75)
    end
    return ret, action
end

local isShowTips = false
local tipsCreators = {}
-- 屏幕上分提示(大鱼进场等)
FF_G_Client.ShowTips = function(tipsCreator)
    if tipsCreator ~= nil then
        table.insert(tipsCreators, tipsCreator)
    end
    if isShowTips or #tipsCreators == 0 then
        return
    end
    table.remove(tipsCreators, 1)(function()
        isShowTips = false
        if FF_G_Client then
            FF_G_Client.ShowTips()
        end
    end)
    isShowTips = true
end

-- 鱼进场提示
FF_G_Client.ShowFishCome = function(info)
    FF_G_Client.ShowTips(function(callback)
        local root = cc.Node:create()
        local bg = cc.Sprite:createWithSpriteFrameName("yuzhonglaixi_beijing.png")
        local avatar = cc.Sprite:createWithSpriteFrameName(info.avatar)
        local tips = cc.Sprite:createWithSpriteFrameName(info.tips)
        local scale = info.scale or 1

        root:setPosition(0, 150)
        bg:setScaleX(1.5)
        avatar:setPosition(-175, 0)
        avatar:setScale(scale)
        tips:setPosition(75, 0)

        root:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.25, 1, 1.5),
                cc.ScaleTo:create(0.15, 1, 1),
                cc.DelayTime:create(1),
                cc.ScaleTo:create(0.15, 1, 1.5),
                cc.ScaleTo:create(0.25, 1, 0),
                cc.Hide:create(),
                cc.DelayTime:create(0.15),
                cc.CallFunc:create(callback),
                cc.RemoveSelf:create()
        ))

        root:addChild(bg)
        root:addChild(avatar)
        root:addChild(tips)
        nodeUiTop:addChild(root)
    end)
end

local function TXRandVec2(x1, x2, y1, y2)
    return math.random() * (x2 - x1) + x1, math.random() * (y2 - y1) + y1
end

-- 切换场景效果(全屏泡泡)
FF_G_Client.FullBlisterEffect = function ()
    --local director = cc.Director:getInstance()
    local scene = FF_G_Client.GetRootNode()
    local node = cc.Node:create()
    node:setLocalZOrder(10)
    local time = 0
    for i = 0, 29 do
        for j = 0, 40 - i - 1 do
            local sprite = cc.Sprite:createWithSpriteFrameName("qipao.png")
            sprite:setScale(i / 30 * 2.3 + 0.3)
            local x1, y1 = TXRandVec2(-300, 1580, -2150 - (-700 * i / 30), (-700 * i / 30))
            local x2, y2 = TXRandVec2(-300, 1580, 1000, 1001)

            local y = 1000 - y1
            local time1 = y / 1550
            time = math.max(time, time1)

            sprite:setPosition(x1, y1)
            node:addChild(sprite)
            sprite:runAction(cc.Sequence:create(
                    cc.MoveTo:create(time1, {x = x2, y = y2}),
                    cc.RemoveSelf:create()
            ))
        end
    end
    --node:addChild(ccui.Text:create("dgdgdg"))
    node:runAction(cc.Sequence:create(
            cc.DelayTime:create(time),
            cc.RemoveSelf:create()
    ))
    scene:addChild(node)
end

FF_G_Client.AddCombinedBg = function(fish, scale, offset)
    --print(fish:GetId())
    fish:GetAnimNode():PushRootNode()
    local rootNode = cc.Director:getInstance():popNode()
    local bg = cc.Sprite:createWithSpriteFrameName("texiao_dapanyu.png")
    if scale then
        bg:setScale(scale)
    end
    if offset then
        bg:setPosition(offset[1], offset[2])
    end
    bg:setLocalZOrder(-1)
    bg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))
    rootNode:addChild(bg)
end

FF_G_Client.GetAnimRootNode = function(anim)
    anim:PushRootNode()
    return cc.Director:getInstance():popNode()
end

FF_G_Client.GetActionRootNode = function(action)
    return FF_G_Client.GetAnimRootNode(action:GetAnim())
end

FF_G_Client.GetActionDrawNode = function(action)
    return FF_G_Client.GetAnimDrawNode(action:GetAnim())
end

FF_G_Client.GetAnimDrawNode = function(anim)
    anim:PushDrawNode()
    return cc.Director:getInstance():popNode()
end

FF_G_Client.SwitchParentTo = function(node, parent)
    node:retain()
    node:removeFromParent(false)
    parent:addChild(node)
    node:release()
end

FF_G_Client.ReAddToParent = function(node)
    FF_G_Client.SwitchParentTo(node, node:getParent())
end

FF_G_Client.GetNodeByNodeIndex = function(nodeIndex)
    root:PushNode(nodeIndex)
    return director:popNode()
end

FF_G_Client.AddNodeTo = function(node, nodeIndex)
    local parent = FF_G_Client.GetNodeByNodeIndex(nodeIndex)
    parent:addChild(node)
end

FF_G_Client.PushNode = function(node)
    director:pushNode(node)
end

FF_G_Client.SwitchParentToNodeIndex = function(node, nodeIndex)
    local parent = FF_G_Client.GetNodeByNodeIndex(nodeIndex)
    node:retain()
    node:removeFromParent(false)
    parent:addChild(node)
    node:release()
end

local screenScaleX
FF_G_Client.GetScreenScaleX = function()
    if screenScaleX then return screenScaleX end
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local root = FF_G_Client.GetRootNode():getParent()
    screenScaleX = 1.0 / root:getScaleX() * (visibleSize.width / 1280)
    print("screenScaleX:", screenScaleX)
    return screenScaleX
end

FF_G_Client.GetPlayerUiPos = function(player)
    local x, y = player:GetPos()
    if isRotate then
        x, y = -x, -y
    end
    return x, y
end

FF_G_Client.IsPlayerInBottom = function(player)
    local id = player:GetSitId()
    return id == 0 or id == 1
end

FF_G_Client.IsPlayerInBottomWithRotate = function(player)
    local id = player:GetSitId()
    if isRotate then
        return id == 2 or id == 3
    end
    return id == 0 or id == 1
end

FF_G_Client.ShowFishDeathEffect = function(playerId, fishTypeId, value)
    local info = FF_G.TypeIdToFishCreator[fishTypeId]
    assert(info)
    local deathInfo = info.DeathEffectInfo
    if not deathInfo then return end
    --assert(deathInfo.banner)
    --assert(string.len(deathInfo.banner) > 0)
    assert(deathInfo.isCsStyle or (deathInfo.banner and string.len(deathInfo.banner) > 0))
    assert(deathInfo.isCsStyle or (deathInfo.avatar and string.len(deathInfo.avatar) > 0))
    local data = FF_G.MergeTables(deathInfo, {
        playerId = playerId,
        value = value,
    })
    FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_ShowFishDeathEffect, data)
    --FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_ShowFishDeathEffect, {
    --    playerId = playerId,
    --    value = value,
    --    isCsStyle = deathInfo.isCsStyle,
    --    banner = deathInfo.banner,
    --    fish = deathInfo.avatar,
    --})
end

FF_G_Client.RunFireAction = function(node)
    node:runAction(
            cc.Sequence:create(
                    cc.ScaleTo:create(0.045, 0.65, 1),
                    cc.ScaleTo:create(0.045, 1)
            )
    )
end

FF_G_Client.ConvertToUiPos = function(x, y)
    if type(x) == "table" then
        if isRotate then
            return {x = -x.x, y = -x.y}
        end
        return {x = x.x, y = x.y}
    else
        if isRotate then
            return -x, -y
        end
        return x, y
    end
end

local showCoinFormat

FF_G_Client.FormatPlayerCoin = function(coin)
    if not showCoinFormat then
        local rate = FF_G.ExchangeRate
        local bits = 0
        for _ = 1, 10 do
            if rate <= 1 then
                break
            end
            bits = bits + 1
            rate = rate / 10
        end
        showCoinFormat = "%0." .. bits .. "f"
    end
    return string.format(showCoinFormat, coin)
end

FF_G_Client.CreateCsBonusBanner = function()
    local type = FF_G.CsBonusType

    local bg
    local anim = false
    local bgScale = 2
    local bannerRotation = true
    local filename = string.format("cs_fish_turntable%d.png", type)
    local s, e

    if type == 5 then
        anim = true
        bgScale = 1
        bannerRotation = false
        filename = string.format("cs_fish_turntable%d ", type) .. "(%s).png"
        s = 1
        e = 10
    elseif type == 4 then
        bgScale = 1
    elseif type == 6 then
        bgScale = 1.2
    end

        if anim then
            bg = FF_G_Client.CreateFrameAnim(filename, s, e, 1 / 15)
        else
            bg = cc.Sprite:createWithSpriteFrameName(filename)
        end
        bg:setScale(bgScale)

        if bannerRotation then
            bg:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5, 360)))
        end
        return bg
    end