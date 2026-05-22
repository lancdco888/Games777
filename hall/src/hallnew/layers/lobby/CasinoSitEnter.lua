local this = {}
this.stateName = "CasinoSitEnter"
this.stateGroupName = "CasinoSitEnter"
this.opened = false
this.gotoType = 0--在调用本脚本的地方判断跳转到哪步
this.Open = function()
	assert(not this.opened)
	GameData.game_id = GameData:GetGameID(GameData.game_id)
    this.OnGameClick()
	this.opened = true

end

this.Close = function()
	assert(this.opened)
	this.opened = false
end

function this.OnGameClick()
	--进游戏默认最小等级(是普通场的情况下)
	local temparr = GameData.casinoLevelTabs[GameData.entergame_id]
	if temparr == nil then
		this.Close()
		return
	end

	local info = temparr[#temparr]
    sGameManager.InitCasinoParam()
    sGameManager.curLevel =info
	sGameManager.curCasinoLvID = info.id

    this.HandleEnterGame(GameData.game_id)
end
function this.HandleEnterGame(gameID)
    go(function()
        local data_ = PKG_Client_Lobby_EnterGame.Create()
       	data_.gameId = GameData.entergame_id-- GameData:IsRichThreeThousandsGameID(GameData.entergame_id) and  GameData.entergame_id or gameID
		dump(data_, " ** data_ ** ")
        UIManager.ShowWaiting()
        local rlt_ = gNet_SendRequest(data_)
        UIManager.HideWaiting()

		dump(rlt_, " rlt_ ")
		if rlt_ ~= nil then
			if rlt_.typeId == PKG_Lobby_Client_EnterGameCatchFish_Success.typeId then
			elseif rlt_.typeId == PKG_Generic_Error.typeId then
                local num = rlt_.number
                if num == -9999 then
                    -- "您操作太频繁，请稍后再试"
                    UIManager.ShowMsgBox("ဆက်တိုက်လုပ်ဆောင်မှုများနေသဖြင့် ခဏစောင့်ဆိုင်းပြီးမှ လုပ်‌ဆောင်ပေးပါရှင့်(E9999)")
                else
					local msg = string.format(
						"%s(id:%s,msg:%s)",
						TR("网络连接失败，请重试"),
						tostring(data_.gameId),
						tostring(rlt_.message)
					)
					UIManager.ShowMsgBox(msg)
                end
			elseif rlt_.typeId == PKG_Lobby_Client_EnterGameSlots_Success.typeId then
				GameData.serverID = rlt_.serviceId
                GameData.game_id = rlt_.GameId

				if not WaitOpen(GameData.serverID, 4000) then
					return
				end

				SleepSecsByClock(0.01)
				package.loaded["hall.src.hallnew.layers.lobby.CanisoGameEnter"] = nil
				local CanisoGameEnter_script = require("hall.src.hallnew.layers.lobby.CanisoGameEnter")
				gStates_SetAsync(CanisoGameEnter_script)
			end
		else

		end
    end)
end
return this
