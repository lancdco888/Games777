if not CreatorNetworkHelp then
    CREATOR.getMsgCallback = function(msg)
        if CreatorNetworkHelp then
            CreatorNetworkHelp.OnGetPackage(msg)
        end
    end


    CREATOR.onGetMsgError = function(aSerialID)
        if CreatorNetworkHelp then
            CreatorNetworkHelp.OnGetPackageError(aSerialID)
        end
    end
end

CreatorNetworkHelp = CreatorNetworkHelp or {}

local callBackMap = {}

local subscriber = {}

---@type GameProtocolHub
local _protocolHub = nil

function CreatorNetworkHelp.getHub()
    if _protocolHub == nil then
        local requireString = string.format("FGame.Game%d.Hub.Game%dHub", FCasinoCtx.gameId, FCasinoCtx.gameId)
        _protocolHub = require(requireString).new()
    end
    
    return _protocolHub
end

function CreatorNetworkHelp.OnGetPackage(msg)
    if not FCasinoCtx then
        return
    end

    local parseData = CreatorNetworkHelp.getHub():ParseNetwork(msg)
    if parseData then
        local cID = msg.serialID

        if callBackMap[cID] then
            print("lua get package do call back :" .. tostring(cID))
            callBackMap[cID](parseData ~= nil, parseData);
        end

        CreatorNetworkHelp.SendSubscriber(parseData)
    end
end

function CreatorNetworkHelp.OnGetPackageError(aSerialID)
    if not FCasinoCtx then
        return
    end
    
    if callBackMap[aSerialID] then
        print("lua get package error do call back :" .. tostring(cID))
        callBackMap[aSerialID](false, {});
    end
end

function CreatorNetworkHelp.SendSubscriber(msgJson)
    local msgName = msgJson._msgName_
    local list = nil;
    if subscriber[msgName] then
        list = subscriber[msgName];
    end
    if list and #list > 0 then
        for key, value in pairs(list) do
            value.callback(msgJson)
        end
    end
end

function CreatorNetworkHelp.SendRequest(msg, callback)
    local hub = CreatorNetworkHelp.getHub()
    msg = hub:transformToServer(msg)
    if not msg then
        return;
    end

    if callback then
        local serialId = CREATOR.createSerialId()
        msg._seralID_ = serialId
        callBackMap[-serialId] = callback;
    end

    CREATOR.sendRequest(cjson.encode(msg))
end

---------------------subscriber
function CreatorNetworkHelp.AddSubscriber(msgName, callback, target)
    subscriber[msgName] = subscriber[msgName] or {}
    table.insert(subscriber[msgName], { callback = callback, target = target })
end

function CreatorNetworkHelp.RemoveSubscriber(msgName, target)
    local list = subscriber[msgName]
    for index, value in ipairs(list) do
        if value.target == target then
            table.remove(list, index);
            break
        end
    end
end

function CreatorNetworkHelp.RemoveAllSubscribers(msgName)
    subscriber[msgName] = {}
end

return CreatorNetworkHelp;
