
-- @brief 玩家金币类型定义
FPlayerMoneyType = {
    NORMAL_MONEY = 0, -- 普通金币
    BIND_MONEY   = 1, -- 绑定金币
}

-- @brief spin按钮状态定义
FSpinStatus = {
    SPIN    = 1,      -- 普通状态（此时按钮应该为spine状态）
    WAITING = 2,      -- 等待状态（此时按钮应该显示stop或auto且不可点击）
    STOP    = 3,      -- 停止状态（此时按钮应该显示stop且可以点击）
}

-- @brief 游戏模式定义
FGameMode = {
    NORMAL  = 1,      -- 普通游戏模式
    FREE    = 2,      -- 免费游戏模式
    SPECIAL = 3,      -- 落地牌游戏模式
}

-- @brief 系统事件定义
FSysEvent = {
    ON_NET_DISCONNECT = 1, -- 网络断开连接(请求超时或返回类型不是预期时会调用断线，触发此消息派发)
    CHANGE_BET_VALUE  = 2, -- 押注值改变
    ON_LOGIC_UPDATE   = 3, -- 逻辑更新事件
    CHANGE_DISPLAY_EXCHANGERATE = 4, --显示汇率切换
    ON_SEND_REQUEST = 5,  -- 发送网络请求
    ON_RECV_LOTTERT_DATA = 6, -- 收到彩金消息
    ON_UPDATE_SERVICE_RED_DOT = 7,--刷新客服红点
}


-- @brief 主题类型定义
FThemeType = {
    Lilac            = "Lilac",             -- 紫色UI
    CrimsonCartoon   = "CrimsonCartoon",    -- 深红色卡通风格UI
}