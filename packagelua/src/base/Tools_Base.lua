local Tools_Base = {}
-- 给基础包用的
----------------------------------------------------------------
Tools_Base.DesignedX			=	1280.0
Tools_Base.DesignedY			=	720.0
Tools_Base.visibleSize			=	cc.Director:getInstance():getVisibleSize()
Tools_Base.ScaleX				=	Tools_Base.visibleSize.width / Tools_Base.DesignedX
Tools_Base.ScaleY				=	Tools_Base.visibleSize.height / Tools_Base.DesignedY
Tools_Base.ScaleMax				=   math.max(Tools_Base.ScaleX, Tools_Base.ScaleY)
Tools_Base.ScaleMin				=   math.min(Tools_Base.ScaleX, Tools_Base.ScaleY)

LangDef = require("packagelua.src.base.LangDef")
for k,v in pairs(LangDef) do
    Tools_Base[k] = v
end

function Tools_Base.AdjustBg(bgNode)
    local DesignedX			=	1280.0
    local DesignedY			=	720.0
    local visibleSize			=	cc.Director:getInstance():getVisibleSize()
    local ScaleX				=	visibleSize.width / DesignedX
    local ScaleY				=	visibleSize.height / DesignedY
    local ScaleMax				=   math.max(ScaleX, ScaleY)
    local ScaleMin				=   math.min(ScaleX, ScaleY)
    bgNode:setScale(ScaleMax)
end

function Tools_Base.AdjustCenter(centerNode)
    local DesignedX			=	1280.0
    local DesignedY			=	720.0
    local visibleSize			=	cc.Director:getInstance():getVisibleSize()
    local ScaleX				=	visibleSize.width / DesignedX
    local ScaleY				=	visibleSize.height / DesignedY
    local ScaleMax				=   math.max(ScaleX, ScaleY)
    local ScaleMin				=   math.min(ScaleX, ScaleY)
    centerNode:setScale(ScaleMin)
end

-- 国家名字转id
function Tools_Base.Name2Id(name)
    for id, data in pairs(Tools_Base.Languages) do
        if data.name == name then
            return id
        end
    end
    return LangDef.LANG_EN
end

function Tools_Base.Id2Name(id)
    for __, data in pairs(Tools_Base.Languages) do
        if data.id == id then
            return data.name
        end
    end
    return "en"
end

--创建一个节点
function Tools_Base.CreateNode(csb_file_name)
    local node
    if csb_file_name == nil then
        node = cc.Layer:create()
    else
        node = cc.CSLoader:createNode(csb_file_name)
    end
    node:enableNodeEvents()
	TR_Node(node)
    return node
end

function Tools_Base.CreateLayer(csb_file_name)
    return Tools_Base.CreateNode(csb_file_name)
end

----------------------------------------------------------------

-- 按钮是件
function Tools_Base.AddClickEvent(btn, handler)
    btn:addTouchEventListener(
        function(btn, type)
            if type == ccui.TouchEventType.began then
                btn:setScale(0.95)
            elseif type == ccui.TouchEventType.ended then
                gSound.clickSound()
                btn:setScale(1.0)
				if handler then handler() end
            elseif type == ccui.TouchEventType.canceled then
            	btn:setScale(1.0)
            elseif type == ccui.TouchEventType.moved then
                btn:setScale(0.95)
            end
		end
	)
end

-- 基础消息弹窗
function Tools_Base.ShowMsgBox(msg, on_confirm, on_cancel)
    local MsgBoxBaseLayer = require("packagelua.src.msg.MsgBoxBaseLayer").new()
    MsgBoxBaseLayer:ShowMsgBox(msg,on_confirm, on_cancel)
end

----------------------------------------------------------------
-- Waiting 界面处理

Tools_Base.waiting_cnt = 0
Tools_Base.waiting_layer = nil

function Tools_Base.ShowWaiting()
    local layer = Tools_Base.waiting_layer
    if layer == nil then
        local WaitingLayer = require("packagelua.src.msg.WaitingLayer")
        layer = WaitingLayer:create()
        cc.Director:getInstance():getRunningScene():addChild(layer)
        Tools_Base.waiting_layer = layer
        Tools_Base.waiting_cnt = 0
    end
    layer:setVisible(true)
    Tools_Base.waiting_cnt = Tools_Base.waiting_cnt + 1
end

function Tools_Base.HideWaiting()
    Tools_Base.waiting_cnt = Tools_Base.waiting_cnt - 1
    if Tools_Base.waiting_cnt <= 0 then
        if Tools_Base.waiting_layer ~= nil then
            Tools_Base.waiting_layer:removeFromParent()
            Tools_Base.waiting_layer = nil
        end
        Tools_Base.waiting_cnt = 0
    end
end

----------------------------------------------------------------

--储存登录域名相关数据
function Tools_Base.SaveConfigParam(data_)
end

----------------------------------------------------------------
--- 判断账号密码是否合理用
---str：字符串 包含数字字母
---lowest：需要最低位数
---highest：需要最高位数
function Tools_Base.formatString(str,lowest,highest)
	if	lowest > highest then
		__G__TRACKBACK__("Tools_Base.formatString : lowest > highest")
	end
	local t = ""
	for str in string.gmatch(str,"[%w]") do
		t = t .. str
	end
	if str == t -- 只包含数字字母
	and	#str>= lowest -- 不低于lowest字符
	and	#str<= highest	then -- 不高于于highest字符
		return true
	end
	return false
end

--防止连续点击
function Tools_Base.PreventContinuousClick(button,time)
	if not button then
		print("需要传入按钮记录时间")
		return false
	end
	button.click_time = button.click_time or 0
	local socket = require("socket")
	local timer = socket.gettime()
	if timer - button.click_time < (time or 0.5) then
		return false
	end
	button.click_time = timer
	return true
end

function Tools_Base.GetStringWordNum(str)
    local fontSize = 20
    local lenInByte = #str
    local count = 0
    local i = 1
    while true do
        local curByte = string.byte(str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then
            byteCount = 1
        elseif curByte>=128 and curByte<224 then
            byteCount = 2
        elseif curByte>=224 and curByte<240 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        else
            break
        end
        -- local char = string.sub(str, i, i+byteCount-1)
        i = i + byteCount
        count = count + 1
    end
    return count
end

function Tools_Base.HasSpace(text)
    release_print("text:" .. text)
	for i=1, text:len() do
        local ch = string.byte(text, i, i)
        if ch <= 32 then
            return true
        end
	end
	return false
end

function Tools_Base.ReplaceNode(node, new_node)
    new_node:setContentSize(node:getContentSize())
    new_node:setScale(node:getScale())
    new_node:setPosition(cc.p(node:getPosition()))
    new_node:setAnchorPoint(cc.p(node:getAnchorPoint()))
    new_node:setLocalZOrder(node:getLocalZOrder())
    new_node:setName(node:getName())
    node:getParent():addChild(new_node)
    node:removeFromParent()
    return new_node
end

function Tools_Base.ReplaceEdit(node)
    local edit = NewEditBox:create()
    return Tools_Base.ReplaceNode(node, edit)
end

return Tools_Base
