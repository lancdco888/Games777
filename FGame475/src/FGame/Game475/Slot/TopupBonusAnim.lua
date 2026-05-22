local TopupBonusAnim = Class("TopupBonusAnim")
local MusicCfg = Import(".MusicCfg")
function TopupBonusAnim:ctor(render)
    self.render = render
    self.render.visible = false
    self:InitUI()
end

function TopupBonusAnim:__delete()
    if self.timer1 then
        StopTimer(self.timer1)
        self.timer1 = nil
    end
    if self.timer2 then
        StopTimer(self.timer2)
        self.timer2 = nil
    end
    if self.timer3 then
        StopTimer(self.timer3)
        self.timer3 = nil
    end
end

function TopupBonusAnim:InitUI()

end

function TopupBonusAnim:PlayTopupBonusAnim(cb)
    self.render.visible = true
    self.render:GetTransition("animScale"):Play(function()
        if cb then
            cb()
            self.render.visible = false
            cb = nil
        end
    end)
    FToolSet.PlayFGUISound(MusicCfg.SND_FeatureTrigger)
    -- self.render.visible = true
    -- self:PlayFireDragon(
    --     function ()
    --         self.timer1 = StartOnceTimer(
    --             function ()
    --                 self.render:GetTransition("animScale"):Play(function()
    --                     self:PlayFireDragon(
    --                         function ()
    --                             if cb then
    --                                 cb()
    --                                 cb = nil
    --                                 self.render.visible = false
    --                             end
    --                         end
    --                     )
    --                     self.timer2 = StartOnceTimer(
    --                         function ()
    --                             self.LeftDragon.visible = false
    --                             self.RightDragon.visible = false
    --                             self.CenterCorona.visible = false
    --                             self.hs.visible = false
    --                             self.c15.visible = false

    --                             self.timer = nil
    --                         end
    --                     , 1)
    --                 end)
    --             end
    --         , 2)
    --     end
    -- )
    -- self.timer3 = StartOnceTimer(
    --     function ()
    --         self.LeftDragon.visible = true
    --         self.LeftDragon.playing = true
    --         self.RightDragon.visible = true
    --         self.RightDragon.playing = true

    --         self.CenterCorona.visible = true
    --         self.CenterCorona.playing = true
    --         self.hs.scale = vec2(1,1)
    --         self.c15.scale = vec2(0,0)
    --         self.hs.visible = true
    --         self.c15.visible = true
    --         self.timer = nil
    --     end
    -- , 1)
end

-- function TopupBonusAnim:PlayFireDragon(cb)
--     self.FireDragon.visible = true
--     --从start帧开始，播放到end帧（-1表示结尾），重复times次（0表示无限循环），循环结束后，停止在endAt帧（-1表示参数end）
--     self.FireDragon:SetPlaySettings(0,-1,1,-1,
--         function ()
--             self.FireDragon.visible = false
--             self.FireDragon.playing = false
--             self.FireDragon.frame = 0
--             if cb then
--                 cb()
--                 cb = nil
--             end
--         end
--     )
--     self.FireDragon.playing = true
-- end

return TopupBonusAnim