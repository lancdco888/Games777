local CaiJinItem = class("CaiJinItem", function(node)
    return node
end)

function CaiJinItem:ctor()
    self.types = {} -- 彩金框节点
	self.lastData = {0, 0}
end

function CaiJinItem:SetGameID(gameID)
	self.gameID = gameID
end

function CaiJinItem:onEnter()
    self:InitData()
    self:InitUI()
end

function CaiJinItem:InitData()
    local game_id = GameData:GetGameID(self.gameID)
    local data = const_game.Param[game_id]
	if not data then
		print("Error: no caijin cfg found for:" .. game_id)
		return
	end

    self.caijin_type = data.caijin_type or 1 -- 彩金背景框类型
end

function CaiJinItem:InitUI()
    --所有彩金类型
    local types = {}
    local children = self:getChildren()
    for _, child in ipairs(children) do
        local name = child:getName()
        local id = tonumber(name)
        types[id] = child

		-- 清理遗留的 action
		local num_node_1 = child:findChild("num_1")
		num_node_1:stopAllActions()
		local num_node_2 = child:findChild("num_2")
		num_node_2:stopAllActions()

		num_node_1._start_digit = nil
		num_node_2._start_digit = nil

		child:setVisible(false)
    end

    self.types = types
end

--设置彩金类型
function CaiJinItem:SetVisible(type,bool_)
    for type_,node in pairs(self.types) do
        if tostring(type_) == tostring(type) then
            node:setVisible(true)
            if not bool_ then
                node:findChild("bg_2"):setVisible(false)
            end
        else
            node:setVisible(false)
        end
    end
end

--从一个数字变化到另外一个数字
function CaiJinItem:RunToNumber(time, label, from, to)
    local MAX_TIMES = time*30 -- 最大变化次数 变成帧率2倍
    local lerp_value = to - from -- 插值
    if lerp_value == 0 then
        return
    end
    local times = 0 --准备变化多少次
    if lerp_value > MAX_TIMES then
        times = MAX_TIMES
    else
        times = lerp_value
    end 
    local delta = (lerp_value / times == 0) and 1 or lerp_value / times
    local index = 0     --当前第几次
    label:runAction(cc.Repeat:create(
        cc.Sequence:create(
            cc.DelayTime:create(time/times),
            cc.CallFunc:create(
                function()
                    index = index + 1
					local strTem = Tools.GetLotteryMoneyStr(from + delta*index)
                    label:setString(strTem)
                    if index >= times then
						local strTem = Tools.GetLotteryMoneyStr(to)
                        label:setString(strTem)
                    end
                end
            )
        ),
        times
    ))
end

function CaiJinItem:RunToNum(num_1,setp_1, num_2,setp_2)
    if  type (num_1)~=type(1) then 
		num_1 = Int64ToNumber(num_1)
	end
    if  type (setp_1)~=type(1) then 
		setp_1 = Int64ToNumber(setp_1)
	end
    if  type (num_2)~=type(1) then 
		num_2 = Int64ToNumber(num_2)
	end
    if  type (setp_2)~=type(1) then 
		setp_2 = Int64ToNumber(setp_2)
	end
    for _,node in pairs(self.types) do
        if node:isVisible() then
            local num_node_1 = node:findChild("num_1")
            local num_node_2 = node:findChild("num_2")
            -----------------------大奖--------------------
            local now_digit_1 = 0
            local run_action = false
			if num_node_1._start_digit == nil then -- 第一次
                now_digit_1 = num_1
                run_action = setp_1 > 0 
            else
                local current_caijin = Tools.string_Exchangerate(num_node_1:getString())
                if current_caijin > num_1+setp_1 then -- 当前彩金大于服务器彩金
                    now_digit_1 = num_1
                    run_action = setp_1 > 0 
                elseif current_caijin < num_1+setp_1 then -- 当前彩金小于服务器彩金
                    now_digit_1 = current_caijin
                    run_action = (num_1+setp_1-current_caijin) > 0 
                else
                    now_digit_1 = current_caijin
                    run_action = false
                end
            end
            num_node_1._start_digit = now_digit_1
            num_node_1:setString(Tools.GetLotteryMoneyStr(num_node_1._start_digit))
            num_node_1:stopAllActions()
            if run_action then
                self:RunToNumber(const_game.Caijin_UpdateTime, num_node_1, num_node_1._start_digit, num_1+setp_1)
            end
            
            ---------------------二奖--------------------
            local now_digit_2 = 0
            if num_node_2._start_digit == nil then
                now_digit_2 = num_2
                run_action = setp_2 > 0 
            else
                local current_caijin = Tools.string_Exchangerate(num_node_2:getString())
                if current_caijin > num_2+setp_2 then 
                    now_digit_2 = num_2
                    run_action = setp_2 > 0
                elseif current_caijin < num_2+setp_2 then
                    now_digit_2 = current_caijin
                    run_action = (num_2+setp_2-current_caijin) > 0 
                else
                    now_digit_2 = current_caijin
                    run_action = false
                end
            end
            num_node_2._start_digit = now_digit_2
            num_node_2:setString(Tools.GetLotteryMoneyStr(num_node_2._start_digit))
            num_node_2:stopAllActions()
            if run_action then
                self:RunToNumber(const_game.Caijin_UpdateTime, num_node_2, num_node_2._start_digit, num_2+setp_2)
            end
        end
    end
end

--设置彩金数据data为: {setp, lType, lReal, hallShow}, ...
function CaiJinItem:SetDataList(data_list_)
    if not self.caijin_type then
        print("游戏没有配置彩金信息：", self.gameID)
        return
    end

    if data_list_ == nil then return end
    if not data_list_[1] then return end

    local data = data_list_[1]
    self:SetVisible(self.caijin_type,data_list_[2])
	
	--获取彩金2的值
	local value = data_list_[2] and data_list_[2].lReal or 0
     if  type (value)~=type(1) then 
		value = Int64ToNumber(value)
	end
	local valueStep = data_list_[2] and data_list_[2].setp or 0
    if  type (valueStep)~=type(1) then 
		valueStep = Int64ToNumber(valueStep)
	end
	if value == 0 and self.gameID ~= 210 and self.gameID ~= 211 and self.gameID ~= 232 then
		print("彩金信息出错，大奖彩金为0， 游戏ID：",self.gameID)
		return
	end

	--初始化第一次取得彩金，直接赋值
	local initStep = 5
	if self.lastData[1] == 0 and self.lastData[2] == 0 then
		self:RunToNum(data_list_[1].lReal,Int64ToNumber(data_list_[1].setp) + initStep, value, valueStep + initStep * 2)
	--彩金1正常增长
	elseif Int64ToNumber(data_list_[1].lReal) > self.lastData[1] then
		--彩金2正常增长
		if value > self.lastData[2] or value == self.lastData[2] then
			self:RunToNum(self.lastData[1],data_list_[1].lReal - self.lastData[1], self.lastData[2],
				 value - self.lastData[2])
		--彩金2被消耗
		else
			self:RunToNum(self.lastData[1],data_list_[1].lReal - self.lastData[1], value,0)
		end
	--彩金2正常增长
	elseif value > self.lastData[2] then
		--彩金1正常增长
		if data_list_[1].lReal > self.lastData[1] or data_list_[1].lReal == self.lastData[1] then
			self:RunToNum(self.lastData[1],data_list_[1].lReal - self.lastData[1], self.lastData[2],
				 value - self.lastData[2])
		--彩金1被消耗
		else
			self:RunToNum(data_list_[1].lReal,0, self.lastData[2],value - self.lastData[2])
		end
	--彩金1、2同时被消耗
	else
		self:RunToNum(data_list_[1].lReal,0, value,0)
	end
	
	--保存上一次的彩金值
	--第一次假转的值要保存下来
	if self.lastData[1] == 0 and self.lastData[2] == 0 then
		self.lastData[1] = Int64ToNumber(data_list_[1].lReal)+Int64ToNumber(data_list_[1].setp) + initStep
		self.lastData[2] = value + valueStep + initStep * 2
	else 
		self.lastData[1] = Int64ToNumber(data_list_[1].lReal)
		self.lastData[2] = value
	end
end

return CaiJinItem
