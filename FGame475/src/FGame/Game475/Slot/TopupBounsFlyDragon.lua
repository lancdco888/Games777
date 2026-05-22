local TopupBounsFlyDragon = Class("TopupBounsFlyDragon")
local MusicCfg = Import(".MusicCfg")
local Utils = Import(".Utils")
function TopupBounsFlyDragon:ctor(render, caijinPanel)
    self.render = render
    self.render.visible = false
    self.anims = {}
    self.indexs = {1, 6, 11, 2, 7, 12, 3, 8, 13, 4, 9, 14, 5, 10, 15}
    self.tbIndexs = nil
    self.topupBounsSlot = nil
    self.tipsPanel = nil
    self.onFinishCallback = nil
    self.count = 0
    self:InitUI()
    self.caijinPanel = caijinPanel
end

function TopupBounsFlyDragon:__delete()
end

function TopupBounsFlyDragon:InitUI()
    for i = 1, 15 do
        local anim = self.render:GetChild(i)
        anim.playing = false
        anim.frame = 0
        anim.visible = false
        table.insert(self.anims, anim)
    end
end

function TopupBounsFlyDragon:ResetDatas(tbIndexs, topupBounsSlot, tipsPanel, cb)
    self.tbIndexs = tbIndexs
    self.topupBounsSlot = topupBounsSlot
    self.tipsPanel = tipsPanel
    self.count = 0
    self.onFinishCallback = cb
end

function TopupBounsFlyDragon:PlayFlyDragon(index, symbolType, cb)
    self.render.visible = true
    local anim = self.anims[index]
    anim.visible = true
    --从start帧开始，播放到end帧（-1表示结尾），重复times次（0表示无限循环），循环结束后，停止在endAt帧（-1表示参数end）
    anim:SetPlaySettings(
        0,
        -1,
        1,
        -1,
        function()
            anim.visible = false
            anim.playing = false
            anim.frame = 0
            if cb then
                cb()
                cb = nil
            end
            self.render.visible = false
        end
    )
    anim.playing = true

    local mini_ani = self.caijinPanel:GetChild("mini_ani")
    local major_ani = self.caijinPanel:GetChild("major_ani")
    local minor_ani = self.caijinPanel:GetChild("minor_ani")
    local grand_ani = self.caijinPanel:GetChild("grand_ani")
    mini_ani.visible = false
    minor_ani.visible = false
    major_ani.visible = false
    grand_ani.visible = false

    local jackpotAni = nil
    if symbolType == 2 then
        jackpotAni = mini_ani
    elseif symbolType == 3 then
        jackpotAni = minor_ani
    elseif symbolType == 4 then
        jackpotAni = major_ani
    elseif symbolType == 5 then
        jackpotAni = grand_ani
    end
    if jackpotAni then
        jackpotAni.visible = true
        Utils.PlayMovieClip(jackpotAni, 1, -1, 1, -1,function ()
            jackpotAni.visible = false
            jackpotAni.playing = false
            jackpotAni.frame = 0
        end)
    end
end

--tbIndexs 落地牌中奖位置
--topupBounsSlot 落地牌节点

function TopupBounsFlyDragon:Play(tbIndexs, topupBounsSlot, tipsPanel, cb)
    self:ResetDatas(tbIndexs, topupBounsSlot, tipsPanel, cb)
    self:PlayOnce()
end

function TopupBounsFlyDragon:PlayOnce()
    self.count = self.count + 1
    if self.count > 15 then
        self.count = 0
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
        end
        return
    end
    local index = self.indexs[self.count] -- -- 位置

    if self.tbIndexs[index] then -- 是否存在中奖
        local symbolType = self.tbIndexs[index].SymbolType
        if symbolType == 1 then
            local thunderSounds = {MusicCfg.Luodi_thunder1, MusicCfg.Luodi_thunder2, MusicCfg.Luodi_thunder3}
            local randomThunder = thunderSounds[math.random(#thunderSounds)]
            FToolSet.PlayFGUISound(randomThunder)
        else
            if typeVal == 2 or typeVal == 3 then 
                FToolSet.PlayFGUISound(MusicCfg.Luodi_minor_mini)
            else 
                FToolSet.PlayFGUISound(MusicCfg.Luodi_major_grand)
            end
            -- FToolSet.PlayFGUISound(MusicCfg.SND_LargePrize)
        end
        local topSymbolRender = self.topupBounsSlot.topSymbolRenders[index]
        local DragonCircle = topSymbolRender:GetChild("DragonCircle")
        DragonCircle.visible = false
        DragonCircle.playing = false
        self:PlayFlyDragon(
            index,
            symbolType,
            function()
            end
        )
        self.tipsPanel:PlayTopAnim(
            function()
                self:PlayOnce()
            end,
            self.tbIndexs[index].SymbolValue
        )
    else
        self:PlayOnce()
    end
end

return TopupBounsFlyDragon
