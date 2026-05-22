local SpreadLayer = class("SpreadLayer", function()
    return Tools.CreateLayer("csb/lobby/SpreadLayer.csb")
end)

function SpreadLayer:onEnter()
	self:InitUI()

    self:Load()
end

function SpreadLayer:SetCloseFunc(isClose,closefunc)
    local btn_close = self:findChild("btn_close")
    btn_close:setVisible(closefunc == nil)

    if closefunc then
        local func = self.Close
        self.Close = function ()
            if func then
                func()
            end 
            closefunc()
        end
    end
end

function SpreadLayer:InitUI()
    local frame = self:findChild("frame")
    self.frame = frame

    self.img_node = self:findChild("img")
    self.website_node = self:findChild("website")
    self.account_node = self:findChild("account")

    local _lang_btn_confirm = self:findChild("_lang_btn_confirm")
    if _lang_btn_confirm then
        Tools.AddClickEvent(_lang_btn_confirm, function()
            self:OnConfirm()
        end, true)
    end

    local btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:Close()
    end, true)
end

function SpreadLayer:OnConfirm()
    print("on confirm")

    local permission = Device:HasStoragePermission()
    if not permission then
        Device:RequestStoragePermission(function(rlt)
            if rlt == "success" then
                self:OnConfirm()
            else
                self:Close()
            end
        end)
        return
    end

    self:Capture()

    go(function()
        SleepSecs(0.3)
        self:Close()
    end)
end

function SpreadLayer:Capture()
    if not cc.utils.captureNode then
        print("no captureNode function")
        UIManager.ShowToast(TR("截图失败"))
        return
    end

    local scale = 1.0
    local root = self:findChild("root")
    local image = cc.utils:captureNode(root, scale)
    if not image then
        print("no image")
        UIManager.ShowToast(TR("截图失败"))
        return
    end

    local file_path_ = cc.FileUtils:getInstance():getWritablePath() .. "/my_capture_image.png"
    if not image:saveToFile(file_path_) then
        print("save failed")
        UIManager.ShowToast(TR("保存截图文件失败"))
        return
    end
    
    if not activity.SpreadLogic:SaveToPhoto(file_path_) then
        print("SaveToPhoto failed")
        UIManager.ShowToast(TR("收藏失败"))
        return
    end

    UIManager.ShowToast(TR("收藏成功"))
end

function SpreadLayer:Load()
    go(function()
        if not activity.SpreadLogic:HasSpreadInfo() then
            local success = activity.SpreadLogic:FetchSpreadInfo()
            if not success then
                return
            end
        end

        local spread_info = activity.SpreadLogic:GetSpreadInfo()
        local website = spread_info.website
        local qr_url = spread_info.qr_url
        local qr_image = spread_info.qr_image

        -- 加载图片
        if not self:LoadImage(qr_image) then
            print("load img failed:" .. tostring(qr_image))
            return
        end
        
        self:UpdateSignature(website)
    end)
end

function SpreadLayer:IsSpreadDownload()
    local fu = cc.FileUtils:getInstance()
    return fu:isFileExist(path) 
end

function SpreadLayer:GetSpreadImagePath()
    local fu = cc.FileUtils:getInstance()
    return fu:getWritablePath() .. "/spread.jpeg"
end

function SpreadLayer:LoadImage(img_path)
    local fu = cc.FileUtils:getInstance()
    if not fu:isFileExist(img_path) then
        print("LoadImage Failed:" .. img_path)
        return false
    end
    
    if not self.img_node then
        print("LoadImage Failed: no image node")
        return false
    end

    local img = self.img_node
    cc.Director:getInstance():getTextureCache():reloadTexture(img_path)
    img:loadTexture(img_path)
    local size = img:getVirtualRendererSize()
    local p_size = self.frame:getContentSize()
    p_size.width = p_size.width - 4
    p_size.height = p_size.height - 4
    img:setContentSize(p_size)
    return true
end

function  SpreadLayer:UpdateSignature(website)
    self.website_node:setString(website)
    if UserData.account_name == "" then
        self.account_node:setString("")
    else
        local str_ = string.format(TR("我的ID: %s"), UserData.account_name)
        self.account_node:setString(str_)
    end
end

return SpreadLayer
