local this = {}
this.stateName = "CanisoGameEnter"
this.stateGroupName = "CanisoGameEnter"
this.opened = false
this.gotoType = 0--在调用本脚本的地方判断跳转到哪步

this.Open = function()
	assert(not this.opened)
	local root = cc.Node:create()
	gScene:addChild(root)
	this.root = root

	GameData.game_id = GameData:GetGameID(GameData.game_id)
	local net_code = "hall.src.pkgs.slot_" .. tostring(GameData.game_id) 
	package.loaded[net_code] = nil
	package.loaded["g_net"] = {} -- 协议文件有些时候会多一句 require('g_net'), 加这一行避免脚本错误
	local ok, err_msg = pcall(require, net_code)
	if not ok then
		-- 协议加载错误 上报
		this.opened = true
		gStates_CloseAsync(this)
		return
	end

	--CanisoGameEnter运行
	--注册老虎机协议命令
	gNet_RegisterServiceMappings("PKG_Client_Slots_",GameData.serverID)
	gNet_RegisterServiceMappings("PKG_Extral_",GameData.serverID)
	this.opened = true
	this.CanisoGameEnterRun()
end

this.Close = function()
	assert(this.opened)
	this.root:removeFromParent()
	this.opened = false
end

--发送进入casino游戏包
this.SendEnterCanisoGame = function()
	print(GameData.game_id)

	sGameManager.slotEnterResult = nil
	sGameManager.NetRestoreCasino = false
	sGameManager.NetRestoreCasinoRlt = nil

	local data_ = PKG_Client_Slots_Enter.Create()
	return gNet_SendRequest(data_)
end

--进入casino游戏判断
this.CanisoGameEnterRun = function()
	print("*******进入casino游戏判断")
	sGameManager.gameState = const_game.Game_State
	UIManager.ShowWaiting()
	local rlt_ = this.SendEnterCanisoGame()
	UIManager.HideWaiting()
	if(rlt_ ~= nil)then
		--收到返回数据
		if(rlt_.typeId == PKG_Slots_Client_Enter_Success.typeId) then
			sGameManager.slotEnterResult = rlt_
			GameData.entryConditions = rlt_.entryConditions
			sGameManager.curCoin = rlt_.enterMoney
			sGameManager.curXiMa = rlt_.enterMoneyGift
			sGameManager.casinoMoneyType = rlt_.moneyType
			sGameManager.betRatios = rlt_.betRatios
			-- 强退level找不到就用第一档
			if sGameManager.curLevel == nil then
				sGameManager.curLevel = GameData.entryConditions[1]
			end
			--总共有多少桌
			sGameManager.numTables = rlt_.tableSize
			--每一桌有多少人
			--sGameManager.numChairs = rlt_.chairTable
			--每一桌的椅子数
			sGameManager.chairSize = rlt_.chairSize
			--玩家坐的位置，目前没用
			sGameManager.chairID = rlt_.chairId
			--所有座位的玩家信息
			sGameManager.playersInfo = rlt_.players
			this.HandleSitInfo(rlt_, rlt_.tableId)
		elseif (this.IsReConnection(rlt_)) then
			print("IsReConnection")
			-- 初始化老虎机变量
			sGameManager.InitCasinoParam()
			if rlt_.enterBase ~= null then
				sGameManager.slotEnterResult = rlt_.enterBase
				sGameManager.NetRestoreCasino = true
				sGameManager.NetRestoreCasinoRlt = rlt_

				GameData.entryConditions = rlt_.enterBase.entryConditions
				sGameManager.curCoin = rlt_.enterBase.enterMoney
				sGameManager.curXiMa = rlt_.enterBase.enterMoneyGift
				sGameManager.casinoMoneyType = rlt_.enterBase.moneyType
				sGameManager.betRatios = rlt_.enterBase.betRatios
			end
			-- 强退level找不到就用第一档
			if sGameManager.curLevel == nil then
				sGameManager.curLevel = GameData.entryConditions[1]
			end
			this.HandleSitInfo(rlt_, rlt_.enterBase.tableId)
			
		elseif(rlt_.typeId == PKG_Generic_Error.typeId)then
			print("PKG_Generic_Error:",rlt_.typeId)
			print(string.format("%s: %s",Def.Info_LoginWrong, rlt_.message))
			UIManager.ShowMsgBox(TR("未知数据包"))
			--local panel = sGameManager.ShowErrorInfo(str,Def.PopUp_ErrorInfo,nil)
			--gStates_WaitAppear(panel)
			--gStates_WaitDisappear(panel)
			--gGotoCaniso = true
		end
	else
		print("CanisoGameEnterRun rlt_ is null")
		--todo
	end
	gStates_CloseAsync(this)
end

--处理座位相关信息
function this.HandleSitInfo(rlt_, tableID)
	print("tableID:", tableID)
	--0：表示在选座界面，其余表示在老虎机游戏里面
	if tableID == 0 then
		if gStates_Exists("CasinoSit") then
			if rlt_.typeId == PKG_Slots_Client_Enter_Success.typeId then
				print("客户端已进入选卓，服务器再次让客户端进入选座，刷新座位信息")
				if sGameManager.playersInfo ~= nil then
					
				end
			--已经在老虎机选座，断线重连，主动发退出游戏包，返回大厅
			elseif (this.IsReConnection(rlt_)) then
				gorun(function ()
					coroutine.yield()
					local data_ = PKG_Client_Slots_Leave.Create()
					local rlt_ = gNet_SendRequest(data_)
					this.HandleCasinoReturn(rlt_)
				end)
			end
		else
			--客户端首次进入选座界面
			if rlt_.typeId == PKG_Slots_Client_Enter_Success.typeId then
				local script = require "hall.src.hallnew.layers.lobby.CasinoSit"
				gStates_SetAsync(script)
			--杀进程断线重连老虎机选座，主动发退出游戏包，返回大厅
			elseif (this.IsReConnection(rlt_)) then
				gorun(function ()
					coroutine.yield()
					local data_ = PKG_Client_Slots_Leave.Create()
					local rlt_ = gNet_SendRequest(data_)
					this.HandleCasinoReturn(rlt_)
				end)
			end
		end
	else
		-- 设置断线重连
		sGameManager.NetRestoreCasino = true
		sGameManager.NetRestoreCasinoRlt = rlt_
		if sGameManager.isCasinoLoaded then
			print("已加载过老虎机脚本")
			return
		end
		local script = require("hall.src.hallnew.layers.lobby.CasinoLoading")
		gStates_SetAsync(script)
	end 
end

--处理返回
function this.HandleCasinoReturn(rlt_)
	print("老虎机选座返回大厅")
	if rlt_ ~= nil then
		if(rlt_.typeId == PKG_Slots_Client_Leave_Success.typeId)then
            this.BackLobby()
		elseif(rlt_.typeId == PKG_Generic_Error.typeId)then
			print("PKG_Generic_Error:",rlt_.typeId)
			print(string.format("%s: %s",Def.Info_LoginWrong, rlt_.message))
			UIManager.ShowToast(TR("老虎机选座返回大厅，数据发生错误"))
		else
			print("无法解析命令字段:", rlt_.typeName)
		end
	else
		print("返回空包")
	end
end

function this.IsReConnection(rlt_)
	local isok = false
	if GameData.game_id == 206 then
		if (rlt_.typeId == PKG_Slots_Client_SugarEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 205 then
		if (rlt_.typeId == PKG_Slots_Client_WealthGoldEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 220 or GameData.game_id == 223 then
		if (rlt_.typeId == PKG_Slots_Client_PandaTreasuresEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 215 then
		if (rlt_.typeId == PKG_Slots_Client_LotteryPhoenixEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 213 then
		if (rlt_.typeId == PKG_Slots_Client_TigerWealthEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 214 then
		if (rlt_.typeId == PKG_Slots_Client_GrandDragonsEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 222 then
		if (rlt_.typeId == PKG_Slots_Client_LuckyDollarEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 221 or GameData.game_id == 332 or GameData.game_id == 240  then
		if (rlt_.typeId == PKG_Slots_Client_AfricanBuffaloEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 225 then
		if (rlt_.typeId == PKG_Slots_Client_OceanPrincessEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 210 then
		if (rlt_.typeId == PKG_Slots_Client_Empire88EnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 224 or GameData.game_id == 289 then
		if (rlt_.typeId == PKG_Slots_Client_ImmortalMonkeyEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 226 then
		if (rlt_.typeId == PKG_Slots_Client_LeprechaunStackGoldEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 218 or GameData.game_id == 217 or GameData.game_id == 231 then
		if (rlt_.typeId == PKG_Slots_Client_FortuneTreeEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 207 or GameData.game_id == 209 then
		if (rlt_.typeId == PKG_Slots_Client_FestivalEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 208 then
		if (rlt_.typeId == PKG_Slots_Client_LuckyDiamondEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 229 then
		if (rlt_.typeId == PKG_Slots_Client_VegasNightEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 219 then
		if (rlt_.typeId == PKG_Slots_Client_EgyptianFantasyEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 230 or GameData.game_id == 333  then
		if (rlt_.typeId == PKG_Slots_Client_FortuneCatEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 216 or GameData.game_id == 331 then
		if (rlt_.typeId == PKG_Slots_Client_Golden88EnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 211 or GameData.game_id == 301 then
		if (rlt_.typeId == PKG_Slots_Client_MissBunnyEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 232 then
		if (rlt_.typeId == PKG_Slots_Client_GoldenPigEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 212 then
		if (rlt_.typeId == PKG_Slots_Client_SnowGoddessEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 233 then
		if (rlt_.typeId == PKG_Slots_Client_DafuShowEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 256 then
		if (rlt_.typeId == PKG_Slots_Client_Fortunes388EnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 234 then
		if (rlt_.typeId == PKG_Slots_Client_Sevens7EnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 259 or GameData.game_id == 317 or GameData.game_id == 318 or GameData.game_id == 325 then
		if (rlt_.typeId == PKG_Slots_Client_JinJiBaoXiEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 257 then
		if (rlt_.typeId == PKG_Slots_Client_DuanWuEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 251 or GameData.game_id == 309 or GameData.game_id == 315 then
		if (rlt_.typeId == PKG_Slots_Client_Fortune5lianEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 255 then
		if (rlt_.typeId == PKG_Slots_Client_DiamondEternityEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 252 then
		if (rlt_.typeId == PKG_Slots_Client_DoubleBlessingsEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 258 or GameData.game_id == 319 then
		if (rlt_.typeId == PKG_Slots_Client_DancingDrumsEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 260 then
		if (rlt_.typeId == PKG_Slots_Client_FortuneTreeEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 270 or GameData.game_id == 320 or GameData.game_id == 323 
	or GameData.game_id == 321 or GameData.game_id == 322 then
		if (rlt_.typeId == PKG_Slots_Client_EyesOfWealthEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 271 then
		if (rlt_.typeId == PKG_Slots_Client_DragonKingEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 272 then
		if (rlt_.typeId == PKG_Slots_Client_NvwaEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 273 then
		if (rlt_.typeId == PKG_Slots_Client_KoiAnnunciationEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 294 or GameData.game_id == 295
	 then
		if (rlt_.typeId == PKG_Slots_Client_WealthGold2EnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 276 then
		if (rlt_.typeId == PKG_Slots_Client_WealthTreasureEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 277 then
		if (rlt_.typeId == PKG_Slots_Client_DragonGiftEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 278 then
		if (rlt_.typeId == PKG_Slots_Client_RichFishEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 279 then
		if (rlt_.typeId == PKG_Slots_Client_PegasusEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 280 then
		if (rlt_.typeId == PKG_Slots_Client_DragonPrinceEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 281 then
		if (rlt_.typeId == PKG_Slots_Client_DragonsdeluxeEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 283 then
		if (rlt_.typeId == PKG_Slots_Client_LionTreasureEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 288 or GameData.game_id == 282 or GameData.game_id == 313 then
		if (rlt_.typeId == PKG_Slots_Client_NvXiaEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 291 or GameData.game_id == 292 then
		if (rlt_.typeId == PKG_Slots_Client_MoonFestivalEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 293 then
		if (rlt_.typeId == PKG_Slots_Client_KinsRapidEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 296 or GameData.game_id == 307 then
		if (rlt_.typeId == PKG_Slots_Client_TigerPrincessEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 297 then
		if (rlt_.typeId == PKG_Slots_Client_PandaGoldEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 298 or  GameData.game_id == 299 then
		if (rlt_.typeId == PKG_Slots_Client_TigerPrincessEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 302 then
		if (rlt_.typeId == PKG_Slots_Client_DoublePandaEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 303 or GameData.game_id == 304 or GameData.game_id == 307  then
		if (rlt_.typeId == PKG_Slots_Client_TigerGardenEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 305 then
		if (rlt_.typeId == PKG_Slots_Client_RedEmpressEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 306  then
		if (rlt_.typeId == PKG_Slots_Client_HeavenEarthEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 310  then
		if (rlt_.typeId == PKG_Slots_Client_TreeWealthEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 311 then
		if (rlt_.typeId == PKG_Slots_Client_FireLinkEnterResumed.typeId) then
			isok = true
		end
	elseif GameData.game_id == 312 then
		if (rlt_.typeId == PKG_Slots_Client_FireLinkEnterResumed.typeId) then
			isok = true
		end
	end

	if not isok then
		local cfg = const_game.Param[GameData.game_id]
		if cfg and rlt_.typeName == cfg[const_game.Reconnect_Msg] then
			isok = true
		end
	end

	if isok then
		print("Panel_CasinoGameEnter 收到断线重连包")
		dump(rlt_,"rlt_")
		return true
	end
	return false
end

function this.BackLobby()
    sGameManager.isCasinoLoaded = false
    sGameManager.gameState = const_game.Lobby_State

    local layer = BottomLayer:Get(LobbyLayer)
	if layer then
        layer:EnterLobby()
    else
        EnterLobbyPanel()
    end
    gStates_CloseAsync(this)
end

return this