-- effect/death_coin.lua
local root, fish, lua, isSelf, x, y, value = ...
-- 鱼死亡显示金币效果

if not FF_G.IsServer then
    FF_G_Client.ShowFishDeathCoin(isSelf, x, y, value)
end

