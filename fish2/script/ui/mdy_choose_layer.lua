module("mdy_choose_layer", package.seeall)

local layer = nil       -- 主界面
local round = 1         -- 当前轮次
local total_round = 6
local score = 0         -- 能获得的总分
local gold = 0          -- 玩家当前的金币
local ratio = 1         -- 比例
local awards = {}       -- 玩家每一轮实际可获得的金币
local timeout = 8

local ui = {            -- 界面相关
    shells = {},         -- 所有贝壳

    gold = nil,           -- 当前金币
    clock = nil,          -- 倒计时
    round = nil,          -- 剩余轮数

    tips = nil        -- 开局前弹出的提示，选中毒蛇结束游戏
}

function pop(score_, ratio_, parent)
    score = score_
    ratio = ratio_
    layer = cc.CSLoader:createNode("csb/MdyChooseLayer.csb")
    pop_layer(layer, parent)
    init(score)

    -- 弹出选中 毒蛇 结束游戏提示
    play_tips_ani()
    
    set_timeout(3.0, function() check() end)
    return layer
end

function init(score)
    round = 0
    gold = 0
    init_ui()

    total_round = math.random(3, 6)

    awards = make_awards(score, total_round)
end

function check()
    if #awards == 0 then
        over()
        return
    end
    choose()
end

function choose()
    local coin = awards[1]

    FF_G.playEffect("OneOutOfSix_AddRound")
    FF_G.playEffect("OneOutOfSix_ShellClose")

    round = round + 1
    ui.round:setString(tostring(round-1))
    for _,shell in ipairs(ui.shells) do
        shell:setVisible(true)
        shell:close_shell()
    end

    timeout = 8             --最大超时
    ui.clock:setString(tostring(timeout))
    set_timeout(1, on_time_tick)
end

-- 选中某个贝壳，可能是超时自动选中，或者玩家手动选择
function selected(index)
    for _, item in ipairs(ui.shells) do
        item.closed:setTouchEnabled(false)
    end

    FF_G.playEffect("OneOutOfSix_ShellOpen")

    local coin = table.remove(awards, 1)      -- 该轮的预定值
    local board = make_board(coin, index)

    local sel_shell = ui.shells[index]
    pos = sel_shell:convertToWorldSpaceAR(cc.p(0, 0))
    pos = layer:convertToNodeSpace(pos)

    layer:runAction(cc.Sequence:create(
        cc.CallFunc:create(function()
            play_finger_ani(pos)
        end),
        cc.DelayTime:create(0.5),
        
        -- 贝壳反馈动画
        cc.CallFunc:create(
            function()
                sel_shell:play_sel_ani()
            end
        ),
        cc.DelayTime:create(0.2),

        -- 展示被选中的贝壳
        cc.CallFunc:create(
            function()
                sel_shell:show_with_coin(coin, true)
                if coin ~= 0 then
                    play_lizi_ani(pos, 0.7)    -- XXX
                    FF_G.playEffect("OneOutOfSix_GetCoin")
                else
                    FF_G.playEffect("OneOutOfSix_GetSnake")
                end
            end
        ),
        cc.DelayTime:create(0.7),    -- XXX

        cc.CallFunc:create(function()
            -- 金币增加效果
            gold = gold + coin * ratio
            -- ui.gold:setString(Tools.CoinToShowString(gold)
            ui.gold:setString(gold)
        end),
        cc.DelayTime:create(0.8),    -- XXX

        -- 展示其余贝壳
        cc.CallFunc:create(function()
            for i=1,#ui.shells do
                if i ~= index then
                    local shell = ui.shells[i]
                    shell:show_with_coin(board[i], false)
                    if board[i] ~= 0 then
                        local delay = 0.1*i
                        shell:play_show_ani(delay)
                    end
                end
            end
            FF_G.playEffect("OneOutOfSix_ShellOpen")
        end),
        cc.DelayTime:create(1.8),    -- XXX

        cc.CallFunc:create(function()
            check()
        end)
    ))
end

-- 所有选择完成
function over()
    layer:runAction(
        cc.Sequence:create(
            cc.CallFunc:create(function()
                FF_G.playEffect("PK_game_end")
                play_end_ani()
            end),
            cc.DelayTime:create(1.4),

            cc.CallFunc:create(function()
                if layer.onExit then
                    layer.onExit()
                end
                close_layer(layer)
                layer = nil
            end)
        )
    )
end

function calc_times_score(score, round)
    local times = 1
    while score % 10 == 0 do
        score = score / 10
        times = times * 10
    end

    if score <= round * 6 then
        score = score * 10
        times = times / 10
    end
    return times, score
end

---------------------------------------------------------
-- 按照轮次拆分 score
function make_awards(score, round)
    local times, score = calc_times_score(score, round)
    local mean = math.floor(score/round)
    local rest = score - mean * round
    local ret = {}
    for i=1,round do
        table.insert(ret, mean)
    end
    ret[#ret] = ret[#ret] + rest

    -- 随机分布下
    for i=1,round do
        local id = math.random(1, round)
        if id == i then id = i + 1 end
        if id > round then id = 1 end
        local exchange = math.random(0, math.floor(ret[id])-1)
        ret[i] = ret[i] + exchange
        ret[id] = ret[id] - exchange
    end

    -- 毒蛇
    table.insert(ret, 0)
    dump(ret, " ########## ret ########### ")

    for i,num in ipairs(ret) do
        ret[i] = ret[i] * times
    end

    return ret
end

local mdy_shell = require("script.ui.mdy_shell")
function init_ui()
    ui.shells = {}
    for i=1,6 do
        local shell = mdy_shell:new():hide()
        shell:addTo(layer:findChild("shell_" .. tostring(i))):close_shell()
        shell.on_shell_clicked = function()
            on_shell_clicked(i)
        end
        table.insert(ui.shells, shell)
    end
    
    ui.clock = layer:findChild("clock")
    ui.clock:setString("0")
    ui.gold = layer:findChild("gold")
    ui.gold_bg = layer:findChild("gold_bg")
    ui.round = layer:findChild("round")
    ui.round:setString("0")
    -- ui.gold:setString(Tools.CoinToShowString(gold))
    ui.gold:setString(gold)
    ui.tips = layer:findChild("tips"):hide()

    -- 设置背景铺满
    local bg = layer:findChild("bg")
    adjust_bg(bg)
end

function on_shell_clicked(index)
    stop_timers()

    selected(index)
end

-- 根据 coin 的上下浮动生成棋盘
-- index 的值需要为 coin
function make_board(coin, index)
    -- 随机生成毒蛇数目
    local snake_cnt
    do
        local snake_cnt_map = {
            [1] = 0.04,
            [2] = 0.13,
            [3] = 0.35,
            [4] = 0.37,
            [5] = 0.11
        }
        local rand = math.random(1, 100) / 100.0
        local rate = 0.0
        for i,v in ipairs(snake_cnt_map) do
            rate = rate + v
            if rand < rate then
                snake_cnt = i
                break
            end
        end
        snake_cnt = snake_cnt or 1
        -- 将玩家的毒蛇也计算在内, 避免出现6毒蛇的情况
        if coin == 0 then
            snake_cnt = snake_cnt - 1
        end
    end

    local times, scrore_tmp = calc_times_score(score, total_round)
    local mean = math.floor(scrore_tmp/total_round)

    if coin == 0 then coin = mean end
    local board = {}
    do
        -- 插入所有毒蛇
        for i=1,snake_cnt do
            table.insert(board, 0)
        end
        -- 剩余位置插入随机值
        for i=#board+1, 6 do
            local value = math.random(
                1,
                math.floor(mean * 1.5)
            )
            value = math.floor(value) * times
            table.insert(board, value)
        end
        -- 洗牌
        board = shuffle(board)
        -- 插入选中的数字
        table.insert(board, index, coin)
    end

    return board
end

function shuffle(t)
    local new_t = {}
    while #t ~= 0 do
        local index = math.random(1, #t)
        local v = table.remove(t, index)
        table.insert(new_t, v)
    end
    dump(new_t)
    return new_t
end

function set_timeout(sec, handler)
    layer:runAction(cc.Sequence:create(
        cc.DelayTime:create(sec),
        cc.CallFunc:create(handler)
    ))
end

function stop_timers()
    layer:stopAllActions()
end

function on_time_tick()
    timeout = timeout - 1
    if timeout <= 0 then
        timeout = 0
    end
    ui.clock:setString(tostring(timeout))
    if timeout == 3 then
        FF_G.playEffect("OneOutOfSix_Countdown")
    end
    if timeout == 0 then
        -- 超时，自动选择第一个
        selected(1)
    else
        -- 其他情况继续定时器
        set_timeout(1, on_time_tick)
    end
end

-----------------------------------------------------------------------------------
-- 弹出提示
function play_tips_ani()
    if not ui.tips then
        print("无提示节点.")
        return
    end
    ui.tips:setScale(0)
    ui.tips:runAction(cc.Sequence:create(
        cc.Show:create(),
        cc.DelayTime:create(0.5),       --等待弹窗完成
        cc.ScaleTo:create(0.2, 1.08),
        cc.ScaleTo:create(0.05, 1.0),
        cc.DelayTime:create(1.5),       --展示时间
        cc.Spawn:create(
            cc.ScaleTo:create(0.05, 0),
            cc.FadeOut:create(0.05)
        ),
        cc.Hide:create(),
        cc.CallFunc:create(play_start_ani)   -- 开始动画
    ))
end

function play_finger_ani(pos, on_done)
    local finger = layer:findChild("finger")
    local icon1 = finger:findChild("1"):hide()
    local icon2 = finger:findChild("2"):hide()
    finger:setPosition(pos)
    finger:runAction(cc.Sequence:create(
        cc.Show:create(),
        cc.CallFunc:create(function()
            icon1:setVisible(true)
            icon2:setVisible(false)
        end),
        cc.DelayTime:create(0.15),
        cc.CallFunc:create(function()
            icon1:setVisible(false)
            icon2:setVisible(true)
        end),
        cc.DelayTime:create(0.15),
        cc.Hide:create(),
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(
            function()
                if on_done then
                    on_done()
                end
            end
        )
    ))
end

-- 播放粒子动画
function play_lizi_ani(pos, sec)
    local node = cc.Node:create()
    node:setPosition(pos)
    layer:addChild(node)
    node:setOpacity(0)

    local mypat = cc.ParticleSystemQuad:create("game/mdy/maodaye_lizi_01.plist")
    node:addChild(mypat)
    mypat:setScale(2.5)
    
    local dst = ui.gold_bg:getParent():convertToWorldSpace(cc.p(ui.gold_bg:getPosition()))
    dst = layer:convertToNodeSpace(dst)

    local end_move = function()
        local node = cc.Node:create()
        layer:addChild(node)
        node:setPosition(dst)
        local mypat = cc.ParticleSystemQuad:create("game/mdy/maodaye_lizi_02.plist");
        mypat:setScale(1.5)
        node:addChild(mypat)
        node:runAction(cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.RemoveSelf:create(true)))
    end

    node:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.8, dst),
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(end_move),
        cc.ScaleTo:create(0.6, 0.1),
        cc.RemoveSelf:create(true)
    ))

    -- local action = cc.CSLoader:createTimeline("csb/MdyCoinLiZi.csb")
    -- local sp = cc.CSLoader:createNode("csb/MdyCoinLiZi.csb")
    -- layer:addChild(sp)
    -- sp:runAction(action)
    -- action:gotoFrameAndPlay(0, false)

    -- local dst = ui.gold_bg:getParent():convertToWorldSpace(cc.p(ui.gold_bg:getPosition()))
    -- dst = layer:convertToNodeSpace(dst)
    
    -- sp:setPosition(pos)
    -- sp:runAction(
    --     cc.Sequence:create(
    --         cc.MoveTo:create(
    --             sec-0.1,
    --             dst
    --         ),
    --         cc.FadeOut:create(0.1),
    --         cc.RemoveSelf:create()
    --     )    
    -- )
end

function play_start_ani()
    local eft = sp.SkeletonAnimation:createWithBinaryFile("ui/fish_cat_start/fish_cat_start.skel", "ui/fish_cat_start/fish_cat_start.atlas")
	eft:setAnchorPoint(cc.p(0.5, 0.5))
	eft:setOpacityModifyRGB(false)
	eft:setAnimation(0, "fish_cat_start_en", false)
    eft:registerSpineEventHandler(function(obj)
        -- 移除该动画
        eft:runAction(
            cc.RemoveSelf:create()
        )
    end, 3)
    eft:setPosition(cc.p(0, 0))
    layer:addChild(eft)
end

function play_end_ani()
    local eft = sp.SkeletonAnimation:createWithBinaryFile("ui/fish_cat_end/fish_cat_end.skel", "ui/fish_cat_end/fish_cat_end.atlas")
	eft:setAnchorPoint(cc.p(0.5, 0.5))
	eft:setOpacityModifyRGB(false)
	eft:setAnimation(0, "fish_cat_end_en", false)
    eft:registerSpineEventHandler(function(obj)
        -- 移除该动画
        eft:runAction(
            cc.RemoveSelf:create()
        )
    end, 3)
    eft:setPosition(cc.p(0, 0))
    layer:addChild(eft)
end
