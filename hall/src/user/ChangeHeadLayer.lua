local ChangeHeadLayer = class("ChangeHeadLayer", function()
    return Tools.CreateLayer("csb/lobby/ChangeHeadLayer.csb")
end)

function ChangeHeadLayer:onEnter()
    self.selected_head_id = UserData.avatar_id or 1

    self:InitUI()
end

function ChangeHeadLayer:InitUI()
    --关闭按钮
	local ui_close_btn = self:findChild('lua_close_btn')
	Tools.AddClickEvent(ui_close_btn, function()
		self:Close()
	end, true)

	local _lang_btn_confirm = self:findChild('_lang_btn_confirm')
	Tools.AddClickEvent(_lang_btn_confirm, function()
		self:OnBtnChangeHead()
	end, true)

	--目前头像
	self.ui_head_icon = self:findChild("lua_head_icon")
	local p1, p2 = Tools.GetHeadPath(UserData.avatar_id)
	self.ui_head_icon:loadTextures(p1, p2)
	--头像列表
	self:InitHeadList()
	--选中当前头像
	local id = UserData.avatar_id
	if id == 0 then id = 1 end
	self:SelectHeadAt(id)
end

function ChangeHeadLayer:InitHeadList()
	self.ui_head_list = {}
	for i = 1,12 do
		local item = self:findChild("lua_head_" .. i)
		local btn = item:findChild("lua_btn")
		local p1, p2 = Tools.GetHeadPath(i)
		btn:loadTextures(p1, p2)
		--点击事件
		local id = i
		Tools.AddClickEvent(btn, function()
			self:OnClickHead(id)
		end, true)
		local tag = item:findChild("lua_tag")
		tag:setVisible(false)
		self.ui_head_list[i] = item
	end
end

function ChangeHeadLayer:OnBtnChangeHead()
	if (self.selected_head_id ~= UserData.avatar_id) then
        self:HandleHeadChange(self.selected_head_id)
	end
end

function ChangeHeadLayer:OnClickHead(id)
    self.selected_head_id = id
    self:SelectHeadAt(id)
end

function ChangeHeadLayer:HandleHeadChange(id)
    go(function()
        local data_ = PKG_Client_Lobby_ChangeAvatar.Create()
        if CheckCanSendPkg(data_) == false then
            print("操作过于频繁")
            return
        end

        data_.avatar_id = id
        UIManager.ShowWaiting()
        local rlt_ = gNet_SendRequest(data_)
        UIManager.HideWaiting()
		if(getmetatable(rlt_) == PKG_Lobby_Client_ChangeAvatar_Success) then
            AddCachedResponse(data_, nil, 3)

			UserData.avatar_id = rlt_.avatar_id
			Dispatcher:Dispatch(UserData)
            UIManager.ShowMsgBox(TR("操作成功"), function()
                self:Close()
            end)
        elseif(getmetatable(rlt_) == PKG_Generic_Error)then
            UIManager.ShowMsgBox(TR("更换头像失败"))
        end
    end)
end

-- id从1开始
function ChangeHeadLayer:SelectHeadAt(id)
	for idx, head_item in ipairs(self.ui_head_list) do
		local tag = head_item:findChild("lua_tag")
		local bg = head_item:findChild("bg")
		if idx == id then
			tag:setVisible(true)
			bg:setVisible(true)
		else
			tag:setVisible(false)
			bg:setVisible(false)
		end
	end

	local p1, p2 = Tools.GetHeadPath(id)
	self.ui_head_icon:loadTextures(p1, p2)
end

return ChangeHeadLayer
