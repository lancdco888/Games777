local LangCombo = import(".LangCombo")
local utils = require("bootstrap.src.utils")

local LoginLayer = class("LoginLayer", function()
    return Tools_Base.CreateLayer("packagelua/res/studio/csb/LoginLayer.csb")
end)

--检查是否是首次获得账号
local function CheckIsFristLogin()
    local data_ = cc.UserDefault:getInstance():getStringForKey("Account")
    if not data_ or data_ == "" then
        return true
    end
    return false
end

function LoginLayer:onEnter()
    -- 需要兼容老包
    package.loaded["packagelua.src.downloader.hotfixJson"] = nil
    package.loaded["packagelua.src.downloader.DownloadManager"] = nil
    package.loaded["packagelua.src.downloader.downloader_def"] = nil
    package.loaded["packagelua.src.downloader.init"] = nil
    package.loaded["packagelua.src.downloader.DownloadTask"] = nil
    require "packagelua.src.downloader.init"
    sDownloadMgr.Init()
    hotfixJson = require("packagelua.src.downloader.hotfixJson").new()
    self:CheckNewI18n()

    -- Device 模块需要重新加载
    package.loaded["packagelua.src.base.Device"] = nil
    Device = require("packagelua.src.base.Device")
    -- Tools_Base
    package.loaded["packagelua.src.base.Tools_Base"] = nil
    Tools_Base      = require("packagelua.src.base.Tools_Base")
    require("packagelua.src.BuildConfig")

    Sdk = require("packagelua.src.sdk.Sdk").new()
    Sdk:firstOpen()

    Device:setScreenType(Device.H_Screen_Type)

    self.accDatas = LoginData.accDatas
    self.autoLogining = false                   -- 是否正处于自动登录中

    self:InitUI()
    self:AdjustUI()

    if CheckIsFristLogin() then
        LoginData:SetAutoLogin(true)
        LoginData:SetType(LoginData.TYPE.GUEST)
        LoginData:SaveAccDatas()
    end

    if NEED_PASSWD_LOGIN then
        NEED_PASSWD_LOGIN = nil
        self:ShowAutoLoginUI(false)
        self:OnBtnPassword()
    -- 去掉自动登录
    -- elseif self:CanAutoLogin() then
    --     self:ShowAutoLoginUI(true)
    --     self:CheckAutoLogin()
    end
end

--------------------------------------------------------------------------

function LoginLayer:ShowAutoLoginUI(bShow)
    self.autoLogining = bShow

    self.btn_guest:setVisible(not bShow)
    self.btn_facebook:setVisible(not bShow)
    self.btn_password:setVisible(not bShow)
    self.btn_return:setVisible(not bShow)
    if self.btn_service then
        self.btn_service:setVisible(not bShow)
    end
    if self.lang_combo then
        self.lang_combo.root:setVisible(not bShow)
    end
    if self.screen_combo then
        self.screen_combo.root:setVisible(not bShow)
    end
    if self.version_label then
        self.version_label:setVisible(not bShow)
    end

    if not bShow then
        self:InitUI()
        self:ShowLoadingNode(false)
    end
end

--------------------------------------------------------------------------

function LoginLayer:CheckNewI18n()
    -- 需要兼容老包
    package.loaded["packagelua.src.bootstrap.init"] = nil
    require("packagelua.src.bootstrap.init")
    ResetTranslator()
end

function LoginLayer:CanAutoLogin()
    -- local bAutoLogin = LoginData:IsAutoLogin()
    local bAutoLogin = false
    if not bAutoLogin then
        return false
    end

    local login_type = LoginData:GetType()
    if login_type == LoginData.TYPE.GUEST then
        return true
    elseif login_type == LoginData.TYPE.PWD then
        -- 没有保存密码就不自动登录
        if not LoginData:GetIsSavePwd() then
            return false
        end
        local account = LoginData.accDatas.acc_name
        local password = LoginData.accDatas.pwd_name
        if account == "" or not account or password == "" or not password then
            return false
        end
        return true
    elseif login_type == LoginData.TYPE.FACKBOOK then
        local fbid = LoginData.accDatas.fbid
        if not fbid or fbid == "" then
            return false
        end
        return true
    end
    return true
end

function LoginLayer:CheckAutoLogin()
    go(function()
        local login_type = LoginData:GetType()
        if login_type == LoginData.TYPE.GUEST then
            LoginData:SetAccount(self.accDatas.username)
            LoginData:SetPassword(nil)
        elseif login_type == LoginData.TYPE.PWD then
            -- 没有保存密码就不自动登录
            if not LoginData:GetIsSavePwd() then
                return
            end
            -- 没有账号 或 密码
            local account = LoginData.accDatas.acc_name
            local password = LoginData.accDatas.pwd_name
            if account == "" or not account or password == "" or not password then
                return
            end
            LoginData:SetAccount(account)
            LoginData:SetPassword(password)
        elseif login_type == LoginData.TYPE.FACKBOOK then
            local fbid = LoginData.accDatas.fbid
            if not fbid or fbid == "" then
                return
            end
            LoginData:SetAccount(fbid)
        end

        Tools_Base.ShowWaiting()
        self:ConnectNetwork()
        Tools_Base.HideWaiting()

        if not self:GetServerVersionInfo() then
            if tolua.isnull(self) then return end
            self:ShowAutoLoginUI(false)
        end
    end)
end

function LoginLayer:InitUI()
    local panel = self:getChildByName("panel")
    local btn_facebook = panel:getChildByName("btn_facebook")
    Tools_Base.AddClickEvent(btn_facebook, function()
        if Tools_Base.PreventContinuousClick(self, 2.0) then
            self:OnBtnFaceBook()
        end
    end, true)
    self.btn_facebook = btn_facebook

    local btn_guest = panel:getChildByName("btn_guest")
    Tools_Base.AddClickEvent(btn_guest, function()
        if Tools_Base.PreventContinuousClick(self, 2.0) then
            self:OnBtnGuest()
        end
    end, true)
    self.btn_guest = btn_guest

    local btn_password = panel:getChildByName("btn_password")
    Tools_Base.AddClickEvent(btn_password, function()
        if Tools_Base.PreventContinuousClick(self,0.4) then
            self:OnBtnPassword()
        end
    end, true)
    self.btn_password = btn_password

    local res_path = "login/denglu_mimadenglu.png"
    local res_path2 = "login/denglu_mimadenglu_2.png"
    if LoginData:GetPassword() and #LoginData:GetPassword() > 0 then
        if LoginData:GetIsSavePwd() then
            btn_password:loadTextures(res_path,res_path)
        else
            btn_password:loadTextures(res_path2,res_path2)
        end
    else
        btn_password:loadTextures(res_path2,res_path2)
    end

    self.btn_service = panel:getChildByName("btn_service")
    Tools_Base.AddClickEvent(self.btn_service, function()
        if Tools_Base.PreventContinuousClick(self,0.4) then
            self:OnBtnService()
        end
    end, true)
    self:showService()

    local btn_return = panel:getChildByName("btn_return")
    Tools_Base.AddClickEvent(btn_return, function()
        Tools_Base.ShowMsgBox(TR("亲，确定不再玩一会儿游戏了吗？"), function()
            cc.Director:getInstance():endToLua()
        end,function () end)
    end, true)
    self.btn_return = btn_return

    self:InitLangCombo()
    local platform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_IPHONE == platform or cc.PLATFORM_OS_IPAD == platform then
        self:HideFacebookButton()
    end

    if not BuildConfig.IsShowLoginFaceBookButton() then
        self:HideFacebookButton()
    end

    self:InitVersionInfo()

    self:ShowLoadingNode(false)
end

------------------------------------------------------------------------------------------
-- 登录界面 Loading 处理
function LoginLayer:ShowLoadingNode(bShow)
    AddBootStrapSearchPath()

    local loading_layer = self.loading_layer
    if not loading_layer then
        local LoadingLayer = require("bootstrap.src.LoadingLayer")
        loading_layer = LoadingLayer.new()
        self.loading_layer = loading_layer
        self:addChild(loading_layer)
        TR_Node(loading_layer)
        loading_layer:setRate(0.0)
    end
    loading_layer:showLoading(true)
    loading_layer:setVisible(bShow)
    if not bShow then
        loading_layer.loadingBar:stopAllActions()
        loading_layer.loadingBar:setPercent(0)
    end
end

function LoginLayer:SetLoadingPercent(percent)
    if self.loading_layer then
        self.loading_layer:setRate(percent / 100.0)
    end
end

function LoginLayer:SetLoadingTips(tips)
    if self.loading_layer then
        self.loading_layer:setTips(tips)
    end
end

function LoginLayer:DestroyLoading()
    if self.loading_layer then
        RemoveBootStrapSearchPath()
        self.loading_layer:removeFromParent()
        self.loading_layer = nil
    end
end

------------------------------------------------------------------------------------------

function LoginLayer:InitVersionInfo()
    local label = self:findChild("info")
    if label then
        local info = hotfixJson:GetLocalInfosByModule("packagelua")
        local showtext = ""
        if info and info.version then
            showtext = "v" .. info.version
        end

        label:setString(showtext)
        self.version_label = label
    end
end


function LoginLayer:HideFacebookButton()
    self.btn_password:setPositionX(self.btn_guest:getPositionX())
    self.btn_facebook:setVisible(false)
end

function LoginLayer:InitLangCombo()
    local node = self:findChild("LangCombo")
    assert(node)

    if #ConfigParam.Language > 1 then
        node:setVisible(true)
        self.lang_combo = LangCombo:new()
        self.lang_combo:InitNode(node)

        self.lang_combo.OnLangChanged = function(name)
            PackageluaAddSearchPath()
        end
    else
        node:setVisible(false)
    end
end

-- 是否需要开启客服按钮
function LoginLayer:showService()
    local ok = pcall(
        function()
            ResetTranslator()
            require "hall.src.pkgs.client_lobby"
            return require("hall.src.hallnew.layers.lobby.ChatLayer")
        end
    )
    if not ok then
        self.btn_service:setVisible(false)
    else
        self.btn_service:setVisible(true)
        self.btn_service:loadTextures(const_def.ServiceList[ConfigParam.Region],const_def.ServiceList[ConfigParam.Region],const_def.ServiceList[ConfigParam.Region])
    end
end

function LoginLayer:AdjustUI()
    --背景 铺满
    local bg = self:getChildByName("bg")
    Tools_Base.AdjustBg(bg)

    local center = cc.p(Tools_Base.visibleSize.width/2.0, Tools_Base.visibleSize.height/2.0)
    bg:setPosition(center)
    --面板尽量放大居中
    local panel = self:getChildByName("panel")
    Tools_Base.AdjustCenter(panel)
    panel:setPosition(center)
end

function LoginLayer:OnBtnFaceBook()
    go(
        function()
            local fbid =  FacebookSingle:getCurrentFbid()
            if not fbid then
                -- 调用sdk拿到token去校验
                local token = FacebookSingle:getFBToken()
                print(token,"------>>>>>>>token")
                self:ConnectNetwork()
                Tools_Base.ShowWaiting()
                fbid = FacebookSingle:getFBIDByToken(token)
                Tools_Base.HideWaiting()
                if not fbid then
                    return
                end
                print(fbid,"------>>>>>>>fbid")
                FacebookSingle:setCurrentFbid(fbid)
            else
                print("本地有facebook")
            end
            LoginData:SetType(LoginData.TYPE.FACKBOOK)
            LoginData:SetAccount(fbid)
            LoginData:SetPassword(nil)

            self:ShowAutoLoginUI(true)
            if not gNet:Alive() then
                self:ConnectNetwork()
            end

            if not self:GetServerVersionInfo() then
                if not tolua.isnull(self) then
                    self:ShowAutoLoginUI(false)
                end
            end
        end
    )
end

function LoginLayer:OnBtnGuest()
    LoginData:SetType(LoginData.TYPE.GUEST)
    LoginData:SetAccount(self.accDatas.username)
    LoginData:SetPassword(nil)

    self:ShowAutoLoginUI(true)
    go(
        function()
            self:ConnectNetwork()
            if tolua.isnull(self) then return end

            if not self:GetServerVersionInfo() then
                if not tolua.isnull(self) then
                    self:ShowAutoLoginUI(false)
                end
            end
        end
    )
end

function LoginLayer:OnBtnPassword()
    print("密码登入")
    local passwordLoginLayer = require("packagelua.src.login.PasswordLoginLayer")
    gStates_SetAsync(passwordLoginLayer)
end

function LoginLayer:OnBtnService()
    print("在线客服")
    local accountid = LoginData.accDatas['account_id'] or 0
    local username = LoginData.accDatas['username'] or ""
    if username == "" or accountid == "" then
        print("当前还未注册,去拿虚拟账号")
        accountid = LoginData.accDatas['vtrtual_id'] or 0
        username = LoginData.accDatas['vtrtual_name'] or ""
    end
    self:registAccForChat(accountid,username)
end

-- 先放这里连一下网 协程调用
function LoginLayer:ConnectNetwork()
    local Network = require("packagelua.src.base.Network")
    local ip = SettingData:GetNetworkIP()
    local port = SettingData:GetNetworkPort()

    if Network:SetHost(ip, port) == false then return false end
    print("IP:",ip)
    print("PORT:",port)

    Tools_Base.ShowWaiting()
    local ret = Network:ConnectServer()
    Tools_Base.HideWaiting()
    if not ret then
        print("-------->>>>> 网络连接失败")
        return false
    end

    print("-------->>>>> 网络成功")
    return true
end

import(".DownloadingHall")
function LoginLayer:GetVersionDone()
    if not DownloadingHall(self.loading_layer) then
        Tools_Base.ShowMsgBox(TR("版本更新失败"))

        if tolua.isnull(self) then return end
        self:ShowAutoLoginUI(false)
        return
    end
    if tolua.isnull(self) then return end
    SleepSecs(0.1)

    go(function()
        if tolua.isnull(self) then return end

        self:ShowLoadingNode(false)
        self:ShowLoadingNode(true)
        self:SetLoadingPercent(0)
        self:SetLoadingTips(TR("正在进入大厅..."))

        for path_,__ in pairs(package.loaded) do
            if string.find(path_, "hall") or string.find(path_, "exchange") then
                package.loaded[path_] = nil
            end
        end
        cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()

        if tolua.isnull(self) then return end
        self:SetLoadingPercent(50)
        SleepSecs(0.2)

        local hallChunkFile = cc.FileUtils:getInstance():fullPathForFilename("src/hall/src.chunk.zip")
        if LoadChunksFromZIP and hallChunkFile ~= "" then
            LoadChunksFromZIP(hallChunkFile)
            print("Loading Chunk:" .. hallChunkFile)
        end

        UserData = require("hall.src.hallnew.data.UserData")
        GameData = require("hall.src.hallnew.data.GameData")
        Tools = require("hall.src.hallnew.Tools")
        require "hall.src.common.Def"
        require "hall.src.common.const_game"
        require "hall.src.common.GameInfoManager"
        sGameManager.Init()
        require("hall.src.main")

        if tolua.isnull(self) then return end
        self:SetLoadingPercent(100)
        SleepSecs(0.2)
    end)
end

local function CheckValidJson(json_str)
    local decode = json.old_decode or json.decode
    local status, __ = pcall(decode, json_str)
    return status
end

-- 获取热更新配置
function LoginLayer:GetServerVersionInfo()
    local data_ = PKG_Client_Login_GetServerVersionInfo.Create()
    data_.packageName = Device:GetPackageName()
    print("package:", data_.packageName)
    -- 用户类型 0=游客 1=facebook 2=用户名密码
    data_.type = LoginData:GetType()
    local tpye = data_.type
    data_.type = data_.type == 3 and 2 or data_.type -- 3类型就是账号密码注册登录
    -- 游客传username,facebook传facebookid,用户名密码传用户名
    data_.account = LoginData:GetAccount() or ""
    -- 用户名密码登录的密码
    data_.password = LoginData:GetPassword() or ""
    if tpye == 3 then
        data_.account = ""
        data_.password = ""
    end

    if tolua.isnull(self) then return end
    self:ShowLoadingNode(true)
    self:SetLoadingTips(TR("正在检查版本信息..."))
    self:SetLoadingPercent(0)
    local rlt_ = gNet_SendRequest(data_)

    if tolua.isnull(self) then return end
    self:SetLoadingPercent(100)
    SleepSecs(0.4)
    self:ShowLoadingNode(false)

    if not rlt_ then
        Tools_Base.ShowMsgBox(TR("网络连接失败，请重试"))
        return false
    end

    if getmetatable(rlt_) == PKG_Login_Client_ServerVersionInfo then
        if rlt_.info == "account_or_password_error" then
            Tools_Base.ShowMsgBox(TR("用户名或密码错误"))
            return false
        end

        local hotfixInfo = rlt_.info
        if CheckValidJson(hotfixInfo) then
            hotfixJson:LoadServerJson(hotfixInfo)
        else
            Tools_Base.ShowMsgBox(TR("网络连接失败，请重试"))
            return false
        end

        self:GetVersionDone()
        return true
    elseif getmetatable(rlt_) == PKG_Generic_Error then
        local num = Int64ToNumber(rlt_.number)
        if (num == -6)then
            Tools_Base.ShowMsgBox(TR("服务器未响应"))
            return false
        elseif (num == -113)then
            Tools_Base.ShowMsgBox(TR("用户名或密码错误"))
            return false
        else
            print("PKG_Client_Login_GetServerVersionInfo PKG_Generic_Error \nmessage:"..rlt_.message.."\nnumber:"..num)
            Tools_Base.ShowMsgBox(TR("用户名或密码错误"))
            return false
        end
        return true
    else
        print("PKG_Client_Login_GetServerVersionInfo 发送失败")
        Tools_Base.ShowMsgBox(TR("网络连接失败，请重试"))
        return false
    end

    return true
end

-- 客服聊天 先注册个聊天账号
function LoginLayer:registAccForChat(accountid,username)
    go(
        function()
            self:ConnectNetwork()
            local data_ = PKG_Client_Lobby_RegisterTempMsgService.Create()
            data_.accountid = accountid
            data_.username = username
            dump(data_,"data_")
            Tools_Base.ShowWaiting()
            local rlt_ = gNet_SendRequest(data_)
            Tools_Base.HideWaiting()
            if (rlt_ ~= nil) then
                if(getmetatable(rlt_) == PKG_Lobby_Client_RegisterTempMsgServiceResult) then
                    -- todo 保存虚拟账号放
                    LoginData:ModifyAccDatas('vtrtual_name',rlt_.username)
                    LoginData:ModifyAccDatas('vtrtual_id',rlt_.accountid)
                    LoginData:SaveAccDatas()
                    dump(rlt_,"虚拟账号来咯")
                    require "hall.src.common.ServiceModel"
                    --注册应用内客服主动推送的消息
                    gNetHandlers_Register(PKG_Lobby_Client_Message, "OnReceiveCustomerServiceMsg",
                                    function (rlt_)
                                        Dispatcher:Dispatch("OnReceiveCustomerServiceMsg",rlt_,nil,true)
                                    end)
                    local panel_service = require "hall.src.hallnew.layers.lobby.Panel_service"
                    panel_service.uploadimageUrl = rlt_.url
                    panel_service.setVirAcc(rlt_.accountid,rlt_.username)
                    gStates_SetAsync(panel_service)
                elseif(getmetatable(rlt_) == PKG_Generic_Error)then
                    Tools_Base.ShowMsgBox(TR("网络连接失败，请重试"))
                    dump(rlt_,"为何会给我发 PKG_Generic_Error")
                end
            else
                Tools_Base.ShowMsgBox(TR("网络连接失败，请重试"))
                print("发包失败???")
            end
        end
    )
end

return LoginLayer
