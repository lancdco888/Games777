local WinLines          = Class("WinLines")
local WinLineConfigs    = Import("..Cfgs.WinLineConfigs")
local WinLinesInfo      = require("FGame.Common.Logic.General.WinLines")
local SymbolCfg         = Import(".SymbolConfig")
local Tools             = Import(".Tools")
function WinLines:ctor(game,cfg)
    self.game = game
    self.WinLinesInfo = WinLinesInfo.New(game.game_node:GetChild("WinLines"), WinLineConfigs.Lines,true,true,cfg)
    self.showLine = 0
    self.index = 0
    self.wincoin = 0
    self.play_anim_time = 2
    self:InitUI()
end

function WinLines:__delete()
    self.WinLinesInfo:Delete()
    if self.timer then
        StopTimer(self.timer)
        self.timer = nil
    end
end

function WinLines:InitUI()
    self.lines = {}
end

--设置中奖线的节点
function WinLines:SetShowIndexAndCell(index,cell)
    if type(self.lines[index]) ~= "table" then
        self.lines[index] = {}
    end
    table.insert(self.lines[index],cell)
end

function WinLines:ShowLine()
    if self.showLine == 0 then
        return
    end
    local line_node = self.lines[self.showLine]
    local lenth = #line_node
    for k, node in ipairs(line_node) do
        local render = node.render_list[1]
        local node_ = render:GetChild("node")
        local real_render = render
        --3x7格子用的node作为主节点
        if node_ then
            real_render = node_
        end
        local cfg = node.upcfg
        if cfg.isplist then
            if cfg.animation then
                local anim_name = cfg.animation
                local anim = real_render:GetChild(anim_name)
                Tools.AnimNodeSet(anim,true)
                anim:SetPlaySettings(0,-1,0,-1,function ()
                end)
            end
        else
            if cfg.animation_n then
                real_render:GetTransition(cfg.animation_n):Play(1,0,function ()
                end)
            end
            if cfg.animation then
                real_render:GetTransition(cfg.animation):Play(1,0,function ()
                end)
            end
            if cfg.free_animation then
                real_render:GetTransition(cfg.free_animation):Play(1,0,function ()
                end)
            end
        end
    end
    self.WinLinesInfo:BlinkLine(self.showLine)
    self.timer = StartOnceTimer(function ()
        self:StopLine()
        self:PlayLine()
    end,self.play_anim_time)
end

-- 设置需要播放的线表
function WinLines:SetAllLine(list)
    self.all_lines = list
    self.index = 0
end

-- index , sound 
function WinLines:PlayLine()
    self.index = self.index + 1
    if self.index > #self.all_lines then
        self.index = 1
    end
    self.showLine = self.all_lines[self.index].lineIndex
    self.wincoin = self.all_lines[self.index].winCoin
    self:ShowLine()
end

--停止当前播放线计时也停止
function WinLines:StopLine()
    if self.showLine == 0 then
        return
    end
    local line_node = self.lines[self.showLine]
    for _, node in ipairs(line_node) do
        local render = node.render_list[1]
        local node_ = render:GetChild("node")
        local real_render = render
        --3x7格子用的node作为主节点
        if node_ then
            real_render = node_
        end
        local cfg = node.upcfg
        if cfg.isplist then
            local anim_name = ""
            if cfg.animation then
                anim_name = cfg.animation
                local anim = real_render:GetChild(anim_name)
                Tools.AnimNodeStop(anim)
            end
        else
            if cfg.animation_n then
                real_render:GetTransition(cfg.animation_n):Stop()
            end
        end
    end
    self.WinLinesInfo:StopBlinkLine()
    self.showLine = 0
    self.wincoin = 0
    if self.timer then
        StopTimer(self.timer)
        self.timer = nil
    end
end

--清除数据
function WinLines:ClearDatas()
    self:StopLine()
    self.all_lines = {}
    for index, line in pairs(self.lines) do
        self.lines[index] = {}
    end
    self.index = 0
end

return WinLines