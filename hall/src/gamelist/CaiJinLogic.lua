local CaiJinLogic = class("CaiJinLogic")

function CaiJinLogic:ctor()
    self.game_lottery_data = nil    --上次获取到的数据
end

function CaiJinLogic:FetchData()
    local data_ = PKG_Other_Support_ReqAllLottery.Create()
    local rlt_ = gNet_SendRequest(data_)
    if rlt_ ~= nil and rlt_.lotterys and #rlt_.lotterys > 0 then
        local lotterys = rlt_.lotterys
        local game_lottery_data = {}        --客户端需要的,以gameid为key组织的数据
        for _,lottery in ipairs(lotterys) do
            for _,gameID in ipairs(lottery.gameIDs) do
                if lottery.hallShow ~= 0 then
                    local lottery_data = game_lottery_data[gameID]
                    if lottery_data == nil then
                        lottery_data = {}
                        game_lottery_data[gameID] = lottery_data
                    end
                    table.insert(lottery_data, lottery)
                end
            end
        end
        --对每一个gameid数据排序后 交给界面显示
        for gameID,lottery_data in pairs(game_lottery_data) do
            table.sort(lottery_data, function(a, b)
                return a.lType > b.lType
            end)
        end

        return game_lottery_data
    else
    end
    return nil
end

function CaiJinLogic:GetData()
    local data = self:FetchData()
    self.game_lottery_data = data
    return self.game_lottery_data
end

return CaiJinLogic
