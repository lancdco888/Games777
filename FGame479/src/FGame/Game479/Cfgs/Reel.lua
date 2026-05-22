return {
    -- 格子X轴数,--量
    xCellNumber = 5,
    -- 格子Y轴数量
    yCellNumber = 3,

    -- 抬起动画时间
    liftDuration = 0.2,
    -- 抬起距离
    liftDistance = -80,
    -- 回弹动画时间
    bounceDuration = 0.2,
    -- 回弹距离
    bounceDistance = 50,

    -- 滚动速度
    scrollSpeed = 0.3                                                                                                                                                                                                                                                                                                                                                                                                                                                 ,

    -- 转轴宽度
    reelWidth = 203,--188,
    -- 转轴高度
    reelHeight = 410,--388,
    reeliconHight = 410 / 3,
    -- 转轴与转之间的间隔
    reelSpace = 7  ,--18,
    reelOffsetX = 0,
    reelOffsetY = 0,

    -- 转轴最少转过格子数量（数据马上回来也得达到这个最少数量才会展示结果）
    rollSymbolMinNum = 6,
    -- 转轴停止间隔时间
    rellStopInterval = {
        [FGameMode.NORMAL]  = 0.5,
        [FGameMode.FREE]    = 0.5,
        [FGameMode.SPECIAL] = 0.3,
    },
}