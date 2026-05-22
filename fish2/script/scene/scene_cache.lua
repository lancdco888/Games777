-- scene/scene_cache.lua
local root, lua = ...

--local unpack = unpack or table.unpack

FF_G.shakesCache = {}

local NilNumber = -99999    -- 代表空

local TimeLineType_FishBorn             = 0             -- 鱼出生
local TimeLineType_SwitchScene          = 1             -- 播放切换场景动画
local TimeLineType_SwitchBg             = 2             -- 切换背景
local TimeLineType_SetPlayRatio         = 3             -- 设置播放速度(切换场景前加速离场)
local TimeLineType_PlayBgAnim           = 4             -- 播放背景动画
local TimeLineType_ClearFish            = 5             -- 清除所有鱼
local TimeLineType_HaiwanglaixiTips     = 6             -- 海王来袭动画
local TimeLineType_SwitchBgMusic        = 7             -- 切换背景音乐
local TimeLineType_Shake                = 8             -- 屏幕震动
local TimeLineType_BossWarning          = 9             -- Boss预警
local TimeLineType_End                  = 10            -- Loop结束标志

FF_G.Haiwanglaixi_FishType_KingOctopus          = 1            -- 八爪章鱼
FF_G.Haiwanglaixi_FishType_NightBeast           = 2            -- 暗夜巨兽
FF_G.Haiwanglaixi_FishType_KingCrab             = 3            -- 霸王蟹
FF_G.Haiwanglaixi_FishType_Crocodile            = 4            -- 史前巨鳄
FF_G.Haiwanglaixi_FishType_WakeupKingOctopus    = 10           -- 觉醒八爪章鱼
FF_G.Haiwanglaixi_FishType_WakeupNightBeast     = 11           -- 觉醒暗夜巨兽
FF_G.Haiwanglaixi_FishType_WakeupKingCrab       = 12           -- 觉醒霸王蟹
FF_G.Haiwanglaixi_FishType_WakeupCrocodile      = 13           -- 觉醒史前巨鳄
FF_G.Haiwanglaixi_FishType_Wakeup               = 100          -- 觉醒

FF_G.BossWarning_Red            = 1  -- 红色
FF_G.BossWarning_Purple         = 2  -- 紫色
FF_G.BossWarning_BossCome       = 3  -- BOSS来袭
FF_G.BossWarning_BisonComing    = 4  -- 蛮荒凶兽来袭

local fishGroup1 = FF_G.LoadLuaFunc("script/config/fish_group.lua")()
local fishGroup = {}

local InitFishGroup = function(fishGroup1)
    for name, fishTypes in pairs(fishGroup1) do
        for _, fishType in ipairs(fishTypes) do
            fishGroup[fishType] = fishGroup[fishType] or {}
            table.insert(fishGroup[fishType], name)
        end
    end
end

InitFishGroup(fishGroup1)

local getTableStr = function(t)
    local txt = ''
    for _, v in ipairs(t) do
        txt = txt .. v .. ", "
    end
    return txt
end

local CloseAll = function(name)
    local actions = root:FindActionsByLuaName(name)
    for _, action in ipairs(actions) do
        action:GetLua():OnCall("exit")
    end
end

-- 切换背景
local SwitchBg = function (index)
    --print("switch bg:" .. index)
    CloseAll("action/bg.lua")
    CloseAll("action/bg_cs.lua")
    if index >= 100 then
        local actionName = string.format("actions/cs/bg/bg%d.actions", index)
        root:ShowEffect(actionName, "enter",
                "action/bg_cs.lua", FF_G.kNodeIndex_Bg, 0, 0, true)
    else
        local actionName = string.format("actions/bg/bg%d.actions", index)
        root:ShowEffect(actionName, "enter",
                "action/bg.lua", FF_G.kNodeIndex_Bg, 0, 0, true)
    end
end

local gameId = root:GetGameId()
local timelineCache = root:GetTimelineCache()
local gameTimeLines = timelineCache:GetGameTimeLines(gameId)
local isEmpty = gameTimeLines:IsEmpty()

--print("gameId:", gameId)
--print("isEmpty:", isEmpty)

local sceneIndex = 0

-- 生成一个场景
local CreateScene = function(totalSeconds)
    local inited = false
    local scene = {}
    local eventCount = 0
    -- 时间线事件
    local timeLine = {}
    -- 捕鱼规则
    local rules = {}

    local currentSceneIndex = sceneIndex
    local fishEventTimelines
    if isEmpty then
        gameTimeLines:PushTimeLines()
    --else
    --    fishEventTimelines = gameTimeLines:GetTimeLines(sceneIndex)
    end
    sceneIndex = sceneIndex + 1

    local fishEventIndex = 0
    -- 震动事件缓存
    --local shakesCache = {}
    local PushShake = function(shake)
        table.insert(FF_G.shakesCache, shake)
        return #FF_G.shakesCache
    end

    local GetFishBornEvent = function(time, info)
        local fish = info.fish
        local fishParamType = type(fish)
        local fishTypes, pathways
        local fixedPathway = info.fixedPathway
        if fishParamType == "number" or fishParamType == "string" then
            fishTypes = { fish }
        elseif fishParamType == "table" then
            fishTypes = fish
        end
        FF_G.Assert(fishTypes ~= nil and #fishTypes > 0)

        if FilterBornEvent then
            FilterBornEvent(time, fishTypes)
        end

        local lineCount = info.lineCount
        if lineCount then
            fixedPathway = true
        end
        if info.pathway then
            fixedPathway = true
            lineCount = 1
            pathways = { info.pathway }
        else
            assert(info.pathwayGroup ~= nil, "Pathway and pathway group can't both nil.")
            pathways = FF_G.PathwayHelper.GetPathwayNamesByGroup(info.pathwayGroup)
        end
        assert(#pathways > 0)
        local fishTypeCount = info.fishTypeCount
        if type(fishTypeCount) == 'table' and #fishTypeCount == 0 then
            fishTypeCount = nil
        end
        local fishCount = info.fishCount
        if not fishCount then
            if type(fishTypeCount) == 'number' then
                fishCount = fishTypeCount
            else
                fishCount = #fishTypes
            end
        end
        if not info.fixedFishType then
            if type(fishCount) == 'number' then
                --assert(fishCount <= #fishTypes, debug.traceback("", 10))
                if fishCount > #fishTypes then
                    print("fishCount:", fishCount)
                    print("fishTypes:", getTableStr(fishTypes))
                    print(debug.traceback("Stack trace"))
                    print(debug.getinfo(1))
                    assert(false)
                end
            else
                for _, count in ipairs(fishCount) do
                    if count > #fishTypes then
                        print("fishCount:", getTableStr(fishCount))
                        print("fishTypes:", getTableStr(fishTypes))
                        print(debug.traceback("Stack trace"))
                        print(debug.getinfo(1))
                        assert(false)
                    end
                end
            end
        end
        if type(fishCount) == 'number' then
            fishCount = { fishCount }
        end
        if type(fishTypeCount) == 'number' then
            fishTypeCount = { fishTypeCount }
        elseif fishTypeCount == nil then
            fishTypeCount = {}
        end
        return {
            time = time,
            type = TimeLineType_FishBorn,
            speedScale = info.speedScale or 1.0,
            fishTypes = fishTypes,                              -- 鱼类型组
            fishCount = fishCount,                              -- 鱼的数量
            fishTypeCount = fishTypeCount,                      -- 鱼类型数量
            lineCount = lineCount or 1,                         -- 选择的鱼线数量
            intervalTime = info.intervalTime or 0,              -- 两条鱼的间隔时间
            fixedPathway = fixedPathway == true,
            fixedFishType = info.fixedFishType == true,
            offsets = info.offsets or {},
            offsetAngles = info.offsetAngles or {},
            pathways = pathways,                                -- 鱼线组
            action = info.action or "",
            script = info.script or "",
            notRemove = info.notRemove == true,                 -- 走完先不删除
            -- table
            createPrams = info.createPrams,
            subPathway = info.subPathway,
            -- 不需要缓存到c++
            shakes = info.shakes,
            --maker = maker,                                    -- 废弃
            --prams = info.prams,                               -- 似乎废弃?
        }
    end

    local AddShakeEvents = function(time, shakes)
        if not FF_G.IsServer then
            for _, shake in ipairs(shakes) do
                scene.AddShakeEvent(time + shake.startTime, shake.continueTime, shake.strength)
            end
        end
    end

    scene.AddFishBornEvent = function(time, info)
        if isEmpty then
            --AddFishBornEvent(timeLine, unpack({...}))
            local bornInfo = GetFishBornEvent(time, info)
            local fishEventTimelines = gameTimeLines:GetTimeLines(currentSceneIndex)
            local bornEvent = fishEventTimelines:PushFishBornEvent()
            bornEvent:Init(bornInfo.fixedPathway, bornInfo.fixedFishType, bornInfo.lineCount, bornInfo.speedScale,
                    bornInfo.intervalTime, bornInfo.action, bornInfo.script, bornInfo.fishCount, bornInfo.fishTypeCount,
                    bornInfo.fishTypes, bornInfo.offsetAngles, bornInfo.offsets, bornInfo.pathways, bornInfo.notRemove)
            local createPrams = bornInfo.createPrams
            if createPrams then
                local fadeInSecs = createPrams.fadeInSecs or NilNumber
                local fadeOutStartTime = createPrams.fadeOutStartTime or NilNumber
                local fadeOutSecs = createPrams.fadeOutSecs or NilNumber
                local scaleInSec = createPrams.scaleInSec or NilNumber
                bornEvent:SetCreateParams(fadeInSecs, fadeOutStartTime, fadeOutSecs, scaleInSec)
            end
            local subPathway = bornInfo.subPathway
            if subPathway then
                for _, pathway in ipairs(subPathway) do
                    local useAngle = pathway.useAngle or false
                    local startTime = pathway.startTime or 0
                    local endTime = pathway.endTime or 0
                    local offsetTime = pathway.offsetTime or 0
                    local speed = pathway.speed or 0
                    local pathway = pathway.pathway
                    assert(pathway)
                    --print("push sub pathway:", pathway, speed, offsetTime, startTime, endTime)
                    bornEvent:PushSubPathways(useAngle, startTime, endTime, offsetTime, speed, pathway)
                end
            end
        end
        table.insert(timeLine, {
            time, TimeLineType_FishBorn, fishEventIndex,
        })
        fishEventIndex = fishEventIndex + 1
        if info.shakes then
            AddShakeEvents(time, info.shakes)
        end
    end
    -- 切换场景
    scene.AddSwitchSceneEvent = function(time)
        table.insert(timeLine, {
            time, TimeLineType_SwitchScene,
        })
    end
    -- 切换背景
    -- bgIndex: 背景id (目前只有支持1,3)
    scene.AddSwitchBgEvent = function(time, bgIndex)
        table.insert(timeLine, {
            time, TimeLineType_SwitchBg, bgIndex,
        })
    end
    -- 设置播放速度(切换)
    -- ratio(播放速率，默认为1)
    scene.AddSetPlayRatioEvent = function(time, ratio)
        table.insert(timeLine, {
            time, TimeLineType_SetPlayRatio, ratio,
        })
    end
    -- 设置背景动画
    -- animName(动画名)
    scene.AddSetPlayBgAnimEvent = function(time, animName, loops)
        table.insert(timeLine, {
            time, TimeLineType_PlayBgAnim, animName, loops == true,
        })
    end
    scene.AddClearFishEvent = function(time)
        table.insert(timeLine, {
            time, TimeLineType_ClearFish,
        })
    end
    -- 海王来袭动画
    scene.AddHaiwanglaixiEvent = function(time, fishType, ratio)
        table.insert(timeLine, {
            time, TimeLineType_HaiwanglaixiTips, fishType, ratio,
        })
    end
    -- 海王来袭动画
    -- fishId: 仅Boss_come需要
    scene.AddBossWarningEvent = function(time, warningType, info)
        if warningType == TimeLineType_BossWarning then
            assert(info)
            assert(info.ratio or info.fishTypeId)
        end
        info = info or {}
        table.insert(timeLine, {
            time, TimeLineType_BossWarning, warningType, info.fishTypeId, info.ratio,
        })
    end
    -- 切换背景音乐
    scene.AddSwitchBgMusicEvent = function(time, musicName)
        table.insert(timeLine, {
            time, TimeLineType_SwitchBgMusic, musicName,
        })
    end
    -- 屏幕震动事件
    scene.AddShakeEvent = function(time, continueTime, strength)
        table.insert(timeLine, {
            time, TimeLineType_Shake, continueTime, strength,
        })
    end
    -- 增加一条捕鱼规则
    -- rule -> {startTime, endTime, cdTime, bornEvent, groupName, limit}
    scene.AddRule = function(rule, info)
        assert(rule.checkDeathCd and type(info.fish) == "number" or true)
        rule.bornEvent = GetFishBornEvent(0, info)
        local shakes = info.shakes
        if shakes then
            rule.shakeEventIndex = PushShake(shakes)
        end
        table.insert(rules, rule)
    end

    --local waitTime = 0
    -- key -> fish type
    -- value -> [groupName]
    --local fishGroup = {}
    -- key -> fish type or group name
    -- value -> count
    local fishMonitor = {}
    -- key -> fishType
    local lastDeathTimeOfType = {}
    local lastLeaveTimeOfType = {}

    local getLastFishDeathTime = function(type)
        return lastDeathTimeOfType[type] or -1000
    end

    local getLastFishLeaveTime = function(type)
        return lastLeaveTimeOfType[type] or -1000
    end

    local addFishCount = function(typeId, num)
        local count = fishMonitor[typeId] or 0
        count = math.max(0, count + num)
        --print("add fish count:", typeId, ", ", num, ", ", count)
        fishMonitor[typeId] = count
        local group = fishGroup[typeId]
        if group then
            for _, name in ipairs(group) do
                local count = fishMonitor[name] or 0
                count = math.max(0, count + num)
                fishMonitor[name] = count
                --print("add fish count:", name, ", ", num, ", ", count)
            end
        end
    end

    local onFishBorn = function(typeId)
        addFishCount(typeId, 1)
    end

    local onFishRemoved = function(fish, isDeath)
        local typeId = fish:GetTypeId()
        addFishCount(typeId, -1)
        local group = fishGroup[typeId]
        local tp = root:CurrentTimePoint()
        if isDeath == true then
            lastDeathTimeOfType[typeId] = tp
            if group then
                for _, name in ipairs(group) do
                    lastDeathTimeOfType[name] = tp
                end
            end
        else
            lastLeaveTimeOfType[typeId] = tp
            if group then
                for _, name in ipairs(group) do
                    lastLeaveTimeOfType[name] = tp
                end
            end
        end
    end

    -- 处理鱼出生事件
    local handleFishBornEvent = function(event, delayTime, monitor, luaName, luaData, mutex, maskTypes)
        delayTime = delayTime or 0
        --local time11 = root:NowSteadyEpochSeconds()
        local pathways = event.pathways
        assert(event.fishTypes, "fishTypes is nil.")
        assert(pathways, "pathways is nil.")
        assert(#pathways > 0, "pathways size is 0.")
        local fishTypes
        if mutex == true then
            fishTypes = {}
            for _, type in ipairs(event.fishTypes) do
                if not maskTypes[type] then
                    table.insert(fishTypes, type)
                end
            end
        else
            fishTypes = table.copyArray(event.fishTypes)
        end
        local pathways = table.copyArray(pathways)
        local fixedPathway = event.fixedPathway
        local fixedFishType = event.fixedFishType
        -- 固定鱼线模式(出了不删除鱼线)
        if fixedPathway then
            local newPathways = {}
            for _ = 1, event.lineCount do
                local pathwayIndex = root:NextInt() % #pathways + 1
                local pathwayName = table.remove(pathways, pathwayIndex)
                table.insert(newPathways, pathwayName)
            end
            pathways = newPathways
        end
        --print("pathways len:" .. #pathways)

        local typeCount = event.fishTypeCount
        if type(typeCount) == "table" and #typeCount == 0 then
            typeCount = nil
        end
        if type(typeCount) == "table" then
            local index = root:NextInt() % #typeCount + 1
            typeCount = typeCount[index]
        end
        --print("type count:", typeCount)
        if typeCount then
            local newFishTypes = {}
            local len = math.min(typeCount, #fishTypes)
            for _ = 1, len do
                local fishTypeIndex = root:NextInt() % #fishTypes + 1
                local fishType = table.remove(fishTypes, fishTypeIndex)
                table.insert(newFishTypes, fishType)
            end
            fishTypes = newFishTypes
        end
        --print("fishTypes len:" .. #pathways)

        -- 出鱼数量
        local count = event.fishCount
        if type(count) == "table" then
            local index = root:NextInt() % #count + 1
            count = count[index]
        end
        if not fixedFishType then
            count = math.min(count, typeCount)
        end
        -- 间隔时间
        local intervalTime = event.intervalTime or 0

        local fishCount = 0
        local waitTime = 0

        local offsetsCount = event.offsets and #event.offsets or 0
        local offsetAnglesCount = event.offsetAngles and #event.offsetAngles or 0
        local subPathways = event.subPathway
        local action = event.action
        local script = event.script
        -- 脚本参数
        --local prams = event.prams
        local notRemove = event.notRemove

        while fishCount < count do
            --local time1 = root:NowSteadyEpochSeconds()
            local typeIndex = root:NextInt() % #fishTypes + 1
            local pathwayIndex = root:NextInt() % #pathways + 1
            local fishType, pathwayName
            -- 如果指定了鱼类型数量，则不删除
            if fixedFishType then
                fishType = fishTypes[typeIndex]
            else
                fishType = table.remove(fishTypes, typeIndex)
            end
            if fixedPathway then
                pathwayName = pathways[pathwayIndex]
            else
                pathwayName = table.remove(pathways, pathwayIndex)
            end
            --local time2 = root:NowSteadyEpochSeconds()
            local info = FF_G.TypeIdToFishCreator[fishType]
            --FF_PRAMS = prams
            if script and string.len(script) == 0 then
                script = nil
            end
            if action and string.len(action) == 0 then
                action = nil
            end
            assert(info, string.format("can't found fish type %d info.", fishType))
            local fish = FF_G.FishCreator(info, nil, script, action, event.createPrams)
            local pathway = FF_G.PathwayHelper.GetPathwayIndexByName(pathwayName)
            fish:SetPathwayIndex(pathway)
            fish:SetWaitTime(waitTime + delayTime)
            fish:SetSpeedScale(event.speedScale)
            if notRemove == true then
                fish:SetRemoveWhenEndOfPathway(false)
            end

            if subPathways then
                for _, subPathway in ipairs(subPathways) do
                    local pathwayIndex = FF_G.PathwayHelper.GetPathwayIndexByName(subPathway.pathway)
                    assert(pathwayIndex, "can't find pathway:" .. subPathway.pathway)
                    fish:PushSubPathway(subPathway.startTime, subPathway.endTime, subPathway.offsetTime,
                            subPathway.speed, pathwayIndex, subPathway.useAngle)
                end
            end
            if offsetsCount > 0 then
                local idx = fishCount % offsetsCount + 1
                local offset = event.offsets[idx]
                fish:SetOffset(offset[1], offset[2])
            end
            if offsetAnglesCount > 0 then
                local idx = fishCount % offsetAnglesCount + 1
                local offset = event.offsetAngles[idx]
                fish:SetOffsetAngle(offset)
            end
            if FF_G.IsStandalone then
                local ratio = fish:GetCoin()
                print("create fish:" .. fish:GetId() .. " " .. typeIndex, " " .. pathwayIndex, ", fish type:"
                        .. fishType, " " .. pathwayName)
                print("coin:" .. ratio)
            end
            root:AddFish(fish)
            onFishBorn(fishType)
            if monitor then
                luaName = luaName or ""
                GT = luaData or {}
                root:NotifyFishBornMsg(fish, root:CurrentTimePoint() + waitTime + delayTime, luaName)
            end
            fishCount = fishCount + 1
            waitTime = waitTime + intervalTime
            --local time3 = root:NowSteadyEpochSeconds()
            --print("create fish use:", time2 - time1, ",", time3 - time2)
        end
        --local time12 = root:NowSteadyEpochSeconds()
        --print("create fish event use:", time12 - time11)
    end

    local GetFishCount = function(groupName)
        return fishMonitor[groupName] or 0
    end
    local TryGetEvent = function(time, index, eventCount)
        if index > eventCount then
            return nil
        end
        local event = timeLine[index]
        local eventTime = event[1]
        if time >= eventTime then
            return event
        end
    end
    --scene.SetFishGroup = function(name, fishTypes)
    --    for _, fishType in ipairs(fishTypes) do
    --        fishGroup[fishType] = fishGroup[fishType] or {}
    --        --fishGroup[fishType][name] = true
    --        table.insert(fishGroup[fishType], name)
    --    end
    --end
    scene.PushFishGroups = function(_)
        --print("Deprecated function:scene.PushFishGroups().")
        --for name, fishTypes in pairs(fishGroup) do
        --    scene.SetFishGroup(name, fishTypes)
        --end
    end
    local Enable = function()
        fishMonitor = {}
        lastDeathTimeOfType = {}
        lastLeaveTimeOfType = {}
        lua:Set_onFishRemoved(onFishRemoved)
        for _, rule in ipairs(rules) do
            rule.waitTime = 0
        end
        for _, fish in ipairs(root:GetAllFish()) do
            local typeId = fish:GetTypeId()
            onFishBorn(typeId)
        end
    end
    local Disable = function() end
    local Update = function(t, eventCount)
        local time = t.sceneTime
        while true do
            local event = TryGetEvent(time, t.timeLineIndex, eventCount)
            if event == nil then break end
            t.timeLineIndex = t.timeLineIndex + 1
            local eventType = event[2]
            if eventType == TimeLineType_SwitchBg then
                local bgIndex = event[3]
                SwitchBg(bgIndex)
            elseif eventType == TimeLineType_SetPlayRatio then
                local ratio = event[3]
                root:SetPlayRatio(ratio)
            elseif eventType == TimeLineType_PlayBgAnim then
                local animName, loops = event[3], event[4]
                FF_G.Broadcast.sendBroadcast("bgPlayAnimEvent", {
                    msg = animName,
                    loops = loops,
                })
            elseif eventType == TimeLineType_SwitchScene then
                if not FF_G.IsServer then
                    FF_G_Client.FullBlisterEffect()
                end
            elseif eventType == TimeLineType_FishBorn then
                local fishEventIndex = event[3]
                --print("fish born event:", fishEventIndex)
                local bornEvent = fishEventTimelines:GetFishBornEvent(fishEventIndex)
                local fixedPathway, fixedFishType, lineCount, speedScale, intervalTime, action, script, fishCount,
                      fishTypeCount, fishTypes, offsetAngles, offsets, pathways, notRemove = bornEvent:GetFields()
                --if #fishTypeCount == 0 then
                --    fishTypeCount = nil
                --end
                local bornInfo = {
                    fixedPathway = fixedPathway,
                    fixedFishType = fixedFishType,
                    lineCount = lineCount,
                    speedScale = speedScale,
                    intervalTime = intervalTime,
                    action = action,
                    script = script,
                    fishCount = fishCount,
                    fishTypeCount = fishTypeCount,
                    fishTypes = fishTypes,
                    offsetAngles = offsetAngles,
                    offsets = offsets,
                    pathways = pathways,
                    notRemove = notRemove,
                }
                if bornEvent:HasCreateParams() then
                    local fadeInSecs, fadeOutStartTime, fadeOutSecs, scaleInSec = bornEvent:GetCreateParams()
                    if fadeInSecs       == NilNumber then fadeInSecs = nil end
                    if fadeOutStartTime == NilNumber then fadeOutStartTime = nil end
                    if fadeOutSecs      == NilNumber then fadeOutSecs = nil end
                    if scaleInSec       == NilNumber then scaleInSec = nil end
                    bornInfo.createPrams = {
                        fadeInSecs = fadeInSecs,
                        fadeOutStartTime = fadeOutStartTime,
                        fadeOutSecs = fadeOutSecs,
                        scaleInSec = scaleInSec,
                    }
                end
                local count = bornEvent:GetSubPathwaysCount()
                if count > 0 then
                    bornInfo.subPathway = {}
                    for i = 0, count - 1 do
                        local useAngle, startTime, endTime, offsetTime, speed, pathway = bornEvent:GetSubPathways(i)
                        table.insert(bornInfo.subPathway, {
                            useAngle = useAngle,
                            startTime = startTime,
                            endTime = endTime,
                            offsetTime = offsetTime,
                            speed = speed,
                            pathway = pathway,
                        })
                    end
                end
                handleFishBornEvent(bornInfo)
            elseif eventType == TimeLineType_ClearFish then
                --print("clear fish event")
                root:RemoveAllFish()
            elseif eventType == TimeLineType_SwitchBgMusic then
                local musicName = event[3]
                FF_G.PlayBgMusic(musicName)
            elseif eventType == TimeLineType_Shake then
                if not FF_G.IsServer then
                    local continueTime, strength = event[3], event[4]
                    root:ShakeScreen(continueTime, strength)
                end
            elseif eventType == TimeLineType_HaiwanglaixiTips then
                if not FF_G.IsServer then
                    local fishType, ratio = event[3], event[4]
                    if fishType == FF_G.Haiwanglaixi_FishType_Wakeup then
                        local ret, action = root:ShowEffect("actions/effect/fish_juexing/fish_juexing.actions", "show",
                                "", FF_G.kNodeIndex_Ui, 0, 0, false)
                        assert(ret)
                        action:SetLoop(1)
                    else
                        FF_PRAMS = {
                            fishType = fishType,
                            ratio = ratio,
                        }
                        root:ShowEffect("actions/effect/bosswarning/haiwanglaixi/boss_haiwanlaixi.actions", "show",
                                "action/haiwanglaixi.lua", FF_G.kNodeIndex_Ui, 0, 0, false)
                    end
                end
            elseif eventType == TimeLineType_BossWarning then
                if not FF_G.IsServer then
                    local warningType, fishTypeId, ratio = event[3], event[4]
                    if warningType == FF_G.BossWarning_Red then
                        local ret, action = root:ShowEffect("actions/effect/bosswarning/red/fish_color_zise.actions", "show",
                                "action/boss_warning.lua", FF_G.kNodeIndex_Ui, 0, 0, false)
                        assert(ret)
                        action:GetAnim():SetScale(FF_G_Client.GetScreenScaleX(), 1)
                    elseif warningType == FF_G.BossWarning_Purple then
                        local ret, action = root:ShowEffect("actions/effect/bosswarning/purple/fish_color_zise.actions", "show",
                                "action/boss_warning.lua", FF_G.kNodeIndex_Ui, 0, 0, false)
                        assert(ret)
                        action:GetAnim():SetScale(FF_G_Client.GetScreenScaleX(), 1)
                    elseif warningType == FF_G.BossWarning_BossCome then
                        FF_PRAMS = {
                            fishTypeId = fishTypeId,
                            ratio = ratio,
                        }
                        local ret, action = root:ShowEffect("actions/effect/bosswarning/bosscome/fish_cat_bosscome.actions", "show",
                                "action/boss_come.lua", FF_G.kNodeIndex_Ui, 0, 0, false)
                        assert(ret)
                        action:GetAnim():SetScale(FF_G_Client.GetScreenScaleX(), 1)
                    elseif warningType == FF_G.BossWarning_BisonComing then
                        FF_PRAMS = {
                            isRunAway = false,
                        }
                        local ret, _ = root:ShowEffect("ext/bosswarning/bisoncoming/Spine_BisonComing.actions", "BisonComing",
                                "action/bison_coming.lua", FF_G.kNodeIndex_Ui, 0, 0, false)
                        assert(ret)
                    end
                end
            end
        end
        if FF_G.IsServer or FF_G.IsStandalone then
            root:SetMonitorMode(true)
            local tp = root:CurrentTimePoint()
            for _, rule in ipairs(rules) do
                if rule.startTime <= time and rule.endTime >= time then
                    local checkRemovedCd = true
                    if rule.deathCd then
                        --local fishType = rule.bornEvent.fishTypes[1]
                        local fishTypeOrName = rule.groupName
                        local last = getLastFishDeathTime(fishTypeOrName)
                        if tp - last < rule.deathCd then
                            checkRemovedCd = false
                        end
                    end
                    if rule.leaveCd then
                        --local fishType = rule.bornEvent.fishTypes[1]
                        local fishTypeOrName = rule.groupName
                        local last = getLastFishLeaveTime(fishTypeOrName)
                        if tp - last < rule.leaveCd then
                            checkRemovedCd = false
                        end
                    end
                    if checkRemovedCd then
                        if rule.waitTime > 0.000001 then
                            rule.waitTime = rule.waitTime - 0.1
                        --end
                        --if rule.waitTime <= 0.000001 and GetFishCount(rule.groupName) < rule.limit then
                        elseif GetFishCount(rule.groupName) < rule.limit then
                            local shakeEventIndex = rule.shakeEventIndex
                            --print("shakeEventIndex:", shakeEventIndex)
                            local luaName = shakeEventIndex and "effect/shake.lua" or ""
                            local luaData = {
                                shakeEventIndex = shakeEventIndex,
                            }
                            local mutex, maskTypes = rule.mutex, {}
                            if mutex then
                                local types = rule.bornEvent.fishTypes
                                for _, type in ipairs(types) do
                                    if GetFishCount(type) > 0 then
                                        maskTypes[type] = true
                                    end
                                end
                            end
                            if #maskTypes < #rule.bornEvent.fishTypes then
                                --print("lua name:", luaName)
                                handleFishBornEvent(rule.bornEvent, 1.0, true,
                                        luaName, luaData, mutex, maskTypes)
                                if FF_G.IsStandalone then
                                    local shakes = rule.bornEvent.shakes
                                    if shakes then
                                        for _, shake in ipairs(shakes) do
                                            FF_G.AddTimerTask(shake.startTime, function()
                                                root:ShakeScreen(shake.continueTime, shake.strength)
                                            end)
                                        end
                                    end
                                end
                                rule.waitTime = rule.cdTime or 0
                            end
                        end
                    end
                end
            end
            root:SetMonitorMode(false)
        end
    end
    -- 将场景添加到游戏中
    scene.PushToGame = function(autoAddSwitchSceneEffect)
        if not inited then
            scene.AddSetPlayRatioEvent(totalSeconds - 2.5, 15)
            scene.AddSwitchSceneEvent(totalSeconds - 1)
            scene.AddClearFishEvent(totalSeconds - 0.5)
            scene.AddSetPlayRatioEvent(totalSeconds - 0.1, 1)
            local index = 0
            for _, event in ipairs(timeLine) do
                event[0] = index
                index = index + 1
            end
            table.sort(timeLine, function(event1, event2)
                if event1[1] == event2[1] then
                    return event1[0] < event2[0]
                end
                return event1[1] < event2[1]
            end)
            for _, event in ipairs(timeLine) do
                event[0] = nil
            end
            eventCount = #timeLine
            fishEventTimelines = gameTimeLines:GetTimeLines(currentSceneIndex)
            inited = true
        end
        local count = eventCount
        if not autoAddSwitchSceneEffect then
            count = count - 4
        end
        table.insert(FF_G.timeLines, {
            Enable = Enable,
            Disable = Disable,
            Update = Update,
            totalSeconds = totalSeconds,
            eventCount = count,
        })
        --print("timeLines len:", #timeLine)
    end
    return scene
end

FF_G.FishEventHelper = {
    CreateScene = CreateScene,
}
