
CodeGen_generic_md5 ="#*MD5<b8db1cae20fe1fb702c040ad89b86834>*#"

--[[
通用返回
]]
PKG_Generic_Success = {
    typeName = "PKG_Generic_Success",
    typeId = 101,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Generic_Success)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Generic_Success.__index = PKG_Generic_Success

--[[
通用返回失败
]]
PKG_Generic_Fail = {
    typeName = "PKG_Generic_Fail",
    typeId = 102,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Generic_Fail)
        end
        o.number = 0 -- Int64
        o.message = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- number
        r, self.number = d:Rvi64()
        if r ~= 0 then return r end
        -- message
        r, self.message = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- number
        d:Wvi64(self.number)
        -- message
        d:Wstr(self.message)
    end
}
PKG_Generic_Fail.__index = PKG_Generic_Fail

--[[
通用错误返回
]]
PKG_Generic_Error = {
    typeName = "PKG_Generic_Error",
    typeId = 103,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Generic_Error)
        end
        o.number = 0 -- Int64
        o.message = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- number
        r, self.number = d:Rvi64()
        if r ~= 0 then return r end
        -- message
        r, self.message = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- number
        d:Wvi64(self.number)
        -- message
        d:Wstr(self.message)
    end
}
PKG_Generic_Error.__index = PKG_Generic_Error

local o = ObjMgr
o.Register(PKG_Generic_Success)
o.Register(PKG_Generic_Fail)
o.Register(PKG_Generic_Error)