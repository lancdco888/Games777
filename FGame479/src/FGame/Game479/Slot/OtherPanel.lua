local OtherPanel = Class("OtherPanel")
function OtherPanel:ctor(render,game)
    self.render = render
    self.game = game
    --self.render.visible = false
    self.freecountpanel = self.render:GetChild("freecountpanel")
    -- self.collectbtn = self.render:GetChild("entercaijinboard"):GetChild("collectbtn")
    -- self.entercaijinboard = self.render:GetChild("entercaijinboard")
    -- FToolSet.AddClickListener(self.collectbtn,handler(self, function ()
    --     print("collect按钮点击测试")
    --     self:CollectCallback()
    -- end))
    self.enterfreeboard = FairyGUI.UIPackage.CreateObject("Game479","enterfreeboard")
    FCasinoCtx.commonPanel.topEffectLayer:AddChild(self.enterfreeboard)
    self.enterfreeboard:SetPivot(0.5, 0.5, true)
    self.enterfreeboard.xy = vec2(GetFairyRoot().width/2, GetFairyRoot().height/2+40)
    self.enterfreeboard.visible = false
    self.enterstartbtn = self.enterfreeboard:GetChild("btn")
    FToolSet.AddClickListener(self.enterstartbtn,handler(self, function ()
        print("start按钮点击测试")
        self:StartCallback()
    end))
    -- FToolSet.AddClickListener(self.animendbtn,        handler(self, self.StopScrollWinMoney))
end


function OtherPanel:__delete()
   self.render:RemoveFromParent(true)
end

function OtherPanel:SetCount(count,allcount)
    if not count then
        self.freecountpanel.visible = false
        return
    end
   -- self.render.visible = true
    self.freecountpanel.visible = true
    local str = count.."x"..allcount
    print(str)
    self.freecountpanel:GetChild("free_count").text = count.."/"..allcount
end
function OtherPanel:Hide()
    --self.render.visible = false
end
--免费进入弹窗面板
function OtherPanel:CreateFreeEnterBoard(enterfreecount,beilv,overfunc)
    beilv = enterfreecount == 20 and 3 or 2
    overfunc = overfunc or function ()  end
    self.game:ChangeBgm()
    FToolSet.PlayFGUISound("ui://Game479/show_box" )
    self.enterfreeboard.visible = true
    self.enterfreeboard:GetChild("freespins").url = "ui://Game479/text_alabo_free"..enterfreecount
    self.enterfreeboard:GetChild("freecount").url = "ui://Game479/text_alabo_bonus"..enterfreecount
    self.enterfreeboard:GetChild("multiplier").url = "ui://Game479/text_alabo_bonus"..beilv
    self.enterstartbtn.visible = true
    self.rollanimcallback = overfunc
    self.rollanimcallbacktimer = StartOnceTimer(function ()
        self.rollanimcallbacktimer = nil
        if self.rollanimcallback then
            self.enterstartbtn.visible = false
            self.enterfreeboard.visible = false
            self.rollanimcallback()
            self.rollanimcallback = nil
        end
    end,5)
end
--免费结束面板
function OtherPanel:CreateEndWinBoard(endwin,overfunc)
    overfunc = overfunc or function ()  end
    self.game:ChangeBgm()
    FToolSet.PlayFGUISound("ui://Game479/fgend" )
    local enterboard = self.render:GetChild("fgroundsboard")
    enterboard.visible = true
    enterboard:GetChild("freeendwin").text = FToolSet.NumToStr(endwin)
    self.render:GetTransition("endwinboard"):Play()
    StartOnceTimer(function ()
        self.render:GetTransition("endwinboardexit"):Play()
        overfunc()
    end,4)
end
function OtherPanel:endwinboardexit()
    self.render:GetTransition("endwinboardexit"):Play()
end
--免费结束面板
function OtherPanel:CreateJpWinBoard(jpwin,overfunc)
    overfunc = overfunc or function ()  end
    self.game:ChangeBgm()
    FToolSet.PlayFGUISound("ui://Game479/jpwin" )
    FToolSet.PlayFGUISound("ui://Game479/VO_JPwin_EN" )

    local enterboard = self.render:GetChild("entercaijinboard")
    enterboard.visible = true
    enterboard:GetTransition("hidecollectbtn"):Play()
    self.collectbtn.visible = false
    enterboard:GetChild("caijinnumber").text = FToolSet.NumToStr(jpwin)
    self.render:GetTransition("enterjpboard"):Play()
    StartOnceTimer(function ()
        enterboard:GetTransition("showcollectbtn"):Play(function ()
            self.game:ChangeBgm("ui://Game479/jpcelebrate")
            self.collectbtn.visible = true
            self.entercaijinboard:GetTransition("playpenjinbi"):Play()
            self.rollanimcallback = overfunc
            self.rollanimcallbacktimer = StartOnceTimer(function ()
                self.rollanimcallbacktimer = nil
                if self.rollanimcallback then
                    self.collectbtn.visible = false
                    self.game:ChangeBgm()
                    self.entercaijinboard:GetTransition("stoppenjinbi"):Play()
                    self.render:GetTransition("enterjpboardexit"):Play(function ()
                        self.rollanimcallback()
                        self.rollanimcallback = nil
                    end)
                end
            end,23)
        end)
    end,2)
end
--collect按钮点击回调
function OtherPanel:CollectCallback()
    if self.rollanimcallbacktimer then
        StopTimer(self.rollanimcallbacktimer)
        self.rollanimcallbacktimer = nil
        if self.rollanimcallback then
            self.game:ChangeBgm()
            self.collectbtn.visible = false
            self.entercaijinboard:GetTransition("stoppenjinbi"):Play()
            self.render:GetTransition("enterjpboardexit"):Play(function ()
                self.rollanimcallback()
                self.rollanimcallback = nil
            end)
        end
    end
end
function OtherPanel:StartCallback()
    if self.rollanimcallbacktimer then
        StopTimer(self.rollanimcallbacktimer)
        self.rollanimcallbacktimer = nil
        if self.rollanimcallback then
            self.enterstartbtn.visible = false
            self.enterfreeboard.visible = false
            self.rollanimcallback()
            self.rollanimcallback = nil
        end
    end
end


return OtherPanel