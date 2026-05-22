local BetConfigParser = Class("BetConfigParser")

function BetConfigParser:ctor()    
    -- 当前C位下标
    self.curCIndex = 1
    -- 当前押注档位
    self.curBetGear = 1
    
    -- 解析当前游戏押注档位配置
    self.betCfg = {}
    
    for k, v in pairs(FCasinoCtx.enterData.betRatios) do
        local lvID = v.lvID % 10

        if not self.betCfg[lvID] then
            self.betCfg[lvID] = {}
        end

        -- 选C限制
        local enabled = true
        local desc = ""
        for __, condition in pairs(FCasinoCtx.enterData.entryConditions) do
            if condition.id == v.lvID then
                if FCasinoCtx.lobbyData.isCasinoLevelOpen then
                    enabled = FCasinoCtx.playerMoney >= condition.enterMinMoney
                end
                desc = condition.desc
            end
        end

        table.insert(self.betCfg[lvID], {
            betMoney = v.betMoney,
            betLine  = v.betLine,
            rawLvId  = v.lvID,
            lvID     = lvID,
            enabled  = enabled,
            strCValue= desc
        })
    end

    
    local lvID = nil
    local curBetMoney = nil
    -- 通过断线重连数据推断当前C位
    local reconnectData = FCasinoCtx.reconnectData
    if reconnectData then
        lvID = reconnectData.lvID % 10
        curBetMoney = reconnectData.currentBetMoney
    else
        -- 通过大厅数据推断当前C位
        local curSlotsLevel = FCasinoCtx.lobbyData.curSlotsLevel
        if curSlotsLevel then
            lvID = curSlotsLevel.id % 10
            curBetMoney = curSlotsLevel.spinMinMoney
        end
    end
    
    -- 没有则取第一个配置
    if lvID == nil then
        for id, cfg in pairs(self.betCfg) do
            for k, v in pairs(cfg) do
                self.curCIndex = id
                self.curBetGear = k
                break
            end
            break
        end
    else
        for k, v in pairs(self.betCfg[lvID]) do
            if v.betMoney == curBetMoney then
                self.curCIndex = lvID
                self.curBetGear = k
                break
            end
        end
    end

    self.betCValues = {}
    for k, v in pairs(self.betCfg) do
        local cValue = string.match(v[1].strCValue, "(%d+)")
        cValue = tonumber(cValue)
        self.betCValues[k] = cValue
    end
end


return BetConfigParser