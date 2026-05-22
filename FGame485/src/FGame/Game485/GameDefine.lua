
local GameDefine = {}


GameDefine.NORMAL_LINE_INDEX = 1000
GameDefine.SCATTER_LINE_INDEX = 1001
GameDefine.BONUS_LINE_INDEX = 1002

GameDefine.WILD_ICON = 10
GameDefine.BONUS_ICON = 9
GameDefine.SCATTER_ICON = 11
GameDefine.FREE_COUNT_IN_TOPUPBONUS = 3


-- 播放抛金币动画最小倍数
GameDefine.PlayCoinFountainMinBet = 15

------------------------------------------------ 初始图案 ------------------------------------------------
GameDefine.InitSymbolData = {
    {{icon = 1, value = 0, value2 = 0,type = 0}, {icon = 6, value = 0, value2 = 0,type = 0}, {icon = 8, value = 0, value2 = 0,type = 0}, {icon = 4, value = 0, value2 = 0,type = 0} },
    {{icon = 5, value = 0, value2 = 0,type = 0}, {icon = 4, value = 0, value2 = 0,type = 0},{icon = 7, value = 0, value2 = 0,type = 0}, {icon = 7, value = 0, value2 = 0,type = 0} },
    {{icon = 6, value = 0, value2 = 0,type = 0}, {icon = 7, value = 0, value2 = 0,type = 0}, {icon = 2, value = 0, value2 = 0,type = 0}, {icon = 3, value = 0, value2 = 0,type = 0} },
    {{icon = 1, value = 0, value2 = 0,type = 0}, {icon = 6, value = 0, value2 = 0,type = 0}, {icon = 1, value = 0, value2 = 0,type = 0}, {icon = 5, value = 0, value2 = 0,type = 0} },
    {{icon = 7, value = 0, value2 = 0,type = 0}, {icon = 7, value = 0, value2 = 0,type = 0},{icon = 2, value = 0, value2 = 0,type = 0}, {icon = 6, value = 0, value2 = 0,type = 0} },
}


return GameDefine