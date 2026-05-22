gScene = nil

local function main()
	xpcall(require, __G__TRACKBACK__, "hall.src.patch.patch")

    local director = cc.Director:getInstance()

    gScene = director:getRunningScene()
    director:setDisplayStats(false)

    require "packagelua.src.base.generic"
	require "packagelua.src.base.class_def"
    require "packagelua.src.base.client_login"

    package.loaded["hall.src.pkgs.BaseInfo"] = nil
    require "hall.src.pkgs.BaseInfo"

    package.loaded["hall.src.pkgs.client_lobby"] = nil
    require "hall.src.pkgs.client_lobby"

    package.loaded["hall.src.pkgs.slot_com"] = nil
    require "hall.src.pkgs.slot_com"

    package.loaded["hall.src.pkgs.Lobby_Slots"] = nil
    require "hall.src.pkgs.Lobby_Slots"

    package.loaded["hall.src.pkgs.SupportOther"] = nil
    require "hall.src.pkgs.SupportOther"

    UserData = require("hall.src.common.UserData")
    GameData = require("hall.src.common.GameData")

    Tools = require("hall.src.common.Tools")
    package.loaded["hall.src.common.Def"] = nil
    package.loaded["hall.src.common.const_game"] = nil
    package.loaded["hall.src.common.GameInfoManager"] = nil
    require "hall.src.common.Def"
    require "hall.src.common.const_game"
    require "hall.src.common.GameInfoManager"
    sGameManager.Init()

    user = require("hall.src.user.user")
    service = require("hall.src.service.service")
    activity = require("hall.src.activity.activity")

	require "hall.src.hallnew.init"
	require "hall.src.ext.init"
    require "hall.src.logic"

	require "hall.src.common.Def.Language.language"

	xpcall(require, __G__TRACKBACK__, "hall.src.exchange.main")

    -- 语言处理
    package.loaded["packagelua.src.bootstrap.init"] = nil
    require("packagelua.src.bootstrap.init")
    ResetTranslator()

    package.loaded["packagelua.src.base.g_sound"] = nil
    require("packagelua.src.base.g_sound")

    Sdk = require("hall.src.sdk.Sdk").new()
    Sdk:firstOpen()

	go(function()
        CheckPermission()
        LogicMain()
    end)
    LoadGameVersionJson()

    if Device.GetMemoryInfo then
        local memInfo = Device:GetMemoryInfo()
        dump(memInfo, " ** MemoryInfo ** ")

        local scheduler = cc.Director:getInstance():getScheduler()
        if dump_mem_scheduler ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(dump_mem_scheduler)
            dump_mem_scheduler = nil
        end
        dump_mem_scheduler = scheduler:scheduleScriptFunc(
            function()
                local memInfo = Device:GetMemoryInfo()
                dump(memInfo, " ** MemoryInfo ** ")
            end,
            60,
            false
        )
    else
        print("MemoryInfo : Device.MemoryInfo() not found")
    end

	local listener = cc.EventListenerKeyboard:create()
	listener:registerScriptHandler(function(code, event)
			if code == cc.KeyCode.KEY_0 then
			end
		end, cc.Handler.EVENT_KEYBOARD_RELEASED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, -1)
end

function CheckPermission()
	Device:GetDeviceID()
	while true do
		yield()
		if Device:GetDeviceID() ~= nil then
			return
		end
	end
end

xpcall(main, __G__TRACKBACK__)
