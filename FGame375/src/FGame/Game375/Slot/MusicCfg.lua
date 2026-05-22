local MusicCfg = {}
MusicCfg.reel_stop                             = "ui://Game375/reel_stop"                   --转轮停止音效前半
MusicCfg.speed_reel                            = "ui://Game375/speed_reel"                  --出现2SC后延时停止音效
MusicCfg.normal_pearl_sound                    = "ui://Game375/fx_dynamite_scatter_"        --普通和免费模式中落地牌强调音效
MusicCfg.pearl_stop_sound                      = "ui://Game375/fx_dynamite_scatter_"        --落地牌模式中落地牌强调音效
MusicCfg.fx_scatter_                           = "ui://Game375/fx_scatter_"                 --出现SC强调音效前半
MusicCfg.win_feature                           = "ui://Game375/fx_feature_trigger"          --中免费打铃音效
MusicCfg.win_feature_2                         = "ui://Game375/fx_dynamite_trigger"         --中落地牌打铃音效
--MusicCfg.scatter_win                           = "ui://Game375/scatter_win"               --中免费音效
MusicCfg.free_music                            = "ui://Game375/fx_free_games_loop_music"    --免费背景音效
--MusicCfg.SND_Fea_End                           = "ui://Game375/SND_Fea_End"               --免费和落地牌结束音效
MusicCfg.respin_                               = "ui://Game375/fx_TNT_feature_intro_music"  --落地牌背景音效(开头)
MusicCfg.respin_bgm                            = "ui://Game375/eurekaLockLoopNew"           --落地牌背景音效(循环)
MusicCfg.SND_GrandBell                         = "ui://Game375/SND_GrandBell"               --落地牌全屏中奖打铃音效
--MusicCfg.shot_wild                             = "ui://Game375/shot_wild"                 --百搭中奖动画音效
--MusicCfg.wild_long_sound                       = "ui://Game375/wild_long_sound"           --百搭合成动画音效
MusicCfg.MineCartIntroSFXOnly                  = "ui://Game375/MineCartIntroSFXOnly"        --落地牌进入音效
MusicCfg.MineCartIntroYell                     = "ui://Game375/MineCartIntroYell"           --落地牌进入音效2(人声)
MusicCfg.fx_dynamite_transform                 = "ui://Game375/fx_dynamite_transform"       --落地牌变形
MusicCfg.explosion_2_0_seconds                 = "ui://Game375/explosion_2_0_seconds"       --落地牌爆炸音效
MusicCfg.MineCarLoop                           = "ui://Game375/MineCarLoop"                 --铁轨音效
MusicCfg.TrainWhistle                          = "ui://Game375/TrainWhistle"                --鸣笛音效
MusicCfg.eurekaChimeSmallest                   = "ui://Game375/eurekaChimeSmallest"         --10倍以下飞金币字体音效
MusicCfg.eurekaChimeSmall                      = "ui://Game375/eurekaChimeSmall"            --10-30倍飞金币字体音效
MusicCfg.eurekaChimeBig                        = "ui://Game375/eurekaChimeBig"              --30倍以上飞金币字体音效
MusicCfg.Caijin_Win = {
    [3] = {url = "ui://Game375/fx_nugget_long_credit_prize", time = 4},
    [4] = {url = "ui://Game375/fx_nugget_long_credit_prize", time = 3},
    [5] = {url = "ui://Game375/fx_nugget_long_credit_prize", time = 6},
}
return MusicCfg