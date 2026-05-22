module("dragon_turntable", package.seeall)

-- 不同层级的神龙转盘角度对应的倍率
local rateInLevel = {
    [1] = {rates = {0,350,0,300,0,250,0,200}, iscenter = true, turns = 10, needleoffsety = 26}, 
    [2] = {rates = {400,0,600,450,0,500}, iscenter = false, turns = 8, needleoffsety = 34},
    [3] = {rates = {1000,0,2000}, iscenter = false, turns = 6, needleoffsety = 46},
    [4] = {needleoffsety = 39}, -- 第四轮不旋转只是把针 指向元宝
}
-- 创建一个神龙转盘
-- rate :倍率
function create_dragon_turntable(rate, startposX, startposY, endposX, endposY, callback)
    local node = cc.CSLoader:createNode("csb/dragon_turntable.csb")
    node:setPosition(cc.p(startposX or 0,startposY or 0))
    
    -- local root = check_ui_root()
    -- 使用更低的 ui 层级
    local root = FF_G_Client.GetNodeByNodeIndex(FF_G.kNodeIndex_UiTop)
    root:addChild(node)
    local c1, c2, c3 = node:getChildByName("c_1"),node:getChildByName("c_2"),node:getChildByName("c_3")
    local c1_num_root, c2_num_root, c3_num_root = c1:getChildByName("num_root"),c2:getChildByName("num_root"),c3:getChildByName("num_root")
    local needle = node:getChildByName("needle")
    local Ingots = node:getChildByName("Ingots")
    local tips = node:getChildByName("tips")
    node.nodelist = {
        c1 = c1, 
        c2 = c2,
        c3 = c3,
        c1_num_root = c1_num_root,
        c2_num_root = c2_num_root,
        c3_num_root = c3_num_root,
        needle = needle,
        Ingots = Ingots,
        tips = tips,
    }
    node.rate = rate
    if rate < 400 then
        node.level = 1
    elseif 400 <= rate and rate < 1000 then
        node.level = 2
    elseif 1000 <= rate and rate < 10000 then
        node.level = 3
    elseif rate == 10000 then
        node.level = 4
    else
        print("ERROR:创建一个神龙转盘,但是倍率的区间找不到")
        print(debug.traceback()) 
    end
    node.callback = callback or function()
        print("ERROR:创建一个神龙转盘,但是没有回调")
        print(debug.traceback()) 
    end
    moveto_player_position(node,{x = endposX or 300, y = endposY or -200})
end

-- 移动神龙转盘到指定玩家的位置, 并渐显转盘倍率
function moveto_player_position(node, pos)
    node:runAction(
        cc.Sequence:create(
            cc.EaseOut:create(cc.MoveTo:create(0.5, pos),1),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(
                function ()
                    for i = 1, 3 do
                        local num_root = node.nodelist["c"..i.."_num_root"]
                        num_root:setOpacity(0)
                        num_root:setVisible(true)
                        num_root:runAction(cc.FadeIn:create(0.8))
                    end

                    node.nodelist.needle:setOpacity(0)
                    node.nodelist.needle:setVisible(true)
                    node.nodelist.needle:runAction(cc.FadeIn:create(0.8))
                end
            ),
            cc.DelayTime:create(0.8),
            cc.CallFunc:create(
                function ()
                    node.nodelist.Ingots:setScale(1.2)
                    node.nodelist.Ingots:setVisible(true)
                    node.nodelist.Ingots:runAction(cc.ScaleTo:create(0.5,1))

                    node.nodelist.tips:setScale(0.2)
                    node.nodelist.tips:setVisible(true)
                    node.nodelist.tips:runAction(cc.ScaleTo:create(0.5,1))
                end
            ),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(
                function ()
                    show_tips(node)
                end
            )
        )
     )
end

-- 展示最大倍率的提示框
function show_tips(node)
    local posx,posy = node.nodelist.tips:getPosition()
    node.nodelist.tips:runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.2, {x= posx,y = posy+20}),
            cc.MoveTo:create(0.2, {x= posx,y = posy}),
            cc.DelayTime:create(0.3),
            cc.FadeOut:create(0.1),
            cc.CallFunc:create(
                function ()
                    -- 开始旋转了
                    local Ingots_anim = node.nodelist.Ingots:getChildByName("anim")
                    Ingots_anim:setVisible(true)
                    whirling(node,node.level and 1 or nil)
                end
            )
        )
    )
end

-- 根据不同的倍率去旋转 [一共三层]
-- level: 1,2,3三层由外到里
function whirling(node, level)
    if not node then
        return
    elseif not level then
        node:removeFromParent()
        node = nil
        return
    end
    local angle, index = calculate_angle(node, level)
    if not angle then
        node:removeFromParent()
    end
    local glint = node:getChildByName("glint_"..level)
    glint:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(0.4),
            cc.FadeOut:create(0.4)
        )
    )
    local rotate_node = node.nodelist["c"..level]
    rotate_node:runAction(
        cc.Sequence:create(
            cc.RotateBy:create(3,angle*0.9),
            cc.CallFunc:create(
                function ()
                    local fire_anim = node.nodelist.needle:getChildByName("fire_anim")
                    fire_anim:setVisible(true)
                    fire_anim:getAnimation():play("fire",1,0)
                    local posx,posy = node.nodelist.needle:getPosition()
                    node.nodelist.needle:runAction(
                        cc.Sequence:create(
                            cc.MoveTo:create(0.3, {x= posx,y = posy-20}),
                            cc.MoveTo:create(0.3, {x= posx,y = posy})
                        )
                    )
                end
            ),
            cc.EaseSineOut:create(cc.RotateBy:create(1.5,angle*0.1)),
            cc.CallFunc:create(
                function ()
                    local show_node = rotate_node:getChildByName("t_"..index)
                    local show_glint = show_node:getChildByName("glint")
                    show_glint:setOpacity(0)
                    show_node:setVisible(true)
                    local fadein_action = cc.FadeIn:create(0.2)
                    local fadeout_action = cc.FadeOut:create(0.2)
                    show_glint:runAction(
                        cc.Sequence:create(
                            fadein_action,
                            fadeout_action,
                            fadein_action,
                            fadeout_action,
                            fadein_action,
                            fadeout_action,
                            cc.CallFunc:create(
                                function ()
                                    once_whirl_end(node, level)
                                end
                            )
                        )
                    )
                end
            )
        )
    )
end

-- 一次旋转结束判断是否进行下一轮还是结算
function once_whirl_end(node, level)
    if node.level == level then
        local ring_anim_1 = node:getChildByName("ring_anim_1")
        local ring_anim_2 = node:getChildByName("ring_anim_2")
        local ring_anim_3 = node:getChildByName("ring_anim_3")
        ring_anim_1:setVisible(true)
        ring_anim_1:getAnimation():play("whirl")
        ring_anim_2:setVisible(true)
        ring_anim_2:getAnimation():play("whirl")
        ring_anim_3:setVisible(true)
        ring_anim_3:getAnimation():play("whirl")
        node.nodelist.c1:runAction(cc.RotateBy:create(3,1000))
        node.nodelist.c2:runAction(cc.RotateBy:create(3,-1000))
        node.nodelist.c3:runAction(cc.RotateBy:create(3,1000))
        node:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(1.5),
                cc.CallFunc:create(node.callback),
                cc.FadeOut:create(1),
                cc.RemoveSelf:create()
            )
        )
    else
        local posx,posy = node.nodelist.needle:getPosition()
        local offsety = rateInLevel[level].needleoffsety
        node.nodelist.needle:runAction(
            cc.Sequence:create(
                cc.MoveTo:create(0.3, {x= posx,y = posy-offsety}),
                cc.CallFunc:create(
                    function ()
                        local nextlevel = level+1
                        if nextlevel == #rateInLevel then -- 转到了最后一轮（第四轮），不需要旋转
                            once_whirl_end(node, nextlevel)
                        else
                            whirling(node,level+1)
                        end
                    end
                )
            )
        )
    end
end

-- 根据倍率和层数计算节点 旋转角度, 旋转到的下标位置
function calculate_angle(node, level)
    if not node or not level then
        print("ERROR: dragon_turntable.calculate_angle() node:",node,"level:",level)
        print(debug.traceback())
        return nil
    end
    local config = rateInLevel[level]
    local rates = config.rates -- 倍率表
    local iscenter = config.iscenter
    local angle_unit = 360/#rates -- 单位角度
    local turns = config.turns
    local target_angel 
    local index 
    for i = 1, #rates do
        if rates[i] == node.rate then
            target_angel = i*angle_unit
            index = i
            break
        end 
    end
    local i = math.random(8)
    while not target_angel do
        if rates[i] == 0 then
            target_angel = i*angle_unit
            index = i
            break
        end
        i = i+1 > 8 and 1 or i+1
    end
    if not iscenter then
        target_angel = target_angel - angle_unit/2
    end
    local f = math.random(2,8)/10
    return math.floor(target_angel- angle_unit*f) + turns*360, index
end