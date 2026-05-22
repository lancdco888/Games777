require("json")
sGameManager ={}

function sGameManager.Init()
	-- 官网 url
	sGameManager.website = ""

	-- 断线重连需要刷新界面的标识位
	sGameManager.NetRestoreCasino = false
	
	-- 断线重连刷新的回包(用于刷新游戏界面)
	sGameManager.NetRestoreCasinoRlt = nil

	-- 老虎机脚本是否被加载（用于断网重连）
	sGameManager.isCasinoLoaded = false

	--汇率
	sGameManager.exchangerate = 1
	
	--游戏状态，大厅、大厅切换游戏过程、游戏中
	sGameManager.gameState = -1
	
	--登入界面的默认保存账号密码
	sGameManager.isSavePwd = true
	
	--防止玩家快速点击
	sGameManager.Isrecharged = false
	
	--从相册获取的图片资源
	sGameManager.Image = nil

	--从相册获取的图片资源size
	sGameManager.ImageSize = nil -- size用string格式

	--图片上传url
	sGameManager.uploadimageUrl = ""
	
	--===========<充值相关数据>===========
	--当前可能要充值的数据(只是选择了,还没有要付款)
	sGameManager.recharge_data				= {}
	sGameManager.recharge_data.is			= false
	sGameManager.recharge_data.product_id 	= nil
	sGameManager.recharge_data.money 		= nil
	--===========<************>===========
	
	--===========<游戏列表相关数据>===========
	sGameManager.GameIsPlay = false
	
	--===========<************>===========
	
	--心跳包
	sGameManager.pingStoped = true

	--手机Home键是否弹出退出提示，在未操作时只显示一个
	sGameManager.phoneHomeIsclick = false

	sGameManager.vip_level = -1

    sGameManager.bRichGame = cc.UserDefault:getInstance():getBoolForKey("IsRichGame", false)

	UserData.buttonList = sGameManager.LoadButtonList()

	--===========<是否使用fff资源>===========
	sGameManager.use_fff_res = cc.FileUtils:getInstance():isFileExist("fff_res.txt")
	--===========<**************>===========
	sGameManager.Uicfg = {}

	--彩金押注类型
	sGameManager._betlotterymode = -1
	--喜码模式开关
	sGameManager._washcode_mode = -1

	--===========<连续弹窗的下级界面已关闭>===========
	sGameManager.lowerlevelisclose = true
	--===========<**************>===========

	-- 紫色版 默认试投注比例版本
	if sGameManager.Uicfg.skin == "purple" then
		sGameManager.use_bet_rate = true
	else
		sGameManager.use_bet_rate = cc.UserDefault:getInstance():getBoolForKey('use_bet_rate', false)
	end
end

--判断是否是老虎机
sGameManager.CheckIsCasino = function (idx)
	idx = GameData:GetGameID(idx)
	if idx > 200 then
		local cfg = const_game.Param[idx]
		if cfg then
			return true
		else
			return false
		end
	end
	return false
end

--设置信息储存
function sGameManager.SaveSetUp(SpeciaSwitch, IsNoticeShow)
	local bool_ = nil
	if SpeciaSwitch then
		bool_ = 1
	else
		bool_ = 2
	end
	cc.UserDefault:getInstance():setIntegerForKey(Def.SpeciaSwitch,bool_)
	cc.UserDefault:getInstance():setBoolForKey(Def.IsNoticeShow,IsNoticeShow)
end

function sGameManager.SetUserInfo(userInfo_)
	for k,v in pairs(userInfo_) do
		UserData[k] = v
	end
end

function sGameManager.RealnameSwitch(is_open_realname_mode)
	sGameManager.is_open_realname_mode = is_open_realname_mode
end

--------------------------------------------------------------------

-- 根据洗码值计算 vip 等级
function sGameManager.GetVipLevel(washcode)
	for i=#GameData.vipInfo,1,-1 do
		if washcode >= GameData.vipInfo[i].enough_wash then
			return GameData.vipInfo[i].id
		end
	end
	return 0
end

function sGameManager.GetMyVipLevel()
	return sGameManager.vip_level
end

function sGameManager.SetMyVipLevel(vip_level)
	sGameManager.vip_level = vip_level
end

function sGameManager.GetVipLevelInfo(level)
	local ret = nil
	for i=#GameData.vipInfo,1,-1 do
		if level == GameData.vipInfo[i].id then
			ret = GameData.vipInfo[i]
			break
		end
	end
	ret = ret or {
    	enough_wash = 0, 			-- 升级需要达到的洗码值 Double
    	fish_permillage_value = 0, 	-- 捕鱼收益千分比 Double
    	slots_permillage_value = 0,	-- 老虎机收益千分比 Double
    	levelup_gift = 0			-- 升级赠送洗码金币 Double
	}

	-- 0 绑金 1 金币
	local type_ = UserData.activity_give_type
	if type_ == 0 then
		ret.gift_type = "bind_coin"			-- none 不赠送, gold 金币, bind_coin 绑定金币
	else
		ret.gift_type = "gold"
	end
	return ret  
end

-- 根据洗码值计算 vip 等级
function sGameManager.GetMaxVipLevel()
	if GameData.vipInfo[#GameData.vipInfo] then
		return GameData.vipInfo[#GameData.vipInfo].id
	end
	return 1
end

function sGameManager.GetVip(recharge)
	for i = 7,1,-1 do
		if(recharge >= GameData.vipInfo[i].total_recharge) then
			return GameData.vipInfo[i].id
		end
	end
	return -1
end

--复制用户ID
function sGameManager.CopyUserID()
	local str = tostring(UserData.id)
	Device:CopyString(str)
end

--初始化老虎机通用变量
function sGameManager.InitCasinoParam()
	sGameManager.curLevel =nil
	sGameManager.curCasinoLvID =nil
	sGameManager.curCoin =nil
	sGameManager.curXiMa =nil
	sGameManager.casinoMoneyType = nil
	sGameManager.betRatios = nil--押注金额和押注数的对应关系
end

--设置汇率
function sGameManager.SettingExchangeRate(rate)
	sGameManager.exchangerate = rate
	cc.UserDefault:getInstance():setIntegerForKey("numformat",1)
	cc.UserDefault:getInstance():setIntegerForKey("comma_or_not",Def.Comma_Or_Not)
end

function sGameManager.IsRichGame()
    return sGameManager.bRichGame
end

function sGameManager.SetRichGame(bRichGame)
	if GameData:HasRichGameThreeThousands() then
		sGameManager.bRichGame = false
		cc.UserDefault:getInstance():setBoolForKey("IsRichGame", false)
		return
	end
    sGameManager.bRichGame = bRichGame
    cc.UserDefault:getInstance():setBoolForKey("IsRichGame", bRichGame)
end

function sGameManager.IsBindCodeOpen()
	return UserData.buttonList[115] ~= 0
end

--检测是否需要弹出选C(casino选等级)界面
function sGameManager.CheckNeedPopCasinoLevel()
	return UserData.buttonList[301] ~= 0
end

function sGameManager.IsVipOpen()
	return UserData.buttonList[114] ~= 0
end

-- 临时保存这个数据，用于下一次进入游戏初始化 UserData.buttonList ，因为断线重连时不会通过大厅，而游戏会使用某些标志
function sGameManager.SaveButtonList(buttonList)
	local json = require("json")
	local data_ = {}
	for k,v in pairs(buttonList) do
		data_[tostring(k)] = v
	end
	local str_ = json.encode(data_)
	cc.UserDefault:getInstance():setStringForKey("ButtonList", str_)
end

function sGameManager.LoadButtonList()
	local json = require("json")
	local str_ = cc.UserDefault:getInstance():getStringForKey("ButtonList", "{}")
	local data_ = json.decode(str_)
	ret = {}
	for k,v in pairs(data_) do
		ret[tonumber(k)] = v
	end
	return ret
end

function sGameManager.PopRecharge()
	go(
		function()
			G_EnterRecharge()
		end
	)
end

function sGameManager.PopSafeBoxLayer()
	PopLayer:Pop(user.SafeBoxLayer)
end

-----------------------------------------------------------
-- 官网， 保证是以 / 结尾

function sGameManager.SetWebSite(url_)
    if string.sub(url_, -1) ~= "/" then
        url_ = url_ .. "/"
    end
	sGameManager.website = url_
end

function sGameManager.GetWebSite()
	return sGameManager.website
end

-----------------------------------------------------------

function sGameManager.SetBetLotteryMode(LotteryMode)
	--_betlotterymode 0 当前押注，1当前C挡位最高押注
	sGameManager._betlotterymode = LotteryMode
end
function sGameManager.GetBetLotteryMode()
	return sGameManager._betlotterymode == 0
end
function sGameManager.SetWashCodeMode(washcode_mode)
	sGameManager._washcode_mode = washcode_mode
end
--喜码开关：1 使用喜码玩家金币必须大于押注才能喜码 喜码开关：0 绑金够就能喜码
function sGameManager.IsXimaMonde()
	return sGameManager._washcode_mode == 1
end

-- 是否使用投注比例
function sGameManager.UseBetRate()
	return sGameManager.use_bet_rate
end

function sGameManager.SetUseBetRate(bUse)
	bUse = bUse and true or false
	sGameManager.use_bet_rate = bUse
	cc.UserDefault:getInstance():setBoolForKey('use_bet_rate', bUse or false)
end
