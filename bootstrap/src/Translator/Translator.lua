local Translator = class("Translator")

function Translator:ctor()
    self.dictianary = {}
end

-- 增加字典，字典可能是散的，由多个 映射表 组成
-- dict = {item, item, item}, item = {text='xx', translate='yy'}
function Translator:add(dict)
    for i,v in ipairs(dict) do
        self.dictianary[v.text] = v.translate
    end
end

function Translator:addFile(file_name)
	local fu = cc.FileUtils:getInstance()
	local filePath = fu:fullPathForFilename(file_name)
	local exists = fu:isFileExist(filePath)
	if not exists then
        print("file not exists:" .. file_name)
		return false
	end
    local str_ = fu:getStringFromFile(filePath)
    local json = require("json")
    local data_ = json.decode(str_) or {}
    self:add(data_)
    return true
end

-- 清除字典
function Translator:clear()
    self.dictianary = {}
end

function Translator:translate(text)
    local translate = self.dictianary[text]
    if not translate then
        return false, ""
    else
        return true, translate
    end
end

return Translator
