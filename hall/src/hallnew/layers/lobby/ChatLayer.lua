local ChatLayer = class("ChatLayer", function()
    return Tools.CreateLayer("csb/lobby/ChatLayer.csb")
end)

function ChatLayer:onEnter()
    self:InitUI()
end

function ChatLayer:InitUI()
	self.allPopTexts = {}
    --关闭按钮
	self.ui_close_btn = self:findChild('lua_close_btn')
	Tools.AddClickEvent(self.ui_close_btn, function()
		local panel_service = require "hall.src.hallnew.layers.lobby.Panel_service"
		gStates_CloseAsync(panel_service)
	end, true)
	--客服聊天框预制体
	self.chat_list = self:findChild('chat_list')
	--时间文本预制体
	self.Panel_Time = self.chat_list:getChildByName("Panel_Time")
	-- self.Panel_Time:removeFromParent()
	self.Panel_Time:retain()
	--客服聊天框预制体
	self.item_left = self:findChild('item_left')
	self.item_left:getChildByName("icon"):loadTexture("hall/res/chat_layer/head_service.png")
	self.item_left:getChildByName("content"):getChildByName("msg"):setFontSize(24)
	self.item_left:getChildByName("content"):getChildByName("msg"):setFontName("Arial")
	self.item_left.designWidth = self.item_left:getChildByName("bg"):getContentSize().width
	-- self.item_left:removeFromParent()
	self.item_left:retain()
	--玩家聊天框预制体
	self.item_right = self:findChild('item_right')
	self.item_right:getChildByName("content"):getChildByName("msg"):setFontSize(24)
	self.item_right:getChildByName("content"):getChildByName("msg"):setFontName("Arial")
	self.item_right.designWidth = self.item_right:getChildByName("bg"):getContentSize().width
	-- self.item_right:removeFromParent()
	self.item_right:retain()
	self.chat_list:removeAllItems()
	--发送按钮
	self.btn_send = self:findChild('_lang_btn_send')
	Tools.AddClickEvent(self.btn_send, function()
		self:SendBtnCallBack()
	end, true)
	--添加图片按钮
	self.btn_picture = self:findChild('_lang_btn_picture')
	--输入框
	local input_text = self:findChild('input_text')
	input_text:setString("")
	local input_pos = cc.p(input_text:getPositionX(),input_text:getPositionY())
	local input_ContentSize = input_text:getContentSize()
	self.inputEdit = ccui.EditBox:create(input_ContentSize,"hall/res/chat_layer/tc_shurukuangbeijing.png")
	self.inputEdit:setPosition(input_pos)
	self.inputEdit:setPlaceHolder(TR("请在这里输入你的问题"))
	local PlaceholderFont = 28
	self.inputEdit:setPlaceholderFont("Arial",PlaceholderFont)
	self.inputEdit:setFontSize(36)
	self.inputEdit:setMaxLength(50)
	self.inputEdit:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.inputEdit:setPlaceholderFontColor(cc.c3b(220,220,220))
	self.inputEdit:setAnchorPoint(cc.p(0.5,0.5))
	self.inputEdit:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.inputEdit:registerScriptEditBoxHandler(self.InputCallBack)
	self:addChild(self.inputEdit)

	--查看图片节点
	self.image_node = self:findChild('image_node')
	self.image_node:setLocalZOrder(999)
	self.image_list = self.image_node:getChildByName("image_list")
	self.image_list:setScrollBarEnabled(false)
	self.image_list:setSwallowTouches(false)
	self.image_node:addTouchEventListener(function(ref,type)
		if(type == ccui.TouchEventType.ended) then
			--按键音效
			gSound.clickSound()
			self.image_list:removeAllChildren()
			self.image_node:setVisible(false)
		end
	end)
	self.image_node:setVisible(false)
end
--输入框回调
function ChatLayer:InputCallBack(event,sender)
	if event == "began" then
		self.inputEdit:setPlaceHolder("")
	elseif event == "changed" then
		
	elseif event == "return" then
		if self.inputEdit:getText() == "" then
			self.inputEdit:setPlaceHolder(TR("请在这里输入你的问题"))
		end
	elseif event == "end" then 
		if self.inputEdit:getText() == "" then
			self.inputEdit:setPlaceHolder(TR("请在这里输入你的问题"))
		end
	end
end
--发送按钮回调
function ChatLayer:SendBtnCallBack()
	local msg = self.inputEdit:getText()
	msg = string.gsub(msg, "/r/n", "") -- 去掉换行
	msg = string.trim(msg) -- 去掉前后空格
	if msg == "" or msg == nil then -- 消息为空
		print("消息为空")
		UIManager.ShowToast(TR("请输入您的问题"))
		return
	end
	self.inputEdit:setText("")
	self.inputEdit:setPlaceHolder(TR("请在这里输入你的问题"))
	self.SendMessage(msg,nil)
end
return ChatLayer
