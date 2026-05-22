local path = "hall.src.hallnew.layers."

function init_layers()
    MsgBoxLayer         = require(path .. "common.MsgBoxLayer")
    ToastLayer          = require(path .. "common.ToastLayer")
    LoadingLayer        = require(path .. "common.LoadingLayer")

    LobbyLayer          = require(path .. "LobbyLayer.LobbyLayer")
    FishRoomLayer       = require(path .. "LobbyLayer.FishRoomLayer.FishRoomLayer")
    FishLevelLayer      = require(path .. "LobbyLayer.FishLevelLayer")
    EnterFishLayer		= require(path .. "LobbyLayer.enterfishlayer.EnterFishLayer")
    EffectLayerStar		= require(path .. "LobbyLayer.EffectLayerStar")

    ChatLayer           = require(path .. "lobby.ChatLayer")

    LobbyGoogleRechargeLayer	= require(path .. "lobby.LobbyGoogleRechargeLayer")

    GivePasswordLayer = require(path .. "lobby.give.GivePasswordLayer")
    GiveLayer = require(path .. "lobby.give.GiveLayer")
    InputGivePasswdLayer = require(path .. "lobby.give.InputGivePasswdLayer")
    GiveHistoryLayer = require(path .. "lobby.give.GiveHistoryLayer")
    
    -- --弹窗管理
    PopLayer = require(path .. "PopLayer").new()
end

function reinit_layers()
    for path_,__ in pairs(package.loaded) do
        if string.find(path_, path) then
            package.loaded[path_] = nil
        end
    end
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    init_layers()
end


init_layers()
