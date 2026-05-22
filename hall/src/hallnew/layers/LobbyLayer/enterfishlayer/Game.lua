local Game = class("Game")
local socket = require("socket")
GameInst = nil

function Game:ctor()
    self.cf = nil
    self.mainFishScene = nil
    self.bInFullSync = false
    self.fullSyncStartTime = 0.0
    self.bInRecc = false            -- 重连中

    self.bResLoaded = false         -- 资源是否已预加载
    GameInst = self
end

----------------------------------------------------------------------------
-- 预加载资源
function Game:LoadRes()
    if self.bResLoaded then return end

    self.searchPath = {}

    local basicPath = cc.FileUtils:getInstance():getWritablePath() .. "download/"
    local searchPath = basicPath .. "src/fish_" .. GameData.game_id
    table.insert(self.searchPath, searchPath)
    cc.FileUtils:getInstance():addSearchPath(searchPath, true)

    local gameID = GameData.game_id
    local is_changsheng = const_game.Param[GameData:GetGameID(gameID)][const_game.Game_type] == "changsheng"
    if is_changsheng then
        local searchPath = basicPath .. "src/fish_common_cs"
        cc.FileUtils:getInstance():addSearchPath(searchPath, true)
    end

    local director = cc.Director:getInstance()
    local yield = coroutine.yield
    local count = 0
    local total = 0

    local loading = LoadingLayer:new()
    director:getRunningScene():addChild(loading)
    loading:showLoading(true)
    loading:setRate(0.0)
    loading:setName("loadingLayer")
    self.loading = loading

    loading:regExitEvent(function()
        release_print("loading layer exit!!!")
        self.loading = nil
    end)

    yield()

    local plists = {
        "ui/ui.plist",
        "ui/ui_cn.plist",
        "ui/fish_net.plist",
        "ui/light_line.plist",
        "ui/studio/fish2_ui.plist",
    }
    if is_changsheng then
        table.insert(plists, "ui/studio/fish_ui_cs.plist")
        table.insert(plists, "fish/cs/cs_other.plist")
    end

    local languagePath = "ui/language_" .. GetLang() .. ".plist"
    if cc.FileUtils:getInstance():isFileExist(languagePath) then
    print("language path:", languagePath)
        table.insert(plists, 1, languagePath)
    end

    local gameID = GameData.game_id
    local cfg_plists, pngs = self:GetPreLoadRes(gameID)
    for _,plist in ipairs(cfg_plists) do
        table.insert(plists, plist)
    end
    total = #plists + #pngs

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    for _, plist in ipairs(plists) do
        spriteFrameCache:addSpriteFrames(plist)
        count = count + 1
        loading:setRate(count/total)
        yield()
    end

    for _, png in ipairs(pngs) do
        count = count + 1
        cc.Director:getInstance():getTextureCache():addImage(png)
        loading:setRate(count/total)
        yield()
    end

    self.bResLoaded = true
end

function Game:GetPreLoadRes(game_id)
    require("hall.src.hallnew.cfgs.fish.init")
    local assets = get_fish_preload_res(game_id)

    local plists = {}
    local pngs = {}

    for __,asset in ipairs(assets) do
        if string.find(asset, ".plist") then
            table.insert(plists, asset)
        end
        if string.find(asset, ".png") then
            table.insert(pngs, asset)
        end
    end

    -- dump(plists, "************   plists  ***************")
    -- dump(pngs, "************   pngs  ***************")
    return plists, pngs
end

-- 卸载资源
function Game:UnLoadRes()
    if not self.bResLoaded then return end
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    for __,searchPath in pairs(self.searchPath) do
        cc.FileUtils:getInstance():removeSearchPath(searchPath)
    end
    self.searchPath = {}

    self.bResLoaded = false
end

----------------------------------------------------------------------------

function Game:CreateCatchFish()
    if self.cf ~= nil then return true end
    if self.mainFishScene then
        self.mainFishScene:removeFromParent()
    end
    local mainFishScene = cc.Node:create()
    self.mainFishScene = mainFishScene
    mainFishScene:setContentSize(1280, 720)
    mainFishScene:setAnchorPoint(0.5, 0.5)

    local Env = NewCatchFishEnv or Fish2Env
    local cf = Env(mainFishScene, gNet)
    self.cf = cf

    local p = cc.Node:create()
    local scale = 1.0
    if(Def.DesignedX/Def.DesignedY>Def.visibleSize.width/Def.visibleSize.height	)then
        scale = Def.visibleSize.width/Def.DesignedX
    else 
        scale = Def.visibleSize.height/Def.DesignedY
    end
    p:setPosition(Def.visibleSize.width/2, Def.visibleSize.height/2)
    p:setScale(scale)
    p:addChild(mainFishScene)
    gScene:addChild(p)
    mainFishScene:onUpdate(function()
        --print("update.")
        if self.bInFullSync or self.NeedUpdateFish then
            self:UpdateFish()
            self.NeedUpdateFish = true
        end
    end)
    mainFishScene:onNodeEvent("exit", function()
        print("exit: mainFishScene.")
        self:DestroyCatchFish()
        self.NeedUpdateFish = false
    end)
    return true
end

function Game:UpdateFish()
    if not self.cf then
        return
    end

    if sGameManager.gameState == -1 then
        self:Destroy()
        return
    end

    local r = self.cf:Update()
    if self.bInRecc then
        return
    end

    if self.bInFullSync then
        if self.cf:Alive() then
            self.bInFullSync = false
            if self.loading then
                self.loading:removeFromParent()
                self.loading = nil
            end
        else
            local elasp = socket.gettime() - self.fullSyncStartTime
            if elasp >= 6.0 then
                print("fullsync timeout, start reconnect!")
                self:StartRecconect()
            end
        end
        return
    end

    if not self.cf:Alive() or not gNet:Alive() or not gNet:IsOpened(GameData.serverID) then
        print("not avlive start reconnect!")
        self:StartRecconect()
        return
    end

    if r == 2 then
        print("ret == 2, start reconnect!")
        self:FullSync()
        return
    end

    if r ~= 0 then
        self:Destroy()
        self:GoLobby()
        return
    end
end

function Game:DestroyCatchFish()
    if self.cf == nil then return end

    self.cf:Destroy()
    self.cf = nil

    if self.mainFishScene then
        self.mainFishScene:getParent():removeFromParent()
        self.mainFishScene = nil
    end
    collectgarbage("collect")
    print("exit: DestroyCatchFish().")
end

----------------------------------------------------------------------------

function Game:FullSync()
    if not self.cf then return end
    print("full sync")
    self.bInFullSync = true

    self.fullSyncStartTime = socket.gettime()
    self.cf:FullSync()
end

function Game:GoLobby()
    go(function()
        EnterLobbyPanel()
    end)
end

function Game:Destroy()
    gSound.stopBgm()

    self:DestroyCatchFish()
    self:UnLoadRes()

    if self.loading then
        self.loading:removeFromParent()
        self.loading = nil
    end

    GameInst = nil
end

----------------------------------------------------------------------------

VipLogic = {}

function VipLogic:IsVipOpen()
    return sGameManager.IsVipOpen()
end

----------------------------------------------------------------------------

function Game:Start()
    go(function()
        if sGameManager.gameState == -1 then
            self:Destroy()
            return
        end

        if not self.bResLoaded then
            self:LoadRes()
        end

        if not gNet:Alive() or not gNet:IsOpened(GameData.serverID) then
            self:StartRecconect()
            return
        end

        SendTestMsg(GameData.serverID, 1)
        gNet_SetCppServiceId(GameData.serverID)

        if not self:CreateCatchFish() then
            print("Create CatchFish Failed")
            self:UnLoadRes()
            return
        end
        
        self:FullSync()
    end)
end

function Game:StartRecconect()
    go(function()
        if sGameManager.gameState == -1 then
            self:Destroy()
            return
        end

        print("Game:StartRecconect")
        self.bInRecc = true

        local Network = require("packagelua.src.base.Network")
        UIManager.ShowWaiting()

        local socket = require("socket")
        local t = socket.gettime()
        local ret = Network:ConnectServer()
        print("connect time:" .. socket.gettime() - t)

        if not ret then
            UIManager.HideWaiting()
            self:OnReConnFailed()
            return
        end
        local t = socket.gettime()
        local game_id = SendAuth()
        print("SendAuth time:" .. socket.gettime() - t)

        UIManager.HideWaiting()
        self.bInRecc = false

        if game_id < 0 then
            self:OnReConnFailed()
            return
        end

        self:DestroyCatchFish()
        print("SenAuth:" .. tostring(game_id))

        if game_id == 0 then
            self:Destroy()
            self:GoLobby()
        else
            self:Start()
        end
    end)
end

function Game:OnReConnFailed()
    print("OnReConnFailed")
    SleepSecs(0.1)
    self:StartRecconect()

    -- PopLayer:CloseAll()
    -- UIManager.ShowMsgBox(
    --     TR("网络连接失败，是否重试？"),
    --     function()
    --         self:StartRecconect()
    --     end,
    --     function()
    --         go(
    --             function()
    --                 self:Destroy()

    --                 sGameManager.gameState = -1
    --                 EnterLoginPanel()
    --             end
    --         )
    --     end
    -- )
end

return Game
