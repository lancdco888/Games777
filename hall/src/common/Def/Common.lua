
Def = Def or {}
--UI大版本定义，1：大福UI切图
Def.UI_Version			=	1

-------------------------------------------------

LangDef = require("packagelua.src.base.LangDef")
for k,v in pairs(LangDef) do
    Def[k] = v
end

------------小数点保留位数
Def.Num_PointValue			=	"%.1f"
Def.Num_PointValue_One		=	"%.2f"
Def.Num_PointValue_two		=	"%.3f"
------------

--屏幕共有参数
Def.DesignedX			=	1280.0
Def.DesignedY			=	720.0
Def.visibleSize			=	cc.Director:getInstance():getVisibleSize()
Def.ScaleX				=	Def.visibleSize.width / Def.DesignedX
Def.ScaleY				=	Def.visibleSize.height / Def.DesignedY
Def.ScaleMax			=   math.max(Def.ScaleX, Def.ScaleY)
Def.ScaleMin			=   math.min(Def.ScaleX, Def.ScaleY)

--通用错误返回
Def.Net_RechargeWorng			=	-1
Def.Net_GetVerifyCodeNotTimeUp	=	-4
Def.Net_GetVerifyCodeFailed		=	-5
Def.Net_GetVerifyCodeNoAccount	=	-6
Def.Net_RepeatNickName			=	-7
Def.Net_Login_PasswordWorng		=	-8
Def.Net_RepeatPhone				=	-10
Def.Net_Login_PhoneWorng		=	-14
Def.Net_Login_Settlement		=	-100
Def.Net_EnterCatch_NoService	=	-5
Def.Net_EnterCatch_NoService_2	=	-1
Def.Net_EntetCatch_NoSit		=	-2
Def.Net_GiveRecipientNot		=	-20
Def.Net_GivePasswordError		=	-21
Def.Net_ResetPasswordFail		= 	-300
Def.Net_GiveInsufficientMoney	=	-19
Def.Net_GiveInsufficientMoney_1	=	-13
Def.Net_Insufficient_Redemption	=	-55
Def.Net_Login_WhiteList			=	-110
Def.Net_SignIn_GaveInfoFailed	=	-71
Def.Net_SignIn_TakeFailed		=	-72
Def.Net_SignIn_UnformalTake		=	-73
Def.Net_Login_CannotLogin		=	-120
Def.Net_FacebookIsbulid			=	-50
---------------

Def.SpeciaSwitch			=	"SpeciaSwitch"
Def.IsMusic					=	"music"
Def.IsSoundEffect			=	"effect"
Def.IsNoticeShow			=	"notice"

Def.CasinoLeave_Send		= 	45
Def.CasinoSpinNormal_Send	= 	46
Def.CasinoSpinFree_Send		= 	47
Def.CasinoFGSelect_Send		= 	48
Def.CasinoSpinSpec_Send		= 	49
Def.CasinoSpinCJReel_Send	=	50--彩金转轮
Def.CasinoCaiJinTables_Send	=	51--老虎机子游戏里获取彩金值
Def.CasinoSpinTurntable_Send=	52--老虎机转盘旋转
Def.CasinoTest_Send			=	53--老虎机测试效果包
Def.CasinoClickInfo_Send	=	54--老虎机彩金游戏点击信息包
Def.CasinoCallCustomer_Send = 	55--老虎机中彩金大、巨奖联系包
Def.CasinoSpecialPick_Send  = 	56--老虎机金猪报喜特殊游戏点击包i

--谷歌支付ID
Def.googlepay_ID 	= 101