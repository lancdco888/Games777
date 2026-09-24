---@field CasinoContext CasinoContext
local CasinoContext = Import(".CasinoContext")
local EventEmitter  = Import(".Utils.EventEmitter")

---@field  CasinoContext CasinoContext
FCasinoCtx          = nil

-- @brief 老虎机入口函数
-- @param gameId 游戏id
-- @param enterData 类型应该为 PB.Slots_Client.Enter_Success
-- @param reconnectData 类型应该为 PB.Client_Slots.Enter 请求返回的游戏断线重连类型
function RunCasino(gameId, enterData, reconnectData)
    assert(FCasinoCtx == nil)

    -- 系统事件派发器
    FSysEventEmitter = EventEmitter.New()

    
    CreateFairyRoot()
    FCasinoCtx = CasinoContext.New(gameId, enterData, reconnectData)
    FCasinoCtx:Init()
end

-- @brief 销毁老虎机
function DestroyCasino()
    if FCasinoCtx == nil then return end

    local function doexit()
        FCasinoCtx:Delete()
        FCasinoCtx = nil

        FSysEventEmitter:Delete()

        DestroyFairyRoot()

        StopAllTimer()

        -- 打印class泄漏
        ClassTracker:Dump()
        ClassTracker:Clear()

        -- 返回大厅
        APIGateway.EnterLobby()

        if APIGateway.Clear then
            APIGateway.Clear()
        end
    end

    if ax then
        try {
            doexit,
            catch = function()
                if FlushLogFile then FlushLogFile() end
                -- 退出出错正式包直接重启游戏
                if not isShowDebugInfo() then

                    if DESIGNED_RESOLUTION_W and DESIGNED_RESOLUTION_H then
                        if DESIGNED_RESOLUTION_W > DESIGNED_RESOLUTION_H then
                            -- 横屏
                            gDeviceData:setScreenType(1)
                        else
                            -- 竖屏
                            gDeviceData:setScreenType(2)
                        end
                    else
                        gDeviceData:setScreenType(1)
                    end
                    
                    cc.FileUtils:getInstance():purgeCachedEntries()
                    cc.Director:getInstance():restart()
                end
            end
        }
    else
        doexit()
    end
end
