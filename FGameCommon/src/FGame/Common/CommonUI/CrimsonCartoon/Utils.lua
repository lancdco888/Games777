local Utils = {}


function Utils.SetChildColor(object)
    local color = FTheme.curThemCfg.iconColor
    for i = 0, object.numChildren - 1 do
        local child = object:GetChildAt(i)
        local name = child.name
        if name == "icon" or string.sub(name, 1, 6) == "color_" then
            child.color = color
        end
    end
end


return Utils