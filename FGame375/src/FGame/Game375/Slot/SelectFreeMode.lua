-- 免费游戏模式选择界面
local SelectFreeMode = Class("SelectFreeMode")
local MusicCfg       = Import(".MusicCfg")
local BTN_COUNT = 2

SelectFreeMode.Type_List = {
    [1] = "special",
    [2] = "free",
}

function SelectFreeMode:ctor(parent,game)
    self.render = FairyGUI.UIPackage.CreateObject("Game375", "Selection_Node")
    parent:AddChild(self.render)
    self.render.visible = false
    self.render.sortingOrder = 11
    self.render.xy = game.render:GetChild("selection_pos").xy

    self:ChangeControllerState("wait")
    self.btns_datas = {}      --按钮表
    for i = 1, BTN_COUNT do
        local temp = {}
        temp.btn = self.render:GetChild("btn_" .. i)
        temp.btn:AddEventListener(FGUIEventKey.onClick, function()
            self:OnSelectMode(i)
        end)
        table.insert(self.btns_datas,temp)
    end
end

function SelectFreeMode:__delete()
    self:StopAutoSelectTimer()

    self.render:RemoveFromParent(true)

    -- 析构函数置空回调函数
    self.onSelectGetMsgCallback = nil
end

function SelectFreeMode:ChangeControllerState(str_)
    self.render:GetController("show_type").selectedPage = str_
end

--进入选择动画
function SelectFreeMode:EnterShow(isReconnect)
    self.render.visible = true
    if isReconnect then
        self:StartAutoSelectTimer()
        return
    end
    self.render:GetTransition("enter"):Play(1,0,function ()
        self:StartAutoSelectTimer()
    end)
end

--设置收到选择回包回调函数
function SelectFreeMode:SetSelectGetMsgCallback(cb)
    self.onSelectGetMsgCallback = cb
end

function SelectFreeMode:StartAutoSelectTimer()
    self:StopAutoSelectTimer()
    -- 延迟显示倒计时提示
    self.autoSelectTimer = StartOnceTimer(function()
        local totalTime = 10
        self.timer1 = StartTimer(function()
            -- 倒计时结束
            if totalTime < 0 then
                StopTimer(self.timer1)
                self.autoSelectTimer = nil
                self.timer1 = nil
                self:OnSelectMode(math.random(1, BTN_COUNT))
                return
            end

            local text_tip = self.render:GetChild("tips")
            text_tip.visible = true
            text_tip.text = FToolSet.FmtAutoSelectTip(totalTime)

            totalTime = totalTime - 1
        end, 1)
    end, 5)
end

function SelectFreeMode:StopAutoSelectTimer()
    if self.autoSelectTimer then
        StopTimer(self.autoSelectTimer)
        self.autoSelectTimer = nil
    end
    if self.timer1 then
        StopTimer(self.timer1)
        self.timer1 = nil
    end
    local text_tip = self.render:GetChild("tips")
    text_tip.visible = false
end

function SelectFreeMode:OnSelectMode(index)
    self:StopAutoSelectTimer()
    self.isplayover = false
    self.over_fun = nil

    for id, value in ipairs(self.btns_datas) do
        value.btn.touchable = false
        --播放选择完毕动画
        if index == id then
            value.btn:GetTransition("touch"):Play(1,0,function ()
                self.isplayover = true
                if self.over_fun then
                    self.over_fun()
                end
            end)
        end
    end
    --切换控制器
    self:ChangeControllerState(self.Type_List[index])
    --隐藏文字
    local title_ = self.render:GetChild("n17")
    title_.visible = false

    --回包
    local function final(ok, data)
        if ok then
            if self.isplayover then
                self.render:GetTransition("over"):Play(1,0,function()
                    self.onSelectGetMsgCallback(data.freetype.type)
                end)
            else
                self.over_fun = function ()
                    self.render:GetTransition("over"):Play(1,0,function()
                        self.onSelectGetMsgCallback(data.freetype.type)
                    end)
                end
            end
        end
    end

    local msg = {
        _msgName_ = "PB.Client_Slots.EurekaTrainFreeType",
        type = index
    }
    if RUNTIME_USE_H5_PROTO then
        msg.index = index
        msg.type = nil
    end
    APIGateway.SendExactRequest(msg, "PB.Slots_Client.EurekaTrainFreeTypeRet", final)
end

return SelectFreeMode