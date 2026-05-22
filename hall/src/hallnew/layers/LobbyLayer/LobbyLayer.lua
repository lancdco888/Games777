local LobbyLayer = class("LobbyLayer", function()
    return Tools.CreateLayer("csb/LobbyLayer/LobbyLayer.csb")
end)

function LobbyLayer:onEnter()
    self:InitUI()

    self:AdjustUI()     --适配

    self:EnterLobby()

    --设置跑马灯横竖屏类型
    MarqueeLogic:SetNoticeType("width")
    MarqueeLogic:HideNotice("height")
    MarqueeLogic:ShowNotice_Node()

    local size = Def.visibleSize
    MarqueeLogic:SetNoticePos(cc.p(size.width * 0.5, size.height * 0.85))

    local bg = self:getChild("bg")
    local effectLayer = EffectLayerStar.new()
    bg:addChild(effectLayer)

	--是否在大厅根目录
	self.isOnLobby = true

    -- 聊天新消息
    self:UpdateChatTip()
end

function LobbyLayer:onExit()
    self:CloseKeyReturn()
    Dispatcher:Remove(self)
end

-------------------------------------------------------------------

function LobbyLayer:InitUI()
    self:InitUserInfo()
    self:InitFunctionBtns()

    -- 初始化大厅卡片
    self:InitGameList()

    self:InitFishLevel()
    self:InitFishRoom()

    self:InitKeyReturn()
end

function LobbyLayer:InitUserInfo()
    local UserInfoNode = require("hall.src.hallnew.layers.LobbyLayer.UserInfoNode")
    local node = self:getChild("panel/user_info")
    self.user_info = UserInfoNode.new(node)
    self.user_info:setLocalZOrder(106)
    self.user_info:onEnter()        --主动调用 onEnter 函数
end

function LobbyLayer:InitGameList()
    local GameList = require("hall.src.gamelist.GameList")
    local node = self:getChild("panel/game_list"):hide() --作为模板 一直隐藏
    self.game_list = GameList.new(node)
    self.game_list:onEnter()
    self.game_list:setLocalZOrder(100)
    self.game_list:SetGameList(self:GetGameList())

    -- 渐渐显示
    self.game_list:setOpacity(0)
    self.game_list:runAction(cc.EaseIn:create(cc.FadeIn:create(2),1))
end

function LobbyLayer:GetGameList()
    self.game_ids = {}
    for _,id in ipairs(GameData.game_ids) do
        table.insert(self.game_ids, id)
    end
    return self.game_ids
end

function LobbyLayer:InitFunctionBtns()
    local FunctionButton = require("hall.src.hallnew.layers.LobbyLayer.FunctionButton")
    local node = self:getChild("panel/function_buttons")
    self.function_button = FunctionButton.new(node)
    self.function_button:onEnter()        --主动调用 onEnter 函数
end

function LobbyLayer:InitFishLevel()
    local layer = FishLevelLayer.new()
    self:addChild(layer)
    self.fish_level_layer = layer
end

function LobbyLayer:InitFishRoom()
    local layer = FishRoomLayer.new()
    self:addChild(layer)
    self.fish_room_layer = layer
end

function LobbyLayer:TopAdjustUI(width_)
    --上方适配
    local size = Def.visibleSize
    local scaleWidth = 0
    if width_ then
        scaleWidth =  width_ / self.user_info:getContentSize().width
    else
        scaleWidth = Def.ScaleX
    end

    --关卡界面上边沿
    local lua_bg = self.user_info:getContentSize()
    self.fish_level_layer:SetTop(size.height- lua_bg.height * Def.ScaleX)
    self.fish_room_layer:SetTop(size.height - lua_bg.height * Def.ScaleX)
end

--适配
function LobbyLayer:AdjustUI()
    --整体适配
    local size = Def.visibleSize
    do
        --背景放大铺满
        local bg = self:getChild("bg")
        -- bg:setScale(Def.ScaleMax)
        bg:setScale(Def.ScaleX, Def.ScaleY)
        bg:setPosition(cc.p(size.width/2.0, size.height/2.0))
    end

	local width = size.width
    local scaleWidth = width / self.user_info:getContentSize().width
    do
        --上方适配
        self.user_info:setScale(Def.ScaleX)
        local pos = cc.p(0, size.height)
        pos = self:convertToNodeSpace(pos)
        self.user_info:setPosition(pos)
    end

    do
        --下方适配
        self.function_button:setScale(Def.ScaleX)
    end

    do
        --游戏列表剩余高度,暂时不考虑跑马灯
        local height = size.height
            - self.user_info:getBoundingBox().height
            - 60

		local x = self.game_list:getPositionX()
		local width = size.width - ( 2 * x )
		self.game_list:resize(width, height)
    end
end

--进关卡
function LobbyLayer:EnterFishLevel()
    go(function()
        UIManager.DisableTouch(0.6)

        self:TopAdjustUI()
        self.fish_level_layer:setVisible(true)
        self.function_button:RunExitAni()
        self.user_info:RunExitAni()
        self.game_list:RunExitAni()
        SleepSecs(0.22)
        MarqueeLogic:SetNoticePos()
        self.user_info:RunEnterAni(false)
        self.fish_level_layer:RunEnterAni()
        self.fish_level_layer:UpdateLevelList()
        self.fish_level_layer:UpdateGameName()
		self.isOnLobby = false
    end)
end

--进房间
function LobbyLayer:EnterFishRoom()
    go(function()
        UIManager.DisableTouch(0.6)

        self.fish_room_layer:setVisible(true)
        self.fish_level_layer:RunExitAni()
        SleepSecs(0.5)
        self.fish_room_layer:RunEnterAni()
        self.fish_room_layer:Update()
    end)
end

--回关卡
function LobbyLayer:ReturnFishLevel()
    go(function()
        UIManager.DisableTouch(0.6)

        self.fish_level_layer:setVisible(true)
        self.fish_room_layer:RunExitAni()
        SleepSecs(0.5)
        self.fish_level_layer:RunEnterAni()
    end)
end

--进入捕鱼loading界面
function LobbyLayer:EnterFishLoading()
	go(function()
        UIManager.DisableTouch(0.6)

		self.fish_room_layer:RunExitAni()
		self.fish_room_layer:CloseEvent()
        SleepSecs(0.15)
		self.enterFish_layer = EnterFishLayer.new()
		self:addChild(self.enterFish_layer)
    end)
end

--回大厅
function LobbyLayer:ReturnLobby(sec)
    self.function_button:Update()
    sec = sec or 0.22
    gorun(function()
        UIManager.DisableTouch(0.6)

        self:TopAdjustUI(Def.visibleSize.width)
        sGameManager.GameIsPlay = false
		self.isOnLobby = true
        self.fish_level_layer:RunExitAni()
        self.fish_room_layer:RunExitAni()
        self.user_info:RunExitAni()
        SleepSecs(sec)
        local size = Def.visibleSize
        MarqueeLogic:SetNoticePos(cc.p(size.width * 0.5, size.height * 0.85))
        self.user_info:RunEnterAni(true)
        self.game_list:RunEnterAni()
        self.function_button:RunEnterAni()
    end)
end

function LobbyLayer:EnterLobby()
    UIManager.DisableTouch(0.2)

    sGameManager.GameIsPlay = false
    self.fish_level_layer:setVisible(false)
    self.fish_room_layer:setVisible(false)
    self.user_info:RunEnterAni(true)
    self.game_list:RunEnterAni()
    self.function_button:RunEnterAni()
end

-------------------------------------------------------------------

function LobbyLayer:ShowMailTip(bShow)
    self.function_button:ShowTip("lua_btn_service", bShow)
end

-------------------------------------------------------------------

function LobbyLayer:InitKeyReturn()
	--监听手机返回键
	self.returnListener = nil
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if(cc.PLATFORM_OS_ANDROID == targetPlatform or cc.PLATFORM_OS_WINDOWS == targetPlatform)then
		self.returnKey = false
        self.returnListener = cc.EventListenerKeyboard:create()
        local timer = 0
		self.returnListener:registerScriptHandler(function(code, event)
                if(code == cc.KeyCode.KEY_BACK)then
                    if sGameManager.phoneHomeIsclick then
                       return
                    end
                    sGameManager.phoneHomeIsclick = true
					if os.clock() - timer > 0.3  then
                        timer = os.clock()
                        UIManager.ShowMsgBox(TR("亲，确定不再玩一会儿游戏了吗？"),
                            function()   -- ok
                                cc.Director:getInstance():endToLua()
                                sGameManager.phoneHomeIsclick = false
                            end,
                            function()   --cancel
                                sGameManager.phoneHomeIsclick = false
                            end
                        )
					end
                end
			end, cc.Handler.EVENT_KEYBOARD_RELEASED)
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.returnListener, gScene)
	end
end

function LobbyLayer:CloseKeyReturn()
	if self.returnListener ~= nil then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.returnListener)
        self.returnListener = nil
	end
end

function LobbyLayer:UpdateChatTip()
end

function LobbyLayer:ShowChatTip(bShow)
end

--------------------------------------------------------------------------------------------

return LobbyLayer
