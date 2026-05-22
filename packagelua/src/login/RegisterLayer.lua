local this = {}
this.stateGroupName = "RegisterLayer"
this.stateName = "RegisterLayer"
this.opened = false

local CaptchaLayer = require("packagelua.src.login.CaptchaLayer")

function this.Open()
    this.run_layer = cc.Node:create()
    this.accDatas = LoginData.accDatas
	cc.Director:getInstance():getRunningScene():addChild(this.run_layer)
	this.Init()
    this.Adjust()
end

function this.Close()
    this.run_layer:removeFromParent()
    this.accDatas = nil
end

function this.Init()
	this.layer = cc.CSLoader:createNode("packagelua/res/studio/csb/RegisterLayer.csb")
    this.layer:enableNodeEvents()
	TR_Node(this.layer)
	this.run_layer:addChild(this.layer)

	local popup = this.layer:getChildByName("popup")

	local btn_close = popup:getChildByName("btn_close")
    Tools_Base.AddClickEvent(btn_close, function()
		gSound.clickSound()
        this.OnBtnClose()
    end, true)

    local btn = popup:getChildByName("_lang_btn_register")
    Tools_Base.AddClickEvent(btn, function()
        this.OnBtnRegister(btn)
    end, true)

    this.accountInput = this.initInputNode(popup:getChildByName("Node_1"), false, 4, 12)
    this.passwordInput = this.initInputNode(popup:getChildByName("Node_2"), true, 8, 16)
    this.confirmPasswordInput = this.initInputNode(popup:getChildByName("Node_3"), true, 8, 16)

	popup:setScale(0.01)
	popup:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.5,Tools_Base.ScaleMin)))
end

-- @brief 转换为EditBox
-- @param root 根节点
-- @param isPassword 是否为密码输入框
-- @param min 最少位数
-- @param max 最多位数
function this.initInputNode(root, isPassword, min, max)
	local text_input = root:getChildByName("text_input")

	local fontSize = 26
	local input_pos = cc.p(text_input:getPosition())
	local input_ContentSize = text_input:getContentSize()

	local editTxt = ccui.EditBox:create(input_ContentSize,"")
	text_input:getParent():addChild(editTxt)
	editTxt:setAnchorPoint(cc.p(0.5,0.5))
	editTxt:setPosition(input_pos)
	editTxt:setPlaceHolder(string.format(TR("字母和数字%d至%d位"), min, max))
	editTxt:setPlaceholderFont("",fontSize)
	editTxt:setFontSize(fontSize)
	editTxt:setMaxLength(max)
	editTxt:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	editTxt:setPlaceholderFontColor(cc.c3b(220,220,220))
    editTxt:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)

    if isPassword then
        editTxt:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    end

    editTxt.min = min
    editTxt.max = max

    return editTxt
end

function this.Adjust()
	local shadow = this.layer:getChildByName("shadow")
	shadow:setScale(Tools_Base.ScaleMax)

	local popup = this.layer:getChildByName("popup")
    popup:setScale(Tools_Base.ScaleMin)

    local center = cc.p(Tools_Base.visibleSize.width/2.0, Tools_Base.visibleSize.height/2.0)
    this.layer:setPosition(center)
end

function this.OnBtnClose()
	gStates_CloseAsync(this)
end

function this.checkInput(input, tipFmt)
    local ok = Tools_Base.formatString(input:getText(), input.min, input.max)

    if not ok then
        Tools_Base.ShowMsgBox(string.format(tipFmt, input.min, input.max))
    end

    return ok
end

function this.OnBtnRegister(ref)
	if not Tools_Base.PreventContinuousClick(ref,0.4) then
        return
    end

    -- 账号长度检测
    if not this.checkInput(this.accountInput, TR("账户名称长度%d至%d位")) then
        return
    end

    -- 账号空白符检测
    if Tools_Base.HasSpace(this.accountInput:getText()) then
        Tools_Base.ShowMsgBox(TR("账号不能含有空白字符"))
        return
    end

    -- 密码长度检测
    if not this.checkInput(this.passwordInput, TR("账户密码长度%d至%d位")) then
        return
    end

    -- 密码相同校验
    if this.passwordInput:getText() ~= this.confirmPasswordInput:getText() then
        Tools_Base.ShowMsgBox(TR("两次输入的密码不相同"))
        return
    end

    go(function()
		LoginLayer:ConnectNetwork()

        local account = this.accountInput:getText()
        local password = this.passwordInput:getText()
        this.Register(account, password, "")
    end)
end

function this.onCodeInputDone(code)
    go(function()
        local account = this.accountInput:getText()
        local password = this.passwordInput:getText()
        this.Register(account, password, code)
    end)
end

function this.Register(account, password, code)
    local data_ = PKG_Client_Login_RegisterAccount.Create()
    data_.packageName = Device:GetPackageName()
    data_.clientType = Device:GetSystemModel()
    data_.phoneType = Device:GetPhoneType()
    data_.device_id = tostring(Device:GetDeviceID())
    data_.account_name = account
    data_.password = password
    data_.code = code or ""                 -- 验证码

    Tools_Base.ShowWaiting()
    local rlt = gNet_SendRequest(data_)

    Tools_Base.HideWaiting()

    if rlt == nil then
        Tools_Base.ShowMsgBox(TR("网络连接失败，请重试"))
        return
    end

    -- dump(rlt)
    local rlt_meta = getmetatable(rlt)

    if rlt_meta == PKG_Login_Client_RegisterAccountInfo then
        Tools_Base.ShowMsgBox(TR("注册成功"), function()
            LoginData:SetType(LoginData.TYPE.PWD)
            LoginData:SetAccount(account)
            LoginData:SetPassword(password)
            go(function()
                local layer = BottomLayer:Get(LoginLayer)
                layer:ConnectNetwork()
                if not layer:GetServerVersionInfo() then
                    print("get version info faield.")
                end
            end)

            this.OnBtnClose()
        end)
    elseif rlt_meta == PKG_Login_Client_RequestCaptchaResult then
        local image_data = rlt.image_data

        local layer = CaptchaLayer:create()
        layer:Show(function(code)
            this.onCodeInputDone(code)
        end)
        layer:SetImageData(image_data)
    elseif rlt_meta == PKG_Generic_Error then
        -- 错误码：
        -- "account or password is empty", -1
        -- "packageName is empty", -2
        -- "clientType can not empty", -3
        -- "Registration limit reached", -4
        -- "username illegal", -5
        -- "set account and password error", -6

        local num = Int64ToNumber(rlt.number)
        if num == -1 then
            Tools_Base.ShowMsgBox(TR("用户名或密码为空"))
        elseif num == -2 then
            Tools_Base.ShowMsgBox(TR("包名为空"))
        elseif num == -3 then
            print("获取到的手机型号为空")
            Tools_Base.ShowMsgBox(TR("注册失败，请重试"))
        elseif num == -4 then
            Tools_Base.ShowMsgBox(TR("已达到注册限制"))
        elseif num == -5 then
            Tools_Base.ShowMsgBox(TR("用户名非法，请新输入"))
        elseif num == -6 then
            print("设置用户和密码错误")
            Tools_Base.ShowMsgBox(TR("用户名或密码错误"))
        else
            print("未知错误码:", num)
            Tools_Base.ShowMsgBox(TR("网络连接失败，请重试"))
        end
    end
end

-- 登录请求
function this.SendPKG(account,password)
    LoginData:SetType(LoginData.TYPE.PWD)
    LoginData:SetAccount(account)
    LoginData:SetPassword(password)
    go(function()
        local layer = BottomLayer:Get(LoginLayer)
        if layer then
            layer:ConnectNetwork()
            if not layer:GetServerVersionInfo() then
				print("get version info faield.")
			end
        end
    end)
end

return this
