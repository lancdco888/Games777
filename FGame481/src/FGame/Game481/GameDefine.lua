local GameDefine = {}

-- 进入免费游戏后初始免费次数
GameDefine.INITIAL_FREE_COUNT_IN_FREE_GAME = 15


GameDefine.PlayBigBet = 20

GameDefine.PlayAnimRates = { 15,30,45,60 }

------------------------------------------------ 特殊icon下标定义 ------------------------------------------------
GameDefine.ICON_SCATTER = 9
GameDefine.ICON_JP = 10

------------------------------------------------ 特殊中奖线定义 ------------------------------------------------

-- 普通中奖线最大下标
GameDefine.NORMAL_LINE_INDEX_MAX = 100

------------------------------------------------ 特殊值定义 ------------------------------------------------

-- 播放抛金币动画最小倍数
GameDefine.PlayCoinFountainMinBet = 10

------------------------------------------------ 初始图案 ------------------------------------------------
GameDefine.InitSymbolData = {
    {{icon = 6}, {icon = 6}, {icon = 5}, {icon = 5}, {icon = 8}},
    {{icon = 2}, {icon = 2}, {icon = 5}, {icon = 5}, {icon = 0}},
    {{icon = 8}, {icon = 8}, {icon = 1}, {icon = 1}, {icon = 4}},
    {{icon = 7}, {icon = 7}, {icon = 8}, {icon = 8}, {icon = 2}},
    {{icon = 7}, {icon = 7}, {icon = 1}, {icon = 1}, {icon = 6}},
    {{icon = 6}, {icon = 6}, {icon = 5}, {icon = 5}, {icon = 7}},
}

return GameDefine
