--[[
大厅PING
]]
PKG_Client_Lobby_Ping = {
    typeName = "PKG_Client_Lobby_Ping",
    typeId = 2062,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_Ping)
        end
        o.ticks = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- ticks
        r, self.ticks = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- ticks
        d:Wvi64(self.ticks)
    end
}
PKG_Client_Lobby_Ping.__index = PKG_Client_Lobby_Ping

--[[
大厅Pong
]]
PKG_Lobby_Client_Pong = {
    typeName = "PKG_Lobby_Client_Pong",
    typeId = 1283,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Pong)
        end
        o.ticks = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- ticks
        r, self.ticks = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- ticks
        d:Wvi64(self.ticks)
    end
}
PKG_Lobby_Client_Pong.__index = PKG_Lobby_Client_Pong

local o = ObjMgr
o.Register(PKG_Client_Lobby_Ping)
o.Register(PKG_Lobby_Client_Pong)
