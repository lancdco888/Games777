local Tips = Class("Tips")
function Tips:ctor(render,game)
    self.game = game
    self.render = render
    self.render.visible = false
    self.bigwinnumber = self.render:GetChild("count")
    self.stop_btn = self.render:GetChild("bigwin_btn")
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
    FToolSet.AddClickListener(self.stop_btn,handler(self, function ()
        print("点击事件*********")
        self:HideTips()
        self.game:OnClickStop()
    end))
    
end

--显示
function Tips:ShowTips(winNum,delayTime,multiply)
    self.stop_btn.visible = true
    self.bigwintype = 1
    if multiply >= 30 then
        self.bigwintype = 3
    elseif multiply >= 10 then
        self.bigwintype = 2
    end
    self.render.visible = true
    if winNum then
        self.winNum = winNum
        self.bigwinnumber.visible = true
        self.tweener = FairyGUI.GTween.ToDouble(0, self.winNum, delayTime)
        :OnUpdate(function(tweener)
            local text = FToolSet.NumToStr(tweener.value.d)
            self.bigwinnumber.text = FToolSet.FixedDecimalPlaces(text, 0)
        end)
        :OnComplete(function()
            self.bigwinnumber.text = FToolSet.NumToStr(self.winNum)
            self.tweener = nil
            self.stop_btn.visible = false
        end)
    end
    local typearr = {"big","super","mega"} 
    self.isplayshowanim = true
    --弹出动画
    self.render:GetTransition(typearr[self.bigwintype].."_scale"):Play(function ()
        self.render:GetTransition(typearr[self.bigwintype].."_keep"):Play()
    end)
    self.render:GetTransition("kuang_scale"):Play(function ()
        self.render:GetTransition("kuang_keep"):Play()
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
    self.bigwinnumber.text = FToolSet.NumToStr(self.winNum)
end

--隐藏
function Tips:HideTips()
    print("清理tips????????????",self.isplayshowanim)
    if not self.isplayshowanim then return end
    self:StopScrollMoney()
    self.isplayshowanim = false
    self.stop_btn.visible = false
    local typearr = {"big","super","mega"} 
    self.render:GetTransition(typearr[self.bigwintype].."_scale"):Stop()
    self.render:GetTransition(typearr[self.bigwintype].."_keep"):Stop()
    self.render:GetTransition("kuang_scale"):Stop()
    self.render:GetTransition("kuang_keep"):Stop()
    -- --快速停止消失动画,并且触发停止回调
    self.isplayhideanim = false
    StartOnceTimer(function ()
        self.render:GetTransition(typearr[ self.bigwintype].."_end"):Play()
        self.render:GetTransition("kuang_end"):Play(function ()
            self.render.visible = false
        end)
    end,0.5)
  
end

return Tips