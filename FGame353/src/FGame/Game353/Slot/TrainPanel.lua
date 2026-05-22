local TrainPanel = Class("TrainPanel")
local Utils = Import(".Utils")
local Tools = Import(".Tools")
local MusicCfg = Import(".MusicCfg")
function TrainPanel:ctor(render,game)
    self.render = render
    self.game = game
    self.render.visible = false
    --self.freecountpanel = self.render:GetChild("freecountpanel")
    self.trainlength = {}--火车车厢长度
    self.trainlengthnumber = {}--火车车厢上的分数
    self.trainbodyindex = 0 --创建第几节车厢
    self.movespeed = 4--火车移动速度
    self.body_suiji_index = 4
    self.createbodyindex = 0--创建火车车身次数
    self.colortype = {"red","green","blue","purple","golden"}
    self.disappeartrain = {}--消失的火车数组
    self.isheadtrain = true --是否是火车头
    for i = 1, 6 do
       self:CreateTrainbody(true)
    end
    self.overfunc = nil
    self.isshowlasttraindata = 0 --是否显示上轮火车数据
    self.trainindex = 0--第几轮火车
    self.isPlayBinwinAnim = false--是否播放巨奖动画
end


function TrainPanel:__delete()
    for key, value in pairs(self.disappeartrain) do
        value:RemoveFromParent(true)
    end
   self.render:RemoveFromParent(true)
end
function TrainPanel:SetSignData(isnormaltrain)
    for i = 1, 4 do
        self.render:GetChild("signshow"..i).visible = isnormaltrain
        self.render:GetChild("signgray"..i).visible = isnormaltrain
        self.render:GetChild("signnumber"..i).visible = false
    end
end

--显示上个火车的金币和图标
function TrainPanel:ShowLastTrainIconNumber()
    if self.isshowlasttraindata == 0 then return   end
    print("显示上个火车的金币和图标",self.isshowlasttraindata )
    for i = 1, self.isshowlasttraindata  do
        local trainType = self.game.TrainAnimCount[i].traintype
        local allwincoin =  self.game.TrainAnimCount[i].allwinCoin
        print("trainType,allwincoin",trainType,allwincoin)
        if trainType < 5 then
            self.render:GetChild("signgray"..trainType).visible = false
            self.render:GetChild("signnumber"..trainType).visible = true
            self.render:GetChild("signnumber"..trainType).text = Tools.TopupBounsScoreToStr(allwincoin)
        end
    end
end
function TrainPanel:EnterTrainAnim(trainType,numberdata,overfunc,recovertrain_index,trainindex)
    self.isPlayBinwinAnim = false
    self.trainindex = trainindex 
    self.overtraintype = trainType
    print("self.overtraintype ",self.overtraintype )
    self.overfunc = overfunc or function () end
    self.trainlengthnumber =  numberdata or {{value = 1000000},{value = 2000000},{value = 3000000}
,{value = 4000000},{value = 5000000},{value = 6000000},{value = 7000000},{value = 8000000},{value = 9000000}}
    local changetype = {4,3,2,1,5}
    trainType = changetype[trainType]
    self.trainType = trainType
    self.render.visible = true
    self.count = 1
    self.createbodyindex = 0
    self.trainbodyindex = 0
    self.allwincoin = 0
    self.isheadtrain = true
    self.render:GetChild("bg").url = "ui://Game353/"..self.colortype[trainType]
    local gradeborad = self.render:GetChild("gradeborad")
    self.render:GetChild("bottomicon").visible = false
    self.render:GetChild("goldbottomicon").visible = false
    self:SetSignData(false)
    if trainType<5 then
        gradeborad.url = "ui://Game353/0normal"
    else
        gradeborad.url = "ui://Game353/0golden"
    end
    local trainhead = self.render:GetChild("trainhead")
    trainhead:GetChild("head").url = "ui://Game353/3".. self.colortype[trainType]
    self.trainlength = {}
    table.insert(self.trainlength,trainhead)
    self.render:GetTransition("inint"):Play()
    local anim = self.render:GetChild("anim")
    anim.sortingOrder = 200
    if recovertrain_index and recovertrain_index > 0  then
        self.game:ChangeBgm("ui://Game353/TrainMusic")
        if trainType<5 then
            self:SetSignData(true)
            self:ShowLastTrainIconNumber()
            self.render:GetChild("bottomicon").visible = true
            self.render:GetChild("bottomicon").url = "ui://Game353/bottomicon"..trainType
        else
            self:SetSignData(false)
            self.render:GetChild("bottomicon").visible = false
            self.render:GetChild("goldbottomicon").visible = true
            self.render:GetChild("goldbottomicon"):GetChild("goldbottomwin").text = FToolSet.NumToStr(self.trainlengthnumber[1].value) 
        end
        self.render:GetTransition("trainanimstart"):Play()
        self:RecoverTrainMove(recovertrain_index)
        return
    end
    local enteranim = anim.component:GetChild("n"..trainType)
    FToolSet.PlayFGUISound("ui://Game353/TrainIntro")
    Utils.PlayWebm({render = enteranim,timer = 1,callback = function()
        self.game:ChangeBgm("ui://Game353/TrainMusic")
        if trainType<5 then
            self:SetSignData(true)
            self:ShowLastTrainIconNumber()
            self.render:GetChild("bottomicon").visible = true
            self.render:GetChild("bottomicon").url = "ui://Game353/bottomicon"..trainType
        else
            self:SetSignData(false)
            self.render:GetChild("bottomicon").visible = false
            self.render:GetChild("goldbottomicon").visible = true
            self.render:GetChild("goldbottomicon"):GetChild("goldbottomwin").text = FToolSet.NumToStr(self.trainlengthnumber[1].value) 
        end
        self.render:GetTransition("trainanimstart"):Play()
        local wheel = trainhead:GetChild("wheel")
        for i = 1, 5 do
            wheel.component:GetChild("n"..i).visible = false
        end
        local wheelanim = wheel.component:GetChild("n"..trainType)
        print("Huochezhuang轮",trainType)
        Utils.PlayWebm({render = wheelanim,timer = -1,callback = function()
        end})
        local smoke = trainhead:GetChild("n10")
        Utils.PlayWebm({render = smoke,timer = -1,callback = function()
        end})
        self:PlayRollingAnim()
    end})
end
--断线重连恢复火车移动状态
function TrainPanel:RecoverTrainMove(recovertrain_index)
    -- if columnindex % 1000 == 0 then
    --     self:EnterTrainAnim(trainType,numberdata,overfunc)
    -- elseif columnindex % 1000 == 1  then
    -- end
    if recovertrain_index == 1 then
        for i = 1, 2 do
            self:CreateTrainbody()
        end
        for key, value in pairs(self.trainlength) do
            value.x = value.x + 2000
        end
        
    else
        self.trainbodyindex = recovertrain_index - 2
        self.createbodyindex = self.trainbodyindex
        for i = 1, 3 do
            self:CreateTrainbody()
        end
        table.remove(self.trainlength,1)
        self.isheadtrain  = false
        for key, value in pairs(self.trainlength) do
            value.x = value.x + 2000 + 540
        end
    end
    if recovertrain_index == 1 then
        local number = self.trainlength[2]:GetChild("trainnumber")
        number.visible = false
    else
        for i = 1, 2 do
            local number = self.trainlength[i]:GetChild("trainnumber")
            number.visible = false
        end
    end
    for i = 1, recovertrain_index do
        self.allwincoin = self.allwincoin +  FToolSet.NumToStr(self.trainlengthnumber[self.count].value)
        self.count = self.count + 1
        local winallnumber = self.render:GetChild("winallnumber")
        winallnumber.visible = true
        winallnumber.text = self.allwincoin
    end
    self:PlayRollingAnim()
end
--免费结束面板
function TrainPanel:CreateTrainbody(isinit)
    local trainbody
    if #self.disappeartrain == 0 or isinit then
        print("正常创建车身~~~~~~~~~~~~~~")
        trainbody = FairyGUI.UIPackage.CreateObject("Game353", "trainbody")
    else
        print("消失车身列表中的————创建车身~~~~~~~~~~~~~~")
        trainbody = self.disappeartrain[#self.disappeartrain]
        table.remove(self.disappeartrain,#self.disappeartrain)
    end

    self.render:AddChild(trainbody)
    if  isinit then 
        table.insert(self.disappeartrain,trainbody)
        trainbody.xy = vec2(-1280,320)
        return  
    end
     --获取车身长度最后一节的位置，并创建一节车厢
    --如果第一次创建车身则获取车头位置
    local lastpos = self.trainlength[#self.trainlength].xy
    self.trainbodyindex = self.trainbodyindex + 1
    trainbody:SetPivot(0.5, 0.5, true)
    local traintypepos = {
        [4] = {posy = 155,scaley = 1.05},
        [5] = {posy = 155,scaley = 1.05},
        [6] = {posy = 132,scaley = 1.21},
        [7] = {posy = 161,scaley = 1.01},
        [8] = {posy = 161,scaley = 1.01},
        [9] = {posy = 141,scaley = 1.144},
    }
    --车厢类型随机
    self.body_suiji_index = self.body_suiji_index +math.random(1,2)
    if self.body_suiji_index > 9 then
        self.body_suiji_index = 4
    end
    local typedata = self.body_suiji_index
    trainbody.xy = vec2(lastpos.x-self.trainlength[#self.trainlength].width/2-trainbody.width/2+4,348)
    local bodytype = trainbody:GetChild("bodytype")
    local bodytype_ = trainbody:GetChild("bodytype_")
    bodytype.url = string.format("ui://Game353/%d%s",typedata,self.colortype[self.trainType])
    bodytype_.url = string.format("ui://Game353/%d_%s",typedata,self.colortype[self.trainType])
    bodytype.y = traintypepos[typedata].posy
    bodytype_.y = traintypepos[typedata].posy
    bodytype.scaleY = traintypepos[typedata].scaley
    bodytype_.scaleY = traintypepos[typedata].scaley
    --车厢number
    if self.trainlengthnumber[self.trainbodyindex].type == 1 then
        trainbody:GetChild("jujiangtype").visible = false
        trainbody:GetChild("trainnumber").visible = true
        trainbody:GetChild("trainnumber").text = FToolSet.NumToStr(self.trainlengthnumber[self.trainbodyindex].value)--火车车厢上的分数
    else
        --大小奖不显示金币显示大小奖类型图标
        local changetype = {4,3,2,1}
        local data = changetype[self.trainlengthnumber[self.trainbodyindex].type-10]
        trainbody:GetChild("jujiangtype").visible = true
        trainbody:GetChild("jujiangtype").url = "ui://Game353/flysign"..data
    end
    table.insert(self.trainlength,trainbody)
    self.createbodyindex = self.createbodyindex + 1
end
--循环滚动
function TrainPanel:PlayRollingAnim()
    self.moveTweener = FTween.Start(self.render,
        FTween.RepeatForever(
            {
                FTween.Delay(0.01,function ()
                    self:TrainMove()
                end)
            }
        )
    )
end
function TrainPanel:StopRollingAnim()
    if self.moveTweener then
        self.moveTweener.Kill()
        self.moveTweener = nil
    end
    self.isshowlasttraindata = 0 
    if self.isPlayBinwinAnim then return end
    local winanim = self.render:GetChild("winanim")
    FToolSet.PlayFGUISound("ui://Game353/BoxcarAward01")
    Utils.PlayWebm({render = winanim,timer = 0.5,callback = function()
        print("StopRollingAnimself.overtraintype ",self.overtraintype )
        if self.overtraintype < 5 then
            self.render:GetChild("signgray"..self.overtraintype).visible = false
            local anim = self.render:GetChild("signshow"..self.overtraintype)
            self.render:GetChild("signnumber"..self.overtraintype).visible = true
            self.render:GetChild("signnumber"..self.overtraintype ).text =  Tools.TopupBounsScoreToStr(self.game.TrainAnimCount[self.trainindex].allwinCoin)
            FToolSet.PlayFGUISound(string.format(MusicCfg.slots_353_Award,math.random(1,10)))
            Utils.PlayWebm({render = anim,timer = 1,callback = function()
                anim.visible = true
                StartOnceTimer(function ()
                    self.render.visible = false
                    self.overfunc()
                end,2)
            end})
        else
            self.render.visible = false
            self.overfunc()
        end
    end})

end
--免费结束面板
function TrainPanel:TrainMove()
    if #self.trainlength == 0 then
        self:StopRollingAnim()
        return
    end
    for key, value in pairs(self.trainlength) do
            value.x = value.x + self.movespeed
    end
    if self.trainlength[#self.trainlength].x > -self.render.width/2 
    and self.createbodyindex < #self.trainlengthnumber  then
        self:CreateTrainbody()
    end
    for i = #self.trainlength, 1, -1 do
        if  not self.coinflying and (self.trainlength[i].x > self.render.width/2-5 and self.trainlength[i].x < self.render.width/2 +20) then
            local number = self.trainlength[i]:GetChild("trainnumber")--dump
            if number then
                number.visible = false
                local isBigWinType = false
                local bigwinTye_,bigwinnumber = 0,0
                if self.trainlengthnumber[self.count].type-10 > 2 then
                    --火车中大巨奖
                    isBigWinType = true
                    self.isPlayBinwinAnim = true
                    bigwinTye_,bigwinnumber = self.trainlengthnumber[self.count].type-10,self.trainlengthnumber[self.count].value
                end
                if not isBigWinType then
                    self.trainlength[i]:GetChild("jujiangtype").visible = false
                    self.allwincoin = self.allwincoin +  FToolSet.NumToStr(self.trainlengthnumber[self.count].value)
                end
                if self.trainlengthnumber[self.count].type == 1 then
                    self.render:GetChild("flynumber").text =  FToolSet.NumToStr(self.trainlengthnumber[self.count].value)
                    self.render:GetChild("flynumber").sortingOrder = 100
                end
                local toserverData = self.game.PlaytrainanimCount * 1000 + self.count
                print("toserverData",self.trainindex,#self.game.TrainAnimCount,self.count,#self.game.TrainAnimCount[self.trainindex].traindata)
                if self.trainindex == #self.game.TrainAnimCount and self.count == #self.game.TrainAnimCount[self.trainindex].traindata then
                    toserverData = 9999
                end
                self:PushCoinInfo(toserverData)
                local flycoinanimstr = "flycoin"
                local jujingeffect = nil
                --大小奖类型飞金币动画更改
                if self.trainlengthnumber[self.count].type > 1 and not isBigWinType then
                    self.render:GetChild("flynumber").visible = false
                    flycoinanimstr = "flycointype"
                    local changetype = {4,3,2,1}
                    local data = changetype[self.trainlengthnumber[self.count].type-10]
                    self.render:GetChild("jujiangtype").visible = true
                    self.render:GetChild("jujiangtype").url = "ui://Game353/flysign"..data
                    self.render:GetChild("jujiangtype").sortingOrder = 100
                    local musicstr = {"TrainHit_Mini","TrainHit_Minor","TrainHit_Major","TrainHit_Grand",}
                    jujingeffect = musicstr[data]
                end
                self.count = self.count + 1
                self.coinflying = true
                if not isBigWinType then
                    self.trainlength[i]:GetTransition("t0"):Play()
                    FToolSet.PlayFGUISound("ui://Game353/BoxcarAwardFly01")
                    self.render:GetTransition(flycoinanimstr):Play(function ()
                        self.coinflying = false
                        if jujingeffect then
                            FToolSet.PlayFGUISound("ui://Game353/"..jujingeffect)
                        else
                            FToolSet.PlayFGUISound("ui://Game353/BoxcarAward01")
                        end
                        local winanim = self.render:GetChild("winanim")
                        local winallnumber = self.render:GetChild("winallnumber")
                        winallnumber.visible = true
                        winallnumber.text = self.allwincoin
                        Utils.PlayWebm({render = winanim,timer = 0.5,callback = function()
                        end})
                    end)
                else
                    print("bigwinTye_,bigwinnumber",bigwinTye_,bigwinnumber)
                    self:ShowBigwinAnim(bigwinTye_,bigwinnumber,function ()
                        self:StopRollingAnim()
                    end)
                end
            end
        end
    end
    for i = #self.trainlength, 1, -1 do
        if  self.trainlength[i].x > self.render.width+self.trainlength[i].width then
            if not self.isheadtrain then
                print("火车车身消失")
                table.insert(self.disappeartrain,self.trainlength[i])
            end
            table.remove(self.trainlength,i)
            self.isheadtrain  = false
            break
        end
    end
  
end
--发送点击数据
function TrainPanel:PushCoinInfo(index)
    print("发送点击数据",index)
    APIGateway.SendPush({
        _msgName_ = "PB.Client_Slots.CionInfo",
        cells = {index}
    })
end
--展示巨奖动画
function TrainPanel:ShowBigwinAnim(bigwinindex,bigwinnumber,callback)
    self.render.visible = true
    callback = callback or function () end
    --bigwinnumber = FToolSet.NumToStr(bigwinnumber)
    local visible_ = bigwinindex == 3 and true or false
    self.render:GetChild("bigwinbg").sortingOrder = 100
    self.render:GetChild("bigwinsign_").sortingOrder = 100
    self.render:GetChild("bigwinanim_").sortingOrder = 100
    self.render:GetChild("majoranim").sortingOrder = 100
    self.render:GetChild("grandanim").sortingOrder = 100

    self.render:GetChild("bigwinsign_").url = "ui://Game353/flysign"..(5-bigwinindex)
    self.render:GetChild("bigwinanim_").url = "ui://Game353/bigwinsign"..(5-bigwinindex)
    self.render:GetTransition("bigwinanim"):Play(function()
        self.coinflying = false
        local majoranim = self.render:GetChild("majoranim") 
        local grandanim =  self.render:GetChild("grandanim")
        majoranim.visible = visible_
        grandanim.visible = not visible_
        if visible_ then
            Utils.PlayWebm({render = majoranim,timer = -1,callback = function() end})
        else
            Utils.PlayWebm({render = grandanim,timer = -1,callback = function() end})
        end
        local second = self.game:ShowBottomWin(false,bigwinnumber)
        self.game:Coin_Roll_Function(function ()
            majoranim.visible = false
            grandanim.visible = false
            self.isPlayBinwinAnim = false
            FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
            callback()
        end,second)
    end)
end
return TrainPanel