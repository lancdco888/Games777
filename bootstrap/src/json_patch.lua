local json = require("json")

if json.old_decode then
    return
end

json.old_decode = json.decode
function json.decode(str)
    local success, data_ = pcall(json.old_decode, str)
    if not success then
        return nil
    end
    return data_
end
