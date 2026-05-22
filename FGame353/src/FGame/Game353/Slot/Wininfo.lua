local Wininfo = Class("Wininfo")
local Utils = Import(".Utils")
function Wininfo:ctor(render)
    self.render = render
    self.render.visible = false
    self:InitUI()
end

function Wininfo:__delete()
end


local iconNames =
{
    "swd-00_353",    --1-百搭
    "ssc-00_353",    --2-财宝 这个来出免费
    "sh1-00_353",    --3-禄
    "sh2-00_353",    --4-福
    "sh3-00_353",    --5-财
    "sh4-00_353",    --6-吉
    "sh5-00_353",    --7-红包
    "sl1-00_353",    --8-A
    "sl2-00_353",    --9-K
    "sl3-00_353",    --10-Q
    "sl4-00_353",    --11-J
    "sl5-00_353",    --12-10
    "sl6-00_353",    --13-9
    "swd-00_353",    --1-百搭
    "swd-00_353",    --1-百搭
    "swd-00_353",    --1-百搭
}

function Wininfo:InitUI()
 
    self._lenText = self.render:GetChild("lenText")
   
    self._icon = self.render:GetChild("icon")
   
    self._infoText = self.render:GetChild("infoText")
    
end

function Wininfo:Show(icon, len, aCoin, count)
    self.render.visible = true
    --
    self._lenText.text = len
    --
    self._icon.url = "ui://Game353/"..iconNames[icon]
    local str_aCoin = FToolSet.NumToStr(aCoin)
    if count == 1 then
        self._infoText.text = string.format("#%s", str_aCoin)
    else
        self._infoText.text = string.format("#%s(x%d)", str_aCoin, count)
    end
    --
end

function Wininfo:Hide()
    self.render.visible = false
end

return Wininfo