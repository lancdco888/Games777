local FreePanel = Class("FreePanel")
local MusicCfg = Import(".MusicCfg")
function FreePanel:ctor(render,game)
    self.render = render
    self.game = game
    self.render.visible = false
    self.selectList = {}
    self.isclicking_index = {}
    self.selectId = nil
    self.greenshowlist = {}
    self.resultlist = {}
    self.graylist = {}
    self.resultindex = 1
    self.showanimlist = {}
    self.greenresult = {}
    self.resultendlist = {}
    self.wildcount = false
    self.played_list = {}
    self:Init()
end

function FreePanel:__delete()
    self:StopAutoClickTimer()
end
function FreePanel:Init()
    --获取按钮响应
    local btnpanel = self.render:GetChild("btniconPanel")
    for i = 1, 20 do
        local btn = btnpanel:GetChild("n"..173+i)
        FToolSet.AddClickListener(btn,handler(self, function ()
            self:onclick(i)
        end))
        table.insert(self.selectList,btn)
        --展示点击按钮动画
        local anim = self.render:GetChild("n"..153+i)
        table.insert(self.showanimlist,anim)
    end
    ---绿色小点表
    local countlist = {20,15,11,10,7,5}
    for i = 1,6 do
        self.greenresult[countlist[i]] =1
        self.greenshowlist[countlist[i]] = {}
        local begin =  (i-1)*3 + 173
        for j = 1, 3 do
            local point = self.render:GetChild("n"..begin+j)
            table.insert(self.greenshowlist[countlist[i]],point)
        end
    end
    for _, value in pairs(self.greenshowlist) do
        for _, show in pairs(value) do
            show.visible = false
        end
    end
    dump(self.greenresult)
end

function FreePanel:RecoverData()
    for _, value in pairs(self.greenshowlist) do
        for _, show in pairs(value) do
            show.visible = false
        end
    end
    for key, value in pairs(self.showanimlist) do
        value.visible = true
        value:GetTransition("initstate"):Play()
    end
    local countlist = {20,15,11,10,7,5}
    for i = 1,6 do
        self.greenresult[countlist[i]] =1
    end
    self.resultindex = 1
    self.isclicking_index = {}
    self.resultendlist = {}
    self.wildcount = false
    self.played_list = {}
end
function FreePanel:freeselectover()
    self.render.visible = false
end
function FreePanel:IsOpen_btn(visible)
    for key, value in pairs(self.selectList) do
        value.visible = visible
    end
end
function FreePanel:enterfreeselect(rlt,cells)
   -- FCasinoCtx.commonPanel.bottomPanel.render.visible = false
   FCasinoCtx.commonPanel:ShowBottom()

    -- FToolSet.PlayFGUISound("ui://Game479/selectbegin" )
    -- self.game.slot:GetTransition("changeselect"):Play()
    self:RecoverData()
    self.resultlist = rlt.openlist
    self.graylist = rlt.ohterlist
    self.freeAllCount = rlt.freeTime
    self.freemulyiplay = 2
    self.selectId = nil
    self.render.visible = true
    
    self.game:ChangeBgm("ui://Game479/sgbgm")
    if cells then
        self:IsOpen_btn(true)
        self:StartAutoClickTimer()
        self.render:GetTransition("selectrecover"):Play()
        for i = 1, #cells do
            self:onclick(cells[i],true)
        end
    else
        self:IsOpen_btn(false)
        self.render:GetTransition("selectstart"):Play( function ()
            for key, value in pairs(self.showanimlist) do
                value:GetTransition("init"):Play()
            end
            StartOnceTimer(function ()
                self:IsOpen_btn(true)
                self:StartAutoClickTimer()
            end,2)
        end)
    end
end
--选中发送选择包index
function FreePanel:onclick(index,isauto)
    if self.isclicking_index[index] or self.resultindex > #self.resultlist then return end
    self.isclicking_index[index] = index
    table.insert(self.resultendlist,index)
    print("select点击",index)
    FToolSet.PlayFGUISound("ui://Game479/mining" )
    --发送点击包数据
    table.insert(self.played_list,index)
    if not isauto then
        self:PushCoinInfo(index)
    end
   self:StopAutoClickTimer()
    --展示点击结果
    local clickcount = self.resultlist[self.resultindex]
    self.showanimlist[index].visible = true
    if clickcount == -1 then
        self.wildcount = true
        local countlist = {20,15,11,10,7,5}
        for i = 1,6 do
            self.greenshowlist[countlist[i]][self.greenresult[countlist[i]]].visible = true
            self.greenshowlist[countlist[i]][self.greenresult[countlist[i]]]:GetTransition("show"):Play()
            self.greenresult[countlist[i]] = self.greenresult[countlist[i]] + 1
        end
        self.showanimlist[index]:GetChild("showcount").url = "ui://Game479/text_alabo_freewild"
    else
        self.greenshowlist[clickcount][self.greenresult[clickcount]].visible = true
        self.greenshowlist[clickcount][self.greenresult[clickcount]]:GetTransition("show"):Play()
        self.greenresult[clickcount] = self.greenresult[clickcount] + 1
        self.showanimlist[index]:GetChild("showcount").url = "ui://Game479/text_alabo_free"..self.resultlist[self.resultindex]
    end
    self.showanimlist[index]:GetTransition("click"):Play()
    self.resultindex = self.resultindex + 1
    --同步右面绿色按钮
    if self.resultindex > #self.resultlist then
        
        self:IsOpen_btn(false)
        StartOnceTimer(function ()
            local grayindex = 1
            for i = 1, 20 do
                if not self.isclicking_index[i] then
                    --self.showanimlist[i].visible = true
                    print("self.graylist[grayindex]",self.graylist[grayindex])
                    if self.graylist[grayindex] == -1 then
                        self.showanimlist[i]:GetChild("showcount").url = "ui://Game479/text_alabo_freewild"
                    else
                        self.showanimlist[i]:GetChild("showcount").url = "ui://Game479/text_alabo_free"..self.graylist[grayindex]
                    end
                    self.showanimlist[i]:GetTransition("gray"):Play()
                    grayindex = grayindex + 1
                end
            end
            print("结果展示完成？？？？？？？？？？？？")
            --闪烁结果框具体次数
            local resultcount = 0
            local countlist = {20,15,11,10,7,5}
            for i = 1,6 do
                --点击累加到3个
                if self.greenresult[countlist[i]] == 4 then
                    resultcount = countlist[i] 
                    break
                end
            end
            for key, value in pairs(self.resultlist) do
                --if resultcount == value or value == -1 then
                    print("resultendlist[key]",self.resultendlist[key])
                    self.showanimlist[self.resultendlist[key]]:GetTransition("showresult"):Play()
                --end
            end
            FToolSet.PlayFGUISound("ui://Game479/opt_music_end" )
            self:SelectOver()
        end,2)
    else
        self:StartAutoClickTimer()
    end
end
--发送点击数据
function FreePanel:PushCoinInfo(index,auto)
    print("发送点击数据",index)
    APIGateway.SendPush({
        _msgName_ = "PB.Client_Slots.CionInfo",
        cells = self.played_list
    })
end
function FreePanel:SelectOver()
    StartOnceTimer(function ()
        FCasinoCtx.commonPanel:ShowBottom(true)
        self:freeselectover()
        self.game:EnterFreeGame(true)
        self.selectId = nil
    end,3)
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
    for i = 1, 20 do
        self:onclick(i)
    end
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
        self:enterfreeselect()
    end
end
--是否次数中有wild图标
function FreePanel:IsWildCount()
    return self.wildcount
end
return FreePanel