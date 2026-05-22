local this = {}

this.stateGroupName = "Main"
this.stateName = "CasinoLoading"
this.opened = false
this.loadingLayer = nil

function this.Open()
	if this.opened then
		return
	end
	this.opened = true

	local loadingLayer
	local game_id = GameData.game_id
    local fguiRunTimeSupport = Tools.IsFGUIRuntimeSupport()
	if fguiRunTimeSupport and GameData:IsFGUIReleaseGame(game_id) then
		loadingLayer = require("hall.src.hallnew.layers.lobby.CasinoLoading.FGCasinoLoading"):new()
		-- FGCasinoLoading 内部自己销毁 Layer, 不需要要借助 Close
		this.loadingLayer = nil
	elseif GameData:IsCocosSupportGame(game_id) then
		loadingLayer = require("hall.src.hallnew.layers.lobby.CasinoLoading.CasinoLoading"):new()
		this.loadingLayer = loadingLayer
	else
		UIManager.ShowToast("UnSupportted game found:" .. game_id)
	end

	if Sdk then
		Sdk:startTrial()
	end

	gScene:addChild(loadingLayer)
end

function this.Close()
	if (not this.opened) then
		return
	end
	this.opened = false

	if not tolua.isnull(this.loadingLayer) then
		this.loadingLayer:removeFromParent()
		this.loadingLayer = nil
	end
end

return this
