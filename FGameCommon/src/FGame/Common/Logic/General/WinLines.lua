--  local WinLines = require("FGame.Common.Logic.General.WinLines") -- 引用
--  self.winLines = WinLines.New(slot:GetChild("ReelContainer"),FConfig.WinLineConfigs.lua.Line88) -- 初始化 88 线 配置在 WinLineConfigs配置
--  self.winLines:ShowLine(lineIndex) -- 显示 某条线
--  self.winLines:HideLine()    -- 隐藏线
--  self.winLines:BlinkLine(lineIndex)    -- 某条线闪烁
--  self.winLines:StopBlinkLine()    -- 停止闪烁线（关闭定时器）
--  self.winLines::Delete() -- 释放
local WinLines = Class("WinLines")
function WinLines:ctor(parent, lineConfig,no_head,no_tail,cfg)
    self.lines = {}
    self.is_no_head = no_head
    self.is_no_tail = no_tail
    self._reelCfg = cfg
    for lineIndex, cfg in ipairs(lineConfig) do
        self:CreateLine(cfg, lineIndex)
    end
    self.parent = parent
    self.linePanel = FairyGUI.GComponent()
    self.linePanel.width = parent.width
    self.linePanel.height = parent.height
    parent:AddChild(self.linePanel)
    self:InitUI()
end

function WinLines:__delete()
    self:StopTimer()
    self:HideLine()
    self.lines = {}
    self.lineNodes = {}
end

-- 0  slots_line_flat
-- 1  slots_line_short_down
-- 2  slots_line_long_down
-- -1 slots_line_short_up
-- -2 slots_line_long_up
-- 1 -1  用角
function WinLines:CreateLine(cfg, lineIndex)
    local line = cfg.line
    local color = cfg.color
    local reelCfg = self._reelCfg or FCasinoCtx.gameCfg.Reel
    local xNum = reelCfg.xCellNumber + 1     -- 6
    local yNum = 2 * reelCfg.yCellNumber - 1 --  5
    local ret = {}
    for i = 1, xNum do
        local v = line[i] or line[i - 1]
        local type = 0
        if 1 == i or i == xNum then
            type = 0
        else
            type = v - line[i - 1]
        end
        local yIndex = v * 2 - type -- 对应的当前行数
        table.insert(ret, { pos = yIndex * xNum + i, type = type, color = color })
    end
    self.lines[lineIndex] = ret
end

function WinLines:InitUI()
    local reelCfg = self._reelCfg or FCasinoCtx.gameCfg.Reel
    local xNum = reelCfg.xCellNumber + 1     -- 6
    local yNum = 2 * reelCfg.yCellNumber - 1 -- 3 * 2 - 1 -- 5

    local realwidth = reelCfg._Width or reelCfg.reelWidth
    local realHeight = reelCfg._Height or reelCfg.reelHeight
    local realSpace = reelCfg._Space or reelCfg.reelSpace

    self.lineNodes = {}
    local xOffect = realwidth + realSpace
    local yOffect = realHeight / (yNum + 1)
    for i = 1, yNum do
        for j = 1, xNum do
            local line = FairyGUI.UIPackage.CreateObject("Basics", "Line")
            line.x = (j - 1) * xOffect
            line.y = i * yOffect
            line:SetPivot(0.5, 0.5, true)
            self.linePanel:AddChild(line)
            line.name = "line"
            line.visible = false
            local head = line:GetChild("head")
            head.visible = (not self.is_no_head) and (j == 1)
            local tail = line:GetChild("tail")
            tail.visible = (not self.is_no_tail) and (j == xNum)
            local headText = line:GetChild("headText")
            headText.visible = (not self.is_no_head) and (j == 1)
            local tailText = line:GetChild("tailText")
            tailText.visible = (not self.is_no_tail) and j == xNum
            local body = line:GetChild("body")
            if self.is_no_head or  self.is_no_tail then
                body.visible = not (j == 1 or j == xNum)
            end
            table.insert(
                    self.lineNodes,
                    {
                        line = line,
                        head = head,
                        tail = tail,
                        headText = headText,
                        tailText = tailText,
                        body = body
                    }
            )
        end
    end
end

function WinLines:HideLine()
    for _, body in ipairs(self.lineNodes) do
        body.line.visible = false
    end
end

function WinLines:ShowLine(lineIndex)
    local line = self.lines[lineIndex]
    self:HideLine()
    for i, cell in ipairs(line) do
        local nodeTabs = self.lineNodes[cell.pos]
        nodeTabs.headText.text = lineIndex
        nodeTabs.tailText.text = lineIndex
        nodeTabs.body.url = FConfig.WinLineConfigs.Type2Url[cell.type]
        local color = self:_color(cell.color)
        color = APIGateway.color4(color)
        nodeTabs.head.color = color
        nodeTabs.tail.color = color
        nodeTabs.body.color = color

        nodeTabs.line.visible = true
    end
end

function WinLines:_color(obj)
    if type(obj) == "string" then
        if obj == nil or obj == "" then
            return { r = 0, g = 0, b = 0, a = 0 }
        end
        local r = tonumber("0x" .. string.sub(obj, 2, 3))
        local g = tonumber("0x" .. string.sub(obj, 4, 5))
        local b = tonumber("0x" .. string.sub(obj, 6, 7))
        local a = 255
        if #obj >= 9 then
            a = tonumber("0x" .. string.sub(obj, 8, 9))
        end

        return { r = r, g = g, b = b, a = a }
    end
    return { r = obj[1], g = obj[2], b = obj[3], a = 255 }
end

-- timer: 定时器 时间 默认0.5 ,完整一次显示隐藏 时间是0.5* 2
function WinLines:BlinkLine(lineIndex, timer)
    timer = timer or 0.5
    -- print("BlinkLine :",lineIndex)
    self:StopTimer()
    self:ShowLine(lineIndex)
    local visible = true
    self.timer = StartTimer(function()
        visible = not visible
        if visible then
            self:ShowLine(lineIndex)
        else
            self:HideLine()
        end
    end, timer)
end

function WinLines:StopBlinkLine()
    self:StopTimer()
    self:HideLine()
end

function WinLines:StopTimer()
    if self.timer then
        StopTimer(self.timer)
    end
end

return WinLines
