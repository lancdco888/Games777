-- level/game142.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")

    local scene1 = FishEventHelper.CreateScene(875)
    local scene2 = FishEventHelper.CreateScene(110)
    local scene3 = FishEventHelper.CreateScene(875)
    local scene4 = FishEventHelper.CreateScene(120)
    local scene5 = FishEventHelper.CreateScene(875)
    local scene6 = FishEventHelper.CreateScene(115)

    --场景1：随机boss ，蛮荒凶兽336 
    do
     
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 16)   -- 场景
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
            scene.AddBossWarningEvent(t1 +2.5, FF_G.BossWarning_BossCome, {fishTypeId = 333})
            scene.AddSwitchBgMusicEvent(t1+2.8, "fk_bg_king_02") --下个场景音效
            scene.AddSwitchBgEvent(t1 +2.5, 17)  -- 场景

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
            scene.AddSwitchBgEvent(t2+t1+5, 4)   -- 切换场景

        -- 第二段场景时间划分
            -- scene.AddSetPlayRatioEvent(t1+t2+t3, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+t2+t3+2.5, 1) --还原速度
            scene.AddShakeEvent(t1+t2+t3, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1+t2+t3, "jingbao") --警报响
            scene.AddBossWarningEvent(t3+t1+t2, FF_G.BossWarning_Purple) --预警泛红
            scene.AddBossWarningEvent(t1+t2+t3+2, FF_G.BossWarning_BisonComing) --蛮荒凶兽
            scene.AddSwitchBgMusicEvent(t1+t2+t3+2.8, "bossstage") --下个场景音效
            scene.AddSwitchBgEvent(t1+t2+t3 +2.5, 15) -- 场景
            for i = t3+t1+t2+2.8+30+37 , t3+t1+t2+t4 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t3+t1+t2+2.8+37 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t3+t1+t2+2.8 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
            scene.AddSwitchBgEvent(t1+t2+t3+t4+10, 4)  -- 切换场景
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+10, "bg_02")

            
            
        -- 出boss
            scene.AddRule(
                {
                startTime = t1 + 5,
                endTime = t1+t2-10,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = "boss",  
                limit = 1,
                }, 
                {
                fish = fishGroup["boss"],      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_boss",
                }
            )
           
            scene.AddRule(
                {
                startTime = t1+t2+t3 + 10,
                endTime = t1+t2+t3+t4-10,
                -- cdTime = 0,
                leaveCd = 5,
                deathCd = 5,
                groupName = 336,  
                limit = 1,
                }, 
                {
                fish = 336,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_niu",
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
                mutex = true,
                limit = 1,
                }, 
                {
                fish = fishGroup["special"],     
                fishTypeCount = {1}, 
                pathwayGroup= "Group_special",
                }
            )
        
        -- 鱼王画图-----

            for i = 46, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_411",
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
                        pathway="line_411",
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
                    pathway = "line_411",
                    -- offsets = {{-20, -55}}, 
                    speedScale = 1
                })
            end

            for i = 25, t1+t2+t3+t4+t5, 860 do
                for j = 1,20 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_412",
                        -- script = "rotate_sub_pathway.lua",
                        subPathway = {
                            {
                                pathway = "line_409",
                                
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.35* j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                    
                end
                scene.AddFishBornEvent(i, {
                    fish = 101,
                    fishTypeCount = 1,
                    pathway = "line_412",
                    -- offsets = {{-10, 55}}, 
                    speedScale = 1
                })
            end

            for i = 143, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_413",
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
                    pathway = "line_413",
                    -- offsets = {{-60 , 10}}, 
                    speedScale = 1
                })
            end
            
            for i = 755, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_414",
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
                    pathway = "line_414",
                    -- offsets = {{20 , 0}}, 
                    speedScale = 1
                })
            end

            for i = 385, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 2,
                        fishTypeCount = 1,
                        pathway="line_415",
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
                    pathway = "line_415",
                    -- offsets = {{-23, 5}}, 
                    speedScale = 1
                })
            end

            for i = 521, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 4,
                        fishTypeCount = 1,
                        pathway="line_416",
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
                    pathway = "line_416",
                    -- offsets = {{60, -10}}, 
                    speedScale = 1
                })
            end 
        
        -- 出小鱼跟随： SetFishGroup("fish1", {0,1,2})
            for i = 17, t1-2, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishCount = {4,5},          -- 鱼的数量
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
                    fishCount = {4,5},          -- 鱼的数量
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
                    fishCount = {4,5},          -- 鱼的数量
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
            for i = t1+18, t1+t2+t3-2, 20 do
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
            for i = t1+t2+t3+25, t1+t2+t3+t4+t5, 20 do
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
                    fishCount = {4,5},          -- 鱼的数量
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
                    fishCount = {4,5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end

        -- 出小鱼单条:SetFishGroup("fish1", {0,1,2})
            for i = 0, t1+t2+t3+t4+t5, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {5, 4},
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
            
        -- 补烈焰风暴、钻头蟹：204
            scene.AddRule(
                {
                    startTime = 23,
                    endTime = t1+t2+t3+t4+t5-50,
                    cdTime = 1,
                    leaveCd = 3,
                    deathCd =45,
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
            for i = t1+38, t1+t2+t3-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+t2+t3+38, t1+t2+t3+t4+t5, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
        -- 出比目鱼：5
            for i = 2, t1+t2+t3+t4+t5, 10 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            
            
        -- 炸弹，连环炸弹
            scene.AddRule(
                {
                startTime = 10,
                endTime = t1+t2+t3+t4+t5-40,
                -- cdTime = 1,
                leaveCd = 0,
                deathCd = 15,
                groupName = "Carb",
                -- mutex = true,
                limit = 1,
                }, 
                {
                fish = fishGroup["Carb"],     
                fishTypeCount = {1}, 
                pathwayGroup= "Group_Carb",
                }
            )
            
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
            for i = t1+t2+t3+40, t1+t2+t3+t4+t5, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            
        

        -- 聚财元宵
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
        -- 第一阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+5,
                endTime = t1+t2+t3,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = 10,  
                limit = 15,
                }, 
                {
                fish = 10,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            
            scene.AddRule(
                {
                startTime = t1+t2+10,
                endTime = t1+t2+t3,
                cdTime = 1,
                leaveCd = 1,
                deathCd = 1,
                groupName = 110,  
                limit = 1,
                }, 
                {
                fish = 110,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            
        -- 第二阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+t3+t4+5,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = 11,  
                limit = 15,
                }, 
                {
                fish = 11,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            scene.AddRule(
                {
                startTime = t1+t2+t3+t4+10,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 1,
                deathCd = 1,
                groupName = 111,  
                limit = 1,
                }, 
                {
                fish = 111,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            


    end
              
    --场景2：鱼阵3-鱼王全聚-折线阵
    do
     
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        scene.AddRule(
                {
                startTime = 5,
                endTime = 60,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = "Carb",  
                limit = 1,
                }, 
                {
                fish = fishGroup["Carb"],      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_Carb",
                }
        )
        scene.AddRule(
                {
                startTime = 60,
                endTime = 95,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 202,  
                limit = 1,
                }, 
                {
                fish = 202,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_Carb",
                }
        )


        for i = 0, 2, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 2.5, 2.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 100 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 3, 5, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end

         for i = 6, 8, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 8.5, 8.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 101 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 9, 11, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
        
         for i = 12, 14, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 14.5, 14.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 102 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 15, 17, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end

         for i = 18, 20, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 20.5, 20.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 103 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 21, 23, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end

         for i = 25, 27, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 27.5, 27.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 104 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 28, 30, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end

         for i = 33, 35, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 35.5, 35.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 106 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 36, 38, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end

         for i = 41, 43, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 43.5, 43.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 107 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 44, 46, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end

         for i = 48, 50, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 50.5, 50.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 110 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end
         for i = 51, 52, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_102",           -- 线或线组
            })
         end

         for i = 0, 2, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 2.5, 2.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 100 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 3, 5, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end

         for i = 6, 8, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 8.5, 8.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 101 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 9, 11, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
        
         for i = 12, 14, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 14.5, 14.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 102 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 15, 17, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end

         for i = 18, 20, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 20.5, 20.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 103 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 21, 23, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end

         for i = 25, 27, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 27.5, 27.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 104 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 28, 30, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end

         for i = 33, 35, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 35.5, 35.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 106 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 36, 38, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end

         for i = 41, 43, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 43.5, 43.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 107 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 44, 46, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end

         for i = 48, 50, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 50.5, 50.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 110 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
         for i = 51, 52, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_103",           -- 线或线组
            })
         end
        
         for i = 0, 2, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 2.5, 2.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 100 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 3, 5, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end

         for i = 6, 8, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 8.5, 8.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 101 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 9, 11, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
        
         for i = 12, 14, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 14.5, 14.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 102 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 15, 17, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end

         for i = 18, 20, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 20.5, 20.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 103 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 21, 23, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end

         for i = 25, 27, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 27.5, 27.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 104 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 28, 30, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end

         for i = 33, 35, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 35.5, 35.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 106 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 36, 38, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end

         for i = 41, 43, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 43.5, 43.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 107 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 44, 46, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end

         for i = 48, 50, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 50.5, 50.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 110 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end
         for i = 51, 52, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_104",           -- 线或线组
            })
         end

         for i = 0, 2, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 2.5, 2.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 100 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 3, 5, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end

         for i = 6, 8, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 8.5, 8.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 101 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 9, 11, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
        
         for i = 12, 14, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 14.5, 14.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 102 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 15, 17, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end

         for i = 18, 20, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 20.5, 20.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 103 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 21, 23, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.25,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end

         for i = 25, 27, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 27.5, 27.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 104 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 28, 30, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.6,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end

         for i = 33, 35, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 35.5, 35.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 106 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 36, 38, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 3,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end

         for i = 41, 43, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 43.5, 43.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 107 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 44, 46, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end

         for i = 48, 50, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 50.5, 50.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 110 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 51, 52, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.75,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_105",           -- 线或线组
            })
         end
         for i = 53, 105, 3 do
            scene.AddFishBornEvent(i, {
                fish = {4,4,4,4,4},
                fishTypeCount = {5},
                pathwayGroup = "Group_yzxcyL",
            })
        end
        for i = 53, 105, 3 do
            scene.AddFishBornEvent(i, {
                fish = {10,10,10,10},
                fishTypeCount = {4},
                pathwayGroup = "Group_yzxcyR",
            })
        end
        for i = 54, 105, 10 do
            scene.AddFishBornEvent(i, {
                fish = 104,
                fishTypeCount = 1,
                pathwayGroup = "Group_yzhjxcyL",
            })
        end
        for i = 54, 105, 10 do
            scene.AddFishBornEvent(i, {
                fish = 110,
                fishTypeCount = 1,
                pathwayGroup = "Group_yzhjxcyR",
            })
        end
    end

    --场景3：随机boss ，蛮荒凶兽336 背景15
    
    do
     
        local scene = scene3
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 19)   -- 场景
        scene.AddSwitchBgMusicEvent(1, "OneOutOfSix_BG")
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
            scene.AddBossWarningEvent(t1 +2.5, FF_G.BossWarning_BossCome, {fishTypeId = 333})
            for i = t1+2.8+34 , t1+t2 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t1+2.8+30+34 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t1+2.8 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
            scene.AddSwitchBgEvent(t1 +4.5, 7)  -- 场景

            scene.AddSwitchBgMusicEvent(t2+t1+10, "bg_04")
            scene.AddSwitchBgEvent(t2+t1+10, 4)   -- 切换场景

        -- 第二段场景时间划分
            -- scene.AddSetPlayRatioEvent(t1+t2+t3, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+t2+t3+2.5, 1) --还原速度
            scene.AddShakeEvent(t1+t2+t3, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1+t2+t3, "jingbao") --警报响
            scene.AddBossWarningEvent(t3+t1+t2, FF_G.BossWarning_Purple) --预警泛红
            scene.AddBossWarningEvent(t1+t2+t3+2, FF_G.BossWarning_BisonComing) --牛
            for i = t3+t1+t2+2.8+30+37 , t3+t1+t2+t4 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t3+t1+t2+2.8+37 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t3+t1+t2+2.8 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
            scene.AddSwitchBgEvent(t1+t2+t3 +4.5, 16) -- 场景

            scene.AddSwitchBgEvent(t1+t2+t3+t4+10, 4)  -- 切换场景
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+10, "bg_04")
        -- 出boss
            scene.AddRule(
                {
                startTime = t1 + 5,
                endTime = t1+t2-10,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = "boss",  
                limit = 1,
                }, 
                {
                fish = fishGroup["boss"],      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_boss",
                }
            )
           
            scene.AddRule(
                {
                startTime = t1+t2+t3 + 10,
                endTime = t1+t2+t3+t4-10,
                -- cdTime = 0,
                leaveCd = 5,
                deathCd = 5,
                groupName = 336,  
                limit = 1,
                }, 
                {
                fish = 336,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_niu",
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
                mutex = true,
                limit = 1,
                }, 
                {
                fish = fishGroup["special"],     
                fishTypeCount = {1}, 
                pathwayGroup= "Group_special",
                }
            )
            
            
        
        -- 鱼王画图-----

            for i = 46, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_411",
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
                        pathway="line_411",
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
                    pathway = "line_411",
                    -- offsets = {{-20, -55}}, 
                    speedScale = 1
                })
            end

            for i = 25, t1+t2+t3+t4+t5, 860 do
                for j = 1,20 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_412",
                        -- script = "rotate_sub_pathway.lua",
                        subPathway = {
                            {
                                pathway = "line_409",
                                
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.35* j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                    
                end
                scene.AddFishBornEvent(i, {
                    fish = 101,
                    fishTypeCount = 1,
                    pathway = "line_412",
                    -- offsets = {{-10, 55}}, 
                    speedScale = 1
                })
            end

            for i = 143, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_413",
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
                    pathway = "line_413",
                    -- offsets = {{-60 , 10}}, 
                    speedScale = 1
                })
            end
            
            for i = 755, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_414",
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
                    pathway = "line_414",
                    -- offsets = {{20 , 0}}, 
                    speedScale = 1
                })
            end

            for i = 385, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 2,
                        fishTypeCount = 1,
                        pathway="line_415",
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
                    pathway = "line_415",
                    -- offsets = {{-23, 5}}, 
                    speedScale = 1
                })
            end

            for i = 521, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 4,
                        fishTypeCount = 1,
                        pathway="line_416",
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
                    pathway = "line_416",
                    -- offsets = {{60, -10}}, 
                    speedScale = 1
                })
            end 
        
        -- 出小鱼跟随： SetFishGroup("fish1", {0,1,2})
            for i = 17, t1-2, 20 do
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
            for i = t1+18, t1+t2+t3-2, 20 do
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
            for i = t1+t2+t3+25, t1+t2+t3+t4+t5, 20 do
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
                    fishCount = {4,5},          -- 鱼的数量
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
                    fishCount = {4,5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end
        -- 出小鱼单条:SetFishGroup("fish1", {0,1,2})
            for i = 0, t1+t2+t3+t4+t5, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {5, 4},
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
                    startTime = 25,
                    endTime = t1+t2+t3+t4+t5-50,
                    cdTime = 1,
                    leaveCd = 3,
                    deathCd =45,
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
            for i = t1+38, t1+t2+t3-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+t2+t3+38, t1+t2+t3+t4+t5, 190 do
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
            scene.AddRule(
                {
                startTime = 10,
                endTime = t1+t2+t3+t4+t5-40,
                -- cdTime = 1,
                leaveCd = 0,
                deathCd = 15,
                groupName = "Carb",
                -- mutex = true,
                limit = 1,
                }, 
                {
                fish = fishGroup["Carb"],     
                fishTypeCount = {1}, 
                pathwayGroup= "Group_Carb",
                }
            )
            
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
            
            for i = 35, t1-2, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+25, t1+t2+t3-2, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+t2+t3+18, t1+t2+t3+t4+t5, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            
        -- 小丑鱼学徒
            for i =15, t1, 13 do
                scene.AddFishBornEvent(i, {
                    fish = 326,      
                    fishTypeCount = 1,
                    pathwayGroup = "Group_bubig",
                    
                })
            end
            for i =t1+t2+15, t1+t2+t3, 13 do
                scene.AddFishBornEvent(i, {
                    fish = 326,      
                    fishTypeCount = 1,
                    pathwayGroup = "Group_bubig",
                    
                })
            end
            for i =t1+t2+t3+t4+15, t1+t2+t3+t4+t5, 13 do
                scene.AddFishBornEvent(i, {
                    fish = 326,      
                    fishTypeCount = 1,
                    pathwayGroup = "Group_bubig",
                    
                })
            end

        -- 聚财元宵
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
        -- 第一阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+5,
                endTime = t1+t2+t3,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = 10,  
                limit = 15,
                }, 
                {
                fish = 10,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            
            scene.AddRule(
                {
                startTime = t1+t2+10,
                endTime = t1+t2+t3,
                cdTime = 1,
                leaveCd = 1,
                deathCd = 1,
                groupName = 110,  
                limit = 1,
                }, 
                {
                fish = 110,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            
        -- 第二阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+t3+t4+5,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = 11,  
                limit = 15,
                }, 
                {
                fish = 11,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            scene.AddRule(
                {
                startTime = t1+t2+t3+t4+10,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 1,
                deathCd = 1,
                groupName = 111,  
                limit = 1,
                }, 
                {
                fish = 111,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )

        

                                  
    end
    

    --场景4：鱼阵4-龙虾阵
    do
     
        local scene = scene4
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
   
        for i = 0, 110, 1.75 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                     -- 前进速度
                fish = {6,6,6,6,6,6,6,6,6,106} ,    -- 鱼或鱼组
                fishTypeCount = {10} ,              -- 数量
                pathwayGroup = "Group_longxia2",    -- 线或线组
            })
        end
        for i = 10, 59, 14 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 0.7,                   -- 前进速度
                fish = {202,201} ,                  -- 鱼或鱼组
                fishTypeCount = 1 ,
                pathway = "line_yzd1",              -- 线或线组
                offsetAngles = {math.pi / -2},
            })
        end
        for i = 17, 90, 14 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                     -- 前进速度
                fish = {202,203} ,                  -- 鱼或鱼组
                fishTypeCount = 1 ,
                pathway = "line_yz3",               -- 线或线组
                offsetAngles = {math.pi / -2},
            })
        end

    end

    --场景5：随机boss ，蛮荒凶兽336 背景15
    
    do
     
        local scene = scene5
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 8)   -- 场景
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
            scene.AddBossWarningEvent(t1 +2.5, FF_G.BossWarning_BossCome, {fishTypeId = 333})
            scene.AddSwitchBgMusicEvent(t1+2.8, "fk_bg_king_02") --下个场景音效
            scene.AddSwitchBgEvent(t1 +2.5, 6)  -- 场景

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
            scene.AddSwitchBgEvent(t2+t1+5, 4)   -- 切换场景

        -- 第二段场景时间划分
            -- scene.AddSetPlayRatioEvent(t1+t2+t3, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+t2+t3+2.5, 1) --还原速度
            scene.AddShakeEvent(t1+t2+t3, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1+t2+t3, "jingbao") --警报响
            scene.AddBossWarningEvent(t3+t1+t2, FF_G.BossWarning_Purple) --预警泛红
            scene.AddBossWarningEvent(t1+t2+t3+2, FF_G.BossWarning_BisonComing) --牛
            scene.AddSwitchBgMusicEvent(t1+t2+t3+2.8, "bossstage") --下个场景音效
            scene.AddSwitchBgEvent(t1+t2+t3 +2.5, 16) -- 场景
            for i = t3+t1+t2+2.8+30+37 , t3+t1+t2+t4 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t3+t1+t2+2.8+37 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t3+t1+t2+2.8 ,t3+t1+t2+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
            scene.AddSwitchBgEvent(t1+t2+t3+t4+10, 4)  -- 切换场景
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+10, "bg_02")
            
            
        -- 出boss
            scene.AddRule(
                {
                startTime = t1 + 5,
                endTime = t1+t2-10,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = "boss",  
                limit = 1,
                }, 
                {
                fish = fishGroup["boss"],      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_boss",
                }
            )
            
            scene.AddRule(
                {
                startTime = t1+t2+t3 + 10,
                endTime = t1+t2+t3+t4-10,
                -- cdTime = 0,
                leaveCd = 5,
                deathCd = 5,
                groupName = 336,  
                limit = 1,
                }, 
                {
                fish = 336,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_niu",
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
                mutex = true,
                limit = 1,
                }, 
                {
                fish = fishGroup["special"],     
                fishTypeCount = {1}, 
                pathwayGroup= "Group_special",
                }
            )
        -- 鱼王画图-----

            for i = 143, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_411",
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
                        pathway="line_411",
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
                    pathway = "line_411",
                    -- offsets = {{-20, -55}}, 
                    speedScale = 1
                })
            end

            for i = 750, t1+t2+t3+t4+t5, 860 do
                for j = 1,20 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_412",
                        -- script = "rotate_sub_pathway.lua",
                        subPathway = {
                            {
                                pathway = "line_409",
                                
                                startTime = 0,
                                endTime = 30,
                                offsetTime = 0.35* j,
                                useAngle = true,
                                speed = 200,
                            },
                        },
                    })
                    
                end
                scene.AddFishBornEvent(i, {
                    fish = 101,
                    fishTypeCount = 1,
                    pathway = "line_412",
                    -- offsets = {{-10, 55}}, 
                    speedScale = 1
                })
            end

            for i = 46, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_413",
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
                    pathway = "line_413",
                    -- offsets = {{-60 , 10}}, 
                    speedScale = 1
                })
            end
            
            for i = 25, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_414",
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
                    pathway = "line_414",
                    -- offsets = {{20 , 0}}, 
                    speedScale = 1
                })
            end

            for i = 521, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 2,
                        fishTypeCount = 1,
                        pathway="line_415",
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
                    pathway = "line_415",
                    -- offsets = {{-23, 5}}, 
                    speedScale = 1
                })
            end

            for i = 385, t1+t2+t3+t4+t5, 860 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 4,
                        fishTypeCount = 1,
                        pathway="line_416",
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
                    pathway = "line_416",
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
            for i = t1+t2+t3+5, t1+t2+t3+t4+t5, 20 do
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
            for i = 24, t1-2, 140 do
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
                    fishCount = {4,5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_lxfollow",
                })
            end
            for i = t1+t2+t3+10, t1+t2+t3+t4+t5, 140 do
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

        -- 出小鱼单条:SetFishGroup("fish1", {0,1,2})
            for i = 0, t1+t2+t3+t4+t5, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {5, 4},
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
            
        -- 补烈焰风暴、钻头蟹：204
            scene.AddRule(
                {
                    startTime = 20,
                    endTime = t1+t2+t3+t4+t5-50,
                    cdTime = 1,
                    leaveCd = 3,
                    deathCd =45,
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
            for i = t1+38, t1+t2+t3-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+t2+t3+38, t1+t2+t3+t4+t5, 190 do
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
            
        -- 炸弹，连环炸弹
            scene.AddRule(
                {
                startTime = 10,
                endTime = t1+t2+t3+t4+t5-40,
                -- cdTime = 1,
                leaveCd = 0,
                deathCd = 15,
                groupName = "Carb",
                -- mutex = true,
                limit = 1,
                }, 
                {
                fish = fishGroup["Carb"],     
                fishTypeCount = {1}, 
                pathwayGroup= "Group_Carb",
                }
            )
            
        -- 闪电鲨
            scene.AddRule(
                {
                    startTime = 45,
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
                    endTime = t1+t2+t3-2,
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
                    endTime = t1+t2+t3+t3+t5,
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
            for i = t1+t2+t3+40, t1+t2+t3+t4+t5, 60 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            
        

        -- 聚财元宵
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
            scene.AddFishBornEvent(t1+t2+15, {
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
            scene.AddFishBornEvent(t1+t2+t3+t4+19, {
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
        -- 第一阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+5,
                endTime = t1+t2+t3,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = 10,  
                limit = 15,
                }, 
                {
                fish = 10,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            
            scene.AddRule(
                {
                startTime = t1+t2+10,
                endTime = t1+t2+t3,
                cdTime = 1,
                leaveCd = 1,
                deathCd = 1,
                groupName = 110,  
                limit = 1,
                }, 
                {
                fish = 110,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            
        -- 第二阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+t3+t4+5,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = 11,  
                limit = 15,
                }, 
                {
                fish = 11,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            scene.AddRule(
                {
                startTime = t1+t2+t3+t4+10,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 1,
                deathCd = 1,
                groupName = 111,  
                limit = 1,
                }, 
                {
                fish = 111,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )

                              
    end

    -- 场景6：鱼阵12-圆圈缩小-鱼王
    do
     
        local scene = scene6
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")

         for i = 0, 105, 20 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.4,                                       -- 前进速度
                fish = {12,12,12,12,12,12,12,12,12,12,12,112} ,         -- 鱼或鱼组
                fishTypeCount = {12} ,                                  -- 数量
                pathwayGroup = "Group_quan01",                          -- 线或线组
            })
         end
         for i = 4, 105, 20 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2,                                         -- 前进速度
                fish = {11,11,11,11,11,11,11,11,11,11,11,111} ,         -- 鱼或鱼组
                fishTypeCount = {12} ,                                  -- 数量
                pathwayGroup = "Group_quan01",                          -- 线或线组
            })
         end
         for i = 8, 105, 20 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.4,                                       -- 前进速度
                fish = {10,10,10,10,10,10,10,10,10,10,10,110} ,         -- 鱼或鱼组
                fishTypeCount = {12} ,                                  -- 数量
                pathwayGroup = "Group_quan01",                          -- 线或线组
            })
         end
         for i = 12, 105, 20 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.2,                                       -- 前进速度
                fish = {9,9,9,9,9,9,9,9,9,9,9,109} ,                    -- 鱼或鱼组
                fishTypeCount = {12} ,                                  -- 数量
                pathwayGroup = "Group_quan01",                          -- 线或线组
            })
         end
         for i = 16, 105, 20 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.4,                                       -- 前进速度
                fish = {7,7,7,7,7,7,7,7,7,7,7,107} ,                    -- 鱼或鱼组
                fishTypeCount = {12} ,                                  -- 数量
                pathwayGroup = "Group_quan01",                          -- 线或线组
            })
         end
        for i = 5, 59, 14 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 0.7,                   -- 前进速度
                fish = {202,201} ,                  -- 鱼或鱼组
                fishTypeCount = 1 ,
                pathway = "line_yzd1",              -- 线或线组
                offsetAngles = {math.pi / -2},
            })
        end
        for i = 12, 59, 14 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                     -- 前进速度
                fish = {202,201} ,                  -- 鱼或鱼组
                fishTypeCount = 1 ,
                pathway = "line_yz3",               -- 线或线组
                offsetAngles = {math.pi / -2},
            })
        end
        for i = 70, 100, 12 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                     -- 前进速度
                fish = 202 ,                  -- 鱼或鱼组
                fishTypeCount = 1 ,
                pathway = "line_yz3",               -- 线或线组
                offsetAngles = {math.pi / -2},
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

