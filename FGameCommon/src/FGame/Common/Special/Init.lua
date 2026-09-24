if RUNTIME_IN_COCOS then
    if RUNTIME_IN_COCOS_FISH2 then
        Import(".CocosFish2.FairyGUI")
        Import(".CocosFish2.FairyGUIConstants")
        Import(".CocosFish2.Timer")
        Import(".CocosFish2.APIGateway")
    elseif RUNTIME_IN_COCOS_H5 then
        Import(".CocosH5.FairyGUI")
        Import(".CocosH5.FairyGUIConstants")
        Import(".CocosH5.Timer")
        Import(".CocosH5.APIGateway")
    elseif RUNTIME_IN_COCOS_NEONARCADE then
        Import(".CocosNeonArcade.FairyGUI")
        Import(".CocosNeonArcade.FairyGUIConstants")
        Import(".CocosNeonArcade.Timer")
        Import(".CocosNeonArcade.APIGateway")
    else
        Import(".Cocos.FairyGUI")
        Import(".Cocos.FairyGUIConstants")
        Import(".Cocos.Timer")
        Import(".Cocos.APIGateway")
    end
elseif RUNTIME_IN_CREATOR then
    Import(".Creator.FairyGUI")
    Import(".Creator.FairyGUIConstants")
    Import(".Creator.Timer")
    Import(".Creator.APIGateway")
elseif RUNTIME_IN_UNITY then
    Import(".Unity.FairyGUI")
    Import(".Unity.FairyGUIConstants")
    Import(".Unity.Timer")
    Import(".Unity.APIGateway")
end


-- 2024-8-13 17:40:15
-- H5平台 泰国 墨西哥 巴西 大厅汇率显示三位小数
if RUNTIME_USE_H5_PROTO then
    local region = APIGateway.GetCurRegion()
    if region == "br" or region == "tha" or region == "mex" or region == "es" then
        FConfig.Common.TopLobbyRateTextDecimalPlaces = 3
    end
end