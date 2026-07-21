-- Creator runtime adapters for FGameCommon (Special/Init.lua RUNTIME_IN_CREATOR branch).
-- Prefer TypeScript APIGateway in creator-games777; these Lua stubs keep Import(".Creator.*") working
-- when Lua is still driven under a Creator hybrid shell.

if FConfig then
    FConfig.Debug = true
end

APIGateway = APIGateway or {}

local function jsCall(name, ...)
    if type(jsb) == "table" and jsb.reflection and jsb.reflection.callStaticMethod then
        -- native bridge placeholder
    end
    if type(window) == "table" and window.__CreatorAPIGateway and window.__CreatorAPIGateway[name] then
        return window.__CreatorAPIGateway[name](...)
    end
end

function APIGateway.PlaySound(path, loop)
    local handle = jsCall("PlaySound", path, loop)
    if handle ~= nil then return handle end
    if gSound and gSound.playEffect then
        return gSound.playEffect(path, loop)
    end
end

function APIGateway.StopSound(handle)
    if jsCall("StopSound", handle) ~= nil then return end
    if handle and gSound and gSound.stopEffect then
        gSound.stopEffect(handle)
    end
end

function APIGateway.SetSoundVolume(handle, volume)
    jsCall("SetSoundVolume", handle, volume)
end

function APIGateway.PlayBGM(path)
    local handle = jsCall("PlayBGM", path)
    if handle ~= nil then return handle end
    if gSound and gSound.playBgm then
        return gSound.playBgm(path)
    end
end

function APIGateway.StopBGM()
    if jsCall("StopBGM") ~= nil then return end
    if gSound and gSound.stopBgm then
        gSound.stopBgm()
    end
end

function APIGateway.IsSoundEnable()
    local v = jsCall("IsSoundEnable")
    if v ~= nil then return v end
    if gSound and gSound.isEffectOn then
        return gSound.isEffectOn()
    end
    return true
end

function APIGateway.SetSoundEnable(value)
    if jsCall("SetSoundEnable", value) ~= nil then return end
    if gSound and gSound.setEffectOn then
        gSound.setEffectOn(value)
    end
end

function APIGateway.GetLobbyData()
    local data = jsCall("GetLobbyData")
    if data then return data end
    return {
        bindGoldCoinEnabled = false,
        playerIsVIP = false,
        lobbyExchangeRate = 1,
        gameExchangeRate = 1,
        isLotteryBetMode = false,
        curSlotsLevel = nil,
        isCasinoLevelOpen = true,
        washCodeMode = 0,
        rawGameId = GameData and GameData.game_id or -1,
    }
end

function APIGateway.GetGameReconnectData()
    return jsCall("GetGameReconnectData")
end

function APIGateway.ShowMessageBox(content, onOkCallback, onCancelCallback)
    if jsCall("ShowMessageBox", content, onOkCallback, onCancelCallback) ~= nil then return end
    if UIManager and UIManager.ShowMsgBox then
        UIManager.ShowMsgBox(content, onOkCallback, onCancelCallback)
    elseif onOkCallback then
        onOkCallback()
    end
end

function APIGateway.OpenSettingPanel()
    jsCall("OpenSettingPanel")
end

function APIGateway.OpenServicePanel()
    jsCall("OpenServicePanel")
end

function APIGateway.GetLangText(key)
    local v = jsCall("GetLangText", key)
    if v then return v end
    if TR then return TR(key) end
    return key
end

function APIGateway.EnterLobby()
    if jsCall("EnterLobby") ~= nil then return end
    if EnterLobbyPanel then
        EnterLobbyPanel()
    end
end

function APIGateway.SendPush(msg)
    jsCall("SendPush", msg)
end

function APIGateway.SendRequest(msg, callback)
    if jsCall("SendRequest", msg, callback) ~= nil then return end
    if callback then callback(false, nil) end
end

function APIGateway.SendExactRequest(msg, resultMsgName, callback)
    APIGateway.SendRequest(msg, function(ok, pkg)
        if ok and pkg and pkg._msgName_ == resultMsgName then
            callback(true, pkg)
        else
            callback(false)
            APIGateway.Disconnect()
        end
    end)
end

function APIGateway.AddSubscriber(msgName, callback, target)
    jsCall("AddSubscriber", msgName, callback, target)
end

function APIGateway.RemoveSubscriber(msgName, callback)
    jsCall("RemoveSubscriber", msgName, callback)
end

function APIGateway.RemoveAllSubscribers(target)
    jsCall("RemoveAllSubscribers", target)
end

function APIGateway.Disconnect()
    jsCall("Disconnect")
end

function APIGateway.ParticleEffectFadeOut(particle, duration, delayTime)
    jsCall("ParticleEffectFadeOut", particle, duration, delayTime)
end

function APIGateway.PlayParticleEffect(path, loader3D)
    return jsCall("PlayParticleEffect", path, loader3D)
end

function APIGateway.StopParticleEffect(particle)
    jsCall("StopParticleEffect", particle)
end

function APIGateway.ReplayParticleEffect(particle)
    jsCall("ReplayParticleEffect", particle)
end

function APIGateway.IsInvalidObject(obj)
    local v = jsCall("IsInvalidObject", obj)
    if v ~= nil then return v end
    return obj == nil
end

local inFSlot = false
function APIGateway.InFSlot()
    return inFSlot
end

function APIGateway.OnEnter()
    inFSlot = true
end

function APIGateway.OnDestroy(fairyRoot)
    inFSlot = false
end

function APIGateway.IsDeviceOrientationPortrai()
    local v = jsCall("IsDeviceOrientationPortrait")
    if v ~= nil then return v end
    return false
end

function APIGateway.GetCurRegion()
    local v = jsCall("GetCurRegion")
    if v then return v end
    return "zh"
end

function APIGateway.Clear()
    jsCall("Clear")
end
