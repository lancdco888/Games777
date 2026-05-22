local Utils = {}

-- @brief 落地牌数字转字符串
-- 259,317,318 落地牌显示规则:
-- 显示=得分/当前押注“C等级” 如{1,5,10,20,50) 3等级就是 /10
function Utils.TopupBounsScoreToStr(value)
    value = value / FCasinoCtx.commonPanel:GetCurBetCValue()
    return FToolSet.NumToStr(value)
end

-- @brief 获取转轴下标
-- @return [0,4]
function Utils.GetReelIndex(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    return (index - 1) % reelCfg.xCellNumber
end

-- @brief 获取Y轴格子下标
-- @return [0,2]
function Utils.GetCellIndex(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    return math.floor((index - 1) / reelCfg.xCellNumber)
end
function Utils.printLine(grids,cellNum)
	cellNum = cellNum or 3
	local grids_xb = 0
	for i=1 ,cellNum do
		print(string.format("           第"..i.."行:   %d   %d   %d   %d   %d",
		grids[1+grids_xb].icon,grids[2+grids_xb].icon,grids[3+grids_xb].icon,
		grids[4+grids_xb].icon,grids[5+grids_xb].icon))
		grids_xb = grids_xb + 5
	end
end
Utils.getrowindex = function (index)
	local xb = 1
	if index > 5 and index <= 10 then
		xb = 2
	elseif index > 10 and index <= 15 then
		xb = 3
	elseif index > 15 and index <= 20 then
			xb = 4
	end
	return xb
end
------转化X下标-----------
Utils.getcolumnindex = function (index)
	local xb = index % 5
	if index % 5 == 0 then
		xb = 5
	end
	return  xb
end
function Utils.handle_winline(winline)
    local newwinline = {}
    --按照从上到下,从左到右排序
    for i=1,#winline do		
        for j=i+1,#winline do
            local index = winline[i].index
            local index_x = Utils.getcolumnindex(index)
            local index_y = Utils.getrowindex(index)

            local index_ = winline[j].index
            local index_xx = Utils.getcolumnindex(index_)
            local index_yy = Utils.getrowindex(index_)
            if (index_x > index_xx) then
                winline[i],winline[j] = winline[j],winline[i] 
            elseif (index_x == index_xx) then
                if (index_y > index_yy) then
                    winline[i],winline[j] = winline[j],winline[i] 
                end
            end
        end		
    end
    --是否有全列图形
    local all_line = {0,0,0,0,0}
    for i=1,#winline do	
        local index = winline[i].index
        local pos = winline[i].pos
        local index_x = Utils.getcolumnindex(index)
        if all_line[index_x] == 0 then
            newwinline[#newwinline + 1] = {}
            if Utils.getrowindex(index) == 1 then
                local allline = true
                for j = 1, 3 do
                    local newindex = i + j
                    if newindex > #winline then
                        allline = false
                        break
                    elseif index_x ~= Utils.getcolumnindex(winline[newindex].index)  then
                        allline = false
                        break
                    end
                end
                if allline then
                    all_line[index_x] = 1
                    newwinline[#newwinline].issmallbv = false
                    newwinline[#newwinline].index = index_x
                    newwinline[#newwinline].pos = pos
                    newwinline[#newwinline].freewild = winline[i].freewild
                else
                    newwinline[#newwinline].issmallbv = true
                    newwinline[#newwinline].index = winline[i].index 
                    newwinline[#newwinline].pos = pos
                    newwinline[#newwinline].freewild = winline[i].freewild
                end
            else
                newwinline[#newwinline].issmallbv = true
                newwinline[#newwinline].index = winline[i].index 
                newwinline[#newwinline].pos = pos
                newwinline[#newwinline].freewild = winline[i].freewild
            end
        end
    end
    return newwinline
end
function Utils.PlayWebm(opt)
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
return Utils