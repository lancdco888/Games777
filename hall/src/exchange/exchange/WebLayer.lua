local WebLayer = class("WebLayer", function()
	return Tools.CreateLayer("csb/WebLayer.csb")
end)

function WebLayer:ctor()
    self.webview = nil

    self:InitUI()
end

function WebLayer:InitUI()
    self.content_box = self:findChild("content_box")

    local btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:Close()
    end, true)
end

function WebLayer:setUrl(url)
    print("WebLayer: setUrl" .. tostring(url))

    -- 获取url 参数 用本地url 调用
    local arg =  string.split(url,"#/")
    if #arg ~= 2 then
        return nil
    end

    if not url or not url:find("http") then
        self:Close()
        return
    end

    if self.webview then
        self.webview:removeFromParent()
        self.webview = nil
    end

    local webview = ccexp.WebView:create()
    self:addChild(webview)
    webview:setVisible(false)
    webview:setScalesPageToFit(true)
    webview:setAnchorPoint(cc.p(0.5, 0))

    local size = self.content_box:getContentSize()
    local pos = cc.p(self.content_box:getPosition())
    webview:setPosition(pos)
    webview:setContentSize(size) 
    webview:setJavascriptInterfaceScheme("js")
    webview:setOnJSCallback(function(sender, url)
        self:onJsCallBack(sender, url)
    end)

    -- url = "file:///" .. path .. '#/home/hw1739873117ulgzyno?time=1739873117&can_modify_bank=1&can_modify_tel=1&bank_card_id=&bank_card_tel=&bank_card_name=&region=ind&exchangerate=10000'
    local tail = '&can_modify_bank=1&can_modify_tel=1&bank_card_id=&bank_card_tel=&bank_card_name=&region=ind&exchangerate=1'
    local path = cc.FileUtils:getInstance():fullPathForFilename("hall/res/www/dist/index.html")
    url = "file:///" .. path .. "#/" .. arg[2] .. tail

    print("WebLayer : loadURL," .. url)
    webview:loadURL(url, true)
    go(function()
        SleepSecs(0.3)
        webview:setVisible(true)
    end)

    self.webview = webview
end

function WebLayer:onJsCallBack(sender, url)
    print("WebLayer : onJsCallBack," .. url)

    -- 去掉多余的 js:
    local base64_str_ = ""
    if string.find(url, "js://") then
        base64_str_ = string.sub(url, 6, string.len(url))
    else
        base64_str_ = url
    end

    require("src.hall.src.common.ZZBase64")
    local json_str_ =  ZZBase64.decode(base64_str_)
    local json = require("json")
    local data_ = json.decode(json_str_)

    if data_.type == "openUrl" then
        if data_.url then
            cc.Application:getInstance():openURL(data_.url)
            self:Close()
        else
            print("WebLayer: invalid data_.url!")
        end
    end
end

return WebLayer
