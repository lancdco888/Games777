
local GlobalMsgHandle = Class("GlobalMsgHandle")

function GlobalMsgHandle:ctor()
    APIGateway.AddSubscriber("PB.Slots_Client.OfflineCheck", handler(self, self.OnMsg_OfflineCheck), self)
    APIGateway.AddSubscriber("PB.Slots_Client.Leave_Success", handler(self, self.OnMsg_ReturnLobby), self)
    APIGateway.AddSubscriber("PB.Lobby_Client.ReturnLobby", handler(self, self.OnMsg_ReturnLobby), self)
    APIGateway.AddSubscriber("PB.Support_Other.OneGameLotteryRet", handler(self, self.OnMsg_OneGameLotteryRet), self)

    self.recvLotteryRetCount = 0
    
    FSysEventEmitter:AddListener(FSysEvent.ON_SEND_REQUEST, function()
        self:RemoveCountdown()
    end, self)
end

function GlobalMsgHandle:__delete()
    FSysEventEmitter:RemoveListenersByTag(self)
    APIGateway.RemoveAllSubscribers(self)
    self:RemoveCountdown()
end

function GlobalMsgHandle:RemoveCountdown()
    if self.countdown then
        self.countdown:Delete()
        self.countdown = nil
    end

    if self.countdownTimer then
        StopTimer(self.countdownTimer)
        self.countdownTimer = nil
    end
end

-- @brief 提醒客户端倒计时退出
function GlobalMsgHandle:OnMsg_OfflineCheck()
    print("收到服务器退出提醒")
    self:RemoveCountdown()

    self.countdown = FTheme.Require("Countdown").New()
    self.countdown:SetDestroyCallback(function()
        self:RemoveCountdown()
        
        self.countdownTimer = StartOnceTimer(function()
            self:OnMsg_OfflineCheck()
        end, 60)
    end)
end

-- @brief 服务器通知客户端返回大厅
function GlobalMsgHandle:OnMsg_ReturnLobby()
    print("服务器通知客户端返回大厅")
    DestroyCasino()
end

function GlobalMsgHandle:OnMsg_OneGameLotteryRet(data)
    if self.recvLotteryRetCount > 1 then
        if table.equals(self.lastLotteryData, data) then return end
        self.lastLotteryData = data
    end
    self.recvLotteryRetCount = self.recvLotteryRetCount + 1

    FSysEventEmitter:Emit(FSysEvent.ON_RECV_LOTTERT_DATA, data)
end

return GlobalMsgHandle