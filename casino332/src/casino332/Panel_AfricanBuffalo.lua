local this = {}
this.stateGroupName = "Main"
this.stateName 		= "Panel_AfricanBuffalo"	
this.opened 		= false
--通用逻辑处理
this.logic = gCasino_Common_Func.Re_Require("casino_common.src.Panel_CasinoLogic")
local AfricanBuffalo_Item = require "casino332.src.casino332.AfricanBuffalo_Item"

this.Open = function() 
	assert(not this.opened)
	print("进入casino332")
	print(type(GameData.game_id))
	this.logic.Open()
	this.InitData()
	this.InitScene()
	--杀进程恢复
	if sGameManager.NetRestoreCasino == true then
		this.HandleReconnectByBroke(sGameManager.NetRestoreCasinoRlt)
		--重连包相关数据清空
		--断线重连需要刷新界面的标识位
		sGameManager.NetRestoreCasino = false
		--断线重连刷新的回包(用于刷新游戏界面)
		sGameManager.NetRestoreCasinoRlt = nil
	end
	Casino_soundFunc.PlayBackMusic(Casino_Func.GetCasinoSound(4))	--ngbgm.mp3
	--每个游戏特有处理
	gUpdates_Set("AfricanBuffaloGameUpdate", this.AfricanBuffaloGameUpdate)
	this.opened = true
end
this.Close = function()
	assert(this.opened)

	gUpdates_Close("AfricanBuffaloGameUpdate")
	this.opened = false
	print("casino332退出")
	this.logic.Close()
end
--数据初始化
this.InitData = function ()
	--初始化一些自定义的数据
	this.FGTimes = 0 --免费游戏轮数
	this.coinNum = 0
	this.cellIndex = 1
	this.fg_board = nil
	this.upFreegame_Text = nil

	this.logic.SpinCasinoCallBack = this.SpinCasinoCallBack
	this.logic.NormalEndSpinAnim = this.NormalEndSpinAnim
	this.logic.HandleCasinoSpin_Normal = this.HandleCasinoSpin_Normal
	this.logic.HandleCasinoSpin_Free = this.HandleCasinoSpin_Free
	this.logic.CellStop = this.CellStop
	this.logic.ArrangeWinData = this.ArrangeWinData
	this.logic.ResultAnimation = this.ResultAnimation
	this.logic.SubGameWinCoinAnim = this.SubGameWinCoinAnim
	this.logic.SpecialGameDecide = this.SpecialGameDecide
	this.logic.FreeTimeDecide = this.FreeTimeDecide
	this.logic.FreeGameEnterAnim = this.FreeGameEnterAnim
	this.logic.FreeEndSpinAnim = this.FreeEndSpinAnim
	this.logic.FreeGameEndAnim = this.FreeGameEndAnim

	this.logic.HandleDuanXianChongLian_Initial = this.HandleDuanXianChongLian_Initial
	this.logic.HandleDuanXianChongLian_QT_Waiting = this.HandleDuanXianChongLian_Initial
	this.logic.HandleDuanXianChongLian_RequestWaiting = this.HandleDuanXianChongLian_RequestWaiting
end
--场景初始化
this.InitScene = function ()
	--游戏节点
	this.rootGame = cc.Node:create()
	this.rootGame:setPositionY(-30)
	this.logic.node_Game:addChild(this.rootGame)
	this.rootGame:setScale(1.25,0.95)
	--完全绘制节点
	this.logic.showIconSNode = cc.Node:create()
	this.logic.showIconSNode:setPositionY(-25)
	this.logic.node_Game:addChild(this.logic.showIconSNode)
	this.logic.showIconSNode:setScale(1.25,0.95)
	--免费游戏弹窗面板节点
	this.FreePanelNode = cc.Node:create()
	this.logic.node_Game:addChild(this.FreePanelNode)
	this.FreePanelNode:setScale(1.25,1)
	--计时器根节点
	this.rootTimer = cc.Node:create()
	this.logic.node_Game:addChild(this.rootTimer)
	this.rootTimer:setScale(1.25,1)
	
	--适配
	print("当前窗口宽,高:",Def_Casino.visibleSize.width,Def_Casino.visibleSize.height)
	local SCALE = Def_Casino.visibleSize.width/Def_Casino.visibleSize.height
	if SCALE == 16/9 then

	elseif SCALE == 4/3 then--暂时未做

	elseif SCALE == 2/1 then

	end
	--背景
	this.background = cc.Sprite:createWithSpriteFrameName("background.png")
	this.background:setPosition(cc.p(0,10))
	this.background:setScale(1.4)
	this.logic.node_GameBack:addChild(this.background)

	-- 背景 条 	--格子背景
	this.reelBG = cc.Sprite:createWithSpriteFrameName("reel.png")
	this.reelBG:setPosition(cc.p(0,15))
	this.rootGame:addChild(this.reelBG)
	--
	local cellPosX = {-2,-1,0,1,2}
	--创建格子
	for i = 1, 5 do
		this.logic.gameCells[i] = this.logic.GameCellCreate(AfricanBuffalo_Item,this.rootGame,cellPosX[i]*(Casino_Func.GetIconWidth()+Casino_Func.GetIconFrameSize()),13,i,4)
		this.logic.gameCells[i]:InitItem()
	end
	--格子框架
	this.column = cc.Sprite:createWithSpriteFrameName("column.png")
	this.column:setPosition(cc.p(0,15))
	this.rootGame:addChild(this.column)
end
this.HandleReconnectByBroke = function(_rlt)
	print("杀进程恢复")
	dump(_rlt)
	--恢复普通游戏显示结果
	if _rlt.type == 1 then
		print("普通游戏杀进程重连恢复...")
		this.resumeFinalResult(_rlt.resumedNormal)
		this.resumeTipsBox(_rlt.currentWinCoin)
		if _rlt.resumedNormal.FreeTime > 0 then
			print("进入免费游戏选择界面")
			this.resumeFreeSelectPanel(_rlt.resumedNormal)
		else
			Casino_soundFunc.PlayBackMusic(Casino_Func.GetCasinoSound(4))	--ngbgm.mp3
			this.logic.ChongLian_Initial_Normal()
		end
	--恢复免费游戏显示结果
	elseif _rlt.type == 2 then
		print("恢复免费游戏显示结果")
		this.resumeFinalResult(_rlt.resumedFreeRet)
		--当前次数								--总次数
		if _rlt.resumedFreeRet.totalCount < _rlt.resumedFreeRet.allCount then
			--更换免费游戏背景
			this.background:setSpriteFrame("background_fg.png")
			this.logic.SwitchFreeGameMode()
			this.resumeFreeUI(_rlt.resumedFreeRet.totalCount,_rlt.resumedFreeRet.allCount)
			--播放FG背景音乐--fgbgm.mp3
			Casino_soundFunc.PlayBackMusic(Casino_Func.GetCasinoSound(2))
		else
			Casino_soundFunc.PlayBackMusic(Casino_Func.GetCasinoSound(4))	--ngbgm.mp3
			print("免费次数用完...")
		end
	end
end
this.HandleDuanXianChongLian_Initial = function(_rlt)
	--恢复普通游戏显示结果
	if _rlt.type == 1 then
		print("普通游戏断线重连恢复...")
		if this.compareRlt(_rlt.resumedNormal) then
			print("Normal数据一样...")
			if _rlt.resumedNormal.FreeTime > 0 then
				print("有免费游戏但是还未开始")
				this.logic.ChongLian_Initial_FreeTime()
			else
				this.logic.ChongLian_Initial_Normal()
			end
		else
			print("数据不一样")
			this.logic.ChongLian_Initial_Normal_or(_rlt.resumedNormal)
		end
	--恢复免费游戏显示结果
	elseif _rlt.type == 2 then
		if this.compareRlt(_rlt.resumedFreeRet) then
			print("Free数据一样...")
			if _rlt.resumedFreeRet.totalCount < _rlt.resumedFreeRet.allCount then
				this.logic.ChongLian_Initial_FreeTime()
			else
				this.logic.ChongLian_Initial_Normal()
			end
		else
			print("重连包数据不一样需要选择")
			this.logic.ChongLian_Initial_FreeTime_or(_rlt.resumedFreeRet)
		end
	else
		print("服务器没有检测到客户端的任何操作")
		this.logic.ChongLian_Initial_Normal()
	end
end
this.HandleDuanXianChongLian_RequestWaiting = function (_rlt)
	if _rlt.type == 1 then--恢复普通结果
		print("重新恢复普通游戏")
		if this.compareRlt(_rlt.resumedNormal) == false then
			this.HandleDuanXianChongLian_Initial(_rlt)
			return
		end
	end
	print("再次请求旋转数据")
	this.logic.W_SendSpinPKG(Def.CasinoSpinNormal_Send)
end
--杀进程恢复进入免费游戏弹出界面
this.resumeFreeSelectPanel = function(_rlt)
	this.FGTimes = _rlt.FreeTime
	this.logic.gameState = Def_Casino.State_QT_Waiting
	--改变状态
	this.logic.gameMode = Def_Casino.Mode_FreeTime
	this.logic.typeSpin = Def_Casino.Type_Auto
	this.logic.ForbiddenBtn()
	--换部分按钮的图
	this.logic.DXCL_DisableBtn()
	this.logic.spinTimeing = 0

	this.rootTimer:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function()
		this.CreateFreePanel(1,_rlt.FreeTime)
	end),cc.DelayTime:create(4),cc.CallFunc:create(function()
		this.logic.is_FG_EnterAnim = true
	end)))
end
--恢复免费游戏UI
this.resumeFreeUI = function(usedNum,totalNum)
	this.createFreeUI(usedNum,totalNum)
end
--恢复提示框显示赢钱信息
this.resumeTipsBox = function(currentWinCoin)
	if currentWinCoin > 0 then
		this.logic.winTotalNum = currentWinCoin
		this.logic.SetWinTextVisible(true)
		this.logic.SetWinCount(this.logic.winTotalNum)
	end
end
--比较包内数据与上次结果是否一致
this.compareRlt = function(_rlt)
	for i = 1 , #_rlt.grids do
		local _rltIcon = _rlt.grids[i].icon
		local _rltIndex = _rlt.grids[i].index
		local showIcon = this.logic.gameCells[this.getIndex_Cell(_rltIndex)].lastSymbolIdTuData[this.getIndex_IconInCell(_rltIndex)].icon
		print("_rltIcon : showIcon  =",_rltIcon,showIcon)
		if _rltIcon ~= showIcon then
			return false
		end
	end
	return true
end
--恢复图标最终结果显示
this.resumeFinalResult = function(_rlt)
	for i=1,#_rlt.grids do
		local icon = _rlt.grids[i].icon
		local index = _rlt.grids[i].index
		print("下标: " , index,"图标: " , icon)
		this.logic.gameCells[this.getIndex_Cell(index)]:SetLastSymbolIdTuData(this.getIndex_IconInCell(index),icon)
	end
	for i=1,5 do
		for j=1,4 do
			this.logic.gameCells[i].showTuData[j] = this.logic.gameCells[i]:LocalTableTuData(this.logic.gameCells[i].lastSymbolIdTuData[j])
		end
		this.logic.gameCells[i]:Show()
	end
end
--旋转之前 清除一些UI
this.SpinCasinoCallBack = function()
	Casino_soundFunc.StopAllEffects()
end
--格子停止处理
this.CellStop = function ()
	local scatter_Count = 0
	local ox_Count = 0
	for i = 1, #this.logic.gameCells do
		if this.logic.gameState == Def_Casino.State_RunSpin then
			for j = 1, #this.logic.gameCells[i].lastSymbolIdTuData do
				if this.logic.gameCells[i].lastSymbolIdTuData[j].icon == AfricanBuffalo_Item.iconData.scatter_icon then
					if i == 5 and scatter_Count == 1 then
						break
					end
					scatter_Count = scatter_Count + 1
					break
				end
				if i == 1 or i == 2 then
					if this.logic.gameCells[i].lastSymbolIdTuData[j].icon == AfricanBuffalo_Item.iconData.ox_icon or 
						this.logic.gameCells[i].lastSymbolIdTuData[j].icon == AfricanBuffalo_Item.iconData.wild_icon then
						ox_Count = ox_Count + 1
						break
					end
				end
			end
			if scatter_Count >= 2 or ox_Count >= 2 then
				break
			end
		end
		this.logic.gameCells[i]:Stop()
	end
	return true
end
--通过图标下标(0-19),获取在对应游戏转轮格子里的图标下标号
this.getIndex_IconInCell = function(index)
	local iconIndex = 1 
	if index >= 5 and index < 10 then
		iconIndex = 2
	elseif index >= 10 and index < 15 then
		iconIndex = 3
	elseif index >= 15 and index < 20 then
		iconIndex = 4
	end
	return iconIndex
end
--通过图标下标(0-19),获取在对应游戏转轮格子号(1-5)
this.getIndex_Cell = function(index)
	local _index = index%5 +1
	return _index
end
--通过图标号获取对应精灵
this.getSprite_ByIcon = function(icon)
	local spriteTem = cc.Sprite:createWithSpriteFrameName(Casino_Func.GetIconPicIdData(Def_Casino.Icon_Type,icon))
	return spriteTem
end
--通过图标号获取对应动画
this.getAnim_ByIcon = function(icon,index)
	local anim = nil 
	if icon == AfricanBuffalo_Item.iconData.wild_icon then
		anim = sp.SkeletonAnimation:createWithJsonFile("casino332/newres/spine/Wild.json","casino332/newres/spine/Wild.atlas",1)
		anim:setOpacityModifyRGB(true)
		if this.logic.gameMode == Def_Casino.Mode_Normal then
			anim:setAnimation(0,"Wild_Loop",true)
		elseif this.logic.gameMode == Def_Casino.Mode_FreeTime then
			local wildbet = this.logic.rcvSpinData.grids[index+1].wildbet
			anim:setAnimation(0,string.format("Wild_Loopx%d",wildbet),true)
		end
	elseif icon == AfricanBuffalo_Item.iconData.scatter_icon then
		anim = sp.SkeletonAnimation:createWithJsonFile("casino332/newres/spine/Scatter.json","casino332/newres/spine/Scatter.atlas",1)
		anim:setOpacityModifyRGB(true)
		anim:setAnimation(0,"Scatter_Loop",true)
	elseif icon == AfricanBuffalo_Item.iconData.ox_icon then
		anim = sp.SkeletonAnimation:createWithJsonFile("casino332/newres/spine/H1.json","casino332/newres/spine/H1.atlas",1)
		anim:setOpacityModifyRGB(true)
		anim:setAnimation(0,"H1",true)
	else
		anim = cc.Sprite:createWithSpriteFrameName(Casino_Func.GetIconPicIdData(Def_Casino.Icon_Type,icon))
		anim:runAction(cc.RepeatForever:create(cc.Blink:create(2,2)))
	end
	return anim 
end
--获取特效框
this.getAnim_EffectFrame = function()
	local effectFrame = sp.SkeletonAnimation:createWithJsonFile("casino332/newres/spine/YingFenKuang.json","casino332/newres/spine/YingFenKuang.atlas",1)
	effectFrame:setOpacityModifyRGB(true)
	effectFrame:setAnimation(0,"YingFenKuang",true)
	return effectFrame
end
this.NormalEndSpinAnim = function()
	local resultLine = this.logic.rcvSpinData.lines
	dump(resultLine)
	local time = 0 
	local playEffect_H1 = false
	for i = 1, #resultLine do
		--有牛中奖,且中奖个数>=3
		if resultLine[i].lineIndex == AfricanBuffalo_Item.iconData.ox_icon and #resultLine[i].lineCells >= 3 then
			for j = 1,#resultLine[i].lineCells do
				local icon = resultLine[i].lineCells[j].icon
				local index = resultLine[i].lineCells[j].index
				if this.getIndex_Cell(index) > 2 then
					playEffect_H1 = true
					time = 3
					break
				end
			end
			if time >= 3 then
				for j=1,#resultLine[i].lineCells do
					local icon = resultLine[i].lineCells[j].icon
					local index = resultLine[i].lineCells[j].index
					if icon == AfricanBuffalo_Item.iconData.ox_icon then
						local spriteTem = sp.SkeletonAnimation:createWithJsonFile("casino332/newres/spine/H1.json","casino332/newres/spine/H1.atlas",1)
						spriteTem:setOpacityModifyRGB(true)
						spriteTem:setAnimation(0,"H1",true)
						this.logic.gameCells[this.getIndex_Cell(index)]:ReplaceSprite(spriteTem,this.getIndex_IconInCell(index),4)
					end
					if icon == AfricanBuffalo_Item.iconData.wild_icon then
						local spriteTem = sp.SkeletonAnimation:createWithJsonFile("casino332/newres/spine/Wild.json","casino332/newres/spine/Wild.atlas",1)
						spriteTem:setOpacityModifyRGB(true)
						spriteTem:setAnimation(0,"Wild_Loop",true)
						this.logic.gameCells[this.getIndex_Cell(index)]:ReplaceSprite(spriteTem,this.getIndex_IconInCell(index),4)
					end
				end
			end
		end
		if resultLine[i].lineIndex == 2 then
			playEffect_H1 = false
			Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(13))	--triggering.mp3
			if time == 0 then
				time = 2
			end
		end
	end
	if playEffect_H1 then
		Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(5)) --H1.mp3
	end
	this.rootTimer:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
		this.logic.is_SingleEndAnim = true
	end)))
end
--判断表中是否含有某个值
this.IsInTable =function (value, table)
	for k,v in ipairs(table) do
		if v == value then
			return true; 
		end
	end
	return false;
end
this.addWildTable = function(index)
	local wildTable = {{},{},{},{},{}}

	local cellIndex = this.getIndex_Cell(index)
	if not this.IsInTable(index,wildTable[cellIndex]) then
		wildTable[cellIndex][ #wildTable[cellIndex]+1 ] = index
		table.sort(wildTable[cellIndex])
	end
end
this.FreeEndSpinAnim = function()
	local time = 0 
	local resultLine = this.logic.rcvSpinData.lines
	dump(resultLine)
	--加次数
	if this.logic.rcvSpinData.newFreeTime > 0 then
		time = time + 3
		Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(13))	--triggering.mp3
		this.rootTimer:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
			this.CreateFreePanel(2,this.logic.rcvSpinData.newFreeTime,0)
		end)))
		time = time + 3
	end
	local playEffect_H1 = false
	local judge = false
	local wildNum = 0
	local wildTable = {{},{},{},{},{}}
	for i = 1, #resultLine do
		--替换列表
		for j=1,#resultLine[i].lineCells do
			local icon = resultLine[i].lineCells[j].icon
			local index = resultLine[i].lineCells[j].index
			local wildbet = resultLine[i].lineCells[j].wildbet
			if icon == AfricanBuffalo_Item.iconData.wild_icon then
				judge = true
				local cellIndex = this.getIndex_Cell(index)
				if not this.IsInTable(index,wildTable[cellIndex]) then
					wildTable[cellIndex][ #wildTable[cellIndex]+1 ] = index
					table.sort(wildTable[cellIndex])
				end
			end
		end
		--有牛中奖,且中奖个数>=3
		if resultLine[i].lineIndex == AfricanBuffalo_Item.iconData.ox_icon and #resultLine[i].lineCells >= 3 then
			for j = 1,#resultLine[i].lineCells do
				local icon = resultLine[i].lineCells[j].icon
				local index = resultLine[i].lineCells[j].index
				if this.getIndex_Cell(index) > 2 then
					judge = true
					playEffect_H1 = true
					break
				end
			end
			if judge then
				for j=1,#resultLine[i].lineCells do
					local icon = resultLine[i].lineCells[j].icon
					local index = resultLine[i].lineCells[j].index
					if icon == AfricanBuffalo_Item.iconData.ox_icon then
						this.rootTimer:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
							local spriteTem = sp.SkeletonAnimation:createWithJsonFile("casino332/newres/spine/H1.json","casino332/newres/spine/H1.atlas",1)
							spriteTem:setOpacityModifyRGB(true)
							spriteTem:setAnimation(0,"H1",true)
							this.logic.gameCells[this.getIndex_Cell(index)]:ReplaceSprite(spriteTem,this.getIndex_IconInCell(index),4)
						end)))
					end
				end
			end
		end
	end
	--有替换中奖,翻倍数
	for i=1,#wildTable do
		for j=1,#wildTable[i] do
			local index = wildTable[i][j]
			local wildbet = this.logic.rcvSpinData.grids[index+1].wildbet
			local spriteTem = sp.SkeletonAnimation:createWithJsonFile("casino332/newres/spine/Wild.json","casino332/newres/spine/Wild.atlas",1)
			spriteTem:setOpacityModifyRGB(true)
			spriteTem:setAnimation(0,"Wild_Loop",true)
			this.logic.gameCells[this.getIndex_Cell(index)]:ReplaceSprite(spriteTem,this.getIndex_IconInCell(index),4)
			this.rootTimer:runAction(cc.Sequence:create(cc.DelayTime:create(time+wildNum*3),cc.CallFunc:create(function()
				spriteTem:setAnimation(0,string.format("Wild_Introx%d",wildbet),true)
				Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(14)) 	--wild.mp3
			end)))
			wildNum = wildNum + 1
		end
	end
	if playEffect_H1 then
		Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(5)) --H1.mp3
	end
	if judge then
		time = time + 3
	end
	if wildNum > 0 then
		time = time + (wildNum-1)*3
	end
	print("***********wildNum",wildNum*3,time)
	this.rootTimer:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
		this.logic.is_FG_SingleEndAnim = true
	end)))
end
--根据赢钱倍数来选择播放中奖音乐
this.playWinEffect = function(curBet,curWin)
	if curBet < curWin then
		Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(15)) 	--win_a.mp3
	elseif curBet >= curWin and curBet < curWin*2 then
		Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(16)) 	--win_b.mp3
	elseif curBet >= curWin*2 and curBet < curWin*3 then
		Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(17)) 	--win_c.mp3
	elseif curBet >= curWin*3 and curBet < curWin*4 then
		Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(18)) 	--win_d.mp3
	end
end
this.SpecialGameDecide = function ()
	return false
end
this.SubGameWinCoinAnim = function ()
	this.logic.isSubGameWinCoinAnimEnd = true
end
--获取中奖数据
this.ArrangeWinData = function (rlt_)
	print("当前服务器发来的赢钱：" .. rlt_.winCoin)
	local resultLine = rlt_.lines
	print("#resultLine",#resultLine)
	for i = 1, #resultLine do
		this.logic.winOneTimeNum = this.logic.winOneTimeNum + resultLine[i].winCoin
		this.logic.winLinesArray[i] 			= {}
		this.logic.winLinesArray[i].icon 		= resultLine[i].icon
		this.logic.winLinesArray[i].lineIndex 	= resultLine[i].lineIndex
		this.logic.winLinesArray[i].winCoin 	= resultLine[i].winCoin
		this.logic.winLinesArray[i].points 		= {}
		for j = 1, #resultLine[i].lineCells do
			this.logic.winLinesArray[i].points[j] 		= {}
			this.logic.winLinesArray[i].points[j].index	= resultLine[i].lineCells[j].index
			this.logic.winLinesArray[i].points[j].icon 	= resultLine[i].lineCells[j].icon
		end
	end
end
--结算动画
this.ResultAnimation = function (winData,first,AllData)
	--只有一条中奖线
	if first == Def_Casino.DrawWinLines_1 then
		for i = 1, #winData.points do
			local icon = winData.points[i].icon
			local index = winData.points[i].index
			local zOrder = 4
			if icon == AfricanBuffalo_Item.iconData.scatter_icon then 
				zOrder = 5 
			end
			local spriteTem = this.getAnim_ByIcon(icon,index)
			
			if icon ~= AfricanBuffalo_Item.iconData.ox_icon and icon ~= AfricanBuffalo_Item.iconData.wild_icon then
				this.logic.gameCells[this.getIndex_Cell(index)]:ReplaceSprite(spriteTem,this.getIndex_IconInCell(index),zOrder)
			end
			if icon ~= AfricanBuffalo_Item.iconData.scatter_icon then
				this.logic.gameCells[this.getIndex_Cell(index)]:AddTeXiaoKuang(this.getIndex_IconInCell(index),zOrder)
			end
		end
		--播放中奖音乐
		this.playWinEffect(this.logic.curBet,this.logic.winOneTimeNum)
		this.logic.SetMessage(Def_Casino.BottomMessage_4,winData.winCoin,winData.lineIndex)
	--有多条中奖线且第一次播放动画(第一次播放,可以处理中奖音效等)
	elseif first == Def_Casino.DrawWinLines_2 then
		for i = 1, #winData do
			for j = 1, #winData[i].points do
				local icon = winData[i].points[j].icon
				local index = winData[i].points[j].index
				local zOrder = 4
				if icon == AfricanBuffalo_Item.iconData.scatter_icon then 
					zOrder = 5 
				end
				local spriteTem = this.getAnim_ByIcon(icon,index)
				if icon ~= AfricanBuffalo_Item.iconData.ox_icon and icon ~= AfricanBuffalo_Item.iconData.wild_icon then
					this.logic.gameCells[this.getIndex_Cell(index)]:ReplaceSprite(spriteTem,this.getIndex_IconInCell(index),zOrder)
				end
				if icon ~= AfricanBuffalo_Item.iconData.scatter_icon then
					this.logic.gameCells[this.getIndex_Cell(index)]:AddTeXiaoKuang(this.getIndex_IconInCell(index),zOrder)
				end
			end
		end
		--播放中奖音乐
		this.playWinEffect(this.logic.curBet,this.logic.winOneTimeNum)
	--有多条中奖线且非第一次播放动画(循环播放)
	elseif first == Def_Casino.DrawWinLines_3 then
		for xb = 1, #AllData do
			for i = 1, #AllData[xb].points do
				local icon = AllData[xb].points[i].icon
				local index = AllData[xb].points[i].index
				local zorder = 4
				local spriteTem = this.getSprite_ByIcon(icon)
				if icon ~= AfricanBuffalo_Item.iconData.ox_icon and icon ~= AfricanBuffalo_Item.iconData.wild_icon then
					this.logic.gameCells[this.getIndex_Cell(index)]:ReplaceSprite(spriteTem,this.getIndex_IconInCell(index),zorder)
				end
				this.logic.gameCells[this.getIndex_Cell(index)]:DeleteTeXiaoKuang(this.getIndex_IconInCell(index))
			end
		end
		for i = 1, #winData.points do
			local icon = winData.points[i].icon
			local index = winData.points[i].index
			local zorder = 4
			local spriteTem = this.getAnim_ByIcon(icon,index)
			if icon ~= AfricanBuffalo_Item.iconData.ox_icon and icon ~= AfricanBuffalo_Item.iconData.wild_icon then
				this.logic.gameCells[this.getIndex_Cell(index)]:ReplaceSprite(spriteTem,this.getIndex_IconInCell(index),zorder)
			end
			if icon ~= AfricanBuffalo_Item.iconData.scatter_icon then
				this.logic.gameCells[this.getIndex_Cell(index)]:AddTeXiaoKuang(this.getIndex_IconInCell(index),zorder)
			end
		end
		local index = this.logic.winLinesArrayIndex
		if this.logic.winLinesArray[index].winCoin > 0 then
			this.logic.SetMessage(Def_Casino.BottomMessage_4,winData.winCoin,winData.lineIndex)
		end
	end
end
--处理Normal旋转数据
this.HandleCasinoSpin_Normal = function()
	dump(this.logic.rcvSpinData)
	print("收到casino332_Normal的回包,开始读取数据...")
	print("winCoin",this.logic.rcvSpinData.winCoin)
	print("bet",this.logic.rcvSpinData.bet)
	print("====================Normal显示图结果为====================")
	for i = 1, #this.logic.rcvSpinData.grids do
		print("下标: " , this.logic.rcvSpinData.grids[i].index,"图标: " , this.logic.rcvSpinData.grids[i].icon) --index : 0-14
		local icon = this.logic.rcvSpinData.grids[i].icon
		local iconIndex = this.logic.rcvSpinData.grids[i].index
		this.logic.gameCells[this.getIndex_Cell(iconIndex)]:SetLastSymbolIdTuData(this.getIndex_IconInCell(iconIndex),icon)
	end
	this.logic.spiningCellNums = 5
	this.logic.gameState = Def_Casino.State_StartSpin
end
this.HandleCasinoSpin_Free = function()
	dump(this.logic.rcvSpinData)
	print("收到casino332_Free的回包,开始读取数据...")
	print("bonusWinCoin",this.logic.rcvSpinData.bonusWinCoin)
	print("winCoin",this.logic.rcvSpinData.winCoin)
	print("bet",this.logic.rcvSpinData.bet)
	print("FG运行次数:totalCount",this.logic.rcvSpinData.totalCount)
	print("FG总次数:allCount",this.logic.rcvSpinData.allCount)
	print("====================Free显示图结果为====================")
	for i = 1, #this.logic.rcvSpinData.grids do
		print("下标: " , this.logic.rcvSpinData.grids[i].index,"图标: " , this.logic.rcvSpinData.grids[i].icon) --index : 0-14
		local icon = this.logic.rcvSpinData.grids[i].icon
		local iconIndex = this.logic.rcvSpinData.grids[i].index
		this.logic.gameCells[this.getIndex_Cell(iconIndex)]:SetLastSymbolIdTuData(this.getIndex_IconInCell(iconIndex),icon)
	end
	this.logic.freeGameUsedNum = this.logic.freeGameUsedNum + 1
	--this.logic.freeGameTotalNum = this.logic.rcvSpinData.allCount
	this.upFreegame_Text:setString(string.format("%d/%d",this.logic.freeGameUsedNum,this.logic.freeGameTotalNum))

	this.logic.spiningCellNums = 5
	this.logic.gameState = Def_Casino.State_StartSpin
end
--特殊游戏(重写logic)
this.FreeTimeDecide = function ()
	if this.logic.gameMode == Def_Casino.Mode_Normal then
		if this.logic.rcvSpinData.intoFree == 1 then	--可以进入免费游戏--测
			this.FGTimes = this.FGTimes +1
			return Def_Casino.FreeTimeState_Enter
		end		
	elseif this.logic.gameMode == Def_Casino.Mode_FreeTime then
		print("this.logic.freeGameUsedNum(1):",this.logic.freeGameUsedNum)
		--退出免费游戏 
		if this.logic.freeGameUsedNum == this.logic.freeGameTotalNum then
			print("免费游戏游戏结束...")
			return Def_Casino.FreeTimeState_Over
		end
	end
	return false
end
--免费游戏入场动画
this.FreeGameEnterAnim = function()
	this.rootTimer:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
		this.CreateFreePanel(1,this.logic.rcvSpinData.FreeTime)
	end),cc.DelayTime:create(4),cc.CallFunc:create(function()
		this.logic.is_FG_EnterAnim = true
	end)))
end
--免费游戏结算动画
this.FreeGameEndAnim = function()
	this.rootTimer:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
		this.CreateFreePanel(3,this.logic.rcvSpinData.allCount,this.logic.rcvSpinData.bonusWinCoin)
	end),cc.DelayTime:create(3),cc.CallFunc:create(function()
		this.clearFreeUI()
	end),cc.DelayTime:create(1),cc.CallFunc:create(function()
		this.logic.is_FG_EndAnim = true
	end)))
end
--免费游戏UI   this.logic.freeGameUsedNum / this.logic.freeGameTotalNum
this.createFreeUI = function(usedNum,totalNum)
	this.logic.freeGameUsedNum = usedNum or 0
	this.logic.freeGameTotalNum = totalNum or 0
	local text = this.logic.freeGameUsedNum.."/"..this.logic.freeGameTotalNum

	this.fg_board = cc.Sprite:createWithSpriteFrameName("fg_board.png")
	this.fg_board:setPosition(0,-720/3-22)
	this.FreePanelNode:addChild(this.fg_board)

	local size = this.fg_board:getContentSize()

	local free_game_EN = cc.Sprite:createWithSpriteFrameName("free_game_EN.png")
	free_game_EN:setPosition(size.width*1.15/3,size.height/2+5)
	this.fg_board:addChild(free_game_EN)

	this.upFreegame_Text = cc.Label:createWithBMFont("casino332/newres/fnt/fg_num.fnt",text,0)
	this.upFreegame_Text:setPosition(size.width*2.1/3,size.height/2+5)
	this.fg_board:addChild(this.upFreegame_Text)
end
--清除免费游戏UI
this.clearFreeUI = function()
	if this.fg_board ~= nil then
		this.fg_board:removeFromParent()
		this.fg_board = nil 
	end
end
--创建免费游戏相关面板		  --面板类型,游戏局数,总赢分
this.CreateFreePanel = function(panelType,num,totalwin)
	local shadowPic = cc.Sprite:createWithSpriteFrameName("prompt_bg.png")
	this.FreePanelNode:addChild(shadowPic)
	--赢得免费游戏面板
	if panelType == 1 then
		--fgbegin.mp3
		Casino_soundFunc.PlayBackMusic(Casino_Func.GetCasinoSound(1))
		this.rootTimer:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
			Casino_soundFunc.StopBackMusic()
		end))) 
		--更换免费游戏背景
		this.background:setSpriteFrame("background_fg.png")

		local pop_board = cc.Sprite:createWithSpriteFrameName("pop_board.png")
		this.FreePanelNode:addChild(pop_board)

		local size = pop_board:getContentSize()

		local pop_free_back = cc.Sprite:createWithSpriteFrameName("pop_free_back.png")
		pop_free_back:setPosition(size.width/2,size.height*4/7)
		pop_board:addChild(pop_free_back)

		local freeCounts = cc.Sprite:createWithSpriteFrameName(string.format("normal_%d.png",num))
		freeCounts:setPosition(size.width/2,size.height*4/9)
		pop_board:addChild(freeCounts)

		local pop_congratulation_EN = cc.Sprite:createWithSpriteFrameName("pop_congratulation_EN.png")
		pop_congratulation_EN:setPosition(size.width/2,size.height*5.05/6)
		pop_board:addChild(pop_congratulation_EN)

		local pop_you_win_EN = cc.Sprite:createWithSpriteFrameName("pop_you_win_EN.png")
		pop_you_win_EN:setPosition(size.width/2,size.height*4.9/7)
		pop_board:addChild(pop_you_win_EN)

		local pop_free_game_EN = cc.Sprite:createWithSpriteFrameName("pop_free_game_EN.png")
		pop_free_game_EN:setPosition(size.width*0.87/2,size.height/6)
		pop_board:addChild(pop_free_game_EN)

		pop_board:setScale(0.01)
		pop_board:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.8,0.85)),
		cc.DelayTime:create(2),cc.CallFunc:create(function ()
			--fgbgm.mp3
			Casino_soundFunc.PlayBackMusic(Casino_Func.GetCasinoSound(2))
			pop_board:removeFromParent()
			shadowPic:removeFromParent()
			this.createFreeUI(0,num)
		end)))
	--免费增加次数面板
	elseif panelType == 2 then
		--MapFG.mp3
		Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(19))

		local pop_add_board = cc.Sprite:createWithSpriteFrameName("pop_add_board.png")
		this.FreePanelNode:addChild(pop_add_board)

		local size = pop_add_board:getContentSize()

		local add_you_win_EN = cc.Sprite:createWithSpriteFrameName("add_you_win_EN.png")
		add_you_win_EN:setPosition(size.width/2,size.height*2.85/4)
		pop_add_board:addChild(add_you_win_EN)

		local add_extra_EN = cc.Sprite:createWithSpriteFrameName("add_extra_EN.png")
		add_extra_EN:setPosition(size.width/2,size.height*1.1/4)
		pop_add_board:addChild(add_extra_EN)

		local add_num = cc.Sprite:createWithSpriteFrameName(string.format("add_%d.png",num))
		add_num:setPosition(size.width/2,size.height/2)
		pop_add_board:addChild(add_num)

		pop_add_board:setScale(0.01)
		pop_add_board:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.8,1)),
		cc.DelayTime:create(2),cc.CallFunc:create(function ()
			this.logic.freeGameUsedNum = this.logic.rcvSpinData.totalCount
			this.logic.freeGameTotalNum = this.logic.rcvSpinData.allCount
			local text = this.logic.freeGameUsedNum.."/"..this.logic.freeGameTotalNum
			this.upFreegame_Text:setString(text)
			pop_add_board:removeFromParent()
			shadowPic:removeFromParent()
		end)))
	--免费游戏结算
	elseif panelType == 3 then
		--fgend.mp3
		Casino_soundFunc.PlayBackMusic(Casino_Func.GetCasinoSound(3))

		local free_board = cc.Sprite:createWithSpriteFrameName("free_board.png")
		free_board:setPositionY(-10)
		this.FreePanelNode:addChild(free_board)

		local size = free_board:getContentSize()

		local free_top = cc.Sprite:createWithSpriteFrameName("free_top.png")
		free_top:setPosition(size.width/2,size.height*6/7)
		free_board:addChild(free_top)

		local total_win_EN = cc.Sprite:createWithSpriteFrameName("total_win_EN.png")
		total_win_EN:setPosition(size.width/2,size.height*7/8)
		free_board:addChild(total_win_EN)

		local freeText = cc.Label:createWithBMFont("casino332/newres/fnt/total_num.fnt",Casino_Func.ShuZi_Exchangerate(totalwin,false),0)
		freeText:setPosition(size.width/2,size.height*3.9/7)
		free_board:addChild(freeText)

		free_board:setScale(0.01)
		free_board:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.8,0.85)),
		cc.DelayTime:create(2),cc.CallFunc:create(function ()
			this.background:setSpriteFrame("background.png")
			Casino_soundFunc.PlayBackMusic(Casino_Func.GetCasinoSound(4))	--ngbgm.mp3
			free_board:removeFromParent()
			shadowPic:removeFromParent()
		end)))
	end	
end

--游戏状态更新
this.AfricanBuffaloGameUpdate = function ()
	if this.logic.gameState == Def_Casino.State_Initial then
		this.coinNum = 0
		this.cellIndex = 1
	elseif this.logic.gameState == Def_Casino.State_RunSpin then
		if this.cellIndex <= 5 then
			if this.logic.gameCells[this.cellIndex].state == 2 then --弹性效果状态
				local playStopMusic = true
				for j = 1, #this.logic.gameCells[this.cellIndex].lastSymbolIdTuData-1 do
					if this.logic.gameCells[this.cellIndex].lastSymbolIdTuData[j].icon == AfricanBuffalo_Item.iconData.scatter_icon then
						this.coinNum = this.coinNum + 1
						playStopMusic = false
						Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(6+this.coinNum))	--reelscatr-1-5.mp3
						break
					end
				end
				if this.coinNum >= 2 then
					if this.cellIndex < 5 then
						Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(6))		--reelfast.mp3
					end
					for j = this.cellIndex+1, 5 do
						this.logic.gameCells[j].maxDistance = this.logic.gameCells[j].maxDistance + 20
						this.logic.gameCells[j].speed = this.logic.cellSpeed_js
						print("加距离!!!",this.logic.gameCells[j].maxDistance)
					end
				end
				if playStopMusic then
					Casino_soundFunc.PlayEffects(Casino_Func.GetCasinoSound(12))	--reelstop.mp3
				end
				this.cellIndex = this.cellIndex +1
			end
		end
	end
end


return this