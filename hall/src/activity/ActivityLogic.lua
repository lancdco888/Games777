local ActivityLogic = class("ActivityLogic")

ActivityLogic.ACT_ID_BIND_MONEY = 2      -- 绑定金返利活动
ActivityLogic.ACT_ID_TURNTABLE = 3       -- 转盘
ActivityLogic.ACT_ID_SPREED = 200        -- 官网地址

ActivityLogic.ACT_ID_REBATE_MIN = 1001
ActivityLogic.ACT_ID_REBATE_MAX = 1999

function ActivityLogic:ctor()
    self.activity_status = {}
    self.rebate_ids = {}
    self.rebate_can_gives = {}
end

-- 从服务器更新信息 data : PKG_Lobby_Client_Enter_Success
function ActivityLogic:UpdateWhenEnterLobby(data)
    -- 活动开关集合
    self.activity_status = data.activity_status

    -- 所有 vip 福利活动 id
    self.rebate_ids = {}
    self.rebate_can_gives = {}
    self:UpdateActivityStatus()

    -- 首充开关 1=开 0=关
    self.is_open_first_rechange_washcode = data.is_open_first_rechange_washcode
    -- 首充送多少绑定金币
    self.first_rechange_washcode = data.first_rechange_washcode
    -- 首充送绑金最低档金币
    self.first_rechage_washcode_min_money = data.first_rechage_washcode_min_money

    -- 是否有资格转盘 0=没 1=有
    self.is_spin = data.is_spin
    -- 转盘值列表
    self.spin_array = data.spin_array
    -- 老玩家福利
    self.is_welfare = data.is_welfare

    Dispatcher:Dispatch(self)
end

----------------------------------------------------------------------------------------
-- 获取所有活动状态

function ActivityLogic:ReqActivityStatus()
    self:ReqStatus()
    Dispatcher:Dispatch(self)
    return true
end

function ActivityLogic:ReqStatus()
    local data_ = PKG_Client_Lobby_GetActivityInfo.Create()
    local rlt_ = gNet_SendRequest(data_)
    if rlt_ == nil then
        print("获取活动信息失败!")
        return false
    end

    if getmetatable(rlt_) == PKG_Generic_Error then
        print("获取活动信息失败!")
        return false
    end

    if getmetatable(rlt_) == PKG_Lobby_Client_ResponeActivityInfo then
        self.activity_status = rlt_.activity_status

        self.rebate_ids = {}
        self.rebate_can_gives = {}
        self:UpdateActivityStatus()
        self.is_open_first_rechange_washcode = rlt_.is_open_first_rechange_washcode
        return true
    else
        print("获取活动信息失败!")
        return false
    end
end

function ActivityLogic:GetActivityCfg(id)
    local json = require("json")
    local activity_status = self.activity_status
    for __, status in pairs(activity_status) do
        if id == status.id then
            local config = {}
            config.is_open = ( status.is_open == 1)
            if status.config ~= "" then
                local cfg = json.decode(status.config)
                for k,v in pairs(cfg) do
                    config[k] = v
                end
            else -- config == ""
            end
            return config
        end
    end
    return {}
end

-----------------------------------  首冲活动 ------------------------------------------

-- 是否打开首冲送绑定金币
function ActivityLogic:IsOpenFirstRecharge()
    return self.is_open_first_rechange_washcode == 1
end

function ActivityLogic:GetFirstRechargeInfo()
    return {
        -- 充值多少
        recharge = self.first_rechage_washcode_min_money,
        -- 赠送多少
        gift = self.first_rechange_washcode
    }
end

-----------------------------------  每日转盘  -------------------------------------------
function ActivityLogic:ReqStartSpin()
    -- 请求转盘
    local data_ = PKG_Client_Lobby_StartSpin.Create()
    local rlt_ = gNet_SendRequest(data_)
    if rlt_ == nil then
        print("请求转盘失败!")
        return false
    end

    if getmetatable(rlt_) == PKG_Generic_Error then
        print("请求转盘error失败!")
        dump(rlt_,"rlt_")
        return false
    end

    if getmetatable(rlt_) == PKG_Lobby_Client_ResponeSpinInfo then
        dump(rlt_, " *** 获取转盘奖励 *** ")
        return rlt_.give_washcode
    else
        print("请求转盘失败2!")
        return false
    end
end

-- 每日转盘配置
function ActivityLogic:GetTurntableCfg()
    local config = self:GetActivityCfg(ActivityLogic.ACT_ID_TURNTABLE)
    return {
        -- 后台配置
        config = config,
        spin_array = self.spin_array,
        is_spin = self.is_spin
    }
end

function ActivityLogic:GetTurntableVipLevel()
    local config = self:GetActivityCfg(ActivityLogic.ACT_ID_TURNTABLE)
    if not config then
        return -2       -- -1是一个合法的 vip 等级，所以这里用 -2
    end
    return config.vip
end

-- 是否打开转盘
function ActivityLogic:IsOpenTurntable()
    local config = self:GetActivityCfg(ActivityLogic.ACT_ID_TURNTABLE)
    -- local vipLevel = config.vip
    -- local myVipLevel = sGameManager.GetMyVipLevel()
    -- local ret = self.is_spin == 1 and config.is_open and ((not self.has_turn_spin) or myVipLevel >= tonumber(vipLevel))
    local ret = self.is_spin == 1 and config.is_open
    print("是否打开转盘",ret)
    return ret
end

function ActivityLogic:IsTurntablePopUp()
    local config = self:GetActivityCfg(ActivityLogic.ACT_ID_TURNTABLE)
    return config.dialog == 1
end
-----------------------------------  每日转盘 完  --------------------------------------

----------------------- 官网地址 -------------------------------

-- 是否打开官网地址
function ActivityLogic:IsScreenshotOpen()
    local config = self:GetActivityCfg(ActivityLogic.ACT_ID_SPREED)
    return config.is_open
end

function ActivityLogic:IsScreenshotPopUp()
    local config = self:GetActivityCfg(ActivityLogic.ACT_ID_SPREED)
    return config.dialog == 1
end

-- 是否有老玩家福利
function ActivityLogic:HasWelfare()
    return self.is_welfare == 1
end

function ActivityLogic:SetWelfare(bHas)
    if bHas then
        self.is_welfare = 1
    else
        self.is_welfare = 0
    end
end

----------------------- 官网地址 end-------------------------------
----------------------- 限时返利活动 -------------------------------

function ActivityLogic:UpdateActivityStatus()
    for _, status in pairs(self.activity_status) do
        local id = status.id
        if id >= self.ACT_ID_REBATE_MIN and id <= self.ACT_ID_REBATE_MAX then
            local config = self:GetActivityCfg(id)
            local type = config.activity_type
            if type == 1 or type == 2 or type == 3 then
                table.insert(self.rebate_ids, id)
            end
        end
    end
end

function ActivityLogic:ReqRebateCanGives()
    self.rebate_can_gives = {}
    local rebate_ids = self.rebate_ids
    for _,rebate_id in pairs(rebate_ids) do
        local can_give = self:GetWashCodeActivityInfoByActivityId(rebate_id)
        SleepSecs(0.5)
        self.rebate_can_gives[rebate_id] = can_give
    end
end

function ActivityLogic:GetRebateIds()
    return self.rebate_ids
end

function ActivityLogic:IsRebateOpen(id)
    local config = self:GetActivityCfg(id)
    return config.is_open
end

function ActivityLogic:IsRebatePopUp(id)
    local config = self:GetActivityCfg(id)
    return config.dialog == 1
end

function ActivityLogic:GetRebateType(id)
    local config = self:GetActivityCfg(id)
    if config.activity_type == 1 then
        return "HOUR"
    elseif config.activity_type == 2 then
        if math.fmod(config.activity_value, 7) > 0 then
            return "DAY"
        else
            return "WEEK"
        end
    elseif config.activity_type == 3 then
        return "MONTH"
    end
    return ""
end

function ActivityLogic:GetWashCodeActivityInfoByActivityId(id)
    local data_ = PKG_Client_Lobby_GetWashCodeActivityInfo.Create()
    data_.activity_id = id
    local rlt_ = gNet_SendRequest(data_)
    if rlt_ == nil then
        return false
    end
    if getmetatable(rlt_) == PKG_Generic_Error then
        return false
    end

    if getmetatable(rlt_) == PKG_Lobby_Client_ResponseWashcodeActivityInfo then
        if rlt_.activity_id == id then
            return rlt_.can_give == 1
        end
        return false
    end
    return false
end

function ActivityLogic:CanGiveByID(id)
    return self.rebate_can_gives[id]
end

function ActivityLogic:ReceiveWashcodeActivity(id)
    local data_ = PKG_Client_Lobby_ReceiveWashcodeActivity.Create()
    data_.activity_id = id
    local rlt_ = gNet_SendRequest(data_)
    if rlt_ == nil then
        return false
    end
    if getmetatable(rlt_) == PKG_Generic_Error then
        dump(rlt_,"PKG_Client_Lobby_ReceiveWashcodeActivity PKG_Generic_Error")
        UIManager.ShowMsgBox(TR("领取奖励失败"))
        return false
    end

    if getmetatable(rlt_) == PKG_Lobby_Client_ResponseReceiveWashcodeActivity then
        if rlt_.activity_id == id then
            self.rebate_can_gives[id] = false
            return true, {reward_type = rlt_.reward_type,reward_value = rlt_.reward_value}
        end
        return false
    end
    return false
end
----------------------- 限时返利活动end -----------------------------

return ActivityLogic
