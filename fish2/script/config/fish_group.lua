-- config/fish_group.lua

if not FF_G.FishGroup then
    if FF_G.IsCSGaming then
        FF_G.FishGroup = FF_G.LoadLuaFunc("script/config/fish_group_cs.lua")()
    else
        FF_G.FishGroup = FF_G.LoadLuaFunc("script/config/fish_group_hw.lua")()
    end
end

return FF_G.FishGroup