--[[
通用错误返回
]]
PKG_Generic_Error = {
    typeName = "PKG_Generic_Error",
    typeId = 10,
    Create = function()
        local o = {}
        o.__proto = PKG_Generic_Error
        o.__index = o
        o.__newindex = o


        o.number = 0 -- Int64
        o.message = null -- String
        return o
    end,
    FromBBuffer = function( bb, o )
        o.number = bb:ReadInt64()
        o.message = bb:ReadObject()
    end,
    ToBBuffer = function( bb, o )
        bb:WriteInt64( o.number )
        bb:WriteObject( o.message )
    end
}
BBuffer.Register( PKG_Generic_Error )
--[[
查询版本
]]
PKG_Client_Login_GetServerVersionInfo = {
    typeName = "PKG_Client_Login_GetServerVersionInfo",
    typeId = 2500,
    Create = function()
        local o = {}
        o.__proto = PKG_Client_Login_GetServerVersionInfo
        o.__index = o
        o.__newindex = o
        --[[
        包名
        ]]
        o.packageName = null -- String
        --[[
        用户类型 0=游客 1=facebook 2=用户名密码
        ]]
        o.type = 0 -- Int32
        --[[
        游客传username,facebook传facebookid,用户名密码传用户名
        ]]
        o.account = null -- String
        --[[
        用户名密码登录的密码
        ]]
        o.password = null -- String
        return o
    end,
    FromBBuffer = function( bb, o )
        local ReadObject = bb.ReadObject
        o.packageName = ReadObject( bb )
        o.type = bb:ReadInt32()
        o.account = ReadObject( bb )
        o.password = ReadObject( bb )
    end,
    ToBBuffer = function( bb, o )
        local WriteObject = bb.WriteObject
        WriteObject( bb, o.packageName )
        bb:WriteInt32( o.type )
        WriteObject( bb, o.account )
        WriteObject( bb, o.password )
    end
}
BBuffer.Register( PKG_Client_Login_GetServerVersionInfo )

--[[
服务器版本信息
]]
PKG_Login_Client_ServerVersionInfo = {
    typeName = "PKG_Login_Client_ServerVersionInfo",
    typeId = 2501,
    Create = function()
        local o = {}
        o.__proto = PKG_Login_Client_ServerVersionInfo
        o.__index = o
        o.__newindex = o
        --[[
        info is json
        ]]
        o.info = null -- String
        return o
    end,
    FromBBuffer = function( bb, o )
        o.info = bb:ReadObject()
    end,
    ToBBuffer = function( bb, o )
        bb:WriteObject( o.info )
    end
}
BBuffer.Register( PKG_Login_Client_ServerVersionInfo )
--[[
验证facebook
]]
PKG_Client_Login_ClientVerificationFacebook = {
    typeName = "PKG_Client_Login_ClientVerificationFacebook",
    typeId = 1064,
    Create = function()
        local o = {}
        o.__proto = PKG_Client_Login_ClientVerificationFacebook
        o.__index = o
        o.__newindex = o


        --[[
        token
        ]]
        o.token = null -- String
        return o
    end,
    FromBBuffer = function( bb, o )
        o.token = bb:ReadObject()
    end,
    ToBBuffer = function( bb, o )
        bb:WriteObject( o.token )
    end
}
BBuffer.Register( PKG_Client_Login_ClientVerificationFacebook )
--[[
验证facebook
]]
PKG_Login_Client_ReceivedVerificationFacebook = {
    typeName = "PKG_Login_Client_ReceivedVerificationFacebook",
    typeId = 1071,
    Create = function()
        local o = {}
        o.__proto = PKG_Login_Client_ReceivedVerificationFacebook
        o.__index = o
        o.__newindex = o


        --[[
        验证状态(0=失败；1成功)
        ]]
        o.state = 0 -- Int32
        --[[
        Facebook_id
        ]]
        o.facebook_id = null -- String
        --[[
        Facebook_name
        ]]
        o.facebook_name = null -- String
        return o
    end,
    FromBBuffer = function( bb, o )
        local ReadObject = bb.ReadObject
        o.state = bb:ReadInt32()
        o.facebook_id = ReadObject( bb )
        o.facebook_name = ReadObject( bb )
    end,
    ToBBuffer = function( bb, o )
        local WriteObject = bb.WriteObject
        bb:WriteInt32( o.state )
        WriteObject( bb, o.facebook_id )
        WriteObject( bb, o.facebook_name )
    end
}
BBuffer.Register( PKG_Login_Client_ReceivedVerificationFacebook )

--[[
注册临时聊天服务
]]
PKG_Client_Lobby_RegisterTempMsgService = {
    typeName = "PKG_Client_Lobby_RegisterTempMsgService",
    typeId = 2000,
    Create = function()
        local o = {}
        o.__proto = PKG_Client_Lobby_RegisterTempMsgService
        o.__index = o
        o.__newindex = o


        --[[
        accountid
        ]]
        o.accountid = 0 -- Int32
        --[[
        用户名
        ]]
        o.username = null -- String
        return o
    end,
    FromBBuffer = function( bb, o )
        o.accountid = bb:ReadInt32()
        o.username = bb:ReadObject()
    end,
    ToBBuffer = function( bb, o )
        bb:WriteInt32( o.accountid )
        bb:WriteObject( o.username )
    end
}
BBuffer.Register( PKG_Client_Lobby_RegisterTempMsgService )
--[[
注册临时聊天服务返回结果
]]
PKG_Lobby_Client_RegisterTempMsgServiceResult = {
    typeName = "PKG_Lobby_Client_RegisterTempMsgServiceResult",
    typeId = 1999,
    Create = function()
        local o = {}
        o.__proto = PKG_Lobby_Client_RegisterTempMsgServiceResult
        o.__index = o
        o.__newindex = o


        --[[
        accountid
        ]]
        o.accountid = 0 -- Int32
        --[[
        用户名
        ]]
        o.username = null -- String
        --[[
        图片URL
        ]]
        o.url = null -- String
        return o
    end,
    FromBBuffer = function( bb, o )
        local ReadObject = bb.ReadObject
        o.accountid = bb:ReadInt32()
        o.username = ReadObject( bb )
        o.url = ReadObject( bb )
    end,
    ToBBuffer = function( bb, o )
        local WriteObject = bb.WriteObject
        bb:WriteInt32( o.accountid )
        WriteObject( bb, o.username )
        WriteObject( bb, o.url )
    end
}
BBuffer.Register( PKG_Lobby_Client_RegisterTempMsgServiceResult )