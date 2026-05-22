-- local SymbolConfig = Import(".SymbolConfig")
local Utils = Import(".Utils")
local GameDefine = Import("..GameDefine")

local TopSymbol = Class("TopSymbol")

function TopSymbol:ctor(parent, itemObj, index, aniUrl, icon,isLuodi,luodiType,luodiValue)
    self.render = itemObj
    local xy = Utils.getLogicPosInSlotContainer(index)
    if icon == GameDefine.ICON_WILD or icon == GameDefine.ICON_XIANGNANG then
        xy.y = xy.y - 10
    else
        self.render.scale = vec2(0.8, 0.8)
        xy.x = xy.x + 11
    end

    if isLuodi then
        self.render.x = xy.x + self.render.width/2 - 12
        self.render.y = xy.y + self.render.height/2
    else 
        self.render.x = xy.x
        self.render.y = xy.y
    end

    self.aniUrl = aniUrl
    self.icon = icon
    self.isLuodi = isLuodi
    self.luodiType = luodiType
    self.luodiValue = luodiValue
    parent:AddChild(self.render)

    self.loader_icon = self.render:GetChild("loader_icon")
    self.loader_wild = self.render:GetChild("loader_wild")
    self.loader_animal = self.render:GetChild("loader_animal")
    self.loader_luodi_icon = self.render:GetChild("loader_luodi")
    self.text_luodi = self.render:GetChild("text_luodi")
    -- self.dragonItem = self.render:GetChild("dragonItem")
    self.loader_luodi_spe_val = self.render:GetChild("loader_luodi_spe_val")
end

function TopSymbol:__delete()
    self.render:RemoveFromParent(true)
end

function TopSymbol:Reset()
    self.render.visible = true
    if self.loader_icon and not self.isLuodi then self.loader_icon.visible = true end
    if self.loader_wild then self.loader_wild.visible = false end
    if self.loader_animal then self.loader_animal.visible = false end
    if self.loader_luodi_icon then self.loader_luodi_icon.visible = false end
    if self.text_luodi then self.text_luodi.visible = false end
    if self.loader_luodi_spe_val then self.loader_luodi_spe_val.visible = false end
end

function TopSymbol:ShowLuodiAppear(cb)
    local trans = self.render:GetTransition("show")
    trans:Play(
        function() cb() end
    )
end

-- @brief 数字显示
function TopSymbol:SetText(childName, text)
    if childName == nil then
        return
    end

    local label = self.render:GetChild(childName)
    if not label then
        return
    end

    label.visible = true
    label.text = text
end

function TopSymbol:SetVisible(value)
    self.render.visible = value
end

function TopSymbol:GetRootPos()
    return self.render:LocalToRoot(vec2(self.render.width * 0.5, self.render.height * 0.5))
end

function TopSymbol:ClearShowLine()
    if not Utils.itemExists(GameDefine.ICONS_FLY, self.icon) then
        local aniLoader = self.render:GetChild("loader")
        aniLoader.visible = false
    -- aniLoader.url = ""
    end
    -- aniLoader.playing = false
end

function TopSymbol:ShowLine(type,value)
    if not self.isLuodi then
        local aniLoader = self.render:GetChild("loader")
        if aniLoader then
            aniLoader.url = self.aniUrl
            aniLoader.visible = true
            aniLoader.playing = true
        end
    else
        -- self:ShowLuodiData(type,value)
    end
end

return TopSymbol
