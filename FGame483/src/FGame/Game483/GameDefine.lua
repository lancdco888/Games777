local GameDefine = {}

-- 进入免费游戏后初始免费次数
GameDefine.FREE_COUNT_IN_FREE_GAME = 8


GameDefine.PlayBigBet = 20

GameDefine.PlayAnimRates = { 20,35,50 }

GameDefine.BigWinNames = {"bigwin","megawin","superwin"}

------------------------------------------------ 特殊icon下标定义 ------------------------------------------------

-- wild
GameDefine.ICON_WILD = 8
GameDefine.ICON_SCATTER = 9
------------------------------------------------ lottyType值定义 ------------------------------------------------
---
--- 龙模式,icon 17, lottyType 非零时为落地牌
---
--- 1普通数字奖励
GameDefine.LOTTYTYPE_NUM = 1
--- 2小奖分值
GameDefine.LOTTYTYPE_MINI = 2
--- 3中奖分值
GameDefine.LOTTYTYPE_MINOR = 3
--- 4大奖分值
GameDefine.LOTTYTYPE_MAJOR = 4
--- 5巨奖分值
GameDefine.LOTTYTYPE_GRAND = 5

------------------------------------------------ 特殊中奖线定义 ------------------------------------------------

-- 普通中奖线最大下标
GameDefine.NORMAL_LINE_INDEX_MAX = 100
GameDefine.FREE_LINE_INDEX = 10001

------------------------------------------------ 特殊值定义 ------------------------------------------------

-- 播放抛金币动画最小倍数
GameDefine.PlayCoinFountainMinBet = 10

------------------------------------------------ 初始图案 ------------------------------------------------
GameDefine.InitSymbolData = {
    {[0] = {icon = 1,},{icon = 4, }, {icon = 5, }, {icon = 6, }, {icon = 7, }},
    {[0] = {icon = 4,},{icon = 0, }, {icon = 1, golden = 1}, {icon = 9, golden = 1}, {icon = 3, }},
    {[0] = {icon = 0,},{icon = 8, }, {icon = 5, }, {icon = 6, }, {icon = 8, }},
    {[0] = {icon = 4,},{icon = 0,}, {icon = 9, golden = 1}, {icon = 2, golden = 1}, {icon = 3, }},
    {[0] = {icon = 5,},{icon = 4, }, {icon = 5, }, {icon = 6, }, {icon = 7, }},
}

GameDefine.BIGWIN = 20
GameDefine.MEGAWIN = 35
GameDefine.SUPERMEGAWIN = 50
GameDefine.BigWinNormalSpeed = 3.6
GameDefine.BigWinTotalTime = 21


---------------
GameDefine.DROP_TIME = 0.5
GameDefine.DROP_READY_SHAKE_TIME = 1

GameDefine.LOG_KEY = true

GameDefine.FREE_WON_FREE = 10001

return GameDefine
