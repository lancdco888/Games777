-- 老虎机免费游戏，三个格子一组转动 继承普通游戏 主要逻辑在普通游戏

local NormalSlot = Import(".NormalSlot")
local FreeSlot = Class("FreeSlot", NormalSlot)

function FreeSlot:ctor(parent, game)
end

function FreeSlot:__delete()
end

-- 游戏开始之前重置参数
function FreeSlot:ResetDatas(curturn, allturns, totalWinCoin)
    self.curturn = curturn or 0
    self.allturns = allturns or 6
    self.totalWinCoin = totalWinCoin or 0
    self:RemoveTopSymbol()
end

function FreeSlot:GetCurTurn()
    return self.curturn == 0 and 1 or self.curturn 
end

function FreeSlot:GetAllTurns()
    return self.allturns
end

function FreeSlot:SetAllTurns(allturns)
    if self.allturns == allturns then
        return
    end
    self.allturns = allturns
    self.game:RefreshFreeGameCounter()
end

-- @brief 滚动开始
function FreeSlot:SpinStart()
    FreeSlot.super.SpinStart(self)
    self.curturn = self.curturn + 1
    -- self.game:SetMidTips("freecount", self.curturn, self.allturns)
    self.game:RefreshFreeGameCounter()
end

function FreeSlot:HandleWinDatas(lines)
    FreeSlot.super.HandleWinDatas(self, lines)
    self.totalWinCoin = self.totalWinCoin + self.winCoin
    print("FreeSlot:SetSelf.totalWinCoin>>>>>>"..tostring(self.totalWinCoin))
end

function FreeSlot:SetOpen(isOpen)
    FreeSlot.super.SetOpen(self, isOpen)
end

function FreeSlot:GetWinCoin()
    print("FreeSlot:GetWinCoin>>>>>>>>>"..tostring(self.totalWinCoin))
    return self.totalWinCoin
end

return FreeSlot
