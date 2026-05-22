-- 免费游戏模式选择界面
local Enter_Free_Game = Class("Enter_Free_Game")
local MusicCfg       = Import(".MusicCfg")

function Enter_Free_Game:ctor(parent,pos)
    self.render = FairyGUI.UIPackage.CreateObject("Game375", "Enter_Free_Node")
    self.render.xy = pos
    parent:AddChild(self.render)
end

function Enter_Free_Game:__delete()
    self:StopAutoSelectTimer()

    self.render:RemoveFromParent(true)

    -- 析构函数置空回调函数
    self.onFishCallback = nil
end

function Enter_Free_Game:Show(callback)
    self.onFishCallback = callback
    --进入动画
    self.render:GetTransition("enter"):Play(1,0,function()
        self.render:GetTransition("loop"):Play(-1,0,function () end)
    end)
    self:TakeABreak(function()
        self.render.touchable = true
        FToolSet.AddClickListener(self.render,function()
            self.render:GetTransition("enter"):Stop()
            self.render:GetTransition("loop"):Stop()
            self:StopAutoSelectTimer()
            if self.onFishCallback then
                self.render.touchable = false
                self.onFishCallback()
                self.onFishCallback = nil
            end
        end)
    end,1)
    self:StartAutoSelectTimer()
end

--等待点击结算倒计时
function Enter_Free_Game:StartAutoSelectTimer()
    self:StopAutoSelectTimer()
    -- 延迟显示倒计时提示
    self.autoSelectTimer = StartOnceTimer(function()
        self.autoSelectTimer = nil
        self.render:GetTransition("enter"):Stop()
        self.render:GetTransition("loop"):Stop()
        --结束
        if self.onFishCallback then
            self.render.touchable = false
            self.onFishCallback()
            self.onFishCallback = nil
        end
    end, 10)
end

function Enter_Free_Game:StopAutoSelectTimer()
    if self.autoSelectTimer then
        StopTimer(self.autoSelectTimer)
        self.autoSelectTimer = nil
    end
end

--停2秒再继续
function Enter_Free_Game:TakeABreak(callback,time)
    self.TakeABreaktimer = StartOnceTimer(function ()
        self.TakeABreaktimer = nil
        callback()
    end,time or 2)
end

--清除所有倒计时
function Enter_Free_Game:CleanTimers()
    if self.TakeABreaktimer then
        StopTimer(self.TakeABreaktimer)
        self.TakeABreaktimer = nil
    end
end

return Enter_Free_Game