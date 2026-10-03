-- Creator FairyGUI adapter stub.
-- Wire to FairyGUI-Creator (npm / native) when the Creator project integrates the runtime.

FairyGUI = FairyGUI or {}

FairyGUI.UIPackage = FairyGUI.UIPackage or {
    AddPackage = function(path)
        print("[Creator.FairyGUI] AddPackage", path)
    end,
    RemovePackage = function(path)
        print("[Creator.FairyGUI] RemovePackage", path)
    end,
    CreateObject = function(pkg, res)
        print("[Creator.FairyGUI] CreateObject", pkg, res)
        return nil
    end,
}

FairyGUI.GTween = FairyGUI.GTween or {
    KillAllTweens = function() end,
    To = function(v1, v2, v3) return { OnUpdate = function() return end, OnComplete = function() return end } end,
    ToDouble = function(v1, v2, v3) return { OnUpdate = function() return end, OnComplete = function() return end } end,
}

FairyGUI.UIConfig = FairyGUI.UIConfig or {}
FairyGUI.UIConfig.onMusicCallback = function(path, volumnScale)
    if gSound and gSound.playEffect then
        gSound.playEffect(path, false)
    end
end

local fairyRoot = nil

function CreateFairyRoot()
    assert(fairyRoot == nil)
    print("[Creator.FairyGUI] CreateFairyRoot")
    fairyRoot = { platform = "creator" }
    if APIGateway and APIGateway.OnEnter then
        APIGateway.OnEnter()
    end
    return fairyRoot
end

function DestroyFairyRoot()
    if fairyRoot then
        if gSound and gSound.stopAll then
            gSound.stopAll()
        end
        if APIGateway and APIGateway.OnDestroy then
            APIGateway.OnDestroy(fairyRoot)
        end
        fairyRoot = nil
        print("[Creator.FairyGUI] DestroyFairyRoot")
    end
end

function GetFairyRoot()
    return fairyRoot
end
