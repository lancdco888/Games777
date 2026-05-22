-- utils/broadcast.lua
local root = ...
-- Broadcast System.
local receivers = {}

-- 鱼死亡特效(Player上方显示的spine效果)
FF_G.kBroadcastKey_ShowFishDeathEffect  = 1
-- 金币飘到玩家身上
FF_G.kBroadcastKey_CoinMoveToPlayer     = 2
-- 发射子弹
FF_G.kBroadcastKey_Fire                 = 3
-- 玩家进场或离场
FF_G.kBroadcastKey_PlayerEnterOrExit    = 4
-- 锁定显示金币
FF_G.kBroadcastKey_LockShowCoin         = 5
-- 金币不足
FF_G.kBroadcastKey_CoinNotEnough        = 6

FF_G.Broadcast = {
    register = function(name, receiver)
        --print("register:" .. name)
        if receivers[name] == nil then receivers[name] = {} end
        receivers[name][receiver] = receiver
    end,
    unRegister = function(name, receiver)
        --print("unRegister:" .. name)
        if receivers[name] == nil then return end
        receivers[name][receiver] = nil
    end,
    unRegisterAll = function(receiver)
        --print("unRegisterAll:")
        for _, v in pairs(receivers) do
            if v[receiver] ~= nil then v[receiver] = nil end
        end
    end,
    sendBroadcast = function(name, data)
        --print("broadcast:" .. name)
        local receiver = receivers[name]
        if receiver == nil then return end
        for _, v in pairs(receiver) do
            if type(v.onReceive) == "function" then
                v.onReceive(name, data)
            end
        end
    end
}