local MusicCfg = {}

MusicCfg.collect = "ui://Game483/collect_" -- 收分 123
MusicCfg.bigwin = "ui://Game483/bigwin" -- 大奖
MusicCfg.bigwin_end = "ui://Game483/bigwin_end" -- 大奖结束
MusicCfg.reel_start = "ui://Game483/reel_start" -- 转轮转动过程中背景音效（连续播，转轮停止后结束）
MusicCfg.reel_stop = "ui://Game483/reel_stop" -- 转轮转动停止音效
MusicCfg.longtime_start = "ui://Game483/longtime_start" -- 延时旋转开始音效
MusicCfg.longtime = "ui://Game483/longtime" -- 延时旋转音效
MusicCfg.longtime_end = "ui://Game483/longtime_end" -- 延时旋转结束音效
MusicCfg.mahjong_remove = "ui://Game483/mahjong_remove" -- 消除音效
MusicCfg.mahjong_drop = "ui://Game483/mahjong_drop" -- 麻将掉落音效
MusicCfg.fold_change = "ui://Game483/fold_change_" -- 乘数增长时，光效切换音效（分别对应切换到后三个乘数时音效）
MusicCfg.scatter_emphasize = "ui://Game483/scatter_emphasize" -- scatter强调音效

MusicCfg.bgm_mg = "ui://Game483/bgm_mg" -- 普通背景

MusicCfg.vocals_mjhl = "ui://Game483/vocals_mjhl" -- 中免费时，scatter中奖语音播报
MusicCfg.scatter_bj = "ui://Game483/scatter_bj" -- 中免费时，scatter中奖背景音效（跟语音播报同步）

MusicCfg.free_loading = "ui://Game483/free_loading" -- 进免费加载界面音效

MusicCfg.bgm_bonus_loop = "ui://Game483/bgm_bonus_loop" -- 免费背景

MusicCfg.free_start = "ui://Game483/free_start" 
MusicCfg.free_fold_change = "ui://Game483/free_fold_change" 
MusicCfg.free_end = "ui://Game483/free_end" 
MusicCfg.free_collect = "ui://Game483/free_collect" 

MusicCfg.free_collect = "ui://Game483/free_collect" 
MusicCfg.vocals_X_Normal = {
    [2]= "ui://Game483/vocals_2X",
    [3]= "ui://Game483/vocals_3X",
    [4]= "ui://Game483/vocals_5X",
}
MusicCfg.vocals_X_Free = {
    [1]= "ui://Game483/vocals_2X",
    [2]= "ui://Game483/vocals_4X",
    [3]= "ui://Game483/vocals_6X",
    [4]= "ui://Game483/vocals_10X",
}

MusicCfg.double_remove = {
    [1]= "ui://Game483/vocals_qz_nan",
    [2]= "ui://Game483/vocals_qz_nv",
}

MusicCfg.not_wins = {
    [1]= "ui://Game483/vocals_cygm",
    [2]= "ui://Game483/vocals_hdxl",
    [3]= "ui://Game483/vocals_jpo",
    [4]= "ui://Game483/vocals_kykdndpl",
    [5]= "ui://Game483/vocals_wtpl",
}

MusicCfg.wins = {
    [0]= "ui://Game483/vocals_fc",
    [1]= "ui://Game483/vocals_hz",
    [2]= "ui://Game483/vocals_bb",
    [3]= "ui://Game483/vocals_bw",
    [4]= "ui://Game483/vocals_zyydh",
    [5]= "ui://Game483/vocals_wt",
    [6]= "ui://Game483/vocals_yj",
    [7]= "ui://Game483/vocals_et",
}

return MusicCfg