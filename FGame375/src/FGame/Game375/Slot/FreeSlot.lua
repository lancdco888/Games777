-- 老虎机免费游戏，三个格子一组转动 继承普通游戏 主要逻辑在普通游戏
local NormalSlot        = Import(".NormalSlot")
local FreeSlot          = Class("FreeSlot", NormalSlot)

function FreeSlot:ctor(parent,game)
    self.curturn = 0
    self.allturns = 0
    self.totalWinCoin = 0
    self.free_spin_node = game.render:GetChild("free_spin_number")
end

function FreeSlot:__delete()
end

-- 游戏开始之前重置参数
function FreeSlot:ResetDatas(curturn, allturns, totalWinCoin,needResetState)
    self.curturn = curturn or 0
    self.allturns = allturns or 0
    self.totalWinCoin = totalWinCoin or 0
    if needResetState then
        self:ResetState()
    end
end

--当前免费轮数
function FreeSlot:GetCurTurn()
    return self.curturn
end

--总免费次数
function FreeSlot:GetAllTurns()
    return self.allturns
end

-- @brief 滚动开始
function FreeSlot:SpinStart()
    FreeSlot.super.SpinStart(self)
    self.curturn = self.curturn + 1
    self:ShowFreeCount()
end

function FreeSlot:HandleWinDatas(lines,isReconnect)
    FreeSlot.super.HandleWinDatas(self,lines,isReconnect)
    self.totalWinCoin = self.totalWinCoin + self.winCoin
end

--12x3奖励被排除在外，结束时需要重新加入
function FreeSlot:AddWinCoin(addwin)
    self.totalWinCoin = self.totalWinCoin + addwin
end

function FreeSlot:SetOpen(isOpen)
    FreeSlot.super.SetOpen(self,isOpen)
end

--免费次数显示
function FreeSlot:ShowFreeCount(now_count,all_count)
    local now_text =  self.game.render:GetChild("cur_number")
    now_text.text = now_count or self.curturn
    local all_text =  self.game.render:GetChild("all_number")
    all_text.text = all_count or self.allturns
end

function FreeSlot:GetWinCoin()
    return self.totalWinCoin
end
return FreeSlot