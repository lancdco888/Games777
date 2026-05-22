local SugguestLayer = class("SugguestLayer", function(node)
    node:enableNodeEvents()
    return node
end)

function SugguestLayer:ctor()
    self:Init()
end

function SugguestLayer:Init()
    local lang_ = SettingData.language

    local Button_6 = self:getChildByName("Button_6")
    Tools.AddClickEvent(Button_6, function()
        if self.onServiceClicked then
            self.onServiceClicked()
        end
    end,true)

    local zxkf = Button_6:getChildByName("_lang_zxkf")
    Tools.CcuiTextIgnoreContentAdaptByScaleX(zxkf)
    local Input_name = self:getChildByName("Input_name")
    local Text_3_name = Input_name:getChildByName("Text_3")
    local input_pos = cc.p(Text_3_name:getPositionX(),Text_3_name:getPositionY())
    local input_ContentSize = Text_3_name:getContentSize()

    local nameEdit = ccui.EditBox:create(input_ContentSize, "")
    self.nameEdit = nameEdit
    nameEdit:setPosition(input_pos)
    nameEdit:setPlaceHolder("")
    local PlaceholderFont = 28
    if lang_ == 3 then
        PlaceholderFont = 18
    elseif lang_ == 5 then
        PlaceholderFont = 22
    elseif lang_ == 7 then
        PlaceholderFont = 36
    end

    nameEdit:setPlaceholderFont("Arial", PlaceholderFont)
    nameEdit:setFontSize(36)
    nameEdit:setMaxLength(50)
    nameEdit:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    nameEdit:setPlaceholderFontColor(cc.c3b(220,220,220))
    nameEdit:setAnchorPoint(cc.p(0,0.5))
    nameEdit:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    Input_name:addChild(nameEdit)

    local input_phone = self:getChildByName("input_phone")
    local Text_3_phone = input_phone:getChildByName("Text_3")
    input_pos = cc.p(Text_3_phone:getPositionX(),Text_3_phone:getPositionY())
    input_ContentSize = Text_3_phone:getContentSize()
    local phoneEdit = ccui.EditBox:create(input_ContentSize, "")
    self.phoneEdit = phoneEdit
    phoneEdit:setPosition(input_pos)
    phoneEdit:setPlaceHolder("")
    phoneEdit:setPlaceholderFont("Arial",PlaceholderFont)
    phoneEdit:setFontSize(36)
    phoneEdit:setMaxLength(50)
    phoneEdit:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    phoneEdit:setPlaceholderFontColor(cc.c3b(220,220,220))
    phoneEdit:setAnchorPoint(cc.p(0,0.5))
    phoneEdit:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    input_phone:addChild(phoneEdit)

    local Image_sug = self:getChildByName("Image_sug")
    local Text_2 = Image_sug:getChildByName("Text_2")
    input_pos = cc.p(Text_2:getPositionX(), Text_2:getPositionY())
    input_ContentSize = Text_2:getContentSize()
    local sugEdit = ccui.EditBox:create(input_ContentSize, "")
    self.sugEdit = sugEdit
    sugEdit:setPosition(input_pos)
    sugEdit:setPlaceHolder(TR("请输入您宝贵的建议(200字以内)"))
    sugEdit:setPlaceholderFont("Arial",PlaceholderFont)
    sugEdit:setFontSize(36)
    sugEdit:setMaxLength(200)
    sugEdit:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    sugEdit:setPlaceholderFontColor(cc.c3b(220,220,220))
    sugEdit:setAnchorPoint(cc.p(0,1))
    sugEdit:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    Image_sug:addChild(sugEdit)

    local Button_15 = self:getChildByName("_lang_commit")
    Tools.AddClickEvent(Button_15, function()
        self:SendSuggest()
    end, true)

    -- 上传图片
    local Button_upload = self:getChildByName("_lang_Button_upload")
    self.Button_upload = Button_upload
    Button_upload:addTouchEventListener(function(ref, type)
        if(type == ccui.TouchEventType.ended) then
            if Tools_Base.PreventContinuousClick(Button_upload,0.5) then
                ref:runAction(cc.Sequence:create(cc.CallFunc:create(function() gSound.clickSound(); end),
                cc.DelayTime:create(0.2),
                cc.CallFunc:create(function()
                    -- Device:OpenAlbum()
                    Tools.UploadSelectPhoto(function(success, url, base64data)
                        if not success then
                            print("upload select image failed.")
                            return
                        end
                        if tolua.isnull(self) then return end
                        self:onUploadDone(url, base64data)
                    end)
                end)))
            end
        end
    end)

    -- 上传图片列表
    local ListView_image = self:getChildByName("ListView_image")
    self.ListView_image = ListView_image
    ListView_image:setScrollBarEnabled(false)
    self.Panel_item = ListView_image:getChildByName("Panel_item")
    self.Panel_item:retain()
    ListView_image:removeAllItems()
end

function SugguestLayer:onUploadDone(url, base64data)
	UIManager.ShowWaiting()
	local item = self.Panel_item:clone()
	item:addTouchEventListener(function(ref,type)
		if(type == ccui.TouchEventType.ended) then
            local layer = PopLayer:Pop(service.ImageViewLayer)
            layer:setBase64Image(base64data)
		end
	end)

	local par_size = item:getContentSize()
	local sp = createSpriteFromBase64(base64data)
	sp:setAnchorPoint(cc.p(0.5,0.5))
	sp:setPosition(cc.p(par_size.width/2, par_size.height/2))
	local sp_size = sp:getContentSize()
	local wScale = par_size.width/sp_size.width
	local hScale = par_size.height/sp_size.height
	if wScale*sp_size.width*sp_size.height<=par_size.width*sp_size.height then
		sp:setScale(wScale)
	else
		sp:setScale(hScale)
	end

	item:addChild(sp)
	local Image_remove = item:getChildByName("Image_remove")
	Image_remove:addTouchEventListener(function(ref, type)
		if(type == ccui.TouchEventType.ended) then
			gSound.clickSound()
			self.ListView_image:removeChild(item)
			if self.ListView_image.urls then
				local index = nil
				for k, info in pairs(self.ListView_image.urls) do
					if info.item == item then
						index = k
						break
					end 
				end
				table.remove( self.ListView_image.urls, index )
			end
		end
	end)
	Image_remove:removeFromParent()
	item:addChild(Image_remove)
	self.ListView_image:pushBackCustomItem(item)
	self.ListView_image.urls = self.ListView_image.urls or {}
	table.insert(self.ListView_image.urls,{url = url, item = item})
	UIManager.HideWaiting()
end

function SugguestLayer:onServiceClickedEvent(onServiceClicked)
    self.onServiceClicked = onServiceClicked
end

function SugguestLayer:SendSuggest()
    local name_ = self.nameEdit:getText()
    local phone_ = self.phoneEdit:getText()
    local sug_ = self.sugEdit:getText()
    local urls_ = ""

    if self.ListView_image.urls then
        for i = 1, #self.ListView_image.urls do
            local info = self.ListView_image.urls[i]
            urls_ = urls_..info.url..";"
        end
        if #urls_>0 then
            urls_ = string.sub(urls_, 1,(urls_:len()-1))
        end
    end

    if ( urls_ == "" and sug_ == "" ) or name_ == "" or phone_ == "" then
        UIManager.ShowToast(TR("请完善建议内容"))
        return
    end

    go(
        function()
            local data_ = PKG_Client_Lobby_NewComplaint.Create()
            data_.content = sug_
            data_.images = urls_
            data_.realname = name_
            data_.phone = phone_
            UIManager.ShowWaiting()
            local rlt_ = gNet_SendRequest(data_)
            UIManager.HideWaiting()

            if not rlt_ then
                print("PKG_Client_Lobby_NewComplaint  nil")
                return
            end

            if getmetatable(rlt_) == PKG_Generic_Success then
                UIManager.ShowToast(TR("您的建议已经发送"))
            else
                UIManager.ShowMsgBox("PKG_Client_Lobby_NewComplaint error " .. rlt_.masssage)
                print("PKG_Client_Lobby_NewComplaint error ", rlt_.masssage)
            end

            if not tolua.isnull(self) then
                self:Clear()
            end
        end
    )
end

-- 重置界面
function SugguestLayer:Clear()
    self.nameEdit:setText("")
    self.phoneEdit:setText("")
    self.sugEdit:setText("")
    self.ListView_image:removeAllItems()
    self.ListView_image.urls = {}
end

return SugguestLayer
