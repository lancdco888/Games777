-- 缓动系统
--
-- 用例1:
-- x向右移动100 => 等待2秒 => 回调函数 => 并行执行[从scale1缩放到scale2, x轴向右移动500] => x向左移动100 => 旋转360度
--local slot = self.render:GetChild("slot")
--local scale1 = {x =  slot.scaleX, y = slot.scaleY}
--local scale2 = {x =  scale1.x * 1.5, y =  scale1.y * 1.5}
--FTween.Start(slot,
--        FTween.To(FairyGUI.TweenPropType.X, slot.x, slot.x + 100, 2),
--        FTween.Delay(2, function() print(2) end),
--        FTween.CallFunc(function() print(22) end),
--        FTween.Parallel({
--            FTween.To(FairyGUI.TweenPropType.Scale, scale1, scale2, 2, function() print(11) end),
--            FTween.To(FairyGUI.TweenPropType.X, slot.x, slot.x + 500, 4, function() print(10) end),
--        }),
--        FTween.To(FairyGUI.TweenPropType.X, slot.x + 100, slot.x, 2),
--        FTween.To(FairyGUI.TweenPropType.Rotation, 0, 360, 4)
--)
--
-- 用例2: 
-- [x向右移动100, x向左移动100] 循环两次 => 回调函数 => 旋转360度 => 移动坐标从pos1到pos2
-- => 移动坐标从pos2到pos1 => 缩放从scale1到scale2 => 缩放从scale2到scale1 => 回调函数
-- => [y向上移动100, y向下移动100] 循环两次 => 回调函数 => 删除自己
--
--local slot = self.render:GetChild("slot")
--local pos1 = {x = slot.x, y = slot.y}
--local pos2 = {x = slot.x + 100, y = slot.y + 100}
--local scale1 = {x =  slot.scaleX, y = slot.scaleY}
--local scale2 = {x =  scale1.x * 1.5, y =  scale1.y * 1.5}
--local tween = FTween.Start(slot,
--        FTween.Repeat({
--            FTween.To(FairyGUI.TweenPropType.X, slot.x, slot.x + 100, 0.5),
--            FTween.To(FairyGUI.TweenPropType.X, slot.x + 100, slot.x, 0.5),
--        }, 2),
--        FTween.CallFunc(function() print("end 1") end),
--        FTween.To(FairyGUI.TweenPropType.Rotation, 0, 360, 4),
--        FTween.To(FairyGUI.TweenPropType.Position, pos1, pos2, 4),
--        FTween.To(FairyGUI.TweenPropType.Position, pos2, pos1, 4),
--        FTween.To(FairyGUI.TweenPropType.Scale, scale1, scale2, 4),
--        FTween.To(FairyGUI.TweenPropType.Scale, scale2, scale1, 4),
--        FTween.CallFunc(function() print("end 2") end),
--        FTween.Repeat({
--            FTween.To(FairyGUI.TweenPropType.Y, slot.y, slot.y - 100, 2),
--            FTween.To(FairyGUI.TweenPropType.Y, slot.y - 100, slot.y, 2),
--        }, 2),
--        FTween.CallFunc(function() print("end 3") end),
--        FTween.RemoveSelf()
--)
-- 停止缓动
--StartTimer(function()
--    -- 停止当前tween.
--    tween.Kill()
--
--    -- 停止 slot上所有Tweens
--    FTween.KillTweens(slot)
--end, 1.5)
--

FTween = FTween or {}

local TweenType = {
    To = 1,
    Delay = 2,
    Repeat = 3,
    Shake = 4,
}

local stoppingTarget = {}

function FTween._Run(target, tweens, times, isParallel, onComplete)
    isParallel = isParallel or false
    --print("isParallel:", isParallel)
    --local tweens = {...}
    local idx = 1
    local len = #tweens
    local currentTween = {}
    local subTasks = {}
    local hasKill = false
    local completeCount = 0
    
    local function loopEnd()
        --print("loop end:", times, type(onComplete))
        if times == 1 then
            --print("call onComplete:", type(onComplete))
            if onComplete then onComplete() end
            return true
        end
        idx = 1
        if times ~= -1 then times = times - 1 end
        return false
    end

    local function next()
        --print("next:", hasKill, idx, len)
        if APIGateway == nil or not APIGateway.InFSlot() then return end
        if target and stoppingTarget[target] then return end
        if hasKill then return end
        if idx > len then
            if loopEnd() then return end
        end
        local data = tweens[idx]
        local isSequence = data.type == TweenType.Repeat
        idx = idx + 1
        
        local function onTweenComplete(tween)
            if data.callback then data.callback(target) end
            if tween ~= nil then
                table.removevalue(currentTween, tween)
            end
            --print("onTweenComplete:", isParallel, completeCount, #currentTween)
            if isParallel then
                completeCount = completeCount + 1
                if #currentTween == 0 then
                    if not loopEnd() then
                        next()
                    end
                end
            else
                next()
            end
        end

        if isSequence then
            local subTask = nil
            subTask = FTween._Run(target, data.tweens, data.times, data.isParallel, function() 
                onTweenComplete()
                table.removevalue(subTasks, subTask)
            end)
            table.insert(subTasks, subTask)
        else
            local tween
            if data.type == TweenType.To then
                -- dump(data,"FairyGUI.GTween.To",10)
                tween = FairyGUI.GTween.To(data.startValue, data.endValue, data.duration)
                                :SetTarget(target, data.propType)
                if type(data.easeType) == "number" then
                    tween:SetEase(data.easeType)
                end
            elseif data.type == TweenType.Shake then
                tween = FairyGUI.GTween.Shake(data.startValue, data.amplitude, data.duration)
                                :SetTarget(target)
            elseif data.type == TweenType.Delay then
                tween = FairyGUI.GTween.DelayedCall(0)
                                :SetTarget(target)
                                :SetDuration(data.duration)
            end
            tween:OnComplete(function() onTweenComplete(tween) end)
            if data.onCreate then data.onCreate(tween) end
            --currentTween = tween
            table.insert(currentTween, tween)
        end
        
        -- 并行
        if isParallel and idx <= len then
            next()
        end
    end
    if len > 0 then next() end
    
    local Kill = function(complete)
        hasKill = true
        complete = complete or false
        -- print(string.format("kill tween: %d, %d.", #currentTween, #subTasks))
        for _, tween in ipairs(currentTween) do
            tween:Kill(complete)
        end
        for _, subTask in ipairs(subTasks) do
            subTask.Kill()
        end
        --if currentTween ~= nil then
        --    currentTween:Kill(complete)
        --end
    end
    return {
        Kill = Kill,
        Stop = Kill,
    }
end

function FTween.Start(target, ...)
    local tweens = {...}

    local sequence = {}
    local tasks = {}
    local taskIdx = 1

    local hasKill = false
    local currentTask
    
    local function runTask()
        --print("run task1:", hasKill, taskIdx, #tasks)
        if target and stoppingTarget[target] then return end
        if hasKill then return end
        if taskIdx > #tasks then return end
        local task = tasks[taskIdx]
        --print("run task:", taskIdx, task.isParallel)
        currentTask = FTween._Run(target, task.tweens, task.times, task.isParallel, runTask)
        taskIdx = taskIdx + 1
    end
    
    local function PushSequence()
        --print("push sequence:", #sequence)
        if #sequence > 0 then
            table.insert(tasks, {
                tweens = sequence,
                times = 1,
            })
            sequence = {}
        end
    end
    
    for _, tween in ipairs(tweens) do
        if tween.type == TweenType.Repeat then
            PushSequence()
            if #tween.tweens > 0 then
                table.insert(tasks, {
                    tweens = tween.tweens,
                    times = tween.times,
                    isParallel = tween.isParallel,
                })
            end
        else
            table.insert(sequence, tween)
        end
    end

    PushSequence()
    --print("#task size:", #tasks)
    runTask()
    
    local kill = function(complete)
        hasKill = true
        if currentTask ~= nil then
            currentTask.Kill(complete)
        end
    end
    return {
        Kill = kill,
        Stop = kill,
    }
end

function FTween.Run(...)
    return FTween.Start(...)
end

function FTween.Repeat(tweens, times, isParallel)
    times = times or 1
    isParallel = isParallel or false
    local ret
    ret = {
        type = TweenType.Repeat,
        isParallel = isParallel,
        times = times,
        tweens = tweens,
        stop = function()
            ret.times = 0
        end
    }
    return ret
end

function FTween.GetRepeat(...)
    return FTween.Repeat(...)
end

function FTween.RepeatForever(tweens)
    return FTween.Repeat(tweens, -1)
end

function FTween.Sequence(tweens)
    return FTween.Repeat(tweens, 1)
end

-- 并行执行
-- times 为可选参数,默认值为1.
function FTween.Parallel(tweens, times)
    return FTween.Repeat(tweens, times, true)
end

function FTween.To(propType, startValue, endValue, duration, callback, onCreate, easeType)
    return {
        type = TweenType.To,
        propType = propType,
        startValue = startValue,
        endValue = endValue,
        duration = duration,
        callback = callback,
        onCreate = onCreate,
        easeType = easeType,
    }
end

-- TODO maybe has bug.
function FTween.Shake(startValue, amplitude, duration, callback, onCreate)
    return {
        type = TweenType.Shake,
        startValue = startValue,
        amplitude = amplitude,
        duration = duration,
        callback = callback,
        onCreate = onCreate,
    }
end

function FTween.Delay(duration, callback, onCreate)
    return {
        type = TweenType.Delay,
        duration = duration,
        callback = callback,
        onCreate = onCreate,
    }
end

function FTween.CallFunc(callback)
    return FTween.Delay(0, callback)
end

function FTween.RemoveSelf()
    return FTween.CallFunc(function(target) 
        target:RemoveFromParent(true)
    end)
end

function FTween.KillTweens(target, propType, completed)
    if target == nil then return end
    
    propType = propType or FairyGUI.TweenPropType.None
    completed = completed or false

    stoppingTarget[target] = true
    FairyGUI.GTween.Kill(target, propType, completed)
    stoppingTarget[target] = nil
end

function FTween.StopTweens(target, propType, completed)
    FTween.KillTweens(target, propType, completed)
end 