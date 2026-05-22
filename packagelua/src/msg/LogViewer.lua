local LogViewer = class("LogViewer")

function LogViewer:ctor(list, item)
    self.list = list
    self.item = item

    local log_path = get_log_path()
    self:LoadLogFile(log_path)
end

function  LogViewer:LoadFileChunks(log_path)
    local chunks = {}
    local buffer = {}
    local count = 0

    for line in io.lines(log_path) do
        table.insert(buffer, line)
        count = count + 1
        if count >= 100 then
            table.insert(chunks, table.concat(buffer, "\n"))
            buffer = {}
            count = 0
        end
    end

    -- 把剩下不足 40 行的也加上
    if #buffer > 0 then
        table.insert(chunks, table.concat(buffer, "\n"))
    end

    return chunks
end

function LogViewer:LoadLogFile(log_path)
    local chunks = self:LoadFileChunks(log_path)
    local list = self.list
    local listWidth = list:getContentSize().width

    -- for _, chunk in ipairs(chunks) do
    for i=8,0,-1 do
        local chunk = chunks[#chunks - i]
        if chunk then
            local newitem = self.item:clone()
            newitem:setVisible(true)
            newitem:setString(chunk)
            newitem:setTextAreaSize(cc.size(listWidth, 0))

            local renderer = newitem:getVirtualRenderer()
            local realSize = renderer:getContentSize()
            newitem:setContentSize(cc.size(listWidth, realSize.height))
            list:pushBackCustomItem(newitem)
        end
    end

    list:jumpToBottom()
end

return LogViewer
