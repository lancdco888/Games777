local Tools = {}

Tools.InitUIBox2Symbol = function (datas)
    local retDatas = nil
    if datas and #datas == 5 then
        retDatas = {}
        for _, data in ipairs(datas) do
            local reelCellData = {}
            for _, icon in ipairs(data) do
                local cellData = {
                    icon  = icon,
                    value = 0,
                    isHide = 0,
                    type = 0
                }
                table.insert(reelCellData,cellData)
            end
            table.insert(retDatas,reelCellData)
        end
    end
    return retDatas
end

-- @brief 落地牌数字转字符串
-- 259,317,318 落地牌显示规则:
-- 显示=得分/当前押注“C等级” 如{1,5,10,20,50) 3等级就是 /10
function Tools.TopupBounsScoreToStr(value)
    value = value / FCasinoCtx.commonPanel:GetCurBetCValue()
    return FToolSet.NumToStr(value)
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

-- endVisible:结束时是否显示node
Tools.PlayOnceAnim = function(node,endVisible,callback)
    if not node then
        print("error: Tools.PlayOnceAnim not node")
        return 
    end
    endVisible = endVisible or false
    node.visible = true
    node.frame = 0
    node:SetPlaySettings(0,-1,1,-1,
        function ()
            node.visible = endVisible
            node.playing = false
            node.frame = 0
            if callback then
                callback()
            end
        end
    )
    node.playing = true
end
return Tools