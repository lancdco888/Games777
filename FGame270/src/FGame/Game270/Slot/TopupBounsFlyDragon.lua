local TopupBounsFlyDragon = Class("TopupBounsFlyDragon")
local MusicCfg = Import(".MusicCfg")
function TopupBounsFlyDragon:ctor(render)
    self.render = render
    self.render.visible = false
    self.anims = {}
    self.indexs = { 1, 6, 11, 2, 7, 12, 3, 8, 13, 4, 9, 14, 5, 10, 15 }
    self.tbIndexs = nil
    self.topupBounsSlot = nil
    self.tipsPanel = nil
    self.onFinishCallback = nil
    self.count = 0
    self:InitUI()
end

function TopupBounsFlyDragon:__delete()

end

function TopupBounsFlyDragon:InitUI()
    for i = 1, 15 do
        local anim = self.render:GetChild(i)
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

function TopupBounsFlyDragon:PlayFlyDragon(index)
    FTween.KillTweens(self.render)
    self.render.visible = true
    local anim = self.anims[index]
    FTween.Start(self.render,
            FTween.Delay(0.03),
            FTween.Repeat({
                FTween.Delay(0.2, function()
                    anim.visible = not anim.visible
                end),
            }, 4),
            FTween.CallFunc(function()
                local v = FToolSet.NumToStr(self.tbIndexs[index].SymbolValue)
                self.tipsPanel:PlayTopAnim(nil, v, self.tbIndexs[index].SymbolValue, index)
            end),
            FTween.CallFunc(function()
                self.render.visible = false
                anim.visible = false
                FTween.KillTweens(self.render)
                self.tipsPanel:updateNumber()
                self:PlayOnce()
            end))
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
        self.tipsPanel:PlayWinDoubleBoom()
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
        end
        return
    end
    local index = self.indexs[self.count] -- -- 位置

    if self.tbIndexs[index] then
        -- 是否存在中奖
        if self.tbIndexs[index].lottyType == 1 then
            FToolSet.PlayFGUISound(MusicCfg.SND_Small_5)
        else
            FToolSet.PlayFGUISound(MusicCfg.SND_Small_5)
        end
        self:PlayFlyDragon(index)
    else
        self:PlayOnce()
    end
end

return TopupBounsFlyDragon
