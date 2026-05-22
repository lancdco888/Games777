local MusicCfg = {}

MusicCfg.MAIN_MUSIC = "ui://Game388/MainMusic"
MusicCfg.DELAY_REEL = "ui://Game388/speed_reel"
MusicCfg.DELAY_REEL_STOP = "ui://Game388/StickyAnticipationTerm"
MusicCfg.REELSTOP = "ui://Game388/reel_stop"
MusicCfg.REELSTOP_SC = "ui://Game388/scatter_stop"

MusicCfg.FREE_AWARD_SYMBOL_ANI = "ui://Game388/tiger_gains"
MusicCfg.FREE_TRIGGER = "ui://Game388/win_feature"
MusicCfg.FREE_BG_MUSIC = "ui://Game388/free_music"
MusicCfg.FREE_END_MUSIC = "ui://Game388/BonusMusicTerm"
MusicCfg.FREE_IN_FREE = "ui://Game388/win_freespin_feature"
MusicCfg.FREE_SETTLEMENT_IN = "ui://Game388/win_freespin_feature"
MusicCfg.FREE_SETTLEMENT_OUT = "ui://Game388/BaseToFreeOutro"
MusicCfg.FREE_NEW_IN = "ui://Game388/win_freespin_feature"
-- MusicCfg.FREE_NEW_OUT = "ui://Game388/BaseToFreeOutro"
MusicCfg.FREE_AWARD = "ui://Game388/BonusRollup"
MusicCfg.FREE_AWARD_OUT = "ui://Game388/BonusRollupTerm"
MusicCfg.FREE_SC_AWARD = "ui://Game388/with_scatter_ani"

MusicCfg.LUODI_SCORE_SCROLL = "ui://Game388/powercash_totalwin"
MusicCfg.LUODI_TRIGGER = "ui://Game388/win_feature"
MusicCfg.LUODI_TIP_PANEL = "ui://Game388/MightyCash"
-- MusicCfg.LUODI_BEGIN = "ui://Game388/StickySymbolsIntro"
MusicCfg.LUODI_BG = "ui://Game388/powercash_bgm"
-- MusicCfg.LUODI_REEL = "ui://Game388/speed_reel"
MusicCfg.LUODI_REEL_END = "ui://Game388/reel_stop"
MusicCfg.LUODI_ADDITIONAL_TIME_IN = "ui://Game388/powercash_gains"
MusicCfg.LUODI_ADDITIONAL_TIME_OUT = "ui://Game388/extra_select"
MusicCfg.LUODI_FULL = "ui://Game388/AllSymbolsFilled"
MusicCfg.LUODI_NEW_ITEM = "ui://Game388/biggest_jackpot_level"

MusicCfg.AudioData = {
    {ratio = 0, time = 0.5, url="ui://Game388/minor_win"},
    {ratio = 1, time = 2, url="ui://Game388/mini_win"},
    {ratio = 5, time = 4, url="ui://Game388/small_win"},
    {ratio = 10, time = 16, isOpenFire = true, url="ui://Game388/big_win_2"},
}

return MusicCfg
