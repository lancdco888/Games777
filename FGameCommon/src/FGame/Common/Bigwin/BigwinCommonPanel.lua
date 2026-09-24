---@class BigwincommonPanel
local BigwincommonPanel = Class("BigwincommonPanel")
--BigWinPanelMain_GameId子游戏Bigwin动画完全不一样(内部动画名不一样 动画效果时长不一样)需要自行复制“BigWinPanelMain”到自己项目中进行修改
        --替换所有动效里的animtion
--animurl新动画加载路径（加载新动画游戏ID路径："ui://Game604/604an_win"）
--clickoverfunc点击快速结算Bigwin面板回调
--parent层级主节点
--加载例如：   
--             self.bigwinCommonPanel = BigwinCommonPanel.New()--加载公共动画
--              self.bigwinCommonPanel = BigwinCommonPanel.New(nil,"ui://Game604/604an_win")--老丁给的新Bigwin动画资源 动画名字一样时长一样传参数加载新路径
--             self.bigwinCommonPanel = BigwinCommonPanel.New("Game604","ui://Game604/604an_win")-老丁给的Bigwin资源完全不一样，就自行复制“BigWinPanelMain”
--                                                                                                  组件到自己项目中进行修改动画动效
function BigwincommonPanel:ctor(BigWinPanelMain_GameId,animurl,clickoverfunc,parent)
    self.clickoverfunc = clickoverfunc or function () 
        --Bigwin弹窗结束停止下方栏滚动数字 默认模拟点击stop按键效果
        self.bigwinpanel_to_onclickstop = true
        FCasinoCtx:GetGame():OnClickStop()
        self.bigwinpanel_to_onclickstop = nil
    end
    BigWinPanelMain_GameId = BigWinPanelMain_GameId or "Basics"
    animurl = animurl or "ui://Basics/an_win"
    if parent == nil then
        parent = FCasinoCtx.commonPanel:GetTopEffectLayer()
    end
    --横屏竖屏加载不同的组件文件名
    local BigWinPanelMain ,BigWinPanel= "BigWinPanelMain","BigWinPanel"
    --竖屏游戏
    if APIGateway.IsDeviceOrientationPortrai() then
        BigWinPanelMain ,BigWinPanel= "BigWinPanelMain_V","BigWinPanel_V"
    end
    --添加转换Bigwin类型缩放动作
    self.bigwinboardmain = FairyGUI.UIPackage.CreateObject(BigWinPanelMain_GameId, BigWinPanelMain)
    parent:AddChild(self.bigwinboardmain)
    self.bigwinboardmain:MakeFullScreen()
    self.bigwinboardmain:SetPivot(0.5, 0.5, true)
    self.bigwinboardmain.xy = vec2(GetFairyRoot().width*0.5,GetFairyRoot().height*0.5)
    self.bigwinboardmain.visible = false
    print("创建BigWinPanel")
    --------------------------------------------------------------------------------
    self.bigwinboard = self.bigwinboardmain:GetChild(BigWinPanel)
    self.bigwinboard.visible = false
    --点击回调函数
    self.bigwinboardbtn = self.bigwinboard:GetChild("btn")
    FToolSet.AddClickListener(self.bigwinboardbtn,handler(self, function ()
        if self.BigPanelShowingType and self.BigPanelShowingType > 0 then
            self:PlayBinwinAnim()
            self.clickoverfunc()
        end
    end))
    --加载动画
    self.bigwinboard:GetChild("biganim").url = animurl
    self.bigwinboard:GetChild("epiganim").url = animurl
    self.bigwinboard:GetChild("megaanim").url = animurl
    self.mutilpy = 0
    self.BigPanelShowingType = 0--当前播放的Bigwin类型
    self.Blvconfig = {--递增播放倍率
        15,30,50
    }
    --bigwin面板弹窗正常结束 调用默认oclickstop函数时 会停止自动旋转功能 增加判断字段
    self.bigwinpanel_to_onclickstop = nil
    --结束弹窗动画回调
    self.OutPanelCallBack = function ()  end
    --子游戏需要调整不同倍率SetBlvFunc()
    --子游戏需要调整数字滚动位置SetNumbernode(vec2(GetFairyRoot().width*0.5,GetFairyRoot().height*0.5+145))
    ---------------------------------是否连续播放bigwin---------------------------------------------
    self.isGO_onPlayBigwin = true --是否连续播放bigwin
    self.isGo_onGrade = 0 --连续播放Bigwin等级
    self.startrollnumber = 0 --滚动分数开始数字
    self.timerarr = {} --连续滚动时间分段
    self.numberArr = {}--连续滚动分数分段
end

function BigwincommonPanel:__delete()
    self:StopWinNumber()
end

--设置点击回调
function BigwincommonPanel:SetClickCallBack(fun_)
    self.clickoverfunc = fun_
end
--设置结束弹窗动画回调
function BigwincommonPanel:SetOutPanelCallBack(fun_)
    self.OutPanelCallBack = fun_
end
--number中奖金额 ，time弹出面板总时间
function BigwincommonPanel:CreateBigWinPanel(number,time)
    local multiply = string.format("%.5f", (number / FCasinoCtx.commonPanel:GetBetMoney()))
    local multiply_new = tonumber(multiply)
    self.mutilpy = multiply_new
    --播放什么类型巨奖动画
    if multiply_new < self.Blvconfig[1] then
        return
    end
    local type_ = 1
    if multiply_new >= self.Blvconfig[3] then
        type_ = 3
    elseif multiply_new >= self.Blvconfig[2] then
        type_ = 2
    end
    self.wincount = number
    self.startrollnumber = 0 --滚动分数开始数字
    --是否开启递增巨奖动画效果
    if self.isGO_onPlayBigwin then
        self.isGo_onGrade = 0 --连续播放Bigwin等级
        self.timerarr = {} --连续滚动时间分段
        self.numberArr = {}--连续滚动分数分段
        -- for i = 1, 3 do
        --     print("FCasinoCtx.commonPanel:GetBetMoney()*self.Blvconfig",FCasinoCtx.commonPanel:GetBetMoney()*self.Blvconfig[i])
        -- end
        -- print("multiply <= self.Blvconfig[2]",multiply_new , self.Blvconfig[2],number)
        if multiply_new <= self.Blvconfig[2] then
            self:PlayBinwinAnim(1,number,time)
        else
            local audioData = FConfig.Common:GetFaFaFaAudioData(number)
            time = time or audioData.time
            -- print("all_shijian ",time,multiply_new ,self.Blvconfig[3])
            self.timerarr = {} 
            self.numberArr = {FCasinoCtx.commonPanel:GetBetMoney()*self.Blvconfig[2]}--连续滚动分数分段
            --连续播放等级
            if multiply_new > self.Blvconfig[3] then
                self.isGo_onGrade = 3
                local temp =  math.floor((time) / 3)
                self.timerarr = {temp,temp,time-(temp*2)} 
                self.numberArr[2] = FCasinoCtx.commonPanel:GetBetMoney()*self.Blvconfig[3]
                self.numberArr[3] = number
            else
                self.isGo_onGrade = 2
                local temp =  math.floor((time) / 2)
                self.timerarr = {temp,time-temp} 
                self.numberArr[2] = number--连续滚动分数分段
            end
            self:PlayBinwinAnim(1,self.numberArr[1],self.timerarr[1])
        end
    else
        self:PlayBinwinAnim(type_,number,time)
    end
end
--巨奖动画bigwin    type_ Bigwin类型1、2、3，number中奖金额 ，time弹出面板总时间，overfunc回调函数
function BigwincommonPanel:PlayBinwinAnim(type_,number,time)
    -- print("播放巨奖动画",type_,number,time)
    self.bigwinboard.visible = true
    local bigwintype = {"big","mega","epig"}
    --传参数为空结束弹窗面板
    if not type_ and self.BigPanelShowingType > 0  then
        self:StopAllanim()
        if self.isGO_onPlayBigwin and self.isGo_onGrade > 0 then
            self.BigPanelShowingType =  self.isGo_onGrade
        end
        -- print("传参数为空结束弹窗面板",self.BigPanelShowingType , self.isGo_onGrade)
        self.bigwinboard:GetTransition(bigwintype[self.BigPanelShowingType].."animout_new"):Play(function ()
            self.bigwinboard:GetTransition("hidebtn"):Play()
            self.bigwinboard.visible = false
            self.bigwinboardmain.visible = false
            self.mutilpy = 0
            self.OutPanelCallBack()
        end)
        self.BigPanelShowingType = 0
        self:StopWinNumber()
        return
    elseif not type_ then
        -- self.bigwinboard.visible = false
        return
    end
    self:StopAllanim()
    self.bigwinboard.visible = true
    self.bigwinboardmain.visible = true
    self:RollingFunc(number,time)
    self.BigPanelShowingType = type_
    self.bigwinboard:GetTransition("showbtn"):Play()
    if self.isGO_onPlayBigwin and self.isGo_onGrade > 0 and type_ > 1  then
        self.bigwinboardmain:GetTransition("t0"):Play()
        self.bigwinboard:GetTransition(bigwintype[type_].."anim_go_on"):Play()
    else
        self.bigwinboard:GetTransition(bigwintype[type_].."anim_new"):Play()
    end
end
--停止所有Bigwin进入和退出动画
function BigwincommonPanel:StopAllanim()
    local bigwintype = {"big","mega","epig"}
    self.bigwinboard:GetTransition("hideanim"):Play()
    for i = 1, 3 do
        self.bigwinboard:GetTransition(bigwintype[i].."anim_new"):Stop()
        self.bigwinboard:GetTransition(bigwintype[i].."animout_new"):Stop()
        self.bigwinboard:GetTransition(bigwintype[i].."anim_go_on"):Stop()
    end
  
end
--数字滚分效果
function BigwincommonPanel:RollingFunc(endnumber,time)
    self:StopWinNumber()
    self.scrolltweener = FairyGUI.GTween.ToDouble(self.startrollnumber, endnumber,time)
    :OnUpdate(function(tweener)
        if FConfig.Common.GameScoreForceToInt then
            self.bigwinboard:GetChild("winnumber").text =  FToolSet.NumToStr(tweener.value.d)
        else
            self.bigwinboard:GetChild("winnumber").text =  FToolSet.FixedDecimalPlaces(FToolSet.NumToStr(tweener.value.d,false), 2)--FToolSet.NumToStr(tweener.value.d)
        end
    end)
    :OnComplete(function()  
        --播放递增动画，递增动画等级 ,播放类型动画小于最后等级，
        if self.isGO_onPlayBigwin and self.isGo_onGrade > 0 and self.BigPanelShowingType < self.isGo_onGrade
        and self.BigPanelShowingType ~= 0 then
            self.startrollnumber = self.numberArr[self.BigPanelShowingType]
            local grade = self.BigPanelShowingType + 1
            self:PlayBinwinAnim(grade,self.numberArr[grade],self.timerarr[grade]) 
        else
            self:StopWinNumber()
            self:PlayBinwinAnim()
            self.clickoverfunc()
        end
    end)
    :SetEase(FairyGUI.EaseType.SineIn)--增加递进滚分模式
end
--隐藏停止分数面板展示
function BigwincommonPanel:StopWinNumber()
    if self.scrolltweener   then
        --递增滚分是片段结束时不要显示最后分数不然会导致滚分过程中闪烁
        if self.isGO_onPlayBigwin and self.isGo_onGrade > 0 and self.BigPanelShowingType < self.isGo_onGrade
        and self.BigPanelShowingType ~= 0 then
            self.scrolltweener:Kill()
            self.scrolltweener = nil
            return
        end
        self.bigwinboard:GetChild("winnumber").text = FToolSet.NumToStr(self.wincount)
        self.scrolltweener:Kill()
        self.scrolltweener = nil
    end
end
--其他Bigwin动画数字节框节点需要调整
function BigwincommonPanel:SetNumbernode(pos)
    self.bigwinboard:GetChild("winnumber").xy = pos
end
function BigwincommonPanel:SetBlvFunc(blvarr)
    self.Blvconfig = blvarr
end
--Bigwin免费结束有2秒的结束动画残留 导致结算面板和其他弹窗面板重合 需要做延迟处理
function BigwincommonPanel:BigwinDelayFuc(func)
    if self.mutilpy and self.mutilpy >= self.Blvconfig[1] then
        StartOnceTimer(func,1.5)
    else
        func()
    end
end
return BigwincommonPanel