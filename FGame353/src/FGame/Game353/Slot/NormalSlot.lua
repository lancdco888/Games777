-- 老虎机普通游戏，三个格子一组转动
local Utils = Import(".Utils")
local Tools = Import(".Tools")
local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local BaseSlot = Import(".BaseSlot")

local MusicCfg = Import(".MusicCfg")

local NormalSlot = Class("NormalSlot", BaseSlot)
--自定义图形数据
local initicondata = {
    { 9, 7, 9,2},
    { 8, 6, 6 ,11},
    { 10, 9, 10 ,4},
    { 6, 1, 1 ,10}, -- {8,7,1},
    { 5, 4, 5 ,6}, --{2,7,5},
}
local freeicon,wildicon,jpicon = 13,12,14
function NormalSlot:ctor(parent, game)
    Reel.isspecial = false
    local x = 0
    for i = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
        --初始化自定义图形
        local data = {}
        for j = 1, FCasinoCtx.gameCfg.Reel.yCellNumber do
            table.insert(data, { icon = initicondata[i][j], type = 0, lottyValue = 0 })
        end
        local reel = Reel.New(self.bottomContainer, i, FCasinoCtx.gameCfg.Reel.yCellNumber)
        reel:InitSymbol(data)
        reel:SetMask(false)
        reel.reelContainer.x = x
        self.reels[i] = reel

        -- 单列格子宽度
        x = x + reel.cfg.reelWidth
        -- 每列间距
        x = x + reel.cfg.reelSpace
    end

    self.reelDatas = {}
    self.hasHideIcon = false
    self.hasBouns = {
        false,
        false,
        false,
        false,
        false,
    }
    self.topupBounsCount = 0
    --全列播放动画类型
    self.allwildanimtype = {}
    --第2列和第3列是否有免费图标 有则加速旋转
    self.addForueDelayTime = 0
    
    --得到大图展现数据
    self._freeGameBigIconWinData =  { {}, {}, {},  {}, {}, }
    self._freeGameIconType = 0
    self.blickanimlist = {}
    self.inserfrist = {}
end

function NormalSlot:__delete()
    self:StopShowLine()
end
function NormalSlot:OnReelMask()
    for i = 1, 5 do
        local arraySymbolDisplays = self.reels[i].arraySymbolDisplays
        local render_0 = arraySymbolDisplays[0].render
        -- 是否需要在落地牌中常驻
        render_0:GetChild("mask").visible = true
        local render_5 = arraySymbolDisplays[5].render
        -- 是否需要在落地牌中常驻
        render_5:GetChild("mask").visible = true
    end
     
       
    
end
function NormalSlot:InitIcondata(isispecial)
    local grids = {}
    for i = 1, FCasinoCtx.gameCfg.Reel.yCellNumber do
        --初始化自定义图形
        for j = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
            table.insert(grids, { icon = initicondata[j][i], backinfos = 0, index = (i-1)*5 + j })
        end
    end
    if isispecial then
        self:OnReelMask()
    end
    self:HandleCellDatas(grids)
    self:SetReelSymbolData(function() end, true)
end

-- @brief 滚动开始
function NormalSlot:SpinStart()
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        v:SpinForever()
    end
    -- 删除顶部图案
    self:RemoveTopSymbol()

    -- 隐藏中奖线
    self.reelDatas = {}
    self.hasHideIcon = false
    self.hasBouns = {
        false,
        false,
        false,
        false,
        false,
    }
    self.isEnterFree = false
    self.isEnterTopupBouns = false
    
    self:StopShowLine()
    Reel.iswildtype = 0
    Reel.columnfive = 0
end

-- @brief 设置图案数据
-- @param quickSet 快速设置，跳过动画
function NormalSlot:SetReelSymbolData(callback, quickSet, allwinCoin)
    self.onFinishCallback = callback

    -- 设置最终停止数据 跳过动画
    if quickSet then
        for k, v in pairs(self.reels) do
            v:SetOpen(self.isOpen)
            v:Stop(self.reelDatas[k])
        end
        --FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
        end
        if allwinCoin then
            self.game:ShowBottomWin(true, allwinCoin)
        end
        return
    end
    --收到回包切换按钮状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
    -- 设置最终停止数据
    local count = 0
    local sound = 0
    local earlywarning = 0
    local yujingid = self.game.startReel_count
    if yujingid == 1 then
        if Reel.isspecial then
            self.game:PlayFireWheelAnim(1)
        else
            ---如果不是特殊模式转轮 70%的概率出烟雾
            earlywarning = math.random(1,10) <= 7 and 2 or 0
            if earlywarning > 0 then
                self.game:PlaySmogAnim(function ()
                    if self.game.isSpined then
                        self.game:PlayFireWheelAnim(1)
                    end
                end)
            else
                self.game.startReel_count = 5
            end
        end
    end
    local timeinedx = 1--1.6 + earlywarning
    local addtimearr = {2,4,6,8,10}
    for k, v in pairs(self.reels) do
        local delaytime = FConfig.Common:GetRellStopInterval(k)
        if self.game.startReel_count > 0 and k >= self.game.startReel_count then
            delaytime = delaytime + addtimearr[timeinedx] + earlywarning
            timeinedx = timeinedx + 1
        end
        print("delaytime", delaytime)
        v:Stop(self.reelDatas[k],
            function()
                local jpcount = self:ExistJpIcon(k)
                if self:ExistFreeIcon(k) then
                    FToolSet.PlayFGUISound(string.format(MusicCfg.slots_353_reelFreestop,k))
                elseif jpcount > 0 then
                    if jpcount > 10 then
                        FToolSet.PlayFGUISound(string.format(MusicCfg.slots_353_reelJptrain,k))
                    else
                        FToolSet.PlayFGUISound(string.format(MusicCfg.slots_353_reelJp,k))
                    end
                else
                    FToolSet.PlayFGUISound(MusicCfg.slots_353_reelstop)
                end
                self:SingleWheelAnim(k)
                count = count + 1
                if self.game.startReel_count > 0 and k  >= self.game.startReel_count -1 then
                    self.game:PlayFireWheelAnim(k+1)
                end
                if count >= #self.reels then
                    self.game.startReel_count = 0
                    self:SpinEndCallFunc()
                end
            end
            , delaytime)
    end
end
--是否播放音效
function NormalSlot:can_playmusic(index,musicData)
	local isplay = false
	if index < 4 then
		isplay = true
	elseif musicData >= 2 and index == 4 then
		isplay = true
	elseif index == 5 and musicData >= 3 then
		isplay = true
	end
    if self.isEnterFree then
        isplay = true
        if musicData <= 1 and index == 5  then
            isplay = false
        end  
    end
	return isplay
end
--单轮旋转结束动画展示
function NormalSlot:SingleWheelAnim(index)
    for i = 1, FCasinoCtx.gameCfg.Reel.yCellNumber do
        self:PlayIndexAnim(index,i)
    end
end
function NormalSlot:PlayIndexAnim(index,i,indexXY,music)
    if  indexXY then
        index = Utils.GetReelIndex(indexXY) +1
        i = Utils.GetCellIndex(indexXY) +1
    end
    local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
    local display = arraySymbolDisplays[i]
    local cfg = SymbolConfig[display.data.icon]
    if Tools.IsJpCard(display.data.icon)  then
        if music then
            FToolSet.PlayFGUISound(string.format(MusicCfg.slots_353_Award,math.random(1,10)))
        end
        local data = self.reelDatas[index][i]
        local loader = display.render:GetChild("loader")
        if data.type ~= 1 then
            loader.visible = false
        end
        local anim = display.render:GetChild("anim")
        anim.visible = true
        anim.url = "ui://Game353/jpanim"..data.type
        local enter = anim.component:GetChild("enter")
        self:PlayWebm({render = enter,timer = 0.5,callback = function()
            loader.visible = true
        end})
        if data.type == 99 then
            self.game:PlayLastWheelAnim()
        end
    elseif Tools.IsScCard(display.data.icon) and not  Reel.isspecial then
        local loader = display.render:GetChild("loader")
        loader.url = "ui://Game353/sscanim1"
        if Reel.isInfree then
            loader.url = "ui://Game353/sscfreeanim1"
        end
        local enter = loader.component:GetChild("enter")
        self:PlayWebm({render = enter,timer = 0.5,callback = function()
            loader.url = cfg.icon
            if Reel.isInfree then
                loader.url = cfg.icon.."free"
            end
        end})
    end
end
-- 旋转结束处理
function NormalSlot:SpinEndCallFunc()
    self.inserfrist = {}
    print("所有格子旋转结束")
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    local func = function ()
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
        end
    end
    func()
end


-- 画线 收分
function NormalSlot:DrawLineAndCollectScores(isfreeover)
    --显示下方滚动收分
    local second = 0
    self:ShowLines()
    if not isfreeover then
        second = self.game:ShowBottomWin()
    end
    --（依次闪烁的动画）
    return second
end

function NormalSlot:SetIsEnterFree(isEnterFree)
    self.isEnterFree = isEnterFree
    Reel.isInfree = isEnterFree
end

function NormalSlot:SetFreeIconType(freeicotype)
    self.game.freetype = freeicotype
    Reel.freeicotype = freeicotype == 0 and 0 or freeicotype + 13
end
function NormalSlot:SetIsSpecialgame(visible)
    Reel.isspecial = visible
end
-- 处理格子信息
function NormalSlot:HandleCellDatas(grids)
    local freeCount = 0
    self.topupBounsCount = 0
    self.allwildanimtype = {}
    self.addForueDelayTime = 0
    self.game.Jpwinicon = {}
    self.game.freeIconInfo = {}
    self.game.freewildinfor = {}
    
    
    local bigcount = {{},{},{},{},{}}
    -- 整理服务器数据
    local reelDatas = {}
    local freeaddtime = 0
    for k, v in pairs(grids) do
        local reelIndex = self:GetReelIndex(k) + 1
        local iconIndex = self:GetCellIndex(k) + 1
        reelDatas[reelIndex] = reelDatas[reelIndex] or {}
        if v.icon == freeicon then
            table.insert(self.game.freeIconInfo,{index = v.index,icon = v.icon})
        end
        if v.icon == jpicon then
            table.insert(self.game.Jpwinicon,{index = v.index,icon = v.icon,
            type = v.SymbolType,value = v.SymbolValue})
        end
        reelDatas[reelIndex][iconIndex] = {
            icon = v.icon,
            index = v.index,
            type = v.SymbolType,
            value = v.SymbolValue
        }
    end
    if freeCount >= 3 then
        self.isEnterFree = true
    end
    self.reelDatas = reelDatas
    if Reel.isInfree then--免费游戏中记录wild图标位置信息
        for _, v in pairs(self.reelDatas) do
            for _, value in pairs(v) do
                if value.icon == wildicon then
                    table.insert(self.game.freewildinfor,{index = value.index,icon = value.icon})
                end
            end
        end
    end

end
function NormalSlot:AssDistance()
    self.game.startReel_count = 0--从第几个转轮开始加距离
    if Reel.isInfree then return end
    if Reel.isspecial then
        self.game.startReel_count = 1
        return
    end
    local jpnumber = 0
    for key, value_ in pairs(self.game.Jpwinicon) do
        jpnumber = jpnumber + value_.value
        --如果前4列有火车，第5列会预警加速转；
        if value_.type > 10 and value_.type < 20 then
            self.game.startReel_count = 5
            if (value_.type == 14 or value_.type == 13) and #self.game.TrainAnimCount > 0 then
                self.game.startReel_count = 1
            end
            return
        end
    end
    --如果前4列落地牌总分15倍，第5列会预警加速转
    local multiply = string.format("%.5f", (jpnumber / FCasinoCtx.commonPanel:GetBetMoney()))
    multiply = tonumber(multiply)
    if multiply >= 15 then
        self.game.startReel_count = 5
    end
end
-----处理中奖线 --------
--- animIndexs: 播放anim的 index
--- wild2Indexs:百搭二连线
--- wild3Indexs:百搭三连线
--- 忽略
function NormalSlot:HandleWinDatas(lines)
    print("处理中奖线。。。。。。")
    self.winCoin = 0
    self.spinResult_lines = {}
    self.game.wildIconInfo = {}
    self.game.TrainAnimCount = {}
    if not next(lines) then
        self.game.freewildinfor = {}
        return
    end
    self.inserfrist = {}
    self.game.Jpwinnumber = 0
    self.spinResult_lines = lines
    local winCoin = 0
    for i, line in ipairs(lines) do
        if line.lineIndex < 10000 then -- 落地牌不算分
            winCoin = winCoin + line.winCoin
            if line.lineIndex >= 2010 then
                if #self.inserfrist == 0 then
                    self.inserfrist = self:GetTrainInsert()
                end
                local traindata = {}
                for _, cell in pairs(line.lineCells) do
                    table.insert(traindata,{index = cell.index,icon = cell.icon  ,type =cell.SymbolType,value = cell.SymbolValue })
                end
                for key, value in pairs(self.inserfrist) do
                    if value.type -10 == line.lineIndex-2011  then
                        self.game.TrainAnimCount[key] = {}
                        self.game.TrainAnimCount[key].allwinCoin = value.winCoin
                        self.game.TrainAnimCount[key].traintypeindex =  line.lineIndex-2001 
                        self.game.TrainAnimCount[key].traintype = line.lineIndex-2011
                        self.game.TrainAnimCount[key].traindata = traindata
                    end
                end
            end
        end
    end
    self.winCoin = winCoin
end

--获取火车类型的具体下表
function NormalSlot:GetTrainInsert()
    local inserfrist = {}
    for _, value in pairs(self.reelDatas) do
        for _, valuetype in pairs(value) do
            if  valuetype.type > 10 and valuetype.type <= 88 then
                local type = valuetype.type == 88 and 15 or valuetype.type
                table.insert(inserfrist,{type = type ,winCoin = valuetype.value})
            end
        end
    end
    --根据彩金值从小到大排序
    table.sort( inserfrist, function ( a, b )
        return a.type < b.type
    end  )
    return inserfrist
end
function NormalSlot:_PlayCommonAnim(render, cfg,data,animstr,logicIndex)
    local animation = cfg.animation
    local loader = render:GetChild("loader")
    local anim = render:GetChild("anim")
    if animation ~= "" then
        if cfg.LDRes and data and data.type ~= nil and data.type ~= 0 then
            animation = animation..data.type
        end
        loader.visible = false
        if data and data.type ~= nil and data.type > 1 and data.type <20 then
            render:GetChild("num").visible = true
            local value = self:GetTrainTypeIndex(data.type,true)
            render:GetChild("num").text = Tools.TopupBounsScoreToStr(value)
        end
        anim.visible = true
        anim.url = animation
        local str = animstr or "loop"
        if Reel.isInfree then
            if cfg.ssc then
                anim.url = "ui://Game353/sscfreeanim2"
            end
            if cfg.wild then
                -- if self.game.wildbetindex > #self.game.wildbetarr  then
                --     self.game.wildbetindex = 1
                -- end
                str = str..self.game.wildbetarr[logicIndex]
                -- self.game.wildbetindex = self.game.wildbetindex + 1
            end
        end
        local loop = anim.component:GetChild(str)
        self:PlayWebm({render = loop,timer = -1,callback = function()
        end})
        
    else
        loader.url = cfg.icon
        render:GetTransition("t0"):Play()
    end
end
function NormalSlot:PlayWebm(opt)
    local render = opt.render
    local callback = function() end
    local timer = 1
    local scale = 1
    if opt.callback ~= nil and type(opt.callback) == "function" then
        callback = opt.callback
    end
    if opt.timer ~= nil then timer = opt.timer end
    if opt.scale ~= nil then scale = opt.scale end
    if render == nil then
        callback()
        return
    end
    render.visible = true
    local anim = FToolSet.Image2Webm(render)
    if not anim then
        APIGateway.CreateAllWebmWithRObject(render)
        anim = FToolSet.Image2Webm(render)
    end
    anim:SetPlayScale(scale)
    anim:SetFrame(0)
    anim:Play(timer, function()
        render.visible = false
        callback()
    end)
end
function NormalSlot:SetOpen(isOpen)
    self.isOpen = isOpen
end

function NormalSlot:GetWinCoin()
    print("获取值self.winCoin",self.winCoin)
    return self.winCoin
end

function NormalSlot:SetWinCoin(winCoin)
    self.winCoin = winCoin
end





-- @brief 中奖线展示
function NormalSlot:ShowLines()
    local lines = {}
    local winCoin = 0
    local allLine = {
        lineCells = {},
        winCoin = 0
    }
    local linescount = 0
    dump(self.spinResult_lines,"self.spinResult_lines",10)
    -- 中奖线数据整理
    for k, line in pairs(self.spinResult_lines or {}) do
        if line.lineIndex < 2010 then
            linescount = linescount + 1
            table.insert(lines, line)
            winCoin = winCoin + line.winCoin

            for _, cell in pairs(line.lineCells) do
                -- 去重
                local contain = false
                for __, v in pairs(allLine) do
                    if table.equals(cell, v) then
                        contain = true
                        break
                    end
                end

                if not contain then
                    table.insert(allLine.lineCells, cell)
                end
            end
            allLine.winCoin = line.winCoin
        end
      
    end
    if #lines <= 0 then
        return
    end
    --第一次闪烁全部中奖线
    table.insert(lines, 1, allLine)
    local showIndex = 0
    local function ShowLine(visible, isfirst)
         --清理动画的时候不需要计数增加
        if  visible then
            showIndex = showIndex + 1
            if showIndex > #lines then showIndex = 1 end
        end
        local lineCells = lines[showIndex].lineCells
        for k, cell in pairs(lineCells) do
            local index = cell.index 
            local logicX = Utils.GetReelIndex(index) +1
            local logicY = Utils.GetCellIndex(index) +1
            if visible then
                self:DrawWinIcon(logicX,logicY)
            else
                self:ClearWinIcon(logicX,logicY)
            end
        end
        return lines[showIndex].lineIndex 
    end
    ShowLine(true,#lines)
    self.tweensnor =  FTween.Start(self.bottomContainer,
    FTween.RepeatForever({
        FTween.Delay(2, function() 
            ShowLine(false)--清理中奖线动画 
            ShowLine(true)
        end),
    })
)
end
function NormalSlot:Findindex(index)
    for key, value in pairs(self.game.wildIconInfo) do
        if index == value.index  then
            return true
        end
    end
    return false
end
function  NormalSlot:InitIconvisible(isvisible)
    isvisible = isvisible or false
    for index = 1,  FCasinoCtx.gameCfg.Reel.xCellNumber do
        for indexy = 1,  FCasinoCtx.gameCfg.Reel.yCellNumber do
            local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
            local display = arraySymbolDisplays[indexy]
            display.render.visible = isvisible
        end
    end
end
function NormalSlot:StopShowLine()
    if self.tweensnor then
        self.tweensnor.Kill()
        self.tweensnor = nil
    end
    self:RemoveTopSymbol()
    self:InitIconvisible(true)
end
function NormalSlot:HideIcon(index,isshow)
    isshow = isshow or false
    -- 替换动画到顶层显示
    local logicX = Utils.GetReelIndex(index) +1
            local logicY = Utils.GetCellIndex(index) +1
    local arraySymbolDisplays = self.reels[logicX].arraySymbolDisplays
    local display = arraySymbolDisplays[logicY]
    display.render.visible = isshow
end
function NormalSlot:HideColumn(column,isshow)
    isshow = isshow or false
    for i = 1, FCasinoCtx.gameCfg.Reel.yCellNumber do
        self:HideIcon(column+(i-1)*5,isshow)
    end
end
function NormalSlot:GetTrainTypeIndex(traintype,isnumber)
    for _, value in pairs(self.game.Jpwinicon ) do
        if value.type == traintype then
            if isnumber then
                return value.value
            else
                return value.index
            end
        end
    end
    return 0
end
function NormalSlot:ShowLoaderNumber(index_,allwinCoin)
    --金火车结束不显示分数
    if index_ == 15 then return end
    local index = self:GetTrainTypeIndex(index_)
    print("index_########",index_,index)
    local logicX = Utils.GetReelIndex(index) +1
    local logicY = Utils.GetCellIndex(index) +1
    local arraySymbolDisplays = self.reels[logicX].arraySymbolDisplays
    local display = arraySymbolDisplays[logicY]
    display.render.visible = true
    display.render:GetChild("num").visible = true
    display.render:GetChild("num").text = Tools.TopupBounsScoreToStr(allwinCoin)
end
function NormalSlot:DrawWinIcon(logicX,logicY,isJPanim,animstr)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    -- 替换动画到顶层显示
    local arraySymbolDisplays = self.reels[logicX].arraySymbolDisplays
    local display = arraySymbolDisplays[logicY]
    local cfg = SymbolConfig[display.data.icon]
    local logicIndex = (logicY - 1) * reelCfg.xCellNumber + logicX
    local render = self:GetOrCreateTopSymbol(logicIndex, self.reelcfgdata)
    if display.data.icon == freeicon or display.data.icon == wildicon  then
        render.sortingOrder = 20
    else
        render.sortingOrder = 1
    end
    local data = nil
    if not isJPanim then
        data= self.reelDatas[logicX][logicY] 
    end
    self:_PlayCommonAnim(render,cfg,data,animstr,logicIndex)
    display.render.visible = false
    if  data and data.type ~= nil and data.type == 1 then
        display.render.visible = true
    end
end
function NormalSlot:ClearWinIcon(logicX,logicY)
    local arraySymbolDisplays = self.reels[logicX].arraySymbolDisplays
    local display = arraySymbolDisplays[logicY]
   
    
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local logicIndex = (logicY - 1) * reelCfg.xCellNumber + logicX
    local render = self:GetOrCreateTopSymbol(logicIndex, self.reelcfgdata)
    render.visible = false
    display.render.visible = true
end
function NormalSlot:ExistFreeIcon(index)
    -- if index == 1 or index == 5 then
    --     return false
    -- end
    for i = 1, FCasinoCtx.gameCfg.Reel.yCellNumber do
		if self.reelDatas[index][i].icon == freeicon then
			return true
		end
	end
	return false
end
function NormalSlot:ExistJpIcon(index)
    local jpcount = 0
    for i = 1, FCasinoCtx.gameCfg.Reel.yCellNumber do
		if self.reelDatas[index][i].icon == jpicon then
			jpcount = i < 10 and i or jpcount
            if self.reelDatas[index][i].type > 1 then
                jpcount = jpcount + 10
            end
		end
	end
	return jpcount
end
--获取图标所在位置
function NormalSlot:GetIndePos(index)
    local logicX = Utils.GetReelIndex(index) +1
    local logicY = Utils.GetCellIndex(index) +1
    local arraySymbolDisplays = self.reels[logicX].arraySymbolDisplays
    local render = arraySymbolDisplays[logicY].render
    local xy = render:LocalToRoot(vec2(0,0))
    local container =  FCasinoCtx.commonPanel.topEffectLayer
    local posT = container:RootToLocal(xy)
    return posT
end
function NormalSlot:PlayTablelist(temptable,animstr)
    if #temptable == 0 then return end
    for _, value in ipairs(temptable) do
        local cellIndex = Utils.GetReelIndex(value.index) +1
        local iconIndex = Utils.GetCellIndex(value.index) +1
        self:DrawWinIcon(cellIndex,iconIndex,animstr)
    end
   
end
function NormalSlot:CleanTablelist(temptable)
    if #temptable == 0 then return end
    for _, value in ipairs(temptable) do
        local cellIndex = Utils.GetReelIndex(value.index) +1
        local iconIndex = Utils.GetCellIndex(value.index) +1
        self:ClearWinIcon(cellIndex,iconIndex)
    end
    temptable = {}
end

return NormalSlot
