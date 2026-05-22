local UserData = UserData or {}

--基本信息
UserData.id = 0                         --用户Id ( 随机 8 位整数 )
UserData.username = ""                --用户名
UserData.nickname = ""                --昵称
UserData.avatar_id = 0                  --头像
UserData.phone = ""                   --电话号码
UserData.is_first_login = false         -- 是否是第一次登录

--金币信息
UserData.money = 0.0                    --账户余额( 保留4位小数位, 进部分游戏时会被清0, 结束时会退款返还 )
UserData.money_safe = 0.0               --保险箱数据
UserData.money_gift = 0.0               --洗码金额
UserData.money_gift_safe = 0.0          --洗码保险箱金额
UserData.total_recharge = 0.0           --累计充值

--其他模块信息
UserData.is_gift_money_password = 0     --玩家是否已设置赠送金币密码(1已设置)
UserData.is_system_gift_money = 0       --玩家是否已获赠金币(1已赠送)
UserData.is_popularize = 0              --玩家是否有推广权限(1有)
UserData.is_promotion = 0               --玩家是否已是代理(1=是)
UserData.is_signingave = 0              --这次登录是否SHOW每日签到(1=是)
UserData.has_gift_money_purview = 0     --玩家是否有赠送金币权限(1有)
UserData.is_shows_signingave_button = 0 --是否显示签到按钮(1=显示)
UserData.account_name = "" --账号是否已经绑定了账号密码 是否显示账号绑定按钮

-- 客服界面开关
-- ['id' => 116, 'label' => '常见问题'],
-- ['id' => 117, 'label' => '客服'],
-- ['id' => 118, 'label' => '提交建议'],
-- ['id' => 119, 'label' => '邮件'],
-- ['id' => 120, 'label' => '密语'],
-- ['id' => 121, 'label' => '群发'],
-- 大厅底部按钮的开关表
UserData.buttonList = {}

UserData.activity_give_type = 0 -- 0 绑金 1 金币

UserData.is_experience = 0 -- 是否试玩账号 1 试玩账号

UserData.email = "" -- 邮箱

UserData.is_open_email_bind = 0 -- 邮箱是否可用

UserData.bind_account_money_gift = 0 -- 绑定账号密码送

------------------------------------------------------------
--  退款

UserData.total_refund = 0.0             --累计退款
UserData.has_refund_purview = 0    --是否有退款权限(1有退款权限)

UserData.refund_min_money = 0.0            --退款最小金额
UserData.refund_min_remain_money = 0.0     --退款最小金额
UserData.refund_margin = 0.0               --退款金额增幅
UserData.bankcardcount = 0                      --可配置多少张银行卡
UserData.pay_channel_accounts = 0               --玩家绑定的支付信息
UserData.bank_name = null
UserData.bank_card_name = null
UserData.bank_card_number = null

-- 银行卡账号和虚拟币账号资产可切换阀值,玩家资产小于此值,可切换账号A.B状态
UserData.virtual_coin_status_switch_money = 0 -- Double

-- 充值类型(A,B号),A=0,B=1,A号只允许常规充值,B号只允许虚拟钱包充值
UserData.virtual_coin_status = 0

UserData.gift_min_money = 0
UserData.gift_min_remain_money = 0
UserData.gift_max_money = 0
UserData.gift_fee = 0
UserData.gift_money_mode = 0

-- 能否显示虚拟充值
function UserData:CanUseVirtualRecharge()
    return self.virtual_coin_status == 1
end 

-- 能否显示普通充值
function UserData:CanUseCommonRecharge()
    return self.virtual_coin_status == 0
end

function UserData:IsExperienceUser()
    return UserData.is_experience == 1
end

return UserData
