-- config/fish_info.lua

if not FF_G.FishInfo then
    if FF_G.IsCSGaming then
        --FF_G.FishInfo = FF_G.MergeTables(
        --        FF_G.LoadLuaFunc("script/config/fish_info_hw.lua")(),
        --        FF_G.LoadLuaFunc("script/config/fish_info_cs.lua")()
        --)
        FF_G.FishInfo = FF_G.LoadLuaFunc("script/config/fish_info_cs.lua")()
    else
        FF_G.FishInfo = FF_G.LoadLuaFunc("script/config/fish_info_hw.lua")()
    end
end

return FF_G.FishInfo