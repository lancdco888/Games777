Recharge = Recharge or {}
--右侧金额显示，跳转浏览器扫码充值(201~300)
--右侧金额显示，二级弹窗补充充值信息(301~400)
--早期第四方充值，金额+跳转浏览器拉起第四方apk(401~500)
--信息显示+直接填写信息+可能通过浏览器跳转拉起第四方apk(501~600)
-- >=1301 <=1400 这 100个数字是 充值卡
-- 390 -399印尼订单后四位
--充值渠道列表数据

local G_ExchageRoot = "hall/"
Recharge.RechargeChannelListData = {
-- 泰国充值[[
	[101] =
	{
		name 		= "google充值",
		button 		= G_ExchageRoot .. "res/rechargeLayer/zzzf2_2.png",
		button_touch= G_ExchageRoot .. "res/rechargeLayer/zzzf2.png",
		icon_font 	= "language/rechargeLayer/googlecz1.png",
		icon 		= G_ExchageRoot .. "res/rechargeLayer/cz_3.png",
	},
-- 泰国充值]]


-- 缅甸充值[[
	[6] =
	{
		name 		= "代理充值",
		button 		= G_ExchageRoot .. "res/rechargeLayer/zzzf_2.png",
		button_touch= G_ExchageRoot .. "res/rechargeLayer/zzzf.png",
	},
	[305] =
	{
		name 		= "KBZ Bank",
		button 		= G_ExchageRoot .. "res/rechargeLayer/kbz_bank_2.png",
		button_touch= G_ExchageRoot .. "res/rechargeLayer/kbz_bank.png",
		icon_font 	= "language/rechargeLayer/kbz_bank.png",
		icon 		= G_ExchageRoot .. "res/rechargeLayer/cz_305.png",
		group 		= "KBZ_BANK"
	},
	[310] =
	{
		name 		= "UAB Bank 1",
		button 		= G_ExchageRoot .. "res/rechargeLayer/UABBank_2.png",
		button_touch= G_ExchageRoot .. "res/rechargeLayer/UABBank.png",
		icon_font 	= "language/rechargeLayer/UABBankcz.png",
		icon 		= G_ExchageRoot .. "res/rechargeLayer/cz_310.png",
		group 		= "UAB"
	},
	[311] = 310,
	[312] = 310,
	[313] = 310,

	[317] =
	{
		name 		= "KBZ_Z_1_1充值",
		button 		= G_ExchageRoot .. "res/rechargeLayer/kbz_2.png",
		button_touch= G_ExchageRoot .. "res/rechargeLayer/kbz.png",
		icon_font 	= "language/rechargeLayer/kbz.png",
		icon 		= G_ExchageRoot .. "res/rechargeLayer/cz_10.png",
		group 		= "KBZ"
	},

	[318] = 317,

	[319] =
	{
		name 		= "wavepay_z_1_1充值",
		button 		= G_ExchageRoot .. "res/rechargeLayer/wavepay_2.png",
		button_touch= G_ExchageRoot .. "res/rechargeLayer/wavepay.png",
		icon_font 	= "language/rechargeLayer/wavepay.png",
		icon 		= G_ExchageRoot .. "res/rechargeLayer/cz_9.png",
		group 		= "WAVEPAY"
	},
	[320] = 319,
	[321] = 319,
	[322] = 319,

	[323] =
	{
		name 		= "okpay_1充值",
		button 		= G_ExchageRoot .. "res/rechargeLayer/okpay_2.png",
		button_touch= G_ExchageRoot .. "res/rechargeLayer/okpay.png",
		icon_font 	= "language/rechargeLayer/okplay.png",
		icon 		= G_ExchageRoot .. "res/rechargeLayer/cz_7.png",
	},


	[325] = 317,
	[326] = 317,
	[327] = 317,
	[328] = 317,

	[331] =
	{
		name 		= "Yoma bank",
		button 		= G_ExchageRoot .. "res/rechargeLayer/yoma_2.png",
		button_touch= G_ExchageRoot .. "res/rechargeLayer/yoma.png",
		icon_font 	= "language/rechargeLayer/yoma_bank.png",
		icon 		= G_ExchageRoot .. "res/rechargeLayer/cz_331.png",
		group 		= "YOMA_BANK"
	},
	[332] = 331,
	[333] = 331,
	[334] = 331,

	[344] =
	{
		name 		= "MPT_PAY_1充值",
		button 		= G_ExchageRoot .. "res/rechargeLayer/mptpay_2.png",
		button_touch= G_ExchageRoot .. "res/rechargeLayer/mptpay.png",
		icon_font 	= "language/rechargeLayer/mptpay.png",
		icon 		= G_ExchageRoot .. "res/rechargeLayer/cz_8.png",
	},

	[350] = 317,
	[351] = 317,
	[352] = 317,
	[353] = 317,

	[354] = 319,
	[355] = 319,
	[356] = 319,
	[357] = 319,
	[358] = 319,
	[359] = 319,
	[360] = 319,
	[361] = 319,
	[362] = 319,
	[363] = 319,

	[377] = {
		name 		= "aya pay",
		button 		= G_ExchageRoot .. "res/rechargeLayer/ayapay_2.png",
		button_touch= G_ExchageRoot .. "res/rechargeLayer/ayapay.png",
		icon_font 	= G_ExchageRoot .. "res/rechargeLayer/ayacz.png",
		icon 		= G_ExchageRoot .. "res/rechargeLayer/aya.png",
		group 		= "AYA_PAY"
	},

	-- kbz
	[1001] = 317,
	[1002] = 317,
	[1003] = 317,
	[1004] = 317,
	[1005] = 317,

	[1006] = 317,
	[1007] = 317,
	[1008] = 317,
	[1009] = 317,
	[1010] = 317,
	[1011] = 317,
	[1012] = 317,
	[1013] = 317,
	[1014] = 317,
	[1015] = 317,

	-- wave pay
	[1020] = 319,
	[1021] = 319,
	[1022] = 319,
	[1023] = 319,
	[1024] = 319,
	[1025] = 319,
	[1026] = 319,
	[1027] = 319,
	[1028] = 319,
	[1029] = 319,

	-- kbz
	[1030] = 317,
	[1031] = 317,
	[1032] = 317,
	[1033] = 317,
	[1034] = 317,
	[1035] = 317,
	[1036] = 317,
	[1037] = 317,
	[1038] = 317,
	[1039] = 317,
	[1040] = 317,
	[1041] = 317,
	[1042] = 317,
	[1043] = 317,
	[1044] = 317,
	[1045] = 317,
	[1046] = 317,
	[1047] = 317,
	[1048] = 317,
	[1049] = 317,

	-- wave pay
	[1050] = 319,
	[1051] = 319,
	[1052] = 319,
	[1053] = 319,
	[1054] = 319,
	[1055] = 319,
	[1056] = 319,
	[1057] = 319,
	[1058] = 319,
	[1059] = 319,

	[1060] = 319,
	[1061] = 319,
	[1062] = 319,
	[1063] = 319,
	[1064] = 319,
	[1065] = 319,
	[1066] = 319,
	[1067] = 319,
	[1068] = 319,
	[1069] = 319,
	[1070] = 319,
	[1071] = 319,
	[1072] = 319,
	[1073] = 319,
	[1074] = 319,
	[1075] = 319,
	[1076] = 319,
	[1077] = 319,
	[1078] = 319,
	[1079] = 319,

	-- kbz
	[1080] = 317,
	[1081] = 317,
	[1082] = 317,
	[1083] = 317,
	[1084] = 317,
	[1085] = 317,
	[1086] = 317,
	[1087] = 317,
	[1088] = 317,
	[1089] = 317,
	[1090] = 317,
	[1091] = 317,
	[1092] = 317,
	[1093] = 317,
	[1094] = 317,
	[1095] = 317,
	[1096] = 317,
	[1097] = 317,
	[1098] = 317,
	[1099] = 317,

-- 缅甸充值]]

-- 印尼充值[[
	[1201] =
	{
		name 		= "第四方支付",
		button 		= "language/rechargeLayer/zzcz4_2.png",
		button_touch= "language/rechargeLayer/zzcz4.png",
		icon_font 	= "language/rechargeLayer/zzcz.png",
		icon 		= "language/rechargeLayer/zhuanzhang.png",
	},
-- 印尼充值]]

	--===============================----
    ["bind"] =
    {
        name 		= "bind",
        button 		= "hall/res/common/anniu_01.png",
        button_touch= "hall/res/common/anniu_01.png",
    },

-- [[虚拟货币
	[2001] = {
		name 		= "TRC20",
        button 		= G_ExchageRoot .."res/rechargeLayer/trc20_2.png",
        button_touch= G_ExchageRoot .."res/rechargeLayer/trc20_1.png",
		icon_font 	= "language/rechargeLayer/trc20.png",
		icon 		= G_ExchageRoot .. "res/rechargeLayer/zhuanzhang.png",
	},
	[2002] = {
		name 		= "ERC20",
        button 		= G_ExchageRoot .."res/rechargeLayer/erc20_2.png",
        button_touch= G_ExchageRoot .."res/rechargeLayer/erc20_1.png",
		icon_font 	= "language/rechargeLayer/erc20.png",
		icon 		= G_ExchageRoot .. "res/rechargeLayer/zhuanzhang.png",
	},
-- 虚拟货币]]

-- 浏览器跳转支付
	[2101] = {
		name 		= "PAY",
        button 		= "language/rechargeLayer/www_pay_2.png",
        button_touch= "language/rechargeLayer/www_pay.png",
		icon_font 	= "language/rechargeLayer/www_pay_cz.png",
		icon 		= "language/rechargeLayer/cz_2101.png",
	},
    -- 2102 ~ 2201 和 2101 一样
-- 浏览器跳转支付
}

for id = 2101, 2201 do
    Recharge.RechargeChannelListData[id] = Recharge.RechargeChannelListData[2101]
end

function Recharge.IsWWWPay(channel_id)
    return channel_id >= 2101 and channel_id <= 2201
end

function Recharge.IsVirtualCoin(channel_id)
    return channel_id >= 2001 and channel_id < 2100
end

--充值内客服icon
Recharge.ServiceIcon = {
    'rechargeLayer/line.png',-- line
    'rechargeLayer/messenger.png', -- Messenger
    'rechargeLayer/twitter.png', -- 推特
    'rechargeLayer/viber.png', -- viber
    'rechargeLayer/whats-app.png', -- wahtsApp
    'rechargeLayer/zalo.png', -- zalo
}

function RechargeGetCfgId(channel_id)
	local cfg = Recharge.RechargeChannelListData[channel_id]
	if type(cfg) == "number" then
		return RechargeGetCfgId(cfg)
	end
	return channel_id
end

function RechargeGetChannelCfg(channel_id)
	channel_id = RechargeGetCfgId(channel_id)
	return Recharge.RechargeChannelListData[channel_id]
end
