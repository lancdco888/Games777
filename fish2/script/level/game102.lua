-- level/game102.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")

    

    local scene1 = FishEventHelper.CreateScene(870)
    local scene2 = FishEventHelper.CreateScene(110)
    local scene3 = FishEventHelper.CreateScene(870)
    local scene4 = FishEventHelper.CreateScene(110)
    local scene5 = FishEventHelper.CreateScene(870)
    local scene6 = FishEventHelper.CreateScene(110)

    --场景1 --虎头鲨301，场景2，八爪章鱼312，场景11 
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 2)   
        scene.AddSwitchBgMusicEvent(1, "bg_02")

        
        -- 持续时间段定义    
            local t1 = 60
            local t2 = 280
            local t3 = 120
            local t4 = 280
            local t5 = 120
        -- 第一段场景时间划分
            -- scene.AddSetPlayRatioEvent(t1, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+2.5, 1) --还原速度
            scene.AddShakeEvent(t1, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1, "jingbao") --警报响
            scene.AddBossWarningEvent(t1, FF_G.BossWarning_Purple) --预警泛紫
            scene.AddBossWarningEvent(t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 301})
            
            scene.AddSwitchBgEvent(t1 +4, 1)  -- 切换场景
            
            for i = t1+2.8+34 , t1+t2 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t1+2.8+30+34 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t1+2.8 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
           
            scene.AddSwitchBgMusicEvent(t2+t1+5, "bg_04")
            scene.AddSwitchBgEvent(t2+t1+5, 2)   -- 切换场景

        -- 第二段场景时间划分
            
            -- scene.AddSetPlayRatioEvent(t3+t1+t2, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t3+t1+t2+2.5, 1) --还原速度
            scene.AddShakeEvent(t3+t1+t2, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t3+t1+t2, "jingbao") --警报响
            scene.AddBossWarningEvent(t3+t1+t2, FF_G.BossWarning_Red) --预警泛红
            scene.AddHaiwanglaixiEvent(t3+t1+t2 +2, FF_G.Haiwanglaixi_FishType_KingOctopus) -- boss 预警
            scene.AddSwitchBgEvent(t3+t1+t2 +4, 11) -- 切换场景
            
            for i = t3+t1+t2+2.8+30+37 , t3+t1+t2+t4 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t3+t1+t2+2.8+37 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t3+t1+t2+2.8 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
            
            scene.AddSwitchBgEvent(t1+t2+t3+t4+5, 2)  -- 切换场景
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+5, "OneOutOfSix_BG")
           
        -- 旋转场景 八爪章鱼场景
            for i = t3+t1+t2+8, t3+t1+t2+t4, 60 do
                scene.AddSetPlayBgAnimEvent(i, "turn1")
                scene.AddSetPlayBgAnimEvent(i + 15, "turn2")
                scene.AddSetPlayBgAnimEvent(i + 30, "turn3")
                scene.AddSetPlayBgAnimEvent(i + 45, "turn4")
            end
    
        
            
        
        -- 出boss
            scene.AddRule(
                {
                startTime = t1 + 5,
                endTime = t1+t2-30,
                -- cdTime = 3.5,
                leaveCd = 3,
                deathCd = 3,
                groupName = 301,  
                limit = 1,
                }, 
                {
                fish = 301,      
                fishTypeCount = 1, 
                createPrams = 
                {
                    -- fadeInSecs = 3,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 5,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
                pathwayGroup= "Group_hutousha",
                }
            )
            scene.AddRule(
                {
                    startTime =  t1+t2+t3+5,
                    endTime = t1+t2+t3+t4-12,
                    cdTime = 3.5,
                    leaveCd = 0,
                    deathCd = 0,
                    groupName = 312, 
                    limit = 3,
                },
                {
                    fish = 312,      
                    fishTypeCount = 1,
                    pathway= "line_1",
                }
            )

        -- 出special
            scene.AddRule(
                {
                startTime = 10,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = "special",  
                limit = 2,
                mutex = true,
                }, 
                {
                -- fish = 205, 
                fish = fishGroup["special"],     
                fishTypeCount = {1}, 
                pathwayGroup= "Group_special",
                }
            )
            
        
        
        -- 猫大爷
            scene.AddFishBornEvent( t1+t2+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent( t1+t2+10+40+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
            
            scene.AddFishBornEvent( t1+t2+t3+t4+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent( t1+t2+t3+t4+10+40+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
            
        -- 鱼王画图----line_ywht102_
            -- 雷达旋转中心鱼王
            for i = 6, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_ywht102_1",
                        subPathway = {
                            {
                                pathway = "line_348",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4* j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_ywht102_1",
                        subPathway = {
                            {
                                pathway = "line_349",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 101,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_1",
                    -- offsets = {{-20, -55}}, 
                    speedScale = 1
                })
            end

            for i = 78, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_ywht102_2",
                        subPathway = {
                            {
                                pathway = "line_348",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4* j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_ywht102_2",
                        subPathway = {
                            {
                                pathway = "line_349",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 100,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_2",
                    -- offsets = {{-10, 55}}, 
                    speedScale = 1
                })
            end
            -- 圆旋转中心鱼王
            for i = 22, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_ywht102_3",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 101,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_3",
                    -- offsets = {{-60 , 10}}, 
                    speedScale = 1
                })
            end
            
            for i = 425, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_ywht102_4",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 100,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_4",
                    -- offsets = {{20 , 0}}, 
                    speedScale = 1
                })
            end

            for i = 555, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 2,
                        fishTypeCount = 1,
                        pathway="line_ywht102_5",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 102,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_5",
                    -- offsets = {{-23, 5}}, 
                    speedScale = 1
                })
            end

            for i = 774, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 4,
                        fishTypeCount = 1,
                        pathway="line_ywht102_6",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 104,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_6",
                    -- offsets = {{60, -10}}, 
                    speedScale = 1
                })
            end      

        -- 出小鱼跟随： SetFishGroup("fish1", {0,1,2})
            for i = 7, t1-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishCount = {4,5,6},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_follow",
                })
            end
            for i = t1+7, t1+t2+t3-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishCount = {4,5,6},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_follow",
                })
            end
            for i = t1+t2+t3+7, t1+t2+t3+t4+t5, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishCount = {4,5,6},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_follow",
                })
            end
        -- 出小鱼群： SetFishGroup("fish1", {0,1,2})
            for i = 5, t1-2, 20 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish1"],                       -- 指定鱼组
                fishCount = {5},                -- 鱼的数量
                offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathwayGroup = "Group_group",
                })
            end
            for i = t1+8, t1+t2+t3-2, 20 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish1"],                       -- 指定鱼组
                fishCount = {5},                -- 鱼的数量
                offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathwayGroup = "Group_group",
                })
            end
            for i = t1+t2+t3+t4+5, t1+t2+t3+t4+t5, 20 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish1"],                       -- 指定鱼组
                fishCount = {5},                -- 鱼的数量
                offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathwayGroup = "Group_group",
                })
            end
        -- 出龙虾跟随
            for i = 10, t1-2, 140 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["longxia"],      -- 指定鱼组
                    fishCount = {4,5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end
            for i = t1+10, t1+t2+t3-2, 140 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["longxia"],      -- 指定鱼组
                    fishCount = {3,4},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end
            for i = t1+t2+t3+t4+13, t1+t2+t3+t4+t5, 140 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["longxia"],      -- 指定鱼组
                    fishCount = {3,3},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end

        -- 出小鱼单条:SetFishGroup("fish1", {0,1,2})
            for i = 0, t1-2, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            for i = t1+5.5, t1+t2+t3-2, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            for i = t1+t2+t3+8, t1+t2+t3+t4+t5, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
        
        -- 出普通中型鱼：SetFishGroup("fish2", {3,4,6,7,8,9,10,11,12})
            for i = 6, t1+t2+t3+t4+t5, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2L",
                })
            end
            for i = 4, t1+t2+t3+t4+t5, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2R",
                })
            end
            
        
        -- 出普通大鱼：SetFishGroup("fish3", {13,14,15,16,17})
        
            for i = 8, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3L",
                })
            end
            for i = 0, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3R",
                })
            end
            
        -- 出彩金鱼：SetFishGroup("goldedfish", {320,321,322,323,324})
            for i = 12, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishL",
                })
            end
            for i = 4, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishR",
                })
            end
            
            
            
        -- 补烈焰风暴：204
            scene.AddRule(
                {
                    startTime = 15,
                    endTime = t1-2,
                    cdTime = 1,
                    leaveCd = 5,
                    deathCd =40,
                    groupName = "Storm",
                    limit = 1,
                }, 
                {
                    fish = fishGroup["Storm"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Storm",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+10+5,
                    endTime = t1+t2+t3-2,
                    cdTime = 1,
                    leaveCd = 5,
                    deathCd =40,
                    groupName = "Storm",
                    limit = 1,
                }, 
                {
                    fish = fishGroup["Storm"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Storm",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+t2+t3+10+5,
                    endTime = t1+t2+t3+t4+t5-50,
                    cdTime = 1,
                    leaveCd = 5,
                    deathCd =40,
                    groupName = "Storm",
                    limit = 1,
                }, 
                {
                    fish = fishGroup["Storm"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Storm",
                
                }
            )        
        -- 出组合鱼SetFishGroup("combinedfish", {350,351,352,353,354,355,356})
        
            for i = 38, t1-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+30, t1+t2+t3-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+t2+t3+t4+27, t1+t2+t3+t4+t5, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
        -- 出比目鱼：5
            for i = 2, t1-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            for i = t1+5.5, t1+t2+t3-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            for i = t1+t2+t3+8, t1+t2+t3+t4+t5, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            
            
        -- 炸弹，钻头蟹
            for i = 18, t1-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Carb",
                    offsetAngles = {math.pi / 2},
                })
            end
            for i = t1+18, t1+t2+t3-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Carb",
                    offsetAngles = {math.pi / 2},
                })
            end
            for i = t1+t2+t3+18, t1+t2+t3+t4+t5-40, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Carb",
                    offsetAngles = {math.pi / 2},
                })
            end
            
        -- 闪电鲨
            scene.AddRule(
                {
                    startTime = 40,
                    endTime = t1-2,
                    cdTime = 1,
                    leaveCd = 45,
                    deathCd =60,
                    groupName = 200,
                    limit = 1,
                }, 
                {
                    fish = 200,      
                    fishTypeCount = {1},
                    pathwayGroup = "Group_shadiansha",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+45,
                    endTime = t1+t2+t3-3,
                    cdTime = 1,
                    leaveCd = 45,
                    deathCd =60,
                    groupName = 200,
                    limit = 1,
                }, 
                {
                    fish = 200,      
                    fishTypeCount = {1},
                    pathwayGroup = "Group_shadiansha",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+t2+t3+45,
                    endTime = t1+t2+t3+t4+t5,
                    cdTime = 1,
                    leaveCd = 45,
                    deathCd =60,
                    groupName = 200,
                    limit = 1,
                }, 
                {
                    fish = 200,      
                    fishTypeCount = {1},
                    pathwayGroup = "Group_shadiansha",
                
                }
            )
            
        -- 出旋风鱼
            
            for i = 40, t1-2, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+40, t1+t2+t3-2, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+t2+t3+t4+40, t1+t2+t3+t4+t5, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
        

        -- 聚餐元宵
            scene.AddFishBornEvent(25, {
                fish = 325,      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_yuanxiao",
                createPrams = 
                {
                    fadeInSecs = 3,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 4,            -- 淡出持续时间
                    scaleInSec = 2,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent(t1+t2+55, {
                fish = 325,      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_yuanxiao",
                createPrams = 
                {
                    fadeInSecs = 3,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 4,            -- 淡出持续时间
                    scaleInSec = 2,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent(t1+t2+t3+t4+55, {
                fish = 325,      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_yuanxiao",
                createPrams = 
                {
                    fadeInSecs = 3,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 4,            -- 淡出持续时间
                    scaleInSec = 2,             -- 从小变大入场
                },
            })

            


    end

    --场景2
    --------------------鱼阵1-8线交叉-----------------------
    --------------------鱼阵1-8线交叉-----------------------   
    do
        
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0.0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")

        for i = 0, 105, 2 do
                scene.AddFishBornEvent(i, {
                    fish = 13 ,                      -- 鱼或鱼组
                    fishTypeCount = 1 ,             -- 数量
                    pathway = "line_Z2401",         -- 线或线组
                })
                scene.AddFishBornEvent(i, {
                    fish = 13 ,                 -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    pathway = "line_Z2408",
                })
              end
              for i = 0, 105, 3 do
                if i % 9 == 6 then
                    scene.AddFishBornEvent(i, {
                        fish = 112 ,                 -- 鱼或鱼组
                        fishTypeCount = 1 ,
                        pathway = "line_Z2402",
                   })
                    scene.AddFishBornEvent(i, {
                       fish = 112 ,                   -- 鱼或鱼组
                       fishTypeCount = 1 ,
                       pathway = "line_Z2407",
                   })
                else
                    scene.AddFishBornEvent(i, {
                        fish = 12 ,                 -- 鱼或鱼组
                        fishTypeCount = 1 ,
                        pathway = "line_Z2402",
                   })
                    scene.AddFishBornEvent(i, {
                       fish = 12 ,                   -- 鱼或鱼组
                       fishTypeCount = 1 ,
                       pathway = "line_Z2407",
                   })  
                end
              end
              for i = 0, 105, 1.5 do
                if i*2 % 15 == 12 then
                    scene.AddFishBornEvent(i, {
                        fish = 111 ,                   -- 鱼或鱼组
                        fishTypeCount = 1 ,
                        pathway = "line_Z2403",
                    }) 
                    scene.AddFishBornEvent(i, {
                         fish = 110 ,                 -- 鱼或鱼组
                         fishTypeCount = 1 ,
                         pathway = "line_Z2404",
                    })
                    scene.AddFishBornEvent(i, {
                        fish = 110 ,                   -- 鱼或鱼组
                        fishTypeCount = 1 ,
                        pathway = "line_Z2405",
                    })
                    scene.AddFishBornEvent(i, {
                        fish = 111 ,                 -- 鱼或鱼组
                        fishTypeCount = 1 ,
                        pathway = "line_Z2406",
                    })
                else
                    scene.AddFishBornEvent(i, {
                        fish = 11 ,                   -- 鱼或鱼组
                        fishTypeCount = 1 ,
                        pathway = "line_Z2403",
                    }) 
                    scene.AddFishBornEvent(i, {
                        fish = 10 ,                 -- 鱼或鱼组
                        fishTypeCount = 1 ,
                        pathway = "line_Z2404",
                    })
                    scene.AddFishBornEvent(i, {
                        fish = 10 ,                   -- 鱼或鱼组
                        fishTypeCount = 1 ,
                        pathway = "line_Z2405",
                    })
                    scene.AddFishBornEvent(i, {
                        fish = 11 ,                 -- 鱼或鱼组
                        fishTypeCount = 1 ,
                        pathway = "line_Z2406",
                    })
                end
              end
              for i = 0, 59, 14 do
                scene.AddFishBornEvent(i, {
                    fish = 201 ,                 -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    pathway = "line_yz3",
                    offsetAngles = {math.pi / -2},
                })
              end

    end

    --场景3：--大王乌贼305，场景2，八爪章鱼312，场景11
    do
        
        local scene = scene3
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 17)   
        scene.AddSwitchBgMusicEvent(1, "bg_04")

        
        -- 持续时间段定义    
            local t1 = 60
            local t2 = 280
            local t3 = 120
            local t4 = 280
            local t5 = 120
        -- 第一段场景时间划分
            -- scene.AddSetPlayRatioEvent(t1, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+2.5, 1) --还原速度
            scene.AddShakeEvent(t1, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1, "jingbao") --警报响
            scene.AddBossWarningEvent(t1, FF_G.BossWarning_Purple) --预警泛紫
            scene.AddBossWarningEvent(t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 305})
            
            scene.AddSwitchBgEvent(t1 +4, 3)  -- 切换场景
            
            for i = t1+2.8+34 , t1+t2 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t1+2.8+30+34 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t1+2.8 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
           
            scene.AddSwitchBgMusicEvent(t2+t1+5, "bg_02")
            scene.AddSwitchBgEvent(t2+t1+5, 2)   -- 切换场景

        -- 第二段场景时间划分
            
            -- scene.AddSetPlayRatioEvent(t3+t1+t2, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t3+t1+t2+2.5, 1) --还原速度
            scene.AddShakeEvent(t3+t1+t2, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t3+t1+t2, "jingbao") --警报响
            scene.AddBossWarningEvent(t3+t1+t2, FF_G.BossWarning_Red) --预警泛红
            
            scene.AddHaiwanglaixiEvent(t3+t1+t2 +2, FF_G.Haiwanglaixi_FishType_KingOctopus) -- boss 预警
            scene.AddSwitchBgEvent(t3+t1+t2 +4, 11) -- 切换场景
            
            for i = t3+t1+t2+2.8+30+37 , t3+t1+t2+t4 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t3+t1+t2+2.8+37 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t3+t1+t2+2.8 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
            
            scene.AddSwitchBgEvent(t1+t2+t3+t4+5, 2)  -- 切换场景
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+5, "bg_01")
           
        -- 旋转场景 八爪章鱼场景
            for i = t3+t1+t2+8, t3+t1+t2+t4, 60 do
                scene.AddSetPlayBgAnimEvent(i, "turn1")
                scene.AddSetPlayBgAnimEvent(i + 15, "turn2")
                scene.AddSetPlayBgAnimEvent(i + 30, "turn3")
                scene.AddSetPlayBgAnimEvent(i + 45, "turn4")
            end      
        
        -- 出boss
            scene.AddRule(
                {
                startTime = t1 + 5,
                endTime = t1+t2-20,
                -- cdTime = 3.5,
                leaveCd = 0,
                deathCd = 0,
                groupName = 305,  
                limit = 1,
                }, 
                {
                fish = 305,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_boss",
                }
            )
            scene.AddRule(
                {
                    startTime =  t1+t2+t3+5,
                    endTime = t1+t2+t3+t4-12,
                    cdTime = 3.5,
                    leaveCd = 0,
                    deathCd = 0,
                    groupName = 312, 
                    limit = 3,
                },
                {
                    fish = 312,      
                    fishTypeCount = 1,
                    pathway= "line_1",
                }
            )
        -- 出special
            scene.AddRule(
                {
                startTime = 10,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = "special",  
                limit = 2,
                mutex = true,
                }, 
                {
                -- fish = 205, 
                fish = fishGroup["special"],     
                fishTypeCount = {1}, 
                pathwayGroup= "Group_special",
                }
            )
            
        
        
        -- 猫大爷
            scene.AddFishBornEvent( t1+t2+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent( t1+t2+10+40+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
            
            scene.AddFishBornEvent( t1+t2+t3+t4+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent( t1+t2+t3+t4+10+40+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
        -- 鱼王画图----line_ywht102_
            -- 雷达旋转中心鱼王
            for i = 87, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_ywht102_6",
                        subPathway = {
                            {
                                pathway = "line_348",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4* j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_ywht102_6",
                        subPathway = {
                            {
                                pathway = "line_349",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 101,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_6",
                    -- offsets = {{-20, -55}}, 
                    speedScale = 1
                })
            end

            for i = 16, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_ywht102_5",
                        subPathway = {
                            {
                                pathway = "line_348",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4* j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_ywht102_5",
                        subPathway = {
                            {
                                pathway = "line_349",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 100,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_5",
                    -- offsets = {{-10, 55}}, 
                    speedScale = 1
                })
            end
            -- 圆旋转中心鱼王
            for i = 765, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_ywht102_4",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 101,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_4",
                    -- offsets = {{-60 , 10}}, 
                    speedScale = 1
                })
            end
            
            for i = 515, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_ywht102_3",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 100,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_3",
                    -- offsets = {{20 , 0}}, 
                    speedScale = 1
                })
            end

            for i = 420, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 2,
                        fishTypeCount = 1,
                        pathway="line_ywht102_2",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 102,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_2",
                    -- offsets = {{-23, 5}}, 
                    speedScale = 1
                })
            end

            for i = 33, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 4,
                        fishTypeCount = 1,
                        pathway="line_ywht102_1",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 104,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_1",
                    -- offsets = {{60, -10}}, 
                    speedScale = 1
                })
            end      

        -- 出小鱼跟随： SetFishGroup("fish1", {0,1,2})
            for i = 7, t1-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishCount = {4,5,6},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_follow",
                })
            end
            for i = t1+7, t1+t2+t3-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishCount = {4,5,6},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_follow",
                })
            end
            for i = t1+t2+t3+7, t1+t2+t3+t4+t5, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishCount = {4,5,6},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_follow",
                })
            end
        -- 出小鱼群： SetFishGroup("fish1", {0,1,2})
            for i = 5, t1-2, 20 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish1"],                       -- 指定鱼组
                fishCount = {5},                -- 鱼的数量
                offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathwayGroup = "Group_group",
                })
            end
            for i = t1+8, t1+t2+t3-2, 20 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish1"],                       -- 指定鱼组
                fishCount = {5},                -- 鱼的数量
                offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathwayGroup = "Group_group",
                })
            end
            for i = t1+t2+t3+t4+5, t1+t2+t3+t4+t5, 20 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish1"],                       -- 指定鱼组
                fishCount = {5},                -- 鱼的数量
                offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathwayGroup = "Group_group",
                })
            end
        -- 出龙虾跟随
            for i = 10, t1-10, 140 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["longxia"],      -- 指定鱼组
                    fishCount = {4,5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end
            for i = t1+10, t1+t2+t3-12, 140 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["longxia"],      -- 指定鱼组
                    fishCount = {3,4},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end
            for i = t1+t2+t3+t4+13, t1+t2+t3+t4+t5, 140 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["longxia"],      -- 指定鱼组
                    fishCount = {3,3},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end

        -- 出小鱼单条:SetFishGroup("fish1", {0,1,2})
            for i = 0, t1-2, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            for i = t1+5.5, t1+t2+t3-2, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            for i = t1+t2+t3+8, t1+t2+t3+t4+t5, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
        
        -- 出普通中型鱼：SetFishGroup("fish2", {3,4,6,7,8,9,10,11,12})
            for i = 6, t1+t2+t3+t4+t5, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2L",
                })
            end
            for i = 4, t1+t2+t3+t4+t5, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2R",
                })
            end
            
        
        -- 出普通大鱼：SetFishGroup("fish3", {13,14,15,16,17})
        
            for i = 8, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3L",
                })
            end
            for i = 0, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3R",
                })
            end
            
        -- 出彩金鱼：SetFishGroup("goldedfish", {320,321,322,323,324})
            for i = 12, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishL",
                })
            end
            for i = 4, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishR",
                })
            end
            
            
        -- 补烈焰风暴：204
            scene.AddRule(
                {
                    startTime = 12,
                    endTime = t1-2,
                    cdTime = 1,
                    leaveCd = 5,
                    deathCd =40,
                    groupName = "Storm",
                    limit = 1,
                }, 
                {
                    fish = fishGroup["Storm"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Storm",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+15,
                    endTime = t1+t2+t3-2,
                    cdTime = 1,
                    leaveCd = 5,
                    deathCd =40,
                    groupName = "Storm",
                    limit = 1,
                }, 
                {
                    fish = fishGroup["Storm"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Storm",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+t2+t3+15,
                    endTime = t1+t2+t3+t4+t5-50,
                    cdTime = 1,
                    leaveCd = 5,
                    deathCd =40,
                    groupName = "Storm",
                    limit = 1,
                }, 
                {
                    fish = fishGroup["Storm"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Storm",
                
                }
            )        
        -- 出组合鱼SetFishGroup("combinedfish", {350,351,352,353,354,355,356})
        
            for i = 38, t1-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+30, t1+t2+t3-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+t2+t3+t4+27, t1+t2+t3+t4+t5, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
        -- 出比目鱼：5
            for i = 2, t1-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            for i = t1+5.5, t1+t2+t3-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            for i = t1+t2+t3+8, t1+t2+t3+t4+t5, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            
            
        -- 炸弹，钻头蟹
            for i = 18, t1-2, 21 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Carb",
                    offsetAngles = {math.pi / 2},
                })
            end
            for i = t1+18, t1+t2+t3-2, 21 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Carb",
                    offsetAngles = {math.pi / 2},
                })
            end
            for i = t1+t2+t3+18, t1+t2+t3+t4+t5-40, 21 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Carb",
                    offsetAngles = {math.pi / 2},
                })
            end
            
        -- 闪电鲨
            scene.AddRule(
                {
                    startTime = 40,
                    endTime = t1-2,
                    cdTime = 1,
                    leaveCd = 45,
                    deathCd =60,
                    groupName = 200,
                    limit = 1,
                }, 
                {
                    fish = 200,      
                    fishTypeCount = {1},
                    pathwayGroup = "Group_shadiansha",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+45,
                    endTime = t1+t2+t3-3,
                    cdTime = 1,
                    leaveCd = 45,
                    deathCd =60,
                    groupName = 200,
                    limit = 1,
                }, 
                {
                    fish = 200,      
                    fishTypeCount = {1},
                    pathwayGroup = "Group_shadiansha",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+t2+t3+45,
                    endTime = t1+t2+t3+t4+t5,
                    cdTime = 1,
                    leaveCd = 45,
                    deathCd =60,
                    groupName = 200,
                    limit = 1,
                }, 
                {
                    fish = 200,      
                    fishTypeCount = {1},
                    pathwayGroup = "Group_shadiansha",
                
                }
            )
            
        -- 出旋风鱼
            
            for i = 40, t1-2, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+40, t1+t2+t3-2, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+t2+t3+t4+40, t1+t2+t3+t4+t5, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
        
        

        -- 聚餐元宵
            scene.AddFishBornEvent(25, {
                fish = 325,      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_yuanxiao",
                createPrams = 
                {
                    fadeInSecs = 3,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 4,            -- 淡出持续时间
                    scaleInSec = 2,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent(t1+t2+55, {
                fish = 325,      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_yuanxiao",
                createPrams = 
                {
                    fadeInSecs = 3,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 4,            -- 淡出持续时间
                    scaleInSec = 2,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent(t1+t2+t3+t4+55, {
                fish = 325,      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_yuanxiao",
                createPrams = 
                {
                    fadeInSecs = 3,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 4,            -- 淡出持续时间
                    scaleInSec = 2,             -- 从小变大入场
                },
            })

            


    end
   
    --场景4------------------鱼阵2-4线绘圆---------------------
    
    do
        local scene = scene4
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0.0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")

            for i = 0, 1000, 3.5 do
                scene.AddFishBornEvent(i, {
                    fish = 10 ,                 -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    pathway = "line_98",
                })
            end
            for i = 0, 1000, 1.75 do
                scene.AddFishBornEvent(i, {
                    fish = 4 ,                 -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    pathway = "line_99",
                })
            end
            for i = 0, 1000, 3.5 do
                scene.AddFishBornEvent(i, {
                    fish = 10 ,                 -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    pathway = "line_100",
                })
            end
            for i = 0, 1000, 1.75 do
                scene.AddFishBornEvent(i, {
                    fish = 4 ,                 -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    pathway = "line_101",
                })
            end
            for i = 12, 100, 7 do
                scene.AddFishBornEvent(i, {
                    fish = 202 ,                 -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    pathway = "line_yz3",
                })
            end
            scene.AddRule(
                {
                    startTime = 8,
                    endTime = 100,
                    -- cdTime = 1,
                    leaveCd = 0,
                    deathCd =0,
                    groupName = 200,
                    limit = 1,
                }, 
                {
                    fish = 200,      
                    fishTypeCount = {1},
                    pathwayGroup = "Group_shadiansha",
                
                }
            )




    end 

    --场景5 海王荣耀310，场景2，八爪章鱼312，场景11
    do
        
        local scene = scene5
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 2)   
        scene.AddSwitchBgMusicEvent(1, "bg_04")

        
        -- 持续时间段定义    
            local t1 = 60
            local t2 = 280
            local t3 = 120
            local t4 = 280
            local t5 = 120
        -- 第一段场景时间划分
            -- scene.AddSetPlayRatioEvent(t1, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+2.5, 1) --还原速度
            scene.AddShakeEvent(t1, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1, "jingbao") --警报响
            scene.AddBossWarningEvent(t1, FF_G.BossWarning_Purple) --预警泛紫
            scene.AddBossWarningEvent(t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 310})
            scene.AddSwitchBgEvent(t1 +4, 7)  -- 切换场景
            
            for i = t1+2.8+34 , t1+t2 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t1+2.8+30+34 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t1+2.8 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
           
            scene.AddSwitchBgMusicEvent(t2+t1+5, "bg_02")
            scene.AddSwitchBgEvent(t2+t1+5, 2)   -- 切换场景

        -- 第二段场景时间划分
            
            -- scene.AddSetPlayRatioEvent(t3+t1+t2, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t3+t1+t2+2.5, 1) --还原速度
            scene.AddShakeEvent(t3+t1+t2, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t3+t1+t2, "jingbao") --警报响
            scene.AddBossWarningEvent(t3+t1+t2, FF_G.BossWarning_Red) --预警泛红
            scene.AddHaiwanglaixiEvent(t3+t1+t2 +2, FF_G.Haiwanglaixi_FishType_KingOctopus) -- boss 预警
            scene.AddSwitchBgEvent(t3+t1+t2 +4, 11) -- 切换场景
            
            for i = t3+t1+t2+2.8+30+37 , t3+t1+t2+t4 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t3+t1+t2+2.8+37 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t3+t1+t2+2.8 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
            
            scene.AddSwitchBgEvent(t1+t2+t3+t4+5, 2)  -- 切换场景
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+5, "bg_01")
           
        -- 旋转场景 八爪章鱼场景
            for i = t3+t1+t2+8, t3+t1+t2+t4, 60 do
                scene.AddSetPlayBgAnimEvent(i, "turn1")
                scene.AddSetPlayBgAnimEvent(i + 15, "turn2")
                scene.AddSetPlayBgAnimEvent(i + 30, "turn3")
                scene.AddSetPlayBgAnimEvent(i + 45, "turn4")
            end      
        
        -- 出boss
            scene.AddRule(
                {
                startTime = t1 + 5,
                endTime = t1+t2-10,
                -- cdTime = 3.5,
                leaveCd = 0,
                deathCd = 0,
                groupName = 310,  
                limit = 1,
                }, 
                {
                fish = 310,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_dragon",
                }
            )
            scene.AddRule(
                {
                    startTime =  t1+t2+t3+5,
                    endTime = t1+t2+t3+t4-12,
                    cdTime = 3.5,
                    leaveCd = 0,
                    deathCd = 0,
                    groupName = 312, 
                    limit = 3,
                },
                {
                    fish = 312,      
                    fishTypeCount = 1,
                    pathway= "line_1",
                }
            )
        -- 出special
            scene.AddRule(
                {
                startTime = 10,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = "special",  
                limit = 2,
                mutex = true,
                }, 
                {
                -- fish = 205, 
                fish = fishGroup["special"],     
                fishTypeCount = {1}, 
                pathwayGroup= "Group_special",
                }
            )
            
        
        
        -- 猫大爷
            scene.AddFishBornEvent( t1+t2+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent( t1+t2+10+40+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
            
            scene.AddFishBornEvent( t1+t2+t3+t4+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent( t1+t2+t3+t4+10+40+10, {
                fish = 206,      -- 指定鱼组
                fishTypeCount = 1,
                -- intervalTime = 1.5,
                pathwayGroup = "Group_mdy",
                createPrams = 
                {
                    fadeInSecs = 5,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
            })
        -- 鱼王画图----line_ywht102_
            -- 雷达旋转中心鱼王
            for i = 420, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_ywht102_6",
                        subPathway = {
                            {
                                pathway = "line_348",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4* j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_ywht102_6",
                        subPathway = {
                            {
                                pathway = "line_349",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 101,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_6",
                    -- offsets = {{-20, -55}}, 
                    speedScale = 1
                })
            end

            for i = 33, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_ywht102_5",
                        subPathway = {
                            {
                                pathway = "line_348",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4* j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_ywht102_5",
                        subPathway = {
                            {
                                pathway = "line_349",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.4 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 100,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_5",
                    -- offsets = {{-10, 55}}, 
                    speedScale = 1
                })
            end
            -- 圆旋转中心鱼王
            for i = 515, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_ywht102_4",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 101,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_4",
                    -- offsets = {{-60 , 10}}, 
                    speedScale = 1
                })
            end
            
            for i = 765, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_ywht102_3",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 100,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_3",
                    -- offsets = {{20 , 0}}, 
                    speedScale = 1
                })
            end

            for i = 87, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 2,
                        fishTypeCount = 1,
                        pathway="line_ywht102_2",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 102,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_2",
                    -- offsets = {{-23, 5}}, 
                    speedScale = 1
                })
            end

            for i = 16, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 4,
                        fishTypeCount = 1,
                        pathway="line_ywht102_1",
                        subPathway = {
                            {
                                pathway = "line_yuan1",
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.44 * j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                end
                scene.AddFishBornEvent(i, {
                    fish = 104,
                    fishTypeCount = 1,
                    pathway = "line_ywht102_1",
                    -- offsets = {{60, -10}}, 
                    speedScale = 1
                })
            end      

        -- 出小鱼跟随： SetFishGroup("fish1", {0,1,2})
            for i = 7, t1-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishCount = {4,5,6},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_follow",
                })
            end
            for i = t1+7, t1+t2+t3-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishCount = {4,5,6},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_follow",
                })
            end
            for i = t1+t2+t3+7, t1+t2+t3+t4+t5, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishCount = {4,5,6},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_follow",
                })
            end
        -- 出小鱼群： SetFishGroup("fish1", {0,1,2})
            for i = 5, t1-2, 20 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish1"],                       -- 指定鱼组
                fishCount = {5},                -- 鱼的数量
                offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathwayGroup = "Group_group",
                })
            end
            for i = t1+8, t1+t2+t3-2, 20 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish1"],                       -- 指定鱼组
                fishCount = {5},                -- 鱼的数量
                offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathwayGroup = "Group_group",
                })
            end
            for i = t1+t2+t3+t4+5, t1+t2+t3+t4+t5, 20 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish1"],                       -- 指定鱼组
                fishCount = {5},                -- 鱼的数量
                offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathwayGroup = "Group_group",
                })
            end
        -- 出龙虾跟随
            for i = 10, t1-2, 140 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["longxia"],      -- 指定鱼组
                    fishCount = {4,5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end
            for i = t1+10, t1+t2+t3-2, 140 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["longxia"],      -- 指定鱼组
                    fishCount = {3,4},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end
            for i = t1+t2+t3+t4+13, t1+t2+t3+t4+t5, 140 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["longxia"],      -- 指定鱼组
                    fishCount = {3,3},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end

        -- 出小鱼单条:SetFishGroup("fish1", {0,1,2})
            for i = 0, t1-2, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            for i = t1+5.5, t1+t2+t3-2, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            for i = t1+t2+t3+8, t1+t2+t3+t4+t5, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
        
        -- 出普通中型鱼：SetFishGroup("fish2", {3,4,6,7,8,9,10,11,12})
            for i = 6, t1+t2+t3+t4+t5, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2L",
                })
            end
            for i = 4, t1+t2+t3+t4+t5, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2R",
                })
            end
            
        
        -- 出普通大鱼：SetFishGroup("fish3", {13,14,15,16,17})
        
            for i = 8, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3L",
                })
            end
            for i = 0, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3R",
                })
            end
            
        -- 出彩金鱼：SetFishGroup("goldedfish", {320,321,322,323,324})
            for i = 12, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishL",
                })
            end
            for i = 4, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishR",
                })
            end
            
            
        -- 补烈焰风暴：204
            scene.AddRule(
                {
                    startTime = 10+5,
                    endTime = t1-2,
                    cdTime = 1,
                    leaveCd = 5,
                    deathCd =60,
                    groupName = "Storm",
                    limit = 1,
                }, 
                {
                    fish = fishGroup["Storm"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Storm",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+30+5,
                    endTime = t1+t2+t3-2,
                    cdTime = 1,
                    leaveCd = 5,
                    deathCd =60,
                    groupName = "Storm",
                    limit = 1,
                }, 
                {
                    fish = fishGroup["Storm"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Storm",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+t2+t3+30+5,
                    endTime = t1+t2+t3+t4+t5-50,
                    cdTime = 1,
                    leaveCd = 5,
                    deathCd =60,
                    groupName = "Storm",
                    limit = 1,
                }, 
                {
                    fish = fishGroup["Storm"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Storm",
                
                }
            )        
        -- 出组合鱼SetFishGroup("combinedfish", {350,351,352,353,354,355,356})
        
            for i = 38, t1-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+30, t1+t2+t3-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+t2+t3+t4+27, t1+t2+t3+t4+t5, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
        -- 出比目鱼：5
            for i = 2, t1-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            for i = t1+5.5, t1+t2+t3-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            for i = t1+t2+t3+8, t1+t2+t3+t4+t5, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            
            
        -- 炸弹，钻头蟹
            for i = 18, t1-2, 21 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Carb",
                    offsetAngles = {math.pi / 2},
                })
            end
            for i = t1+18, t1+t2+t3-2, 21 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Carb",
                    offsetAngles = {math.pi / 2},
                })
            end
            for i = t1+t2+t3+18, t1+t2+t3+t4+t5-40, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Carb",
                    offsetAngles = {math.pi / 2},
                })
            end
            
        -- 闪电鲨
            scene.AddRule(
                {
                    startTime = 40,
                    endTime = t1-2,
                    cdTime = 1,
                    leaveCd = 45,
                    deathCd =60,
                    groupName = 200,
                    limit = 1,
                }, 
                {
                    fish = 200,      
                    fishTypeCount = {1},
                    pathwayGroup = "Group_shadiansha",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+45,
                    endTime = t1+t2+t3-3,
                    cdTime = 1,
                    leaveCd = 45,
                    deathCd =60,
                    groupName = 200,
                    limit = 1,
                }, 
                {
                    fish = 200,      
                    fishTypeCount = {1},
                    pathwayGroup = "Group_shadiansha",
                
                }
            )
            scene.AddRule(
                {
                    startTime = t1+t2+t3+45,
                    endTime = t1+t2+t3+t4+t5,
                    cdTime = 1,
                    leaveCd = 45,
                    deathCd =60,
                    groupName = 200,
                    limit = 1,
                }, 
                {
                    fish = 200,      
                    fishTypeCount = {1},
                    pathwayGroup = "Group_shadiansha",
                
                }
            )
            
        -- 出旋风鱼
            
            for i = 40, t1-2, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+40, t1+t2+t3-2, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+t2+t3+t4+40, t1+t2+t3+t4+t5, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
        

        -- 聚餐元宵
            scene.AddFishBornEvent(25, {
                fish = 325,      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_yuanxiao",
                createPrams = 
                {
                    fadeInSecs = 3,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 4,            -- 淡出持续时间
                    scaleInSec = 2,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent(t1+t2+55, {
                fish = 325,      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_yuanxiao",
                createPrams = 
                {
                    fadeInSecs = 3,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 4,            -- 淡出持续时间
                    scaleInSec = 2,             -- 从小变大入场
                },
            })
            scene.AddFishBornEvent(t1+t2+t3+t4+55, {
                fish = 325,      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_yuanxiao",
                createPrams = 
                {
                    fadeInSecs = 3,             -- 淡入持续时间
                    fadeOutStartTime = 40,      -- 淡出开始时间
                    fadeOutSecs = 4,            -- 淡出持续时间
                    scaleInSec = 2,             -- 从小变大入场
                },
            })

            


    end

    --场景6：鱼阵3：-----------鱼阵-------鱼王--------六芒星魔法阵----
    do
        
        local scene = scene6
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")     
           
            for j = 0, 105, 8 do
                scene.AddFishBornEvent(j, {
                    fish = 101,
                    fishTypeCount = 1,
                    speedScale = 1 ,
                    pathway = "line_322",
                    -- offsets = {{-60, 0}},
                })
                for i = 1, 15 do
                    scene.AddFishBornEvent(j, {
                        fish = 1,      -- 指定鱼组
                        fishTypeCount = 1,              -- 鱼类型数量
                        pathway = "line_322",
                        subPathway = {
                            {
                                pathway = "line_336",
                                startTime = 0,
                                endTime = 20,
                                offsetTime = 0.5 * i,
                                useAngle = true,
                                speed = 160 ,
                            },
                        },
                    })
                end
                for i = 1, 15 do
                    scene.AddFishBornEvent(j, {
                        fish = 1,                        -- 指定鱼组
                        fishTypeCount = 1,              -- 鱼类型数量
                        pathway = "line_322",
                        subPathway = {
                            {
                                pathway = "line_337",
                                startTime = 0,
                                endTime = 20,
                                offsetTime = 0.5 * i,
                                useAngle = true,
                                speed = 160,
                            },
                        },
                    })
                end
                for i = 1, 19 do
                    scene.AddFishBornEvent(j, {
                        fish = 2,                       -- 指定鱼组
                        fishTypeCount = 1,              -- 鱼类型数量
                        pathway = "line_322",
                        subPathway = {
                            {
                                pathway = "line_334",
                                startTime = 0,
                                endTime = 20,
                                offsetTime = 0.5 * i,
                                useAngle = true,
                                speed = 160,
                            },
                        },
                    })
                end
            end
            for j = 4, 105, 8 do
                scene.AddFishBornEvent(j, {
                    fish = 102,
                    fishTypeCount = 1,
                    speedScale = 1 ,
                    pathway = "line_322",
                    -- offsets = {{-40, 0}},
                })
                for i = 1, 15 do
                    scene.AddFishBornEvent(j, {
                        fish = 2,      -- 指定鱼组
                        fishTypeCount = 1,              -- 鱼类型数量
                        pathway = "line_322",
                        subPathway = {
                            {
                                pathway = "line_336",
                                startTime = 0,
                                endTime = 20,
                                offsetTime = 0.5 * i,
                                useAngle = true,
                                speed = 160 ,
                            },
                        },
                    })
                end
                for i = 1, 15 do
                    scene.AddFishBornEvent(j, {
                        fish = 2,                        -- 指定鱼组
                        fishTypeCount = 1,              -- 鱼类型数量
                        pathway = "line_322",
                        subPathway = {
                            {
                                pathway = "line_337",
                                startTime = 0,
                                endTime = 20,
                                offsetTime = 0.5 * i,
                                useAngle = true,
                                speed = 160,
                            },
                        },
                    })
                end
                for i = 1, 19 do
                    scene.AddFishBornEvent(j, {
                        fish = 1,                       -- 指定鱼组
                        fishTypeCount = 1,              -- 鱼类型数量
                        pathway = "line_322",
                        subPathway = {
                            {
                                pathway = "line_334",
                                startTime = 0,
                                endTime = 20,
                                offsetTime = 0.5 * i,
                                useAngle = true,
                                speed = 160,
                            },
                        },
                    })
                end
            end
            for i = 2 , 105, 10 do
                scene.AddFishBornEvent(i, {
                    fish = {14,15,14,15},      -- 指定鱼组
                    fishTypeCount = 4,              -- 鱼类型数量
                    pathwayGroup = "Group_longxia",
                    speedScale = 0.6
                })
                
            end
            for i = 2 , 60, 10 do
               
                scene.AddFishBornEvent(i, {
                    fish = {202,203} ,                 -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    pathway = "line_Z23",
                    offsetAngles = {math.pi / -2},
                    speedScale = 1.75
                })
            end
    end 
       
    scene1.PushToGame(true)
    scene2.PushToGame(true)
    scene3.PushToGame(true)
    scene4.PushToGame(true)
    scene5.PushToGame(true)
    scene6.PushToGame(true)

    
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

