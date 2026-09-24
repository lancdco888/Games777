-- 喷金币效果(已废弃 推荐使用：FountainPool)

-- 之前的扩展性太差
-- 2023-6-26 12:26:35  接口不变，统一使用 FountainPool 实现


local FountainPool = Import(".FountainPool")
---@class CoinFountain
local CoinFountain = Class("CoinFountain")

CoinFountain.Anims = {
    "ui://Basics/Ani_Clip_Gold",
    "ui://Basics/Ani_Clip_Gold2",
    "ui://Basics/Ani_Clip_Gold3",
    "ui://Basics/Ani_Clip_Gold4",--非中国风
    "ui://Basics/Ani_Clip_Gold5",--国风
}

function CoinFountain:ctor(parent)
    self.fountainPool = FountainPool.New(parent)
end

function CoinFountain:__delete()
    self:Stop()
    self.fountainPool:Delete()
end

function CoinFountain:SetSortingOrder(value)
    self.fountainPool:SetSortingOrder(value)
end

function CoinFountain:Play(musicUrl, coinAnimName)
    self:Stop()
    if musicUrl then
        self.musicHandle = FToolSet.PlayFGUISound(musicUrl)
    end

    coinAnimName = coinAnimName or CoinFountain.Anims[1]
    self.fountainPool:Play({
        {url = coinAnimName}
    })
end

function CoinFountain:Stop()
    self.fountainPool:Stop()

    if self.musicHandle then
        APIGateway.StopSound(self.musicHandle)
        self.musicHandle = nil
    end
end

return CoinFountain
