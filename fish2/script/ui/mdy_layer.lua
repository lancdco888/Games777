module("mdy_layer", package.seeall)

local choose_score = 0
local choose_ratio = 0
local on_choose_done = nil
local last_bg_music = ""

function pop(score, ratio, on_done_)
    choose_score = score * ratio / FF_G.ExchangeRate
    choose_ratio = 1
    on_choose_done = on_done_
    start_animation()

    last_bg_music = FF_G.rootTable.currentBgName
    FF_G.PlayBgMusic("OneOutOfSix_BG", true)
    FF_G.playEffect("PK_game_start")

    local parent = check_ui_root()
    parent:runAction(cc.Sequence:create(
        cc.DelayTime:create(1.5),
        cc.CallFunc:create(function()
            FF_G.playEffect("MiniGame_Declare")
        end)
    ))
end

-- 开始 疯狂六选一动画
function start_animation()
    local eft = make_effect()
    local parent = check_ui_root()
    parent:addChild(eft)
end

function make_effect()
    local eft = sp.SkeletonAnimation:createWithBinaryFile("ui/cat/fish_cat_6add1.skel", "ui/cat/fish_cat_6add1.atlas")
	eft:setAnchorPoint(cc.p(0.5, 0.5))
	eft:setOpacityModifyRGB(false)
	eft:setAnimation(0, "fish_cat_6add1_en", false)
    eft:registerSpineEventHandler(function(obj)
        -- 移除该动画
        eft:runAction(
            cc.RemoveSelf:create()
        )
        on_animation_done()
    end, 3)
	return eft
end

-- 疯狂六选一动画 播放完毕
function on_animation_done()
    require("script.ui.mdy_choose_layer")
    local parent = check_ui_root()
    local choose_layer = mdy_choose_layer.pop(choose_score, choose_ratio, parent)
    choose_layer.onExit = function()
        FF_G.PlayBgMusic(last_bg_music, true)
        if on_choose_done then
            on_choose_done()
        else
            print("*************** no choose done handler! ***************")
        end
    end
end
