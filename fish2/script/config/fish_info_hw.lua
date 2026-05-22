-- config/fish_info_hw.lua

local fishInfo = {
    -----------------------------------普通鱼------------------------------------------
    -- 迦魶鱼
    GhanaFish = {
        typeId = 0,
        name = "GhanaFish",
        coin = {2, 2},
        priority = 2,
        isCycleFish = false,
        actionFile = "actions/general/jianayu.actions",
        z = 11, --配置层级，越大越在上面
        deathMusic = "najiayu_sound_die",
    },
    -- 小丑鱼
    ClownFish = {
        typeId = 1,
        name = "ClownFish",
        coin = {3, 3},
        priority = 3,
        isCycleFish = false,
        actionFile = "actions/general/xiaochouyu.actions",
        z = 11,
        deathMusic = "cha18_14_ch",
    },
    -- 碟鱼
    DishFish = {
        typeId = 2,
        name = "DishFish",
        coin = {4, 4},
        priority = 4,
        isCycleFish = false,
        actionFile = "actions/general/dieyu.actions",
        z = 11,
        deathMusic = "dieyu_sound_die",
    },
    -- 河豚
    Puffer = {
        typeId = 3,
        name = "Puffer",
        coin = {5, 5},
        priority = 5,
        isCycleFish = false,
        actionFile = "actions/general/xiaohetun.actions",
        z = 12,
        deathMusic = "hetun_sound_die",
    },
    -- 狮子鱼
    LionFish = {
        typeId = 4,
        name = "LionFish",
        coin = {6, 6},
        priority = 6,
        isCycleFish = false,
        actionFile = "actions/general/shiziyu.actions",
        z = 12,
        deathMusic = "shiziyu_sound_die",
    },
    -- 比目鱼
    OtterFish = {
        typeId = 5,
        name = "OtterFish",
        coin = {7, 7},
        priority = 7,
        isCycleFish = false,
        actionFile = "actions/general/bimuyu.actions",
        z = 12,
        deathMusic = "bimuyu_sound_die",
    },
    -- 龙虾
    Lobster = {
        typeId = 6,
        name = "Lobster",
        coin = {8, 8},
        priority = 8,
        isCycleFish = false,
        actionFile = "actions/general/longxia.actions",
        z = 0,
        deathMusic = "cha04_13_ch",
    },
    -- 旗鱼
    SailFish = {
        typeId = 7,
        name = "SailFish",
        coin = {9, 9},
        priority = 9,
        isCycleFish = false,
        actionFile = "actions/general/qiyu.actions",
        z = 12,
        deathMusic = "qiyu_sound_die",
    },
    -- 小水母
    JellyFish = {
        typeId = 8,
        name = "JellyFish",
        coin = {10, 10},
        priority = 10,
        isCycleFish = false,
        actionFile = "actions/general/xiaoshuimu.actions",
        z = 12,
        deathMusic = "shuimu_sound_die",
    },
    -- 章鱼
    OctopusFish = {
        typeId = 9,
        name = "OctopusFish",
        coin = {10, 10},
        priority = 10,
        isCycleFish = false,
        actionFile = "actions/general/zhangyu.actions",
        z = 12,
        deathMusic = "cha24_14_ch",
    },
    -- 灯笼鱼
    LanternFish = {
        typeId = 10,
        name = "LanternFish",
        coin = {12, 12},
        priority = 12,
        isCycleFish = false,
        actionFile = "actions/general/lantern.actions",
        z = 12,
        deathMusic = "cha24_14_ch",
    },
    -- 乌龟
    Tortoise = {
        typeId = 11,
        name = "Tortoise",
        coin = {15, 15},
        priority = 15,
        isCycleFish = false,
        actionFile = "actions/general/seaturtle.actions",
        z = 12,
        deathMusic = "green_turtle_sound_die",
    },
    -- 锯齿鲨
    SawtoothShark = {
        typeId = 12,
        name = "SawtoothShark",
        coin = {18, 18},
        priority = 18,
        isCycleFish = false,
        actionFile = "actions/general/juchiyu.actions",
        z = 12,
        deathMusic = "juchiyu_sound_die",
    },
    -- 蝠鲼
    MantaRay = {
        typeId = 13,
        name = "MantaRay",
        coin = {20, 20},
        priority = 20,
        isCycleFish = false,
        actionFile = "actions/general/fuyu.actions",
        z = 100,
        deathMusic = "fuyu_sound_die",
    },
    -- 巨大小丑鱼
    GiantClownFish = {
        typeId = 14,
        name = "GiantClownFish",
        coin = {10, 25, 5},
        priority = 25,
        isCycleFish = false,
        actionFile = "actions/general/judaxiaochouyu.actions",
        z = 100,
        deathMusic = "judaxiaochouyu_sound_die",
    },
    -- 巨大鲽鱼
    GiantDishFish = {
        typeId = 15,
        name = "GiantDishFish",
        coin = {15, 30, 5},
        priority = 30,
        isCycleFish = false,
        actionFile = "actions/general/judadieyu.actions",
        z = 100,
        deathMusic = "judadieyu_sound_die",
    },
    -- 鲨鱼
    Shark = {
        typeId = 16,
        name = "Shark",
        coin = {25, 40, 5},
        priority = 40,
        isCycleFish = false,
        actionFile = "actions/general/shark.actions",
        z = 100,
        deathMusic = "",
    },
    -- 鲸鱼
    Whale = {
        typeId = 17,
        name = "Whale",
        coin = {30, 60, 10},
        priority = 60,
        isCycleFish = false,
        actionFile = "actions/general/whale.actions",
        --actionFile = "spine/Killerwhale.actions",
        --offsetAngle = math.pi,
        z = 101,
        --scale = 0.6,
        deathMusic = "sharenjing_sound_die",
    },
    -- 巨大河豚
    GiantPuffer = {
        typeId = 18,
        name = "GiantPuffer",
        coin = {10, 25, 5},
        priority = 30,
        isCycleFish = false,
        actionFile = "actions/general/judahetun.actions",
        z = 100,
        deathMusic = "",
    },
    -----------------------------------旋风鱼------------------------------------------
    -- 迦魶鱼(旋风鱼)
    Cycle_GhanaFish = {
        typeId = 100,
        name = "Cycle_GhanaFish",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        -- 旋风鱼绑定的鱼类型
        bindFishTypes = {
            100,
            0
        },
        actionFile = "actions/general/jianayu.actions",
        z = 11,
        offset = {-14, 2},
        cycleBgScale = 0.3,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {5, 0}, -- 旋风鱼背景图片偏移量
        deathMusic = "najiayu_sound_die",
    },
    -- 小丑鱼(旋风鱼)
    Cycle_ClownFish = {
        typeId = 101,
        name = "Cycle_ClownFish",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        -- 旋风鱼绑定的鱼类型
        bindFishTypes = {
            101,
            1
        },
        actionFile = "actions/general/xiaochouyu.actions",
        z = 11,
        offset = {-57, 4},
        cycleBgScale = 0.4,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {3, 0}, -- 旋风鱼背景图片偏移量
        deathMusic = "cha18_14_ch",
    },
    -- 碟鱼(旋风鱼)
    Cycle_DishFish = {
        typeId = 102,
        name = "Cycle_DishFish",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        bindFishTypes = {
            102,
            2
        },
        actionFile = "actions/general/dieyu.actions",
        z = 11,
        offset = {-30, 0},
        cycleBgScale = 0.5,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {0, 0}, -- 旋风鱼背景图片偏移量
        deathMusic = "dieyu_sound_die",
    },
    -- 河豚(旋风鱼)
    Cycle_Puffer = {
        typeId = 103,
        name = "Cycle_Puffer",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        bindFishTypes = {
            103,
            3
        },
        actionFile = "actions/general/xiaohetun.actions",
        z = 12,
        offset = {-3, 5},
        cycleBgScale = 0.4,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {5, 0}, -- 旋风鱼背景图片偏移量
        scale = 1.2,
        deathMusic = "hetun_sound_die",
    },
    -- 狮子鱼(旋风鱼)
    Cycle_LionFish = {
        typeId = 104,
        name = "Cycle_LionFish",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        bindFishTypes = {
            104,
            4
        },
        actionFile = "actions/general/shiziyu.actions",
        z = 12,
        offset = {-45, 10},
        cycleBgScale = 0.7,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {0, 0}, -- 旋风鱼背景图片偏移量
        deathMusic = "shiziyu_sound_die",
    },
    -- 比目鱼(旋风鱼)
    Cycle_OtterFish = {
        typeId = 105,
        name = "Cycle_OtterFish",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        bindFishTypes = {
            105,
            5
        },
        actionFile = "actions/general/bimuyu.actions",
        z = 12,
        offset = {-10, 0},
        cycleBgScale = 0.7,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {3, 3}, -- 旋风鱼背景图片偏移量
        deathMusic = "bimuyu_sound_die",
    },
    -- 龙虾(旋风鱼)
    Cycle_Lobster = {
        typeId = 106,
        name = "Cycle_Lobster",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        bindFishTypes = {
            106,
            6
        },
        actionFile = "actions/general/longxia.actions",
        z = 0,
        offset = {-10, 0},
        cycleBgScale = 0.75,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {0, -2}, -- 旋风鱼背景图片偏移量
        deathMusic = "cha04_13_ch",
    },
    -- 旗鱼(旋风鱼)
    Cycle_SailFish = {
        typeId = 107,
        name = "Cycle_SailFish",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        bindFishTypes = {
            107,
            7
        },
        actionFile = "actions/general/qiyu.actions",
        z = 12,
        offset = {-15, 3},
        cycleBgScale = 0.8,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {10, 0}, -- 旋风鱼背景图片偏移量
        scale = 1.2,
        deathMusic = "qiyu_sound_die",
    },
    -- 水母(旋风鱼)
    Cycle_JellyFish = {
        typeId = 108,
        name = "Cycle_JellyFish",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        bindFishTypes = {
            108,
            8
        },
        actionFile = "actions/general/xiaoshuimu.actions",
        z = 12,
        offset = {-15, 3},
        cycleBgScale = 0.8,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {80, 0}, -- 旋风鱼背景图片偏移量
        scale = 1.2,
        deathMusic = "shuimu_sound_die",
    },
    -- 章鱼(旋风鱼)
    Cycle_OctopusFish = {
        typeId = 109,
        name = "Cycle_OctopusFish",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        bindFishTypes = {
            109,
            9
        },
        actionFile = "actions/general/zhangyu.actions",
        z = 12,
        offset = {-32, 5},
        cycleBgScale = 0.85,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {15, -10}, -- 旋风鱼背景图片偏移量
        deathMusic = "cha24_14_ch",
    },
    -- 灯笼鱼(旋风鱼)
    Cycle_LanternFish = {
        typeId = 110,
        name = "Cycle_LanternFish",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        bindFishTypes = {
            110,
            10
        },
        actionFile = "actions/general/lantern.actions",
        z = 12,
        offset = {-15, -10},
        cycleBgScale = 0.75,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {-5, -2}, -- 旋风鱼背景图片偏移量
        deathMusic = "cha24_14_ch",
    },
    -- 乌龟(旋风鱼)
    Cycle_Tortoise = {
        typeId = 111,
        name = "Cycle_Tortoise",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        bindFishTypes = {
            111,
            11
        },
        actionFile = "actions/general/seaturtle.actions",
        z = 12,
        offset = {-5, 0},
        cycleBgScale = 0.9,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {5, 0}, -- 旋风鱼背景图片偏移量
        scale = 1.2,
        deathMusic = "green_turtle_sound_die",
    },
    -- 锯齿鲨(旋风鱼)
    Cycle_SawtoothShark = {
        typeId = 112,
        name = "Cycle_SawtoothShark",
        coin = {50, 50},
        priority = 50,
        isCycleFish = true,
        bindFishTypes = {
            112,
            12
        },
        actionFile = "actions/general/juchiyu.actions",
        z = 12,
        offset = {0, 0},
        cycleBgScale = 0.9,     -- 旋风鱼背景图片缩放
        cycleBgOffset = {-20, 0}, -- 旋风鱼背景图片偏移量
        deathMusic = "juchiyu_sound_die",
    },
    -----------------------------------特殊鱼------------------------------------------
    -- 闪电鲨
    LightningShark = {
        typeId = 200,
        name = "LightningShark",
        coin = {100, 100},
        priority = 100,
        isCycleFish = false,
        actionFile = "actions/special/shandiansha.actions",
        luaName = "shandiansha.lua",
        z = 103,
        deathMusic = "",
        -- 死亡时显示提示
        DeathEffectInfo = {
            banner = "caitiao_shandiansha.png",
            avatar = "texiao_shandiansha.png",
        },
        -- 出生提示
        BornTipsInfo = {
            avatar = "texiao_shandiansha.png",
            tips = "yuzhonglaixi_shandianshalaile.png",
            scale = 0.8,
        },
    },
    -- 钻头蟹
    DrillCarb = {
        typeId = 201,
        name = "DrillCarb",
        coin = {200, 1000},
        --coin = {10, 15},
        priority = 500,
        isCycleFish = false,
        actionFile = "actions/special/zuantouxie.actions",
        luaName = "zuantouxie.lua",
        offsetAngle = math.pi / 2,
        z = 1,
        bornMusic = {
            delayTime = 0.3,
            paths = {
                "HammerCrab_CardAppear",
            },
            probability = 0.3,  -- 播放机率[0, 1]
        },
        deathMusic = "sound_aiguilleget1",
        mustPlayDeathEffect = true, -- 必放死亡音效
        DeathEffectInfo = {
            banner = "caitiao_zuantouxie.png",
            avatar = "texiao_zuantouxie.png",
        },
        -- 出生提示
        BornTipsInfo = {
            avatar = "texiao_zuantouxie.png",
            tips = "yuzhonglaixi_zuantouxielaile.png",
            scale = 0.65,
        },
    },
    -- 炸弹蟹
    BombCarb = {
        typeId = 202,
        name = "BombCarb",
        coin = {300, 500},
        --coin = {30, 30},
        priority = 300,
        isCycleFish = false,
        actionFile = "actions/special/zhadanxie.actions",
        luaName = "zhadanxie.lua",
        offsetAngle = math.pi / 2,
        z = 1,
        deathMusic = "sound_crabboomget_a",
        mustPlayDeathEffect = true, -- 必放死亡音效
        bornMusic = {
            delayTime = 0.3,
            paths = {
                "HammerCrab_CardAppear",
            },
            probability = 0.3,  -- 播放机率[0, 1]
        },
        DeathEffectInfo = {
            banner = "caitiao_zhadanxie.png",
            avatar = "texiao_zhadanxie.png",
        },
        -- 出生提示
        -- BornTipsInfo = {
        --     avatar = "texiao_zhadanxie.png",
        --     tips = "yuzhonglaixi_zhadanxielaile.png",
        --     scale = 0.7,
        -- },
    },
    -- 连环炸弹蟹
    MultipleBombCarb = {
        typeId = 203,
        name = "MultipleBombCarb",
        coin = {200, 900, 10},
        --coin = {30, 90},
        priority = 500,
        isCycleFish = false,
        actionFile = "actions/special/zhadanxie.actions",
        actionName = "move_multiple",
        luaName = "zhadanxie.lua",
        offsetAngle = math.pi / 2,
        z = 1,
        scale = 1.5,
        bornMusic = {
            delayTime = 0.3,
            paths = {
                "HammerCrab_CardAppear",
            },
            probability = 0.3,  -- 播放机率[0, 1]
        },
        deathMusic = "sound_crabboomget_b",
        mustPlayDeathEffect = true, -- 必放死亡音效
        DeathEffectInfo = {
            banner = "caitiao_lianhuanzhadanxie.png",
            avatar = "texiao_lianhuanzhadanxie.png",
        },
        -- 出生提示
        BornTipsInfo = {
            avatar = "texiao_lianhuanzhadanxie.png",
            tips = "yuzhonglaixi_lianhuanzhadanxielaile.png",
            scale = 0.75,
        },
    },
    -- 烈焰风暴
    FlamesStorm = {
        typeId = 204,
        name = "FlamesStorm",
        coin = {200, 200},
        --coin = {50, 50},
        priority = 200,
        isCycleFish = false,
        actionFile = "actions/special/lieyanfengbao.actions",
        -- 附加资源
        extRes = {
            "ext/flames_storm/fish_lyfb/fish_lyfb.actions",
            "ext/flames_storm/fish_lyfb_pt/fish_lyfb_pt.actions",
            "ext/flames_storm/fish_lyfb_freegame/fish_lyfb_freegame.actions",
        },
        luaName = "lieyanfengbao.lua",
        z = 101,
        deathMusic = "storm_title2",
        mustPlayDeathEffect = true, -- 必放死亡音效
        bornMusic = {
            delayTime = 0.3,
            paths = {
                "HammerCrab_CardAppear",
            },
            probability = 0.3,  -- 播放机率[0, 1]
        },
        -- 死亡提示
        DeathEffectInfo = {
            banner = "caitiao_lieyanfengbao.png",
            avatar = "texiao_lieyanfengbao.png",
        },
        -- 出生提示
        BornTipsInfo = {
            avatar = "texiao_lieyanfengbao.png",
            tips = "yuzhonglaixi_lieyanfengbaolaile.png",
            scale = 0.7,
        },
    },
    -- 神龙转盘
    WheelsOfGodDragon = {
        typeId = 205,
        name = "WheelsOfGodDragon",
        --coin = {3, 9},
        --coin = {300, 900, 100},
        coinList = {100, 150, 200, 250, 300, 350, 400, 450, 500, 1000, 10000},
        priority = 800,
        isCycleFish = false,
        actionFile = "actions/special/shenlongzhuanpan.actions",
        luaName = "wheels_of_god_dragon.lua",
        z = 102,
        scale = 1,
        deathMusic = "",
        upwards = true, -- 保持朝上
        DeathEffectInfo = {
            banner = "caitiao_shenlongzhuanlun.png",
            avatar = "texiao_shenlongzhuanlun.png",
        },
        BornTipsInfo = {
            avatar = "texiao_shenlongzhuanlun.png",
            tips = "yuzhonglaixi_slzpll.png",
            scale = 0.4,
        },
        particles = {
            {
                path = "particle/dragon.plist",
            },
        },
    },
    -- 猫大爷
    CatMaster = {
        typeId = 206,
        name = "CatMaster",
        --coin = {3, 9},
        coin = {100, 500, 10},
        priority = 600,
        isCycleFish = false,
        actionFile = "actions/special/maodaye.actions",
        luaName = "cat_master.lua",
        offsetAngle = math.pi / 2,
        z = 102,
        deathMusic = "",
        -- 出生音效
        bornMusic = {
            delayTime = 8.0,
            paths = {
                "v_Cat_Appear",
                "v_Cat_Progress1",
                "v_Cat_Progress3",
            },
            probability = 0.8,  -- 播放机率[0, 1]
        },
        DeathEffectInfo = {
            banner = "caitiao_maodaye.png",
            avatar = "texiao_maodaye.png",
        },
        BornTipsInfo = {
            avatar = "texiao_maodaye.png",
            tips = "yuzhonglaixi_mdyll.png",
            scale = 0.4,
        },
    },
    -- 凤凰
    FlamingPhoenix = {
        typeId = 207,
        name = "FlamingPhoenix",
        coin = {250, 600, 10},
        priority = 500,
        isCycleFish = false,
        actionFile = "actions/golden/phoenix.actions",
        luaName = "phoenix.lua",
        scale = 4,
        z = 1000,
        deathMusic = "Phoenix_Catch",
        mustPlayDeathEffect = true, -- 必放死亡音效
        DeathEffectInfo = {
            banner = "caitiao_phoenix.png",
            avatar = "texiao_fenghuang.png",
        },
    },
    -- 绿人鱼
    MermaidGreen = {
        typeId = 208,
        name = "MermaidGreen",
        coin = {100, 250, 10},
        priority = 300,
        isCycleFish = false,
        actionFile = "spine/Spine_MermaidGreen_Atlas.actions",
        -- 附加资源
        extRes = {
            "ext/boom_coin/boom_coin.actions",
            "ext/mermaid/fish_meirenyu_effect/fish_meirenyu_effect.actions",
        },
        luaName = "mermaid.lua",
        z = 1000,
        deathMusic = "",
        scale = 1,
        bornMusic = {
            delayTime = 5.0,
            paths = {
                "Mermaid_Appear",
            },
            probability = 0.4,  -- 播放机率[0, 1]
        },
        --offsetAngle = math.pi / 2,
        DeathEffectInfo = {
            banner = "caitiao_zjry.png",
            avatar = "texiao_zijingrenyu_lvse.png",
        },
    },
    -- 紫晶人鱼
    Mermaid = {
        typeId = 209,
        name = "Mermaid",
        coin = {100, 300, 10},
        priority = 300,
        isCycleFish = false,
        actionFile = "spine/Spine_Mermaid_Atlas.actions",
        -- 附加资源
        extRes = {
            "ext/mermaid/boom_coin/boom_coin.actions",
            "ext/mermaid/fish_meirenyu_effect/fish_meirenyu_effect.actions",
        },
        luaName = "mermaid.lua",
        z = 1000,
        deathMusic = "",
        scale = 1,
        bornMusic = {
            delayTime = 5.0,
            paths = {
                "Mermaid_Appear",
            },
            probability = 0.4,  -- 播放机率[0, 1]
        },
        --offsetAngle = math.pi / 2,
        DeathEffectInfo = {
            banner = "caitiao_lry.png",
            avatar = "texiao_zijingrenyu_hongse.png",
        },
    },
    -- 炸弹快艇
    BombSpeedBoat = {
        typeId = 210,
        name = "BombSpeedBoat",
        coin = {200, 400, 10},
        priority = 300,
        isCycleFish = false,
        actionFile = "actions/golden/bombspeedboat.actions",
        -- 附加资源
        extRes = {
            "ext/speedboat_bomb/BombSpeedboat.actions",
        },
        luaName = "speedboat.lua",
        z = 102,
        deathMusic = "",
        bornMusic = {
            delayTime = 2.0,
            paths = {
                "announce_BombSpeedboat",
            },
            probability = 0.2,  -- 播放机率[0, 1]
        },
        DeathEffectInfo = {
            banner = "caitiao_zdxt.png",
            avatar = "texiao_zhadanxiaoting.png",
        },
        -- BornTipsInfo = {
        --     avatar = "texiao_zhadanxiaoting.png",
        --     tips = "yuzhonglaixi_zdxtll.png",
        --     scale = 1,
        -- },
    },
    -- 觉醒霸王蟹
    WakeupKingCrab = {
        typeId = 211,
        name = "WakeupKingCrab",
        coin = {300, 800, 10},
        priority = 500,
        isCycleFish = false,
        actionFile = "actions/special/juexingbawangxie.actions",
        extRes = {
            "ext/juexingbawangxie_carbball/CarbBall.actions",
            "ext/boom_coin/boom_coin.actions",
        },
        luaName = "wakeup_kingcrab.lua",
        offsetAngle = math.pi ,
        z = 3,
        scale = 1.3,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_juexingbawangxie.png",
            avatar = "texiao_juexingbawangxie.png",
        },
    },
    -- 觉醒暗夜巨兽
    WakeupNightBeast = {
        typeId = 212,
        name = "WakeupNightBeast",
        coin = {300, 800, 10},
        priority = 500,
        isCycleFish = false,
        --actionFile = "actions/golden/anyejushou.actions",
        actionFile = "spine/AwakenKingAnglerFish.actions",
        -- 附加资源
        extRes = {
            "ext/fish_jxayjs_boomstar/fish_jxayjs_boomstar.actions",
            "ext/boom_coin/boom_coin.actions",
        },
        luaName = "wakeup_anyejushou.lua",
        z = 1111,
        scale = 0.6,
        offsetAngle = math.pi / 2,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_juexinganyejushou.png",
            avatar = "texiao_juexinganyejushou.png",
        },
    },
    -- 觉醒史前巨鳄
    WakeupCrocodile = {
        typeId = 213,
        name = "WakeupCrocodile",
        coin = {300, 800, 10},
        priority = 500,
        isCycleFish = false,
        --actionFile = "actions/golden/shiqianjue.actions",
        actionFile = "spine/AwakenKingLacoste.actions",
        -- 附加资源
        extRes = {
            "ext/WakeupCrocodileBall/WakeupCrocodileBall.actions",
            "ext/boom_coin/boom_coin.actions",
        },
        luaName = "wakeup_crocodile.lua",
        z = 3,
        offsetAngle = math.pi / 2,
        scale = 0.8,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_juexingshiqianjue.png",
            avatar = "texiao_juexingshiqianjue.png",
        },
    },
    -- 觉醒八爪章鱼
    WakeupKingOctopus = {
        typeId = 214,
        name = "WakeupKingOctopus",
        --coin = {10, 20},
        coin = {300, 800, 10},
        priority = 500,
        isCycleFish = false,
        --actionFile = "spine/AwakenKingTaco.actions",
        actionFile = "actions/special/awakenkingtaco.actions",
        -- 附加资源
        extRes = {
            "spine/AwakenKingTaco.actions",
            "ext/boom_coin/boom_coin.actions",
        },
        luaName = "wakeup_bazhuazhangyu.lua",
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_juexingbazhuazhangyu.png",
            avatar = "texiao_juexingbazhuazhangyu.png",
        },
    },
    -- 雷霸龙
    ThunderDragon = {
        typeId = 215,
        name = "ThunderDragon",
        coin = {300, 800, 10},
        priority = 500,
        isCycleFish = false,
        actionFile = "spine/dragon_thunder_spine.actions",
        -- 附加资源
        extRes = {
            "ext/fish_lbl_baozha/fish_lbl_baozha.actions",
            "ext/lightning/fish_sd2.actions",
            "ext/ThunderDragonBall/ThunderDragonBall_0.plist",
            "ext/boom_coin/boom_coin.actions",
        },
        luaName = "thunder_dragon.lua",
        z = 1000,
        scale = 0.8,
        bornMusic = {
            delayTime = 4.0,
            paths = {
                "ThunderDragon_AwakenProcess_Roar",
            },
            probability = 0.3,  -- 播放机率[0, 1]
        },
        deathMusic = "sound_dragonblow",
        DeathEffectInfo = {
            banner = "caitiao_lbl.png",
            avatar = "texiao_thunderdragon.png",
        },
    },
    -----------------------------------彩金鱼------------------------------------------
    -- 暗夜巨兽
    NightBeast = {
        typeId = 300,
        name = "NightBeast",
        coin = {100, 450, 10},
        priority = 400,
        isCycleFish = false,
        --actionFile = "actions/golden/anyejushou.actions",
        actionFile = "spine/KingAnglerFish.actions",
        luaName = "anyejushou.lua",
        z = 1111,
        scale = 0.6,
        offsetAngle = math.pi / 2,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_anyejushou.png",
            avatar = "texiao_anyejushou.png",
        },
    },
    -- 虎头鲨
    ScreamingTiger = {
        typeId = 301,
        name = "ScreamingTiger",
        coin = {120, 350, 10},
        priority = 400,
        isCycleFish = false,
        actionFile = "actions/golden/hutousha.actions",
        luaName = "hutousha.lua",
        z = 1000,
        scale = 1.4,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_huxiaolongteng.png",
            avatar = "texiao_hutousha.png",
        },
    },
    -- 霸王鲸
    OverloadWhale = {
        typeId = 302,
        name = "OverloadWhale",
        coin = {200, 500, 10},
        priority = 400,
        isCycleFish = false,
        actionFile = "actions/golden/bawangjin.actions",
        z = 1000,
        scale = 1.5,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_bawangjin.png",
            avatar = "texiao_bawangjin.png",
        },
    },
    -- 霸王蟹
    KingCrab = {
        typeId = 303,
        name = "KingCrab",
        coin = {150, 500, 10},
        priority = 400,
        isCycleFish = false,
        actionFile = "actions/golden/bawangxie.actions",
        offsetAngle = math.pi / 2,
        z = 3,
        scale = 1.3,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_bawangxie.png",
            avatar = "texiao_bawangxie.png",
        },
    },
    -- 赤焰龙龟
    DragonTurtle = {
        typeId = 304,
        name = "DragonTurtle",
        coin = {200, 600, 10},
        priority = 400,
        isCycleFish = false,
        actionFile = "actions/golden/chiyanlonggui.actions",
        z = 3,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_chiyanlonggui.png",
            avatar = "texiao_chiyanlonggui.png",
        },
    },
    -- 大王乌贼
    KingSquid = {
        typeId = 305,
        name = "KingSquid",
        coin = {250, 550, 10},
        priority = 400,
        isCycleFish = false,
        actionFile = "actions/golden/dawangwuzei.actions",
        z = 1000,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_dawangwuzei.png",
            avatar = "texiao_dawangwuzei.png",
        },
    },
    -- 电光水母
    KingJeffyFish = {
        typeId = 306,
        name = "KingJeffyFish",
        coin = {200, 400, 10},
        priority = 400,
        isCycleFish = false,
        actionFile = "actions/golden/dianguangshuimu.actions",
        z = 1000,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_dianguangshuimu.png",
            avatar = "texiao_dianguangshuimu.png",
        },
    },
    -- 龙虾将军
    LobsterGeneral = {
        typeId = 307,
        name = "LobsterGeneral",
        coin = {100, 500, 10},
        priority = 400,
        isCycleFish = false,
        actionFile = "actions/golden/longxiajiangjun.actions",
        --actionFile = "spine/generallobster.actions",
        z = 3,
        scale = 1.2,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_longxiajiangjun.png",
            avatar = "texiao_longxiajiangjun.png",
        },
    },
    -- 史前巨鳄
    Crocodile = {
        typeId = 308,
        name = "Crocodile",
        coin = {100, 600, 10},
        priority = 500,
        isCycleFish = false,
        --actionFile = "actions/golden/shiqianjue.actions",
        actionFile = "spine/KingLacoste.actions",
        z = 3,
        offsetAngle = math.pi / 2,
        scale = 0.8,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_shiqianjue.png",
            avatar = "texiao_shiqianjue.png",
        },
    },
    -- 狂暴火龙
    FieryDragon = {
        typeId = 309,
        name = "FieryDragon",
        coin = {300, 1000, 10},
        priority = 800,
        isCycleFish = false,
        actionFile = "spine/dragon_fire_spine.actions",
        luaName = "once_shake.lua",
        z = 1000,
        scale = 0.8,
        deathMusic = "sound_dragonblow",
        DeathEffectInfo = {
            banner = "caitiao_firedragon.png",
            avatar = "texiao_firedragon.png",
        },
    },
    -- 海王荣耀
    GlorySeaKing = {
        typeId = 310,
        name = "GlorySeaKing",
        coin = {200, 1000, 10},
        priority = 800,
        isCycleFish = false,
        actionFile = "spine/dragon_ice_spine.actions",
        luaName = "once_shake.lua",
        z = 1000,
        scale = 0.8,
        deathMusic = "sound_dragonblow",
        DeathEffectInfo = {
            banner = "caitiao_haiwangrongyao.png",
            avatar = "texiao_icedragon.png",
        },
    },
    -- 雷霸龙
    OldThunderDragon = {
        typeId = 311,
        name = "OldThunderDragon",
        coin = {250, 1000, 10},
        priority = 800,
        isCycleFish = false,
        actionFile = "spine/dragon_thunder_spine.actions",
        -- 附加资源
        extRes = {
            "ext/lightning/fish_sd2.actions",
        },
        luaName = "thunder_dragon_old.lua",
        z = 1000,
        scale = 0.8,
        bornMusic = {
            delayTime = 4.0,
            paths = {
                "ThunderDragon_AwakenProcess_Roar",
            },
            probability = 0.3,  -- 播放机率[0, 1]
        },
        deathMusic = "sound_dragonblow",
        DeathEffectInfo = {
            banner = "caitiao_lbl.png",
            avatar = "texiao_thunderdragon.png",
        },
    },
    -- 八爪章鱼
    KingOctopus = {
        typeId = 312,
        name = "KingOctopus",
        --coin = {10, 20},
        coin = {200, 500, 10},
        priority = 500,
        isCycleFish = false,
        --actionFile = "spine/KingTaco.actions",
        actionFile = "actions/golden/bazhuazhangyu.actions",
        luaName = "bazhuazhangyu.lua",
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_bazhuazhangyu.png",
            avatar = "texiao_bazhuazhangyu.png",
        },
    },
    -- 金色龙虾将军
    LobsterKing = {
        typeId = 314,
        name = "LobsterKing",
        coin = {300, 600, 10},
        priority = 500,
        isCycleFish = false,
        actionFile = "spine/Spine_FiveElementsLobsterKing.actions",
        z = 3,
        scale = 0.8,
        deathMusic = "",
        offsetAngle = math.pi / 2,
        DeathEffectInfo = {
            banner = "caitiao_jinselongxiajiangjun.png",
            avatar = "texiao_jinselongxiajiangjun.png",
        },
    },
    -- 黄金小丑鱼
    GoldenClownFish = {
        typeId = 320,
        name = "GoldenClownFish",
        coin = {60, 60, 10},
        priority = 60,
        isCycleFish = false,
        actionFile = "actions/golden/huangjinxiaochouyu.actions",
        z = 100,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_huangjinxiaochouyu.png",
            avatar = "texiao_huangjinxiaochouyu.png",
        },
    },
    -- 黄金碟鱼
    GoldenDishFish = {
        typeId = 321,
        name = "GoldenDishFish",
        coin = {100, 100},
        priority = 100,
        isCycleFish = false,
        actionFile = "actions/golden/huangjindieyu.actions",
        z = 100,
        deathMusic = "huangjindieyu_sound_die",
        DeathEffectInfo = {
            banner = "caitiao_huangjindieyu.png",
            avatar = "texiao_huangjindieyu.png",
        },
    },
    -- 黄金河豚
    GoldenPuffer = {
        typeId = 322,
        name = "GoldenPuffer",
        coin = {120, 120},
        priority = 120,
        isCycleFish = false,
        actionFile = "actions/golden/huangjinhetun.actions",
        z = 100,
        deathMusic = "huangjinhetun_sound_die",
        DeathEffectInfo = {
            banner = "caitiao_huangjinhetun.png",
            avatar = "texiao_huangjinhetun.png",
        },
    },
    -- 黄金鲨鱼
    GoldenShark = {
        typeId = 323,
        name = "GoldenShark",
        coin = {140, 140},
        priority = 140,
        isCycleFish = false,
        actionFile = "actions/golden/huangjinshayu.actions",
        z = 100,
        deathMusic = "goldshark_sound_hit",
        DeathEffectInfo = {
            banner = "caitiao_huangjinshayu.png",
            avatar = "texiao_huangjinshayu.png",
        },
    },
    -- 黄金鲸鱼
    GoldenWhale = {
        typeId = 324,
        name = "GoldenWhale",
        coin = {160, 160},
        priority = 160,
        isCycleFish = false,
        actionFile = "actions/golden/huangjinsharenjing.actions",
        --actionFile = "spine/goldkillerwhale.actions",
        --offsetAngle = math.pi,
        z = 101,
        deathMusic = "v109",
        DeathEffectInfo = {
            banner = "caitiao_huangjinsharenjing.png",
            avatar = "texiao_huangjinsharenjing.png",
        },
    },
    -- 聚财元宵
    LanternFestival = {
        typeId = 325,
        name = "LanternFestival",
        coin = {100, 300, 10},
        priority = 200,
        isCycleFish = false,
        actionFile = "actions/golden/lanternfestival.actions",
        -- 附加资源
        extRes = {
            "ext/yuanxiao/fish_yuanxiao.actions"
        },
        z = 102,
        deathMusic = "",
        scale = 1,
        luaName = "lantern_festival.lua",
        bornMusic = {
            delayTime = 1.0,
            paths = {
                "announce_LanternFish2020",
            },
            probability = 0.3,  -- 播放机率[0, 1]
        },
        DeathEffectInfo = {
            banner = "caitiao_jcyx.png",
            avatar = "texiao_jucaiyuanxiao.png",
        },
        -- 出生提示
        BornTipsInfo = {
            avatar = "texiao_jucaiyuanxiao.png",
            tips = "yuzhonglaixi_jcyxll.png",
            -- scale = 1,
        },
    },
    -- 小丑鱼学徒
    ClownFishLearner  = {
        typeId = 326,
        name = "ClownFishLearner",
        coin = {100, 250, 10},
        priority = 200,
        isCycleFish = false,
        actionFile = "actions/golden/clownfishlearner.actions",
        z = 102,
        deathMusic = "",
        scale = 0.6,
        bornMusic = {
            delayTime = 1.0,
            paths = {
                "announce_ClownFish",
            },
            probability = 0.3,  -- 播放机率[0, 1]
        },
        DeathEffectInfo = {
            banner = "caitiao_xcyxt.png",
            avatar = "texiao_xiaochouyuxuetu.png",
        },
        -- 出生提示
        -- BornTipsInfo = {
        --     avatar = "texiao_xiaochouyuxuetu.png",
        --     tips = "yuzhonglaixi_xcyxtll.png",
        --     scale = 0.8,
        -- },
    },
    -- 金蟾
    GoldenToad = {
        typeId = 327,
        name = "GoldenToad",
        coin = {100, 500, 10},
        priority = 200,
        isCycleFish = false,
        actionFile = "spine/GoldenToad.actions",
        z = 1000,
        deathMusic = "",
        scale = 1,
        offsetAngle = math.pi / 2,
        bornMusic = {
            delayTime = 1.0,
            paths = {
                "announce_GoldToad",
            },
            probability = 0.3,  -- 播放机率[0, 1]
        },
        DeathEffectInfo = {
            banner = "caitiao_zcbc.png",
            avatar = "texiao_zhaocaijinchan.png",
        },
    },
    -- 绿人鱼(废弃，请使用208)
    MermaidGreen1 = {
        typeId = 328,
        name = "MermaidGreen",
        coin = {200, 600, 100},
        priority = 200,
        isCycleFish = false,
        actionFile = "spine/Spine_MermaidGreen_Atlas.actions",
        luaName = "once_shake.lua",
        z = 1000,
        deathMusic = "",
        scale = 1,
        bornMusic = {
            delayTime = 5.0,
            paths = {
                "Mermaid_Appear",
            },
            probability = 0.4,  -- 播放机率[0, 1]
        },
        --offsetAngle = math.pi / 2,
        DeathEffectInfo = {
            banner = "caitiao_zjry.png",
            avatar = "texiao_zijingrenyu_lvse.png",
        },
    },
    -- 紫晶人鱼(废弃，请使用209)
    Mermaid1 = {
        typeId = 329,
        name = "Mermaid",
        coin = {100, 500, 100},
        priority = 200,
        isCycleFish = false,
        actionFile = "spine/Spine_Mermaid_Atlas.actions",
        luaName = "once_shake.lua",
        z = 1000,
        deathMusic = "",
        scale = 1,
        bornMusic = {
            delayTime = 5.0,
            paths = {
                "Mermaid_Appear",
            },
            probability = 0.4,  -- 播放机率[0, 1]
        },
        --offsetAngle = math.pi / 2,
        DeathEffectInfo = {
            banner = "caitiao_lry.png",
            avatar = "texiao_zijingrenyu_hongse.png",
        },
    },
    -- 福旺财神
    GodOfWealth = {
        typeId = 330,
        name = "GodOfWealth",
        --coin = {200, 500},
        coinList = {200, 400, 600},
        priority = 400,
        isCycleFish = false,
        upwards = true, -- 保持朝上
        upwardsFlipX = true,   -- 保持朝上时，需要翻转X轴
        actionFile = "actions/golden/god.actions",
        -- 附加资源
        extRes = {
            "ext/fish_gxfc/fish_gxfc.actions",
            "ext/ingot/ingot.actions",
        },
        luaName = "god_of_wealth.lua",
        z = 104,
        deathMusic = "",
        particles = {
            {
                path = "particle/caishengye.plist",
            },
        },
        scale = 0.8,
        bornMusic = {
            delayTime = 4.0,
            paths = {
                "announce_CNYearFish2020",
            },
            probability = 0.3,  -- 播放机率[0, 1]
        },
        DeathEffectInfo = {
            banner = "caitiao_fwcs.png",
            avatar = "texiao_fuwangcaishen.png",
        },
        -- BornTipsInfo = {
        --     avatar = "texiao_fuwangcaishen.png",
        --     tips = "yuzhonglaixi_fwcsll.png",
        --     scale = 1,
        -- },
    },
    -- 凌云飞马
    Pegasus = {
        typeId = 331,
        name = "Pegasus",
        coin = {100, 300, 10},
        priority = 200,
        isCycleFish = false,
        upwards = true, -- 保持朝上
        actionFile = "actions/golden/pegasus.actions",
        z = 104,
        deathMusic = "",
        scale = 1.2,
        particles = {
            {
                path = "particle/tianma.plist",
                z = -1,
                y = -15,
            },
        },
        bornMusic = {
            delayTime = 2.0,
            paths = {
                "announce_Pegasus",
            },
            probability = 0.2,  -- 播放机率[0, 1]
        },
        DeathEffectInfo = {
            banner = "caitiao_lyfm.png",
            avatar = "texiao_lingyunfeima.png",
        },
        -- BornTipsInfo = {
        --     avatar = "texiao_lingyunfeima.png",
        --     tips = "yuzhonglaixi_lyfmll.png",
        --     scale = 0.7,
        -- },
    },
    -- 小年兽
    NianMonster = {
        typeId = 332,
        name = "NianMonster",
        coin = {100, 300, 10},
        priority = 200,
        isCycleFish = false,
        upwards = true, -- 保持朝上
        actionFile = "actions/golden/nianmonster.actions",
        z = 102,
        deathMusic = "",
        bornMusic = {
            delayTime = 3.0,
            paths = {
                "v_nian",
            },
            probability = 0.6,  -- 播放机率[0, 1]
        },
        particles = {
            {
                path = "particle/luqiling.plist",
            },
        },
        DeathEffectInfo = {
            banner = "caitiao_xns.png",
            avatar = "texiao_xiaonianshou.png",
        },
        -- BornTipsInfo = {
        --     avatar = "texiao_xiaonianshou.png",
        --     tips = "yuzhonglaixi_xnsll.png",
        --     scale = 0.75,
        -- },
    },
    -- 冥焰赤龙
    DragonRed = {
        typeId = 333,
        name = "DragonRed",
        coin = {300, 1000, 10},
        priority = 800,
        isCycleFish = false,
        actionFile = "spine/Spine_DragonRedSpine_DragonRed.actions",
        -- 附加资源
        extRes = {
            "ext/dragonred_fire/dragonred.actions",
        },
        luaName = "dragon_red.lua",
        z = 1000,
        deathMusic = "",
        scale = 0.8,
        bornMusic = {
            delayTime = 5.0,
            paths = {
                "RedDragon_Announce",
                "RedDragon_BreatheFire",
            },
            probability = 0.2,  -- 播放机率[0, 1]
        },
        DeathEffectInfo = {
            banner = "caitiao_mingyanchilong.png",
            avatar = "texiao_mingyanchilong.png",
        },
    },
    -- 炸弹快艇(已废弃)
    BombSpeedBoatOld = {
        typeId = 334,
        name = "BombSpeedBoatOld",
        coin = {200, 500, 100},
        priority = 200,
        isCycleFish = false,
        actionFile = "actions/golden/bombspeedboat.actions",
        z = 102,
        deathMusic = "",
        bornMusic = {
            delayTime = 2.0,
            paths = {
                "announce_BombSpeedboat",
            },
            probability = 0.2,  -- 播放机率[0, 1]
        },
        DeathEffectInfo = {
            banner = "caitiao_zdxt.png",
            avatar = "texiao_zhadanxiaoting.png",
        },
        -- BornTipsInfo = {
        --     avatar = "texiao_zhadanxiaoting.png",
        --     tips = "yuzhonglaixi_zdxtll.png",
        --     scale = 1,
        -- },
    },
    -- 财神爷
    GodArrived = {
        typeId = 335,
        name = "GodArrived",
        coin = {200, 600, 10},
        priority = 400,
        isCycleFish = false,
        upwards = true, -- 保持朝上
        actionFile = "spine/hall_fish_caishen.actions",
        -- 附加资源
        extRes = {
            "ext/fish_scroll_chuxian/fish_scorll.actions",
        },
        luaName = "god_arrived.lua",
        z = 104,
        deathMusic = "",
        particles = {
            {
                path = "particle/caishengye.plist",
            },
        },
        DeathEffectInfo = {
            banner = "caitiao_csy.png",
            avatar = "texiao_caishenye.png",
        },
        -- BornTipsInfo = {
        --     avatar = "texiao_caishenye.png",
        --     tips = "yuzhonglaixi_csyll.png",
        --     scale = 1,
        -- },
    },
    -- 蛮荒凶兽
    BisonComing = {
        typeId = 336,
        name = "BisonComing",
        coin = {200, 600, 10},
        priority = 400,
        isCycleFish = false,
        upwards = true, -- 保持朝上
        beatless = true, -- 死亡时不会被击退
        actionFile = "spine/Spine_BisonComing.actions",
        -- 附加资源
        extRes = {
            "ext/bosswarning/bisoncoming/Spine_BisonComing.actions",
        },
        z = 3,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_manhuangxiongshou.png",
            avatar = "texiao_manhuangxiongshou.png",
        },
    },
    -- 南瓜三兄弟
    Pumpkin = {
        typeId = 337,
        name = "Pumpkin",
        coin = {100, 500, 10},
        priority = 400,
        isCycleFish = false,
        upwards = true, -- 保持朝上
        actionFile = "actions/golden/pumpkin.actions",
        -- 附加资源
        extRes = {
            "ext/fish_ngsxd/fish_ngsxd.actions",
            "ext/pumpkinBomb/pumpkinBomb_0.plist",
        },
        luaName = "pumpkin.lua",
        z = 104,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_nanguasanxiongdi.png",
            avatar = "texiao_nanguasanxiongdi.png",
        },
    },
    -- 组合鱼1(灯笼鱼*5)
    CombinedFish1 = {
        typeId = 350,
        name = "CombinedFish1",
        coin = {50, 50},
        priority = 50,
        isCycleFish = false,
        actionFile = "actions/general/lantern.actions",
        luaName = "combined_fish1.lua",
        z = 100,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_dapanyu.png",
            avatar = "texiao_dapanyu_01.png",
        },
    },
    -- 组合鱼2(鲨鱼*1 + 旗鱼*4)
    CombinedFish2 = {
        typeId = 351,
        name = "CombinedFish2",
        coin = {50, 50},
        priority = 50,
        isCycleFish = false,
        actionFile = "actions/general/shark.actions",
        luaName = "combined_fish2.lua",
        z = 100,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_dapanyu.png",
            avatar = "texiao_dapanyu_02.png",
        },
    },
    -- 组合鱼3(蝠鲼*3)
    CombinedFish3 = {
        typeId = 352,
        name = "CombinedFish3",
        coin = {60, 60},
        priority = 60,
        isCycleFish = false,
        actionFile = "actions/general/fuyu.actions",
        luaName = "combined_fish3.lua",
        z = 100,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_dapanyu.png",
            avatar = "texiao_dapanyu_03.png",
        },
    },
    -- 组合鱼4(乌龟*5)
    CombinedFish4 = {
        typeId = 353,
        name = "CombinedFish4",
        coin = {80, 80},
        priority = 80,
        isCycleFish = false,
        actionFile = "actions/general/seaturtle.actions",
        luaName = "combined_fish4.lua",
        z = 100,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_dapanyu.png",
            avatar = "texiao_dapanyu_04.png",
        },
    },
    -- 组合鱼5(黄金小丑鱼*1 + 巨大小丑鱼*2)
    CombinedFish5 = {
        typeId = 354,
        name = "CombinedFish5",
        coin = {110, 110},
        priority = 110,
        isCycleFish = false,
        actionFile = "actions/golden/huangjinxiaochouyu.actions",
        luaName = "combined_fish5.lua",
        z = 100,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_dapanyu.png",
            avatar = "texiao_dapanyu_05.png",
        },
    },
    -- 组合鱼6(黄金碟鱼*1 + 巨大鲽鱼*2)
    CombinedFish6 = {
        typeId = 355,
        name = "CombinedFish6",
        coin = {120, 120},
        priority = 120,
        isCycleFish = false,
        actionFile = "actions/golden/huangjindieyu.actions",
        luaName = "combined_fish6.lua",
        z = 100,
        deathMusic = "huangjindieyu_sound_die",
        DeathEffectInfo = {
            banner = "caitiao_dapanyu.png",
            avatar = "texiao_dapanyu_06.png",
        },
    },
    -- 组合鱼7(黄金鲨鱼*1 + 鲨鱼*2)
    CombinedFish7 = {
        typeId = 356,
        name = "CombinedFish7",
        coin = {200, 200},
        priority = 120,
        isCycleFish = false,
        actionFile = "actions/golden/huangjinshayu.actions",
        luaName = "combined_fish7.lua",
        z = 100,
        deathMusic = "",
        DeathEffectInfo = {
            banner = "caitiao_dapanyu.png",
            avatar = "texiao_dapanyu_07.png",
        },
    },
}

return fishInfo