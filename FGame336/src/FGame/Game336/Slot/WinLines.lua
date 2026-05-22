local WinLines = Class("WinLines")
function WinLines:ctor(parent)
    self.parent = parent
    self.showLine = 0
    self:InitUI()
end

function WinLines:__delete()
    if self.timer then
        StopTimer(self.timer)
        self.timer = nil
    end
end

function WinLines:InitUI()
    self.lines = {}
    for i = 1, 25 do
        local winlineparent = self.parent:GetChild("lineHead"..i)
        table.insert(self.lines,winlineparent)
    end

    for _, line in ipairs(self.lines) do
        line.visible = false
    end
end

function WinLines:ShowLine(id)
    if self.showLine == id then
        return
    end
    if self.showLine ~= 0 then
        self.lines[self.showLine].visible = false
    end
    self.lines[id].visible = true
    self.showLine = id
end

function WinLines:HideLine(id)
    if self.showLine == id then
        self.lines[id].visible = false
        self.showLine = 0
    end
end

-- index , sound 
function WinLines:PlayLine(tab)
    local id = tab.index
    local sound = tab.sound
    if self.showLine ~= 0 then
        self:StopLine(self.showLine)
    end
    -- Blink 动画
    local visible = true
    self:ShowLine(id)
    self.timer = StartTimer(
        function ()
            visible = not visible
            if visible then
                self:ShowLine(id)
            else
                self:HideLine(id)
            end
        end
    , 0.5)
end

function WinLines:StopLine(id)
    self:HideLine(id)
    if self.timer then
        StopTimer(self.timer)
        self.timer = nil
    end
end

return WinLines