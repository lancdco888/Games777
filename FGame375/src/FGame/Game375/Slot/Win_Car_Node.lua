local Win_Car_Node      = Class("Win_Car_Node")
local CachePool         = Import(".CachePool")
local CarTypeCfg        = Import(".CarTypeCfg")
local FountainEffect_2  = Import(".FountainEffect_2")
local MusicCfg          = Import(".MusicCfg")
function Win_Car_Node:ctor(render)
    self.render = render
    self.start_pos = self.render:GetChild("start_pos").xy
    self.end_pos = self.render:GetChild("end_pos").xy
    self.midpoint_pos = self.render:GetChild("midpoint_pos").xy
    self.car_list = CachePool.New(5,function (item)--检测是否能重置的方法
        return item.isover
    end,
    function (item)--重置方法
        item.ishead = false
        item.cancreate = false
        item.datainfo = nil
        item.SymbolType = 0
    end,
    function (item)--清理的方法
        item.node:RemoveFromParent(true)
        item.node = nil
    end)      --火车节点表
    self.protected = { node = true ,lz_Tween = true}  -- 保护node，不让其被重置或更新
    self.cars_type = ""     --当前火车类型
    self.added_number = 0   --已经添加的车厢个数
    self.cars_info_list = {}--车身节点所有信息
    self.caijintype_list = {
        [2] = "mini",
        [3] = "minor",
        [4] = "major",
        [5] = "grand",
    }
    --彩金车头
    self.caijin_head = self.render:GetChild("caijin_head")
    --彩金车身
    self.caijin_body = self.render:GetChild("caijin_body")
end

function Win_Car_Node:__delete()
    self:CleanTimers()
    self.car_list:Delete()
    if self.car_yanhua_prant then
        self.car_yanhua:Delete()
        self.car_yanhua = nil
        self.car_yanhua_prant:RemoveFromParent(true)
        self.car_yanhua_prant = nil
    end
    self.render:RemoveFromParent(true)
end

------------------------------------普通火车-----------------------------------
--初始化一辆火车list_info:火车所需要的所有信息都在里面(外层组装好需要的结构)
--list_info里节点数据结构
-- {
-- 	[Desc("点对应下标")]
-- 	int32 index = 1;
-- 	[Desc("点对应图形Id")]
-- 	int32 icon= 2;
-- 	[Desc("点对应图形Id的类型 0为常规图形 1~99  表示  jp的类型 如果在中奖线里面  1普通· 2345 大中小巨")]
-- 	int32 SymbolType = 3;
-- 	[Desc("图形的彩金值")]
-- 	int64 SymbolValue = 4;
-- }
--car_type:line数据里面的trainType
function Win_Car_Node:InitNewCar(car_type,list_info)
    self.cars_type = CarTypeCfg[car_type].car_type
    self.cars_info_list = list_info
    --车头
    self:CreateCarItem(true)
    --车厢
    self:CheckIsNeedAddCarriage(true)
end

--创建一个火车的节点
function Win_Car_Node:CreateCarItem(ishead,data)
    --车身需要在上一个车身或者车头后面
    local last_node = self.car_list:getPrevious()
    local final = self.car_list:put({},self.protected)
    if not final then
        return false
    end
    local node = self.car_list:getCurrent()
    --新建一个火车组件
    local ishave,node_1 = self.car_list:checkProtectedAtCurrentPosition("node")
    node.node = node_1
    if not ishave then
        node.node = FairyGUI.UIPackage.CreateObject("Game375", "Car_Item")
        self.render:AddChild(node.node)
    end
    --初始化轮子滚动效果
    local lz_have,lz_Tween = self.car_list:checkProtectedAtCurrentPosition("lz_Tween")
    node.lz_Tween = lz_Tween
    if not lz_have then
        node.lz_Tween = node.node:GetTransition("lunzi_run")
        node.lz_Tween:Play(-1,0,function()
        end)
    end
    --是否跑完
    node.isover = false
    node.ishave_node = true
    node.node:GetTransition("mutable_coins"):Stop()
    node.node:GetTransition("caijin_reseting"):Play()  
    if ishead then
        --车头无数据
        node.node:GetController("type").selectedPage = "head"
        node.node:GetController("car_type").selectedPage = self.cars_type
        node.node:GetTransition("car_body"):Stop()
        node.node:GetTransition("car_head"):Play()
        node.node.xy = self.start_pos
        node.ishead = true
    else
        self.added_number = self.added_number + 1
        --车身是有数据的
        node.ishead = false
        --是否可以创建飞翔金币
        node.cancreate = true
        node.SymbolType = data.SymbolType
        node.datainfo = data
        node.node:GetController("type").selectedPage = "body"
        --普通车身
        if data.SymbolType <= 1 then
            --车身金币字总节点显示
            local number_node =  node.node:GetChild("car_number")
            number_node.visible = true
            node.node:GetController("car_type").selectedPage = self.cars_type
            node.node:GetTransition("car_body"):Play(-1,0,function()
            end)
            --设置金额
            for i = 1, 8 do
                local txt = node.node:GetChild(i .. "_number")
                txt.text = FToolSet.NumToStr(data.SymbolValue)
            end
            --根据显示数值大小和车体类型决定显示的字体
            local exnumber = FCasinoCtx.commonPanel:GetBetMoney()
            local str_ = "small"
            if data.SymbolValue / exnumber > 30 then
                str_ = "big"
                node.node:GetTransition("mutable_coins"):Play(-1,0,function()
                end)
            elseif data.SymbolValue / exnumber > 10 then
                str_ = "middle"
            end
            node.node:GetController("number_type").selectedPage = str_
        else
            --彩金车身
            node.node:GetController("car_type").selectedPage = "caijin"
            node.node:GetController("caijin_type").selectedPage = self.caijintype_list[data.SymbolType]
            local caijin_node = node.node:GetChild(self.caijintype_list[data.SymbolType])
            --彩金字节点
            local txt = caijin_node:GetChild("number")
            txt.visible = true
            txt.text = FToolSet.NumToStr(data.SymbolValue)
        end
        node.node.xy = vec2(last_node.node.x - last_node.node.width,last_node.node.y)
    end
    return true
end

--检测是否需要新增车厢到运动列表,如果需要会新增：返回true需要，false不需要
function Win_Car_Node:CheckIsNeedAddCarriage(isfrist)
    -- 检查是否已添加足够数量的车厢，如果足够则不需要新增
    if self.added_number >= #self.cars_info_list then
        return false
    end
    if isfrist then
        -- 计算可以安全添加车厢的最大索引，以避免数组越界
        local maxIndex = #self.cars_info_list - self.added_number
        maxIndex = math.min(maxIndex, 5) -- 限制最多添加5节车厢
        -- 逐个尝试创建车厢项，如果创建失败则处理错误
        for i = 1, maxIndex do
            local carriage = self:CreateCarItem(false, self.cars_info_list[self.added_number + 1])
            if not carriage then
                break
            end
        end
    else
        self:CreateCarItem(false, self.cars_info_list[self.added_number + 1])
    end
    return true
end

--设置格子上的火车节点
function Win_Car_Node:SetSymbolNode(node)
    self.nowplayedsymbol = node
end

--设置格子上火车的父类
function Win_Car_Node:SetSymbolParent(symbol_parent)
    self.nowplayedsymbolParent = symbol_parent
end

--设置正常火车结束后是否能清理一些公用数据
function Win_Car_Node:SetCanNotClearLock(bool)
    self.cannotclearlock = bool
end

--上方矿车字体隐藏，并创建一个飞往下方矿车的字体
function Win_Car_Node:ChangeTxTShowAndCreateCoins(node,callback)
    --隐藏上方矿车字体
    node.node:GetTransition("hide_txt"):Play()
    --创建飞行用的字体，初始位置为上方矿车字体位置
    local pos = node.node:GetChild("1_number").xy
    pos = vec2(pos.x - node.node.width / 2,pos.y - node.node.height / 2)
    local start_pos = node.node:LocalToRoot(pos)
    --因为有普通矿车类型和彩金类型，两种字体位置不同
    if node.datainfo.SymbolType >= 2 then
        local pos1 = node.node:LocalToRoot(vec2(180,161))
        start_pos = vec2(pos1.x - node.node.width / 2,pos1.y - node.node.height / 2)
    end
    start_pos = self.render:RootToLocal(start_pos)
    start_pos = vec2(start_pos.x + self.render.x,start_pos.y + self.render.y)
    self.fly_txt_node = FairyGUI.UIPackage.CreateObject("Game375", "Fly_Coins")
    self.fly_txt_node.sortingOrder = 1000
    self.fly_txt_node.xy = start_pos
    self.render:AddChild(self.fly_txt_node)
    --设置飞行字体数值和样式
    for i = 1, 9 do
        local txt = self.fly_txt_node:GetChild(i .. "_number")
        txt.text = FToolSet.NumToStr(node.datainfo.SymbolValue)
    end
    --飞到目的地后的音效
    local normal_music_name = ""
    if node.datainfo.SymbolType <= 1 then
        self.fly_txt_node:GetController("car_type").selectedPage = self.cars_type
        --根据显示数值大小和车体类型决定显示的字体
        local exnumber = FCasinoCtx.commonPanel:GetBetMoney()
        local str_ = "small"
        if node.datainfo.SymbolValue / exnumber > 30 then
            normal_music_name = MusicCfg.eurekaChimeBig
            str_ = "big"
            self.fly_txt_node:GetTransition("mutable_coins"):Play(-1,0,function()
            end)
        elseif node.datainfo.SymbolValue / exnumber > 10 then
            normal_music_name = MusicCfg.eurekaChimeSmall
            str_ = "middle"
        else
            normal_music_name = MusicCfg.eurekaChimeSmallest
        end
        self.fly_txt_node:GetController("number_type").selectedPage = str_
    else
        normal_music_name = MusicCfg.eurekaChimeBig
        self.fly_txt_node:GetController("car_type").selectedPage = "caijin"
    end
    --根据下方矿车位置设置字体飞行轨迹、终点
    local end_pos = self.nowplayedsymbol:GetChild("number").xy
    local worldendpos = self.nowplayedsymbol:LocalToRoot(end_pos)
    local real_end_pos = self.render:RootToLocal(worldendpos)
    real_end_pos = vec2(real_end_pos.x + self.render.x,real_end_pos.y + self.render.y)
    FTween.Start(self.fly_txt_node,
        FTween.To(FairyGUI.TweenPropType.Position, start_pos,real_end_pos , 1),
        FTween.CallFunc(function ()
            --字体飞刀下方矿车终点后，抛金币和烟花特效
            self.fly_txt_node.visible = false
            self.nowplayedsymbolParent:PlayCarAddWinEffect(node.datainfo)
            if normal_music_name ~= "" then
                FToolSet.PlayFGUISound(normal_music_name)
            end
            if callback then
                callback()
            end
        end),
        FTween.Delay(1,function ()
            --停止抛金币和烟花特效
            self.nowplayedsymbolParent:StopCarAddWinEffect()
        end),
        FTween.RemoveSelf())
end

--------------------------抛金币效果节点------------------------------
-- 创建一个抛金币节点，供外部使用
function Win_Car_Node:CreateFountainEffect2Node(width,height,pos,game_node)
    local start_pos = self.render:RootToLocal(pos)
    start_pos = vec2(start_pos.x + self.render.x,start_pos.y + self.render.y)
    self.car_yanhua_prant = FairyGUI.GComponent()
    self.car_yanhua_prant.width = width
    self.car_yanhua_prant.height = height
    self.car_yanhua_prant.xy = start_pos
    self.car_yanhua_prant.scale = game_node.scale
    self.car_yanhua_prant.sortingOrder = 1001
    self.render:AddChild(self.car_yanhua_prant)
    self.car_yanhua = FountainEffect_2.New(self.car_yanhua_prant,0)
end

function Win_Car_Node:PlayFountainEffect2Node(number)
    if self.car_yanhua_prant then
        self.car_yanhua:Play(number)
    end
end

function Win_Car_Node:StopFountainEffect2Node()
    if self.car_yanhua_prant then
        self.car_yanhua:Stop()
    end
end

function Win_Car_Node:DeleteFountainEffect2Node()
    if self.car_yanhua_prant then
        self.car_yanhua:Delete()
        self.car_yanhua = nil
        self.car_yanhua_prant:RemoveFromParent(true)
        self.car_yanhua_prant = nil
    end
end
----------------------------------------------------------------------


--火车位置更新
function Win_Car_Node:UpdateCarPos()
    if not self.IsRun then
        return
    end
    --可以滚动
    for i = 1, self.car_list:getSize() do
        local node = self.car_list:get(i)
        if node then
            if node.ishave_node then
                if node.node.x < self.end_pos.x then
                    --未到终点的一直移动
                    node.node.x = node.node.x + 3
                else
                    --到终点了清除当前数据
                    node.isover = true
                end
                --火车移动过了中间点之后，火车车身数字隐藏并播放创建效果，创建飞翔向格子上火车的金币
                if node.node.x >= self.midpoint_pos.x and node.cancreate then
                    node.cancreate = false
                    self:ChangeTxTShowAndCreateCoins(node)
                end
            end
        end
    end
    --检测是否需要添加并添加车厢，不需要则检测是否已经全部停止
    if not self:CheckIsNeedAddCarriage() then
        local isover = true
        for i = 1, self.car_list:getSize() do
            local node = self.car_list:get(i)
            if node then
                if node.ishave_node then
                    if not node.isover then
                        isover = false
                    end
                end
            end
        end
        if isover then
            print("所有车厢已停止")
            self:SetCarRun(false)
            if self.MineCarLoop then
                APIGateway.StopSound(self.MineCarLoop)
                self.MineCarLoop = nil
            end
            --清理火车列表
            self.car_list:clear()
            self.added_number = 0
            if not self.cannotclearlock then
                self.cars_type = ""
                self.nowplayedsymbol = nil
                self.nowplayedsymbolParent = nil
            end
            self.cars_info_list = {}
            --后续操作，格子上的节点进行动画等
            if self.CarRunEndCallBack then
                self.CarRunEndCallBack()
                self.CarRunEndCallBack = nil
            end
        end
    end
end

--设置可以运行
function Win_Car_Node:SetCarRun(isrun)
    self.IsRun = isrun
    if self.IsRun then
        --鸣笛音效
        FToolSet.PlayFGUISound(MusicCfg.TrainWhistle)
        --铁轨音效
        self.MineCarLoop = FToolSet.PlayFGUISound(MusicCfg.MineCarLoop,true)
    end
end

--设置运行完毕之后的回调
function Win_Car_Node:SetCarRunEndCallBack(call)
    self.CarRunEndCallBack = call
end
-------------------------------------------------------------------------------

-------------------------------单独的彩金火车----------------------------------
function Win_Car_Node:InitCaijinCar(car_type,data,callback)
    print("================初始化彩金车头")
    --初始化彩金车头
    self.caijin_head:GetController("type").selectedPage = "head"
    self.caijin_head:GetController("car_type").selectedPage = CarTypeCfg[car_type].car_type
    self.caijin_head:GetTransition("car_head"):Play()
    self.caijin_head_lz_tween = self.caijin_head:GetTransition("lunzi_run")
    self.caijin_head_lz_tween:Play(-1,0,function()
    end)
    --初始化彩金车身
    self.caijin_body:GetController("type").selectedPage = "body"
    self.caijin_body:GetController("car_type").selectedPage = "caijin"
    self.caijin_body:GetController("caijin_type").selectedPage = self.caijintype_list[data.SymbolType]
    local caijin_node = self.caijin_body:GetChild(self.caijintype_list[data.SymbolType])
    caijin_node.visible = true
    self.caijin_body_lz_tween = self.caijin_body:GetTransition("lunzi_run")
    self.caijin_body_lz_tween:Play(-1,0,function()
    end)
    self.caijin_data = data
    local txt = caijin_node:GetChild("number")
    txt.text = FToolSet.NumToStr(data.SymbolValue)
    --添加粒子效果
    if not self.caijin_particle_node then
        self.caijin_particle_node = self.caijin_body:GetChild("particle_node")
        self.caijin_particle = APIGateway.PlayParticleEffect("Game375/particle/375_kcjl", self.caijin_particle_node)
        APIGateway.StopParticleEffect(self.caijin_particle)
    end
    self.caijin_particle_node.visible = false
    --彩金火车运行完毕的回调
    self.CaijinRunEndCallBack = callback
end

--彩金火车运行
function Win_Car_Node:RunCaijinCar()
    print("================彩金火车运行")
    --鸣笛音效
    FToolSet.PlayFGUISound(MusicCfg.TrainWhistle)
    --铁轨音效
    self.MineCarLoop = FToolSet.PlayFGUISound(MusicCfg.MineCarLoop,true)
    self.render:GetTransition("caijin_enter"):Play(1,0,function()
        APIGateway.StopSound(self.MineCarLoop)
        self.MineCarLoop = nil
        --中途停止后，轮子动画也停止，并且做额外的动画
        self.caijin_head_lz_tween.timeScale = 0
        self.caijin_body_lz_tween.timeScale = 0
        self.caijin_body:GetTransition("caijin_win_enter"):Play(1,0,function()
            self.caijin_particle_node.visible = true
            APIGateway.ReplayParticleEffect(self.caijin_particle)
            local audioData = MusicCfg.Caijin_Win[self.caijin_data.SymbolType]
            FToolSet.PlayFGUISound(audioData.url)
            self:TakeABreak(function ()
                self.caijin_body:GetTransition("caijin_win_show"):Play(1,0,function()
                    self.caijin_particle_node = false
                    --生成飞往格子车厢的金币字体,结束之后隐藏节点
                    local node = {}
                    node.node = self.caijin_body
                    node.datainfo = self.caijin_data
                    self:ChangeTxTShowAndCreateCoins(node,function ()
                        self:EndCaijinCar()
                    end)
                end)
            end,audioData.time - 1)
            
            
        end)
    end)
end

--彩金火车结束
function Win_Car_Node:EndCaijinCar()
    print("================彩金火车结束")
    self.MineCarLoop = FToolSet.PlayFGUISound(MusicCfg.MineCarLoop,true)
    self.caijin_head_lz_tween.timeScale = 1
    self.caijin_body_lz_tween.timeScale = 1
    local caijin_node = self.caijin_body:GetChild(self.caijintype_list[self.caijin_data.SymbolType])
    caijin_node.visible = false
    self.render:GetTransition("caijin_over"):Play(1,0,function()
        self.cannotclearlock = false
        self.caijin_data = nil
        self.cars_type = ""
        self.nowplayedsymbol = nil
        self.nowplayedsymbolParent = nil
        self.caijin_head_lz_tween:Stop()
        self.caijin_body_lz_tween:Stop()
        self.caijin_body:GetTransition("caijin_reseting"):Play()
        self.render:GetTransition("caijin_reset"):Play()
        --进入下一步,todo
        APIGateway.StopSound(self.MineCarLoop)
        self.MineCarLoop = nil
        self.CaijinRunEndCallBack()
        self.CaijinRunEndCallBack = nil
    end)
end

--停2秒再继续
function Win_Car_Node:TakeABreak(callback,time)
    self.TakeABreaktimer = StartOnceTimer(function ()
        self.TakeABreaktimer = nil
        callback()
    end,time or 2)
end

function Win_Car_Node:CleanTimers()
    if self.TakeABreaktimer then
        StopTimer(self.TakeABreaktimer)
        self.TakeABreaktimer = nil
    end
end
return Win_Car_Node