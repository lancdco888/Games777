local TurntableLayer = class("TurntableLayer", function()
    return Tools.CreateLayer("csb/lobby/TurntableLayer.csb")
end)
local sfc = cc.SpriteFrameCache:getInstance()
function TurntableLayer:onEnter()
    for i=1,16 do
        local name = string.format("hall/res/turntable/turntable_%d.png",i)
        local sp = cc.Sprite:create(name)
        sfc:addSpriteFrame(sp:getSpriteFrame(),name)
    end
	self:InitUI()
    Dispatcher:Register(UserData, function() self:Update() end, self)
end

function TurntableLayer:onExit()
    Dispatcher:Remove(self)
    for i=1,16 do
        local name = string.format("hall/res/turntable/turntable_%d.png",i)
        sfc:removeSpriteFrameByName(name)
    end
end

function TurntableLayer:SetCloseFunc(isClose,closefunc)
    if closefunc then
        local func = self.Close
        self.Close = function ()
            if func then
                func()
            end 
            closefunc()
        end
    end
end

function TurntableLayer:InitUI()
    self.datas = activity.logic:GetTurntableCfg()
    local msgbg = self:findChild("msgbg")
    msgbg:setVisible(false)
    self.msgbg_posx,self.msgbg_posy = msgbg:getPosition()
    msgbg:setPosition(cc.p(0, self.msgbg_posy))
    local bj = msgbg:findChild("bj")
    local jb = msgbg:findChild("jb")
    local isjb = UserData.activity_give_type == 1
    jb:setVisible(isjb)
    bj:setVisible(not isjb)
    
    self:InitTurntable(self.datas.spin_array)
    self:InitTitle()
end

function TurntableLayer:InitTitle()
    local need_bind = self:findChild("need_bind")
    self.title = need_bind:findChild("_lang_tips")
	local tutle_level = activity.logic:GetTurntableVipLevel()
    if tutle_level > 0 then
        local tips = TR("成为VIP%d后解锁")
        tips = string.format(tips, tutle_level)
        self.title:setString(tips)
    else
        self.title:setString(TR("成为VIP后解锁"))
    end
end

-- 	hall_dazhuanpan_dianji	大转盘点击中心闪光
-- 	hall_dazhuanpan_kuang	数值框特效
-- 	hall_dazhuanpan_money	金币收缩
-- 	hall_dazhuanpan_ok	    大转盘选中

-- 初始化转盘界面
function TurntableLayer:InitTurntable(spin_array)
    local turn_bg = self:findChild("turn_bg")
    self.turn_bg_posx,self.turn_bg_posy = turn_bg:getPosition()
    turn_bg:setPosition(cc.p(0,self.turn_bg_posy))

    local path = "hall/res/effect/turntable/"
    local strJosnname = "hall_dazhuanpan"
    local json_file1 = string.format("%s%s.%s",path,strJosnname,"json")
    local json_file2 = string.format("%s%s.%s",path,strJosnname,"atlas")
    local anim = sp.SkeletonAnimation:createWithJsonFile(json_file1,json_file2,1)
    turn_bg:addChild(anim)
    local content_size = turn_bg:getContentSize()
    anim:setPosition(cc.p(content_size.width/2,content_size.height/2))
    self.turn_bg_anim = anim

    -- 领取按钮
    local _lang_get = self:findChild("_lang_get")
    local anim1 = sp.SkeletonAnimation:createWithJsonFile(json_file1,json_file2,1)
    _lang_get:addChild(anim1)
    content_size = _lang_get:getContentSize()
    anim1:setPosition(cc.p(content_size.width/2,content_size.height/2))
    Tools.AddClickEvent(_lang_get, function()
        go(
            function ()
                anim1:setAnimation(0,"hall_dazhuanpan_money",false)
                _lang_get:setEnabled(false)
                _lang_get:setBright(false)
                local layer = PopLayer:Pop(activity.AwardPopLayer,2)
                layer:RunToSafeBoxNum(self.datas.spin_array[self.spin_index], false)
                if sGameManager.IsBindCodeOpen() then
                    UserData.money_gift_safe = UserData.money_gift_safe + self.datas.spin_array[self.spin_index]
                else
                    UserData.money_safe = UserData.money_safe + self.datas.spin_array[self.spin_index]
                end
                Dispatcher:Dispatch(UserData) 
                local msgbg = self:findChild("msgbg")
                msgbg:setVisible(false)
                local turn_bg = self:findChild("turn_bg")
                turn_bg:runAction(cc.MoveTo:create(0.5, cc.p(0,self.turn_bg_posy)))
                SleepSecs(0.7)
                self:Close()
            end
        )
    end, true)

    dump(sGameManager.exchangerate, " *** sGameManager.exchangerate *** ")
    dump(spin_array, " *** spin_array *** ")
    for i = 1, 16 do
        local num = self:findChild("n_"..i)
        local coins = spin_array[i]/sGameManager.exchangerate
        if coins > 10000 then
            coins = (coins/1000).."k"
        end 
        num:setString(coins)
    end
    local spin = self:findChild("spin")
    Tools.AddClickEvent(spin, function()
        go(
            function ()
                -- local datas = activity.logic:GetTurntableCfg()
                -- local vipLevel = datas.config.vip
                -- local myVipLevel = sGameManager.GetMyVipLevel()
                -- if myVipLevel < tonumber(vipLevel) then
                --     UIManager.ShowMsgBox(datas.config.detail,function ()
                --         cc.UserDefault:getInstance():setBoolForKey(tostring(UserData.id).."has_turn_spin",true)
                --         self:Close()
                --     end)
                --     return
                -- end
                spin:setEnabled(false)
                spin:setBright(false)
                self.turn_bg_anim:setAnimation(0,"hall_dazhuanpan_dianji",false)
                local index = activity.logic:ReqStartSpin()
                if index then
                    self.spin_index = index + 1
                    local turn = self:findChild("turn")
                    self:Whirling(turn,self.spin_index)
                end
            end
        )
    end, true)
    self:Update()
    local _lang_bind_btn = self:findChild("_lang_bind_btn")
    Tools.AddClickEvent(_lang_bind_btn,
        function()
            local layer = PopLayer:Pop(user.VipBenefitLayer)
            local tutle_level = activity.logic:GetTurntableVipLevel()
            if tutle_level >= 0 then
                layer:OnClickBtn(tutle_level)
            end
        end,
    true)

    local _lang_no_btn = self:findChild("_lang_no_btn")
    Tools.AddClickEvent(_lang_no_btn, function()
        go(
            function ()
                self:Close()
            end
        )
    end, true)
end

function TurntableLayer:Whirling(node,index)
    if not node or not index then
        return
    end
    local angle = self:Calculate_angle(node,index)
    local turns = 15
    node:runAction(
        cc.Sequence:create(
            cc.EaseSineInOut:create(cc.RotateBy:create(8,turns*360+angle)),
            cc.CallFunc:create(
                function ()
                    local translucent = self:findChild("translucent")
                    translucent:setVisible(true)
                    self.turn_bg_anim:setAnimation(0,"hall_dazhuanpan_ok",false)
                    local spin = self:findChild("spin")
                    spin:setLocalZOrder(10)
                end
            ),
            cc.DelayTime:create(2),
            cc.CallFunc:create(
                function ()
                    local jiangli = self:findChild("jiangli")
                    jiangli:setString(self.datas.spin_array[index]/sGameManager.exchangerate)
                    local msgbg = self:findChild("msgbg")
                    msgbg:setVisible(true)
                    msgbg:runAction(cc.MoveTo:create(0.5, cc.p(self.msgbg_posx,self.msgbg_posy)))
                    local turn_bg = self:findChild("turn_bg")
                    turn_bg:runAction(cc.MoveTo:create(0.5, cc.p(self.turn_bg_posx,self.turn_bg_posy)))
                end
            )
        )
    )
end

-- 旋转角度
function TurntableLayer:Calculate_angle(node,index)
    if not node or not index then
        return nil
    end
    local spin_array = self.datas.spin_array -- 金币表
    local angle_unit = 360/#spin_array -- 单位角度
    local target_angel 
    target_angel = (index-1)*angle_unit
    return target_angel
end

--播放动画帧
function TurntableLayer:CreateCoinAnimation(index)
    local sprite = cc.Sprite:create(string.format("hall/res/turntable/turntable_%d.png",index))
    local anim = cc.RepeatForever:create(
        cc.Sequence:create(
            cc.CallFunc:create(
                function ()
                    index = index + 1
                    if index>16 then
                        index = 1
                    end
                    sprite:setSpriteFrame(string.format("hall/res/turntable/turntable_%d.png",index))
                end
            ),
            cc.DelayTime:create(0.03)
        )
    )
    return sprite,anim
end


function TurntableLayer:Update()
    local need_bind = self:findChild("need_bind")
    local vip_level = sGameManager.GetMyVipLevel()
	local tutle_level = activity.logic:GetTurntableVipLevel()
    if vip_level < tutle_level then
        need_bind:setVisible(true)
    else
        need_bind:setVisible(false)
    end
end

return TurntableLayer
