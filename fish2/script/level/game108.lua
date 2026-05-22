-- level/game108.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")

    

    local scene1 = FishEventHelper.CreateScene(870)
    local scene2 = FishEventHelper.CreateScene(115)
    local scene3 = FishEventHelper.CreateScene(870)
    local scene4 = FishEventHelper.CreateScene(115)
    local scene5 = FishEventHelper.CreateScene(870)
    local scene6 = FishEventHelper.CreateScene(115)

    --场景1：--雷霸龙215，场景5 ，海王荣耀310，场景6

    do
     
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 16)   -- 场景
        scene.AddSwitchBgMusicEvent(1, "bg_04")
        -- 持续时间段定义    
            local t1 = 60
            local t2 = 280
            local t3 = 120
            local t4 = 280
            local t5 = 120

        -- 第一阶段场景时间划分
            
            -- scene.AddSetPlayRatioEvent(t1, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+2.5, 1) --还原速度
            scene.AddShakeEvent(t1, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1, "jingbao") --警报响
            scene.AddBossWarningEvent(t1, FF_G.BossWarning_Purple) --预警泛紫
            -- scene.AddHaiwanglaixiEvent(t +2, FF_G.Haiwanglaixi_FishType_NightBeast)
            scene.AddBossWarningEvent(t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 215})
            scene.AddSwitchBgMusicEvent(t1+2.8, "fk_bg_king_02") --下个场景音效
            scene.AddSwitchBgEvent(t1 +4.5, 15)  -- 场景
            scene.AddSwitchBgEvent(t1+t2+10, 4)
            scene.AddSwitchBgMusicEvent(t1+t2+20, "bg_02")

        -- 第二阶段场景时间划分
            -- scene.AddSetPlayRatioEvent(t1+t2+t3, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+t2+t3+2.5, 1) --还原速度
            scene.AddShakeEvent(t1+t2+t3, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1+t2+t3, "jingbao") --警报响
            scene.AddBossWarningEvent(t1+t2+t3, FF_G.BossWarning_Purple) --预警泛紫
            -- scene.AddHaiwanglaixiEvent(t1 +2, FF_G.Haiwanglaixi_FishType_NightBeast)
            scene.AddBossWarningEvent(t1+t2+t3 +2, FF_G.BossWarning_BossCome, {fishTypeId = 310})
            scene.AddSwitchBgMusicEvent(t1+t2+t3+2.8, "bossstage") --下个场景音效
            scene.AddSwitchBgEvent(t1+t2+t3 +4.5, 6) -- 场景
            scene.AddSwitchBgEvent(t1+t2+t3+t4+10, 4)
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+10, "bg_02")
            
            
        -- 补boss
            
            scene.AddRule(
                {
                startTime = t1 + 5,
                endTime = t1+t2,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 50,
                groupName = 215,
                limit = 1,
                }, 
                {
                fish = 215,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_dragon",
                }
            )
            scene.AddRule(
                {
                startTime = t1+t2+t3 + 5,
                endTime = t1+t2+t3+t4,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 310,  
                limit = 1,
                }, 
                {
                fish = 310,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_dragon",
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
                limit = 1,
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
            for i = t1+t2+t3+t4+10, t1+t2+t3+t4+t5, 140 do
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
                    fishTypeCount = {4, 5},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            

        -- 出普通中型鱼：SetFishGroup("fish2", {3,4,6,7,8,9,10,11,12})
            for i = 0, t1+t2+t3+t4+t5, 8 do
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
        
            for i = 3, t1+t2+t3+t4+t5, 12 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3L",
                })
            end
            for i = 13, t1+t2+t3+t4+t5, 12 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3R",
                })
            end
            
        -- 出彩金鱼：SetFishGroup("goldedfish", {320,321,322,323,324})
            for i = 18, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishL",
                })
            end
            for i = 8, t1+t2+t3+t4+t5, 15 do
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
            
            for i = 40, t1-2, 113 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+40, t1+t2+t3-2, 115 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+t2+t3+40, t1+t2+t3+t4+t5, 113 do
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

        -- 出辅助线-----

            for i = 89, t1+t2+t3+t4+t5, 860 do
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

            for i = 30, t1+t2+t3+t4+t5, 860 do
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

            for i = 420, t1+t2+t3+t4+t5, 860 do
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
            
            for i = 155, t1+t2+t3+t4+t5, 860 do
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

            for i = 788, t1+t2+t3+t4+t5, 860 do
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

            for i = 525, t1+t2+t3+t4+t5, 860 do
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
        --第一阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+5,
                endTime = t1+t2+t3,
                cdTime = 3,
                leaveCd = 0,
                deathCd = 0,
                groupName = 6,  
                limit = 10,
                }, 
                {
                fish = 6,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            
            scene.AddRule(
                {
                startTime = t1+t2+10,
                endTime = t1+t2+t3,
                cdTime = 3,
                leaveCd = 1,
                deathCd = 1,
                groupName = 106,  
                limit = 1,
                }, 
                {
                fish = 106,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
        --第二阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+t3+t4+5,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = 7,  
                limit = 10,
                }, 
                {
                fish = 7,      
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
                groupName = 107,  
                limit = 1,
                }, 
                {
                fish = 107,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
              

        

                                   
    end
    
    --场景2：------鱼阵：黄金鲨鱼和狮子鱼乱入-------------------
    do
     
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        
        scene.AddRule(
                {
                startTime = 15,
                endTime = 80,
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
        -- scene.AddRule(
        --     {
        --     startTime = 10.5,
        --     endTime = 105,
        --     cdTime = 4,
        --     leaveCd = 0,
        --     deathCd = 0,
        --     groupName = 104,
        --     limit = 2,
        --     }, 
        --     {
        --     fish = 104,      -- 指定鱼组或者鱼id
        --     fishTypeCount = 1, 
        --     pathwayGroup= "Group_shadiansha",
        --     }
        -- )
        for i = 5, 70, 15 do
            scene.AddFishBornEvent(i, {
                fish = 201,
                fishTypeCount = 1,
                pathwayGroup = "Group_Storm",
            })
        end
        for i = 6, 105, 15 do
            scene.AddFishBornEvent(i, {
                fish = 104,
                fishTypeCount = 1,
                pathwayGroup = "Group_yzxcyL",
            })
        end
        for i = 8, 105, 15 do
            scene.AddFishBornEvent(i, {
                fish = 104,
                fishTypeCount = 1,
                pathwayGroup = "Group_yzxcyR",
            })
        end
        

        for i = 0, 105, 7 do
            scene.AddFishBornEvent(i, {
                fish = {4,4,4,4,4},
                fishTypeCount = {5},
                pathwayGroup = "Group_yzxcyL",
            })
        end
        for i = 3, 105, 7 do
            scene.AddFishBornEvent(i, {
                fish = {4,4,4,4,4},
                fishTypeCount = {5},
                pathwayGroup = "Group_yzxcyR",
            })
        end
        for i = 3, 105, 7 do
            scene.AddFishBornEvent(i, {
                fish = {323,323,323},
                fishTypeCount = {2},
                pathwayGroup = "Group_yzhjxcyL",
            })
        end
        for i = 1, 105, 7 do
            scene.AddFishBornEvent(i, {
                fish = {323,323,323},
                fishTypeCount = {2},
                pathwayGroup = "Group_yzhjxcyR",
            })
        end
        for i = 5, 105, 16 do
            scene.AddFishBornEvent(i, {
                fish = {200},
                fishTypeCount = {1},
                pathway = "line_2",
            })
        end
    end

    --场景3：虎头鲨301，场景9 ，海王荣耀310，场景6

    do
     
        local scene = scene3
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 8)   -- 场景
        scene.AddSwitchBgMusicEvent(1, "bg_04")
        -- 持续时间段定义    
            local t1 = 60
            local t2 = 280
            local t3 = 120
            local t4 = 280
            local t5 = 120

        -- 第一阶段场景时间划分
            
            -- scene.AddSetPlayRatioEvent(t1, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+2.5, 1) --还原速度
            scene.AddShakeEvent(t1, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1, "jingbao") --警报响
            scene.AddBossWarningEvent(t1, FF_G.BossWarning_Purple) --预警泛紫
            -- scene.AddHaiwanglaixiEvent(t +2, FF_G.Haiwanglaixi_FishType_NightBeast)
            scene.AddBossWarningEvent(t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 301})
            scene.AddSwitchBgMusicEvent(t1+2.8, "bg_lobby") --下个场景音效
            scene.AddSwitchBgEvent(t1 +4.5, 9)  -- 场景
            scene.AddSwitchBgEvent(t1+t2+30, 4)
            scene.AddSwitchBgMusicEvent(t1+t2+30, "09_bg1")

        -- 第二阶段场景时间划分
            
            -- scene.AddSetPlayRatioEvent(t1+t2+t3, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+t2+t3+2.5, 1) --还原速度
            scene.AddShakeEvent(t1+t2+t3, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1+t2+t3, "jingbao") --警报响
            scene.AddBossWarningEvent(t1+t2+t3, FF_G.BossWarning_Purple) --预警泛紫
            -- scene.AddHaiwanglaixiEvent(t1 +2, FF_G.Haiwanglaixi_FishType_NightBeast)
            scene.AddBossWarningEvent(t1+t2+t3 +2, FF_G.BossWarning_BossCome, {fishTypeId = 310})
            scene.AddSwitchBgMusicEvent(t1+t2+t3+2.8, "bg_king") --下个场景音效
            scene.AddSwitchBgEvent(t1+t2+t3 +4.5, 6) -- 场景

            scene.AddSwitchBgEvent(t1+t2+t3+t4+10, 4)
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+10, "bg_02")
            
            
        -- 补boss
            
            scene.AddRule(
                {
                startTime = t1 + 5,
                endTime = t1+280,
                -- cdTime = 0,
                leaveCd = 3,
                deathCd = 3,
                groupName = 301,  
                limit = 1,
                }, 
                {
                fish = 301,      
                fishTypeCount = {1},
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
                startTime = t1+t2+t3 + 5,
                endTime = t1+t2+t3+t4,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 310,  
                limit = 1,
                }, 
                {
                fish = 310,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_dragon",
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
                limit = 1,
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
            for i = t1+t2+t3+t4+10, t1+t2+t3+t4+t5, 140 do
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
                    fishTypeCount = {4, 5},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            

        -- 出普通中型鱼：SetFishGroup("fish2", {3,4,6,7,8,9,10,11,12})
            for i = 0, t1+t2+t3+t4+t5, 8 do
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
        
            for i = 3, t1+t2+t3+t4+t5, 12 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3L",
                })
            end
            for i = 13, t1+t2+t3+t4+t5, 12 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3R",
                })
            end
            
        -- 出彩金鱼：SetFishGroup("goldedfish", {320,321,322,323,324})
            for i = 18, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishL",
                })
            end
            for i = 8, t1+t2+t3+t4+t5, 15 do
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
            
            for i = 40, t1-2, 120 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+40, t1+t2+t3-2, 120 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+t2+t3+40, t1+t2+t3+t4+t5, 120 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end

        -- 出辅助线-----

            for i = 89, t1+t2+t3+t4+t5, 860 do
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

            for i = 30, t1+t2+t3+t4+t5, 860 do
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

            for i = 420, t1+t2+t3+t4+t5, 860 do
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
            
            for i = 155, t1+t2+t3+t4+t5, 860 do
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

            for i = 788, t1+t2+t3+t4+t5, 860 do
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

            for i = 525, t1+t2+t3+t4+t5, 860 do
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
        --第一阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+5,
                endTime = t1+t2+t3,
                cdTime = 3,
                leaveCd = 0,
                deathCd = 0,
                groupName = 6,  
                limit = 10,
                }, 
                {
                fish = 6,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            
            scene.AddRule(
                {
                startTime = t1+t2+10,
                endTime = t1+t2+t3,
                cdTime = 3,
                leaveCd = 1,
                deathCd = 1,
                groupName = 106,  
                limit = 1,
                }, 
                {
                fish = 106,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
        --第二阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+t3+t4+5,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = 7,  
                limit = 10,
                }, 
                {
                fish = 7,      
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
                groupName = 107,  
                limit = 1,
                }, 
                {
                fish = 107,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )                  
    end

    --场景4：---------鱼阵:小丑鱼、加纳鱼、鲨鱼，黄金鲨，闪电鲨，上下直线---------
    
    do
     
        local scene = scene4
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        
        scene.AddRule(
            {
            startTime = 3,
            endTime = 80,
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

        for i = 0, 105, 0.5 do
            scene.AddFishBornEvent(i, {
                fish = {1,1},
                fishTypeCount = {2},
                pathwayGroup = "Group_yzxcy",
            })
        end
        for i = 0, 105, 0.5 do
            scene.AddFishBornEvent(i, {
                fish = {0,0},
                fishTypeCount = {2},
                pathwayGroup = "Group_yzjny",
            })
        end
        for i = 0, 105, 8 do
            scene.AddFishBornEvent(i, {
                fish = {16,16},
                fishTypeCount = {2},
                pathwayGroup = "Group_yzhjs",
            })
        end
        for i = 4, 105, 8 do
            scene.AddFishBornEvent(i, {
                fish = {323,323},
                fishTypeCount = {2},
                pathwayGroup = "Group_yzhjs",
            })
        end
        for i = 0, 105, 21 do
            scene.AddFishBornEvent(i, {
                fish = 200,
                fishTypeCount = {1},
                pathway = "line_yzsd1",
            })
        end
        for i = 10, 105, 21 do
            scene.AddFishBornEvent(i, {
                fish = 200,
                fishTypeCount = {1},
                pathway = "line_yzsd2",
            })
        end
        for i = 2, 105, 6 do
            scene.AddFishBornEvent(i, {
                fish = 101,
                fishTypeCount = 1,
                pathway = "line_2",
                speedScale = 0.8,
            })
        end
        for i = 5, 105, 6 do
            scene.AddFishBornEvent(i, {
                fish = 100,
                fishTypeCount = 1,
                pathway = "line_2",
                speedScale = 0.8,
            })
        end
    end

    --场景5：赤焰龙龟304，场景4 ，海王荣耀310，场景6
    do
     
        local scene = scene5
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 3)   -- 场景
        scene.AddSwitchBgMusicEvent(1, "09_bg1")
        -- 持续时间段定义    
            local t1 = 60
            local t2 = 280
            local t3 = 120
            local t4 = 280
            local t5 = 120

        -- 第一阶段场景时间划分
            
            -- scene.AddSetPlayRatioEvent(t1, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+2.5, 1) --还原速度
            scene.AddShakeEvent(t1, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1, "jingbao") --警报响
            scene.AddBossWarningEvent(t1, FF_G.BossWarning_Purple) --预警泛紫
            
            scene.AddBossWarningEvent(t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 304})
            scene.AddSwitchBgMusicEvent(t1+2.8, "fk_bg_king_02") --下个场景音效
            scene.AddSwitchBgEvent(t1 +2.5, 5)  -- 场景
            scene.AddSwitchBgEvent(t1+t2+30, 1)
            scene.AddSwitchBgMusicEvent(t1+t2+30, "OneOutOfSix_BG")

        -- 第二阶段场景时间划分
            
            -- scene.AddSetPlayRatioEvent(t1+t2+t3, 16) --加速离场
            -- scene.AddSetPlayRatioEvent(t1+t2+t3+2.5, 1) --还原速度
            scene.AddShakeEvent(t1+t2+t3, 2.5, 8) --震动
            -- scene.AddSwitchBgMusicEvent(t1+t2+t3, "jingbao") --警报响
            scene.AddBossWarningEvent(t1+t2+t3, FF_G.BossWarning_Purple) --预警泛紫
            -- scene.AddHaiwanglaixiEvent(t1 +2, FF_G.Haiwanglaixi_FishType_NightBeast)
            scene.AddBossWarningEvent(t1+t2+t3 +2, FF_G.BossWarning_BossCome, {fishTypeId = 310})
            scene.AddSwitchBgMusicEvent(t1+t2+t3+2.8, "bg_lobby") --下个场景音效
            scene.AddSwitchBgEvent(t1+t2+t3 +4.5, 6) -- 场景


            scene.AddSwitchBgEvent(t1+t2+t3+t4+10, 1)
            scene.AddSwitchBgMusicEvent(t1+t2+t3+t4+10, "bg_04")
            
            
        -- 出boss
            scene.AddRule(
                {
                startTime = t1+5,
                endTime = t1+t2-15,
                -- cdTime = 0,
                leaveCd = 2,
                deathCd = 2,
                groupName = 304,  
                limit = 1,
                }, 
                {
                fish = 304,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_longgui",
                }
            )
            scene.AddRule(
                {
                startTime = t1+t2+t3 + 5,
                endTime = t1+t2+t3+t4,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 310,  
                limit = 1,
                }, 
                {
                fish = 310,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_dragon",
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
            for i = t1+t2+t3+t4+10, t1+t2+t3+t4+t5, 140 do
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
                    fishTypeCount = {4, 5},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            

        -- 出普通中型鱼：SetFishGroup("fish2", {3,4,6,7,8,9,10,11,12})
            for i = 0, t1+t2+t3+t4+t5, 8 do
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
        
            for i = 3, t1+t2+t3+t4+t5, 12 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3L",
                })
            end
            for i = 13, t1+t2+t3+t4+t5, 12 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3R",
                })
            end
            
        -- 出彩金鱼：SetFishGroup("goldedfish", {320,321,322,323,324})
            for i = 18, t1+t2+t3+t4+t5, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishL",
                })
            end
            for i = 8, t1+t2+t3+t4+t5, 15 do
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
        
            for i = 38, t1-2, 180 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+38, t1+t2+t3-2, 180 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            for i = t1+t2+t3+38, t1+t2+t3+t4+t5, 180 do
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
            
            for i = 40, t1-2, 120 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+40, t1+t2+t3-2, 120 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
            for i = t1+t2+t3+40, t1+t2+t3+t4+t5, 120 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end

        -- 出辅助线-----

            for i = 89, t1+t2+t3+t4+t5, 860 do
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

            for i = 30, t1+t2+t3+t4+t5, 860 do
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

            for i = 420, t1+t2+t3+t4+t5, 860 do
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
            
            for i = 155, t1+t2+t3+t4+t5, 860 do
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

            for i = 788, t1+t2+t3+t4+t5, 860 do
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

            for i = 525, t1+t2+t3+t4+t5, 860 do
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
        --第一阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+5,
                endTime = t1+t2+t3,
                cdTime = 3,
                leaveCd = 0,
                deathCd = 0,
                groupName = 6,  
                limit = 10,
                }, 
                {
                fish = 6,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
            
            scene.AddRule(
                {
                startTime = t1+t2+10,
                endTime = t1+t2+t3,
                cdTime = 3,
                leaveCd = 1,
                deathCd = 1,
                groupName = 106,  
                limit = 1,
                }, 
                {
                fish = 106,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
        --第二阶段出旋风
            scene.AddRule(
                {
                startTime = t1+t2+t3+t4+5,
                endTime = t1+t2+t3+t4+t5,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = 7,  
                limit = 10,
                }, 
                {
                fish = 7,      
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
                groupName = 107,  
                limit = 1,
                }, 
                {
                fish = 107,      
                fishTypeCount = 1, 
                pathwayGroup= "Group_fish2",
                }
            )
                              
    end


    --场景6： -----------------鱼阵:上下双螺旋线，中间出彩金鱼--------------
    do
     
        local scene = scene6
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")

        for i = 0, 105, 2.5 do
            if i % 5 == 0 then
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],                      -- 鱼或鱼组
                    fishTypeCount = 1 ,             -- 数量
                    pathway = "line_2",         -- 线或线组
                    speedScale = 1,
                    --offsetAngles = {math.pi / -2},
                })
                scene.AddFishBornEvent(i, {
                    fish = 101 ,                      -- 鱼或鱼组
                    fishTypeCount = 1 ,             -- 数量
                    pathway = "line_yzqxL3",         -- 线或线组
                    speedScale = 1.1
                })
                scene.AddFishBornEvent(i, {
                    fish = 101 ,                      -- 鱼或鱼组
                    fishTypeCount = 1 ,             -- 数量
                    pathway = "line_yzqxR3",         -- 线或线组
                    speedScale = 1.1
                })
                scene.AddFishBornEvent(i, {
                    fish = 1,      -- 指定鱼组
                    fishCount = {5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.3,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_yzqxL1",
                    speedScale = 1.5
                })
                scene.AddFishBornEvent(i, {
                    fish = 1,      -- 指定鱼组
                    fishCount = {5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.3,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_yzqxL2",
                    speedScale = 1.5
                })
                scene.AddFishBornEvent(i, {
                    fish = 1,      -- 指定鱼组
                    fishCount = {5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.3,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_yzqxR1",
                    speedScale = 1.5
                })
                scene.AddFishBornEvent(i, {
                    fish = 1,      -- 指定鱼组
                    fishCount = {5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.3,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_yzqxR2",
                    speedScale = 1.5
                })
            else
                scene.AddFishBornEvent(i, {
                    fish = 102 ,                      -- 鱼或鱼组
                    fishTypeCount = 1 ,             -- 数量
                    pathway = "line_yzqxL3",         -- 线或线组
                    speedScale = 1.1
                })
                scene.AddFishBornEvent(i, {
                    fish = 102 ,                      -- 鱼或鱼组
                    fishTypeCount = 1 ,             -- 数量
                    pathway = "line_yzqxR3",         -- 线或线组
                    speedScale = 1.1
                })
                scene.AddFishBornEvent(i, {
                    fish = 2,      -- 指定鱼组
                    fishCount = {5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.3,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_yzqxL1",
                    speedScale = 1.5
                })
                scene.AddFishBornEvent(i, {
                    fish = 2,      -- 指定鱼组
                    fishCount = {5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.3,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_yzqxL2",
                    speedScale = 1.5
                })
                scene.AddFishBornEvent(i, {
                    fish = 2,      -- 指定鱼组
                    fishCount = {5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.3,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_yzqxR1",
                    speedScale = 1.5
                })
                scene.AddFishBornEvent(i, {
                    fish = 2,      -- 指定鱼组
                    fishCount = {5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.3,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_yzqxR2",
                    speedScale = 1.5
                })
            end
            if i % 15 == 5 and i<80 then
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["Carb"],                      -- 鱼或鱼组
                    fishTypeCount = 1 ,             -- 数量
                    pathwayGroup = "Group_Carb",         -- 线或线组
                    speedScale = 1,
                    offsetAngles = {math.pi / -2},
                }) 
            end
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

