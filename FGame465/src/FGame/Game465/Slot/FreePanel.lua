local FreePanel = Class("FreePanel")
function FreePanel:ctor(render,game)
    self.render = render
    self.game = game
    self.render.visible = false
    self.selectList = {}
    self.isclick = false
    self.selectId = nil
    self:Init()
end

function FreePanel:__delete()
    self:StopAutoClickTimer()
end
function FreePanel:Init()
    --获取按钮响应
    for i = 1, 5 do
        local btn = self.render:GetChild("selectbtn"..i)
        FToolSet.AddClickListener(btn,handler(self, function ()
            self:onclick(i)
        end))
        table.insert(self.selectList,btn)
    end
end
function FreePanel:freeselectover()
    self.render.visible = false
end
function FreePanel:IsOpen_btn(visible)
    for key, value in pairs(self.selectList) do
        value.visible = visible
    end
end
function FreePanel:enterfreeselect(recover)
    self.game:ChangeBgm("ui://Game465/selectbm")
    self.isclick = false
    self.render.visible = true
    if recover then
        self:IsOpen_btn(true)
        self.game.slot:GetTransition("freestay"):Play()
        self.render:GetTransition("recoverselect"):Play()
        self:StartAutoClickTimer()
    else
        self:IsOpen_btn(false)
        self.game.slot:GetTransition("fadeout"):Play()
        self.render:GetTransition("enterselect"):Play(function ()
            self:IsOpen_btn(true)
            self:StartAutoClickTimer()
        end)
    end
end
--选中发送选择包index
function FreePanel:onclick(index,isauto)
    if self.isclick then return end
    self.isclick = true
    self.selectId = index 
    self:StopAutoClickTimer()
    
    self.game:SendPackage(index)
    -- self:SelectOver()
end
function FreePanel:ShowSelectResult(index)
    FToolSet.PlayFGUISound("ui://Game465/fgend" )

    self.render:GetTransition("select"..index):Play()
    StartOnceTimer(function ()
        self.render:GetTransition("exitselect"..index):Play(function ()
            self:SelectOver()
        end)
    end,2)
end
function FreePanel:SelectOver()
        self:freeselectover()
        self.game:EnterFreeGame()
        self.selectId = nil
end
function FreePanel:StartAutoClickTimer()
    self:StopAutoClickTimer()
    -- 延迟显示倒计时提示
    self.timer1 = StartOnceTimer(function()
        local totalTime = 10
        self.timer2 = StartTimer(function()
            -- 倒计时结束
            if totalTime < 0 then
                StopTimer(self.timer2)
                self.timer1 = nil
                self.timer2 = nil
                self:AutoClick()
                return
            end

            local text_tip = self.render:GetChild("autoCountText")
            text_tip.visible = true
            text_tip.text = FToolSet.FmtAutoSelectTip(totalTime)

            totalTime = totalTime - 1
        end, 1)
    end, 5)
end

function FreePanel:AutoClick()
    self:onclick(math.random(1,5))
end

function FreePanel:StopAutoClickTimer()
    if self.timer1 then
        StopTimer(self.timer1)
        self.timer1 = nil
    end
    if self.timer2 then
        StopTimer(self.timer2)
        self.timer2 = nil
    end
    local text_tip = self.render:GetChild("autoCountText")
    text_tip.visible = false
end
--获取选择的类型
function FreePanel:GetSelectId()
    return self.selectId 
end
function FreePanel:RecoverSelectPanel()
    if self.selectId then
        self:enterfreeselect(true)
    end
end
return FreePanel