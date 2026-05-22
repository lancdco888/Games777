local this = {}

this.netHandler_str = "OneGameLotteryRet"

function this.Register(isAuto)
	this.isAuto = isAuto or false
	if (nil ~= gNetHandlers[this.netHandler_str]) then
		this.Unregister()
	end
	this.Init()
	gNetHandlers_Register(PKG_Support_Other_OneGameLotteryRet, this.netHandler_str, this.C_Handle_Bonuses)
end

function this.Unregister()
	this.Interface_Func = nil
	for __,value in pairs(this.bonusesDatas) do
		if(nil ~= value.runNode)then
			value.runNode:removeFromParent()
		end
	end
	gNetHandlers_Unregister(PKG_Support_Other_OneGameLotteryRet, this.netHandler_str)
end

function this.Init()
	this.Interface_Func = nil
	this.bonusesDatas 	= {}
	--[[
		betOrMoney
		lReal
		initDigit
		showDigit
		runNode
	--]]
end

function this.Update()
	if (nil ~= this.Interface_Func) then
		this.Interface_Func(this.bonusesDatas)
	else
		print("无")
	end
end

--处理接收的彩金数据
function this.C_Handle_Bonuses(rlt_)
	-- print("处理接收的彩金数据 ---------------------")
	for i = 1, #rlt_.infos do
		--彩金类型--2小奖分值 3中奖分值 4大奖分值 5巨奖分值
		local lType 		= rlt_.infos[i].lType
		--判断lReal值是押注倍数运算值还是真实值
		local betOrMoney 	= rlt_.infos[i].betOrMoney
		--彩金值 = (betOrMoney == 0 时 lReal*当前倍数) (betOrMoney == 1 时 lReal)
		local lReal 		= rlt_.infos[i].lReal
		-----------------Log------------------------------------------------
		if this.bonusesDatas[lType] == nil then
			-- print("[初始收包] 彩金数据:", "彩金值:", lReal, " -彩金类型:", lType, " -倍数[1是会滚动]:", betOrMoney)
		else
			-- print("[后续收包] 彩金数据:", "彩金值:", lReal, " -彩金类型:", lType, " -倍数[1是会滚动]:", betOrMoney, " -客户端值:", this.bonusesDatas[lType].showDigit)
		end
		--------------------------------------------------------------------
		if(this.bonusesDatas[lType] == nil)then						--第一次接收彩金数据
			this.bonusesDatas[lType] = {}
			this.bonusesDatas[lType].betOrMoney = betOrMoney
			--记录最开始获取的彩金值 用与 后面判断彩金是否重新开始
			this.bonusesDatas[lType].initDigit 	= lReal
			this.bonusesDatas[lType].showDigit 	= lReal
			--不需要滚动的彩金没有 showDigit 和 initDigit 字段
			if (1 == this.bonusesDatas[lType].betOrMoney) then
				this.bonusesDatas[lType].runNode	= cc.Node:create()
				cc.Director:getInstance():getRunningScene():addChild(this.bonusesDatas[lType].runNode)
				if(this.isAuto)then
					this.RunBonus(this.bonusesDatas[lType], 5, const_game.Caijin_UpdateTime)
				end
			end
		elseif (1 == this.bonusesDatas[lType].betOrMoney) then		--后面的只看要滚动的
			--print("lType",lType,lReal,this.bonusesDatas[lType].showDigit,lReal - this.bonusesDatas[lType].showDigit)
			--直接就停了，该滚它还是会滚，不该滚也就不需要处理
			--this.bonusesDatas[lType].runNode:stopAllActions()
			-- if(lReal > this.bonusesDatas[lType].showDigit)then
			-- 	if(this.isAuto)then
			-- 		local step = lReal - this.bonusesDatas[lType].showDigit
			-- 		this.RunBonus(this.bonusesDatas[lType], step, const_game.Caijin_UpdateTime)
			-- 	else
			-- 		this.RunBonus_2(this.bonusesDatas[lType], lReal, const_game.Caijin_UpdateTime)
			-- 	end
			-- elseif(lReal <= this.bonusesDatas[lType].initDigit)then	--比第一次收到的还小，说明有人中大奖，彩金刷新了
			-- 	this.bonusesDatas[lType].initDigit = lReal
			-- 	this.bonusesDatas[lType].showDigit = lReal
			-- end
			--6.16D 收到彩金值处理（1。彩金值小于上把的“滚动完之后的彩金值==初始彩金值”，停止滚动状态）
			---                   （2.彩金值大于上把彩金值  并且 大于显示彩金值，开始滚动彩金=
			---                   （3.彩金值大于上显示的彩金值，还没有滚动完成继续滚动
			---                   （4.彩金值等于显示的彩金值，不做处理
			--修改天杀的bug
			if(lReal < this.bonusesDatas[lType].initDigit)then	--比上一次刷新值收到的还小，说明有人中大奖，彩金刷新了
				--小于上把彩金值 停止滚动刷新数值
				this.bonusesDatas[lType].runNode:stopAllActions()
				this.bonusesDatas[lType].initDigit = lReal
				this.bonusesDatas[lType].showDigit = lReal
				-- print("--有人中奖了 直接刷")
			elseif (lReal > this.bonusesDatas[lType].initDigit and lReal > this.bonusesDatas[lType].showDigit) then
				this.bonusesDatas[lType].initDigit = lReal
				-- print("--需要滚动")
				if(this.isAuto)then
					local step = lReal - this.bonusesDatas[lType].showDigit
					this.RunBonus(this.bonusesDatas[lType], step, const_game.Caijin_UpdateTime)
				else
					this.RunBonus_2(this.bonusesDatas[lType], lReal, const_game.Caijin_UpdateTime)
				end
			elseif lReal > this.bonusesDatas[lType].showDigit then
				-- print("--彩金显示值没有滚完继续滚动")
			else
				-- print("--不需要滚动 或 刷新")
			end
		end

	end
	--更新
	this.Update()
	-- print("--------------------------------------")
end

function this.RunBonus(bonusData,step,time)
	print("step:", step, " time:", time)
	local frameRate = math.floor((60*time) / step)
	local rollValue = 1
	if frameRate < 1 then
		rollValue = 0
		while true do
			rollValue = rollValue + 1
			local item = math.floor((60*time)/(step/rollValue))
			if item >= 1 then
				frameRate = item
				break
			end
		end
	end
	
	--更新
	local UpdateFunc = function ()
		bonusData.showDigit = bonusData.showDigit + rollValue
		this.Update()
	end
	--print("frameRate/60",frameRate/60,math.ceil(step/rollValue))
	--运行
	local updateTimeAction = cc.DelayTime:create(frameRate/60)
	local updateAction = cc.Sequence:create(updateTimeAction,cc.CallFunc:create(UpdateFunc))
	local action = cc.Repeat:create(updateAction,math.floor(step/rollValue))
	bonusData.runNode:runAction(action)
	--
end

function this.RunBonus_2(bonusData, lReal, time)
	--时间，数值，tag，更新回调，结束回调 --second, value, tag, UpdateCallFunc, OverCallFunc
    if bonusData.runNode then
		bonusData.runNode:stopAllActions()
	else
		local node = cc.Node:create()
		cc.Director:getInstance():getRunningScene():addChild(node)
		bonusData.runNode = node
	end
	--
	local step = lReal - bonusData.showDigit
    if step <= 0 then
		bonusData.showDigit = lReal
		this.Update()
        return
    end
    --
	local increment = math.floor((step / time) * 0.016);
	local intervalFPS = 0.016;
	if (increment == 0) then
		increment = 1;
		intervalFPS = time / step;
    end
	--
    local Update = function ()
        bonusData.showDigit = bonusData.showDigit + increment
        if bonusData.showDigit >= lReal then
            bonusData.showDigit = lReal
        end
		this.Update()
		if bonusData.showDigit == lReal then
			print("彩金值滚动完成")
			bonusData.runNode:stopAllActions()
		end
    end
    -------------------------------
    --旋转动画
    local updateAction = cc.Sequence:create(cc.CallFunc:create(Update), cc.DelayTime:create(intervalFPS))
    local repeatAction = cc.RepeatForever:create(updateAction)
    bonusData.runNode:runAction(repeatAction)
end

return this