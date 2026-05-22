local Tools = {}
--格子上的车从3x7格子的大小转换到3x5格子的大小需要的缩放的倍数
Tools.ScaleOfSymbolKC_3x5 = vec2(1.395,1.422)

--免费中奖线ID
Tools.FreeLineID = 1003

--落地牌Icon的ID(普通)
Tools.BounsIconID = 10
--落地牌Icon的ID(3x7)
Tools.BounsIconID_3x7 = 13
--落地牌Icon的ID(双重转盘)
Tools.BounsIconID_Double = 14
--SCIcon的ID
Tools.SCIconID = 12
--WildIcon的ID
Tools.WildIconID = 11
--Wildx2Icon的ID(如果有的话)
Tools.Wildx2IconID = 15

Tools.InitUIBox2Symbol = function (datas)
    local retDatas = nil
    retDatas = {}
    for _, data in ipairs(datas) do
        local reelCellData = {}
        for _, icon in ipairs(data) do
            local cellData = {
                icon  = icon,
                value = 0,
                type = 0
            }
            table.insert(reelCellData,cellData)
        end
        table.insert(retDatas,reelCellData)
    end
    return retDatas
end

Tools.InitUIBox2Symbol_Bouns = function (datas,x_lenth)
    local retDatas = nil
    retDatas = {}
    for i, data in ipairs(datas) do
        local reelCellData = {}
        for j, icon in ipairs(data) do
            local cellData = {
                icon  = icon,
                value = 0,
                type = 0
            }
            retDatas[x_lenth * (j - 1) + i] = cellData
        end
    end
    return retDatas
end

-- @brief 落地牌数字转字符串
function Tools.TopupBounsScoreToStr(value)
    value = value / FCasinoCtx.commonPanel:GetCurBetCValue()
    return FToolSet.NumToStr(value)
end

--适配unity
Tools.GetChildrenList= function (obj)
    local num = obj.numChildren
    local childs = {}
    for i = 0, num-1 do
        table.insert(childs,obj:GetChildAt(i))
    end
    return childs
end

Tools.AnimNodeSet = function (node,bool)
    node.visible = bool
    node.playing = bool
    node.frame = 0
end

--time,停在哪一帧，不填默认第0帧
Tools.AnimNodeStop = function (node,time)
    node.visible = true
    node.playing = false
    node.frame = time or 0
end

--是否是SC
function Tools.IsSCCard(icon)
    return icon == Tools.SCIconID
end

--是否是落地牌(3x5)
function Tools.IsJpCard(icon)
    return icon == Tools.BounsIconID
end

--是否是落地牌(3x7)
function Tools.IsJpCard_3x7(icon)
    return icon == Tools.BounsIconID_3x7
end

--是否是落地牌(双倍转盘)
function Tools.IsJpCard_Double(icon)
    return icon == Tools.BounsIconID_Double
end

--是否是单倍替代
function Tools.IsWildCard(icon)
    return icon == Tools.WildIconID
end

--是否是双倍替代
function Tools.IsWildx2Card(icon)
    return icon == Tools.Wildx2IconID
end

-- @brief 是否需要播放抛金币动画
function Tools.isPlayCoinFountain(value)
    return value / FCasinoCtx.commonPanel:GetBetMoney() >= 15
end

-- @brief 是否需要播放抛金币动画2
function Tools.isPlayCoinFountain2(value)
    return value / FCasinoCtx.commonPanel:GetBetMoney() >= 30
end

-- table  元素数量
function Tools.CheckTabCount(tab)
    local count = 0
    for _, v in pairs(tab) do
        if v then
            count = count + 1
        end
    end
    return count
end

--集体序列帧播放控制
function Tools:InitAnimList(number,callback)
    self:ClearAnimList()
    for i = 1, number do
        table.insert(self.list_anim,{})
    end
    self.playend_callback = callback
end

function Tools:ClearAnimList()
    self.list_anim = {}
    self.played_number = 0
    self.playend_callback = nil
end

function Tools:AddAnimInList(anim_node,index,playtime)
    self.list_anim[index] = false
    anim_node:SetPlaySettings(0,-1,playtime,-1,function ()
        self.list_anim[index] = true
        self.played_number = self.played_number + 1
        if self.played_number >= #self.list_anim then
            local isover = true
            for i = 1, #self.list_anim do
                if not self.list_anim[i] then
                    isover = false
                end
            end
            if isover then
                self.playend_callback()
                self:ClearAnimList()
            end
        end
    end)
end

return Tools