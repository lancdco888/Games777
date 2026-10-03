

-- 对应Ts逻辑：
-- common\script\network\h5\network-data-h5.ts

local DataDecoder = {}

function DataDecoder:parseData(requestData, responseData)
    if requestData.func == "FreeSpinType" then
        responseData._typeid_ = requestData.context.free_type
    end

    responseData._h5MsgName_ = requestData._h5MsgName_
    responseData._h5Func_ = requestData.func

    -- 转换为creator所需结构
    local createrData = {
        getOriginJsonString = function()
            return Crypto.encodeJson(responseData)
        end
    }

    return createrData
end

return DataDecoder
