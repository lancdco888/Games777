local this = {}
this.stateGroupName = "Main"
this.stateName 		= "Casino_FairyGUI"
this.opened 		= false

this.Open = function()
	assert(not this.opened)
	this.opened = true

	-- 进入老虎机关闭大厅bgm
	gSound.stopBgm()

	local res_game_id = GameData.game_id
	sGameManager.gameState = const_game.Game_State

	FBasePkgHub = require("FGame.Common.Special.CocosFish2.FBasePkgHub")

	FGamePkgHubIns = require(string.format("FGame.Game%d.Hub.PkgHub", res_game_id)).new()

	local net_code = "hall.src.pkgs.slot_" .. tostring(res_game_id) 
	package.loaded["g_net"] = {} -- 协议文件有些时候会多一句 require('g_net'), 加这一行避免脚本错误
	local ok, err_msg = pcall(require, net_code)
	if not ok then
		print("load pkg failed.")
		return
	end

	-- 断线重连数据
	local restoreRlt = sGameManager.NetRestoreCasinoRlt
	if not sGameManager.NetRestoreCasino then
		restoreRlt = nil
	end
	sGameManager.NetRestoreCasino = false
	sGameManager.NetRestoreCasinoRlt = nil

	FairyGUI.UIPackage.branch = GetLang()

	if sGameManager.slotEnterResult then
		sGameManager.slotEnterResult = FGamePkgHubIns:Pkg2Pb(sGameManager.slotEnterResult)
	end
	if restoreRlt then
		restoreRlt = FGamePkgHubIns:Pkg2Pb(restoreRlt)
	end

	RunCasino(res_game_id, sGameManager.slotEnterResult, restoreRlt)
	sGameManager.isCasinoLoaded = true
end

this.Close = function()
	assert(this.opened)
    
    if FCasinoCtx then
        DestroyCasino()
    end

	Tools.RestoreSearchPaths()

    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

	collectgarbage("collect")

	this.opened = false
end

return this