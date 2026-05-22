
local CaptchaLayer = class("CaptchaLayer", function()
    return Tools_Base.CreateLayer("packagelua/res/studio/csb/CaptchaLayer.csb")
end)

function CaptchaLayer:onEnter()
    self.fetching = false

    self:InitUI()
    self:AdjustUI()

	self:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
				cc.DelayTime:create(6),
				cc.CallFunc:create(function()
                    self:onTick()
				end)
			)
		)
	)
    self:onTick()
end

function CaptchaLayer:onTick()
    go(function()
        -- 登录界面才这么干，因为这个时候可能还没加载大厅的协议文件
        if not PKG_Client_Lobby_Ping or not PKG_Lobby_Client_Pong then
            require("packagelua.src.base.pkg_pingpong")
        end

        local data_ = PKG_Client_Lobby_Ping.Create()
        data_.ticks = Int64ToNumber(LuaNowEpoch10m())
        gNet_SendRequest(data_)
    end)
end

function CaptchaLayer:onExit()
end

function CaptchaLayer:SetImageData(image_data)
    local len = image_data:GetLen()
    local r, buf = image_data:Rbuf(len)

    if r == 0 then
        local full_path = cc.FileUtils:getInstance():getWritablePath() .. "/captcha_" .. tostring(os.clock()) .. ".png"
        local f = io.open(full_path, "wb")
        if not f then
            print("创建文件失败:" .. full_path)
            return false
        end

        -- 写入数据
        f:write(buf)
        f:close()

        self:LoadChaptcha(full_path)
    end
end

function CaptchaLayer:FetchCaptchaImage()
    if self.fetching then return end

    go(function()
        local data_ = PKG_Client_Login_RequestCaptcha.Create()
        self.fetching = true
        local rlt_ = gNet_SendRequest(data_)
        self.fetching = false

        if getmetatable(rlt_) == PKG_Login_Client_RequestCaptchaResult then
            local image_data = rlt_.image_data
            self:SetImageData(image_data)
        else
            -- Tools_Base.ShowMsgBox(TR("获取验证码失败"))
            self.image:setVisible(true)
        end
    end)
end

function CaptchaLayer:LoadChaptcha(file_path)
    self.image:setVisible(true)
    cc.Director:getInstance():getTextureCache():removeTextureForKey(file_path)
    self.image:loadTexture(file_path, 0)

    self.btn_refresh:setTouchEnabled(true)
end

function CaptchaLayer:InitUI()
    local _lang_btn_ok = self:findChild("_lang_btn_ok")
    Tools_Base.AddClickEvent(_lang_btn_ok, function()
        self:OnBtnOkClick()
    end, true)

    local btn_refresh = self:findChild("btn_refresh")
    btn_refresh:addTouchEventListener(
        function(btn, type)
            if type == ccui.TouchEventType.ended then
                self:OnBtnRefreshClick()
            end
		end
	)
    self.btn_refresh = btn_refresh

    self.image = self:getChildByName("panel"):getChildByName("img")
    local input = self:getChildByName("panel"):getChildByName("input")
    self.input = self:initInput(input, 1, 6)
end

function CaptchaLayer:OnBtnRefreshClick()
    self.btn_refresh:setTouchEnabled(false)
    self.image:setVisible(false)

    self:FetchCaptchaImage()
end

function CaptchaLayer:initInput(input, min, max)
	local fontSize = 26
	local input_pos = cc.p(input:getPosition())
	local input_ContentSize = input:getContentSize()

	local editTxt = ccui.EditBox:create(input_ContentSize, "")
	input:getParent():addChild(editTxt)
	editTxt:setAnchorPoint(cc.p(0.5,0.5))
	editTxt:setPosition(input_pos)
	editTxt:setPlaceHolder(string.format(TR("请输入图中的数字和字母"), min, max))
	editTxt:setPlaceholderFont("",fontSize)
	editTxt:setFontSize(fontSize)
	editTxt:setMaxLength(max)
	editTxt:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	editTxt:setPlaceholderFontColor(cc.c3b(220,220,220))
    editTxt:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)

    return editTxt
end

--适配
function CaptchaLayer:AdjustUI()
    --背景 铺满
    local bg = self:getChildByName("bg")
    bg:setScale(Tools_Base.ScaleMax)
    local center = cc.p(Tools_Base.visibleSize.width/2.0, Tools_Base.visibleSize.height/2.0)
    bg:setPosition(center)

    --面板尽量放大居中
    local panel = self:getChildByName("panel")
    panel:setScale(Tools_Base.ScaleMin)
    panel:setPosition(center)
end

function CaptchaLayer:OnBtnOkClick()
    local text = self.input:getText()
    if text == "" then
        Tools_Base.ShowMsgBox(TR("请输入验证码"))
        return
    end

    if self.on_callback then
        self.on_callback(text)
        self:removeFromParent()
    end
end

function CaptchaLayer:Show(on_input_done)
    cc.Director:getInstance():getRunningScene():addChild(self, 10000)
    self.on_callback = on_input_done
end

return CaptchaLayer
