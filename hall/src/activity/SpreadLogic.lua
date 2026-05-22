local SpreadLogic = class("SpreadLogic")

function SpreadLogic:ctor()
    self.website = ""                   -- 官网 url
    self.qr_url = ""                    -- 二维码 url
    self.qr_image = cc.FileUtils:getInstance():getWritablePath()
        .. "/download/qr_img.png"
    self.got_info = false               -- 是否获得以上信息
end

-- 是否已经保存过推广 图片
function SpreadLogic:IsSavePhoto()
    return cc.UserDefault:getInstance():getBoolForKey(
        "save_spread_image",
        false
    )
end

-- 设置是否保存过 图片
function SpreadLogic:SetSavePhoto(bSaved)
    local saved = false
    if bSaved then
        saved = true
    else
        saved = false
    end
    cc.UserDefault:getInstance():setBoolForKey(
        "save_spread_image",
        saved
    )
end

---------------------------------------------------------------
--  推广图片 处理
function SpreadLogic:HasSpreadInfo()
    return self.got_info
end

function SpreadLogic:GetSpreadInfo()
    return {
        website = self.website,
        qr_url = self.qr_url,
        qr_image = self.qr_image
    }
end

-- 获取推广图片 地址等
-- coroutine !!
function SpreadLogic:FetchSpreadInfo()
    if self:HasSpreadInfo() then
        return true
    end

    -- 获取 url 信息
    local data_ = PKG_Client_Lobby_GetWebsite.Create()
    local rlt_ = gNet_SendRequest(data_)
    
    dump(rlt_, " *************** rlt_ ***************** ")
    self.website = rlt_.website
    self.qr_url = rlt_.website_qrcode
    if self.website == "" or self.qr_url == "" then
        print("photo: invalid pkg info")
        return false
    end

    -- 根据 url 获取二维码图片
    local result = self:DownloadImage(self.qr_url, self.qr_image)
    if not result then
        print("photo: download qr image failed")
        return false
    end

    self.got_info = true
    return true
end

function SpreadLogic:DownloadImage(url, path_)
    local done = false
    local result = false

    local utils = require("hall.src.hallnew.logics.utils")
    utils.req_http_data(
        url,
        function(data)
            if not utils.write_file(path_, data) then
                done = true
                result = false
            else
                done = true
                result = true
            end
        end,
        function()
            done = true
            result = false
        end
    )

    while not done do
        coroutine.yield()
    end
    return result
end

function SpreadLogic:SupportSaveToPhoto()
    return Device:Has_SaveImageToGallery()
end

function SpreadLogic:SaveToPhoto(image_path)
    local support = self:SupportSaveToPhoto()
    if not support then
        print("photo: no support SaveImageToGallery")
        return false
    end

    if self:IsSavePhoto() then
        print("photo: already saved")
        return true
    end

    local success = Device:SaveImageToGallery(image_path, TR("收藏"), TR("收藏个人信息"))
    if not success then
        print("photo: save to photo failed")
        return false
    end

    self:SetSavePhoto(true)
    return true
end

return SpreadLogic
