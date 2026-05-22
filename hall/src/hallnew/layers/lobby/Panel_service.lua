local this = {}
this.stateGroupName = "Panel_service"
this.stateName = "Panel_service"
this.opened = false

-------------------
this.accountid = 0
this.username = ""
-------------------

-- 聊天类型
this.MESSAGE_TYPE = {
	SERVICE_TEXT = 0,-- 客服文本
	SERVICE_PICTURE = 1,-- 客服图片
	PLAYER_TEXT = 2,-- 玩家文本
	PLAYER_PICTURE = 3,-- 玩家图片
}
--入口类型 ： 默认为0：正常进入 ， 1登录界面进入
this.ENTER_PANEL = 0

function this.Open(...)
    assert(not this.opened)
	this.HallWritablePath = cc.FileUtils:getInstance():getWritablePath() .. "download/"
    this.Init()
    this.opened = true
    print("打开panel_service")
end

function this.Close(...)
    assert(this.opened)

    this.ChatLayer:Close()
	gUpdates_Close("PostUpdate")
	Dispatcher:Remove(this)
	this.releaseVirAcc()
    this.opened = false
    print("退出panel_service")
end

--初始化
function this.Init(...)
    this.ChatLayer = PopLayer:Pop(ChatLayer)
    this.ChatLayer.SendMessage = this.SendMessage
    this.ChatLayer.chat_list:addScrollViewEventListener(this.ScrollEvents)
	this.ChatLayer.btn_picture:addTouchEventListener(this.addPictureBtnCallBack)
	if not this.uploadimageUrl then
		this.uploadimageUrl = sGameManager.uploadimageUrl
	end
    this.getMessage(0,10)
	gUpdates_Set("PostUpdate", this.PostUpdate)
	Dispatcher:Register("OnReceiveCustomerServiceMsg",this.OnReceiveCustomerServiceMsg,this,true)
    this.requireMoreMessages = true

    --提示信息表
    this.allPopTexts = {}
end
--服务器推送客服消息处理
function this.OnReceiveCustomerServiceMsg(_self,rlt_)
	if rlt_.type == 1 then -- 客服发的消息
		local curItem = nil
		if rlt_.content ~= "" then
			local time_cell = this.addTime(this.Int64ToDateTime(rlt_.createtime),rlt_.type)
			this.ChatLayer.chat_list:pushBackCustomItem(time_cell)
			local item = this.MakeMsg(this.MESSAGE_TYPE.SERVICE_TEXT,rlt_.content)
			this.ChatLayer.chat_list:pushBackCustomItem(item)
			curItem = item
		end
		if rlt_.image_url ~= "" then
			local time_cell = this.addTime(this.Int64ToDateTime(rlt_.createtime),rlt_.type)
			this.ChatLayer.chat_list:pushBackCustomItem(time_cell)
			local item = this.MakeMsg(this.MESSAGE_TYPE.SERVICE_PICTURE,rlt_.image_url)
			this.ChatLayer.chat_list:pushBackCustomItem(item)
			curItem = item
		end
		if curItem ~= nil then
			local index = this.ChatLayer.chat_list:getIndex(curItem)
			this.ChatLayer.chat_list:jumpToItem(index,cc.p(0,0),cc.p(0,0))
		end
		go(
			function()
				local _data = PKG_Client_Lobby_ReadMessage.Create()
				_data.id = rlt_.Id
				gNet_SendPush(_data)
			end
		)
	else -- 自己发的消息
		print("一般不会走这里")
	end
	return true
end
-- listView 滑动事件监听
 function this.ScrollEvents(sender,eventType)
    -- 滚动到底部
	if eventType == ccui.ScrollviewEventType.scrollToBottom then
	elseif eventType == ccui.ScrollviewEventType.scrolling then
	elseif eventType == ccui.ScrollviewEventType.scrollToTop then
        if this.requireMoreMessages then -- 可以请求聊天内容的时候请求，避免反复请求
			this.requireMoreMessages = false
			this.getMessage(this.ChatLayer.chat_list:getChildrenCount()/2,10)
		end
	end
end
--发送消息回调
function this.SendMessage(message,pictureName)
    go(
		function()
            UIManager.ShowWaiting()--sGameManager.CreateWaiting(this, this.root)
			local data_ = PKG_Client_Lobby_SendMessage.Create()
			data_.content = message or ""
			data_.image = pictureName or ""
			data_.accountid = this.accountid == 0 and UserData.id or this.accountid
			data_.username = this.username == "" and UserData.username or this.username

            local rlt_ = nil

            for i = 1, 2 do
                rlt_ = gNet_SendRequest(data_)
                dump(rlt_, " ** rlt_ ** ")

                if rlt_ and getmetatable(rlt_) == PKG_Lobby_Client_Message then
                    break
                end

                if rlt_ and getmetatable(rlt_) == PKG_Generic_Error and rlt_.number == -9999 then
                    -- "您操作太频繁，请稍后再试"
                    UIManager.ShowMsgBox("ဆက်တိုက်လုပ်ဆောင်မှုများနေသဖြင့် ခဏစောင့်ဆိုင်းပြီးမှ လုပ်‌ဆောင်ပေးပါရှင့်(E9999)")
                    break
                end

                SleepSecs(0.3)
            end

            UIManager.HideWaiting()--this.CloseWaiting()
			this.sendPicture = false
			if(getmetatable(rlt_) == PKG_Lobby_Client_Message)then
				local curItem = nil
				if rlt_.content and rlt_.content ~= "" then
					local time_cell = this.addTime(this.Int64ToDateTime(rlt_.createtime),rlt_.type)
					this.ChatLayer.chat_list:pushBackCustomItem(time_cell)
					local item = this.MakeMsg(this.MESSAGE_TYPE.PLAYER_TEXT,rlt_.content)
					this.ChatLayer.chat_list:pushBackCustomItem(item)
					curItem = item
				end
				if rlt_.image_url and rlt_.image_url ~= "" then
					local time_cell = this.addTime(this.Int64ToDateTime(rlt_.createtime),rlt_.type)
					this.ChatLayer.chat_list:pushBackCustomItem(time_cell)
					local item = this.MakeMsg(this.MESSAGE_TYPE.PLAYER_PICTURE,rlt_.image_url)
					this.ChatLayer.chat_list:pushBackCustomItem(item)
					curItem = item
				end
				if curItem ~= nil then
					local index = this.ChatLayer.chat_list:getIndex(curItem)
					this.ChatLayer.chat_list:jumpToItem(index,cc.p(0,0),cc.p(0,0))
				end
			elseif(getmetatable(rlt_) == PKG_Generic_Error)then
				print("发送按钮的回调错误")
			end
		end
	)
end
--添加图片回调
function this.addPictureBtnCallBack(ref,type)
    if(type == ccui.TouchEventType.ended) then
        this.picture_timer = this.picture_timer or 0
        if os.clock() - this.picture_timer < 0.5 then
            return
        end
        this.picture_timer = os.clock()
        ref:runAction(cc.Sequence:create(cc.CallFunc:create(function() gSound.clickSound(); end),
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function() Device:OpenAlbum() end)))
    end
end
--主动获取消息
function this.getMessage(index,count)
    go(
        function()
            local data_ = PKG_Client_Lobby_GetMessage.Create()
            data_.limitindex = index or 0
			data_.count = count or 10
			data_.accountid = this.accountid
            data_.username = this.username
            local rlt_ = gNet_SendRequest(data_)
            if(getmetatable(rlt_) == PKG_Lobby_Client_AllMessage)then
				if #rlt_.messages == 0 and index ~= 0 then
					UIManager.ShowToast(TR("没有更多"))
					---sGameManager.ShowPromptInfo(this.ChatLayer,"No More News") --Def.Service_noMoreMsg) -- 多语言
					this.ChatLayer:runAction(cc.Sequence:create(cc.DelayTime:create(1),
						cc.CallFunc:create(function() this.requireMoreMessages = true end)))
					return
				end
				if index == 0 then
					this.AllMessageToTab(rlt_.messages,true)
				else
					this.AllMessageToTab(rlt_.messages,false)
				end

			elseif(getmetatable(rlt_) == PKG_Generic_Error)then
				print("this.getMessage PKG_Client_Lobby_GetMessage 错误",rlt_.message)
			end
        end
    )
end

this.CreateChatItem = function (isImage,type,content,createtime)
	local item = nil
	if type == 0 then
		if isImage then
			item = this.MakeMsg(this.MESSAGE_TYPE.PLAYER_PICTURE,content)
		else
			item = this.MakeMsg(this.MESSAGE_TYPE.PLAYER_TEXT,content)
		end
	else
		if isImage then
			item = this.MakeMsg(this.MESSAGE_TYPE.SERVICE_PICTURE,content)
		else
			item = this.MakeMsg(this.MESSAGE_TYPE.SERVICE_TEXT,content)
		end
	end
	this.ChatLayer.chat_list:insertCustomItem(item,0)
	local time_cell = this.addTime(this.Int64ToDateTime(createtime),type)
	this.ChatLayer.chat_list:insertCustomItem(time_cell,0)
	return item
end


--所有聊天信息转成聊天记录
function this.AllMessageToTab(messages,needToBottom)
	local num = 0
	for i=1,#messages do
		local msg = messages[i]
		if msg.image_url and msg.image_url ~= "" then
			num = num + 1
			this.CreateChatItem(true,msg.type,msg.image_url,msg.createtime)
		end
		if msg.content and msg.content ~= "" then
			local isJson = string.sub(msg.content,1,5) == "json:"
			if isJson then
				msg.content = string.gsub(msg.content,"json:","")
				local Msgs = this.Json2Msg(msg)
				for _, jsonMsg in ipairs(Msgs) do
					num = num + 1
					if jsonMsg.image_url and jsonMsg.image_url ~= "" then
						this.CreateChatItem(true,jsonMsg.type,jsonMsg.image_url,jsonMsg.createtime)
					else
						this.CreateChatItem(false,jsonMsg.type,jsonMsg.content,jsonMsg.createtime)
					end
				end
			else
				num = num + 1
				this.CreateChatItem(false,msg.type,msg.content,msg.createtime)
			end
		end
	end
	if needToBottom then
		this.ChatLayer.chat_list:jumpToBottom()
	else
		this.ChatLayer.chat_list:jumpToItem(num*2+1,cc.p(0,0),cc.p(0,0))
	end
	this.ChatLayer:runAction(cc.Sequence:create(cc.DelayTime:create(1),
		cc.CallFunc:create(function() this.requireMoreMessages = true end)))
end
-- 增加一个时间
function this.addTime(time,type)
	--左185 右520
	local Panel_Time = this.ChatLayer.Panel_Time:clone()
	Panel_Time:setVisible(true)
	local create_time = Panel_Time:getChildByName("create_time")
    local pos = cc.p(type == 0 and 355 or 180,create_time:getPositionY())
    create_time:setPosition(pos)
    create_time:setString(time)
	return Panel_Time
end
--制作一个聊天记录
function this.MakeMsg(type,content)
    if type == nil or content == nil then
		print("检查聊天内容是否有误")
		return
    end
    local item = nil
	content = string.gsub(content,"show:","")
	if type == this.MESSAGE_TYPE.SERVICE_TEXT then
		item = this.MakeMessage(this.ChatLayer.item_left,content)--this.Panel_left_cell(改为item_left) : 客服聊天框预制体
	elseif type == this.MESSAGE_TYPE.SERVICE_PICTURE then
		item = this.MakePicture(this.ChatLayer.item_left,content)
	elseif type == this.MESSAGE_TYPE.PLAYER_TEXT then
		item = this.MakeMessage(this.ChatLayer.item_right,content,this.GetMyIcon())--this.Panel_right_cell(改为item_right) : 玩家聊天框预制体
	elseif type == this.MESSAGE_TYPE.PLAYER_PICTURE then
		item = this.MakePicture(this.ChatLayer.item_right,content,this.GetMyIcon())
	end
	return item
end
-- 获取自己的头像
function this.GetMyIcon()
	local head_icon_id = 0
	if UserData and UserData.avatar_id then
		head_icon_id = UserData.avatar_id
	end
	if head_icon_id == 0 then
		head_icon_id = 1
	end
	local path = Tools.GetHeadPath(head_icon_id)
	return path
end
--制作一条文本消息记录
function this.MakeMessage(cell,message,icon)
    local newM = cell:clone()
	local contentBG = newM:getChildByName("bg") -- 聊天框
    local headIcon = newM:getChildByName("icon") -- 头像
    local content = newM:getChildByName("content") -- 单条聊天记录内容
	if icon then
		headIcon:loadTexture(icon)
	end
	local contentMsg = content:getChildByName("msg") -- 聊天文本
	contentMsg:setVisible(true)
	local contentPicture = content:getChildByName("picture") -- 聊天图片
	contentPicture:setVisible(false)
	if not message then
		print("AddMessage 没有 message")
		return
	end
	contentMsg:setString(message)
	this.textAdaptHeight(contentMsg)
	local size = cc.size(contentMsg:getContentSize().width+30,contentMsg:getContentSize().height +20)
	contentBG:setContentSize(size)
	size = cc.size(contentMsg:getContentSize().width+30,
		(contentMsg:getContentSize().height>headIcon:getContentSize().height and contentMsg:getContentSize().height or headIcon:getContentSize().height)+20)
	local icon_height= newM:getContentSize().height - size.height
	headIcon:setPosition(headIcon:getPositionX(),headIcon:getPositionY()-icon_height)
	contentBG:setPosition(contentBG:getPositionX(),contentBG:getPositionY()-icon_height)
    --contentMsg:setPosition(contentMsg:getPositionX(),contentMsg:getPositionY()-icon_height)
    content:setPosition(content:getPositionX(),content:getPositionY()-icon_height)
    newM:setContentSize(cc.size(newM:getContentSize().width,size.height+10))

	return newM
end
-- 文本实际宽高
 function this.textAdaptHeight(text)
	local size = text:getContentSize()
	local real_size = text:getVirtualRendererSize()

	if real_size.width < size.width then
		size.width = 0
	end
	size.height = 0
    text:setTextAreaSize(size)
    text:ignoreContentAdaptWithSize(false)
	size = text:getVirtualRendererSize()
    text:ignoreContentAdaptWithSize(true)
	text:setContentSize(size)
end
--制作一条图片记录
function this.MakePicture(cell,picturePath,icon)
    local newM = cell:clone()
    newM = this.ResetPicture(newM,picturePath,icon)
	return newM
end
--设置图片
function this.ResetPicture(newM,picturePath,icon)
	local headIcon = newM:getChildByName("icon") -- 头像
	local contentBG = newM:getChildByName("bg") -- 聊天框
    local content = newM:getChildByName("content") -- 单条聊天记录内容
	if icon then
		headIcon:loadTexture(icon)
	end
    local contentMsg = newM:getChildByName("content"):getChildByName("msg") -- 聊天文本
	contentMsg:setVisible(false)
	local contentPicture = newM:getChildByName("content"):getChildByName("picture") -- 聊天图片
	contentPicture:setVisible(true)
	if not picturePath then
		print("AddPicture 没有 picturePath")
	end
    if picturePath:find("http") then
		local tab = string.split(picturePath,"/images/")
		local pictureName = string.split(tab[2],",")[1]
		local localPicturePath = this.HallWritablePath.. "picture/" .. pictureName --多语言
		if not Tools.FileIsBeing(localPicturePath) then	--如果不本地存在图片
			this.GetPictureWithUrl(picturePath,newM,icon)
			picturePath = "hallui/serviceEx/Default/ImageFile.png"
		else
			picturePath = localPicturePath
		end
	end
    -- 如果图片非法
	if not cc.Director:getInstance():getTextureCache():addImage(picturePath) then
		picturePath = "hallui/serviceEx/Default/ImageFile.png"
	end
	contentPicture:loadTexture(picturePath,0)
	contentPicture:addTouchEventListener(function(ref,type)
		if(type == ccui.TouchEventType.ended)then
			print("查看原图片")
			local item =  ccui.ImageView:create(picturePath)
			local size = item:getContentSize() -- 图片的原始尺寸，用于滑动容器的滑动区域大小
			local anchor = cc.p(0,0)
			local sVPos = cc.p(0,0)
			local itemPos = cc.p(0,0)
			local svSize = cc.size(size.width > Def.visibleSize.width and Def.visibleSize.width or size.width,
						size.height > Def.visibleSize.height and Def.visibleSize.height or size.height)
			if size.width > Def.visibleSize.width and size.height < Def.visibleSize.height then
				anchor = cc.p(0,0.5)
				sVPos = cc.p(0,Def.visibleSize.height/2)
				itemPos = cc.p(0,size.height/2)
			elseif size.width < Def.visibleSize.width and size.height > Def.visibleSize.height then
				anchor = cc.p(0.5,0)
				sVPos = cc.p(Def.visibleSize.width/2,0)
				itemPos = cc.p(size.width/2,0)
			else
				anchor = cc.p(0.5,0.5)
				sVPos = cc.p(Def.visibleSize.width/2,Def.visibleSize.height/2)
				itemPos = cc.p(size.width/2,size.height/2)
			end
			item:setAnchorPoint(anchor)
			item:setTouchEnabled(true)
			item:setPosition(itemPos)
			item:addTouchEventListener(function(ref,type)
				if(type == ccui.TouchEventType.ended) then
					--按键音效
					gSound.clickSound()
					this.temp = this.temp or 0
					this.temp = this.temp + 1
					-- 双击图片也可以关闭查看图片
					ref:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),
						cc.CallFunc:create(function() this.temp = 0 end)))
					if this.temp == 2 then
						this.ChatLayer.image_list:removeAllChildren()
						this.ChatLayer.image_node:setVisible(false)
						this.temp = 0
					end
				end
			end)
			this.ChatLayer.image_list:addChild(item,999)
			this.ChatLayer.image_list:setAnchorPoint(anchor)
			this.ChatLayer.image_list:setPosition(sVPos)
			this.ChatLayer.image_list:setContentSize(svSize)
			this.ChatLayer.image_list:setInnerContainerSize(size)
			this.ChatLayer.image_node:setVisible(true)
		end
	end)
	this.pictureAdaptWidth(contentPicture,icon and true or false)
	local iamgeScale  = contentPicture:getScale()
	local size = contentPicture:getContentSize()
	local bgSize = cc.size(size.width*iamgeScale+35,size.height*iamgeScale+18)
	contentBG:setContentSize(bgSize)
	local headIconSize = headIcon:getContentSize()
	local otherSize = cc.size(bgSize.width,
		(size.height>headIconSize.height and size.height*iamgeScale or headIconSize.height)+20)
	local icon_height= newM:getContentSize().height - otherSize.height - 5
	headIcon:setPosition(headIcon:getPositionX(),headIcon:getPositionY()-icon_height)
	contentBG:setPosition(contentBG:getPositionX(),contentBG:getPositionY()-icon_height)
	contentPicture:setPosition(contentPicture:getPositionX(),contentPicture:getPositionY()-icon_height)
    newM:setContentSize(cc.size(newM:getContentSize().width,otherSize.height+10))

	return newM
end
-- 图片实际宽高image:图片;width:设计的宽
function this.pictureAdaptWidth(image,right)
	local width = 0
	if right then
		if this.ChatLayer.item_right then
			width = this.ChatLayer.item_right.designWidth
		end
	else
		if this.ChatLayer.item_left then
			width = this.ChatLayer.item_left.designWidth
		end
	end
	local size = image:getVirtualRendererSize()
	if size.width>width then
		image:setScale(width/size.width)
	end
	image:setContentSize(size)
end
-- 获取网络图片
function this.GetPictureWithUrl(url,node,icon)
	local xhr = cc.XMLHttpRequest:new()
	local tab = string.split(url,"/images/")
	xhr._urlFileName = "download/picture/"..string.split(tab[2],",")[1]  -- 图片的相对路径
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	node:retain()
	xhr:open("GET",url)
	local function onDownloadImage()
		print("xhr.readyState is:", xhr.readyState, "xhr.status is: ", xhr.status)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local fileData = xhr.response
			local fullFileName = cc.FileUtils:getInstance():getWritablePath() .. "/".. xhr._urlFileName

			local dirName = string.match(fullFileName, "(.+)/[^/]*$")
			if not cc.FileUtils:getInstance():isDirectoryExist(dirName) then
				cc.FileUtils:getInstance():createDirectory(dirName)
			end

			local file = io.open(fullFileName,"wb")
			file:write(fileData)
			file:close()
			this.ResetPicture(node,fullFileName,icon)
			node:release()

			local chat_list = nil
			if not this.ChatLayer or this.ChatLayer.chat_list then
				return
			end
			chat_list = this.ChatLayer.chat_list
			local percent_ = chat_list:getScrolledPercentVertical()
			chat_list:requestDoLayout()
			if percent_ == percent_ then -- 不要删这一行，判断是否为nan
				chat_list:jumpToPercentVertical(percent_)
			end
		end
	end
	xhr:registerScriptHandler(onDownloadImage)
	xhr:send()
end
-- int64转成标准格式
 function this.Int64ToDateTime(time_)
	local year,month,day,hour,min,second,week,dayforyear  = Int64ToDateTime(time_)
	local time = string.format("%02d-%02d %02d:%02d:%02d",month,day,hour,min,second)
	return time
end
-- 如果 sGameManager.Image == "null" 说明用户取消选择照片 提示 用户取消选择
-- 如果 sGameManager.ImageSize and sGameManager.ImageSize ~= "false" and sGameManager.Image ~= nil 说明 图片ok
-- 每次得到Image之后记得重置Image = nil 和 ImageSize = nil
--上传循环
function this.PostUpdate()
	if sGameManager.Image == "null" then
		UIManager.ShowToast(TR("用户取消选择系统照片"))
		sGameManager.Image = nil
		sGameManager.ImageSize = nil
	elseif sGameManager.ImageSize and sGameManager.ImageSize ~= "false" and sGameManager.Image ~= nil then
		local Image = sGameManager.Image
		local ImageSize = sGameManager.ImageSize
		sGameManager.Image = nil
		sGameManager.ImageSize = nil
		go(function()
				this.sendPicture = true -- 发送图片进行时标识 此时如果来了 客服评价包，会阻塞评价界面
				local timer = 0 -- Activity 切换后等待3帧渲染GL再去处理上传逻辑，防止黑屏
				while true do
					timer = timer+1
					if timer < 3 then
						yield()
					else
						break
					end
				end
				print("Panel_service : start upload picture")
				local newfileBase64 = Tools.getSmilePicture(Image)
				if not newfileBase64 then
					UIManager.ShowToast("change picture error")
					this.sendPicture = false
					return
				end
				this.imgdata = {
					["base64"] = newfileBase64,
					["size"]	= #newfileBase64
				}
				sGameManager.Image = nil
				sGameManager.ImageSize = nil
				UIManager.ShowToast(TR("图片已选择"))
				local xhr = cc.XMLHttpRequest:new()
				xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
				xhr:open("POST",this.uploadimageUrl)---sGameManager.uploadimageUrl)
				UIManager.ShowWaiting()--sGameManager.CreateWaiting(this,this.root)
				local function onReadyStateChanged()
						if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then -- 成功
							if xhr.response == "1" or xhr.response == "2" then
								UIManager.ShowToast(TR("网络异常，图片上传失败"))
								this.sendPicture = false
								UIManager.HideWaiting()--this.CloseWaiting()
							else
								this.SendMessage(nil,xhr.response)
								UIManager.HideWaiting()--this.CloseWaiting()
							end
						else
							UIManager.ShowToast(TR("网络异常，正在努力上传图片~"))
							this.sendPicture = false
							UIManager.HideWaiting()--this.CloseWaiting()
						end
					xhr:unregisterScriptHandler()
				end
				xhr:registerScriptHandler(onReadyStateChanged)
				xhr:send(json.encode(this.imgdata))
			end)
	end
end

-- 虚拟账号release
this.releaseVirAcc = function()
	this.accountid = 0
	this.username = ""
	this.resumePeer = false
	if this.ENTER_PANEL == 1 then
		gNetHandlers_Unregister(PKG_Lobby_Client_Message, "OnReceiveCustomerServiceMsg")
	end
	this.ENTER_PANEL = 0
end

-- 新增一个在登录界面需要的传入的虚拟账号函数
this.setVirAcc = function(accountid,username)
	this.accountid = accountid
	this.username = username
	this.resumePeer = true
	this.ENTER_PANEL = 1
	-- 虚拟账号断线重连协程
	go(
		function()
			if gNet:Alive() then
				if not this.resumePeer then return end
				yield()
			end
			if this.resumePeer then
				-- 连接上了
				go(
					function()
						local rlt_ = nil
						while not rlt_ do
							SleepSecs(0.3)
							if not this.resumePeer or not this.opened then return end
							if not gNet:Alive() then
								rlt_ = this.resumeAcc()
							end
						end
						this.setVirAcc(this.accountid,this.username)
					end
				)
			end
		end
	)
end

-- 虚拟账号断线重连 -- 注意需要协程调用
this.resumeAcc = function()
	local layer = BottomLayer:Get(LoginLayer)
	layer:ConnectNetwork()
	local data_ = PKG_Client_Lobby_RegisterTempMsgService.Create()
	data_.accountid = this.accountid
	data_.username = this.username
	local rlt_ = gNet_SendRequest(data_)
	if rlt_ == nil or getmetatable(rlt_) == PKG_Generic_Error then
		return nil
	end
	return true
end

-- 后台json转成多条消息
this.Json2Msg = function(msg)
	local tabs = json.decode(msg.content)
	local rets = {}
	for _, tab in ipairs(tabs) do
		if tab.type == "image" then
			for _, v in ipairs(tab.url) do
				local Message = PKG_Lobby_Client_Message.Create()
				Message.createtime = msg.createtime
				Message.type = msg.type
				Message.image_url = "http://3.1.33.127/upload2/images/" .. v
				table.insert(rets,1,Message)
			end
		else
			local Message = PKG_Lobby_Client_Message.Create()
			Message.createtime = msg.createtime
			Message.type = msg.type
			Message.content = tab.content
			table.insert(rets,1,Message)
		end
	end
	return rets
end
return this
