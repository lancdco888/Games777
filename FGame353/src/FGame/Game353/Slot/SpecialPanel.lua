local SpecialPanel = Class("SpecialPanel")
local MusicCfg = Import(".MusicCfg")
function SpecialPanel:ctor(render,game)
    self.render = render
    self.game = game 
    self.render.visible = false
    --已点击的位置
    self.clickedIndexs = {}
    --结果数据
    self.overDate = {}
    --记录点击数量下标
    self.playedindex = 1
    --显示动画列表
    self.animList = {}
    --显示背景动画
    self.backanim = {{},{},{},{},{}}
    -- self.overPanel = self.render:GetChild("overPanel")
    -- if not self.overPanel then
    --     print("?????????????????")
    -- end
   -- self.overPanel.sortingOrder = 101
    self.endwintype = self.render:GetChild("endwintype")
    self.endwinnumber = self.render:GetChild("endwinnumber")
    self.winnumber = 0
    self.listenbtn = {}
    self.overcallback = nil
    self.played_list = {}
    self.Doublewin = false
    self.endwintypelist = {{},{},{},{}}
    self:Init()
end

function SpecialPanel:__delete()
    self:StopAutoClickTimer()
    if self.tweensnor then
        self.tweensnor.Kill()
        self.tweensnor = nil
    end
    self.render:RemoveFromParent(true)
    self.overcallback = nil
end
function SpecialPanel:Init()
    self.btnlist = {}
    self.played_list = {}
    local btnpanel = self.render:GetChild("btnpanel") 
    self.animList = {}
    local coinbtn = self.render:GetChild("coinbtn")
    self.grayList = {}
    local speicalgray = self.render:GetChild("speicalgray")
    for i = 1, 12 do
        local node = btnpanel:GetChild("n"..5+i)
        FToolSet.AddClickListener(node,function ()
            self:OnSelectMode(i)
        end)
        local anim = coinbtn:GetChild("n"..81+i)
        local gray = speicalgray:GetChild("n"..45+i)
        table.insert(self.btnlist,node)
        table.insert(self.animList,anim)
        table.insert(self.grayList,gray)
    end
    self.render.visible = true
    self.render:GetTransition("normalstay"):Play()
end
function SpecialPanel:HideList(list,isshow)
    isshow = isshow or false
    for key, value in pairs(list) do
        value.visible = isshow
    end
end
function SpecialPanel:EnterSpecial(winnumber,overDate,callback,cells)
    --FToolSet.PlayFGUISound("ui://Game353/202308151127(21)")
    self.game:ChangeBgm("ui://Game353/SND_BACKGROUND_THEME")
    self.winnumber = winnumber 
    self.overDate = overDate
    self.overcallback = callback or function () end
    self.render.visible = true
    self.playedindex = 1
    self.clickedIndexs = {}
    self.played_list = {}
    self.endwintypelist = {{},{},{},{}}
    self:HideList(self.grayList)
    self.render:GetChild("speicalgray").visible = false
    self:HideList(self.btnlist)
    self:HideList(self.animList,true)
    for key, value in pairs(self.animList) do
        value:GetTransition("coinstay"):Play()
    end
    local enterfunc = function ()
        self:HideList(self.btnlist,true)
        self.render:GetChild("btnpanel").visible = true
        self:StartAutoClickTimer()
        self.game.otherPanel:HideSpecialsign()
    end
    if cells then
        self.render:GetTransition("startspecial"):Play()
        enterfunc()
        for i = 1, #cells do
            self:OnSelectMode(cells[i],true)
        end
    else
        self.render:GetTransition("dooranim"):Play(enterfunc)
        StartOnceTimer(function ()
            self.render:GetTransition("startspecial"):Play()
        end,0.5)
    end
end
function SpecialPanel:OnSelectMode(index,isauto)
    print("点击响应",index)
    if self.clickedIndexs[index] then return end
    print("self.playedindex",self.playedindex,"#self.overDate",#self.overDate)
    if self.playedindex > #self.overDate then return end
    self.clickedIndexs[index]  = true
    --添加最后结果动画数据
    table.insert(self.endwintypelist[self.overDate[self.playedindex]],index)
    print("点击按钮",index)
    table.insert(self.played_list,index)
    if not isauto then
        local typeNum = self.overDate[self.playedindex] == 4  and 2 or 1
        FToolSet.PlayFGUISound(string.format("ui://Game353/SND_REVEAL_%d",typeNum))
        --FToolSet.PlayFGUISound(MusicCfg.jackpot_hit)
        self:PushCoinInfo(index)
    else
        FToolSet.PlayFGUISound("ui://Game353/SND_drumroll")
    end
    self:StopAutoClickTimer()
    local animtype = {"Mini","Minor","Major","Grand"}
    --展示动画
    self.animList[index]:GetTransition("Click"..animtype[self.overDate[self.playedindex]]):Play()
    self.animList[index].sortingOrder = 10
   
    if self.playedindex >= #self.overDate then
        local endtype = self.overDate[self.playedindex]
        self:StopAutoClickTimer()
        --点击完成剩余icon变灰
        self.render:GetChild("speicalgray").visible = true
        for i = 1, 12 do
            if not self.clickedIndexs[i] then
                self.animList[i].visible = false
                self.grayList[i].visible = true
                self.grayList[i]:GetTransition("changegray"):Play()
            end
        end
        self.game:ChangeBgm()
        FToolSet.PlayFGUISound("ui://Game353/SND_ST_End_Tag")
        StartOnceTimer(function ()
            for key, value in pairs(self.endwintypelist[endtype]) do
                --self.animList[value]:GetTransition("Click"..animtype[endtype]):Stop()
                self.animList[value]:GetTransition("win"..animtype[endtype]):Play()
            end
        end,1)
        StartOnceTimer(function ()
            local music_str = string.format("ui://Game353/SND_ST_%s_353",animtype[endtype])
      
            FToolSet.PlayFGUISound(music_str)
            print("music_str",music_str)
            self.render:GetChild("speicalgray").visible = false
            self.render:GetChild("coinbtn").visible = false
            self:HideList(self.btnlist)
            local caitype = {}
            self.endwintype.url = string.format("ui://Game353/winend(%d)_353",5-endtype)
            self.endwinnumber.text = FToolSet.NumToStr(self.winnumber)
            self.render:GetTransition("specialend"):Play(function ()
                self:PlayLoopWinnumber()
            end)
        end,4)
    else
        self:StartAutoClickTimer()
    end
    self.playedindex = self.playedindex + 1
end

--结束界面隐藏
function SpecialPanel:HidePanel()
    self.render.visible = false
    self.overPanel.visible = false
    self.render:GetTransition("t1"):Play( )
    self.render:GetChild("shadow").sortingOrder = 100
    self.render:GetChild("n50").visible = false
    for key, value in ipairs(self.animList) do
        value.visible = false
        value.sortingOrder = 1
    end
    self.overDate = {}
end
--发送点击数据
function SpecialPanel:PushCoinInfo(index,auto)
    print("发送点击数据",index)
    APIGateway.SendPush({
        _msgName_ = "PB.Client_Slots.CionInfo",
        cells = self.played_list
    })
end
function SpecialPanel:StartAutoClickTimer()
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

function SpecialPanel:AutoClick()
    local lenth = #self.overDate - self.playedindex
    local newindex = 1
    for i = 1,15 do
        self:OnSelectMode(i)
    end
    FToolSet.PlayFGUISound(MusicCfg.jackpot_hit)
end

function SpecialPanel:StopAutoClickTimer()
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
function SpecialPanel:PlayLoopWinnumber()
    self.render:GetTransition("startwinnumber"):Play()
    self.tweensnor =  FTween.Start(self.render,
    FTween.RepeatForever({
        FTween.Delay(1, function() 
            self.render:GetTransition("loopwinnumber"):Play()
        end),
    }))
    StartOnceTimer(function ()
        self.render:GetTransition("dooranim"):Play(self.overcallback)
        StartOnceTimer(function ()
            self:StopWinnumber()
            self.render:GetTransition("normalstay"):Play()
        end,0.5)
    end,5)
end
function SpecialPanel:StopWinnumber()
    self.render:GetTransition("loopwinnumber"):Stop()
    if self.tweensnor then
        self.tweensnor.Kill()
        self.tweensnor = nil
    end
end
return SpecialPanel