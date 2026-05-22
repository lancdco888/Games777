local MusicCfg = {}
MusicCfg.SND_EndMask = "ui://Game336/SND_EndMask" -- 免费时开窗音效
MusicCfg.feature_bell = "ui://Game336/feature_bell" -- 中免费游戏时打铃音效
MusicCfg.SND_Scatter = "ui://Game336/SND_Scatter" -- 免费中奖音效 （打铃之后也播）
MusicCfg.SND_Fea_BGM = "ui://Game336/SND_Fea_BGM" -- 免费背景音效
MusicCfg.slots_336_reelscatr = "ui://Game336/slots_336_reelscatr_" -- 免费 转完音效



MusicCfg.SND_FeatureTrigger = "ui://Game336/SND_FeatureTrigger" -- 落地牌 进场提示音效（播弹窗提示动画时）
MusicCfg.SND_FreeSpin_BGM = "ui://Game336/SND_FreeSpin_BGM" -- 落地牌 6-13 bonusCount 背景音乐
MusicCfg.SND_FreeSpin_BGMFast = "ui://Game336/SND_FreeSpin_BGMFast" -- 落地牌 14,15 bonusCount 背景音乐
MusicCfg.SND_HandSDoonk = "ui://Game336/slots_336_reelscatr_" -- 落地牌 出现落地牌强调音效
MusicCfg.SND_GrandStrike = "ui://Game336/SND_GrandStrike" -- 落地牌 重置次数音效
MusicCfg.SND_Rumble = "ui://Game336/SND_Rumble" -- 落地牌 金币汇总前音效
MusicCfg.SND_LargePrize = "ui://Game336/SND_LargePrize" -- 落地牌 金币汇总音效 （15倍以上分数）
MusicCfg.SND_Small_5 = "ui://Game336/SND_Small_5" -- 落地牌 金币汇总音效 
MusicCfg.SND_GrandBell = "ui://Game336/SND_GrandBell" -- 落地牌 全屏打铃音效

-- MusicCfg.SND_JPDoonk = "ui://Game336/SND_JPDoonk" -- 普通免费 出现落地牌

MusicCfg.slots_336_reelstop = "ui://Game336/slots_336_reelstop" -- 转轮停止

MusicCfg._audioData =
{
    {path = "ui://Game336/wintune01", second = 0.1},
    {path = "ui://Game336/wintune02", second = 0.2},
    {path = "ui://Game336/wintune03", second = 0.3},
    {path = "ui://Game336/wintune04", second = 0.4},
    {path = "ui://Game336/wintune05", second = 0.5},
    {path = "ui://Game336/wintune06", second = 0.6},
    {path = "ui://Game336/wintune07", second = 0.7},
    {path = "ui://Game336/wintune08", second = 0.8},
    {path = "ui://Game336/wintune09", second = 0.9},
    {path = "ui://Game336/wintune10", second = 1.25},
    {path = "ui://Game336/wintune11", second = 2.25},
    {path = "ui://Game336/wintune12", second = 1.5},
    {path = "ui://Game336/wintune13", second = 1.9},
    {path = "ui://Game336/wintune14", second = 2.25},
    {path = "ui://Game336/wintune15", second = 4.1},
    {path = "ui://Game336/wintune16", second = 4.05},
    {path = "ui://Game336/wintune17", second = 5.2},
    {path = "ui://Game336/wintune18", second = 6.45},
    {path = "ui://Game336/wintune19", second = 7.65},
    {path = "ui://Game336/wintune20", second = 9.15},
    {path = "ui://Game336/wintune21", second = 12.45},
    {path = "ui://Game336/wintune22", second = 14.7},
    {path = "ui://Game336/wintune23", second = 15},
    {path = "ui://Game336/wintune24", second = 18.7},
    {path = "ui://Game336/wintune25", second = 19.5},
    {path = "ui://Game336/wintune26", second = 25.7},
    {path = "ui://Game336/wintune27", second = 30.9},
    {path = "ui://Game336/wintune28", second = 35.9},
    {path = "ui://Game336/wintune29", second = 39.1},
    {path = "ui://Game336/wintune30", second = 45.3},
    {path = "ui://Game336/wintune31", second = 52.5},
    {path = "ui://Game336/wintune32", second = 57.6},
}





function MusicCfg.GetAudioData(multiply)
	local index = nil
    if multiply > 8000 then
        index = 32
    elseif multiply > 6000 then
        index = 31
    elseif multiply > 5000 then
        index = 30
    elseif multiply > 4000 then
        index = 29
    elseif multiply > 3000 then
        index = 28
    elseif multiply > 2000 then
        index = 27
    elseif multiply > 1000 then
        index = 26
    elseif multiply > 500 then
        index = 25
    elseif multiply > 200 then
        index = 24
    elseif multiply > 100 then
        index = 23
    elseif multiply > 80 then
        index = 22
    elseif multiply > 60 then
        index = 21
    elseif multiply > 40 then
        index = 20
    elseif multiply > 30 then
        index = 19
    elseif multiply > 20 then
        index = 18
    elseif multiply > 15 then
        index = 17
    elseif multiply > 10 then
        index = 16
    elseif multiply > 7 then
        index = 15
    elseif multiply > 5 then
        index = 14
    elseif multiply > 3 then
        index = 13
    elseif multiply > 2 then
        index = 12
    elseif multiply > 1 then
        index = 11
    elseif multiply > 0.9 then
        index = 10
    elseif multiply > 0.8 then
        index = 9
    elseif multiply > 0.7 then
        index = 8
    elseif multiply > 0.6 then
        index = 7
    elseif multiply > 0.5 then
        index = 6
    elseif multiply > 0.4 then
        index = 5
    elseif multiply > 0.3 then
        index = 4
    elseif multiply > 0.2 then
        index = 3
    elseif multiply > 0.1 then
        index = 2
    else
        index = 1
    end
    return MusicCfg._audioData[index]
end
return MusicCfg