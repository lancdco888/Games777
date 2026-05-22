FToolSet = {}

-- @brief 数字转字符串
-- @param value : number
-- @param isConvertInteger 是否强制截断为整数
-- @param useGameExchangeRate 是否使用大厅汇率
-- @param maxDecimalPlaces 最大小数位
-- @return string
function FToolSet.NumToStr(value, isConvertInteger, useLobbyExchangeRate, maxDecimalPlaces)
    if FCasinoCtx == nil then return "" end

    if useLobbyExchangeRate then
        value = value / FCasinoCtx.lobbyData.lobbyExchangeRate
    else
        value = value / FCasinoCtx.lobbyData.gameExchangeRate
    end

    -- 是否强制转换为整形
    if isConvertInteger == nil then
        isConvertInteger = FConfig.Common.GameScoreForceToInt
    end
    
    local formatted    
    if isConvertInteger then
        formatted= string.format("%d", math.floor(value))
    else
        formatted= tostring(value)
        
        -- 去除尾部0
        -- 1.0 -> 1
        formatted = string.gsub(formatted, "%.0+$", "")
        if string.find(formatted, "%.") then
            -- 保留三位有效小数位
            -- 1.123456 -> 1.123
            formatted = string.gsub(formatted, "(%.%d%d%d)(%d+)$", "%1")

            -- 去除尾部0
            -- 1.230 -> 1.23
            formatted = string.gsub(formatted, "0+$", "")
            -- 去除尾部.
            -- 0. -> 0
            formatted = string.gsub(formatted, "%.$", "")
        end
    end

    -- 保留小数位，多了裁掉，不够则补齐
    if FTheme.curThemCfg.textDecimalPlaces ~= nil then
        formatted = FToolSet.FixedDecimalPlaces(formatted, FTheme.curThemCfg.textDecimalPlaces)
    else
        -- 大厅汇率固定小数
        if useLobbyExchangeRate then
            formatted = FToolSet.FixedDecimalPlaces(formatted, FConfig.Common.TopLobbyRateTextDecimalPlaces)
        end
    end

    -- 最大保留小数位
    maxDecimalPlaces = maxDecimalPlaces or 2
    if FToolSet.GetDecimalPlaces(formatted) > maxDecimalPlaces then
        formatted = FToolSet.FixedDecimalPlaces(formatted, maxDecimalPlaces)
    end

    return formatted
end

-- @brief 彩金 NumToStr
function FToolSet.LotteryNumToStr(value, isConvertInteger, useLobbyExchangeRate)
    if useLobbyExchangeRate then
        value = value / FCasinoCtx.lobbyData.lobbyExchangeRate
    else
        value = value / FCasinoCtx.lobbyData.gameExchangeRate
    end

    return FToolSet.FixedDecimalPlaces(tostring(value), 2)
end

-- @brief 添加逗号分割
function FToolSet.AddCommaSeparation(str)
    local k
    while true do
        str, k = string.gsub(str, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return str
end


-- @param 固定小数位
--        如str为0.1        固定位数为3   则返回0.100
--        如str为100.1456   固定位数为0   则返回100 
-- @param str: string
-- @param decimalPlaces: number 小数位
function FToolSet.FixedDecimalPlaces(str, decimalPlaces)
    local dp1 = FToolSet.GetDecimalPlaces(str)
    -- 小数位数一致
    if dp1 == decimalPlaces then
        return str
    end

    if dp1 > decimalPlaces then
        if decimalPlaces == 0 then
            return string.sub(str, 1, -(dp1 - decimalPlaces + 2))
        end
        return string.sub(str, 1, -(dp1 - decimalPlaces + 1))
    else
        if dp1 == 0 then
            str = str .. "."
        end
        
        return str .. string.rep("0", decimalPlaces - dp1)
    end
end

-- @brief 获取小数点后面位数
--        如str为100.1456   返回4 
-- @param str: string
function FToolSet.GetDecimalPlaces(str)
    -- 小数点后面的位数
    local decimalPlaces = 0

    local s, e = string.find(str, "%.%d*")
    if s then
        decimalPlaces = e - s
    else
        decimalPlaces = 0
    end
    return decimalPlaces
end


-- 根据押注动态计算彩金的游戏
local dynamicBonusGames = {
    820,
    816,
    823,
}

-- @brief 获取动态彩金倍率值
function FToolSet.GetBonusMultiplier()
    local rawGameId = FCasinoCtx.lobbyData.rawGameId
    local dynamic = false

    for _, v in pairs(dynamicBonusGames) do
        if v == rawGameId then
            dynamic = true
            break
        end
    end

    if dynamic or rawGameId < 250 or FCasinoCtx.lobbyData.isLotteryBetMode then
        -- 当前押注值
        return FCasinoCtx.commonPanel:GetBetMoney()        
    end
    -- 当前C位最大押注值
    local list = FCasinoCtx.commonPanel:GetCurCConfigList()
    return list[#list].betMoney
end

-- @brief 获取落地牌betScale
function FToolSet:GetBetScale()
    local cfg = FCasinoCtx.commonPanel:GetCurrentBetConfig()
    return cfg.betMoney / cfg.betLine
end

-- @brief 播放FairyGUI音效
function FToolSet.PlayFGUISound(url, loop)
    local item = FairyGUI.UIPackage.GetItemByURL(url)
    if not item then
        return -1
    end
    return APIGateway.PlaySound(item.file, loop)
end

-- @brief 播放背景音乐
function FToolSet.PlayBGM(url)
    local item = FairyGUI.UIPackage.GetItemByURL(url)
    if not item then
        FToolSet.StopBGM()
        return -1
    end

    if FTheme.curThemCfg.useUnifiedSoundOutlet then
        FToolSet.StopBGM()
        FToolSet.bgmSoundHandle = FToolSet.PlayFGUISound(url, true)
        return FToolSet.bgmSoundHandle
    else
        return APIGateway.PlayBGM(item.file)
    end
end

function FToolSet.StopBGM()
    APIGateway.StopSound(FToolSet.bgmSoundHandle)
    FToolSet.bgmSoundHandle = nil
    APIGateway.StopBGM()
end

function FToolSet.FmtLogMoney(money)
    return string.format("%f(%s)", money, FToolSet.NumToStr(money))
end


function FToolSet.AddClickListener(btn, callback)
    APIGateway.AddEventListener(btn, FGUIEventKey.onClick, function()
        if not btn.touchable then return end
        if callback then callback() end
    end, true)
end

-- @brief 十二选三倒计时提示文本
function FToolSet.FmtAutoSelectTip(time)
    return string.format("Automatic selection after %d seconds", time)
end

-- 序列帧动画播一次
-- node：动画节点
-- endVisible：结束是否隐藏
-- callback： 回调
function FToolSet.PlayOnceAnim(node,endVisible,callback)
    if not node then
        print("error: FToolSet.PlayOnceAnim not node")
        return 
    end
    endVisible = endVisible or false
    node.visible = true
    node.frame = 0
    node:SetPlaySettings(0,-1,1,-1,
        function ()
            node.visible = endVisible
            node.playing = false
            node.frame = 0
            if callback then
                callback()
            end
        end
    )
    node.playing = true
end

-- table  元素数量
function FToolSet.CheckTabCount(tab)
    local count = 0
    for _, v in pairs(tab) do
        if v then
            count = count + 1
        end
    end
    return count
end

-- A点到O点的角度
function FToolSet:A2ODeg(APos,OPos)
    local deg = 0
    if OPos.x == APos.x then
        if APos.y > OPos.y then
            deg = 90
        else
            deg = -90
        end
    elseif OPos.y == APos.y then
        if APos.x > OPos.x then
            deg = 0
        else
            deg = 0
        end
    else
        deg = math.deg(math.atan((OPos.y-APos.y )/(OPos.x-APos.x)))
    end
    return deg
end

-- 遍历子节点 执行函数  不会深度遍历，只有一层
function FToolSet:ChildrenIPairs(obj,func)
    local num = obj.numChildren
    local childs = {}
    for i = 0, num-1 do
        table.insert(childs,obj:GetChildAt(i))
    end
    for i, child in ipairs(childs) do
        func(i,child)
    end
end

-- endVisible:结束时是否显示node -- webm动画执行一次
FToolSet.PlayOnceWebmAnim = function(anim,endVisible,callback)
    if not anim then
        print("error: FToolSet.PlayOnceWebmAnim not node")
        return 
    end
    endVisible = endVisible or false
    anim:SetVisible(true)
    anim:RePlay(1,function ()
        anim:SetVisible(endVisible)
        if callback then
            callback()
        end
    end)
end

FToolSet.Image2Webm = function(image)
    if RUNTIME_IN_CREATOR then
        return image.node:getComponent("WebmComponent")
    end
    return image.webmAnimation
end

-- @brief 由于缅甸，越南，印尼钱币面值很大，游戏比例都是1：1，为了方便玩家立即做以下改动需求，不需要显示小数点
-- 游戏内不需要钱分切换，全部显示分
function FToolSet.IsForceShowGameScore()
    local region = APIGateway.GetCurRegion()
    if region == "mm" or region == "vn" or region == "ind" then
        return true
    end
    return false
end

-- [[定时器 绑定class 
-- 删除class时 FToolSet:StopAllTimers(self) 会自动停止所有的定时器
FToolSet.timers = {}
function FToolSet:StartOnceTimer(callback, delay, obj)
    if not obj then
        print("StartOnceTimer error: not obj")
        return
    end
    self.timers[obj] = self.timers[obj] or {}
    local id = #self.timers[obj] + 1
    for i, v in ipairs(self.timers) do
        if v == 0 then
            id = i
            break
        end
    end
    self.timers[obj][id] = StartOnceTimer(function ()
        -- self:StopTimer(id, obj)
        self.timers[obj][id] = 0
        if callback then
            callback()
        end
    end, delay)
    return id
end

function FToolSet:StopTimer(id, obj)
    if not id or not obj then
        print("StopTimer error: not obj or id")
        return
    end
    self.timers[obj] = self.timers[obj] or {}
    if self.timers[obj][id] ~= 0 then
        StopTimer(self.timers[obj][id])
        self.timers[obj][id] = 0
    else
        print("Tools:StopTimer was stoped")
    end
end

function FToolSet:StopAllTimers(obj)
    if not self.timers[obj] then
        print("Tools:StopAllTimers(obj) not obj: ", obj)
        return
    end
    for i, v in pairs(self.timers[obj]) do
        if v ~= 0 then
            StopTimer(v)
        end
    end
    self.timers[obj] = nil
end

function FToolSet:TrimNumStrTailZero(str)
    if string.find(str, "%.") then
        -- 去除尾部0
        -- 1.230 -> 1.23
        str = string.gsub(str, "0+$", "")
        -- 去除尾部.
        -- 0. -> 0
        str = string.gsub(str, "%.$", "")
    end
    return str
end
