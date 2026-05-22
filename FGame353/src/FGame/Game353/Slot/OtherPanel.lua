local OtherPanel = Class("OtherPanel")
function OtherPanel:ctor(render,game)
    self.render = render
    self.game = game
    --self.render.visible = false
    self.freecountpanel = self.render:GetChild("freecountpanel")
    self.GoldPanel = self.render:GetChild("GoldPanel")
    -- self.collectbtn = self.render:GetChild("entercaijinboard"):GetChild("collectbtn")
    -- self.entercaijinboard = self.render:GetChild("entercaijinboard")
    -- FToolSet.AddClickListener(self.collectbtn,handler(self, function ()
    --     print("collect按钮点击测试")
    --     self:CollectCallback()
    -- end))
end


function OtherPanel:__delete()
   self.render:RemoveFromParent(true)
end

function OtherPanel:SetCount(count,allcount)
    if not count or allcount == 1 then
        self.freecountpanel.visible = false
        return
    end
   -- self.render.visible = true
    self.freecountpanel.visible = true
    local str = count.."x"..allcount
    print(str)
    self.freecountpanel:GetChild("free_count").text = str
end
function OtherPanel:Hide()
    --self.render.visible = false
end
--免费进入弹窗面板
function OtherPanel:CreateFreeEnterBoard(enterfreecount,beilv,overfunc)
    overfunc = overfunc or function ()  end
    self.game:ChangeBgm()
    FToolSet.PlayFGUISound("ui://Game353/selectend" )
    local enterboard = self.render:GetChild("enterfreeboard")
    enterboard.visible = true
    enterboard:GetChild("enterfreecount").text = enterfreecount
    enterboard:GetChild("beilv").url = "ui://Game353/X"..beilv
    self.render:GetTransition("enterboard"):Play()
    StartOnceTimer(function ()
        self.render:GetTransition("enterboardexit"):Play(overfunc)
    end,3)
end
function OtherPanel:ExtraFreeBoard(enterfreecount,overfunc)
    overfunc = overfunc or function ()  end
    FToolSet.PlayFGUISound("ui://Game353/selectend" )
    local enterboard = self.render:GetChild("extrafreePanel")
    enterboard.visible = true
    enterboard:GetChild("extrascale"):GetChild("extrafreecount").url = "ui://Game353/freecount"..enterfreecount
    enterboard:GetTransition("t0"):Play(overfunc)
end
function OtherPanel:GoldTrainBoard(number,overfunc)
    overfunc = overfunc or function ()  end
    local GoldPanel = self.render:GetChild("GoldPanel")
    GoldPanel.visible = true
    GoldPanel:GetChild("goldcount").text = FToolSet.NumToStr(number)
    -- GoldPanel:GetTransition("t0"):Play(overfunc)
end
--免费结束面板
function OtherPanel:CreateEndWinBoard(endwin,overfunc)
    overfunc = overfunc or function ()  end
    self.game:ChangeBgm()
    FToolSet.PlayFGUISound("ui://Game353/SND_ST_End_Tag" )
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
    FToolSet.PlayFGUISound("ui://Game353/jpwin" )
    FToolSet.PlayFGUISound("ui://Game353/VO_JPwin_EN" )

    local enterboard = self.render:GetChild("entercaijinboard")
    enterboard.visible = true
    enterboard:GetTransition("hidecollectbtn"):Play()
    self.collectbtn.visible = false
    enterboard:GetChild("caijinnumber").text = FToolSet.NumToStr(jpwin)
    self.render:GetTransition("enterjpboard"):Play()
    StartOnceTimer(function ()
        enterboard:GetTransition("showcollectbtn"):Play(function ()
            self.game:ChangeBgm("ui://Game353/jpcelebrate")
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

return OtherPanel