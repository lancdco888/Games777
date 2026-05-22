local Tips = Class("Tips")
local TipsConfig = Import(".TipsConfig")
local MusicCfg = Import(".MusicCfg")
function Tips:ctor(render)
    self.render = render
    self.render.visible = false
    self.num_number = 0
    self:InitUI()
end

function Tips:__delete()
    if self.timer then
        StopTimer(self.timer)
        self.timer = nil
    end
    if self.turnsAddTimer then
        StopTimer(self.turnsAddTimer)
        self.turnsAddTimer = nil
    end
end

function Tips:InitUI()
    self.bg = self.render:GetChild("bg")
    self.text = self.render:GetChild("text")
    self.boom = self.render:GetChild("boom")
    self.boom.visible = false

    -- 落地牌使用
    self.num = self.render:GetChild("num")
    self.num.visible = false

    self.boom1 = self.render:GetChild("boom1")
    self.boom2 = self.render:GetChild("boom2")
    self.boom1.visible = false
    self.boom2.visible = false

    --
    -- 免费使用
    self.curturn = self.render:GetChild("curturn")
    self.curturn.visible = false

    self.allturns = self.render:GetChild("allturns")
    self.allturns.visible = false
    self.freePosX = 600
    self.freeScale = vec2(0.7, 0.7)
end

-- imageUrl:提示文本的url
-- curturn：免费游戏的当前轮次
-- allturns：免费游戏的总轮次
-- oldturns: 免费游戏总轮次叠加的起始轮次
function Tips:ShowTips(imageUrl, curturn, allturns, oldturns)
    self.boom1.visible = false
    self.boom2.visible = false
    self.boom.visible = false
    if self.timer then
        StopTimer(self.timer)
        self.timer = nil
    end

    if not imageUrl then
        return
    end
    local cfg = TipsConfig[imageUrl]
    if cfg then
        self.render.visible = true
        self.text.url = cfg.url
        if cfg.animation then
            self:PlayBoom()
        end
        self.num.visible = cfg.showNum
        if cfg.showNum then
            self.num_number = 0
            self.num.text = self.num_number
        end
        if cfg.scale then
            self.text.scale = cfg.scale
        else
            self.text.scale = vec2(1, 1)
        end
        if cfg.freePosX then
            self.text.x = cfg.freePosX
        else
            self.text.x = 640
        end
        if curturn then
            self.curturn.text = curturn
            self.curturn.visible = true
        else
            self.curturn.visible = false
        end
        if oldturns then
            self.allturns.visible = true
            self:RunTurnsAddAnim(oldturns, allturns)
        else
            if allturns then
                self.allturns.text = allturns
                self.allturns.visible = true
            else
                self.allturns.visible = false
            end
        end
        if cfg.music then
            FToolSet.PlayFGUISound(MusicCfg[cfg.music])
        end
    end
end

function Tips:HideTips()
    self:StopWinDoubleBoom()
    self.render.visible = false
    self.boom1.visible = false
    self.boom2.visible = false
    self.boom.visible = false
end

function Tips:PlayBoom()
    self.boom.visible = true
    self.render:GetTransition("boom"):Play(function()
        self.boom.visible = false
    end)
end

function Tips:PlayTopAnim(cb, num)
    if cb then
        cb()
    end
    self.num_number = self.num_number + num
    self.num.text = self.num_number
end

function Tips:updateNumber()
    self.num.text = self.num_number
end

function Tips:PlayWinDoubleBoom()
    self.boom1.visible = true
    self.boom2.visible = true

    self.render:GetTransition("boom1"):Play(function()
        self.timer = StartOnceTimer(function()
            self:PlayWinDoubleBoom()
            self.timer = nil
        end, 1.5)
    end)
end

function Tips:StopWinDoubleBoom()
    self.boom1.visible = false
    self.boom2.visible = false
end

function Tips:RunTurnsAddAnim(startTurn, endTurn)
    self.turnsAddTimer = StartTimer(
            function()
                self.allturns.text = startTurn
                startTurn = startTurn + 1
                if startTurn > endTurn then
                    StopTimer(self.turnsAddTimer)
                    self.turnsAddTimer = nil
                end
            end
    , 0.1)
end

return Tips
