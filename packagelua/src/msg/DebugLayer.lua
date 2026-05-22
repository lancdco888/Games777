local DebugLayer = class("DebugLayer")

function DebugLayer:ctor()
    self.last_button_y = 0

    self:InitUI()
end

function DebugLayer:InitUI()
    self.root = Tools_Base.CreateLayer("packagelua/res/studio/csb/DebugLayer.csb")
    local scale = Tools_Base.ScaleMin
    self.root:setScale(scale)
    self.Panel = self.root:getChildByName("Panel")
    self.btn_template = self.Panel:getChildByName("btn_template")
    self.btn_template:setVisible(false)
    self.last_button_y = self.btn_template:getPositionY()

    Tools_Base.AddClickEvent(self.Panel, function()
        self.root:removeFromParent()
    end, true)

    self:AddFunction("清除日志", function()
        self:OnBtnClear()
        self.list:removeAllItems()
    end)

    self:AddFunction("复制日志", function()
        self:OnBtnCopy()
    end)

    self.list = self.Panel:getChildByName("list")
    local item = self.Panel:getChildByName("item")
    item:setVisible(false)

    local LogViewer = require("packagelua.src.msg.LogViewer")
    self.logViewer = LogViewer.new(self.list, item)
end

function DebugLayer:AddFunction(title, handler)
    local btn = self.btn_template:clone()
    btn:setTitleText(title)
    btn:setVisible(true)
    btn:setPositionY(self.last_button_y)
    self.last_button_y = self.last_button_y + btn:getContentSize().height
    self.btn_template:getParent():addChild(btn)

    Tools_Base.AddClickEvent(btn, function()
        if handler then handler() end
    end, true)
end

function DebugLayer:OnBtnCopy()
    local log_file_name = get_log_path()
    local content = io.readfile(log_file_name)
    Device:CopyString(content)
end

function DebugLayer:OnBtnClear()
    local log_file_name = get_log_path()
    local f = io.open(log_file_name, "w")
    if f then
        f:close()
    else
        print("无法打开文件: " .. log_file_name)
    end
end

function DebugLayer:Show()
    cc.Director:getInstance():getRunningScene():addChild(self.root, 10000)
end

return DebugLayer
