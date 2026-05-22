local utils = import(".utils")

local CasinoLoading = class("CasinoLoading", function()
	local node = cc.CSLoader:createNode("csb/lobby/GameLoadingLayer.csb")
	node:enableNodeEvents()
	return node
end)

function CasinoLoading:ctor()
	sGameManager.gameState = const_game.Lobby_To_Game_State

	self.res_game_id = GameData:GetGameID(GameData.game_id)

	self:Init()
	self:Adjust()
	self:Start()
end

function CasinoLoading:Start()
	go(function()
		if not self:DownloadModule("casino" .. self.res_game_id) then
			return
		end

		if not self:DownloadModule("casino_common") then
			return
		end
	
		self:LoadindRes()
	end)
end

function CasinoLoading:DownloadModule(module_)
	-- 无需下载
	if not sDownloadMgr.CheckModule(module_) then
		return true
	end

	local done = false
	local updateFunc = function(module_)
		local percent = sDownloadMgr.updateTask[module_].percent

        if tolua.isnull(self) then return end
		self:RefreshLoadingBar(percent)
	end

	sDownloadMgr.UpdatingCallBack[module_] = updateFunc
	local endFunc = function(module_)  -- success
		done = true
	end
	sDownloadMgr.EndCallBack[module_] = endFunc

	local retry = nil
	local failedFunc = function(module_)
        UIManager.ShowMsgBox(TR("版本更新失败, 是否重试？"),
            function()
                retry = true
            end,
            function()
				retry = false
            end
        )
    end
    if sDownloadMgr.FailedCallBack then
        sDownloadMgr.FailedCallBack[module_] = failedFunc
    end

	sDownloadMgr.StartDownloadTask(module_)

	while not done do
		if retry == true then
			retry = nil
			return self:DownloadModule(module_)
		end
		if retry == false then
			retry = nil
			EnterLobbyPanel()
			return false
		end
		SleepSecs(0.1)
	end
	return true
end

function CasinoLoading:Init()
	self.file_names = {}
	
	MarqueeLogic:HideNotice_Node()
	MarqueeLogic:HideNotice("width")
	
    local panel = self:getChildByName("panel")
    self.percent = panel:getChildByName("percent")
    self.bar_fg = panel:getChildByName("bar_fg")
	self.loading_bar = panel:getChildByName("loading_bar")
    self.percent:setVisible(true)
    self.loading_bar:setPercent(0)
    self.loading_bar:setVisible(true)
end

function CasinoLoading:Adjust()
	self:AdjustLoadingGameUI()
end

function CasinoLoading:AdjustLoadingGameUI()
	self:ChangeLoadingBG()
	self:ChangeLoadingBar_fg_LoadingBar()

	local res_game_id = self.res_game_id

	--竖屏游戏需要转换屏幕
	local width,height = 1280,720
	if const_game.Param[res_game_id][const_game.ScreenType] == const_game.V_Screen_Type then
		Device:setScreenType(const_game.V_Screen_Type)
		width,height = height,width
		Tools.ResetWidthHeight()
	end

	local size = cc.Director:getInstance():getVisibleSize()
	local ScaleX = size.width / width
	local ScaleY = size.height / height
	local ScaleMax = math.max(ScaleX, ScaleY)
	local ScaleMin = math.min(ScaleX, ScaleY)
	local bg_shadow = self:getChildByName("bg_shadow")
	bg_shadow:setScale(ScaleMax)

	--背景 铺满
	local bg = self:getChildByName("bg")
	if res_game_id >= 250 and res_game_id <= 260 then
		bg:setContentSize(size)
	elseif res_game_id >= 270 then
		bg:setContentSize(size)
	else
		bg:setScale(1.26*ScaleMin)
	end
	local center = cc.p(size.width/2.0, size.height/2.0)
	bg:setPosition(center)
	--
	local logo = self:getChildByName("logo")
	logo:setPosition(center)
	logo:setScale(ScaleMin)
	--
	--面板尽量放大居中
	local panel = self:getChildByName("panel")
	
	if const_game.Param[res_game_id][const_game.ScreenType] == const_game.V_Screen_Type then
		panel:setScale(ScaleMin*0.95)
		self.loading_bar:setScale(0.8)
		self.bar_fg:setScale(0.8)
		center.y = center.y - (ScaleMin*230)
	else
		panel:setScale(ScaleMin)
	end
	
	panel:setPosition(center)
end

--刷新进度条
function CasinoLoading:RefreshLoadingBar(progress)
    progress = math.floor(progress)
    if progress <= 0 then
        progress = 0
    elseif progress >= 100 then
        progress = 100
    end

    self.loading_bar:setPercent(progress)
    self.percent:setString(tostring(progress) .. "%")
end

function CasinoLoading:ChangeLoadingBar_fg_LoadingBar()
	local str_Barfg = nil
	local loading_bar = nil

	local res_game_id = self.res_game_id

	if res_game_id == 325 then
		str_Barfg = "casino325/res/casino325/bar_fg.png"
		loading_bar = "casino325/res/casino325/loading_bar.png"
	end
	if str_Barfg and loading_bar then
		Tools.LoadTexture(self.bar_fg, str_Barfg)
		Tools.LoadTexture(self.loading_bar, loading_bar)
	end
end

function CasinoLoading:ChangeLoadingBG()
	local res_game_id = self.res_game_id

	require "hall.src.common.Def_Casino_Loading"
	local str_bg = Def_Casino_Loading.LoadingBG[res_game_id]
	local str_logo = Def_Casino_Loading.LoadingLogo[res_game_id]
	
	if str_bg ~= "" then
		local bg = self:getChildByName("bg")
		Tools.LoadTexture(bg, str_bg)
	end

	--新8款有 logo
	local logo = self:getChildByName("logo")
	if str_logo ~= "" then
		Tools.LoadTexture(logo, str_logo)
	else
		logo:setVisible(false)
	end
end

function CasinoLoading:LoadindRes()
	print("要加载资源了")
    self.loading_bar:setPercent(0)

	--进入老虎机关闭大厅bgm
	gSound.stopBgm()

	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	
	self:Prepare_Loading_Res()
	print("开始加载资源了")
	gorun(function ()
		for idx,full_path in ipairs(self.file_names) do
			cc.SpriteFrameCache:getInstance():addSpriteFrames(full_path)
			local progress = math.floor(idx/(#self.file_names) * 100.0)
			self:RefreshLoadingBar(progress)
			SleepSecs(0.04)

			if tolua.isnull(self) then return end
		end

        local success, ret = xpcall(function()
            self:EnterCasino()
        end, __G__TRACKBACK__)

        if not success then
            UIManager.ShowMsgBox("Error loading casino resources.", function()
                self:removeFromParent()
                utils.GoBackLobby()
            end)
        end
	end)
end

function CasinoLoading:Prepare_Loading_Res()
	print("装载资源")

	local res_game_id = self.res_game_id

	local download_res = const_def.WritablePath .. "/src/casino" .. res_game_id .. "/res/"
	cc.FileUtils:getInstance():addSearchPath(download_res, true)
	local dafault_res = const_def.DefaultPath .. "src/casino" .. res_game_id .. "/res/"
	cc.FileUtils:getInstance():addSearchPath(dafault_res)

    local gameChunkFile = cc.FileUtils:getInstance():fullPathForFilename(string.format("src/casino%d/src.chunk.zip", res_game_id, res_game_id))
    if LoadChunksFromZIP and gameChunkFile ~= "" then
        LoadChunksFromZIP(gameChunkFile)
        print("Loading Chunk:" .. gameChunkFile)
    else
        local download_src = const_def.WritablePath .. "/src/casino" .. res_game_id .. "/src/"
        cc.FileUtils:getInstance():addSearchPath(download_src, true)
        local default_src = const_def.DefaultPath .. "src/casino" .. res_game_id .. "/src/"
        cc.FileUtils:getInstance():addSearchPath(default_src)
    end

    local commonChunkFile = cc.FileUtils:getInstance():fullPathForFilename("src/casino_common/src.chunk.zip")
    if LoadChunksFromZIP and commonChunkFile ~= "" then
        LoadChunksFromZIP(commonChunkFile)
        print("Loading Chunk:" .. commonChunkFile)
    end

	--
	--公共老虎机资源
	self:Push_File_Path("casino_common/res/lang_EN_c.plist")
	self:Push_File_Path("casino_common/res/lang_CN_c.plist")
	self:Push_File_Path("casino_common/res/button_c.plist")
	self:Push_File_Path("casino_common/res/coin.plist")
	self:Push_File_Path("casino_common/res/prompt_bg_plist.plist")
	self:Push_File_Path("casino_common/res/coinShow.plist")
	self:Push_File_Path("casino_common/res/slotshupin.plist")
	self:Push_File_Path("casino_common/res/coin_stack.plist")
	self:Push_File_Path("casino_common/res/coin8g_2.plist")
	self:Push_File_Path("casino_common/res/zuanshis.plist")
	self:Push_File_Path("casino_common/res/hongBao.plist")
	self:Push_File_Path("casino_common/res/Bat_Flying1.plist")
	self:Push_File_Path("casino_common/res/CasinoDaFUQJ.plist")
	self:Push_File_Path("casino_common/res/fafafa/fafafaButtonLanguage.plist")
	self:Push_File_Path("casino_common/res/fafafa/fafafazfpicture.plist")
	self:Push_File_Path("casino_common/res/fafafa/language/fafafaAddBtn.plist")
	self:Push_File_Path("casino_common/res/fafafa/ximaResources.plist")
	self:Push_File_Path("casino_common/res/fafafa/ximaResources1.plist")
	self:Push_File_Path("casino_common/res/dafuLanguage.plist")
	self:Push_File_Path("casino_common/res/languageShezhi.plist")
	self:Push_File_Path("casino_common/res/newQuJianPic.plist")
	self:Push_File_Path("casino_common/res/Language/settingAdd.plist")
	self:Push_File_Path("casino_common/res/Language/oldlanguageAdd.plist")
	self:Push_File_Path("casino_common/res/addlanguage/ina_ph_language.plist")
	self:Push_File_Path("casino_common/res/addlanguage/pt_language.plist")
	self:Push_File_Path("casino_common/res/addlanguage/bd_language.plist")
	
	--发发发的公共资源
	if res_game_id >= 270 then
		self:Push_File_Path("casino_common/res/fafafa/coin_100.plist")
	end
	if (res_game_id == 205) then
        self:Push_File_Path("casino205/res/casino205/newres/background_ui.plist")
		self:Push_File_Path("casino205/res/casino205/newres/fgAdd.plist")
		self:Push_File_Path("casino205/res/casino205/newres/freegame_ui.plist")
		self:Push_File_Path("casino205/res/casino205/newres/info_ui.plist")
		self:Push_File_Path("casino205/res/casino205/newres/scroll_show.plist")
		self:Push_File_Path("casino205/res/casino205/newres/fgselect.plist")
		self:Push_File_Path("casino205/res/casino205/newres/symbol.plist")
	elseif (res_game_id == 206) then
        self:Push_File_Path("casino206/res/casino206/info/Info.plist")
        self:Push_File_Path("casino206/res/casino206/newres/symbol.plist")
        self:Push_File_Path("casino206/res/casino206/newres/lang_CN.plist")
        self:Push_File_Path("casino206/res/casino206/newres/lang_EN.plist")
        self:Push_File_Path("casino206/res/casino206/newres/teshuGame.plist")
        self:Push_File_Path("casino206/res/casino206/newres/caiJinBan.plist")
        self:Push_File_Path("casino206/res/casino206/newres/tgwg_jianglicishu.plist")
	elseif (res_game_id == 207) then
		self:Push_File_Path("casino207/res/casino207/symbols_new.plist")
		self:Push_File_Path("casino207/res/casino207/symbol-effect.plist")
		self:Push_File_Path("casino207/res/casino207/wild-frame.plist")
		self:Push_File_Path("casino207/res/casino207/chipBoundingLightning.plist")
		self:Push_File_Path("casino207/res/casino207/loading/backGround0.plist")
		self:Push_File_Path("casino207/res/casino207/breakbtn.plist")
		self:Push_File_Path("casino207/res/casino207/firework-0.plist")
		self:Push_File_Path("casino207/res/casino207/lineElements.plist")
		self:Push_File_Path("casino207/res/casino207/lang_EN/lang_EN_01.plist")
		self:Push_File_Path("casino207/res/casino207/null.plist")
		self:Push_File_Path("casino207/res/casino207/loading/backGround0.plist")
		self:Push_File_Path("casino207/res/casino207/lang_CN/lang_CN_04.plist")
		self:Push_File_Path("casino207/res/casino207/hyll_shuzi.plist")
		self:Push_File_Path("casino207/res/casino207/symbol_caishenkuang.plist")
		self:Push_File_Path("casino207/res/casino207/haoyunniannian_donghuajiangli.plist")
		self:Push_File_Path("casino207/res/casino207/frame-line3.plist")
		self:Push_File_Path("casino207/res/casino207/bgNumBack_zhuzi.plist")
		self:Push_File_Path("casino207/res/casino207/JJK.plist")
		self:Push_File_Path("casino207/res/casino207/lang_EN/lang_EN_04.plist")
		self:Push_File_Path("casino207/res/casino207/jpLoading.plist")
		self:Push_File_Path("casino207/res/casino207/SCP_1.plist")
		self:Push_File_Path("casino207/res/casino207/lightnings.plist")
		self:Push_File_Path("casino207/res/casino207/lang_EN/lang_EN_03.plist")
		self:Push_File_Path("casino207/res/casino207/symbol-other.plist")
		self:Push_File_Path("casino207/res/casino207/lang_EN/lang_EN_02.plist")
		self:Push_File_Path("casino207/res/casino207/jpFRAME.plist")
		self:Push_File_Path("casino207/res/casino207/jpFRAMETEXT.plist")
		self:Push_File_Path("casino207/res/casino207/jpBoundingLightning.plist")
		self:Push_File_Path("casino207/res/casino207/freeGameSelection-0.plist")
		self:Push_File_Path("casino207/res/casino207/freeGameSelection-1.plist")
		self:Push_File_Path("casino207/res/casino207/chipJp.plist")
		self:Push_File_Path("casino207/res/casino207/frame-line3.plist")
		self:Push_File_Path("casino207/res/casino207/lang_CN/lang_CN_01.plist")
		self:Push_File_Path("casino207/res/casino207/lang_CN/lang_CN_02.plist")
		self:Push_File_Path("casino207/res/casino207/lang_CN/lang_CN_03.plist")
	elseif (res_game_id == 208) then
		self:Push_File_Path("casino208/res/casino208/info/info.plist")
		self:Push_File_Path("casino208/res/casino208/newres/symbol_reel_0.plist")
		self:Push_File_Path("casino208/res/casino208/newres/back_1.plist")
		self:Push_File_Path("casino208/res/casino208/newres/back_2.plist")
		self:Push_File_Path("casino208/res/casino208/newres/back_3.plist")
		self:Push_File_Path("casino208/res/casino208/newres/lineElements.plist")
		self:Push_File_Path("casino208/res/casino208/newres/wild_show.plist")
		self:Push_File_Path("casino208/res/casino208/newres/back_4.plist")
		self:Push_File_Path("casino208/res/casino208/newres/symbol_reel_1.plist")
		self:Push_File_Path("casino208/res/casino208/newres/multiboard.plist")
	elseif (res_game_id == 209) then
		self:Push_File_Path("casino209/res/casino209/symbol.plist")
		self:Push_File_Path("casino209/res/casino209/jpFRAME.plist")
		self:Push_File_Path("casino209/res/casino209/wild-frame.plist")
		self:Push_File_Path("casino209/res/casino209/chipBoundingLightning.plist")
		self:Push_File_Path("casino209/res/casino209/breakbtn.plist")
		self:Push_File_Path("casino209/res/casino209/lang_EN/lang_EN_02.plist")
		self:Push_File_Path("casino209/res/casino209/firework-0.plist")
		self:Push_File_Path("casino209/res/casino209/lineElements.plist")
		self:Push_File_Path("casino209/res/casino209/lang_CN/lang_CN_03.plist")
		self:Push_File_Path("casino209/res/casino209/null.plist")
		self:Push_File_Path("casino209/res/casino209/lang_CN/lang_CN_01.plist")
		self:Push_File_Path("casino209/res/casino209/lang_CN/lang_CN_02.plist")
		self:Push_File_Path("casino209/res/casino209/freeGameSelection-0.plist")
		self:Push_File_Path("casino209/res/casino209/jpBoundingLightning.plist")
		self:Push_File_Path("casino209/res/casino209/frame-line2.plist")
		self:Push_File_Path("casino209/res/casino209/bgNumBack_zhuzi.plist")
		self:Push_File_Path("casino209/res/casino209/JJK.plist")
		self:Push_File_Path("casino209/res/casino209/lang_EN/lang_EN_01.plist")
		self:Push_File_Path("casino209/res/casino209/jpLoading.plist")
		self:Push_File_Path("casino209/res/casino209/SCP_1.plist")
		self:Push_File_Path("casino209/res/casino209/lightnings.plist")
		self:Push_File_Path("casino209/res/casino209/lang_EN/lang_EN_03.plist")
		self:Push_File_Path("casino209/res/casino209/lang_CN/lang_CN_02.plist")
		self:Push_File_Path("casino209/res/casino209/jpLoading.plist")
	elseif (res_game_id == 210) then
		self:Push_File_Path("casino210/res/casino210/newres/plist/bg_dice.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/BGcount.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/bgremaintimes.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/BGSprites1.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/BGSprites2.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/collect_btn.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/Dice_state_normal.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/fg_glow.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/FG_SELECTLAYER.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/FG_SELECTLAYER_add.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/fgScroll.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/FGStencil.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/frame-line.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/juanzhoujiesuan4.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/lineElements.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/multilang_jishu.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/NGaddon.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/shengzhi.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/Stencil.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/Stencil_new.plist")
		self:Push_File_Path("casino210/res/casino210/newres/plist/Symbols.plist")
		self:Push_File_Path("casino210/res/casino210/newres/lang/casinoj_lang_CN.plist")
		self:Push_File_Path("casino210/res/casino210/newres/lang/casinoj_lang_EN.plist")
	elseif (res_game_id == 211) then
		self:Push_File_Path("casino211/res/casino211/newres/plist/Line_Element.plist")
		self:Push_File_Path("casino211/res/casino211/newres/plist/symbols_new.plist")
		self:Push_File_Path("casino211/res/casino211/newres/plist/lang_CN.plist")
		self:Push_File_Path("casino211/res/casino211/newres/plist/lang_EN.plist")
	elseif (res_game_id == 212) then
		self:Push_File_Path("casino212/res/casino212/newres/lang_EN3.plist")
		self:Push_File_Path("casino212/res/casino212/newres/lang_EN2.plist")
		self:Push_File_Path("casino212/res/casino212/newres/lang_EN1.plist")
		self:Push_File_Path("casino212/res/casino212/newres/lang_CN1.plist")
		self:Push_File_Path("casino212/res/casino212/newres/lang_CN2.plist")
		self:Push_File_Path("casino212/res/casino212/newres/lang_CN3.plist")
		self:Push_File_Path("casino212/res/casino212/newres/Others.plist")
		self:Push_File_Path("casino212/res/casino212/newres/xuehua.plist")
		self:Push_File_Path("casino212/res/casino212/newres/fgNum.plist")
		self:Push_File_Path("casino212/res/casino212/newres/symbols_1.plist")
		self:Push_File_Path("casino212/res/casino212/newres/tanban.plist")
		self:Push_File_Path("casino212/res/casino212/newres/jpBackground.plist")
		self:Push_File_Path("casino212/res/casino212/newres/column.plist")
	elseif (res_game_id == 213) then
		self:Push_File_Path("casino213/res/casino213/newres/plist/lang_CN.plist")
		self:Push_File_Path("casino213/res/casino213/newres/plist/lang_EN.plist")
		self:Push_File_Path("casino213/res/casino213/newres/symbol.plist")
		self:Push_File_Path("casino213/res/casino213/newres/fgWild.plist")
		self:Push_File_Path("casino213/res/casino213/newres/fgwildmulti.plist")
		self:Push_File_Path("casino213/res/casino213/newres/SG.plist")
		self:Push_File_Path("casino213/res/casino213/newres/caijin_symbol.plist")
		self:Push_File_Path("casino213/res/casino213/newres/Click_coin.plist")
	elseif (res_game_id == 214) then
		self:Push_File_Path("casino214/res/casino214/newres/info_ui.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_a_0.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_a_1.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_a_2.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_b_0.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_b_1.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_b_2.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_c_0.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_c_1.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_c_2.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_d_0.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_d_1.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_d_2.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_e_0.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_e_1.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_e_2.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_main_0.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_main_1.plist")
		self:Push_File_Path("casino214/res/casino214/newres/dragon_main_2.plist")
		self:Push_File_Path("casino214/res/casino214/newres/flower_animate.plist")
		self:Push_File_Path("casino214/res/casino214/newres/fgselect_ui.plist")
		self:Push_File_Path("casino214/res/casino214/newres/free_show.plist")
		self:Push_File_Path("casino214/res/casino214/newres/freegame_select.plist")
		self:Push_File_Path("casino214/res/casino214/newres/pocket_animate_0.plist")
		self:Push_File_Path("casino214/res/casino214/newres/pocket_animate_1.plist")
		self:Push_File_Path("casino214/res/casino214/newres/symbol_reel_change.plist")
		self:Push_File_Path("casino214/res/casino214/newres/symbol_reel_change_1.plist")
		self:Push_File_Path("casino214/res/casino214/newres/symbol_reel_nochange.plist")
		self:Push_File_Path("casino214/res/casino214/newres/xs_ui.plist")
	elseif (res_game_id == 215) then
        self:Push_File_Path("casino215/res/casino215/newres/xs_ui.plist")
		self:Push_File_Path("casino215/res/casino215/newres/symbol.plist")
		self:Push_File_Path("casino215/res/casino215/newres/fgWild.plist")
		self:Push_File_Path("casino215/res/casino215/newres/fgSelect.plist")
		self:Push_File_Path("casino215/res/casino215/newres/Info_EN.plist")
		self:Push_File_Path("casino215/res/casino215/newres/Info_CN.plist")
		self:Push_File_Path("casino215/res/casino215/newres/bj.plist")
		self:Push_File_Path("casino215/res/casino215/newres/111.plist")
	elseif (res_game_id == 216) then
		self:Push_File_Path("casino216/res/casino216/newres/plist/fufly.plist")
		self:Push_File_Path("casino216/res/casino216/newres/plist/coin.plist")
		--self:Push_File_Path("casino216/res/casino216/big_win/coin.plist")
		self:Push_File_Path("casino216/res/casino216/newres/plist/jpLoading.plist")
		self:Push_File_Path("casino216/res/casino216/newres/plist/reelbgAndJP.plist")
		self:Push_File_Path("casino216/res/casino216/newres/plist/info_EN.plist")
		self:Push_File_Path("casino216/res/casino216/newres/plist/symbols_1.plist")
		self:Push_File_Path("casino216/res/casino216/newres/plist/symbol_2.plist")
		self:Push_File_Path("casino216/res/casino216/newres/plist/symbols.plist")
		self:Push_File_Path("casino216/res/casino216/newres/plist/prizeCN_EN.plist")
		self:Push_File_Path("casino216/res/casino216/newres/plist/FGOption.plist")
		self:Push_File_Path("casino216/res/casino216/newres/plist/background.plist")
	elseif (res_game_id == 217) then
		self:Push_File_Path("casino217/res/casino217/newres/lang_CN/JP_CN.plist")
		self:Push_File_Path("casino217/res/casino217/newres/lang_EN/JP_EN.plist")
		self:Push_File_Path("casino217/res/casino217/newres/lang_TW/JP_TW.plist")
		self:Push_File_Path("casino217/res/casino217/newres/lang_EN/INFO_EN_P1.plist")
		self:Push_File_Path("casino217/res/casino217/newres/lang_EN/INFO_EN_P2.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/batLight.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/bgEndLight.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/fgContents.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/fgEndLight.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/fgEnterLoopLight.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/fgTransEnterLight.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/fufly.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/jpLoading.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/Scatter_01.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/Scatter_02_1.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/Scatter_02_2.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/Scatter_02_3.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/Scatter_02_4.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/symbols.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/wild_01_0.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/wild_01_1.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/wild_02_0.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/wild_02_1.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/wild_02_2.plist")
		self:Push_File_Path("casino217/res/casino217/newres/plist/null.plist")
	elseif (res_game_id == 218) then
		self:Push_File_Path("casino218/res/casino218/info/Info_CN.plist")
		self:Push_File_Path("casino218/res/casino218/info/Info_EN.plist")
		self:Push_File_Path("casino218/res/casino218/newres/symbol.plist")
		self:Push_File_Path("casino218/res/casino218/newres/jpLoading.plist")
		self:Push_File_Path("casino218/res/casino218/newres/TSGAMEXZBT.plist")
		self:Push_File_Path("casino218/res/casino218/newres/CaiJinWin.plist")
		self:Push_File_Path("casino218/res/casino218/newres/lang_CN.plist")
		self:Push_File_Path("casino218/res/casino218/newres/lang_EN.plist")
		self:Push_File_Path("casino218/res/casino218/newres/symbol_1.plist")
		self:Push_File_Path("casino218/res/casino218/newres/symbol_2.plist")
		self:Push_File_Path("casino218/res/casino218/newres/background.plist")
		self:Push_File_Path("casino218/res/casino218/newres/Click_coin.plist")
	elseif (res_game_id == 219) then
		self:Push_File_Path("casino219/res/casino219/newres/plist/image.plist")
		self:Push_File_Path("casino219/res/casino219/newres/plist/jinbi.plist")
		self:Push_File_Path("casino219/res/casino219/newres/plist/lang_EN.plist")
		self:Push_File_Path("casino219/res/casino219/newres/plist/symbol.plist")
		self:Push_File_Path("casino219/res/casino219/newres/plist/shuPlist.plist")
		self:Push_File_Path("casino219/res/casino219/info/Info_EN.plist")
	elseif (res_game_id == 220) then
		self:Push_File_Path("casino220/res/casino220/newres/lang_CN/lang_CN_03.plist")
		self:Push_File_Path("casino220/res/casino220/newres/lang_EN/lang_EN_03.plist")
		self:Push_File_Path("casino220/res/casino220/newres/symbol.plist")
		self:Push_File_Path("casino220/res/casino220/newres/lang_CN/lang_CN_01.plist")
		self:Push_File_Path("casino220/res/casino220/newres/lang_CN/lang_CN_02.plist")
		self:Push_File_Path("casino220/res/casino220/newres/lang_EN/lang_EN_01.plist")
		self:Push_File_Path("casino220/res/casino220/newres/lang_EN/lang_EN_02.plist")
		self:Push_File_Path("casino220/res/casino220/newres/useless.plist")
	elseif (res_game_id == 221) then
		self:Push_File_Path("casino221/res/casino221/info/Info.plist")
		self:Push_File_Path("casino221/res/casino221/newres/plist/symbol.plist")
		self:Push_File_Path("casino221/res/casino221/newres/plist/lang_EN.plist")
		self:Push_File_Path("casino221/res/casino221/newres/plist/freeGame.plist")
		self:Push_File_Path("casino221/res/casino221/newres/plist/bg.plist")
	elseif (res_game_id == 240) then
		self:Push_File_Path("casino240/res/casino240/info/Info.plist")
		self:Push_File_Path("casino240/res/casino240/newres/plist/symbol.plist")
		self:Push_File_Path("casino240/res/casino240/newres/plist/lang_EN.plist")
		self:Push_File_Path("casino240/res/casino240/newres/plist/freeGame.plist")
		self:Push_File_Path("casino240/res/casino240/newres/plist/bg.plist")
	elseif (res_game_id == 222) then
		self:Push_File_Path("casino222/res/casino222/info/Info.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/symbol.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/lang_EN.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/caijin.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/catch_board.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/dollar.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/jp_frame.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_bonus.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_bonus_board.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_catch.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_catch_board.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_catch_start_btn.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_jp.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_jp_board_grand.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_jp_board_major.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_jp_board_mini.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_jp_board_minor.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_light.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_normal.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_normal_board.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/pop_win.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/wheel_big_light.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/wheel_board.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/wheel_board_1.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/wheel_board_2.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/wheel_btn.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/wheel_change.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/wheel_point_1.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/wheel_point_2.plist")
		self:Push_File_Path("casino222/res/casino222/newres/plist/wheel_small_light.plist")
	elseif (res_game_id == 223) then
		self:Push_File_Path("casino223/res/casino223/newres/lang_CN/lang_CN_03.plist")
		self:Push_File_Path("casino223/res/casino223/newres/lang_EN/lang_EN_03.plist")
		self:Push_File_Path("casino223/res/casino223/newres/symbol.plist")
		self:Push_File_Path("casino223/res/casino223/newres/lang_CN/lang_CN_01.plist")
		self:Push_File_Path("casino223/res/casino223/newres/lang_CN/lang_CN_02.plist")
		self:Push_File_Path("casino223/res/casino223/newres/lang_EN/lang_EN_01.plist")
		self:Push_File_Path("casino223/res/casino223/newres/lang_EN/lang_EN_02.plist")
		self:Push_File_Path("casino223/res/casino223/newres/useless.plist")
		self:Push_File_Path("casino223/res/casino223/newres/freecell.plist")
	elseif (res_game_id == 224) then
		self:Push_File_Path("casino224/res/casino224/newres/plist/lizi_h5.plist")
		self:Push_File_Path("casino224/res/casino224/newres/plist/fakebtn.plist")
		self:Push_File_Path("casino224/res/casino224/newres/plist/symbol.plist")
		self:Push_File_Path("casino224/res/casino224/newres/plist/lizi_h2.plist")
		self:Push_File_Path("casino224/res/casino224/newres/lang_EN/lang_EN_01.plist")
		self:Push_File_Path("casino224/res/casino224/newres/lang_EN/lang_EN_02.plist")
		self:Push_File_Path("casino224/res/casino224/newres/lang_EN/lang_EN_03.plist")
		self:Push_File_Path("casino224/res/casino224/newres/plist/useless.plist")
		self:Push_File_Path("casino224/res/casino224/newres/plist/lizi_h3.plist")
		self:Push_File_Path("casino224/res/casino224/newres/plist/lizi_h4.plist")
		self:Push_File_Path("casino224/res/casino224/newres/lang_CN/lang_CN_01.plist")
		self:Push_File_Path("casino224/res/casino224/newres/lang_CN/lang_CN_02.plist")
		self:Push_File_Path("casino224/res/casino224/newres/lang_CN/lang_CN_03.plist")
	elseif (res_game_id == 225) then
		self:Push_File_Path("casino225/res/casino225/newres/plist/background.plist")
		self:Push_File_Path("casino225/res/casino225/newres/plist/info_123_CN.plist")
		self:Push_File_Path("casino225/res/casino225/newres/plist/info_45_CN.plist")
		self:Push_File_Path("casino225/res/casino225/newres/plist/info_123_EN.plist")
		self:Push_File_Path("casino225/res/casino225/newres/plist/info_45_EN.plist")
		self:Push_File_Path("casino225/res/casino225/newres/plist/column.plist")
		self:Push_File_Path("casino225/res/casino225/newres/plist/symbol.plist")
		self:Push_File_Path("casino225/res/casino225/newres/plist/BGTimes_coin.plist")
	elseif (res_game_id == 226) then
		self:Push_File_Path("casino226/res/casino226/newres/plist/symbol.plist")
		self:Push_File_Path("casino226/res/casino226/newres/plist/Info.plist")
		self:Push_File_Path("casino226/res/casino226/newres/plist/Spe_icons.plist")
		self:Push_File_Path("casino226/res/casino226/newres/plist/Spe_icons1.plist")
		self:Push_File_Path("casino226/res/casino226/newres/plist/Spe_icons2.plist")
	elseif (res_game_id == 227) then
	elseif (res_game_id == 228) then
	elseif (res_game_id == 229) then
		self:Push_File_Path("casino229/res/casino229/newres/plist/symbol.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/lsymbol.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/info_1_3_CN.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/info_4_6_CN.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/info_1_3_EN.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/info_4_6_EN.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/FrameAndBG.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/BGPic.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/lottery.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/lineElements.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/jpLoading.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/FGorSG_UI.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/bgBeforeEnterAnimation.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/bgBeforeEnterLightning0.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/bgBeforeEnterLightning1.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/chipBoundingLightning.plist")
		self:Push_File_Path("casino229/res/casino229/newres/plist/lightnings.plist")
	elseif (res_game_id == 230) then
		self:Push_File_Path("casino230/res/casino230/plist/symbol.plist")
		self:Push_File_Path("casino230/res/casino230/lang_CN/lang_CN.plist")
		self:Push_File_Path("casino230/res/casino230/lang_EN/lang_EN.plist")
		self:Push_File_Path("casino230/res/casino230/lang_TW/lang_TW.plist")
		self:Push_File_Path("casino230/res/casino230/plist/background.plist")
		self:Push_File_Path("casino230/res/casino230/plist/column.plist")
		self:Push_File_Path("casino230/res/casino230/plist/firework-0.plist")
		self:Push_File_Path("casino230/res/casino230/plist/otherplist.plist")
		self:Push_File_Path("casino230/res/casino230/plist/breakbtn.plist")
	elseif (res_game_id == 231) then
		self:Push_File_Path("casino231/res/casino231/info/Info_CN.plist")
		self:Push_File_Path("casino231/res/casino231/info/Info_EN.plist")
		self:Push_File_Path("casino231/res/casino231/newres/symbol.plist")
		self:Push_File_Path("casino231/res/casino231/newres/jpLoading.plist")
		self:Push_File_Path("casino231/res/casino231/newres/CaiJinWin.plist")
		self:Push_File_Path("casino231/res/casino231/newres/lang_CN.plist")
		self:Push_File_Path("casino231/res/casino231/newres/lang_EN.plist")
		self:Push_File_Path("casino231/res/casino231/newres/symbol.plist")
		self:Push_File_Path("casino231/res/casino231/newres/symbol_2.plist")
		self:Push_File_Path("casino231/res/casino231/newres/Click_coin.plist")
		self:Push_File_Path("casino231/res/casino231/newres/btnPic.plist")
	elseif (res_game_id == 232) then
		self:Push_File_Path("casino232/res/casino232/plist/initBGPic.plist")
		self:Push_File_Path("casino232/res/casino232/plist/backgroundBG.plist")
		self:Push_File_Path("casino232/res/casino232/plist/info_01_03.plist")
		self:Push_File_Path("casino232/res/casino232/plist/symbol.plist")
		self:Push_File_Path("casino232/res/casino232/plist/font_EN.plist")
		self:Push_File_Path("casino232/res/casino232/plist/FGandJP_UI.plist")
	elseif (res_game_id == 233) then
		self:Push_File_Path("casino233/res/casino233/plist/info.plist")
		self:Push_File_Path("casino233/res/casino233/plist/symbol.plist")
	elseif (res_game_id == 234) then
		self:Push_File_Path("casino234/res/casino234/plist/symbol.plist")
		self:Push_File_Path("casino234/res/casino234/plist/symbolLights.plist")
		self:Push_File_Path("casino234/res/casino234/plist/info_01_02_EN.plist")
		self:Push_File_Path("casino234/res/casino234/plist/reel.plist")
		self:Push_File_Path("casino234/res/casino234/plist/jpLight1.plist")
		self:Push_File_Path("casino234/res/casino234/plist/jpLight2.plist")
		self:Push_File_Path("casino234/res/casino234/plist/jpLight3.plist")
		self:Push_File_Path("casino234/res/casino234/plist/jpLight4.plist")
		self:Push_File_Path("casino234/res/casino234/plist/jpframe.plist")
		self:Push_File_Path("casino234/res/casino234/plist/JP_1_4_CN_EN.plist")
		self:Push_File_Path("casino234/res/casino234/plist/spinCellLights.plist")
		self:Push_File_Path("casino234/res/casino234/plist/bigWinIllumination_0.plist")
		self:Push_File_Path("casino234/res/casino234/plist/bigWinIllumination_1.plist")
		self:Push_File_Path("casino234/res/casino234/plist/specialSpinBtn.plist")
		self:Push_File_Path("casino234/res/casino234/plist/specialWheel.plist")
		self:Push_File_Path("casino234/res/casino234/plist/spinButtonLight.plist")
		self:Push_File_Path("casino234/res/casino234/plist/specialDeng.plist")
		self:Push_File_Path("casino234/res/casino234/plist/wheelOnEnterStars_0.plist")
		self:Push_File_Path("casino234/res/casino234/plist/wheelOnEnterStars_1.plist")
		self:Push_File_Path("casino234/res/casino234/plist/wheelOnEnterStars_2.plist")
		self:Push_File_Path("casino234/res/casino234/plist/wheelOnEnterStars_3.plist")
		self:Push_File_Path("casino234/res/casino234/plist/wheelOnEnterStars_4.plist")
		self:Push_File_Path("casino234/res/casino234/plist/bonusSpinClickedStars_0.plist")
		self:Push_File_Path("casino234/res/casino234/plist/bonusSpinClickedStars_1.plist")
		self:Push_File_Path("casino234/res/casino234/plist/winboardcontents.plist")
		self:Push_File_Path("casino234/res/casino234/plist/coinSpring0.plist")
		self:Push_File_Path("casino234/res/casino234/plist/coinSpring1.plist")
		self:Push_File_Path("casino234/res/casino234/plist/coinSpring2.plist")
		self:Push_File_Path("casino234/res/casino234/plist/coinSpring3.plist")
		self:Push_File_Path("casino234/res/casino234/plist/winboardlight.plist")
		self:Push_File_Path("casino234/res/casino234/plist/winjp.plist")
		self:Push_File_Path("casino234/res/casino234/plist/jpLoading.plist")
		self:Push_File_Path("casino234/res/casino234/FruitGame/DropFishGame.plist")
		self:Push_File_Path("casino234/res/casino234/FruitGame/DropFishBG.plist")
		self:Push_File_Path("casino234/res/casino234/FruitGame/FruitGame.plist")
	elseif (res_game_id == 251) then
		self:Push_File_Path("casino251/res/casino251/newres/plist/symbol.plist")
		self:Push_File_Path("casino251/res/casino251/newres/plist/image.plist")
		self:Push_File_Path("casino251/res/casino251/newres/plist/lang_EN.plist")
		self:Push_File_Path("casino251/res/casino251/newres/plist/lang_EN1.plist")
		self:Push_File_Path("casino251/res/casino251/newres/plist/lang_EN2.plist")
		self:Push_File_Path("casino251/res/casino251/newres/plist/caijin.plist")
	elseif (res_game_id == 252) then
		self:Push_File_Path("casino252/res/casino252/images.plist")
		self:Push_File_Path("casino252/res/casino252/symbol.plist")
		self:Push_File_Path("casino252/res/casino252/infos/infos.plist")
	elseif (res_game_id == 255) then
	
		self:Push_File_Path("casino255/res/casino255/newres/plist/symbol.plist")
		self:Push_File_Path("casino255/res/casino255/newres/plist/image.plist")
		self:Push_File_Path("casino255/res/casino255/newres/plist/lang_EN.plist")
		self:Push_File_Path("casino255/res/casino255/newres/plist/lang_EN1.plist")
		self:Push_File_Path("casino255/res/casino255/newres/plist/lang_EN2.plist")
		self:Push_File_Path("casino255/res/casino255/newres/plist/caijin.plist")
	elseif (res_game_id == 256) then
		self:Push_File_Path("casino256/res/casino256/texturePlist_1.plist")
		self:Push_File_Path("casino256/res/casino256/infos.plist")
		self:Push_File_Path("casino256/res/casino256/symbol.plist")
	elseif (res_game_id == 257) then
		self:Push_File_Path("casino257/res/casino257/newres/plist/symbol.plist")
		self:Push_File_Path("casino257/res/casino257/newres/plist/image.plist")
		self:Push_File_Path("casino257/res/casino257/newres/plist/lang_EN.plist")
		self:Push_File_Path("casino257/res/casino257/newres/plist/lang_EN1.plist")
		self:Push_File_Path("casino257/res/casino257/newres/plist/lang_EN2.plist")
	elseif (res_game_id == 258) then
		self:Push_File_Path("casino258/res/casino258/symbol.plist")
		self:Push_File_Path("casino258/res/casino258/slots_258_infos.plist")
		self:Push_File_Path("casino258/res/casino258/image.plist")
	elseif (res_game_id == 259) then
		self:Push_File_Path("casino259/res/casino259/259CaiJinBar.plist")
		self:Push_File_Path("casino259/res/casino259/259symbol.plist")
		self:Push_File_Path("casino259/res/casino259/259Infos.plist")
		self:Push_File_Path("casino259/res/casino259/259Images.plist")
		-- self:Push_File_Path("casino259/res/casino259/newres/ppp4.plist")
		-- self:Push_File_Path("casino259/res/casino259/newres/ppp3.plist")
		-- self:Push_File_Path("casino259/res/casino259/newres/ppp2.plist")
		-- self:Push_File_Path("casino259/res/casino259/newres/ppp1.plist")
		-- self:Push_File_Path("casino259/res/casino259/newres/symbol.plist")
		-- self:Push_File_Path("casino259/res/casino259/newres/lang_EN2.plist")
		-- self:Push_File_Path("casino259/res/casino259/newres/lang_EN1.plist")
		-- self:Push_File_Path("casino259/res/casino259/newres/lang_EN.plist")
		-- self:Push_File_Path("casino259/res/casino259/newres/lang_CN.plist") 
		-- self:Push_File_Path("casino259/res/casino259/newres/kongbai.plist") 
	elseif (res_game_id == 260) then
		self:Push_File_Path("casino260/res/casino260/images.plist")
		self:Push_File_Path("casino260/res/casino260/infos.plist")
		self:Push_File_Path("casino260/res/casino260/symbol.plist")
	elseif (res_game_id == 270) then
		self:Push_File_Path("casino_common/res/fafafa/lines.plist")
		self:Push_File_Path("casino270/res/casino270/plists/images.plist")
		self:Push_File_Path("casino270/res/casino270/plists/symbol.plist")
	elseif (res_game_id == 271) then
		self:Push_File_Path("casino271/res/casino271/slots_271_freegame.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_image.plist")
		self:Push_File_Path("casino271/res/casino271/symbol_271_info.plist")
		self:Push_File_Path("casino271/res/casino271/symbol271.plist")
		self:Push_File_Path("casino271/res/casino271/freeintofree271.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/green_end271.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/green_loop271.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/kuang_left.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/kuang_middle.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/kuang_right.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/red_end271.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/red_loop271.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/slide271.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/wildanim_green.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/wildanim_pink.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/wildanim_red.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/wildanim_yellow.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/yellow_end271.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/yellow_loop271.plist")
		self:Push_File_Path("casino271/res/casino271/slots_271_animations/advanceAnim.plist")
	elseif (res_game_id == 272) then
		 self:Push_File_Path("casino272/res/casino272/slots_272_freegame.plist")
		 self:Push_File_Path("casino272/res/casino272/slots_272_image.plist")
		 self:Push_File_Path("casino272/res/casino272/symbol272.plist")
		 self:Push_File_Path("casino272/res/casino272/slots_272_animations/nvwaintro.plist")
		 self:Push_File_Path("casino272/res/casino272/slots_272_animations/nvwaloop.plist")
		 self:Push_File_Path("casino272/res/casino272/slots_272_animations/pop_up.plist")
		 self:Push_File_Path("casino272/res/casino272/slots_272_animations/replace.plist")
		 self:Push_File_Path("casino272/res/casino272/slots_272_animations/wildintro.plist")
		 self:Push_File_Path("casino272/res/casino272/slots_272_animations/wildintro_2x.plist")
		 self:Push_File_Path("casino272/res/casino272/slots_272_animations/wildloop.plist")
		 self:Push_File_Path("casino272/res/casino272/slots_272_animations/wildloop_2x.plist")
	elseif (res_game_id == 273) then
		self:Push_File_Path("casino273/res/casino273/slots_273_freegame.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_image.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_special.plist")
		self:Push_File_Path("casino273/res/casino273/symbol_273_info.plist")
		self:Push_File_Path("casino273/res/casino273/symbol273.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_multiplx.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_animations/slots273_coin.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_animations/slots273_copper.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_animations/slots273_fan.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_animations/slots273_koi_1.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_animations/slots273_koi_2.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_animations/slots273_koi_3.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_animations/slots273_koi_4.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_animations/slots273_koi_5.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_animations/slots273_koi_main.plist")
		self:Push_File_Path("casino273/res/casino273/slots_273_animations/slots273_red_envelopes.plist")
	elseif (res_game_id == 274) then
		self:Push_File_Path("casino274/res/casino274/274_symbol.plist")
		self:Push_File_Path("casino274/res/casino274/274_win_symbol.plist")
		self:Push_File_Path("casino274/res/casino274/274_freeGames.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_fg_frame.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_fg_scroll.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_fg_x2.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_fg_x3.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_fg_x5.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_fg_x8.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_fg_x10.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_fg_x15.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_fg_x30.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_red_envelopes.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_versatile.plist")
		self:Push_File_Path("casino274/res/casino274/animations/slots274_yuanbao.plist")
	elseif (res_game_id == 275) then
		self:Push_File_Path("casino275/res/casino275/slots_275_freegame.plist")
		self:Push_File_Path("casino275/res/casino275/slots_275_image.plist")
		self:Push_File_Path("casino275/res/casino275/symbol_275_info.plist")
		self:Push_File_Path("casino275/res/casino275/symbol275.plist")
		self:Push_File_Path("casino275/res/casino275/slots_275_multiplx.plist")
		self:Push_File_Path("casino275/res/casino275/slots_275_animations/multi_base.plist")
		self:Push_File_Path("casino275/res/casino275/slots_275_animations/slots275_flame.plist")
		self:Push_File_Path("casino275/res/casino275/slots_275_animations/slots275_gold_coin.plist")
		self:Push_File_Path("casino275/res/casino275/slots_275_animations/slots275_red_envelopes.plist")
	elseif (res_game_id == 276) then
		self:Push_File_Path("casino_common/res/fafafa/lines.plist")
		self:Push_File_Path("casino276/res/casino276/plist/slots_276_image.plist")
		self:Push_File_Path("casino276/res/casino276/plist/slots_276_symbol.plist")
		self:Push_File_Path("casino276/res/casino276/plist/slots_276_win_symbol.plist")
	elseif (res_game_id == 277) then
		self:Push_File_Path("casino_common/res/fafafa/lines.plist")
		self:Push_File_Path("casino277/res/casino277/plist/image.plist")
		self:Push_File_Path("casino277/res/casino277/plist/symbol.plist")
	elseif (res_game_id == 278) then
		self:Push_File_Path("casino278/res/casino278/plist/278_image.plist")
		self:Push_File_Path("casino278/res/casino278/plist/278_symbol.plist")
		self:Push_File_Path("casino278/res/casino278/plist/278_win_symbol.plist")
	elseif (res_game_id == 279) then
		self:Push_File_Path("casino279/res/casino279/slots_279_freegame.plist")
		self:Push_File_Path("casino279/res/casino279/slots_279_image.plist")
		self:Push_File_Path("casino279/res/casino279/symbol_279_info.plist")
		self:Push_File_Path("casino279/res/casino279/symbol279.plist")
		self:Push_File_Path("casino279/res/casino279/slots_279_animations/kuang_left.plist")
		self:Push_File_Path("casino279/res/casino279/slots_279_animations/kuang_middle.plist")
		self:Push_File_Path("casino279/res/casino279/slots_279_animations/kuang_right.plist")
		self:Push_File_Path("casino279/res/casino279/slots_279_animations/slide279.plist")
		self:Push_File_Path("casino279/res/casino279/slots_279_animations/advanceAnim.plist")
	elseif (res_game_id == 280) then
		self:Push_File_Path("casino280/res/casino280/plists/image.plist")
		self:Push_File_Path("casino280/res/casino280/plists/symbol.plist")
		self:Push_File_Path("casino280/res/casino280/plists/winLinesNumber.plist")
		self:Push_File_Path("casino280/res/casino280/plists/winLinesOther.plist")
		self:Push_File_Path("casino280/res/casino280/plists/winSymbol.plist")
	elseif (res_game_id == 281) then
		self:Push_File_Path("casino281/res/casino281/slots_281_freegame.plist")
		self:Push_File_Path("casino281/res/casino281/slots_281_image.plist")
		self:Push_File_Path("casino281/res/casino281/symbol_281_info.plist")
		self:Push_File_Path("casino281/res/casino281/symbol281.plist")
		self:Push_File_Path("casino281/res/casino281/slots_281_special.plist")
		self:Push_File_Path("casino281/res/casino281/slots_281_animations/slots281_dragon.plist")
		self:Push_File_Path("casino281/res/casino281/slots_281_animations/slots281_gold.plist")
		self:Push_File_Path("casino281/res/casino281/slots_281_animations/slots281_wild.plist")
		self:Push_File_Path("casino281/res/casino281/slots_281_animations/slots_281_coin.plist")
		self:Push_File_Path("casino281/res/casino281/slots_281_animations/slots281_wildgreen.plist")
		self:Push_File_Path("casino281/res/casino281/slots_281_animations/slots281_wildpurple.plist")
	elseif (res_game_id == 282) then
		self:Push_File_Path("casino282/res/casino282/slots_282_image.plist")
		self:Push_File_Path("casino282/res/casino282/symbol282.plist")
		self:Push_File_Path("casino282/res/casino282/anims.plist")
		self:Push_File_Path("casino282/res/casino282/anims2.plist")
	elseif (res_game_id == 283) then
		self:Push_File_Path("casino283/res/casino283/plists/slots_283_image.plist")
		self:Push_File_Path("casino283/res/casino283/plists/symbol283.plist")
		self:Push_File_Path("casino283/res/casino283/plists/winsymbol_283.plist")
	elseif (res_game_id == 287) then
		self:Push_File_Path("casino287/res/casino287/slots_287_image.plist")
		self:Push_File_Path("casino287/res/casino287/symbol287.plist")
		self:Push_File_Path("casino287/res/casino287/symbol287_info.plist")
		self:Push_File_Path("casino287/res/casino287/slots287winline.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/denglong_00000_1.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/Guan_anim00000_1.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/L88_CENTER_COM_00000_1.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/L88_CENTER_HIT_00000_1.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/L88_CENTER_MISS_00000_1.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/L88_OUTER_COM_00000_1.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/L88_OUTER_HIT_00000_1.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/L88_OUTER_INIT_00000_1.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/L88_OUTER_LCOM_00000_1.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/L88_OUTER_LHIT_00000_1.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/L88_OUTER_LMISS_00000_1.plist")
		self:Push_File_Path("casino287/res/casino287/slots_287_animations/L88_OUTER_MISS_00000_1.plist")
	elseif (res_game_id == 288) then
		self:Push_File_Path("casino288/res/casino288/plist/image.plist")
		self:Push_File_Path("casino288/res/casino288/plist/symbol.plist")
		self:Push_File_Path("casino288/res/casino288/plist/winsymbol.plist")
		self:Push_File_Path("casino288/res/casino288/plist/Asian_Roar.plist")
		self:Push_File_Path("casino288/res/casino288/plist/ReSpin.plist")
		self:Push_File_Path("casino288/res/casino288/plist/ZipZap.plist")
	elseif (res_game_id == 289) then
		self:Push_File_Path("casino289/plists/image.plist")
		self:Push_File_Path("casino289/plists/symbol.plist")
		self:Push_File_Path("casino289/plists/winsymbol.plist")
	elseif (res_game_id == 291) then
		self:Push_File_Path("casino_common/res/fafafa/lines.plist")
		self:Push_File_Path("casino291/Plists/CellIcon.plist")
		self:Push_File_Path("casino291/Plists/WinIcon.plist")
	elseif (res_game_id == 292) then
		self:Push_File_Path("casino_common/res/fafafa/lines.plist")
		self:Push_File_Path("casino292/Plists/CellIcon.plist")
		self:Push_File_Path("casino292/Plists/WinIcon.plist")
	elseif (res_game_id == 293) then
		self:Push_File_Path("casino293/res/casino293/slots_293_freegame.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_image.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_imageadd.plist")
		self:Push_File_Path("casino293/res/casino293/symbol293.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_multiplx.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/Wild_Gold_00000_1.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/Wild_00000_1.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/Sparks_1_00000_1.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/Scatter_00000_1.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/Pic_5_00000_1.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/Pic_4_00000_1.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/Pic_3_00000_1.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/Pic_2_00000_1.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/Pic_1_00000_1.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/FLOWER_L_000_1.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/FLOWER_L_00000_1.plist")
		self:Push_File_Path("casino293/res/casino293/slots_293_animations/ANIM_INDICATOR_PULSATING_0000.plist")
	elseif (res_game_id == 294) then
		self:Push_File_Path("casino294/res/casino294/slots_294_freegame.plist")
		self:Push_File_Path("casino294/res/casino294/slots_294_image.plist")
		self:Push_File_Path("casino294/res/casino294/symbol294.plist")
		self:Push_File_Path("casino294/res/casino294/slots_294_animations/multi_base.plist")
		self:Push_File_Path("casino294/res/casino294/slots_294_animations/slots_294_multiplx.plist")
		self:Push_File_Path("casino294/res/casino294/slots_294_animations/5Kings_BagFinal.plist")
		self:Push_File_Path("casino294/res/casino294/slots_294_animations/5Kings_Bird.plist")
		self:Push_File_Path("casino294/res/casino294/slots_294_animations/Coin0000.plist")
	elseif (res_game_id == 295) then
		self:Push_File_Path("casino295/Plists/CellIcon.plist")
		self:Push_File_Path("casino295/Plists/WinIcon.plist")
		self:Push_File_Path("casino295/Plists/Image.plist")
	elseif (res_game_id == 296) then
		self:Push_File_Path("casino296/Plists/Image.plist")
	elseif (res_game_id == 297) then
		self:Push_File_Path("casino_common/res/fafafa/lines.plist")
		self:Push_File_Path("casino297/Plists/Image.plist")
		self:Push_File_Path("casino297/Plists/CellIcon.plist")
		self:Push_File_Path("casino297/Plists/WinIcon.plist")
	elseif (res_game_id == 298) then
self:Push_File_Path("casino298/res/casino298/slots_298_freegame.plist")
		self:Push_File_Path("casino298/res/casino298/slots_298_image.plist")
		self:Push_File_Path("casino298/res/casino298/symbol298.plist")
		self:Push_File_Path("casino298/res/casino298/slots_298_animations/Coin0000.plist")
		self:Push_File_Path("casino298/res/casino298/slots_298_animations/Scatter_0000.plist")
		self:Push_File_Path("casino298/res/casino298/slots_298_animations/WildAnim_00.plist")
	elseif (res_game_id == 299) then
		self:Push_File_Path("casino299/res/casino299/slots_299_freegame.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_image.plist")
		self:Push_File_Path("casino299/res/casino299/symbol299.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/Wild_Buddha1.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x1_Appear_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x2_Appear_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x3_Appear_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x4_Appear_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x5_Appear_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x6_Appear_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x7_Appear_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x8_Appear_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x9_Appear_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x10_Appear_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x1_Fade_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x2_Fade_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x3_Fade_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x4_Fade_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x5_Fade_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x6_Fade_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x7_Fade_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x8_Fade_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/x9_Fade_00000.plist")
		self:Push_File_Path("casino299/res/casino299/slots_299_animations/slots299_freeicon.plist")
	elseif (res_game_id == 301) then
		self:Push_File_Path("casino301/res/casino301/Plists/Animations_1.plist")
		self:Push_File_Path("casino301/res/casino301/Plists/Animations_2.plist")
		self:Push_File_Path("casino301/res/casino301/Plists/Image.plist")
		self:Push_File_Path("casino301/res/casino301/Plists/Lines.plist")
	elseif (res_game_id == 302) then
		self:Push_File_Path("casino302/res/casino302/Plists/CellIcon.plist")
		self:Push_File_Path("casino302/res/casino302/Plists/Image.plist")
	elseif (res_game_id == 303) then
		self:Push_File_Path("casino303/res/casino303/slots_303_freegame.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_image.plist")
		self:Push_File_Path("casino303/res/casino303/symbol303.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_Banner_12_ExFG_0000_1.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_Banner_12_ExFG_0030_1.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_Banner_12_FG_0000_1.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_Banner_12_FG_0030_1.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_Banner_Bkg_0000_1.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_Banner_Bkg_0030_1.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_ExRSF_Text_00000_1.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_x2_End_00000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_x2_Intro_00000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_x3_End_00000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_x3_Intro_00000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_x5_End_00000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/IMG_x5_Intro_00000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/Nudge_1_Down_000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/Nudge_1_Up_000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/Nudge_2_Down_000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/Nudge_2_Up_000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/Nudge_3_Down_000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/Nudge_3_Up_000.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/Scatter_00_1.plist")
		self:Push_File_Path("casino303/res/casino303/slots_303_animations/Wild_00_1.plist")
	elseif (res_game_id == 304) then
		self:Push_File_Path("casino304/res/casino304/slots_304_freegame.plist")
		self:Push_File_Path("casino304/res/casino304/slots_304_image.plist")
		self:Push_File_Path("casino304/res/casino304/symbol304.plist")
		self:Push_File_Path("casino304/res/casino304/slots_304_animations/Scatter_000.plist")
		self:Push_File_Path("casino304/res/casino304/slots_304_animations/Wild_000.plist")
		self:Push_File_Path("casino304/res/casino304/slots_304_animations/WildRespin_000.plist")
	elseif (res_game_id == 305) then
		self:Push_File_Path("casino305/res/casino305/Plists/Image.plist")
		self:Push_File_Path("casino305/res/casino305/Plists/Animations.plist")
	elseif (res_game_id == 306) then
		self:Push_File_Path("casino306/res/casino306/slots_306_freegame.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_image.plist")
		self:Push_File_Path("casino306/res/casino306/symbol306.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/Earth_Cloud_Closing0032.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/Earth_Cloud_Opening0000.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/Heaven_Cloude_Closing_0032.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/Heaven_Cloude_Opening_0000.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/Multiplier_x2_0000.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/Multiplier_x5_0000.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/Multiplier_x10_0000.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/Multiplier_x25_0000.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/Multiplier_x50_0000.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/Wild2_Cloude_Loop_00000.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/Wild1_Cloude_Loop_00000.plist")
		self:Push_File_Path("casino306/res/casino306/slots_306_animations/YY_Loop_0000.plist")
	elseif (res_game_id == 307) then
		self:Push_File_Path("casino307/res/casino307/slots_307_freegame.plist")
		self:Push_File_Path("casino307/res/casino307/slots_307_image.plist")
		self:Push_File_Path("casino307/res/casino307/symbol307.plist")
		self:Push_File_Path("casino307/res/casino307/slots_307_animations/DF_sp_extendedwild_2_0001.plist")
		self:Push_File_Path("casino307/res/casino307/slots_307_animations/DF_sp_sym_wild_ext_0000.plist")
		self:Push_File_Path("casino307/res/casino307/slots_307_animations/DF_sp_sym_wild_stars_0000.plist")
		self:Push_File_Path("casino307/res/casino307/slots_307_animations/scat_0000.plist")
		self:Push_File_Path("casino307/res/casino307/slots_307_animations/pic1_0000.plist")
		self:Push_File_Path("casino307/res/casino307/slots_307_animations/pic2_0000.plist")
	elseif (res_game_id == 309) then
		-- self:Push_File_Path("casino309/res/casino309/slots_309_freegame.plist")
		self:Push_File_Path("casino309/res/casino309/slots_309_image.plist")
		self:Push_File_Path("casino309/res/casino309/symbol309.plist")	
	elseif (res_game_id == 310) then
		self:Push_File_Path("casino310/res/casino310/Plist/RulePicture.plist")
		self:Push_File_Path("casino310/res/casino310/Plist/Image.plist")
		self:Push_File_Path("casino310/res/casino310/Plist/Symbol.plist")
	elseif (res_game_id == 311) then
		self:Push_File_Path("casino311/res/casino311/Plist/Icons.plist")
		self:Push_File_Path("casino311/res/casino311/Plist/Image.plist")
		self:Push_File_Path("casino311/res/casino311/Plist/Rule.plist")
	elseif (res_game_id == 313) then
		for i=1,13 do
			self:Push_File_Path(string.format("casino313/res/casino313/plist/animation_%d.plist",i))
		end
		self:Push_File_Path("casino313/res/casino313/plist/icons.plist")
		self:Push_File_Path("casino313/res/casino313/plist/images.plist")
	elseif (res_game_id == 315) then
		self:Push_File_Path("casino315/res/casino315/Plist/rulepicture.plist")
		self:Push_File_Path("casino315/res/casino315/Plist/Image.plist")
		self:Push_File_Path("casino315/res/casino315/Plist/315Symbol.plist")
	elseif (res_game_id == 317) then
		self:Push_File_Path("casino317/res/casino317/317CaiJinBar.plist")
		self:Push_File_Path("casino317/res/casino317/317symbol.plist")
		self:Push_File_Path("casino317/res/casino317/317Infos.plist")
		self:Push_File_Path("casino317/res/casino317/317Images.plist")
	elseif (res_game_id == 325) then
		self:Push_File_Path("casino325/res/casino325/325CaiJinBar.plist")
		self:Push_File_Path("casino325/res/casino325/325symbol.plist")
		self:Push_File_Path("casino325/res/casino325/325Infos.plist")
		self:Push_File_Path("casino325/res/casino325/325Images.plist")
	elseif (res_game_id == 318) then
		self:Push_File_Path("casino318/res/casino318/318CaiJinBar.plist")
		self:Push_File_Path("casino318/res/casino318/318symbol.plist")
		self:Push_File_Path("casino318/res/casino318/318Infos.plist")
		self:Push_File_Path("casino318/res/casino318/318Images.plist")
	elseif (res_game_id == 319) then
		self:Push_File_Path("casino319/res/casino319/symbol.plist")
		self:Push_File_Path("casino319/res/casino319/slots_319_infos.plist")
		self:Push_File_Path("casino319/res/casino319/image.plist")
	elseif (res_game_id == 320) then
		self:Push_File_Path("casino320/res/casino320/slots_320_line.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_image.plist")
		self:Push_File_Path("casino320/res/casino320/symbol.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/longfei320.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/Corona_00000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/DragonCircleLoop_00000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/DragonExplo00000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/Flame_00.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/FlameBorder_LG_00000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/FlameBorder_SM_00000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/GrandJackpot_sparks_000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/IMG_Bolt_B_H_L_0_2_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/IMG_Bolt_B_H_L_2_0_0001.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/IMG_Bolt_B_H_L_3_2_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/IMG_Bolt_B_H_R_0_1_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/IMG_Bolt_B_H_R_1_2_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/IMG_RJP_GenTop_0066.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/IMG_TS_HandS_Orb_Dragons_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/IMG_TS_HandS_Trans_B_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/Pic1_Intro_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/Pic1_Loop_0031.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/Pic2_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/Pic3_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/Pic4_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/Scatter_Intro_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/Scatter_Loop_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/WildBG_Intro_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/WildBG_Loop_0000.plist")
		self:Push_File_Path("casino320/res/casino320/slots_320_animations/Maitreya_loop.plist")
	elseif (res_game_id == 321) then
		self:Push_File_Path("casino321/res/casino321/slots_321_line.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_image.plist")
		self:Push_File_Path("casino321/res/casino321/symbol.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/longfei321.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Corona_00000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/DragonCircleLoop_00000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/DragonExplo00000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/IMG_RJP_GenTop_0066.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/IMG_TS_HandS_Orb_Dragons_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/IMG_TS_HandS_Trans_B_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Pic1_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Pic2_Intro_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Pic2_Loop_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Pic3_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Pic4_Intro_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Pic4_Loop_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Reveal_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Scatter_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Wild1UP_Intro_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Wild1UP_Loop_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Wild2UP_Intro_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Wild2UP_Loop_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Wild3UP_Intro_0000.plist")
		self:Push_File_Path("casino321/res/casino321/slots_321_animations/Wild3UP_Loop_0000.plist")
	elseif (res_game_id == 322) then
		self:Push_File_Path("casino322/res/casino322/slots_322_line.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_image.plist")
		self:Push_File_Path("casino322/res/casino322/symbol.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/longfei322.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Corona_00000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/DragonCircleLoop_00000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/DragonExplo00000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/IMG_RJP_GenTop_0066.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/IMG_TS_HandS_Orb_Dragons_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/IMG_TS_HandS_Trans_B_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Pic1_Intro_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Pic1_Loop_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Pic2_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Pic3_Intro_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Pic3_Loop_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Pic4_Intro_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Pic4_Loop_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Reveal_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Scatter_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Wild1UP_Intro_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Wild1UP_Loop_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Wild2UP_Intro_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Wild2UP_Loop_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Wild3UP_Intro_0000.plist")
		self:Push_File_Path("casino322/res/casino322/slots_322_animations/Wild3UP_Loop_0000.plist")
	elseif (res_game_id == 323) then
		self:Push_File_Path("casino323/res/casino323/slots_323_line.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_image.plist")
		self:Push_File_Path("casino323/res/casino323/symbol.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Corona_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/DragonCircleLoop_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/DragonExplo00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Flame_00.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/FlameBorder_LG_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/FlameBorder_SM_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/GrandJackpot_sparks_000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/IMG_Bolt_B_H_L_0_2_0000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/IMG_Bolt_B_H_L_2_0_0001.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/IMG_Bolt_B_H_L_3_2_0000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/IMG_Bolt_B_H_R_0_1_0000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/IMG_Bolt_B_H_R_1_2_0000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/IMG_RJP_GenTop_0066.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/IMG_TS_HandS_Orb_Dragons_0000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/IMG_TS_HandS_Trans_B_0000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Pic1_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Pic2_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Pic3_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Pic4_Mega_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/ScatterMega_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Wild1UP_Intro_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Wild1UP_Loop_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Wild2UP_Intro_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Wild2UP_Loop_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Wild3UP_Intro_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/Wild3UP_Loop_00000.plist")
		self:Push_File_Path("casino323/res/casino323/slots_323_animations/longfei.plist")
	elseif (res_game_id == 331) then
		self:Push_File_Path("casino331/res/casino331/newres/plist/fufly.plist")
		self:Push_File_Path("casino331/res/casino331/newres/plist/coin.plist")
		--self:Push_File_Path("casino331/res/casino331/big_win/coin.plist")
		self:Push_File_Path("casino331/res/casino331/newres/plist/jpLoading.plist")
		self:Push_File_Path("casino331/res/casino331/newres/plist/reelbgAndJP.plist")
		self:Push_File_Path("casino331/res/casino331/newres/plist/info_EN.plist")
		self:Push_File_Path("casino331/res/casino331/newres/plist/symbols_1.plist")
		self:Push_File_Path("casino331/res/casino331/newres/plist/symbol_2.plist")
		self:Push_File_Path("casino331/res/casino331/newres/plist/symbols.plist")
		self:Push_File_Path("casino331/res/casino331/newres/plist/prizeCN_EN.plist")
		self:Push_File_Path("casino331/res/casino331/newres/plist/FGOption.plist")
		self:Push_File_Path("casino331/res/casino331/newres/plist/background.plist")
	elseif (res_game_id == 332) then
		self:Push_File_Path("casino332/res/casino332/info/Info.plist")
		self:Push_File_Path("casino332/res/casino332/newres/plist/symbol.plist")
		self:Push_File_Path("casino332/res/casino332/newres/plist/lang_EN.plist")
		self:Push_File_Path("casino332/res/casino332/newres/plist/freeGame.plist")
		self:Push_File_Path("casino332/res/casino332/newres/plist/bg.plist")
	elseif (res_game_id == 333) then
		self:Push_File_Path("casino333/res/casino333/plist/symbol.plist")
		self:Push_File_Path("casino333/res/casino333/lang_CN/lang_CN.plist")
		self:Push_File_Path("casino333/res/casino333/lang_EN/lang_EN.plist")
		self:Push_File_Path("casino333/res/casino333/lang_TW/lang_TW.plist")
		self:Push_File_Path("casino333/res/casino333/plist/background.plist")
		self:Push_File_Path("casino333/res/casino333/plist/column.plist")
		self:Push_File_Path("casino333/res/casino333/plist/firework-0.plist")
		self:Push_File_Path("casino333/res/casino333/plist/otherplist.plist")
		self:Push_File_Path("casino333/res/casino333/plist/breakbtn.plist")
	end
end

function CasinoLoading:EnterCasino()
	for name,mod in pairs(package.loaded) do
		if string.find(name, "casino_common.src") then
			package.loaded[name] = nil
		end
		
		local gamemod = string.format("casino%d.src", GameData.game_id)
		if string.find(name, gamemod) then
			package.loaded[name] = nil
		end
	end

	print("进入老虎机")
	require "casino_common.src.Casino_Common"
	require "casino_common.src.Casino_Common_Func"
	--
	gCasino_Common_Func.Re_Require("casino_common.src.Def_Casino")
	gCasino_Common_Func.Re_Require("casino_common.src.Casino_Func")
	gCasino_Common_Func.Re_Require("casino_common.src.Casino_soundFunc")
	gCasino_Common_Func.Re_Require("casino_common.src.Audio.CasinoSimpleAudioEngine")
	
	local res_game_id = self.res_game_id
	if (res_game_id >= 270) then
		gCasino_Common_Func.Re_Require("casino_common.src.FaFaFa.FaFaFaCommon")
		gCasino_Common_Func.Re_Require("casino_common.src.FaFaFa.FaFaFaConfig")
	end
	--
	sGameManager.gameState = const_game.Game_State
	MarqueeLogic:ShowNotice_Node()
	if const_game.Param[res_game_id][const_game.ScreenType] == const_game.V_Screen_Type then
		MarqueeLogic:SetNoticePos(Tools_Base.visibleSize.width/2,Tools_Base.visibleSize.height- 360 * Tools_Base.ScaleY)
		MarqueeLogic:SetNoticeType("height")
	else
		MarqueeLogic:SetNoticePos()
		MarqueeLogic:SetNoticeType("width")
	end
	local script = nil
	if (res_game_id == 205) then
		script = gCasino_Common_Func.Re_Require("casino205.src.casino205.Panel_CasinoWealthGod")
	elseif (res_game_id == 206) then
        script = gCasino_Common_Func.Re_Require("casino206.src.casino206.Panel_CasinoCandy")
	elseif (res_game_id == 207) then
        script = gCasino_Common_Func.Re_Require("casino207.src.casino207.Panel_CasinoJunior")
	elseif (res_game_id == 208) then
        script = gCasino_Common_Func.Re_Require("casino208.src.casino208.Panel_Luckydiamond")
	elseif (res_game_id == 209) then
        script = gCasino_Common_Func.Re_Require("casino209.src.casino209.Panel_CasinoJunior")
	elseif (res_game_id == 210) then
        script = gCasino_Common_Func.Re_Require("casino210.src.casino210.Panel_EMPIRE88")
	elseif (res_game_id == 211) then
        script = gCasino_Common_Func.Re_Require("casino211.src.casino211.Panel_MissBunny")
	elseif (res_game_id == 212) then
        script = gCasino_Common_Func.Re_Require("casino212.src.casino212.Panel_ShowGoddess")
	elseif (res_game_id == 213) then
        script = gCasino_Common_Func.Re_Require("casino213.src.casino213.Panel_GoldenTiger")
	elseif (res_game_id == 214) then
        script = gCasino_Common_Func.Re_Require("casino214.src.casino214.Panel_CasinoDragonRace")
	elseif (res_game_id == 215) then
        script = gCasino_Common_Func.Re_Require("casino215.src.casino215.Panel_CaiFeng")
	elseif (res_game_id == 216) then
        script = gCasino_Common_Func.Re_Require("casino216.src.casino216.Panel_Golden88")
	elseif (res_game_id == 217) then
        script = gCasino_Common_Func.Re_Require("casino217.src.casino217.Panel_CasinoJunior")
	elseif (res_game_id == 218) then
        script = gCasino_Common_Func.Re_Require("casino218.src.casino218.Panel_FortuneTree")
	elseif (res_game_id == 219) then
        script = gCasino_Common_Func.Re_Require("casino219.src.casino219.Panel_EgyptianFantasy")
	elseif (res_game_id == 220) then
        script = gCasino_Common_Func.Re_Require("casino220.src.casino220.Panel_CasinoJunior")
	elseif (res_game_id == 221) then
        script = gCasino_Common_Func.Re_Require("casino221.src.casino221.Panel_AfricanBuffalo")
	elseif (res_game_id == 240) then
        script = gCasino_Common_Func.Re_Require("casino240.src.casino240.Panel_AfricanBuffalo")
	elseif (res_game_id == 222) then
        script = gCasino_Common_Func.Re_Require("casino222.src.casino222.Panel_LuckyDollars")
	elseif (res_game_id == 223) then
        script = gCasino_Common_Func.Re_Require("casino223.src.casino223.Panel_CasinoJunior")
	elseif (res_game_id == 224) then
        script = gCasino_Common_Func.Re_Require("casino224.src.casino224.Panel_CasinoJunior")
	elseif (res_game_id == 225) then
        script = gCasino_Common_Func.Re_Require("casino225.src.casino225.Panel_Princess")
	elseif (res_game_id == 226) then
        script = gCasino_Common_Func.Re_Require("casino226.src.casino226.Panel_SpriteGlod")
	elseif (res_game_id == 227) then
	elseif (res_game_id == 228) then
	elseif (res_game_id == 229) then
        script = gCasino_Common_Func.Re_Require("casino229.src.casino229.Panel_VegasNight")
	elseif (res_game_id == 230) then
	    script = gCasino_Common_Func.Re_Require("casino230.src.casino230.Panel_CasinoJunior")
	elseif (res_game_id == 231) then
	    script = gCasino_Common_Func.Re_Require("casino231.src.casino231.Panel_RichTree")
	elseif (res_game_id == 232) then
	    script = gCasino_Common_Func.Re_Require("casino232.src.casino232.Panel_GoldenPig")
	elseif (res_game_id == 233) then
	    script = gCasino_Common_Func.Re_Require("casino233.src.casino233.Panel_DaFu_Show")
	elseif (res_game_id == 234) then
	    script = gCasino_Common_Func.Re_Require("casino234.src.casino234.Panel_Sevens")
	elseif (res_game_id == 251) then
	    script = gCasino_Common_Func.Re_Require("casino251.src.casino251.Panel_MuchHappiness")
	elseif (res_game_id == 252) then
	    script = gCasino_Common_Func.Re_Require("casino252.src.casino252.Casino252")
	elseif (res_game_id == 255) then
	    script = gCasino_Common_Func.Re_Require("casino255.src.casino255.Panel_slots255")
	elseif (res_game_id == 256) then
	    script = gCasino_Common_Func.Re_Require("casino256.src.casino256.Casino256")
	elseif (res_game_id == 257) then
	    script = gCasino_Common_Func.Re_Require("casino257.src.casino257.Panel_Duanwu")
	elseif (res_game_id == 258) then
	    script = gCasino_Common_Func.Re_Require("casino258.src.casino258.Casino258")
	elseif (res_game_id == 259) then
        -- script = gCasino_Common_Func.Re_Require("casino259.src.casino259.Panel_CasinoJunior")
        script = gCasino_Common_Func.Re_Require("casino259.src.casino259.Casino259")
	elseif (res_game_id == 260) then
	    script = gCasino_Common_Func.Re_Require("casino260.src.casino260.Casino260")
	elseif (res_game_id == 270) then
	    script = gCasino_Common_Func.Re_Require("casino270.src.casino270.Casino270")
	elseif (res_game_id == 271) then
	    script = gCasino_Common_Func.Re_Require("casino271.src.casino271.Casino271")
	elseif (res_game_id == 272) then
	    script = gCasino_Common_Func.Re_Require("casino272.src.casino272.Casino272")
	elseif (res_game_id == 273) then
	    script = gCasino_Common_Func.Re_Require("casino273.src.casino273.Casino273")
	elseif (res_game_id == 274) then
	    script = gCasino_Common_Func.Re_Require("casino274.src.casino274.Casino274")
	elseif (res_game_id == 275) then
	    script = gCasino_Common_Func.Re_Require("casino275.src.casino275.Casino275")
	elseif (res_game_id == 276) then
	    script = gCasino_Common_Func.Re_Require("casino276.src.casino276.Casino276")
	elseif (res_game_id == 277) then
	    script = gCasino_Common_Func.Re_Require("casino277.src.casino277.Casino277")
	elseif (res_game_id == 278) then
	    script = gCasino_Common_Func.Re_Require("casino278.src.casino278.Casino278")
	elseif (res_game_id == 279) then
	    script = gCasino_Common_Func.Re_Require("casino279.src.casino279.Casino279")
	elseif (res_game_id == 280) then
	    script = gCasino_Common_Func.Re_Require("casino280.src.casino280.Casino280")
	elseif (res_game_id == 281) then
	    script = gCasino_Common_Func.Re_Require("casino281.src.casino281.Casino281")
	elseif (res_game_id == 282) then
	    script = gCasino_Common_Func.Re_Require("casino282.src.casino282.Casino282")
	elseif (res_game_id == 283) then
	    script = gCasino_Common_Func.Re_Require("casino283.src.casino283.Casino283")
	elseif (res_game_id == 287) then
	    script = gCasino_Common_Func.Re_Require("casino287.src.casino287.Casino287")
	elseif (res_game_id == 288) then
	    script = gCasino_Common_Func.Re_Require("casino288.src.casino288.Casino288")
	elseif (res_game_id == 289) then
	    script = gCasino_Common_Func.Re_Require("casino289.src.casino289.Casino289")
	elseif (res_game_id == 291) then
	    script = gCasino_Common_Func.Re_Require("casino291.src.casino291.Casino291")
	elseif (res_game_id == 292) then
	    script = gCasino_Common_Func.Re_Require("casino292.src.casino292.Casino292")
	elseif (res_game_id == 293) then
	    script = gCasino_Common_Func.Re_Require("casino293.src.casino293.Casino293")
	elseif (res_game_id == 294) then
	    script = gCasino_Common_Func.Re_Require("casino294.src.casino294.Casino294")
	elseif (res_game_id == 295) then
	    script = gCasino_Common_Func.Re_Require("casino295.src.casino295.Casino295")
	elseif (res_game_id == 296) then
	    script = gCasino_Common_Func.Re_Require("casino296.src.casino296.Casino296")
	elseif (res_game_id == 297) then
	    script = gCasino_Common_Func.Re_Require("casino297.src.casino297.Casino297")
	elseif (res_game_id == 298) then
	    script = gCasino_Common_Func.Re_Require("casino298.src.casino298.Casino298")
	elseif (res_game_id == 299) then
	    script = gCasino_Common_Func.Re_Require("casino299.src.casino299.Casino299")
	elseif (res_game_id == 301) then
	    script = gCasino_Common_Func.Re_Require("casino301.src.casino301.Casino301")
	elseif (res_game_id == 302) then
	    script = gCasino_Common_Func.Re_Require("casino302.src.casino302.Casino302")
	elseif (res_game_id == 303) then
	    script = gCasino_Common_Func.Re_Require("casino303.src.casino303.Casino303")
	elseif (res_game_id == 304) then
	    script = gCasino_Common_Func.Re_Require("casino304.src.casino304.Casino304")
	elseif (res_game_id == 305) then
	    script = gCasino_Common_Func.Re_Require("casino305.src.casino305.Casino305")
	elseif (res_game_id == 306) then
	    script = gCasino_Common_Func.Re_Require("casino306.src.casino306.Casino306")
	elseif (res_game_id == 307) then
	    script = gCasino_Common_Func.Re_Require("casino307.src.casino307.Casino307")
	elseif (res_game_id == 309) then
	    script = gCasino_Common_Func.Re_Require("casino309.src.casino309.Casino309")
	elseif (res_game_id == 310) then
	    script = gCasino_Common_Func.Re_Require("casino310.src.casino310.Casino310")
	elseif (res_game_id == 311) then
	    script = gCasino_Common_Func.Re_Require("casino311.src.casino311.Casino311")
	elseif (res_game_id == 313) then
	    script = gCasino_Common_Func.Re_Require("casino313.src.casino313.Casino313")
	elseif (res_game_id == 315) then
	    script = gCasino_Common_Func.Re_Require("casino315.src.casino315.Casino315")
	elseif (res_game_id == 317) then
        script = gCasino_Common_Func.Re_Require("casino317.src.casino317.Casino317")
	elseif (res_game_id == 325) then
        script = gCasino_Common_Func.Re_Require("casino325.src.casino325.Casino325")
	elseif (res_game_id == 318) then
        script = gCasino_Common_Func.Re_Require("casino318.src.casino318.Casino318")
	elseif (res_game_id == 319) then
	    script = gCasino_Common_Func.Re_Require("casino319.src.casino319.Casino319")
	elseif (res_game_id == 320) then
	    script = gCasino_Common_Func.Re_Require("casino320.src.casino320.Casino320")
	elseif (res_game_id == 321) then
	    script = gCasino_Common_Func.Re_Require("casino321.src.casino321.Casino321")
	elseif (res_game_id == 322) then
	    script = gCasino_Common_Func.Re_Require("casino322.src.casino322.Casino322")
	elseif (res_game_id == 323) then
	    script = gCasino_Common_Func.Re_Require("casino323.src.casino323.Casino323")
	elseif (res_game_id == 331) then
        script = gCasino_Common_Func.Re_Require("casino331.src.casino331.Panel_Golden88")
	elseif (res_game_id == 332) then
        script = gCasino_Common_Func.Re_Require("casino332.src.casino332.Panel_AfricanBuffalo")
	elseif (res_game_id == 333) then
	    script = gCasino_Common_Func.Re_Require("casino333.src.casino333.Panel_CasinoJunior")
	end
	
	if script ~= nil then
		gStates_SetAsync(script)
		sGameManager.isCasinoLoaded = true
	else
		print("服务器发送的游戏ID不对，无法进入老虎机：", GameData.game_id)
		EnterLobbyPanel()
	end
end

function CasinoLoading:Push_File_Path(path)
	local len = #self.file_names
	self.file_names[len + 1] = path
end

return CasinoLoading
