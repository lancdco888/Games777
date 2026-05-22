local SymbolCarAnim     = Class("SymbolCarAnim")
local CarTypeCfg        = Import(".CarTypeCfg")
local Tools             = Import(".Tools")
local MusicCfg          = Import(".MusicCfg")

function SymbolCarAnim:ctor(parent,cfg,slot)
    self.parent = parent
    self.slots = slot
    self.render = FairyGUI.GComponent()
    self.render.width = self.parent.width
    self.render.height = self.parent.height
    self.parent:AddChild(self.render)
    self.grids = {}                 --上一把的格子数据
    self.old_nodes_list = {}        --转换动画节点表
    self.new_nodes_list = {}        --转换后矿车和雷管节点表
    self.cfg = cfg                  --格子配置
    self._5or7xCellNumber = false   --5列true，7列false
    if self.cfg.xCellNumber == 5 then
        self._5or7xCellNumber = true
    end
    for i = 1, self.cfg.xCellNumber * self.cfg.yCellNumber do
        self.old_nodes_list[i] = {}
        self.new_nodes_list[i] = {}
    end
    --正在播放的矿车是在哪个节点
    self.playing_index = 0
    --当前矿车赢钱效果播放结束后的回调
    self.OnFinishCallbackOfCarPlay = nil
    --当前矿车总赢钱集合(不同赢钱值有不同效果)
    self.play_car_win_list = {}
end

function SymbolCarAnim:__delete()
    self:StopAutoSelectTimer()
    self.render:RemoveFromParent(true)
end

function SymbolCarAnim:SetOnFinishCallback(callback)
    self.OnFinishCallback = callback
end

--断线重连设置节点数据
function SymbolCarAnim:ReconnectAddNewBounsSymbol(grids)
    self:Clean()
    for i = 1, #grids do
        local cell = grids[i]
        --只有落地牌才会去创建
        if Tools.IsJpCard(cell.icon) then
            --转换前的表中没有节点才需要去创建
            if (not next(self.old_nodes_list[i])) and (not self.new_nodes_list[i].node) then
                --转换前的节点(固定创建1x1的雷管)
                self.old_nodes_list[i].node = self:CreateNode(cell,i,false,true)
                self.old_nodes_list[i].car_type = cell.SymbolType
                self.old_nodes_list[i].authenticity = true
                self.old_nodes_list[i].canchange = false
                self.old_nodes_list[i].node.visible = true
            end                                     
            --并隐藏转盘上的图案
            local render = self.slots:GetIndexOffSymbol(i)
            render.visible = false
        end
    end
    self.grids = grids
end

--每次旋转完，根据上一次数据为新增的落地牌创建节点(转换动画前的准备工作)
function SymbolCarAnim:AddNewBounsSymbol(grids)
    for i = 1, #grids do
        local cell = grids[i]
        --只有落地牌才会去创建
        if Tools.IsJpCard(cell.icon) then
            --并且是新增的或者旧数据类型和当前数据类型不一样
            if self.grids[i] == nil or cell.SymbolType ~= self.grids[i].SymbolType then
                --转换前的表中没有节点才需要去创建
                if (not next(self.old_nodes_list[i])) or (not self.old_nodes_list[i].node) then
                    --转换前的节点(固定创建1x1的雷管)
                    self.old_nodes_list[i].node = self:CreateNode(cell,i,true)
                    self.old_nodes_list[i].car_type = 15
                    self.old_nodes_list[i].authenticity = true
                    self.old_nodes_list[i].canchange = false
                end                                     
                self.old_nodes_list[i].node.visible = true
                --并隐藏转盘上的图案
                local render = self.slots:GetIndexOffSymbol(i)
                render.visible = false
            end
        end
    end
    for i = 1, #grids do
        local cell = grids[i]
        --只有落地牌才会去创建
        if Tools.IsJpCard(cell.icon) then
            --并且是新增的
            if self.grids[i] == nil then
                self:_CreateItem_Change(cell,i)
            else
                --旧数据类型和当前数据类型不一样
                if cell.SymbolType ~= self.grids[i].SymbolType then
                    --如果上次的数据不是落地牌,并且这次数据是1x1雷管新表不需要创建
                    self:_CreateItem_Change(cell,i)
                else
                    --旧数据类型和当前数据类型一样时，要通过判断起点和之前是否一样,不一样才创建
                    if cell.trainStart ~= self.grids[i].trainStart then
                        --如果上次的数据不是落地牌,并且这次数据是1x1雷管新表不需要创建
                        self:_CreateItem_Change(cell,i)
                    end
                end
            end
        end
    end
    self.grids = grids
end

--创建转换后节点
function SymbolCarAnim:_CreateItem_Change(cell,i)
    if self.grids[i] == nil or (not Tools.IsJpCard(self.grids[i].icon)) then
        if cell.SymbolType == 15 then
            self.new_nodes_list[i].cancreate = false
        end
    end
    --转换后的节点(转换后可能不在是1x1的雷管)
    if self.new_nodes_list[i].cancreate then
        self.new_nodes_list[i].node = self:CreateNode(cell,i)
        self.new_nodes_list[i].authenticity = true
        self.new_nodes_list[i].car_type = cell.SymbolType
    end
end

--进行转换
function SymbolCarAnim:RunChangeNode()
    local need_wait = false
    --先看看有没有雷管节点，雷管节点有转变退出动画，要先做
    for k, v in pairs(self.old_nodes_list) do
        if next(v) then
            if v.canchange and v.car_type >= 13 and v.authenticity then
                v.canchange = false
                need_wait = true
                v.node:GetTransition("change"):Play(1,0,function()
                    v.node:RemoveFromParent(true)
                    v.node = nil
                end)
            end
        end
    end
    local fun_ = function ()
        --如果是矿车节点，并且是主点，就直接删除节点
        for k, v in pairs(self.old_nodes_list) do
            if next(v) then
                if v.canchange and v.car_type <= 12 and v.authenticity then
                    v.canchange = false
                    v.node:RemoveFromParent(true)
                    v.node = nil
                end
            end
        end
        --进行转变动画
        for k, v in pairs(self.new_nodes_list) do
            if v.authenticity then
                v.node.visible = true
                if v.car_type <= 14 then
                    v.node:GetTransition("come"):Play(1,0,function ()
                        if v.car_type >= 13 then
                            local node_ = v.node:GetChild("n1")
                            node_.playing = true
                            node_.frame = 0
                            node_.animationName = CarTypeCfg[v.car_type].anim_name
                            node_.loop = true
                        end
                    end)
                else
                    local node_ = v.node:GetChild("n1")
                    node_.playing = true
                    node_.frame = 0
                    node_.animationName = CarTypeCfg[v.car_type].anim_name
                    node_.loop = true
                end
            end
        end
        --将新表赋值给旧表,并清空新表
        for k, v in pairs(self.new_nodes_list) do
            if v.node then
                self.old_nodes_list[k] = v
            end
            self.new_nodes_list[k] = {}
        end
    end
    if need_wait then
        FToolSet.PlayFGUISound(MusicCfg.fx_dynamite_transform)
        self:TakeABreak(function ()
            fun_()
            self:TakeABreak(function ()
                self.OnFinishCallback()
                self.OnFinishCallback = nil
            end,1)
        end,0.5)
    else
        --清空新表
        for k, v in pairs(self.new_nodes_list) do
            self.new_nodes_list[k] = {}
        end
        self.OnFinishCallback()
        self.OnFinishCallback = nil
    end
end

--结算(雷管爆炸动画)
function SymbolCarAnim:RunOverBoomAnim()
    local bool = false
    for k, v in pairs(self.old_nodes_list) do
        if next(v) then
            if v.car_type >= 13 and v.authenticity then
                if not bool then
                    bool = true
                    FToolSet.PlayFGUISound(MusicCfg.explosion_2_0_seconds)
                end
                v.node:GetTransition("boom"):Play()
            end
        end
    end
end

--指定矿车结算显示状态
function SymbolCarAnim:RunOverOfCarAnim(datas,callback)
    local index = datas[1].trainStart
    if (not self.old_nodes_list[index]) or (not self.old_nodes_list[index].node) then
        callback()
        return
    end
    --前半部分正常火车数据
    self.play_car_win_list = datas[1]
    --根据是否有额外数据判断，是否要额外播放一轮彩金矿车
    self.play_caijin_car_list = datas[2]
    --根据彩金数据设置奖励层锁定
    self.slots.game:SetCanNotClearLock(self.play_caijin_car_list ~= nil)
    self.playing_index = index
    self.show_text = 0
    self.OnFinishCallbackOfCarPlay = callback
    --切换矿车为等待点击状态，并设置点击事件
    local node = self.old_nodes_list[index].node
    local up_number = node:GetChild("up_to_number")
    up_number.visible = false
    local tips_txt = node:GetChild("tips_txt")
    tips_txt.visible = true
    self.slots.game:SetTouchable_CarAinimation(true)
    self.slots.game:AddClickListener_CarAinimation(function ()
        self:StopAutoSelectTimer()
        self:ChangeCarToEnd()
    end)
    self:StartAutoSelectTimer()
end

--等待点击结算倒计时
function SymbolCarAnim:StartAutoSelectTimer()
    self:StopAutoSelectTimer()
    -- 延迟显示倒计时提示
    self.autoSelectTimer = StartOnceTimer(function()
        self.autoSelectTimer = nil
        self:ChangeCarToEnd()
    end, 5)
end

function SymbolCarAnim:StopAutoSelectTimer()
    if self.autoSelectTimer then
        StopTimer(self.autoSelectTimer)
        self.autoSelectTimer = nil
    end
end

--矿车结算完毕后清除数据
function SymbolCarAnim:ClaerCarToEndData()
    self.slots.game:DeleteFountainEffect2Node()
    self.particle_node_left = nil
    self.particle_node_right = nil
    self.playnode = nil
    self.car_number = 0
    self.show_text = 0
    self.play_car_win_list = nil
    self.play_caijin_car_list = nil
    self.playing_index = nil
end

--结算完毕后总结效果
function SymbolCarAnim:PlayCarNumberShowEffect(callback)
    local down_show_number = self.playnode:GetChild("down_show_number")
    down_show_number.visible = true
    local txtinfo = self.playnode:GetChild("n14")
    txtinfo.visible = false
    local show_number = down_show_number:GetChild("show_number")
    show_number.text = self.car_number
    local particle_left = down_show_number:GetChild("particle3_node")
    particle_left.visible = true
    local particle_right = down_show_number:GetChild("particle4_node")
    particle_right.visible = true
    local str_ = "Game375/particle/375_carts_dd"
    local particle_1 = APIGateway.PlayParticleEffect(str_, particle_left)
    local particle_2 = APIGateway.PlayParticleEffect(str_, particle_right)
    self:TakeABreak(function ()
        APIGateway.StopParticleEffect(particle_1)
        APIGateway.StopParticleEffect(particle_2)
        if callback then
            callback()
        end
    end,2)
end

--矿车进入结算状态
function SymbolCarAnim:ChangeCarToEnd()
    self.car_number = 0
    local node = self.old_nodes_list[self.playing_index].node
    self.playnode = node
    local tips_txt = node:GetChild("tips_txt")
    tips_txt.visible = false
    self.slots.game:SetTouchable_CarAinimation(false)
    local playnode = node:GetChild("coin_fly_pos")
    --创建抛金币节点
    local width = playnode.width * node.scaleX
    local height = playnode.height * node.scaleY
    local pos = vec2(playnode.x - playnode.width/2 , playnode.y - playnode.height/2)
    local word_pos = node:LocalToRoot(pos)
    self.slots.game:CreateFountainEffect2Node(width,height,word_pos)
    --创建上方火车动画效果
    self.slots.game:InitNewCar(self.play_car_win_list.trainType,self.play_car_win_list.lineCells,
    function ()
        local fun_ = function ()
            self.slots.game:Caijin_StopWin()
            self:PlayCarNumberShowEffect(function ()
                self:ClaerCarToEndData()
                self.OnFinishCallbackOfCarPlay()
            end)
        end
        --根据是否有彩金数据决定是否在播放一轮彩金矿车动画
        if not self.play_caijin_car_list then
            print("=========没有彩金火车=======")
            fun_()
        else
            print("=========有彩金火车=======")
            local caijin_data = self.play_caijin_car_list.lineCells[1]
            self.slots.game:InitCaijinCar(self.play_caijin_car_list.trainType,caijin_data,fun_)
        end
    end,node,self)
    --根据矿车类型，设置彩金闪烁效果
    local lenth = CarTypeCfg[self.play_car_win_list.trainType].caijin_num
    for i = 0, lenth do
        self.slots.game:Caijin_PlayWin(i)
    end
end

--矿车结算效果
function SymbolCarAnim:PlayCarAddWinEffect(data)
    self.car_number = self.car_number + 1
    local particle_left = self.playnode:GetChild("particle1_node")
    particle_left.visible = true
    local particle_right = self.playnode:GetChild("particle2_node")
    particle_right.visible = true
    --根据金币数值决定播放哪种效果
    local str_ = "Game375/particle/375_jpsf_1"
    local exnumber = FCasinoCtx.commonPanel:GetBetMoney()
    if data.SymbolValue / exnumber > 30 then
        --白粒子，抛金币
        self.slots.game:PlayFountainEffect2Node(math.random(25,35))
    elseif data.SymbolValue / exnumber > 10 then
        --红粒子，抛金币
        str_ = "Game375/particle/375_jpsf_2"
        self.slots.game:PlayFountainEffect2Node(math.random(20,30))
    end
    self.particle_node_left = APIGateway.PlayParticleEffect(str_, particle_left)
    self.particle_node_right = APIGateway.PlayParticleEffect(str_, particle_right)
    self.show_text = self.show_text + data.SymbolValue
    local txt = self.playnode:GetChild("number")
    txt.visible = true
    txt.text = FToolSet.NumToStr(self.show_text)
end

--停止播放效果
function SymbolCarAnim:StopCarAddWinEffect()
    if self.playnode then
        APIGateway.StopParticleEffect(self.particle_node_left)
        APIGateway.StopParticleEffect(self.particle_node_right)
        self.slots.game:StopFountainEffect2Node()
    end
end

--停2秒再继续
function SymbolCarAnim:TakeABreak(callback,time)
    self.TakeABreaktimer = StartOnceTimer(function ()
        self.TakeABreaktimer = nil
        callback()
    end,time or 2)
end

-- @brief 获取转轴下标
-- @return [0,4]
function SymbolCarAnim:GetReelIndex(index)
    local reelCfg = self.cfg
    return (index - 1) % reelCfg.xCellNumber
end

-- @brief 获取Y轴格子下标
-- @return [0,2]
function SymbolCarAnim:GetCellIndex(index)
    local reelCfg = self.cfg
    return math.floor((index - 1) / reelCfg.xCellNumber)
end

--创建一个或是车厢或是雷管节点
function SymbolCarAnim:CreateNode(cell,index,isinit,isReconnect)
    local type_ = 15
    if not isinit then
        type_ = cell.SymbolType
    end
    local carCfg = CarTypeCfg[type_]
    local node = FairyGUI.UIPackage.CreateObject("Game375", carCfg.name)
    --根据格子列数确定是否缩放
    if self._5or7xCellNumber then
        node.scale = Tools.ScaleOfSymbolKC_3x5
    else
        node.scale = vec2(1,1.02)
    end
    self.render:AddChild(node)
    --位置通过获取trainStart位置的symbol的pos来确定
    local symbol = self.slots:GetIndexOffSymbol(index)
    local real_pos = vec2(symbol.x - symbol.width / 2, symbol.y - symbol.height / 2)
    local worldpos = self.slots.bottomContainer:RootToLocal(real_pos)
    local pos_ = self.render:LocalToRoot(worldpos)
    node.xy = pos_
    node.visible = false
    --因为矿车类型只有左上角才可以进入创建，所以需要将其他位置设为不可创建
    --又因为girds是从左到右，从上到下顺序，所以如果是矿车一定会先检测到左上角
    --这样就不需要做多余的检测，只需要设置不可创建就行了
    if not isinit then
        self:SetNodeForType(carCfg,index,node,type_,isReconnect)
    end
    return node
end

--根据传入位置和矿车或雷管的类型数据设置数据
function SymbolCarAnim:SetNodeForType(carCfg,index,node,type_,isReconnect)
    local real_x = self:GetReelIndex(index) + 1
    local real_y = self:GetCellIndex(index) + 1
    for x = real_x, real_x + carCfg.x_lenth - 1 do
        for y = real_y, real_y + carCfg.y_lenth - 1 do
            local xy = (y - 1) * self.cfg.xCellNumber + x
            --新表后续矩形范围不让创建,并将数据都填充为当前数据
            self.new_nodes_list[xy].cancreate = false
            self.new_nodes_list[xy].node = node
            self.new_nodes_list[xy].car_type = type_
            self.new_nodes_list[xy].authenticity = false
            --旧表后续矩形范围全部设为需要改变
            self.old_nodes_list[xy].canchange = true
            if isReconnect then
                self.old_nodes_list[xy].canchange = false
                self.old_nodes_list[xy].car_type = type_
                self.old_nodes_list[xy].node = node
            end
        end
    end
end

--清除所有倒计时
function SymbolCarAnim:CleanTimers()
    if self.TakeABreaktimer then
        StopTimer(self.TakeABreaktimer)
        self.TakeABreaktimer = nil
    end
end

--重置
function SymbolCarAnim:ResetState()
    for k, v in pairs(self.new_nodes_list) do
        v.node = nil
        v.cancreate = true 
    end
end

--清除(结束后调用)
function SymbolCarAnim:Clean()
    self:CleanTimers()
    for k, v in pairs(self.old_nodes_list) do
        if v.node and v.authenticity then
            v.node:RemoveFromParent(true)
            v.node = nil
        end
    end
    self.old_nodes_list = {}
    for k, v in pairs(self.new_nodes_list) do
        if v.node then
            v.node:RemoveFromParent(true)
            v.node = nil
        end
    end
    self.new_nodes_list = {}
    for i = 1, self.cfg.xCellNumber * self.cfg.yCellNumber do
        self.old_nodes_list[i] = {}
        self.new_nodes_list[i] = {}
    end
    self.grids = {}
    self.playing_index = 0
    self:ClaerCarToEndData()
    self.OnFinishCallbackOfCarPlay = nil
end

return SymbolCarAnim