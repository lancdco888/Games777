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

    self.topAnim = self.render:GetChild("topAnim")
    self.topAnim.visible = false
    --
    -- 免费使用
    self.curturn = self.render:GetChild("curturn")
    self.curturn.visible = false

    self.allturns = self.render:GetChild("allturns")
    self.allturns.visible = false
    self.freePosX = 600
    self.freeScale = vec2(0.7,0.7)

end

-- imageUrl:提示文本的url
-- curturn：免费游戏的当前轮次
-- allturns：免费游戏的总轮次
-- oldturns: 免费游戏总轮次叠加的起始轮次
function Tips:ShowTips(imageUrl,curturn,allturns,oldturns)
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
        if cfg.winanimation  then
            self:PlayWinDoubleBoom()
        end
        self.num.visible = cfg.showNum
        if cfg.showNum then
            self.num_number = 0
            self.num.text = self.num_number
        end
        if cfg.scale then
            self.text.scale = cfg.scale
        else
            self.text.scale = vec2(1,1)
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
            self:RunTurnsAddAnim(oldturns,allturns)
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
end

function Tips:PlayBoom()
    self.boom.visible = true
    self.boom:SetPlaySettings(0,-1,1,-1,
        function ()
            self.boom.visible = false
            self.boom.playing = false
            self.boom.frame = 0
        end
    )
    self.boom.playing = true
end

function Tips:PlayTopAnim(cb, num)
    self.topAnim.visible = true
    self.topAnim.frame = 0
    self.topAnim:SetPlaySettings(0,-1,1,-1,
        function ()
            self.topAnim.visible = false
            self.topAnim.playing = false
            self.topAnim.frame = 0
            if cb then
                cb()
                cb = nil
            end
        end
    )
    self.num_number = self.num_number + num
    self.num.text = self.num_number
    self.topAnim.playing = true
end

function Tips:PlayWinDoubleBoom()
    self.boom1.visible = true
    self.boom2.visible = true
    self.boom1.frame = 0
    self.boom2.frame = 0
    self.boom:SetPlaySettings(0,-1,1,-1,
        function ()
            self.boom1.visible = false
            self.boom2.visible = false
            self.boom1.playing = false
            self.boom2.playing = false
        end
    )
    self.timer = StartOnceTimer(
        function ()
            self.timer = nil
            self:PlayWinDoubleBoom()
        end
    ,1.5)
    self.boom1.playing = true
    self.boom2.playing = true
end

function Tips:StopWinDoubleBoom()
    if self.timer then
        StopTimer(self.timer)
        self.timer = nil
    end
    self.boom1.visible = false
    self.boom2.visible = false
    self.boom1.playing = false
    self.boom2.playing = false
end

function Tips:RunTurnsAddAnim(startTurn,endTurn)
    self.turnsAddTimer = StartTimer(
        function ()
            self.allturns.text = startTurn
            startTurn = startTurn + 1
            if startTurn > endTurn then
                StopTimer(self.turnsAddTimer)
                self.turnsAddTimer = nil
            end
        end
    ,0.1)
end

return Tips