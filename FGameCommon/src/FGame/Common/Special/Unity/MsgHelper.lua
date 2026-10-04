local msgSender = require("network.msg.msgsender")
local msgDispatcher = require "network.msg.msgdispatcher"
local pbHelper = require "network.pbhelper"

-- msgName to msgId.
local function GetMsgId(msgName)
    return pbHelper.getTypeId(msgName)
end

-- msgId to msgName.
local function GetMsgName(msgId)
    return pbHelper.getMsgName(msgId)
end

-- callback为可选参数.
-- 如果callback为null,则为普通推送消息.
-- callback回调参数: (isOk: bool, rsqMsg: table).
local function Send(reqMsgName, reqMsg, callback)
    -- reqMsgName参数也可以传msgId.
    if type(reqMsgName) == "number" then
        reqMsgName = GetMsgName(reqMsgName)
    end
    local cb = callback and function (isTimeout, resMsgId, resMsg)
        local isOk = not isTimeout
        if isOk then
            local resMsgName = GetMsgName(resMsgId)
            resMsg._msgName_ = resMsgName
        end

        local msgName = isOk==true and GetMsgName(resMsgId) or "no_ok"
        dump( resMsg, "[回包] FGUI <<< " .. msgName )

        callback(isOk, resMsg)
    end or nil
    
    dump( reqMsg, "[发包] FGUI >>> " .. tostring(reqMsgName) )

    msgSender.send(reqMsgName, reqMsg, cb)
end

local callbackMap = {}

local function AddSubscriber(msgId, callback, target)
    assert(callback ~= nil)
    local cb = function(resMsgId, resMsg)
        local msgName = GetMsgName(resMsgId)
        resMsg._msgName_ = msgName
        callback(resMsg)
    end
    callbackMap[callback] = {
        callback = cb,
        target = target,
    }
    msgDispatcher.addSubscriber(msgId, cb, target)
end

local function RemoveSubscriber(msgId, callback)
    local cb = callbackMap[callback]
    callbackMap[callback] = nil
    msgDispatcher.removeSubscriber(msgId, cb.callback)
end

local function RemoveAllSubscribers(target)
    assert(target ~= nil)
    for k, v in pairs(callbackMap) do
        if v.target == target then
            callbackMap[k] = nil
        end
    end
    msgDispatcher.removeAllSubscribers(target)
end

local function Clear()
    for _, v in pairs(callbackMap) do
        msgDispatcher.removeAllSubscribers(v.target)
    end
    callbackMap = {}
end

return {
    GetMsgId = GetMsgId,
    GetMsgName = GetMsgName,
    Send = Send,
    AddSubscriber = AddSubscriber,
    RemoveSubscriber = RemoveSubscriber,
    RemoveAllSubscribers = RemoveAllSubscribers,
    Clear = Clear,
}
