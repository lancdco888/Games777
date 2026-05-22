-- level/game101.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group_cs.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")
    FF_G.SetCsBonusType(2) --打死鱼彩金框的样式
    local scene1 = FishEventHelper.CreateScene(310)
    local scene2 = FishEventHelper.CreateScene(55)
    local scene3 = FishEventHelper.CreateScene(310)
    local scene4 = FishEventHelper.CreateScene(60)
    --local scene5 = FishEventHelper.CreateScene(935)
    --local scene6 = FishEventHelper.CreateScene(110)

    --场景1:响震四方随机刷鱼
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 103)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")
        --海草
        for i = 7, 300, 15 do
            scene.AddFishBornEvent(i, {
                fish = {11201,11214,11217,11219,11221,11225,11232,11278,11286},
                fishTypeCount = {1},
                intervalTime = 5,
                pathwayGroup = "Group_cs_gfish",
            })
        end
        --小鱼
        for i = 0.1, 300, 4 do
            scene.AddFishBornEvent(i, {
                fish = {10001,10019,10025,10021,10017,10014,10032,10086,10078},      -- 指定鱼组
                fishTypeCount = 4,
                pathwayGroup = "Group_cs_follow",
            })
        end
        for i = 0.1, 300, 4 do
            scene.AddFishBornEvent(i, {
                fish = {10001,10019,10025,10021,10017,10014,10032,10086,10078},      -- 指定鱼组
                fishTypeCount = 4,
                pathwayGroup = "Group_cs_gfishR",
            })
        end
            --出中鱼
        for i = 1.1, 300, 6.5 do
            scene.AddFishBornEvent(i, {
                fish = {10020,10085,10024,10036},      -- 指定鱼组
                fishTypeCount = 2,
                pathwayGroup = "Group_cs_gfishL",
            })
        end
            --出大鱼
        for i = 2.1, 300, 8.9 do
            scene.AddFishBornEvent(i, {
                fish = {10079,10080},      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_cs_Cbfish",
            })
        end
        --旋风鱼1
        for i = 8, 300, 40 do
            scene.AddFishBornEvent(i, {
                fish = {31141,31142,31143,31144,31145,31146,31147,31148,31149},
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3L",
            })
        end
        --旋风鱼2
        for i = 28, 300, 40 do
            scene.AddFishBornEvent(i, {
                fish = {31141,31142,31143,31144,31145,31146,31147,31148,31149},
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3R",
            })
        end
        -- 出boss-循环出-随机选一
        for i = 10, 300, 12 do
            scene.AddFishBornEvent(i, {
                fish = {10081,10082,10083,10048},      -- 指定鱼组
                fishTypeCount = {1},
                intervalTime = 1,
                pathwayGroup = "Group_cs_boss",
            })
            
        end
        -- --补boss黄色蝾螈
        -- scene.AddRule(              --补鱼专用的函数
        --     {
        --     startTime = 5,          --开始时间
        --     endTime = 300,          --结束时间
        --     leaveCd = 0,            --自然离开后CD时间
        --     deathCd = 0,            --被捕获后的CD时间
        --     groupName = 10083,        --鱼的id
        --     limit = 1,              --最多有几个同时在   
        --     }, 
        --     {
        --     fish = 10083,             --鱼的ID
        --     fishTypeCount = 1,    --数量
        --     pathwayGroup= "Group_cs_boss", --鱼线
        --     }
        -- )
        -- --补BOSS蓝色飞龙
        -- scene.AddRule(              --补鱼专用的函数
        --     {
        --     startTime = 15,          --开始时间
        --     endTime = 300,          --结束时间
        --     leaveCd = 0,            --自然离开后CD时间
        --     deathCd = 0,            --被捕获后的CD时间
        --     groupName = 10048,        --鱼的id
        --     limit = 1,              --最多有几个同时在   
        --     }, 
        --     {
        --     fish = 10048,             --鱼的ID
        --     fishTypeCount = 1,    --数量
        --     pathwayGroup= "Group_cs_boss", --鱼线
        --     }
        -- )
        -- 圆盘炸弹109
        scene.AddRule(
            {
            startTime = 10,
            endTime = 300,
            -- cdTime = 1,
            leaveCd = 0,
            deathCd = 15,
            groupName = 20109,
            -- mutex = true,
            limit = 1,
            }, 
            {
            fish = 20109,     
            fishTypeCount = {1}, 
            pathwayGroup= "Group_cs_Cbfish",
            }
        )
        -- 出跟随： 
        for i = 0, 300, 24 do                --出鱼的时间
            scene.AddFishBornEvent(i, {
                fish = {10001,10019},      -- 指定鱼组
                fishCount = {4,5},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0.8,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,           --忘了，照着填吧
                pathwayGroup = "Group_cs_BCycle",  --鱼线
            })
        end
        -- 出小鱼群： 
        for i = 12, 300, 24 do
            scene.AddFishBornEvent(i, {
            fish = 10019,                       -- 指定鱼组
            fishCount = {5},                -- 鱼的数量
            offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 0,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathwayGroup = "Group_cs_Carb",
            })
        end
        -- -- 出小鱼群： 
        -- for i = 24, 300, 36 do
        --     scene.AddFishBornEvent(i, {
        --     fish = 10025,                       -- 指定鱼组
        --     fishCount = {5},                -- 鱼的数量
        --     offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
        --     fishTypeCount = 1,              -- 鱼类型数量
        --     intervalTime = 0,             -- 两条鱼的间隔时间
        --     lineCount = 1,                  -- 固定选一条鱼线
        --     fixedFishType = true,
        --     pathwayGroup = "Group_cs_lxfollow",
        --     })
        -- end
    end

--场景2：-------------------------
    do
     
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 104)
        scene.AddSwitchBgMusicEvent(0, "bg_01")

--------- 鱼阵109-1 -4横线，两边出小鱼，中间出大鱼----------------------
        scene.AddFishBornEvent(3, {
            fish = 10079,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {3},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 2.5,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_3", 
            speedScale = 1
        })
        scene.AddFishBornEvent(3, {
            fish = 10079,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {3},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 2.5,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_4", 
            speedScale = 1
        })
        scene.AddFishBornEvent(12, {
            fish = 10082,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {3},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 5,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_3", 
            speedScale = 1
        })
        scene.AddFishBornEvent(12, {
            fish = 10082,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {3},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 5,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_4", 
            speedScale = 1
        })
        scene.AddFishBornEvent(26, {
            fish = 10080,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {3},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 3,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_3", 
            speedScale = 1
        })
        scene.AddFishBornEvent(26, {
            fish = 10080,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {3},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 3,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_4", 
            speedScale = 1
        })
        scene.AddFishBornEvent(36.5, {
            fish = 10083,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {1},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 5,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_3", 
            speedScale = 1
        })
        scene.AddFishBornEvent(36.5, {
            fish = 10083,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {1},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 5,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_4", 
            speedScale = 1
        })
        scene.AddFishBornEvent(43, {
            fish = 10048,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {1},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 3.5,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_3", 
            speedScale = 1
        })
        scene.AddFishBornEvent(42, {
            fish = 10048,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {1},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 3.5,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_4", 
            speedScale = 1
        })
    end
    --场景3:响震四方随机刷鱼
    do
        
        local scene = scene3
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 103)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")
        --海草
        for i = 7, 300, 15 do
            scene.AddFishBornEvent(i, {
                fish = {11201,11214,11217,11219,11221,11225,11232,11278,11286},
                fishTypeCount = {1,2},
                intervalTime = 5,
                pathwayGroup = "Group_cs_gfish",
            })
        end
        --小鱼
        for i = 0.1, 300, 3 do
            scene.AddFishBornEvent(i, {
                fish = {10001,10019,10025,10021,10017,10014,10032,10086,10078},      -- 指定鱼组
                fishTypeCount = 4,
                pathwayGroup = "Group_cs_follow",
            })
        end
        for i = 0.1, 300, 3 do
            scene.AddFishBornEvent(i, {
                fish = {10001,10019,10025,10021,10017,10014,10032,10086,10078},      -- 指定鱼组
                fishTypeCount = 4,
                pathwayGroup = "Group_cs_gfishR",
            })
        end
            --出中鱼
        for i = 1.1, 300, 6.5 do
            scene.AddFishBornEvent(i, {
                fish = {10020,10085,10024,10036},      -- 指定鱼组
                fishTypeCount = 2,
                pathwayGroup = "Group_cs_gfishL",
            })
        end
            --出大鱼
        for i = 2.1, 300, 8.9 do
            scene.AddFishBornEvent(i, {
                fish = {10079,10080,10081,10082},      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_cs_Cbfish",
            })
        end
        --旋风鱼
        for i = 8, 300, 13 do
            scene.AddFishBornEvent(i, {
                fish = {31141,31142,31143,31144,31145,31146,31147,31148,31149},
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3L",
            })
        end
        --组合鱼
        for i = 0, 300, 17 do
            scene.AddFishBornEvent(i, {
                fish = {31141,31142,31143,31144,31145,31146,31147,31148,31149},
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3R",
            })
        end
        --补boss黄色蝾螈
        scene.AddRule(              --补鱼专用的函数
            {
            startTime = 5,          --开始时间
            endTime = 300,          --结束时间
            leaveCd = 0,            --自然离开后CD时间
            deathCd = 0,            --被捕获后的CD时间
            groupName = 10083,        --鱼的id
            limit = 1,              --最多有几个同时在   
            }, 
            {
            fish = 10083,             --鱼的ID
            fishTypeCount = 1,    --数量
            pathwayGroup= "Group_cs_boss", --鱼线
            }
        )
        --补BOSS蓝色飞龙
        scene.AddRule(              --补鱼专用的函数
            {
            startTime = 15,          --开始时间
            endTime = 300,          --结束时间
            leaveCd = 0,            --自然离开后CD时间
            deathCd = 0,            --被捕获后的CD时间
            groupName = 10048,        --鱼的id
            limit = 1,              --最多有几个同时在   
            }, 
            {
            fish = 10048,             --鱼的ID
            fishTypeCount = 1,    --数量
            pathwayGroup= "Group_cs_boss", --鱼线
            }
        )
        -- 圆盘炸弹109
        scene.AddRule(
            {
            startTime = 10,
            endTime = 300,
            -- cdTime = 1,
            leaveCd = 0,
            deathCd = 15,
            groupName = 20109,
            -- mutex = true,
            limit = 1,
            }, 
            {
            fish = 20109,     
            fishTypeCount = {1}, 
            pathwayGroup= "Group_cs_Cbfish",
            }
        )
        -- 出跟随： 
        for i = 0, 300, 12 do                --出鱼的时间
            scene.AddFishBornEvent(i, {
                fish = {10001,10019},      -- 指定鱼组
                fishCount = {4,5},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 1,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,           --忘了，照着填吧
                pathwayGroup = "Group_cs_BCycle",  --鱼线
            })
        end
        -- 出小鱼群： 
        for i = 12.5, 300, 20 do
            scene.AddFishBornEvent(i, {
            fish = 10019,                       -- 指定鱼组
            fishCount = {5},                -- 鱼的数量
            offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 0,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathwayGroup = "Group_cs_Carb",
            })
        end
        -- 出小鱼群： 
        for i = 2.5, 300, 20 do
            scene.AddFishBornEvent(i, {
            fish = 10025,                       -- 指定鱼组
            fishCount = {5},                -- 鱼的数量
            offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 0,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathwayGroup = "Group_cs_lxfollow",
            })
        end
    end

--场景4：------鱼阵：机器人大扫荡-------------------
    do
     
        local scene = scene4
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 104)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        
        --小鱼
        scene.AddFishBornEvent(1, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_1", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_2", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_3", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0.5, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_4", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_5", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_6", 
            speedScale = 1
        })
        scene.AddFishBornEvent(3, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_7", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2.5, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_8", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_9", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_10", 
            speedScale = 1
        })
        scene.AddFishBornEvent(3, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_11", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_12", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_13", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2.5, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_14", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_15", 
            speedScale = 1
        })scene.AddFishBornEvent(3, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_16", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_17", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_18", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_19", 
            speedScale = 1
        })
        scene.AddFishBornEvent(3, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_20", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2.5, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_21", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_22", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_23", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_24", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2.5, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_25", 
            speedScale = 1
        })
        scene.AddFishBornEvent(3, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_26", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_27", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_28", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_29", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10001,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_30", 
            speedScale = 1
        })


        --中间大鱼
      
        --向上
        scene.AddFishBornEvent(0, {
            fish = 10083,      
            fishCount = {1},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 1,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_32", 
            speedScale = 1
        })
        scene.AddFishBornEvent(7, {
            fish = 10086,      
            fishCount = {7},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 7,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_32", 
            speedScale = 1
        })
        scene.AddFishBornEvent(6, {
            fish = 10082,      
            fishCount = {3},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 16,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_33", 
            speedScale = 1
        })
        scene.AddFishBornEvent(14, {
            fish = 10083,      
            fishCount = {2},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 16,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_33", 
            speedScale = 1
        })
        --中线
        scene.AddFishBornEvent(32, {
            fish = 10079,      
            fishCount = {2},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_34", 
            speedScale = 1
        })
        scene.AddFishBornEvent(48, {
            fish = 10080,      
            fishCount = {1},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_34", 
            speedScale = 1
        })
        --向下
        scene.AddFishBornEvent(4, {
            fish = 10080,      
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_36", 
            speedScale = 1
        })
        scene.AddFishBornEvent(8, {
            fish = 10086,      
            fishCount = {5},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_35", 
            speedScale = 1
        })
        scene.AddFishBornEvent(5, {
            fish = 10079,      
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_37", 
            speedScale = 1
        })
    end



    scene1.PushToGame(true)
    scene2.PushToGame(true)
    scene1.PushToGame(true)
    scene4.PushToGame(true)
    --scene5.PushToGame(true)
    --scene6.PushToGame(true)

     
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

