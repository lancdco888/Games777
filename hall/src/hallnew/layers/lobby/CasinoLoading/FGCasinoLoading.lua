local utils = import(".utils")

local FGCasinoLoading = class("FGCasinoLoading", function()
	local node = cc.CSLoader:createNode("csb/lobby/GameLoadingLayer.csb")
	node:enableNodeEvents()
	return node
end)

function FGCasinoLoading:ctor()
	sGameManager.gameState = const_game.Lobby_To_Game_State

	self.res_game_id = GameData:GetGameID(GameData.game_id)

	self:Init()
	self:Adjust()
	self:Start()

	self:onUpdate(function(dt) self:OnUpdateLoadingBar(dt) end)

	self.curShowProgress = 0
	self.curLogicProgress = 0
end

function FGCasinoLoading:Start()
	go(function()
		if not self:DownloadModule("FGame" .. self.res_game_id) then
			return
		end

		if not self:DownloadModule("FGameCommon") then
			return
		end

        local success, ret = xpcall(function()
            self:LoadindRes()
        end, __G__TRACKBACK__)

        if not success then
            UIManager.ShowMsgBox("Error loading fgame resources.", function()
                self:removeFromParent()
                utils.GoBackLobby()
            end)
        end
	end)
end

function FGCasinoLoading:DownloadModule(module_)
	-- 无需下载
	if not sDownloadMgr.CheckModule(module_) then
		return true
	end

	self.curShowProgress = 0
	self.curLogicProgress = 0

	local done = false
	local updateFunc = function(module_)
		local percent = sDownloadMgr.updateTask[module_].percent
		self.curLogicProgress = percent
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

	if sDownloadMgr.StartDownloadTask(module_) == false then
        UIManager.ShowMsgBox("Error downloading fgame resources.", function()
            self:removeFromParent()
            utils.GoBackLobby()
        end)
		return
	end

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

function FGCasinoLoading:Init()
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

function FGCasinoLoading:Adjust()
	self:AdjustLoadingGameUI()
end

function FGCasinoLoading:AdjustLoadingGameUI()
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
		panel:setScale(ScaleMin)
		self.loading_bar:setScale(0.8)
		self.bar_fg:setScale(0.8)
		center.y = center.y - (ScaleMin*230)
	else
		panel:setScale(ScaleMin)
	end
	
	panel:setPosition(center)
end

--刷新进度条
function FGCasinoLoading:RefreshLoadingBar(progress)
    progress = math.floor(progress)
    if progress <= 0 then
        progress = 0
    elseif progress >= 100 then
        progress = 100
    end

    self.loading_bar:setPercent(progress)
    self.percent:setString(tostring(progress) .. "%")
end

function FGCasinoLoading:ChangeLoadingBar_fg_LoadingBar()
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

function FGCasinoLoading:ChangeLoadingBG()
	local res_game_id = self.res_game_id

	local bgImgUrl = string.format("FGame%d/res/Game%d/loading/bg.png", res_game_id, res_game_id)
	bgImgUrl = cc.FileUtils:getInstance():fullPathForFilename(bgImgUrl)
	if bgImgUrl ~= "" then
		local bg = self:getChildByName("bg")
		Tools.LoadTexture(bg, bgImgUrl)
	end

	local logoImg = string.format("FGame%d/res/Game%d/loading/logo.png", res_game_id, res_game_id)
	local logo = self:getChildByName("logo")
	logoImg = cc.FileUtils:getInstance():fullPathForFilename(logoImg)
	if logoImg ~= "" then
		Tools.LoadTexture(logo, logoImg)
	else
		logo:setVisible(false)
	end
end

function FGCasinoLoading:LoadindRes()
	self.curShowProgress = 0
	self.curLogicProgress = 0

	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	
	Tools.SaveSearchPaths()

	local res_game_id = self.res_game_id
	Tools.AddRelativeSearchPath("src/FGameCommon/res/")
	Tools.AddRelativeSearchPath(string.format("src/FGame%d/res/", res_game_id))

    local gameChunkFile = cc.FileUtils:getInstance():fullPathForFilename(string.format("src/FGame%d/src.chunk.zip", res_game_id, res_game_id))
    if LoadChunksFromZIP and gameChunkFile ~= "" then
        LoadChunksFromZIP(gameChunkFile)
        print("Loading Chunk:" .. gameChunkFile)
    else
        Tools.AddRelativeSearchPath(string.format("src/FGame%d/src/", res_game_id))
    end

    local commonChunkFile = cc.FileUtils:getInstance():fullPathForFilename("src/FGameCommon/src.chunk.zip")
    if LoadChunksFromZIP and commonChunkFile ~= "" then
        LoadChunksFromZIP(commonChunkFile)
        print("Loading Chunk:" .. commonChunkFile)
    else
        Tools.AddRelativeSearchPath("src/FGameCommon/src/")
    end

	RUNTIME_IN_COCOS_FISH2 = true
	require("FGame.Common.Global")

	self:PreLoadingResource(function()
		self:EnterCasino()
	end)
end

function FGCasinoLoading:OnUpdateLoadingBar(dt)
	self.curShowProgress = self.curShowProgress + dt * 200
	if self.curShowProgress > self.curLogicProgress then
		self.curShowProgress = self.curLogicProgress
	end
	self:RefreshLoadingBar(self.curShowProgress)
end

---------------------------------------------------------------------------------------

function FGCasinoLoading:collectWebm(dirName)
	local baseDir = nil
	local webms = {}

	local files = cc.FileUtils:getInstance():listFiles(dirName)
	for _, file in pairs(files) do
		if string.sub(file, -5) == ".webm" then
			if not baseDir then
				local beginpos, endpos = string.find(file, dirName)
				if beginpos ~= nil then
					baseDir = string.sub(file, 1, beginpos - 1)
				end
			end
			table.insert(webms, string.sub(file, #baseDir + 1))
		end
	end

	if baseDir then
		return webms, baseDir .. dirName .. "/"
	end
	return webms, baseDir
end

function FGCasinoLoading:collectPreloadWebms(filename)
	local prefix = string.match(filename, "(.+/)(.-)%.lua")
	local script = string.gsub(filename, "/", ".")
	script = string.gsub(script, "%.lua$", "")

	local ok, list = pcall(require, script)
	if ok and type(list) == "table" then
		local webms = {}
		for k, v in pairs(list) do
			webms[k] = prefix .. v .. ".webm"
		end
		return webms
	end
	return {}
end

function FGCasinoLoading:PreLoadingResource(onSuccess)
	local res_game_id = self.res_game_id

	-- 游戏资源包
	local items = {}
	local gamePkg = FairyGUI.UIPackage.AddPackage(string.format("Game%d/Game%d", res_game_id, res_game_id))
	
	if gamePkg == nil then
        UIManager.ShowMsgBox("Error downloading fgame resources.", function()
            self:removeFromParent()
            utils.GoBackLobby()
        end)
	end

	for k, v in pairs(gamePkg:GetItems()) do
		table.insert(items, v)
	end

	-- 根据主题加载对应的公共界面资源
	local ok, cfg = pcall(require, string.format("FGame.Game%d.Cfgs.Theme", res_game_id))
	if ok then
		local name = cfg.name or "Lilac"
		local basePkg = FairyGUI.UIPackage.AddPackage("Basics/Theme_" .. name)
		if basePkg then
			for k, v in pairs(basePkg:GetItems()) do
				table.insert(items, v)
			end
		end
	end

	-- 收集webm
	-- if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
	-- 	local webms, baseDir = self:collectWebm("Basics/Webm")
	-- 	if baseDir then
	-- 		cc.FileUtils:getInstance():writeStringToFile(Crypto.encodeJson(webms), baseDir .. "webm.list")
	-- 	end
	-- 	webms, baseDir = self:collectWebm(string.format("Game%d/Webm", res_game_id))
	-- 	if baseDir then
	-- 		cc.FileUtils:getInstance():writeStringToFile(Crypto.encodeJson(webms), baseDir .. "webm.list")
	-- 	end
	-- end

	cc.Webm:setDecodeThreadCount(3)

	-- 预加载webm
	local webmFiles = {}
	local list = self:collectPreloadWebms("Basics/Webm/preload.lua")
	for k, v in pairs(list or {}) do
		table.insert(webmFiles, v)
	end
	list = self:collectPreloadWebms(string.format("Game%d/Webm/preload.lua", res_game_id))
	for k, v in pairs(list or {}) do
		table.insert(webmFiles, v)
	end
	-- dump(webmFiles, "webmFiles")

	self.loadAsync = require("hall.src.hallnew.layers.lobby.CasinoLoading.FGUILoader.LoadAsync").new()
	self.loadAsync:loadItems(items)
	self.loadAsync:loadWebms(webmFiles)
	self.loadAsync:start(function(taskPercent, totalPercent)
		self.curLogicProgress = math.floor(totalPercent * 100)
	end, function()
		go(function() if onSuccess then onSuccess() end end)
	end)
end

---------------------------------------------------------------------------------------

function FGCasinoLoading:EnterCasino()
	gStates_SetAsync(require("hall.src.hallnew.layers.lobby.CasinoLoading.FGCasinoGame"))
	self:removeFromParent()
end

return FGCasinoLoading
