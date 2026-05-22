Recharge = Recharge or {}

--银行卡号最低位数
Recharge.Bank_MinNumber      =   10

--银行卡号最高位数
Recharge.Bank_MaxNumber      =   15

--退款，二维码选择银行图标路径
Recharge.Path_ExchangeBank   =   "exchange/mm_icon/%d.png"

--退款，二维码退款选择银行
Recharge.Exchange_Banklist = {
    [1] = "KBZ Pay",    [2] = "WAVE Pay",  [3] = "MPT Pay",
    [4] = "OK $",
}

--开户行列表路径
Recharge.Path_BankName = "bind_card_layer/mm_bank/%d.png"

--开户行列表
Recharge.Bank_NameList = {
    [1] = "WAVE Pay",
	[2] = "KBZ Pay"
}

-- 工具会修改这个字段
local UseAYAExchange = false
if UseAYAExchange == true then
    Recharge.Bank_NameList[3] = "AYA Pay"
end
