sGameManager = sGameManager or {}
--===========<充值相关数据>===========
--充值渠道列表
sGameManager.payChannels 		= {}
--扫码方式金额表
sGameManager.channelMoneys	 	= {}
--vip方式信息表
sGameManager.vipChannels		= {}
--充值 手动输入金额 最大值
sGameManager.recharge_max_money = 0
--充值 手动输入金额 最小值
sGameManager.recharge_min_money = 0
--玩家修改实名信息,金币不可超越值
sGameManager.max_fix_realname_money = 0
--充值金额列表 [充值id]{充值金额列表}
sGameManager.rechargeAmountList = {}
--充值识别额度
sGameManager.accuracy 			= 0 
--===========<************>===========

--===========<退款相关数据>===========
--充值渠道列表
sGameManager.exchange_payChannels 		= {}
--二维码退款是否上传二维码
sGameManager.exchange_QRpath 			= ""
--二维码对应银行
sGameManager.exchange_QRBank 			= ""
--===========<************>===========