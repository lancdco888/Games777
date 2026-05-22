local Defined = Import("..Cfgs.Defined")

local MusicCfg = {}
MusicCfg.SND_EndMask = "ui://" .. Defined.GameName .. "/SND_EndMask"                   -- 免费时开窗音效
MusicCfg.feature_bell = "ui://" .. Defined.GameName .. "/feature_bell"                 -- 中免费游戏时打铃音效
MusicCfg.SND_Scatter = "ui://" .. Defined.GameName .. "/SND_Scatter"                   -- 免费中奖音效 （打铃之后也播）
MusicCfg.SND_Fea_BGM = "ui://" .. Defined.GameName .. "/SND_Fea_BGM"                   -- 免费背景音效
MusicCfg.slots_321_reelscatr = "ui://" .. Defined.GameName .. "/slots_321_reelscatr_"  -- 免费 转完音效

MusicCfg.SND_FeatureTrigger = "ui://" .. Defined.GameName .. "/SND_FeatureTrigger"     -- 落地牌 进场提示音效（播弹窗提示动画时）
MusicCfg.SND_FreeSpin_BGM = "ui://" .. Defined.GameName .. "/SND_FreeSpin_BGM"         -- 落地牌 6-13 bonusCount 背景音乐
MusicCfg.SND_FreeSpin_BGMFast = "ui://" .. Defined.GameName .. "/SND_FreeSpin_BGMFast" -- 落地牌 14,15 bonusCount 背景音乐
MusicCfg.SND_HandSDoonk = "ui://" .. Defined.GameName .. "/SND_HandSDoonk"             -- 落地牌 出现落地牌强调音效
MusicCfg.SND_GrandStrike = "ui://" .. Defined.GameName .. "/SND_GrandStrike"           -- 落地牌 重置次数音效
MusicCfg.SND_Rumble = "ui://" .. Defined.GameName .. "/SND_Rumble"                     -- 落地牌 金币汇总前音效
MusicCfg.SND_LargePrize = "ui://" .. Defined.GameName .. "/SND_LargePrize"             -- 落地牌 金币汇总音效 （15倍以上分数）
MusicCfg.SND_Small_5 = "ui://" .. Defined.GameName .. "/SND_Small_5"                   -- 落地牌 金币汇总音效
MusicCfg.SND_GrandBell = "ui://" .. Defined.GameName .. "/SND_GrandBell"               -- 落地牌 全屏打铃音效

MusicCfg.SND_JPDoonk = "ui://" .. Defined.GameName .. "/SND_JPDoonk"                   -- 普通免费 出现落地牌

MusicCfg.slots_321_reelstop = "ui://" .. Defined.GameName .. "/slots_321_reelstop"     -- 转轮停止

return MusicCfg
