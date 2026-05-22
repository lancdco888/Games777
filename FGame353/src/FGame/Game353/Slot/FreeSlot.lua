-- 老虎机免费游戏，三个格子一组转动 继承普通游戏 主要逻辑在普通游戏

local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local NormalSlot = Import(".NormalSlot")
local FreeSlot = Class("FreeSlot", NormalSlot)
local MusicCfg = Import(".MusicCfg")

function FreeSlot:ctor(parent,game)
end

function FreeSlot:__delete()
end

-- 游戏开始之前重置参数
function FreeSlot:ResetDatas(curturn, allturns, totalWinCoin)
    self.curturn = curturn or 0
    self.allturns = allturns or 6
    self.totalWinCoin = totalWinCoin or 0
    self:RemoveTopSymbol()
    self.game.otherPanel:SetCount(self.curturn,self.allturns)
    --self.game.freecountPanel:enterFreeCount(self.curturn,self.allturns)
end

function FreeSlot:GetCurTurn()
    return self.curturn
end

function FreeSlot:GetAllTurns()
    return self.allturns
end

function FreeSlot:SetAllTurns(allturns)
    if self.allturns == allturns then
        return
    end
    local oldaddturns = self.allturns
    self.allturns = allturns
    -- FToolSet.PlayFGUISound(MusicCfg.feature_bell)
    -- StartOnceTimer(function ()
    --     FToolSet.PlayFGUISound(MusicCfg.SND_Scatter)
    -- end,2)
    self.game.otherPanel:SetCount(self.curturn,self.allturns)
end

-- @brief 滚动开始
function FreeSlot:SpinStart()
    FreeSlot.super.SpinStart(self)
    self.curturn = self.curturn + 1
    self.game.otherPanel:SetCount(self.curturn,self.allturns)
    self._freeGameIconType = 0
end
function FreeSlot:HandleWinDatas(lines)
    FreeSlot.super.HandleWinDatas(self,lines)
    self.totalWinCoin = self.totalWinCoin + self.winCoin
    print("计算免费中金币",self.totalWinCoin)
end

function FreeSlot:SetOpen(isOpen)
    FreeSlot.super.SetOpen(self,isOpen)
end

function FreeSlot:GetWinCoin()
    print("获取免费中金币",self.totalWinCoin)
    return self.totalWinCoin
end
function FreeSlot:SetWinCoin(winCoin)

    self.totalWinCoin = winCoin
    print("设置免费中金币",self.totalWinCoin)
end
return FreeSlot