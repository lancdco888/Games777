-- utils/cannon.lua
local root = ...

-- 炮台倍率显示
FF_G_Client.CreateRatioNode = function(center, ratio, isInBottomSite, isSelf)
    local bgName
    if isSelf then
        bgName = "paotaixianshijinbilanse.png"
    else
        bgName = "paotaixianshijinbihese.png"
    end
    local ratioBg = cc.Sprite:createWithSpriteFrameName(bgName)
    local size = ratioBg:getContentSize()
    --local ratio = ccui.Text:create()
    --local ratioText = FF_G_Client.CreateNumText("no1_%s.png", 23, 28)
    local ratioText = FF_G_Client.CreateNumText("no1_%s.png", 21, 28)
    if isInBottomSite then
        ratioBg:setPosition(center.x, center.y - 8)
    else
        ratioBg:setPosition(center.x, center.y + 8)
        ratioBg:setScaleY(-1)
        ratioText.node:setScaleY(-1)
    end
    ratio = ratio / FF_G.ExchangeRate
    ratioText.SetString("" .. ratio)
    ratioText.node:setPosition(size.width / 2, size.height / 2)
    ratioBg:addChild(ratioText.node)
    return ratioBg
end

---- 炮台基座位置
--FF_G_Client.GetCannonBasePos = function(cannon)
--    local x, y = cannon:GetPos()
--    if y < 0 then
--        y = y - 30
--    else
--        y = y + 30
--    end
--    return x, y
--end
