return {
    -- 格子X轴数量
    xCellNumber = 5,
    -- 格子Y轴数量
    yCellNumber = 3,
    -- 抬起动画时间
    liftDuration = 0,
    -- 抬起距离
    liftDistance = -80,
    -- 回弹动画时间
    bounceDuration = 0.18,
    -- 回弹距离
    bounceDistance = 100,

    -- 滚动速度
    scrollSpeed = 0.5,

    -- 转轴宽度
    reelWidth = 128,
    -- 转轴高度
    reelHeight = 348,
    -- 转轴与转轴之间的间隔
    reelSpace = 8,

    -- 转轴最少转过格子数量（数据马上回来也得达到这个最少数量才会展示结果）
    rollSymbolMinNum = 15,

    --转轮X轴偏移
    offx = 0,
    --转轮y轴偏移
    offy = 0,

    -- 转轴停止间隔时间
    rellStopInterval = {
        [FGameMode.NORMAL]  = 0.25,
        [FGameMode.FREE]    = 0.25,
        [FGameMode.SPECIAL] = 0.35,
    },
}