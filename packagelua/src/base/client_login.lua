
CodeGen_client_login_md5 ="#*MD5<7303ea307c6f011669b18297404b5e45>*#"

--[[
客户端登陆类型
]]
PKG_Client_Login_ClientType = {
    typeName = "PKG_Client_Login_ClientType",
    typeId = 1103,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_ClientType)
        end
        --[[
        客户端登陆类型[unknown,windows,iphone10,xiaomi...]
        ]]
        o.clientType = "" -- String
        --[[
        最后一次登录的手机系统(0 robot,1 andriod,2 ios,3 windows)
        ]]
        o.phoneType = 0 -- Int32
        --[[
        注册IP
        ]]
        o.createIp = "" -- String
        --[[
        版本号
        ]]
        o.version = "" -- String
        --[[
        包名
        ]]
        o.packageName = "" -- String
        --[[
        设备号(手机唯一编号),注册时写入(不修改)
        ]]
        o.device_id = "" -- String
        --[[
        内存信息
        ]]
        o.ram = "" -- String
        --[[
        推广码
        ]]
        o.promotion_code = "" -- String
        --[[
        facebook账号/id
        ]]
        o.facebook = "" -- String
        --[[
        密码
        ]]
        o.password = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- clientType
        r, self.clientType = d:Rstr()
        if r ~= 0 then return r end
        -- phoneType
        r, self.phoneType = d:Rvi32()
        if r ~= 0 then return r end
        -- createIp
        r, self.createIp = d:Rstr()
        if r ~= 0 then return r end
        -- version
        r, self.version = d:Rstr()
        if r ~= 0 then return r end
        -- packageName
        r, self.packageName = d:Rstr()
        if r ~= 0 then return r end
        -- device_id
        r, self.device_id = d:Rstr()
        if r ~= 0 then return r end
        -- ram
        r, self.ram = d:Rstr()
        if r ~= 0 then return r end
        -- promotion_code
        r, self.promotion_code = d:Rstr()
        if r ~= 0 then return r end
        -- facebook
        r, self.facebook = d:Rstr()
        if r ~= 0 then return r end
        -- password
        r, self.password = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- clientType
        d:Wstr(self.clientType)
        -- phoneType
        d:Wvi32(self.phoneType)
        -- createIp
        d:Wstr(self.createIp)
        -- version
        d:Wstr(self.version)
        -- packageName
        d:Wstr(self.packageName)
        -- device_id
        d:Wstr(self.device_id)
        -- ram
        d:Wstr(self.ram)
        -- promotion_code
        d:Wstr(self.promotion_code)
        -- facebook
        d:Wstr(self.facebook)
        -- password
        d:Wstr(self.password)
    end
}
PKG_Client_Login_ClientType.__index = PKG_Client_Login_ClientType

--[[
验证包基类
]]
PKG_Client_Login_Auth = {
    typeName = "PKG_Client_Login_Auth", -- : PKG_Client_Login_ClientType
    typeId = 1104,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_Auth)
        end
        PKG_Client_Login_ClientType.Create(o)
        --[[
        包生成时的协议号
        ]]
        o.pkgGenMd5 = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Client_Login_ClientType.Read(self, om)
        if r ~= 0 then return r end
        -- pkgGenMd5
        r, self.pkgGenMd5 = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Client_Login_ClientType.Write(self, om)
        -- pkgGenMd5
        d:Wstr(self.pkgGenMd5)
    end
}
PKG_Client_Login_Auth.__index = PKG_Client_Login_Auth

--[[
按钮开关
]]
PKG_Login_Client_button_settings = {
    typeName = "PKG_Login_Client_button_settings",
    typeId = 1015,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_button_settings)
        end
        --[[
        按钮id
        ]]
        o.key = 0 -- Int32
        --[[
        是否开启 1=开启 0=关闭
        ]]
        o.is_open = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- key
        r, self.key = d:Rvi32()
        if r ~= 0 then return r end
        -- is_open
        r, self.is_open = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- key
        d:Wvi32(self.key)
        -- is_open
        d:Wvi32(self.is_open)
    end
}
PKG_Login_Client_button_settings.__index = PKG_Login_Client_button_settings

PKG_Login_Client_GameUpdatePath = {
    typeName = "PKG_Login_Client_GameUpdatePath",
    typeId = 1005,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_GameUpdatePath)
        end
        --[[
        游戏id
        ]]
        o.gameId = 0 -- Int32
        --[[
        游戏热更新路径
        ]]
        o.gameUpdatePath = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- gameId
        r, self.gameId = d:Rvi32()
        if r ~= 0 then return r end
        -- gameUpdatePath
        r, self.gameUpdatePath = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- gameId
        d:Wvi32(self.gameId)
        -- gameUpdatePath
        d:Wstr(self.gameUpdatePath)
    end
}
PKG_Login_Client_GameUpdatePath.__index = PKG_Login_Client_GameUpdatePath

--[[
网络重新导向
]]
PKG_Login_Client_ReRouteNetWork = {
    typeName = "PKG_Login_Client_ReRouteNetWork",
    typeId = 1010,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_ReRouteNetWork)
        end
        --[[
        域名
        ]]
        o.host = "" -- String
        --[[
        端口
        ]]
        o.port = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- host
        r, self.host = d:Rstr()
        if r ~= 0 then return r end
        -- port
        r, self.port = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- host
        d:Wstr(self.host)
        -- port
        d:Wvi32(self.port)
    end
}
PKG_Login_Client_ReRouteNetWork.__index = PKG_Login_Client_ReRouteNetWork

--[[
获取热更新路径
]]
PKG_Login_Client_GetUpdatePath_Success = {
    typeName = "PKG_Login_Client_GetUpdatePath_Success",
    typeId = 1004,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_GetUpdatePath_Success)
        end
        --[[
        大厅热更新路径
        ]]
        o.lobbyUpdatePath = "" -- String
        --[[
        游戏热更新路径
        ]]
        o.gameUpdatePaths = {} -- List<Shared<PKG.Login_Client.GameUpdatePath>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- lobbyUpdatePath
        r, self.lobbyUpdatePath = d:Rstr()
        if r ~= 0 then return r end
        -- gameUpdatePaths
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.gameUpdatePaths = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- lobbyUpdatePath
        d:Wstr(self.lobbyUpdatePath)
        -- gameUpdatePaths
        o = self.gameUpdatePaths
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Login_Client_GetUpdatePath_Success.__index = PKG_Login_Client_GetUpdatePath_Success

--[[
客户端包类型验证
]]
PKG_Login_Client_ReceivedPackagetType = {
    typeName = "PKG_Login_Client_ReceivedPackagetType",
    typeId = 1006,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_ReceivedPackagetType)
        end
        --[[
        验证状态(0=失败；1成功)
        ]]
        o.state = 0 -- Int32
        o.message = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- state
        r, self.state = d:Rvi32()
        if r ~= 0 then return r end
        -- message
        r, self.message = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- state
        d:Wvi32(self.state)
        -- message
        d:Wstr(self.message)
    end
}
PKG_Login_Client_ReceivedPackagetType.__index = PKG_Login_Client_ReceivedPackagetType

--[[
客户端推广码验证
]]
PKG_Login_Client_ReceivedPromotionCode = {
    typeName = "PKG_Login_Client_ReceivedPromotionCode",
    typeId = 1007,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_ReceivedPromotionCode)
        end
        --[[
        验证状态(0=失败；1成功)
        ]]
        o.state = 0 -- Int32
        o.message = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- state
        r, self.state = d:Rvi32()
        if r ~= 0 then return r end
        -- message
        r, self.message = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- state
        d:Wvi32(self.state)
        -- message
        d:Wstr(self.message)
    end
}
PKG_Login_Client_ReceivedPromotionCode.__index = PKG_Login_Client_ReceivedPromotionCode

--[[
强更包
]]
PKG_Login_Client_GameEnforceUpdatePath = {
    typeName = "PKG_Login_Client_GameEnforceUpdatePath",
    typeId = 1011,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_GameEnforceUpdatePath)
        end
        o.version = "" -- String
        o.updatePath = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- version
        r, self.version = d:Rstr()
        if r ~= 0 then return r end
        -- updatePath
        r, self.updatePath = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- version
        d:Wstr(self.version)
        -- updatePath
        d:Wstr(self.updatePath)
    end
}
PKG_Login_Client_GameEnforceUpdatePath.__index = PKG_Login_Client_GameEnforceUpdatePath

--[[
服务器版本信息
]]
PKG_Login_Client_ServerVersionInfo = {
    typeName = "PKG_Login_Client_ServerVersionInfo",
    typeId = 1009,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_ServerVersionInfo)
        end
        --[[
        info is json
        ]]
        o.info = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- info
        r, self.info = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- info
        d:Wstr(self.info)
    end
}
PKG_Login_Client_ServerVersionInfo.__index = PKG_Login_Client_ServerVersionInfo

--[[
校验成功, 下一步去连游戏
]]
PKG_Login_Client_Auth_Success_Game = {
    typeName = "PKG_Login_Client_Auth_Success_Game",
    typeId = 1002,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_Auth_Success_Game)
        end
        --[[
        游戏类型编号
        ]]
        o.gameId = 0 -- Int32
        --[[
        游戏ip
        ]]
        o.gameIp = "" -- String
        --[[
        游戏port
        ]]
        o.gamePort = 0 -- Int16
        --[[
        游戏token
        ]]
        o.gameToken = "" -- String
        --[[
        用户名
        ]]
        o.username = "" -- String
        --[[
        账号Id
        ]]
        o.accountId = 0 -- Int32
        --[[
        手机号
        ]]
        o.phone = "" -- String
        --[[
        facebook账号/id
        ]]
        o.facebook = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- gameId
        r, self.gameId = d:Rvi32()
        if r ~= 0 then return r end
        -- gameIp
        r, self.gameIp = d:Rstr()
        if r ~= 0 then return r end
        -- gamePort
        r, self.gamePort = d:Rvi16()
        if r ~= 0 then return r end
        -- gameToken
        r, self.gameToken = d:Rstr()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- phone
        r, self.phone = d:Rstr()
        if r ~= 0 then return r end
        -- facebook
        r, self.facebook = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- gameId
        d:Wvi32(self.gameId)
        -- gameIp
        d:Wstr(self.gameIp)
        -- gamePort
        d:Wvi16(self.gamePort)
        -- gameToken
        d:Wstr(self.gameToken)
        -- username
        d:Wstr(self.username)
        -- accountId
        d:Wvi32(self.accountId)
        -- phone
        d:Wstr(self.phone)
        -- facebook
        d:Wstr(self.facebook)
    end
}
PKG_Login_Client_Auth_Success_Game.__index = PKG_Login_Client_Auth_Success_Game

--[[
注册账号结果
]]
PKG_Login_Client_RegisterAccountInfo = {
    typeName = "PKG_Login_Client_RegisterAccountInfo",
    typeId = 1012,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_RegisterAccountInfo)
        end
        --[[
        用户id
        ]]
        o.account_id = 0 -- Int32
        --[[
        用户名
        ]]
        o.username = "" -- String
        --[[
        登陆账号
        ]]
        o.account_name = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        -- account_name
        r, self.account_name = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
        -- username
        d:Wstr(self.username)
        -- account_name
        d:Wstr(self.account_name)
    end
}
PKG_Login_Client_RegisterAccountInfo.__index = PKG_Login_Client_RegisterAccountInfo

--[[
验证google
]]
PKG_Login_Client_ReceivedVerificationGoogle = {
    typeName = "PKG_Login_Client_ReceivedVerificationGoogle",
    typeId = 1013,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_ReceivedVerificationGoogle)
        end
        --[[
        验证状态(0=失败；1成功)
        ]]
        o.state = 0 -- Int32
        --[[
        google id
        ]]
        o.google_id = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- state
        r, self.state = d:Rvi32()
        if r ~= 0 then return r end
        -- google_id
        r, self.google_id = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- state
        d:Wvi32(self.state)
        -- google_id
        d:Wstr(self.google_id)
    end
}
PKG_Login_Client_ReceivedVerificationGoogle.__index = PKG_Login_Client_ReceivedVerificationGoogle

--[[
验证google
]]
PKG_Login_Client_ReceivedVerificationApple = {
    typeName = "PKG_Login_Client_ReceivedVerificationApple",
    typeId = 1014,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_ReceivedVerificationApple)
        end
        --[[
        验证状态(0=失败；1成功)
        ]]
        o.state = 0 -- Int32
        --[[
        apple id
        ]]
        o.apple_id = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- state
        r, self.state = d:Rvi32()
        if r ~= 0 then return r end
        -- apple_id
        r, self.apple_id = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- state
        d:Wvi32(self.state)
        -- apple_id
        d:Wstr(self.apple_id)
    end
}
PKG_Login_Client_ReceivedVerificationApple.__index = PKG_Login_Client_ReceivedVerificationApple

--[[
验证facebook
]]
PKG_Login_Client_ReceivedVerificationFacebook = {
    typeName = "PKG_Login_Client_ReceivedVerificationFacebook",
    typeId = 1008,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_ReceivedVerificationFacebook)
        end
        --[[
        验证状态(0=失败；1成功)
        ]]
        o.state = 0 -- Int32
        --[[
        Facebook_id
        ]]
        o.facebook_id = "" -- String
        --[[
        Facebook_name
        ]]
        o.facebook_name = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- state
        r, self.state = d:Rvi32()
        if r ~= 0 then return r end
        -- facebook_id
        r, self.facebook_id = d:Rstr()
        if r ~= 0 then return r end
        -- facebook_name
        r, self.facebook_name = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- state
        d:Wvi32(self.state)
        -- facebook_id
        d:Wstr(self.facebook_id)
        -- facebook_name
        d:Wstr(self.facebook_name)
    end
}
PKG_Login_Client_ReceivedVerificationFacebook.__index = PKG_Login_Client_ReceivedVerificationFacebook

--[[
校验成功, 下一步去连大厅
]]
PKG_Login_Client_Auth_Success_Lobby = {
    typeName = "PKG_Login_Client_Auth_Success_Lobby",
    typeId = 1001,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_Auth_Success_Lobby)
        end
        --[[
        大厅token
        ]]
        o.lobbyToken = "" -- String
        --[[
        用户名( 如果是新用户以用户名方式注册, 就夹带生成的 GUID 码返回以便客户端记录下来 )
        ]]
        o.username = "" -- String
        --[[
        用户Id
        ]]
        o.accountId = 0 -- Int32
        --[[
        电话
        ]]
        o.phone = "" -- String
        --[[
        facebook账号/id
        ]]
        o.facebook = "" -- String
        --[[
        游戏Id
        ]]
        o.gameId = 0 -- Int32
        --[[
        玩家信息
        ]]
        o.self = null -- Shared<PKG.ClassDef.selfAccount>
        --[[
        vip信息
        ]]
        o.vips = {} -- List<Shared<PKG.ClassDef.Vip>>
        --[[
        ServerId
        ]]
        o.serviceId = 0 -- Int32
        --[[
        金币和真钱比例 1000 表示 1真钱=1000游戏币
        ]]
        o.money_exchange_coin = 0 -- Int32
        --[[
        码值等级
        ]]
        o.gift_cfg = {} -- List<Shared<PKG.ClassDef.gift_cfg>>
        --[[
        是否实名制登记 0=关闭 1=开启 
        ]]
        o.is_open_realname_mode = 0 -- Int32
        --[[
        google id
        ]]
        o.google = "" -- String
        --[[
        apple id
        ]]
        o.apple = "" -- String
        --[[
        活动赠送类型 0=绑定金币 1=金币
        ]]
        o.activity_give_type = 0 -- Int32
        --[[
        功能硬性开关
        ]]
        o.botton_configs = {} -- List<Shared<PKG.Login_Client.button_settings>>
        --[[
        压住彩金模式
        ]]
        o.slots_bet_lottery_mode = 0 -- Int32
        --[[
        洗码模式0=常规洗码 1=必须有压住的金币才能洗码
        ]]
        o.washcode_mode = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- lobbyToken
        r, self.lobbyToken = d:Rstr()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- phone
        r, self.phone = d:Rstr()
        if r ~= 0 then return r end
        -- facebook
        r, self.facebook = d:Rstr()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvi32()
        if r ~= 0 then return r end
        -- self
        r, self.self = om:Read()
        if r ~= 0 then return r end
        -- vips
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.vips = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- serviceId
        r, self.serviceId = d:Rvi32()
        if r ~= 0 then return r end
        -- money_exchange_coin
        r, self.money_exchange_coin = d:Rvi32()
        if r ~= 0 then return r end
        -- gift_cfg
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.gift_cfg = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- is_open_realname_mode
        r, self.is_open_realname_mode = d:Rvi32()
        if r ~= 0 then return r end
        -- google
        r, self.google = d:Rstr()
        if r ~= 0 then return r end
        -- apple
        r, self.apple = d:Rstr()
        if r ~= 0 then return r end
        -- activity_give_type
        r, self.activity_give_type = d:Rvi32()
        if r ~= 0 then return r end
        -- botton_configs
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.botton_configs = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- slots_bet_lottery_mode
        r, self.slots_bet_lottery_mode = d:Rvi32()
        if r ~= 0 then return r end
        -- washcode_mode
        r, self.washcode_mode = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- lobbyToken
        d:Wstr(self.lobbyToken)
        -- username
        d:Wstr(self.username)
        -- accountId
        d:Wvi32(self.accountId)
        -- phone
        d:Wstr(self.phone)
        -- facebook
        d:Wstr(self.facebook)
        -- gameId
        d:Wvi32(self.gameId)
        -- self
        om:Write(self.self)
        -- vips
        o = self.vips
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- serviceId
        d:Wvi32(self.serviceId)
        -- money_exchange_coin
        d:Wvi32(self.money_exchange_coin)
        -- gift_cfg
        o = self.gift_cfg
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- is_open_realname_mode
        d:Wvi32(self.is_open_realname_mode)
        -- google
        d:Wstr(self.google)
        -- apple
        d:Wstr(self.apple)
        -- activity_give_type
        d:Wvi32(self.activity_give_type)
        -- botton_configs
        o = self.botton_configs
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- slots_bet_lottery_mode
        d:Wvi32(self.slots_bet_lottery_mode)
        -- washcode_mode
        d:Wvi32(self.washcode_mode)
    end
}
PKG_Login_Client_Auth_Success_Lobby.__index = PKG_Login_Client_Auth_Success_Lobby

--[[
注册账号密码
]]
PKG_Client_Login_RegisterAccount = {
    typeName = "PKG_Client_Login_RegisterAccount",
    typeId = 1113,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_RegisterAccount)
        end
        --[[
        包名
        ]]
        o.packageName = "" -- String
        --[[
        客户端登陆类型 手机型号
        ]]
        o.clientType = "" -- String
        --[[
        系统类型(0 robot,1 andriod,2 ios,3 windows)
        ]]
        o.phoneType = 0 -- Int32
        --[[
        设备号(手机唯一编号),注册时写入(不修改)
        ]]
        o.device_id = "" -- String
        --[[
        账号名
        ]]
        o.account_name = "" -- String
        --[[
        密码
        ]]
        o.password = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- packageName
        r, self.packageName = d:Rstr()
        if r ~= 0 then return r end
        -- clientType
        r, self.clientType = d:Rstr()
        if r ~= 0 then return r end
        -- phoneType
        r, self.phoneType = d:Rvi32()
        if r ~= 0 then return r end
        -- device_id
        r, self.device_id = d:Rstr()
        if r ~= 0 then return r end
        -- account_name
        r, self.account_name = d:Rstr()
        if r ~= 0 then return r end
        -- password
        r, self.password = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- packageName
        d:Wstr(self.packageName)
        -- clientType
        d:Wstr(self.clientType)
        -- phoneType
        d:Wvi32(self.phoneType)
        -- device_id
        d:Wstr(self.device_id)
        -- account_name
        d:Wstr(self.account_name)
        -- password
        d:Wstr(self.password)
    end
}
PKG_Client_Login_RegisterAccount.__index = PKG_Client_Login_RegisterAccount

--[[
验证apple
]]
PKG_Client_Login_ClientVerificationApple = {
    typeName = "PKG_Client_Login_ClientVerificationApple",
    typeId = 1115,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_ClientVerificationApple)
        end
        --[[
        google token
        ]]
        o.token = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- token
        r, self.token = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- token
        d:Wstr(self.token)
    end
}
PKG_Client_Login_ClientVerificationApple.__index = PKG_Client_Login_ClientVerificationApple

--[[
验证google
]]
PKG_Client_Login_ClientVerificationGoogle = {
    typeName = "PKG_Client_Login_ClientVerificationGoogle",
    typeId = 1114,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_ClientVerificationGoogle)
        end
        --[[
        google token
        ]]
        o.token = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- token
        r, self.token = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- token
        d:Wstr(self.token)
    end
}
PKG_Client_Login_ClientVerificationGoogle.__index = PKG_Client_Login_ClientVerificationGoogle

--[[
查询版本
]]
PKG_Client_Login_GetServerVersionInfo = {
    typeName = "PKG_Client_Login_GetServerVersionInfo",
    typeId = 1112,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_GetServerVersionInfo)
        end
        --[[
        包名
        ]]
        o.packageName = "" -- String
        --[[
        用户类型 0=游客 1=facebook 2=用户名密码 3=代理 4=google 5=apple
        ]]
        o.type = 0 -- Int32
        --[[
        游客传username,facebook传facebookid,用户名密码传用户名
        ]]
        o.account = "" -- String
        --[[
        用户名密码登录的密码
        ]]
        o.password = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- packageName
        r, self.packageName = d:Rstr()
        if r ~= 0 then return r end
        -- type
        r, self.type = d:Rvi32()
        if r ~= 0 then return r end
        -- account
        r, self.account = d:Rstr()
        if r ~= 0 then return r end
        -- password
        r, self.password = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- packageName
        d:Wstr(self.packageName)
        -- type
        d:Wvi32(self.type)
        -- account
        d:Wstr(self.account)
        -- password
        d:Wstr(self.password)
    end
}
PKG_Client_Login_GetServerVersionInfo.__index = PKG_Client_Login_GetServerVersionInfo

--[[
验证facebook
]]
PKG_Client_Login_ClientVerificationFacebook = {
    typeName = "PKG_Client_Login_ClientVerificationFacebook",
    typeId = 1111,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_ClientVerificationFacebook)
        end
        --[[
        token
        ]]
        o.token = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- token
        r, self.token = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- token
        d:Wstr(self.token)
    end
}
PKG_Client_Login_ClientVerificationFacebook.__index = PKG_Client_Login_ClientVerificationFacebook

--[[
获取热更新路径
]]
PKG_Client_Login_GetUpdatePath = {
    typeName = "PKG_Client_Login_GetUpdatePath",
    typeId = 1110,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_GetUpdatePath)
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
PKG_Client_Login_GetUpdatePath.__index = PKG_Client_Login_GetUpdatePath

--[[
重置密码
]]
PKG_Client_Login_ResetPassword = {
    typeName = "PKG_Client_Login_ResetPassword",
    typeId = 1109,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_ResetPassword)
        end
        --[[
        用户填写的电话号码
        ]]
        o.phone = "" -- String
        --[[
        短信校验码
        ]]
        o.verifyCode = "" -- String
        --[[
        新密码
        ]]
        o.newPassword = "" -- String
        --[[
        设备号(手机唯一编号)
        ]]
        o.device_id = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- phone
        r, self.phone = d:Rstr()
        if r ~= 0 then return r end
        -- verifyCode
        r, self.verifyCode = d:Rstr()
        if r ~= 0 then return r end
        -- newPassword
        r, self.newPassword = d:Rstr()
        if r ~= 0 then return r end
        -- device_id
        r, self.device_id = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- phone
        d:Wstr(self.phone)
        -- verifyCode
        d:Wstr(self.verifyCode)
        -- newPassword
        d:Wstr(self.newPassword)
        -- device_id
        d:Wstr(self.device_id)
    end
}
PKG_Client_Login_ResetPassword.__index = PKG_Client_Login_ResetPassword

--[[
请求下发短信
]]
PKG_Client_Login_RequireVerifyCode = {
    typeName = "PKG_Client_Login_RequireVerifyCode",
    typeId = 1108,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_RequireVerifyCode)
        end
        --[[
        用户填写的电话号码
        ]]
        o.phone = "" -- String
        --[[
        区号
        ]]
        o.AreaCode = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- phone
        r, self.phone = d:Rstr()
        if r ~= 0 then return r end
        -- AreaCode
        r, self.AreaCode = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- phone
        d:Wstr(self.phone)
        -- AreaCode
        d:Wstr(self.AreaCode)
    end
}
PKG_Client_Login_RequireVerifyCode.__index = PKG_Client_Login_RequireVerifyCode

--[[
手机 + 密码 登陆
]]
PKG_Client_Login_AuthByPhonePassword = {
    typeName = "PKG_Client_Login_AuthByPhonePassword", -- : PKG_Client_Login_Auth
    typeId = 1107,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_AuthByPhonePassword)
        end
        PKG_Client_Login_Auth.Create(o)
        --[[
        手机号
        ]]
        o.phone = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Client_Login_Auth.Read(self, om)
        if r ~= 0 then return r end
        -- phone
        r, self.phone = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Client_Login_Auth.Write(self, om)
        -- phone
        d:Wstr(self.phone)
    end
}
PKG_Client_Login_AuthByPhonePassword.__index = PKG_Client_Login_AuthByPhonePassword

--[[
游客 登录( 通过传空用户名来实现新用户注册 + 登录, 成功后记录到本地 )
]]
PKG_Client_Login_AuthByUsername = {
    typeName = "PKG_Client_Login_AuthByUsername", -- : PKG_Client_Login_Auth
    typeId = 1106,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_AuthByUsername)
        end
        PKG_Client_Login_Auth.Create(o)
        --[[
        用户名
        ]]
        o.username = "" -- String
        --[[
        账号名
        ]]
        o.account_name = "" -- String
        --[[
        google id
        ]]
        o.google = "" -- String
        --[[
        apple id
        ]]
        o.apple = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Client_Login_Auth.Read(self, om)
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        -- account_name
        r, self.account_name = d:Rstr()
        if r ~= 0 then return r end
        -- google
        r, self.google = d:Rstr()
        if r ~= 0 then return r end
        -- apple
        r, self.apple = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Client_Login_Auth.Write(self, om)
        -- username
        d:Wstr(self.username)
        -- account_name
        d:Wstr(self.account_name)
        -- google
        d:Wstr(self.google)
        -- apple
        d:Wstr(self.apple)
    end
}
PKG_Client_Login_AuthByUsername.__index = PKG_Client_Login_AuthByUsername

--[[
手机登陆( 已过时，会直接用这个手机号来建 acc, 密码为空 )
]]
PKG_Client_Login_AuthByPhone = {
    typeName = "PKG_Client_Login_AuthByPhone", -- : PKG_Client_Login_Auth
    typeId = 1105,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_AuthByPhone)
        end
        PKG_Client_Login_Auth.Create(o)
        --[[
        手机号
        ]]
        o.phone = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Client_Login_Auth.Read(self, om)
        if r ~= 0 then return r end
        -- phone
        r, self.phone = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Client_Login_Auth.Write(self, om)
        -- phone
        d:Wstr(self.phone)
    end
}
PKG_Client_Login_AuthByPhone.__index = PKG_Client_Login_AuthByPhone

--[[
客户端推广码验证
]]
PKG_Client_Login_ClientPromotionCode = {
    typeName = "PKG_Client_Login_ClientPromotionCode",
    typeId = 1102,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_ClientPromotionCode)
        end
        --[[
        facebook账号/id
        ]]
        o.facebook = "" -- String
        --[[
        用户名
        ]]
        o.username = "" -- String
        --[[
        设备号(手机唯一编号),注册时写入(不修改)
        ]]
        o.device_id = "" -- String
        --[[
        推广码
        ]]
        o.promotion_code = "" -- String
        --[[
        google id
        ]]
        o.google = "" -- String
        --[[
        apple id
        ]]
        o.apple = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- facebook
        r, self.facebook = d:Rstr()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        -- device_id
        r, self.device_id = d:Rstr()
        if r ~= 0 then return r end
        -- promotion_code
        r, self.promotion_code = d:Rstr()
        if r ~= 0 then return r end
        -- google
        r, self.google = d:Rstr()
        if r ~= 0 then return r end
        -- apple
        r, self.apple = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- facebook
        d:Wstr(self.facebook)
        -- username
        d:Wstr(self.username)
        -- device_id
        d:Wstr(self.device_id)
        -- promotion_code
        d:Wstr(self.promotion_code)
        -- google
        d:Wstr(self.google)
        -- apple
        d:Wstr(self.apple)
    end
}
PKG_Client_Login_ClientPromotionCode.__index = PKG_Client_Login_ClientPromotionCode

--[[
客户端包类型验证
]]
PKG_Client_Login_ClientPackagetType = {
    typeName = "PKG_Client_Login_ClientPackagetType",
    typeId = 1101,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_ClientPackagetType)
        end
        --[[
        facebook账号/id
        ]]
        o.facebook = "" -- String
        --[[
        用户名
        ]]
        o.username = "" -- String
        --[[
        设备号(手机唯一编号),注册时写入(不修改)
        ]]
        o.device_id = "" -- String
        --[[
        包类型(0=正常官网包;1=特殊推荐包)
        ]]
        o.packageType = 0 -- Int32
        --[[
        google id
        ]]
        o.google = "" -- String
        --[[
        apple id
        ]]
        o.apple = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- facebook
        r, self.facebook = d:Rstr()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        -- device_id
        r, self.device_id = d:Rstr()
        if r ~= 0 then return r end
        -- packageType
        r, self.packageType = d:Rvi32()
        if r ~= 0 then return r end
        -- google
        r, self.google = d:Rstr()
        if r ~= 0 then return r end
        -- apple
        r, self.apple = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- facebook
        d:Wstr(self.facebook)
        -- username
        d:Wstr(self.username)
        -- device_id
        d:Wstr(self.device_id)
        -- packageType
        d:Wvi32(self.packageType)
        -- google
        d:Wstr(self.google)
        -- apple
        d:Wstr(self.apple)
    end
}
PKG_Client_Login_ClientPackagetType.__index = PKG_Client_Login_ClientPackagetType

--[[
判断此用户名是否能绑定
]]
PKG_Client_Login_HasAccountName = {
    typeName = "PKG_Client_Login_HasAccountName",
    typeId = 1116,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Login_HasAccountName)
        end
        --[[
        账号
        ]]
        o.account_name = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_name
        r, self.account_name = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_name
        d:Wstr(self.account_name)
    end
}
PKG_Client_Login_HasAccountName.__index = PKG_Client_Login_HasAccountName

--[[
检查账号结果
]]
PKG_Login_Client_HasAccountNameResult = {
    typeName = "PKG_Login_Client_HasAccountNameResult",
    typeId = 1016,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Login_Client_HasAccountNameResult)
        end
        --[[
        true表示可以
        ]]
        o.okya = false -- Boolean
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- okya
        r, self.okya = d:Rb()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- okya
        d:Wb(self.okya)
    end
}
PKG_Login_Client_HasAccountNameResult.__index = PKG_Login_Client_HasAccountNameResult

local o = ObjMgr
o.Register(PKG_Client_Login_ClientType)
o.Register(PKG_Client_Login_Auth)
o.Register(PKG_Login_Client_button_settings)
o.Register(PKG_Login_Client_GameUpdatePath)
o.Register(PKG_Login_Client_ReRouteNetWork)
o.Register(PKG_Login_Client_GetUpdatePath_Success)
o.Register(PKG_Login_Client_ReceivedPackagetType)
o.Register(PKG_Login_Client_ReceivedPromotionCode)
o.Register(PKG_Login_Client_GameEnforceUpdatePath)
o.Register(PKG_Login_Client_ServerVersionInfo)
o.Register(PKG_Login_Client_Auth_Success_Game)
o.Register(PKG_Login_Client_RegisterAccountInfo)
o.Register(PKG_Login_Client_ReceivedVerificationGoogle)
o.Register(PKG_Login_Client_ReceivedVerificationApple)
o.Register(PKG_Login_Client_ReceivedVerificationFacebook)
o.Register(PKG_Login_Client_Auth_Success_Lobby)
o.Register(PKG_Client_Login_RegisterAccount)
o.Register(PKG_Client_Login_ClientVerificationApple)
o.Register(PKG_Client_Login_ClientVerificationGoogle)
o.Register(PKG_Client_Login_GetServerVersionInfo)
o.Register(PKG_Client_Login_ClientVerificationFacebook)
o.Register(PKG_Client_Login_GetUpdatePath)
o.Register(PKG_Client_Login_ResetPassword)
o.Register(PKG_Client_Login_RequireVerifyCode)
o.Register(PKG_Client_Login_AuthByPhonePassword)
o.Register(PKG_Client_Login_AuthByUsername)
o.Register(PKG_Client_Login_AuthByPhone)
o.Register(PKG_Client_Login_ClientPromotionCode)
o.Register(PKG_Client_Login_ClientPackagetType)
o.Register(PKG_Client_Login_HasAccountName)
o.Register(PKG_Login_Client_HasAccountNameResult)