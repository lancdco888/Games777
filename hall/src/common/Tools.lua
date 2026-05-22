local Tools = {}

----------------------------------------------------------------
--创建一个节点
function Tools.CreateNode(csb_file_name)
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

function Tools.CreateLayer(csb_file_name)
    return Tools.CreateNode(csb_file_name)
end

----------------------------------------------------------------

-- 按钮是否高亮
function Tools.AddClickEvent(btn, handler, enableSound)
	if btn == nil or tolua.isnull(btn) then
		print("Tools.AddClickEvent(), btn is null.")
		print(debug.traceback())
		return
	end

    if enableSound == nil then enableSound = true end

	local name = btn:getName()
    if not btn.old_scaleX then
        btn.old_scaleX = btn:getScaleX()
    end

    if not btn.old_scaleY then
        btn.old_scaleY = btn:getScaleY()
    end

    btn:addTouchEventListener(
        function(btn, type)
            if type == ccui.TouchEventType.began then
				btn:setScaleX(btn.old_scaleX * 0.95)
				btn:setScaleY(btn.old_scaleY * 0.95)
            elseif type == ccui.TouchEventType.ended then
				if enableSound then gSound.clickSound() end
				btn:setScaleX(btn.old_scaleX * 1.0)
				btn:setScaleY(btn.old_scaleY * 1.0)

				if not Tools_Base.PreventContinuousClick(btn, sec or 0.4) then
				    print("别点这么快")
				    return
				end

				if handler then handler() end
            elseif type == ccui.TouchEventType.canceled then
				btn:setScaleX(btn.old_scaleX * 1.0)
				btn:setScaleY(btn.old_scaleY * 1.0)
            elseif type == ccui.TouchEventType.moved then
				btn:setScaleX(btn.old_scaleX * 0.95)
				btn:setScaleY(btn.old_scaleY * 0.95)
            end
		end
	)
end

function Tools.ReplaceNode(node, new_node)
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

function Tools.ReplaceEdit(node)
    local edit = NewEditBox:create()
    return Tools.ReplaceNode(node, edit)
end

function Tools.ResetParent(node, new_parent)
	local pos = node:convertToWorldSpace(cc.p(0, 0))
    node:retain()
    node:removeFromParent()
    new_parent:addChild(node)

	local nodep = new_parent:convertToNodeSpace(pos)
	node:setPosition(nodep)

    node:release()
end

local fileUtils = cc.FileUtils:getInstance()
function Tools.FindFirstExist(file)
    if fileUtils:isFileExist(file) then
        return file
    end
    return nil
end

--替换一个图的纹理
function Tools.LoadTexture(ImageView,path)
	local new_path = Tools.FindFirstExist(path)
	if new_path then
		ImageView:loadTexture(new_path)
		local size = ImageView:getVirtualRendererSize()
		ImageView:setContentSize(size)
	else
		print("[Error] Tools.LoadTexture:" .. path .. "图不存在!!!")
		print(debug.traceback())
	end
end
----------------------------------------------------------------

function Tools.GetHeadPath(id)
    if id == 0 then id = 1 end
    local path1 = string.format("common/avtar/%d.png", id)
    return path1, path1
end

function Tools.GetShowNickName()
	if UserData.username ~= UserData.nickname then
		return UserData.nickname
	else
		if UserData.username == UserData.phone then
			return tostring(UserData.id)
		else
			return UserData.phone
		end
	end
end

function Tools.FormatIndNum(num_str)
	local str = ""
	local len = #num_str
	local index = 1
	for i = len, 1, -1 do
		str = string.sub(num_str, i, i) .. str
		if(index %3 == 0 and index ~= len) then
			str = "," .. str
		end
		index = index + 1
	end
	return str
end

----------------------------------------------------------------

-- 自定义一个GridView替换ScrollView
function Tools.ReplaceScrollView(ScrollView)
    local gView_ = GridView:create()
	gView_:copyProperties(ScrollView)
	ScrollView:getParent():addChild(gView_)
	ScrollView:removeFromParent()
	return gView_
end

-- 排列 容器(根据item的宽和View的宽)
function Tools.ViewDoLayout(View)
    local childrenCount = View:getChildrenCount()
    if childrenCount == 0 then
        return
    end
    local children = View:getChildren()
    local childSize = children[1]:getContentSize()
    local model_w = childSize.width
    local model_h = childSize.height

    local viewSize = View:getContentSize()
    local self_w = viewSize.width
    local self_h = viewSize.height
    local function getPosByIndex(index,total)
        local num = math.floor(self_w/model_w)
        local mod = math.floor((index - 1) / num) + 1
        local remainder = math.fmod(index, num) == 0 and num or math.fmod(index, num)

        local PosX = (remainder-1) * model_w
        local PosY = (math.floor((total - 1) / num) + 1) * model_h < self_h and self_h - mod * model_h or (math.floor((total - 1) / num) + 1) * model_h - mod * model_h
        return cc.p(PosX,PosY)
    end
    local function doLayout()
        local num = math.floor(self_w/model_w)
        for i,child in ipairs(children) do
            child:setAnchorPoint(0, 0)
            child:setScale(1)
            child:setPosition(getPosByIndex(i,childrenCount))
        end
        local height_ = (math.floor((childrenCount-1)/num)+1)*model_h
        View:setInnerContainerSize(cc.size(self_w,height_))
    end
    doLayout()
end

local MOVE_ACTION_TAG=10001
function Tools.MoveInAni(node, time, x)
    node:stopActionByTag(MOVE_ACTION_TAG)
    local action = cc.Sequence:create(
        cc.Show:create(),
        cc.MoveBy:create(0.0, cc.p(x, 0)),
        cc.MoveBy:create(time, cc.p(-x, 0))
    )
    action:setTag(MOVE_ACTION_TAG)
	node:runAction(action)
end

function Tools.MoveOutAni(node, time, x, callback)
    node:stopActionByTag(MOVE_ACTION_TAG)
    local action = cc.Sequence:create(
        cc.MoveBy:create(time, cc.p(x, 0)),
        cc.MoveBy:create(0.0, cc.p(-x, 0)),
        cc.Hide:create(),
        cc.CallFunc:create(
            function()
                if callback then
                    callback()
                end
            end
        )
    )
    action:setTag(MOVE_ACTION_TAG)
	node:runAction(action)
end

---将超过designSize大小的图片缩放至5M以下
---base64:图片的base64
---返回压缩后的图片base64
function Tools.getSmilePicture(base64)
	local scale = 1
	local sp = createSpriteFromBase64(base64)
	local size = sp:getContentSize()
	local designSize = {width = 1920,height = 1080}
	if size.height > size.width then
		designSize = {width = 1080,height = 1920}
	end
	if size.width<designSize.width and size.height<designSize.height then
		return base64
	elseif size.width/designSize.width > size.height/designSize.height then
		scale = tonumber(string.format("%.2f",designSize.width/size.width))-0.01
	else
		scale = tonumber(string.format("%.2f", designSize.height/size.height))-0.01
	end
	local render = cc.RenderTexture:create(size.width * scale,size.height * scale)
	sp:setScale(scale)
	sp:setPosition(size.width * (scale / 2), size.height * (scale / 2))
	render:begin()
	sp:visit()
	render:endToLua()
	render:retain()
	local pngPath = cc.FileUtils:getInstance():getWritablePath().."/PICTURE"..os.time()..".png"
	render:saveToFile("PICTURE"..os.time()..".png", cc.IMAGE_FORMAT_PNG,true)
	-- 创建文件是异步操作，需要等待创建完毕
	while not cc.FileUtils:getInstance():isFileExist(pngPath) do
		yield()
	end
	local files = ""
	local file = io.open( pngPath,"rb")
	if file then
		files = file:read("*a")
		file:close()
	else
		print "没有找到文件"
		return nil
	end
	-- 读取文件是异步操作，需要等待读取完毕
	while files == "" do
		yield()
	end
	go(
		function()
			-- 异步删除文件
			cc.FileUtils:getInstance():removeFile(pngPath)
		end
	)
	render:release()
	require("hall.src.common.ZZBase64")
	return ZZBase64.encode(files)
end
-- 判断某个资源是否存在
function Tools.FileIsBeing(FileName)
    local f = io.open(FileName,"r")

	if(f == nil )then
		return false
	end
    f:close()
	return true
end

--重置屏幕宽高
function Tools.ResetWidthHeight()
	Def.visibleSize			=	cc.Director:getInstance():getVisibleSize()
	Def.ScaleX				=	Def.visibleSize.width / Def.DesignedX
	Def.ScaleY				=	Def.visibleSize.height / Def.DesignedY
	Def.ScaleMax			=   math.max(Def.ScaleX, Def.ScaleY)
	Def.ScaleMin			=   math.min(Def.ScaleX, Def.ScaleY)

	if Device.currentScreenType == const_game.V_Screen_Type then
        Tools_Base.DesignedX, Tools_Base.DesignedY =	Def.DesignedY, Def.DesignedX
	else
        Tools_Base.DesignedX, Tools_Base.DesignedY =	Def.DesignedX, Def.DesignedY
	end
	Tools_Base.visibleSize =	cc.Director:getInstance():getVisibleSize()
	Tools_Base.ScaleX				=	Tools_Base.visibleSize.width / Tools_Base.DesignedX
	Tools_Base.ScaleY				=	Tools_Base.visibleSize.height / Tools_Base.DesignedY
	Tools_Base.ScaleMax				=   math.max(Tools_Base.ScaleX, Tools_Base.ScaleY)
	Tools_Base.ScaleMin				=   math.min(Tools_Base.ScaleX, Tools_Base.ScaleY)

	PopLayer:ResetRoot()
end

function Tools.AdjustBg(bgNode)
    local DesignedX			=	1280.0
    local DesignedY			=	720.0
    local visibleSize			=	cc.Director:getInstance():getVisibleSize()
    local ScaleX				=	visibleSize.width / DesignedX
    local ScaleY				=	visibleSize.height / DesignedY
    local ScaleMax				=   math.max(ScaleX, ScaleY)
    local ScaleMin				=   math.min(ScaleX, ScaleY)
    bgNode:setScale(ScaleMax)
end

function Tools.AdjustCenter(centerNode)
    local DesignedX			=	1280.0
    local DesignedY			=	720.0
    local visibleSize			=	cc.Director:getInstance():getVisibleSize()
    local ScaleX				=	visibleSize.width / DesignedX
    local ScaleY				=	visibleSize.height / DesignedY
    local ScaleMax				=   math.max(ScaleX, ScaleY)
    local ScaleMin				=   math.min(ScaleX, ScaleY)
    centerNode:setScale(ScaleMin)
end

--数字添加逗号 效果 100000 -> 100,000
function Tools.ShuZiAddDouHao(num)
	if num - math.floor(num) > 0 then
		print("数字不能有小数!!!",num)
		num = math.floor(num)
	end
	local nums = tostring(num)
	local strCoin = ""
	local len = #nums
	local index = 1
	for i = len,1,-1 do
		strCoin = string.sub(nums,i,i)..strCoin --截取字符串
		if(index %3 == 0 and index ~= len)then
			strCoin = ","..strCoin
		end
		index = index + 1
	end
	return strCoin
end

--数字转字符串 并根据情况添加逗号、点等符号(大厅用)
function Tools.CoinToShowString(num)
	local is_positive = false
	if num < 0 then
		num = -num
		is_positive = true
	end


	local strNum = tostring(num / sGameManager.exchangerate)
	local weishu = 0
	if Def.NotEffectiveDecimal == 0 then
		local curExchangerate = sGameManager.exchangerate
		while curExchangerate >= 10 do
			curExchangerate = curExchangerate / 10
			weishu = weishu + 1
		end
	end
	strNum = Tools.NumberFormat(strNum,weishu)
	--是否需要显示逗号(0:需要，1:不需要)
	if (Def.Comma_Or_Not == 0) then
		local douhao_str = ""
		local xiaoshu_str = ""
		local is = false
		for i = 1, #strNum do
			if is then
				xiaoshu_str = xiaoshu_str .. string.sub(strNum,i,i)
			else
				if string.sub(strNum,i,i) == "." then
					is = true
					xiaoshu_str = xiaoshu_str .. "."
				else
					douhao_str = douhao_str .. string.sub(strNum,i,i)
				end
			end
		end
		if #douhao_str > 0 then
			douhao_str = Tools.ShuZiAddDouHao(douhao_str)
			strNum = douhao_str .. xiaoshu_str
		end
	end

	if is_positive then
		strNum = "-" .. strNum
	end
	return strNum
end

function Tools.NumberFormat(num,digits)
    if type(num) ~= "number" then
        num = tonumber(num)
    end
    digits = digits or 0
    digits = math.floor(digits)
    if digits < 0 then
        digits = 0
    end
    local nDecimal = 10 ^ digits
    local nTemp = math.floor(num * nDecimal)
    local nRet = nTemp / nDecimal
	local format = "%." .. string.format("%d",digits) .. "f"
	nRet = string.format(format,tostring(nRet))
    return nRet;
end

-- 获取小数位数
function Tools.GetDecimalCount(exchangerate)
	local count = 0
	while exchangerate >= 10 do
		exchangerate = exchangerate / 10
		count = count + 1
	end
	return count
end

function Tools.GetLotteryMoneyStr(num)
	local forceInt = ( Def.NotEffectiveDecimal == 1 )
	local decimalCnt
	if sGameManager.UseBetRate() then
		num = num / sGameManager.exchangerate
		decimalCnt = 2
	else
		if Def.NotEffectiveDecimal == 1 then
			decimalCnt = 0
		else
			decimalCnt = Tools.GetDecimalCount(sGameManager.exchangerate)
		end
	end
	return Tools.FormatNumber(num, decimalCnt)
end

--数字转字符串 并根据情况添加逗号、点等符号(老虎机用)
function Tools.ShuZi_Exchangerate(num, isBYX)
	--isBYX 为 true 	1.010 -> 1.010
	--isBYX 为 false 	1.010 -> 1.01
	--是否 不保留有效小数位
	---1.5留的坑

	num = num / sGameManager.exchangerate
	local decimalCnt
	-- 是否为显示有效小数模式(0:是，1:否)
	if isBYX then
		decimalCnt = Tools.GetDecimalCount(sGameManager.exchangerate)
	else
		decimalCnt = -1
	end

	return Tools.FormatNumber(num, decimalCnt)
end

-- 格式化 数字, decimalCnt 小数点位数: < 0 就用默认的 %f
function Tools.FormatNumber(num, decimalCnt)
	local fmt
	if decimalCnt < 0 then
		fmt = "%f"
	elseif decimalCnt == 0 then
		fmt = "%d"
	else
		fmt = "%." .. string.format("%d", decimalCnt) .. "f"
	end

	local strNum = string.format(fmt, num)

	--是否需要显示逗号(0:需要，1:不需要)
	if Def.Comma_Or_Not == 0 then
		local douhao_str = ""
		local xiaoshu_str = ""
		local is = false
		for i = 1, #strNum do
			if is then
				xiaoshu_str = xiaoshu_str .. string.sub(strNum,i,i)
			else
				if string.sub(strNum,i,i) == "." then
					is = true
					xiaoshu_str = xiaoshu_str .. "."
				else
					douhao_str = douhao_str .. string.sub(strNum,i,i)
				end
			end
		end
		if #douhao_str > 0 then
			douhao_str = Tools.ShuZiAddDouHao(douhao_str)
			strNum = douhao_str .. xiaoshu_str
		end
	end

	return strNum
end

-- 字符串转数字 去掉逗号(确保是个数字字符串，错误不管)
function Tools.string_Exchangerate(str)
	local strTab = str:split(",")
	local num = ""
	for i = 1, #strTab do
		num = num .. strTab[i]
	end
	if tonumber(num) ~= nil then
		return tonumber(num) * sGameManager.exchangerate
	else
		return 0
	end
end

--数字转字符串 砍一刀功能用
function Tools.NumberAutoExchange(number, forceInteger)
    number = number / sGameManager.exchangerate

    local formatted
    if forceInteger then
        formatted = string.format("%d", number)
    else
        formatted = string.format("%f", number)
    end

    -- 去除尾部0
    -- 1.0 -> 1
    formatted = string.gsub(formatted, "%.0+$", "")
    if string.find(formatted, "%.") then
        -- 保留三位有效小数位
        -- 1.123456 -> 1.123
        formatted = string.gsub(formatted, "(%.%d%d%d)(%d+)$", "%1")

        -- 去除尾部0
        -- 1.230 -> 1.23
        formatted = string.gsub(formatted, "0+$", "")
        -- 去除尾部.
        -- 0. -> 0
        formatted = string.gsub(formatted, "%.$", "")
    end

    --是否需要显示逗号(0:需要，1:不需要)
    if const_def.NotEffectiveDecimal == 0 then
        local k
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then break end
        end
    end

    return formatted
end

--保留两位小数
function Tools.RemovedZero(number)
    local formatted = string.format("%0.2f", number)
    formatted = string.gsub(formatted, "%.0+$", "")
    if string.find(formatted, "%.") then
        formatted = string.gsub(formatted, "0+$", "")
        formatted = string.gsub(formatted, "%.$", "")
    end
    return formatted
end

-- 数字除汇率
function Tools.NumberToShowString(num)
	return num/sGameManager.exchangerate
end

---------------------------------------------------------
--  Recharge 下面有相应代码，hall 暂时没使用这一块。
--手机号位数判断(或者其他账号判断momo，zalo等)
-- function Tools.CheckPhone(len_)
-- end

--获取手机号长度配置
-- function Tools.GetPhoneLenth()
-- end
---------------------------------------------------------

function Tools.PushGoogleAnalyticsEvent(type_)
end

---------------------------------------------------------

-- mask:addChild(node))--node就是被遮罩裁剪的对象
-- 制作模板裁剪
-- parent：模板父节点
-- stencilPath：模板资源路径
function Tools.MakeMask(parent,stencilPath)
    --创建遮罩层
    local stencilNode = cc.Node:create()
    local stencil = ccui.ImageView:create(stencilPath)
    stencilNode:addChild(stencil)
    stencil:setAnchorPoint(cc.p(0,0))
    stencil:setPosition(cc.p(0,0))
    local mask = cc.ClippingNode:create(stencilNode)
    mask:setAnchorPoint(cc.p(0,0))
    mask:setPosition(cc.p(0,0))
    mask:setInverted(false)
    mask:setAlphaThreshold(0)
    parent:addChild(mask)
    return mask
end

----------------------------------------------------------------------

-- 上传一张相册里面的图片，并回调
-- callback (success, url, base64data)
function Tools.UploadSelectPhoto(callback)
    gUpdates_Close("PostUpdate")

    sGameManager.Image = nil
    sGameManager.ImageSize = 0
    Device:OpenAlbum()

    local call_done = function(success, url, base64data)
        gUpdates_Close("PostUpdate")
        if callback then callback(success, url, base64data) end
    end

    local PostUpdate = function()
        if sGameManager.Image == "null" then
            sGameManager.Image = nil
            sGameManager.ImageSize = nil
            call_done(false, "", nil)
            return
        end

        if sGameManager.ImageSize and sGameManager.ImageSize ~= "false" and sGameManager.Image ~= nil then
            local Image = sGameManager.Image
            local ImageSize = sGameManager.ImageSize
            sGameManager.Image = nil
            sGameManager.ImageSize = nil
            gUpdates_Close("PostUpdate")

            go(function()
                SleepSecs(0.2)

                local newfileBase64 = Tools.getSmilePicture(Image)
                if not newfileBase64 then
                    call_done(false, "", nil)
                    return
                end

                local xhr = cc.XMLHttpRequest:new()
                xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
                xhr:open("POST", sGameManager.uploadimageUrl)
                UIManager.ShowWaiting()

                local function onReadyStateChanged()
                    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then -- 成功
                        UIManager.HideWaiting()
                        if xhr.response == "1" or xhr.response == "2" then
                            UIManager.ShowToast(TR("网络异常，图片上传失败"))
                            call_done(false, "", nil)
                            return
                        end
                        print("image upload success.")
                        call_done(true, xhr.response, newfileBase64)
                    else
                        UIManager.ShowToast(TR("网络异常，正在努力上传图片~"))
                        UIManager.HideWaiting()
                    end
                    xhr:unregisterScriptHandler()
                end

                xhr:registerScriptHandler(onReadyStateChanged)

                local imgdata = {
                    ["base64"] = newfileBase64,
                    ["size"]	= #newfileBase64
                }
                xhr:send(json.encode(imgdata))
            end)
        end
    end

	gUpdates_Set("PostUpdate", PostUpdate)
end

----------------------------------------------------------------------

-- 自定义尺寸的文本框适配框改变fontsize使其不会超框
function Tools.CcuiTextIgnoreContentAdaptByFontSize(node)
	if not node or tolua.type(node) ~= "ccui.Text" or node:isIgnoreContentAdaptWithSize() then
		return
	end
	local real_size = node:getVirtualRendererSize()
	local content_size = node:getContentSize()
	local area_renderer = real_size.width*real_size.height
	local area_content = content_size.width *content_size.height
	if area_renderer>area_content then
		local font_size = node:getFontSize()
		local font_size_new = math.floor(font_size/(area_renderer/area_content))
		node:setFontSize(font_size_new)
	end
end
-- 自定义尺寸的文本框适配框改变fontsize使其不会超框
function Tools.CcuiTextIgnoreContentAdaptOneLineByFontSize(node)
	if not node or tolua.type(node) ~= "ccui.Text" or node:isIgnoreContentAdaptWithSize() then
		return
	end
	local real_size = node:getVirtualRendererSize()
	local content_size = node:getContentSize()
	local area_renderer = real_size.width*real_size.height
	local area_content = content_size.width *content_size.height
	if area_renderer>area_content then
		local font_size = node:getFontSize()
		local font_size_new = math.floor(font_size/(area_renderer/area_content))
		node:setFontSize(font_size_new)
	end
end
-- 自定义尺寸的文本框适配框改变scaleX使其不会超框
function Tools.CcuiTextIgnoreContentAdaptByScaleX(node)
	if not node or tolua.type(node) ~= "ccui.Text" or node:isIgnoreContentAdaptWithSize() then
		return
	end
	local real_size = node:getVirtualRendererSize()
	local content_size = node:getContentSize()
	local width_renderer = real_size.width
	local width_content = content_size.width
	if width_renderer>width_content then
		local scalex = width_content/width_renderer
		node:setContentSize(cc.size(width_content/scalex,content_size.height))
		node:setScaleX(scalex)
	end
end

function Tools.AddRichEdit(node)
    local richText = ccui.RichText:create()
    Tools.ReplaceNode(node, richText)
    return richText
end

-- 底层运行时 是否支持 FGUI
function Tools.IsFGUIRuntimeSupport()
	if FairyGUI or fairygui then
		return true
	else
		return false
	end
end

function Tools.AddRelativeSearchPath(rel_path)
	local search_paths = {}
	local df = cc.FileUtils:getInstance():getDefaultResourceRootPath()
	table.insert(search_paths, df .. rel_path)
	local basicPath = cc.FileUtils:getInstance():getWritablePath() .. "download/"
	table.insert(search_paths, basicPath .. rel_path)
	for _,p in ipairs(search_paths) do
		cc.FileUtils:getInstance():addSearchPath(p, true)
	end
end

local searchPaths = nil
function Tools.SaveSearchPaths()
	searchPaths = cc.FileUtils:getInstance():getSearchPaths()
end

function Tools.RestoreSearchPaths()
	if searchPaths ~= nil then
		cc.FileUtils:getInstance():setSearchPaths(searchPaths)
		searchPaths = nil
	end
end

function Tools.CoinToString(number, forceInteger)
	local region = ConfigParam.Region
	if region == "mm" or region == "vn" or region == "ind" then
		forceInteger = true
	end

	return Tools.NumberAutoExchange(number, forceInteger)
end
-- fmt( "%{%{1}} = {0} + {0}", 100, 200)
-- {200} = 100 + 100
function Tools.Fmt(format, ...)
    local args = {...}

    format = string.gsub(format, "({%d+})", function(s)
        local idx = string.match(s, "{(%d+)}")
        local arg = args[idx + 1]
        if type(arg) == "number" then
            if math.floor(arg) == arg then
                return string.format("%d", arg)
            end
            return string.format("%.3f", arg)
        end
        return tostring(arg)
    end)

    -- format = string.gsub(format, "%%{%%", "{")
    -- format = string.gsub(format, "%%}%%", "}")
    format = string.gsub(format, "\\n", "\n")

    return format
end

-- 字符串转数字 去掉逗号(确保是个数字字符串，错误不管)
function Tools.StringToNumber(str)
    -- 去掉空格
    str = string.gsub(str, " ", "")

    if str == "" then
        return "0"
    end

    str = string.gsub(str, ",", "")
	return checknumber(str) * sGameManager.exchangerate
end

function Tools.FormatTime(time)
	local year, month, day, hour, min, second, _, _  = Int64ToDateTime(time)
	local fmt = "%d-%02d-%02d %02d:%02d:%02d"
	return fmt:format(year, month, day, hour, min, second)
end

-------------------------------------------------------------------------

local function __delay_get(tbl, key)
    local value = rawget(tbl, key)
    if value ~= nil then return value end

    local loaders = rawget(tbl, "__delay_loaders")
    if not loaders then
        print("error: no __delay_loaders")
        return nil
    end
    local loader = loaders[key]
    if loader == nil then
        print("no such loader for :" .. key)
        return nil
    end
    value = loader.loader(unpack(loader.args))

    rawset(tbl, key, value)
    return value
end

function Tools.AddDelayField(tbl, key, loader, ...)
    local loaders = rawget(tbl, "__delay_loaders")
    if not loaders then
        loaders = {}
        rawset(tbl, "__delay_loaders", loaders)
    end
    loaders[key] = {
        loader = loader,
        args = { ... }
    }

    local meta = getmetatable(tbl)
    if not meta then
        meta = {}
        setmetatable(tbl, meta)
    end

    if not meta._is_delay_index then
        meta._is_delay_index = true

        local _old_index = meta.__index
        local _old_index_table = nil
        local _old_index_function = nil
        if type(_old_index) == "table" then _old_index_table = _old_index end
        if type(_old_index) == "function" then _old_index_function = _old_index end
        meta.__index = function(tbl, key)
            local v = __delay_get(tbl, key)
            if v then return v end

            if _old_index_function then
                return _old_index_function(tbl, key)
            end

            if _old_index_table then
                return _old_index_table[key]
            end
        end
    end
end

return Tools
