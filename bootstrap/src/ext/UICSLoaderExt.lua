local CSLoader = cc.CSLoader

local create_node_func = cc.CSLoader.createNode
local fileUtils = cc.FileUtils:getInstance()
function CSLoader:createNode(path)
    if not fileUtils:isFileExist(path) then
        print("CSLoader:createNode file not found:", path)
        return
    end
    return create_node_func(self, path)
end
