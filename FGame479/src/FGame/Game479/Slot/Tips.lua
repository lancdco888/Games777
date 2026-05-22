local Tips = Class("Tips")
function Tips:ctor(render)
    self.render = render
    self.render.visible = true
    self.msgs = {}
    self:InitUI()
end

function Tips:__delete()
    FTween.KillTweens(self.render)
    self.render = nil
    if self.tweener then
        self.tweener:Kill(false)
        self.tweener = nil
    end
end

function Tips:InitUI()
   for i = 1, 5 do
        local msg = self.render:GetChild("msg_"..i)
        msg.visible = false
        local num = nil
        if i > 2 then
            num = msg:GetChild("num")
        end
        local loader = msg:GetChild("image")
        table.insert(self.msgs,{msg = msg, num = num, loader = loader})
   end
end

--显示
function Tips:ShowTips(bigWinLevel,winNum,delayTime)
    if not bigWinLevel or bigWinLevel <= 1 then --这个游戏 没有1,0 level
        return
    end
    self:HideTips()
    local type,url = FConfig.Common:GetBigWinTipsData(bigWinLevel)
    self.type = type
    local tab = self.msgs[self.type]
    tab.msg.visible = true
    if winNum and tab.num then
        self.winNum = winNum
        --先获取结束值存在几位小数
        local digit = FToolSet.GetDecimalPlaces(FToolSet.NumToStr(self.winNum))
        self.tweener = FairyGUI.GTween.ToDouble(0, self.winNum, delayTime)
        :OnUpdate(function(tweener)
            local text = FToolSet.NumToStr(tweener.value.d)
            tab.num.text = FToolSet.FixedDecimalPlaces(text, digit)
        end)
        :OnComplete(function()
            tab.num.text = FToolSet.NumToStr(self.winNum)
            self.tweener = nil
        end)
    end
    tab.loader.url = url
    self.isplayshowanim = true
    --弹出动画
    tab.msg:GetTransition("show"):Play(function ()
        self.isplayshowanim = false
    end)
end

-- 停止转动播放和弹出效果，显示最大值
function Tips:StopScrollMoney()
    if not self.render then
        return
    end
    if self.tweener then
        self.tweener:Kill(true)
        self.tweener = nil
    end
    if self.type then
        local tab = self.msgs[self.type]
        --0,1,2没有数字
        if tab.num then
            tab.num.text = FToolSet.NumToStr(self.winNum)
        end
        --快速停止弹出动画
        if self.isplayshowanim then
            self.isplayshowanim = false
            self.msgs[self.type].msg:GetTransition("show"):Stop()
        end
    end
end

--隐藏
function Tips:HideTips()
    self:StopScrollMoney()
    -- --快速停止消失动画,并且触发停止回调
    if self.isplayhideanim then
        self.isplayhideanim = false
        self.msgs[self.type].msg:GetTransition("hide"):Stop(true,true)
    else
        if self.type then
           -- self.isplayhideanim = true
           -- self.msgs[self.type].msg:GetTransition("hide"):Play(function ()
               -- self.isplayhideanim = false
                FTween.KillTweens(self.render)
                self.msgs[self.type].msg.visible = false
                self.type = nil
            --end)
        end
    end
end

return Tips