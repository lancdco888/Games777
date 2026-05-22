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
    for i = 1, 2 do
        local btn = self.render:GetChild("btn"..i)
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
function FreePanel:enterfreeselect(freeiconcount)
    print("freeiconcount",freeiconcount)
    local freetext = self.render:GetChild("freecount")
    freetext.text = freeiconcount
    FToolSet.PlayFGUISound("ui://Game353/selectbegin" )
    self.game.slot:GetTransition("fadeout"):Play()
    -- self:RecoverData()
    self.selectId = nil
    self.isClick = false
    self.render.visible = true
    self:IsOpen_btn(false)
    self.render:GetTransition("selectstart"):Play( function ()
        self.game:ChangeBgm(MusicCfg.Free_SelectBg)
        self:IsOpen_btn(true)
        self:StartAutoClickTimer()
    end)
end
function FreePanel:onclick(index)
    print("点击freetype",index)
    if self.isClick then
        return
    end

    self.isClick = true
    self:StopAutoClickTimer()

    local sendmsg = {
        _msgName_ = "PB.Client_Slots.BuffaloFreeType",
        type = index
    }

    if RUNTIME_USE_H5_PROTO then
        sendmsg.index = index + 1
        sendmsg.type = nil
    end
    
    APIGateway.SendExactRequest(sendmsg, "PB.Slots_Client.BuffaloFreeTypeRet", function(ok, msg)
        if ok then
            print("收到服务器回包")
            dump(msg,"msg")
            FToolSet.PlayFGUISound(MusicCfg.Free_Select_click)
            self.render:GetTransition("onclick"..index):Play(function()
                self.game:EnterFreeGame(index)
                self.game.slot:GetTransition("fadein"):Play(function ()
                end)
                self.render:GetTransition("selectend"):Play(function()
                    self:freeselectover()
                    
                    self.selectId = nil
                end)
            end)
        end
    end)
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
    self:onclick(math.random(1,2))
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