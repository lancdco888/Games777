-- 鱼种配置表，提供给鱼配置使用

-------------------------------------------------------
-- group: 鱼的分类, 1:一般鱼, 2: 彩金鱼, 3:特殊鱼
-- name: 鱼的名字
-- desc: 鱼的描述信息，多行使用 [[]] 这种格式, 普通鱼和彩金鱼可以使用空
-- icon: 鱼的图片
-- coins: 倍率
-- background : 背景图, 1: 普通鱼背景, 2:黄色背景, 3:红色背景, 4:特殊鱼背景
-- --games: 需要显示的游戏, 如 {101, 102}, 不配置该字段代表所有游戏都显示
-- tag 标签, 1 boss, 2 海王
-------------------------------------------------------

local cfg = {
    --------------------------------------- 普通鱼 ---------------------------------------
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "迦魶鱼",
        desc = "",
        icon = "yuzhong_011.png",
        coins = {2, 2},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},

        name = "小丑鱼",
        desc = "",
        icon = "yuzhong_02.png",
        coins = {3, 3},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "碟鱼",
        desc = "",
        icon = "yuzhong_03.png",
        coins = {4, 4},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "河豚",
        desc = "",
        icon = "yuzhong_04.png",
        coins = {5, 5},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "狮子鱼",
        desc = "",
        icon = "yuzhong_05.png",
        coins = {6, 6},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "比目鱼",
        desc = "",
        icon = "yuzhong_06.png",
        coins = {7, 7},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "龙虾",
        desc = "",
        icon = "yuzhong_07.png",
        coins = {8, 8},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "旗鱼",
        desc = "",
        icon = "yuzhong_08.png",
        coins = {9, 9},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "小水母",
        desc = "",
        icon = "yuzhong_19.png",
        coins = {10, 10},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "章鱼",
        desc = "",
        icon = "yuzhong_09.png",
        coins = {10, 10},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "灯笼鱼",
        desc = "",
        icon = "yuzhong_10.png",
        coins = {12, 12},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "乌龟",
        desc = "",
        icon = "yuzhong_11.png",
        coins = {15, 15},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "锯齿鲨",
        desc = "",
        icon = "yuzhong_12.png",
        coins = {18, 18},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "蝠鲼",
        desc = "",
        icon = "yuzhong_13.png",
        coins = {20, 20},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "巨大小丑鱼",
        desc = "",
        icon = "yuzhong_14.png",
        coins = {10, 25},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "巨大河豚",
        desc = "",
        icon = "yuzhong_18.png",
        coins = {10, 25},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "巨大鲽鱼",
        desc = "",
        icon = "yuzhong_17.png",
        coins = {15, 30},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "鲨鱼",
        desc = "",
        icon = "yuzhong_15.png",
        coins = {25, 40},
        background = 1
    },
    {
        group = 1,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "鲸鱼",
        desc = "",
        icon = "yuzhong_16.png",
        coins = {30, 60},
        background = 1
    },



    --昌盛
    {
        group = 1,
        games = {114},
        name = "小暗红鱼",
        desc = "",
        icon = "fish_type1.png",
        coins = {2, 2},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "小红鱼",
        desc = "",
        icon = "fish_type3.png",
        coins = {2, 2},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "小黄虫",
        desc = "",
        icon = "fish_type4.png",
        coins = {2, 2},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "小蓝鲽鱼",
        desc = "",
        icon = "fish_type7.png",
        coins = {2, 2},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "小绿鱼",
        desc = "",
        icon = "fish_type11.png",
        coins = {2, 2},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "龙虾",
        desc = "",
        icon = "fish_type19.png",
        coins = {2, 2},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "小黄鲽鱼",
        desc = "",
        icon = "fish_type5.png",
        coins = {3, 3},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "小黄鱼",
        desc = "",
        icon = "fish_type6.png",
        coins = {3, 3},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "红斑鱼",
        desc = "",
        icon = "fish_type25.png",
        coins = {3, 3},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "气泡鱼",
        desc = "",
        icon = "fish_type15.png",
        coins = {4, 4},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "斑纹鱼",
        desc = "",
        icon = "fish_type21.png",
        coins = {4, 4},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "粉红蝴蝶",
        desc = "",
        icon = "fish_type33.png",
        coins = {4, 4},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "螃蟹",
        desc = "",
        icon = "fish_type17.png",
        coins = {5, 5},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "刀鱼",
        desc = "",
        icon = "fish_type37.png",
        coins = {5, 5},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "灰色乌贼",
        desc = "",
        icon = "fish_type43.png",
        coins = {5, 5},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "小丑鱼",
        desc = "",
        icon = "fish_type2.png",
        coins = {6, 6},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "小青鱼",
        desc = "",
        icon = "fish_type12.png",
        coins = {6, 6},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "青鱼",
        desc = "",
        icon = "fish_type14.png",
        coins = {6, 6},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "红色小丑鱼",
        desc = "",
        icon = "fish_type27.png",
        coins = {7, 7},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "粉色飞虫",
        desc = "",
        icon = "fish_type32.png",
        coins = {7, 7},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "刺鲨",
        desc = "",
        icon = "fish_type35.png",
        coins = {7, 7},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "小蓝鱼",
        desc = "",
        icon = "fish_type10.png",
        coins = {8, 8},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "河豚",
        desc = "",
        icon = "fish_type23.png",
        coins = {8, 8},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "大黄色蝴蝶鱼",
        desc = "",
        icon = "fish_type86.png",
        coins = {8, 8},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "斑纹鱼2",
        desc = "",
        icon = "fish_type22.png",
        coins = {9, 9},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "灯笼鱼",
        desc = "",
        icon = "fish_type34.png",
        coins = {9, 9},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "海星",
        desc = "",
        icon = "fish_type78.png",
        coins = {9, 9},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "小红龟",
        desc = "",
        icon = "fish_type8.png",
        coins = {10, 10},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "乌龟",
        desc = "",
        icon = "fish_type13.png",
        coins = {10, 10},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "章鱼",
        desc = "",
        icon = "fish_type20.png",
        coins = {10, 10},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "红色灯笼鱼",
        desc = "",
        icon = "fish_type26.png",
        coins = {12, 12},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "灰色鲽鱼",
        desc = "",
        icon = "fish_type42.png",
        coins = {12, 12},
        background = 1
    },
    {
        group = 1,
        games = {112},
        name = "黄金灯笼鱼",
        desc = "",
        icon = "fish_type64.png",
        coins = {12, 12},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "彩色蝴蝶鱼",
        desc = "",
        icon = "fish_type85.png",
        coins = {12, 12},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "黑色灯笼鱼",
        desc = "",
        icon = "fish_type24.png",
        coins = {15, 15},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "蝴蝶",
        desc = "",
        icon = "fish_type39.png",
        coins = {15, 15},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "灰色斑鱼",
        desc = "",
        icon = "fish_type58.png",
        coins = {15, 15},
        background = 1
    },
    {
        group = 1,
        games = {112},
        name = "黄金斑纹鲨",
        desc = "",
        icon = "fish_type65.png",
        coins = {15, 15},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "墨鱼",
        desc = "",
        icon = "fish_type18.png",
        coins = {18, 18},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "壁虎",
        desc = "",
        icon = "fish_type36.png",
        coins = {18, 18},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "剑鱼",
        desc = "",
        icon = "fish_type44.png",
        coins = {18, 18},
        background = 1
    },
    {
        group = 1,
        games = {112},
        name = "黄金旗鱼",
        desc = "",
        icon = "fish_type66.png",
        coins = {18, 18},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "旗鱼",
        desc = "",
        icon = "fish_type16.png",
        coins = {20, 20},
        background = 1
    },
    {
        group = 1,
        games = {121},
        name = "金龟",
        desc = "",
        icon = "fish_type28.png",
        coins = {20, 20},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "紫色蝠鱼",
        desc = "",
        icon = "fish_type57.png",
        coins = {20, 20},
        background = 1
    },
    {
        group = 1,
        games = {112},
        name = "黄金蝙蝠鱼",
        desc = "",
        icon = "fish_type67.png",
        coins = {20, 20},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "黄色机器人",
        desc = "",
        icon = "fish_type79.png",
        coins = {20, 20},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "蝠鱼",
        desc = "",
        icon = "fish_type38.png",
        coins = {25, 25},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "白色鲨鱼2",
        desc = "",
        icon = "fish_type55.png",
        coins = {25, 25},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "蓝色机器人",
        desc = "",
        icon = "fish_type80.png",
        coins = {25, 25},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "灰色蝾螈",
        desc = "",
        icon = "fish_type81.png",
        coins = {25, 25},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "白鲨",
        desc = "",
        icon = "fish_type45.png",
        coins = {30, 30},
        background = 1
    },
    {
        group = 1,
        games = {110,112},
        name = "黄色鲨鱼2",
        desc = "",
        icon = "fish_type56.png",
        coins = {30, 30},
        background = 1
    },
    {
        group = 1,
        games = {112},
        name = "黄金虎鲨",
        desc = "",
        icon = "fish_type68.png",
        coins = {30, 30},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "古铜色蝾螈",
        desc = "",
        icon = "fish_type82.png",
        coins = {30, 30},
        background = 1
    },
    {
        group = 1,
        games = {109,111,113,115,116,117,118,119,120,121,122},
        name = "黄金鲨鱼",
        desc = "",
        icon = "fish_type41.png",
        coins = {35, 35},
        background = 1
    },
    {
        group = 1,
        games = {110,113,116,121},
        name = "小海豚",
        desc = "",
        icon = "fish_type9.png",
        coins = {40, 300},
        background = 1
    },
    {
        group = 1,
        games = {111},
        name = "绿三角龙",
        desc = "",
        icon = "fish_type60.png",
        coins = {40, 40},
        background = 1
    },
    {
        group = 1,
        games = {112},
        name = "黄金海豚",
        desc = "",
        icon = "fish_type69.png",
        coins = {40, 40},
        background = 1
    },
    {
        group = 1,
        games = {119},
        name = "翡翠玄武",
        desc = "",
        icon = "fish_type90.png",
        coins = {100, 100},
        background = 1
    },
    {
        group = 1,
        games = {111},
        name = "银三角龙",
        desc = "",
        icon = "fish_type61.png",
        coins = {120, 120},
        background = 1
    },
    {
        group = 1,
        games = {113},
        name = "红色飞鱼",
        desc = "",
        icon = "fish_type77.png",
        coins = {120, 120},
        background = 1
    },
    {
        group = 1,
        games = {119},
        name = "白银玄武",
        desc = "",
        icon = "fish_type91.png",
        coins = {120, 120},
        background = 1
    },
    {
        group = 1,
        games = {117},
        name = "绿鳄鱼",
        desc = "",
        icon = "fish_type115.png",
        coins = {120, 120},
        background = 1
    },
    {
        group = 1,
        games = {117},
        name = "红鳄鱼",
        desc = "",
        icon = "fish_type113.png",
        coins = {150, 150},
        background = 1
    },
    {
        group = 1,
        games = {115},
        name = "蓝色鲨鱼",
        desc = "",
        icon = "fish_type29.png",
        coins = {40, 200},
        background = 1
    },
    {
        group = 1,
        games = {121},
        name = "白色美人鱼",
        desc = "",
        icon = "fish_type30.png",
        coins = {200, 200},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "黄色蝾螈",
        desc = "",
        icon = "fish_type83.png",
        coins = {200, 200},
        background = 1
    },
    {
        group = 1,
        games = {121},
        name = "金色美人鱼",
        desc = "",
        icon = "fish_type31.png",
        coins = {300, 300},
        background = 1
    },
    {
        group = 1,
        games = {116,117},
        name = "鳄鱼",
        desc = "",
        icon = "fish_type47.png",
        coins = {300, 300},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "蓝色飞龙",
        desc = "",
        icon = "fish_type48.png",
        coins = {300, 300},
        background = 1
    },
    {
        group = 1,
        games = {109},
        name = "铁甲兽",
        desc = "",
        icon = "fish_type51.png",
        coins = {150, 300},
        background = 1
    },
    {
        group = 1,
        games = {109,110,112,120},
        name = "黄金大鲨鱼",
        desc = "",
        icon = "fish_type52.png",
        coins = {300, 300},
        background = 1
    },
    {
        group = 1,
        games = {119},
        name = "黄金玄武",
        desc = "",
        icon = "fish_type92.png",
        coins = {120, 300},
        background = 1
    },
    {
        group = 1,
        games = {120},
        name = "金蟾",
        desc = "",
        icon = "fish_type95.png",
        coins = {100, 300},
        background = 1
    },
    {
        group = 1,
        games = {117},
        name = "金鳄鱼",
        desc = "",
        icon = "fish_type114.png",
        coins = {200, 280},
        background = 1
    },
    {
        group = 1,
        games = {118},
        name = "企鹅",
        desc = "",
        icon = "Image_2D_1150_2333.png",
        coins = {320, 320},
        background = 1
    },
    {
        group = 1,
        games = {111},
        name = "金三角龙",
        desc = "",
        icon = "fish_type62.png",
        coins = {40, 380},
        background = 1
    },
    {
        group = 1,
        games = {121},
        name = "黄金美人鱼2",
        desc = "",
        icon = "fish_type123.png",
        coins = {400, 400},
        background = 1
    },
    {
        group = 1,
        games = {122},
        name = "黄金铁甲鲨鱼",
        desc = "",
        icon = "fish_type40.png",
        coins = {200, 500},
        background = 1
    },
    {
        group = 1,
        games = {118},
        name = "李逵",
        desc = "",
        icon = "fish_type49.png",
        coins = {200, 500},
        background = 1
    },
    {
        group = 1,
        games = {110,112,118,120},
        name = "金龙",
        desc = "",
        icon = "fish_type50.png",
        coins = {300, 500},
        background = 1
    },
    {
        group = 1,
        games = {115},
        name = "羊",
        desc = "",
        icon = "fish_type72.png",
        coins = {200, 500},
        background = 1
    },
    {
        group = 1,
        games = {122},
        name = "黄金铁甲飞龙",
        desc = "",
        icon = "fish_type98.png",
        coins = {300, 500},
        background = 1
    },
    --109组合鱼
    {
        --三个鱼组合
        group = 1,
        games = {109},
        name = "组合鱼1",
        desc = "",
        icon = "yuzhong_15_15_20.png",
        -- coins = {15, 15, 20},
        coins = {15, 20},
        background = 1
    },
    {
        --四个鱼组合
        group = 1,
        games = {109},
        name = "组合鱼2",
        desc = "",
        icon = "yuzhong_24_28_32.png",
        -- coins = {24, 28, 32},
        coins = {24, 32},
        background = 1
    },
    --110组合鱼
    {
        --三个鱼组合
        group = 1,
        games = {110},
        name = "组合鱼3",
        desc = "",
        icon = "yuzhong_d_12_15_21.png",
        -- coins = {12, 15, 21},
        coins = {12, 21},
        background = 1
    },
    {
        --四个鱼组合
        group = 1,
        games = {110},
        name = "组合鱼4",
        desc = "",
        icon = "yuzhong_d_24_32_40.png",
        -- coins = {24, 32, 40},
        coins = {24, 40},
        background = 1
    },
    {
        --5个鱼组合
        group = 1,
        games = {110},
        name = "组合鱼5",
        desc = "",
        icon = "yuzhong_52.png",
        coins = {50, 50},
        background = 1
    },
    {
        --6个鱼组合
        group = 1,
        games = {110},
        name = "组合鱼6",
        desc = "",
        icon = "yuzhong_80.png",
        coins = {80, 80},
        background = 1
    },
    --111组合鱼
    {
        --三角形主鱼三角龙
        group = 1,
        games = {111},
        name = "组合鱼7",
        desc = "",
        icon = "yuzhong_55.png",
        coins = {55, 55},
        background = 1
    },
    {
        --5个鱼组合
        group = 1,
        games = {111},
        name = "组合鱼8",
        desc = "",
        icon = "yuzhong_62.png",
        coins = {62, 62},
        background = 1
    },
    {
        --6个鱼组合
        group = 1,
        games = {111},
        name = "组合鱼9",
        desc = "",
        icon = "yuzhong_70.png",
        coins = {70, 70},
        background = 1
    },
    {
        --三角形主鱼葫芦组合
        group = 1,
        games = {111},
        name = "组合鱼10",
        desc = "",
        icon = "yuzhong_200.png",
        coins = {200, 200},
        background = 1
    },
    --113组合鱼
    {
        --乌龟组合
        group = 1,
        games = {113},
        name = "组合鱼11",
        desc = "",
        icon = "yuzhong_40.png",
        coins = {40, 40},
        background = 1
    },
    {
        --龙虾组合
        group = 1,
        games = {113},
        name = "组合鱼12",
        desc = "",
        icon = "yuzhong_300.png",
        coins = {300, 300},
        background = 1
    },
    --116组合鱼
    {
        --灯笼鱼组合
        group = 1,
        games = {116},
        name = "组合鱼13",
        desc = "",
        icon = "hdc_yz_4.png",
        coins = {16, 16},
        background = 1
    },
    {
        --乌龟、小绿鱼组合
        group = 1,
        games = {116},
        name = "组合鱼14",
        desc = "",
        icon = "hdc_yz_5.png",
        coins = {22, 22},
        background = 1
    },
    {
        --乌龟、小蓝鱼组合
        group = 1,
        games = {116},
        name = "组合鱼15",
        desc = "",
        icon = "hdc_yz_6.png",
        coins = {28, 28},
        background = 1
    },
    {
        --白鲨、小黄鱼组合
        group = 1,
        games = {116},
        name = "组合鱼16",
        desc = "",
        icon = "hdc_yz_7.png",
        coins = {36, 36},
        background = 1
    },
    {
        --旗鱼组合
        group = 1,
        games = {116},
        name = "组合鱼17",
        desc = "",
        icon = "hdc_yz_8.png",
        coins = {42, 42},
        background = 1
    },
    {
        --蝠鱼组合
        group = 1,
        games = {116},
        name = "组合鱼18",
        desc = "",
        icon = "hdc_yz_9.png",
        coins = {50, 50},
        background = 1
    },
    {
        --金鲨组合
        group = 1,
        games = {116},
        name = "组合鱼19",
        desc = "",
        icon = "hdc_yz_10.png",
        coins = {64, 64},
        background = 1
    },
    {
        --白鲨、灰色鲽鱼组合
        group = 1,
        games = {116},
        name = "组合鱼20",
        desc = "",
        icon = "hdc_yz_2.png",
        coins = {72, 72},
        background = 1
    },
    {
        --白鲨、旗鱼组合
        group = 1,
        games = {116},
        name = "组合鱼21",
        desc = "",
        icon = "hdc_yz_3.png",
        coins = {80, 80},
        background = 1
    },
    {
        --海盗船组合
        group = 1,
        games = {116},
        name = "组合鱼22",
        desc = "",
        icon = "hdc_yz_1.png",
        coins = {160, 500},
        background = 1
    },
    --117组合鱼
    {
        --闪电盘组合
        group = 1,
        games = {117},
        name = "组合鱼23",
        desc = "",
        icon = "ssey_yz_1.png",
        coins = {60, 60},
        background = 1
    },
    {
        --金鲨组合
        group = 1,
        games = {117},
        name = "组合鱼24",
        desc = "",
        icon = "ssey_yz_2.png",
        coins = {100, 100},
        background = 1
    },
    {
        --鳄鱼组合
        group = 1,
        games = {117},
        name = "组合鱼25",
        desc = "",
        icon = "ssey_yz_3.png",
        coins = {204, 204},
        background = 1
    },
    --118组合鱼
    {
        --3个鱼组合
        group = 1,
        games = {118},
        name = "组合鱼26",
        desc = "",
        icon = "yuzhong_12_15_21.png",
        -- coins = {12, 15, 21},
        coins = {12, 21},
        background = 1
    },
    {
        --4个鱼组合
        group = 1,
        games = {118},
        name = "组合鱼27",
        desc = "",
        icon = "yuzhong_24_32_40.png",
        -- coins = {24, 32, 40},
        coins = {24, 40},
        background = 1
    },
    --119组合鱼
    {
        --屠龙宝刀组合
        group = 1,
        games = {119},
        name = "组合鱼28",
        desc = "",
        icon = "ssg_yz_1.png",
        coins = {60, 60},
        background = 1
    },
    {
        --金鲨组合
        group = 1,
        games = {119},
        name = "组合鱼29",
        desc = "",
        icon = "ssg_yz_2.png",
        coins = {100, 100},
        background = 1
    },
    {
        --白银乌龟组合
        group = 1,
        games = {119},
        name = "组合鱼30",
        desc = "",
        icon = "ssg_yz_3.png",
        coins = {174, 174},
        background = 1
    },
    --120组合鱼
    {
        --3个鱼组合
        group = 1,
        games = {120,122},
        name = "组合鱼31",
        desc = "",
        icon = "yuzhong_18_24_30.png",
        -- coins = {18, 24, 30},
        coins = {18, 30},
        background = 1
    },
    {
        --4个鱼组合
        group = 1,
        games = {120,122},
        name = "组合鱼32",
        desc = "",
        icon = "yuzhong_48_60_72.png",
        -- coins = {48, 60, 72},
        coins = {48, 72},
        background = 1
    },
    --121组合鱼
    {
        --3个小丑鱼组合
        group = 1,
        games = {121},
        name = "组合鱼33",
        desc = "",
        icon = "hjmry_yz_1.png",
        coins = {18, 18},
        background = 1
    },
    {
        --3个小蓝鱼组合
        group = 1,
        games = {121},
        name = "组合鱼34",
        desc = "",
        icon = "hjmry_yz_2.png",
        coins = {24, 24},
        background = 1
    },
    {
        --3个乌龟组合
        group = 1,
        games = {121},
        name = "组合鱼35",
        desc = "",
        icon = "hjmry_yz_3.png",
        coins = {30, 30},
        background = 1
    },
    {
        --三个蝴蝶组合
        group = 1,
        games = {121},
        name = "组合鱼36",
        desc = "",
        icon = "hjmry_yz_4.png",
        coins = {45, 45},
        background = 1
    },
    {
        --三个旗鱼组合
        group = 1,
        games = {121},
        name = "组合鱼37",
        desc = "",
        icon = "hjmry_yz_5.png",
        coins = {60, 60},
        background = 1
    },
    {
        --四个刀鱼组合
        group = 1,
        games = {121},
        name = "组合鱼38",
        desc = "",
        icon = "hjmry_yz_6.png",
        coins = {20, 20},
        background = 1
    },
    {
        --四个刺鲨组合
        group = 1,
        games = {121},
        name = "组合鱼39",
        desc = "",
        icon = "hjmry_yz_7.png",
        coins = {28, 28},
        background = 1
    },
    {
        --四个灰色鲽鱼组合
        group = 1,
        games = {121},
        name = "组合鱼40",
        desc = "",
        icon = "hjmry_yz_8.png",
        coins = {48, 48},
        background = 1
    },
    {
        --四个墨鱼组合
        group = 1,
        games = {121},
        name = "组合鱼41",
        desc = "",
        icon = "hjmry_yz_9.png",
        coins = {72, 72},
        background = 1
    },
    {
        --四个蝠鱼组合
        group = 1,
        games = {121},
        name = "组合鱼42",
        desc = "",
        icon = "hjmry_yz_10.png",
        coins = {100, 100},
        background = 1
    },
    --炸弹
    {
        group = 1,
        games = {109},
        name = "全屏炸弹",
        desc = "",
        icon = "fish_type54.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {110,113,116},
        name = "定时炸弹",
        desc = "",
        icon = "fish_type59.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {111},
        name = "葫芦",
        desc = "",
        icon = "fish_type63.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {112},
        name = "神龙宝藏",
        desc = "",
        icon = "fish_type70.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "圆盘炸弹",
        desc = "",
        icon = "fish_type109.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {115},
        name = "炸弹鳄鱼",
        desc = "",
        icon = "fish_type73.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {117},
        name = "深海炸弹",
        desc = "",
        icon = "fish_type112.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {118},
        name = "全屏炸弹2",
        desc = "",
        icon = "fish_type88.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {119},
        name = "屠龙宝刀",
        desc = "",
        icon = "Image_2D_0038_0108.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {120},
        name = "金蟾炸弹",
        desc = "",
        icon = "fish_type97.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {121},
        name = "深海鱼雷",
        desc = "",
        icon = "fish_type118.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {122},
        name = "龙鲨炸弹",
        desc = "",
        icon = "Image_2D_0472_0988.png",
        coins = {-1, -1},
        background = 1
    },
    --旋风鱼
    {
        group = 1,
        games = {109},
        name = "一箭双雕",
        desc = "",
        icon = "fish_type124.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {110},
        name = "追风逐月",
        desc = "",
        icon = "fish_type101.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {111},
        name = "旋风鱼哪吒",
        desc = "",
        icon = "fish_type102.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {113},
        name = "同类炸弹",
        desc = "",
        icon = "fish_type108.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {112},
        name = "海纳百川",
        desc = "",
        icon = "fish_type107.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "响震四方",
        desc = "",
        icon = "fish_type110.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {115},
        name = "横扫千军",
        desc = "",
        icon = "fish_type111.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {116,117},
        name = "百发百中",
        desc = "",
        icon = "fish_type119.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {118},
        name = "旋风斧",
        desc = "",
        icon = "fish_type125.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {119},
        name = "漂流瓶",
        desc = "",
        icon = "fish_type116.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {120},
        name = "出奇制胜",
        desc = "",
        icon = "fish_type120.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {121,122},
        name = "应有尽有",
        desc = "",
        icon = "fish_type117.png",
        coins = {-1, -1},
        background = 1
    },
    --海藻
    {
        group = 1,
        games = {109,110,111,113,112,115,116,117,118,119,120,122},
        name = "海草",
        desc = "",
        icon = "fish_type53.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {121},
        name = "宝箱",
        desc = "",
        icon = "fish_type100.png",
        coins = {-1, -1},
        background = 1
    },
    {
        group = 1,
        games = {114},
        name = "礼盒",
        desc = "",
        icon = "fish_type84.png",
        coins = {-1, -1},
        background = 1
    },
    





    --------------------------------------- 彩金鱼 ---------------------------------------
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "大盘鱼1",
        desc = "",
        icon = "yuzhong_caijingyu_02.png",
        coins = {50, 50},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "大盘鱼2",
        desc = "",
        icon = "yuzhong_caijingyu_03.png",
        coins = {50, 50},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "大盘鱼3",
        desc = "",
        icon = "yuzhong_caijingyu_04.png",
        coins = {60, 60},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "大盘鱼4",
        desc = "",
        icon = "yuzhong_caijingyu_05.png",
        coins = {80, 80},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "大盘鱼5",
        desc = "",
        icon = "yuzhong_caijingyu_11.png",
        coins = {110, 110},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "大盘鱼6",
        desc = "",
        icon = "yuzhong_caijingyu_15.png",
        coins = {120, 120},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "大盘鱼7",
        desc = "",
        icon = "yuzhong_caijingyu_14.png",
        coins = {200, 200},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "黄金小丑鱼",
        desc = "",
        icon = "yuzhong_caijingyu_01.png",
        coins = {60, 60},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "黄金碟鱼",
        desc = "",
        icon = "yuzhong_caijingyu_10.png",
        coins = {100, 100},
        background = 2
    },
    
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "黄金河豚",
        desc = "",
        icon = "yuzhong_caijingyu_12.png",
        coins = {120, 120},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "黄金鲨鱼",
        desc = "",
        icon = "yuzhong_caijingyu_06.png",
        coins = {140, 140},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "黄金杀人鲸鱼",
        desc = "",
        icon = "yuzhong_caijingyu_13.png",
        coins = {160, 160},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "聚财元宵",
        desc = "",
        icon = "yuzhong_caijinyu_27.png",
        coins = {100, 300},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "小丑鱼学徒",
        desc = "",
        icon = "yuzhong_caijinyu_24.png",
        coins = {100, 250},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "福旺财神",
        desc = "",
        icon = "yuzhong_caijinyu_30.png",
        coins = {200, 600},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "凌云飞马",
        desc = "",
        icon = "yuzhong_caijinyu_25.png",
        coins = {100, 300},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "小年兽",
        desc = "",
        icon = "yuzhong_caijinyu_32.png",
        coins = {100, 300},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "炸弹快艇",
        desc = "",
        icon = "yuzhong_caijinyu_28.png",
        coins = {200, 400},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "财神爷",
        desc = "",
        icon = "yuzhong_caishenye.png",
        coins = {200, 600},
        background = 2
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "暗夜巨兽",
        desc = "",
        icon = "yuzhong_caijingyu_17.png",
        coins = {100, 450},
        --games = {146, 144, 143, 142, 141, 107},
        tag = 2,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "虎头鲨",
        desc = "",
        icon = "yuzhong_caijingyu_24.png",
        coins = {120, 350},
        --games = {146, 145,144, 143, 142, 141, 102, 103, 108},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "霸王鲸",
        desc = "",
        icon = "yuzhong_caijingyu_07.png",
        coins = {200, 500},
        --games = {146, 145,144, 143, 142, 141,106, 104,101},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "霸王蟹",
        desc = "",
        icon = "yuzhong_caijingyu_08.png",
        coins = {150, 500},
        --games = {145, 104},
        tag = 2,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "赤焰龙龟",
        desc = "",
        icon = "yuzhong_caijingyu_16.png",
        coins = {200, 600},
        --games = {146,145,108,105,103},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "大王乌贼",
        desc = "",
        icon = "yuzhong_caijingyu_09.png",
        coins = {250, 550},
        --games = {146, 145,144, 143, 142, 141,101,102,105},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "电光水母",
        desc = "",
        icon = "yuzhong_caijinyu_19.png",
        coins = {200, 400},
        --games = {146, 145,144, 143, 142, 141,101,104,107},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "龙虾将军",
        desc = "",
        icon = "yuzhong_caijinyu_20.png",
        coins = {100, 500},
        --games = {146, 145,144, 143, 142, 141,101,105},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "招财宝蟾",
        desc = "",
        icon = "yuzhong_caijinyu_33.png", 
        coins = {100, 500},
        --games = {146,145},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "冥焰赤龙",
        desc = "",
        icon = "yuzhong_mingyanchilong_36.png",  
        coins = {300, 1000},
        --games = {146, 145,144, 143, 142, 141},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "蛮荒凶兽",
        desc = "",
        icon = "yuzhong_caijinyu_35.png",  
        coins = {200, 600},
        --games = {146,145,142},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "金色龙虾将军",
        desc = "",
        icon = "yuzhong_caijinyu_34.png",  
        coins = {300, 600},
        --games = {146, 145,144, 143, 142, 141},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "史前巨鳄",
        desc = "",
        icon = "yuzhong_caijingyu_22.png",
        coins = {100, 600},
        --games = {146, 145,144, 143, 142, 141,106},
        tag = 2,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "八爪章鱼",
        desc = "",
        icon = "yuzhong_caijinyu_18.png",
        coins = {200, 500},
        --games = {145,102},
        tag = 2,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "狂暴火龙",
        desc = "",
        icon = "yuzhong_caijingyu_21.png",
        coins = {300, 1000},
        --games = {146, 145,144, 143, 142, 141,107,106,103},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "海王荣耀",
        desc = "",
        icon = "yuzhong_176.png",
        coins = {200, 1000},
        --games = {146,145,144, 143, 142, 141,108,102},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "雷霸龙",
        desc = "",
        icon = "yuzhong_caijingyu_23.png",
        coins = {300, 800},
        --games = {146,145,144, 143, 142, 141,140,104,105,108},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "觉醒暗夜巨兽",
        desc = "",
        icon = "yuzhong_juexinganyejushou.png",
        coins = {300, 800},
        --games = {146,140},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "觉醒霸王蟹",
        desc = "",
        icon = "yuzhong_juexingbawangxie.png",
        coins = {300, 800},
        --games = {146,140},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "觉醒八爪章鱼",
        desc = "",
        icon = "yuzhong_juexingbazhuazhangyu.png",
        coins = {300, 800},
        --games = {146,140},
        tag = 1,
        background = 3
    },
    {
        group = 2,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = "觉醒史前巨鳄",
        desc = "",
        icon = "yuzhong_juexingshiqianjue.png",
        coins = {300, 800},
        --games = {146,140},
        tag = 1,
        background = 3
    },
    --------------------------------------- 特殊鱼 ---------------------------------------
    {
        group = 3,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = TR("紫晶人鱼"), --紫晶人鱼
        desc = TR("会发出天籁之声的传奇生物，捕获后可获得全屏攻击效果。"),
        icon = "yuzhong_caijinyu_22_2.png", 
        coins = {100, 300},
        --games = {146,145,140},
        background = 4
    },
    {
        group = 3,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = TR("闪电鲨"), --闪电鲨
        desc = TR("释放闪电攻击周围的鱼"),
        icon = "yuzhong_teshuyu_06.png",
        coins = {100, 100},
        background = 4
    },
    {
        group = 3,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = TR("旋风鱼"), --旋风鱼
        desc = TR("捕获后可同时捕获其他全部同种类型的鱼"),
        icon = "yuzhong_teshuyu_05.png",
        coins = {100, 100},
        background = 4
    },
    {
        group = 3,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = TR("钻头蟹"), --钻头蟹
        desc = TR("获得一个免费的钻头弹可来回穿透，最后爆炸"),
        icon = "yuzhong_teshuyu_04.png",
        coins = {200, 200},
        background = 4
    },
    {
        group = 3,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = TR("炸弹蟹"), --炸弹蟹
        desc = TR("捕获可引发大爆炸效果"),
        icon = "yuzhong_teshuyu_08.png",
        coins = {300, 300},
        background = 4
    },
    {
        group = 3,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = TR("南瓜"), --南瓜
        desc = TR("跳来跳去的南瓜"),
        icon = "yuzhong_nanguasanxiongdi.png",
        coins = {100, 500},
        background = 4
    },
    {
        group = 3,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = TR("连环炸弹蟹"), --连环炸弹蟹
        desc = TR("可以引发好几次爆炸效果"),
        icon = "yuzhong_teshuyu_09.png",
        coins = {200, 500},
        background = 4
    },
    {
        group = 3,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = TR("烈焰风暴"), --烈焰风暴
        desc = TR("捕获可获得一段时间免费游戏"),
        icon = "yuzhong_teshuyu_01.png",
        coins = {200, 200},
        background = 4
    },
    {
        group = 3,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = TR("神龙转盘"), --神龙转盘
        desc = TR("三层转轮游戏，挑战最大奖！"),
        icon = "yuzhong_173.png",
        coins = {100, 1000},
        background = 4
    },
    {
        group = 3,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = TR("猫大爷"), --猫大爷
        desc = TR("获得6次免费猜奖游戏！"),
        icon = "yuzhong_175.png",
        coins = {100, 500},
        --games = {146,145,143,141,140,108,106,104,102},
        background = 4
    },
    {
        group = 3,
        games = {101, 102, 103, 104, 105, 106,107,108,140,141,142,143,144,145,146},
        name = TR("凤凰"), --凤凰
        desc = TR("传说中的神秘生物，大范围的全屏攻击！"),
        icon = "yuzhong_174.png",
        coins = {250, 600},
        --games = {146,145,106,103},
        background = 4
    }
    
}

return cfg
