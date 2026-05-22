local utils = {}

function utils.GoBackLobby()
	go(function()
		local data_ = PKG_Client_Slots_Leave.Create()
		local rlt_ = gNet_SendRequest(data_)

		Device:setScreenType(const_game.H_Screen_Type)
		Tools.ResetWidthHeight()

		sGameManager.isCasinoLoaded = false
		sGameManager.gameState = const_game.Lobby_State

		-- 得到服务器正常回复,就退回大厅,异常情况直接退到登录界面
		if rlt_ and rlt_.typeId == PKG_Slots_Client_Leave_Success.typeId then
			EnterLobbyPanel()
		else
			LogoutLobby()
			EnterLoginPanel()
		end
	end)
end

return utils
