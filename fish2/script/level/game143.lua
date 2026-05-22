-- level/game143.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")

    

    local scene1 = FishEventHelper.CreateScene(877)
    local scene2 = FishEventHelper.CreateScene(120)
    local scene3 = FishEventHelper.CreateScene(877)
    local scene4 = FishEventHelper.CreateScene(115)
    local scene5 = FishEventHelper.CreateScene(877)
    local scene6 = FishEventHelper.CreateScene(115)

    --场景1：随机boss，金色龙虾将军 314，背景19
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 17)   
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
            -- scene.AddHaiwanglaixiEvent(t +2, FF_G.Haiwanglaixi_FishType_NightBeast)
            scene.AddBossWarningEvent(t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 333})
            -- scene.AddSwitchBgMusicEvent(t+2.8, "bossstage") --下个场景音效
            -- scene.AddSwitchBgEvent(t +4.5, 2)  -- 场景
            for i = t1+2.8 , t1+t2 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t1+2.8+30 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t1+2.8+30+37 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
            -- scene.AddSwitchBgEvent(370+5, 2)
            scene.AddSwitchBgMusicEvent(t1+t2+5, "OneOutOfSix_BG")
           
        -- 第二段场景时间划分
 
            -- scene.AddSetPlayRatioEvent(t1+t2+t3, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+t2+t3+2.5, 1) --还原速度
            scene.AddShakeEvent(t1+t2+t3, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1+t2+t3, "jingbao") --警报响
            scene.AddBossWarningEvent(t1+t2+t3, FF_G.BossWarning_Red) --预警泛紫
            scene.AddBossWarningEvent(t1+t2+t3 +2, FF_G.BossWarning_BossCome, {fishTypeId = 314})
            
            scene.AddSwitchBgEvent(t1+t2+t3 +4, 19) -- 场景
            scene.AddSetPlayBgAnimEvent(t1+t2+t3 +4.5, "scar", true) -- 循环播发场景动画 “true”
            
            
            for i = t1+t2+t3+2.8 , t1+t2+t3+t4 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t1+2.8+30 ,t1+t2+t3+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t1+2.8+30+37 ,t1+t2+t3+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
            

            
            scene.AddSwitchBgEvent(t1+t2+t3+t4+15, 1)
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+15, "OneOutOfSix_BG")

    
        
            
        
        -- 出boss
            scene.AddRule(
                {
                startTime = t1 + 5,
                endTime = t1+t2-10,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 10,
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
                    startTime =  t1+t2+t3 + 5,
                    endTime = t1+t2+t3+t4-10,
                    -- cdTime = 1,
                    leaveCd = 0,
                    deathCd = 0,
                    groupName = 314, 
                    limit = 1,
                },
                {
                    fish = 314,      
                    fishTypeCount = 1,
                    pathwayGroup= "Group_boss",
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

        -- 出小鱼跟随： SetFishGroup("fish1", {0,1,2})
            for i = 7, t1-2, 20 do
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
            for i = t1+8, t1+t2+t3-2, 25 do
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
            for i = t1+t2+t3+5, t1+t2+t3+t3+t5, 27 do
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
            for i = 11, t1-2, 140 do
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
            for i = t1+13, t1+t2+t3-2, 145 do
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
            for i = t1+t2+t3+t4+10, t1+t2+t3+t4+t5, 145 do
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
            for i = t1+t2+t3+t4+38, t1+t2+t3+t4+t5, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
        -- 出比目鱼：5
            for i = 2, t1+t2+t3+t4+t5, 20 do
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
            -- for i = 8, t1-2, 15 do
            --     scene.AddFishBornEvent(i, {
            --         fish = fishGroup["Carb"],
            --         fishTypeCount = {1},
            --         pathwayGroup = "Group_Carb",
            --         offsetAngles = {math.pi / 2},
            --     })
            -- end
            -- for i = t1+8, t1+t2+t3-2, 15 do
            --     scene.AddFishBornEvent(i, {
            --         fish = fishGroup["Carb"],
            --         fishTypeCount = {1},
            --         pathwayGroup = "Group_Carb",
            --         offsetAngles = {math.pi / 2},
            --     })
            -- end
            -- for i = t1+t2+t3+8, t1+t2+t3+t4+t5-40, 15 do
            --     scene.AddFishBornEvent(i, {
            --         fish = fishGroup["Carb"],
            --         fishTypeCount = {1},
            --         pathwayGroup = "Group_Carb",
            --         offsetAngles = {math.pi / 2},
            --     })
            -- end
            
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
            
            for i = 40, t1-2, 90 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+40, t1+t2+t3-2, 90 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+t2+t3+40, t1+t2+t3+t4+t5, 90 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end

        -- 出辅助线-----

            for i = 30, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_350",
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
                        pathway="line_350",
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
                    pathway = "line_350",
                    -- offsets = {{-20, -55}}, 
                    speedScale = 1
                })
            end

            for i = 89, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_351",
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
                        pathway="line_351",
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
                    pathway = "line_351",
                    -- offsets = {{-10, 55}}, 
                    speedScale = 1
                })
            end

            for i = 150, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_346",
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
                    pathway = "line_346",
                    -- offsets = {{-60 , 10}}, 
                    speedScale = 1
                })
            end
            
            for i = 400, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_347",
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
                    pathway = "line_347",
                    -- offsets = {{20 , 0}}, 
                    speedScale = 1
                })
            end

            for i = 520, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 2,
                        fishTypeCount = 1,
                        pathway="line_346",
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
                    pathway = "line_346",
                    -- offsets = {{-23, 5}}, 
                    speedScale = 1
                })
            end

            for i = 780, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 4,
                        fishTypeCount = 1,
                        pathway="line_347",
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
                    pathway = "line_347",
                    -- offsets = {{60, -10}}, 
                    speedScale = 1
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
                groupName = 12,  
                limit = 15,
                }, 
                {
                fish = 12,      
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
                groupName = 112,  
                limit = 1,
                }, 
                {
                fish = 112,      
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


    --场景2：-----------------鱼阵5-鲨鱼浪潮------------------
    do
     
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(1, "bg_01")
        -----------------鱼阵5-鲨鱼浪潮------------------
        
        for i = 0, 110, 9 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 12 ,                     -- 鱼或鱼组
                fishTypeCount = 2 ,             -- 数量
                offsets = {{0, 205}, {0, -205}},   --一线多鱼刷鱼的位置
                intervalTime = 0,               -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yz3",           -- 线或线组
            })
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.25,               -- 前进速度
                fish = 323 ,                     -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_yz3",           -- 线或线组
            })
         end
         for i = 1.5, 110, 9 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.25,                 -- 前进速度
                fish = 16 ,                     -- 鱼或鱼组
                fishTypeCount = 2 ,             -- 数量
                offsets = {{0, 115}, {0, -115}},   --一线多鱼刷鱼的位置
                intervalTime = 0,               -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yz3",           -- 线或线组
            })
         end
         for i = 3, 110, 9 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 12 ,                     -- 鱼或鱼组
                fishTypeCount = 2 ,             -- 数量
                offsets = {{0, 205}, {0, -205}},   --一线多鱼刷鱼的位置
                intervalTime = 0,               -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yz3",           -- 线或线组
            })
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,               -- 前进速度
                fish = 202 ,  
                action = "move1", 
                offsets = {{20, -20}},                  -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_yz3",           -- 线或线组
            })
         end
         for i = 4.5, 110, 9 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.25,                 -- 前进速度
                fish = 16 ,                     -- 鱼或鱼组
                fishTypeCount = 2 ,             -- 数量
                offsets = {{0, 115}, {0, -115}},   --一线多鱼刷鱼的位置
                intervalTime = 0,               -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yz3",           -- 线或线组
            })
         end
         for i = 6, 110, 9 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 12 ,                     -- 鱼或鱼组
                fishTypeCount = 2 ,             -- 数量
                offsets = {{0, 205}, {0, -205}},   --一线多鱼刷鱼的位置
                intervalTime = 0,               -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yz3",           -- 线或线组
            })
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.25,               -- 前进速度
                fish = 323 ,                     -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_yz3",           -- 线或线组
            })
         end
         for i = 7.5, 110, 9 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 112 ,                     -- 鱼或鱼组
                fishTypeCount = 2 ,             -- 数量
                offsets = {{0, 115}, {0, -115}},   --一线多鱼刷鱼的位置
                intervalTime = 0,               -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yz3",           -- 线或线组
            })
         end
        --  for i = 7.5, 90, 9 do
            
        --     scene.AddFishBornEvent(i, 
        --         {
        --             speedScale = 0.6,                   -- 前进速度
        --             fish = {202,203},                        -- 鱼或鱼组
        --             fishTypeCount = 1 ,                 -- 数量
        --             pathway = "line_125",               -- 线或线组
        --             offsetAngles = {math.pi / -2},
        --         })
        --  end
    end

    --场景3：随机boss，金色龙虾将军 314，背景16
    do
        
        local scene = scene3
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 18)   
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
            -- scene.AddHaiwanglaixiEvent(t +2, FF_G.Haiwanglaixi_FishType_NightBeast) -- boss 预警
            scene.AddBossWarningEvent(t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 333})
            
            scene.AddSwitchBgEvent(t1 +4, 7)  -- 切换场景
            
            for i = t1+2.8 , t1+t2 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t1+2.8+30 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t1+2.8+30+37 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
           
            scene.AddSwitchBgMusicEvent(t1+t2+5, "OneOutOfSix_BG")
            scene.AddSwitchBgEvent(t1+t2+5, 1)   -- 切换场景

        -- 第二段场景时间划分    
            -- scene.AddSetPlayRatioEvent(t1+t2+t3, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+t2+t3+2.5, 1) --还原速度
            scene.AddShakeEvent(t1+t2+t3, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1+t2+t3, "jingbao") --警报响
            scene.AddBossWarningEvent(t1+t2+t3, FF_G.BossWarning_Red) --预警泛紫
            scene.AddBossWarningEvent(t1+t2+t3 +2, FF_G.BossWarning_BossCome, {fishTypeId = 314}) -- boss 预警
            scene.AddSwitchBgEvent(t1+t2+t3 +4, 16) -- 切换场景
            scene.AddSetPlayBgAnimEvent(t1+t2+t3 +4.5, "scar", true)
            
            for i = t1+t2+t3+2.8+37 , t1+t2+t3+t4 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t1+t2+t3+2.8 ,t1+t2+t3+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t1+t2+t3+2.8+30+37 ,t1+t2+t3+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
            
            scene.AddSwitchBgEvent(t1+t2+t3+t4+15, 1)
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+15, "OneOutOfSix_BG")

    
        
            
        
        -- 出boss
            scene.AddRule(
                {
                startTime = t1 + 5,
                endTime = t1+t2-10,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 10,
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
                    startTime =  t1+t2+t3 + 5,
                    endTime = t1+t2+t3+t4-10,
                    -- cdTime = 1,
                    leaveCd = 0,
                    deathCd = 0,
                    groupName = 314, 
                    limit = 1,
                },
                {
                    fish = 314,      
                    fishTypeCount = 1,
                    pathwayGroup= "Group_boss",
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
                limit = 2,
                }, 
                {
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
            for i = t1+8, t1+t2+t3-2, 25 do
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
            for i = t1+t2+t3+5, t1+t2+t3+t3+t5, 27 do
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
            for i = 11, t1-2, 140 do
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
            for i = t1+13, t1+t2+t3-2, 145 do
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
            for i = t1+t2+t3+t4+10, t1+t2+t3+t4+t5, 145 do
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
        -- 出小鱼跟随： SetFishGroup("fish1", {0,1,2})
            for i = 7, t1-2, 20 do
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
        -- 出小鱼单条:SetFishGroup("fish1", {0,1,2})
            for i = 0, t1+t2+t3+t4+t5, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {3, 4},
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
                    startTime = 20,
                    endTime = t1+t2+t3+t4+t5-50,
                    cdTime = 1,
                    leaveCd = 3,
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
            for i = t1+38, t1+t2+t3-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+t2+t3+t4+38, t1+t2+t3+t4+t5, 190 do
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
            for i = t1+t2+t3+8+t4, t1+t2+t3+t4+t5, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            for i = t1+t2+t3+8, t1+t2+t3+t4, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["OtterFish"],
                    fishTypeCount = {1,2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_bimu",
                })
            end
            
        -- 炸弹，钻头蟹
            for i = 8, t1-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Carb",
                    offsetAngles = {math.pi / 2},
                })
            end
            for i = t1+8, t1+t2+t3-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Carb",
                    offsetAngles = {math.pi / 2},
                })
            end
            for i = t1+t2+t3+8, t1+t2+t3+t4+t5-40, 15 do
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
            
            for i = 40, t1-2, 90 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+40, t1+t2+t3-2, 90 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+t2+t3+40, t1+t2+t3+t4+t5, 90 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end

        -- 出辅助线-----

            for i = 30, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_350",
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
                        pathway="line_350",
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
                    pathway = "line_350",
                    -- offsets = {{-20, -55}}, 
                    speedScale = 1
                })
            end

            for i = 89, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_351",
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
                        pathway="line_351",
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
                    pathway = "line_351",
                    -- offsets = {{-10, 55}}, 
                    speedScale = 1
                })
            end

            for i = 150, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_346",
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
                    pathway = "line_346",
                    -- offsets = {{-60 , 10}}, 
                    speedScale = 1
                })
            end
            
            for i = 400, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_347",
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
                    pathway = "line_347",
                    -- offsets = {{20 , 0}}, 
                    speedScale = 1
                })
            end

            for i = 520, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 2,
                        fishTypeCount = 1,
                        pathway="line_346",
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
                    pathway = "line_346",
                    -- offsets = {{-23, 5}}, 
                    speedScale = 1
                })
            end

            for i = 780, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 4,
                        fishTypeCount = 1,
                        pathway="line_347",
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
                    pathway = "line_347",
                    -- offsets = {{60, -10}}, 
                    speedScale = 1
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
        -- 第一阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+5,
                endTime = t1+t2+t3,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = 12,  
                limit = 15,
                }, 
                {
                fish = 12,      
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
                groupName = 112,  
                limit = 1,
                }, 
                {
                fish = 112,      
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
    

    --场景4：-----------------鱼阵6-鱼王全聚-三顾茅庐-----------------
    do
     
        local scene = scene4
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(1, "bg_01")
        scene.AddRule(
                {
                startTime = 3,
                endTime = 70,
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

        for i = 0, 2, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 2.5, 2.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 100 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 3, 5, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end

        for i = 6, 8, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 8.5, 8.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 101 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 9, 11, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        
        for i = 12, 14, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 14.5, 14.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 102 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 15, 17, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end

        for i = 18, 20, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.3,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 20.5, 20.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.3,                 -- 前进速度
                fish = 103 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 21, 23, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.3,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end

        for i = 24, 26, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 26.5, 26.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 104 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 27, 29, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end

        for i = 30, 33, 0.75 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.13,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 33.75, 33.75, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.13,                 -- 前进速度
                fish = 106 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 34.5, 37.5, 0.75 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.13,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end

        for i = 39, 43, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 44, 44, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 107 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 45, 49, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end

        for i = 51, 55, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 56, 56, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 110 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 57, 61, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_116",           -- 线或线组
            })
        end
        for i = 0, 2, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 2.5, 2.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 100 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 3, 5, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end

        for i = 6, 8, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 8.5, 8.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 101 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 9, 11, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        
        for i = 12, 14, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 14.5, 14.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 102 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 15, 17, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end

        for i = 18, 20, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.3,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 20.5, 20.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.3,                 -- 前进速度
                fish = 103 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 21, 23, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.3,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end

        for i = 24, 26, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 26.5, 26.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 104 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 27, 29, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end

        for i = 30, 33, 0.75 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.13,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 33.75, 33.75, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.13,                 -- 前进速度
                fish = 106 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 34.5, 37.5, 0.75 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.13,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end

        for i = 39, 43, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 44, 44, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 107 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 45, 49, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end

        for i = 51, 55, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 56, 56, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 110 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 57, 61, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_117",           -- 线或线组
            })
        end
        for i = 59, 61, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 58.5, 58.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 100 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 56, 58, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end

        for i = 53, 55, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 52.5, 52.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 101 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 50, 52, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        
        for i = 47, 49, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 46.5, 46.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 102 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 44, 46, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end

        for i = 41, 43, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.3,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 40.5, 40.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.3,                 -- 前进速度
                fish = 103 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 38, 40, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.3,                 -- 前进速度
                fish = 3 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end

        for i = 35, 37, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 34.5, 34.5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 104 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 32, 34, 0.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end

        for i = 28, 31, 0.75 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.13,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 27.25, 27.25, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.13,                 -- 前进速度
                fish = 106 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 23.5, 26.5, 0.75 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 2.13,                 -- 前进速度
                fish = 6 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end

        for i = 18, 22, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 17, 17, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 107 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 12, 16, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 7 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end

        for i = 6, 10, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 5, 5, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 110 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 0, 4, 1 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 10 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_118",           -- 线或线组
            })
        end
        for i = 6, 59, 6 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.2,                 -- 前进速度
                fish = 200 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_360",           -- 线或线组
            })
        end
        for i = 3, 59, 6 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.2,                 -- 前进速度
                fish = {16,323} ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_360",           -- 线或线组
            })
        end
        for i = 70, 105, 3 do
            scene.AddFishBornEvent(i, {
                fish = {7,7,7,7,7},
                fishTypeCount = {5},
                pathwayGroup = "Group_yzxcyL",
            })
        end
        for i = 70, 105, 3 do
            scene.AddFishBornEvent(i, {
                fish = {9,9,9,9,9},
                fishTypeCount = {5},
                pathwayGroup = "Group_yzxcyR",
            })
        end
        for i = 75, 105, 10 do
            scene.AddFishBornEvent(i, {
                fish = 107,
                fishTypeCount = 1,
                pathwayGroup = "Group_yzhjxcyL",
            })
        end
        for i = 75, 105, 10 do
            scene.AddFishBornEvent(i, {
                fish = 109,
                fishTypeCount = 1,
                pathwayGroup = "Group_yzhjxcyR",
            })
        end
    
    end

    --场景5：随机boss，金色龙虾将军 314，背景19
    do
        
        local scene = scene5
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 19)   
        scene.AddSwitchBgMusicEvent(1, "bg_02")
        -- 持续时间段定义    
            local t1 = 60
            local t2 = 280
            local t3 = 120
            local t4 = 280
            local t5 = 120

        -- 第一场景时间划分
            
            
            -- scene.AddSetPlayRatioEvent(t1, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+2.5, 1) --还原速度
            scene.AddShakeEvent(t1, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1, "jingbao") --警报响
            scene.AddBossWarningEvent(t1, FF_G.BossWarning_Purple) --预警泛紫
            -- scene.AddHaiwanglaixiEvent(t +2, FF_G.Haiwanglaixi_FishType_NightBeast) -- boss 预警
            scene.AddBossWarningEvent(t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 333})
            
            scene.AddSwitchBgEvent(t1 +4, 9)  -- 切换场景
            
            for i = t1+2.8+34 , t1+t2 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t1+2.8+30+34 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t1+2.8 ,t1+t2, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
           
            scene.AddSwitchBgMusicEvent(t1+t2+5, "OneOutOfSix_BG")
            scene.AddSwitchBgEvent(t1+t2+5, 1)   -- 切换场景

        -- 第二场景时间划分   
            -- scene.AddSetPlayRatioEvent(t1+t2+t3, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+t2+t3+2.5, 1) --还原速度
            scene.AddShakeEvent(t1+t2+t3, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1+t2+t3, "jingbao") --警报响
            scene.AddBossWarningEvent(t1+t2+t3, FF_G.BossWarning_Red) --预警泛紫
            scene.AddBossWarningEvent(t1+t2+t3 +2, FF_G.BossWarning_BossCome, {fishTypeId = 314}) -- boss 预警
            scene.AddSwitchBgEvent(t1+t2+t3 +4, 19) -- 切换场景
            scene.AddSetPlayBgAnimEvent(t1+t2+t3 +4.5, "scar", true)
            
            for i = t1+t2+t3+2.8+30+37 , t1+t2+t3+t4 , 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bg_king") --30
            end
            for i = t1+t2+t3+2.8+37 ,t1+t2+t3+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "fk_bg_king_02") --37
            end
            for i = t1+t2+t3+2.8 ,t1+t2+t3+t4, 30+37+34 do
                scene.AddSwitchBgMusicEvent(i, "bossstage") --34
            end
            
            scene.AddSwitchBgEvent(t1+t2+t3+t4+15, 1)
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+15, "OneOutOfSix_BG")

        
        -- 出boss
            scene.AddRule(
                {
                startTime = t1 + 5,
                endTime = t1+t2-10,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 10,
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
                    startTime =  t1+t2+t3 + 5,
                    endTime = t1+t2+t3+t4-10,
                    -- cdTime = 1,
                    leaveCd = 0,
                    deathCd = 0,
                    groupName = 314, 
                    limit = 1,
                },
                {
                    fish = 314,      
                    fishTypeCount = 1,
                    pathwayGroup= "Group_boss",
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
                limit = 2,
                }, 
                {
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
        -- 出小鱼跟随： SetFishGroup("fish1", {0,1,2})
                for i = 7, t1-2, 20 do
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
            for i = t1+8, t1+t2+t3-2, 25 do
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
            for i = t1+t2+t3+5, t1+t2+t3+t3+t5, 27 do
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
            for i = 11, t1-2, 140 do
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
            for i = t1+13, t1+t2+t3-2, 145 do
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
            for i = t1+t2+t3+t4+10, t1+t2+t3+t4+t5, 145 do
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
                    fishTypeCount = {3, 4},
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
                    startTime = 20,
                    endTime = t1+t2+t3+t4+t5-50,
                    cdTime = 1,
                    leaveCd = 3,
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
            for i = t1+38, t1+t2+t3-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+t2+t3+t4+38, t1+t2+t3+t4+t5, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
        -- 出比目鱼：5
            for i = 2, t1+t2+t3+t4+t5, 20 do
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
                startTime = 25,
                endTime = t1+t2+t3+t4+t5,
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
            -- for i = 8, t1-2, 15 do
            --     scene.AddFishBornEvent(i, {
            --         fish = fishGroup["Carb"],
            --         fishTypeCount = {1},
            --         pathwayGroup = "Group_Carb",
            --         offsetAngles = {math.pi / 2},
            --     })
            -- end
            -- for i = t1+8, t1+t2+t3-2, 15 do
            --     scene.AddFishBornEvent(i, {
            --         fish = fishGroup["Carb"],
            --         fishTypeCount = {1},
            --         pathwayGroup = "Group_Carb",
            --         offsetAngles = {math.pi / 2},
            --     })
            -- end
            -- for i = t1+t2+t3+8, t1+t2+t3+t4+t5-40, 15 do
            --     scene.AddFishBornEvent(i, {
            --         fish = fishGroup["Carb"],
            --         fishTypeCount = {1},
            --         pathwayGroup = "Group_Carb",
            --         offsetAngles = {math.pi / 2},
            --     })
            -- end
            
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

        -- 出辅助线-----

            for i = 30, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_350",
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
                        pathway="line_350",
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
                    pathway = "line_350",
                    -- offsets = {{-20, -55}}, 
                    speedScale = 1
                })
            end

            for i = 89, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_351",
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
                        pathway="line_351",
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
                    pathway = "line_351",
                    -- offsets = {{-10, 55}}, 
                    speedScale = 1
                })
            end

            for i = 150, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 1,
                        fishTypeCount = 1,
                        pathway="line_346",
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
                    pathway = "line_346",
                    -- offsets = {{-60 , 10}}, 
                    speedScale = 1
                })
            end
            
            for i = 400, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 0,
                        fishTypeCount = 1,
                        pathway="line_347",
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
                    pathway = "line_347",
                    -- offsets = {{20 , 0}}, 
                    speedScale = 1
                })
            end

            for i = 520, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 2,
                        fishTypeCount = 1,
                        pathway="line_346",
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
                    pathway = "line_346",
                    -- offsets = {{-23, 5}}, 
                    speedScale = 1
                })
            end

            for i = 780, t1+t2+t3+t4+t5, t1+t2+t3+t4+t5 do
                for j = 1,8 do
                    scene.AddFishBornEvent(i, {
                        fish = 4,
                        fishTypeCount = 1,
                        pathway="line_347",
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
                    pathway = "line_347",
                    -- offsets = {{60, -10}}, 
                    speedScale = 1
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
                groupName = 12,  
                limit = 15,
                }, 
                {
                fish = 12,      
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
                groupName = 112,  
                limit = 1,
                }, 
                {
                fish = 112,      
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

    --场景6：鱼阵--------------鱼阵13-1圈接1圈-鱼王------------- 
    do
     
        local scene = scene6
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 4)
        scene.AddSwitchBgMusicEvent(1, "bg_01")
        scene.AddRule(
                {
                startTime = 3,
                endTime = 70,
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

         for i = 0, 105, 4.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                         -- 前进速度
                fish = {0,0,0,0,0,0,0,0,100} ,              -- 鱼或鱼组
                fishTypeCount = {9} ,                   -- 数量
                offsets = { {0,0},{60, 0}, {-60, 0}, {0, 60}, {0, -60}, {42, 42}, {-42, -42}, {42, -42}, {-42, 42}}, --多鱼的时候位置偏移
                intervalTime = 0,                       -- 两条鱼的间隔时间
                lineCount = 1,                          -- 固定选一条鱼线
                --fixedFishType = true,
                pathwayGroup = "Group_fish1",           -- 线或线组
            })
         end
         for i = 1.5, 105, 4.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                         -- 前进速度
                fish = {1,1,1,1,1,1,1,1,101} ,                     -- 鱼或鱼组
                fishTypeCount = {9} ,                   -- 数量
                offsets = { {0,0},{60, 0}, {-60, 0}, {0, 60}, {0, -60}, {42, 42}, {-42, -42}, {42, -42}, {-42, 42}}, --多鱼的时候位置偏移
                intervalTime = 0,                       -- 两条鱼的间隔时间
                lineCount = 1,                          -- 固定选一条鱼线
                -- fixedFishType = true,
                pathwayGroup = "Group_Cycle",           -- 线或线组
            })
         end
         for i = 3, 105, 4.5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                         -- 前进速度
                fish = {2,2,2,2,2,2,2,2,102} ,                     -- 鱼或鱼组
                fishTypeCount = {9} ,                   -- 数量
                offsets = { {0,0},{60, 0}, {-60, 0}, {0, 60}, {0, -60}, {42, 42}, {-42, -42}, {42, -42}, {-42, 42}}, --多鱼的时候位置偏移
                intervalTime = 0,                       -- 两条鱼的间隔时间
                lineCount = 1,                          -- 固定选一条鱼线
                -- fixedFishType = true,
                pathwayGroup = "Group_xiexian",         -- 线或线组
            })
         end
         for i = 3, 105, 5 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                         -- 前进速度
                fish = {324,323,322,321,200} ,                            -- 鱼或鱼组
                fishTypeCount = {1} ,                   -- 数量
                intervalTime = 0,                       -- 两条鱼的间隔时间
                lineCount = 1,                          -- 固定选一条鱼线
                --fixedFishType = true,
                pathwayGroup = "Group_follow",         -- 线或线组
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

