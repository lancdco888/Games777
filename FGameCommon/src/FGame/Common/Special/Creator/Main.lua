package.path = '/FGame/?.lua;' .. package.path

require("FGame.Common.Special.Creator.Functions")
CREATOR = FromJS("Creator");
GameHub = nil;

require("FGame.Common.Global")

__G__TRACKBACK__ = function(msg)
    local msg = debug.traceback(msg, 3)
    CREATOR.printErr(msg)
    return msg
end

function CreatorRunGame (aGameID)
    local enterstr = CREATOR.gGameData.gameStatusString;
    local resumeStr = CREATOR.gGameData.gameResumeString;

    local enterJson = cjson.decode(enterstr)
    local resumeJson = nil;
    if resumeStr then
        resumeJson = cjson.decode(resumeStr)
    end

    local requireString = string.format("FGame.Game%d.Hub.Game%dHub", aGameID, aGameID)
    -- print("will load Hub file:"..requireString)
    ---@type GameProtocolHub
    GameHub = require(requireString)
    local enterData, resumeData = GameHub:ConvertEnterData(enterJson, resumeJson)

    xpcall(function()
        RunCasino(aGameID, enterData, resumeData)
    end, __G__TRACKBACK__)
end
