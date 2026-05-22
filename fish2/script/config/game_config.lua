FF_G.GameConfig = {
    -- 播放死亡语音的几率[0, 1]
    PlayDeathTalkMusicProbability = 0.2,
    SimpleBulletSpeed = 1300,
    TrackBulletSpeed = 1300,
    -- 子弹待碰撞时间
    SimpleBulletWaitTime = FF_G.IsCSGaming and 0.015 or 0.085,
    -- 昌盛相关
    CS = {
        -- 正常发射cd
        NormalFireCd = 1 / 4;
        -- 加速发射cd
        SpeedUpFireCd = 1 / 8;
    },
    -- 倒计时数字X轴偏移
    CountdownNumOffsetX = {
        default = 505,
        ph = 310,
    }
}