-- level/game140.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")

    

    local scene1 = FishEventHelper.CreateScene(2110)
    local scene2 = FishEventHelper.CreateScene(110)
    -- local scene3 = FishEventHelper.CreateScene(870)
    local scene4 = FishEventHelper.CreateScene(110)
    -- local scene5 = FishEventHelper.CreateScene(870)
    local scene6 = FishEventHelper.CreateScene(110)

    --场景1：特殊觉醒boss
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 19)   
        scene.AddSwitchBgMusicEvent(1, "CollectElements_BGM")
        
        -- 持续时间段定义    
            local t1 = 60

        -- 1紫晶人鱼 209 1~5 60~300
            
            scene.AddShakeEvent(t1, 2.5, 8) --震动
            scene.AddBossWarningEvent(t1, FF_G.BossWarning_Purple) --预警泛紫
            scene.AddBossWarningEvent(t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 209})
            scene.AddSwitchBgMusicEvent(t1 +2, "tournament_waiting")
            scene.AddSwitchBgEvent(t1, 17)  -- 切换场景
            scene.AddRule(
                {
                    startTime =  t1 + 4,
                    endTime = 5*t1,
                    -- cdTime = 3.5,
                    leaveCd = 0,
                    deathCd = 45,
                    groupName = 209, 
                    limit = 1,
                },
                {
                    fish = 209,      
                    fishTypeCount = 1,
                    pathwayGroup= "Group_Mermaid",
                }
            )

        -- 2绿人鱼 208 6~10 360~600
            scene.AddShakeEvent(6*t1, 2.5, 8) --震动
            scene.AddBossWarningEvent(6*t1, FF_G.BossWarning_Purple) --预警泛紫
            scene.AddBossWarningEvent(6*t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 208})
            scene.AddSwitchBgMusicEvent(6*t1 +2, "CollectElements_BGM")
            scene.AddRule(
                {
                    startTime =  6*t1 + 4,
                    endTime = 10*t1,
                    -- cdTime = 3.5,
                    leaveCd = 0,
                    deathCd = 45,
                    groupName = 208, 
                    limit = 1,
                },
                {
                    fish = 208,      
                    fishTypeCount = 1,
                    pathwayGroup= "Group_Mermaid",
                }
            )    
            
        -- 3觉醒霸王蟹 211 11~15 660~900
            scene.AddHaiwanglaixiEvent(11*t1, FF_G.Haiwanglaixi_FishType_Wakeup)
            scene.AddHaiwanglaixiEvent(11*t1 + 2, FF_G.Haiwanglaixi_FishType_WakeupKingCrab) 
            scene.AddSwitchBgMusicEvent(11*t1 + 1, "fk_bg_king_02")
            scene.AddSwitchBgMusicEvent(15*t1-5, "bg_06")
            scene.AddSwitchBgEvent(11*t1 + 3, 10)
            scene.AddSetPlayBgAnimEvent(11*t1 + 4, "scar", true)
            scene.AddBossWarningEvent(11*t1-2, FF_G.BossWarning_Red)
            scene.AddRule(
                    {
                        startTime =  11*t1 + 5,
                        endTime = 15*t1-30,
                        cdTime = 3.5,
                        leaveCd = 0,
                        deathCd = 50,
                        groupName = 211, 
                        limit = 2,
                    },
                    {
                        fish = 211,      
                        fishTypeCount = 1,
                        pathway= "line_pang1",
                    }
            )
        
        -- 4觉醒的暗夜巨兽 212 16~20 960~1200
            scene.AddHaiwanglaixiEvent(16*t1, FF_G.Haiwanglaixi_FishType_Wakeup)
            scene.AddHaiwanglaixiEvent(16*t1 + 2, FF_G.Haiwanglaixi_FishType_WakeupNightBeast)
            scene.AddSwitchBgEvent(16*t1 + 5-2, 3)
            -- scene.AddSwitchBgMusicEvent(5*t1 + 5-2, "bg_02")
            scene.AddRule(
                {
                startTime = 16*t1 + 5,
                endTime = 20*t1-10,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 50,
                groupName = 212,  
                limit = 1,
                }, 
                {
                fish = 212,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_boss",
                }
            )

        -- 5觉醒史前巨鳄 213 21~25 1260~1500
            scene.AddHaiwanglaixiEvent(21*t1, FF_G.Haiwanglaixi_FishType_Wakeup)
            scene.AddHaiwanglaixiEvent(21*t1 + 2, FF_G.Haiwanglaixi_FishType_WakeupCrocodile)
            scene.AddSwitchBgEvent(21*t1 + 5-2, 4)
            scene.AddRule(
                {
                startTime = 21*t1 + 5,
                endTime = 25*t1-10,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 50,
                groupName = 213,  
                limit = 1,
                }, 
                {
                fish = 213,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_boss",
                }
            )
                         
        
        -- 6觉醒八爪章鱼 214 26~30 1560~1800
            scene.AddHaiwanglaixiEvent(26*t1-1, FF_G.Haiwanglaixi_FishType_Wakeup)
            scene.AddHaiwanglaixiEvent(26*t1+1, FF_G.Haiwanglaixi_FishType_WakeupKingOctopus)
            scene.AddSwitchBgMusicEvent(26*t1+1, "bg_02")
            scene.AddSwitchBgEvent(26*t1+5-3, 11)
            scene.AddBossWarningEvent(26*t1-2, FF_G.BossWarning_Red)
            scene.AddRule(
                {
                    startTime =  26*t1+5,
                    endTime = 30*t1,
                    cdTime = 3.5,
                    leaveCd = 0,
                    deathCd = 50,
                    groupName = 214, 
                    limit = 3,
                },
                {
                    fish = 214,      
                    fishTypeCount = 1,
                    pathway= "line_1",
                }
            )
            -- 旋转场景 八爪章鱼场景

            for i = 26*t1+5+3, 30*t1, 60 do
                scene.AddSetPlayBgAnimEvent(i, "turn1")
                scene.AddSetPlayBgAnimEvent(i + 15, "turn2")
                scene.AddSetPlayBgAnimEvent(i + 30, "turn3")
                scene.AddSetPlayBgAnimEvent(i + 45, "turn4")
            end

                
        -- 7雷霸龙 215 31~35 1860~2100
            scene.AddSwitchBgEvent(31*t1, 15)   -- 场景
            scene.AddShakeEvent(31*t1, 2.5, 8) --震动
            scene.AddSwitchBgMusicEvent(31*t1+2.8, "fk_bg_king_02") --场景音效
            scene.AddBossWarningEvent(31*t1, FF_G.BossWarning_Purple) --预警泛紫          
            scene.AddBossWarningEvent(31*t1 +2, FF_G.BossWarning_BossCome, {fishTypeId = 215})
            
            

            scene.AddRule(
                {
                startTime = 31*t1 + 5,
                endTime = 35*t1,
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

        
        -- 出special
            scene.AddRule(
                {
                startTime = 10,
                endTime = 35*t1-3,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = "special",  
                limit = 1,
                }, 
                {
                -- fish = 205, 
                fish = fishGroup["special"],     
                fishTypeCount = {1}, 
                pathwayGroup= "Group_special",
                }
            )
        -- 猫大爷
            
            for i = 110, 35*t1-2, 133 do
                scene.AddFishBornEvent(i, {
                    fish = 206,
                    fishTypeCount = {1},
                    pathwayGroup = "Group_mdy",
                    createPrams = 
                    {
                        fadeInSecs = 5,             -- 淡入持续时间
                        fadeOutStartTime = 40,      -- 淡出开始时间
                        fadeOutSecs = 3,            -- 淡出持续时间
                        -- scaleInSec = 0.5,             -- 从小变大入场
                    },
                })
            end
         
        -- 聚餐元宵
            
            for i = 55, 35*t1-2, 133 do
                scene.AddFishBornEvent(i, {
                    fish = 325,
                    fishTypeCount = {1},
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
             

        -- 出小鱼跟随： SetFishGroup("fish1", {0,1,2})
            for i = 7, 35*t1-2, 20 do
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
            for i = 5, 35*t1-2, 30 do
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
            for i = 35, 35*t1-2, 140 do
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
            for i = 0, 35*t1-2, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {5, 4},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            

        -- 出普通中型鱼：SetFishGroup("fish2", {3,4,6,7,8,9,10,11,12})
            for i = 0, 35*t1-2, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2L",
                })
            end
            for i = 4, 35*t1-2, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2R",
                })
            end
            
        -- 出普通大鱼：SetFishGroup("fish3", {13,14,15,16,17})
            for i = 0, 35*t1-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3L",
                })
            end
            for i = 8, 35*t1-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish3R",
                })
            end

        -- 出彩金鱼：SetFishGroup("goldedfish", {320,321,322,323,324})
            for i = 4, 35*t1-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishL",
                })
            end
            for i = 12, 35*t1-2, 15 do
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
                    endTime = 35*t1-50,
                    cdTime = 1,
                    leaveCd = 0,
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
        
            for i = 38, 35*t1-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            
        -- 出比目鱼：5
            for i = 2, 35*t1-2, 20 do
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
                endTime = 35*t1-40,
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
                    endTime = 35*t1-2,
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
            
            for i = 90, 35*t1-2, 120 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
           

        -- 出辅助线-----

            for i = 89, 35*t1, 180 do
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

            for i = 30, 35*t1, 185 do
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

            for i = 420,35*t1, 180 do
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
            
            for i = 155, 35*t1, 180 do
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

            for i = 788, 35*t1, 180 do
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

            for i = 525, 35*t1, 180 do
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
        
        

        
               


    end

    -- 场景2：鱼阵1
    
    do
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0.0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        
        scene.AddRule(
                {
                startTime = 10,
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
        --    --出鱼阵1

        for i = 1, 105, 8 do
            scene.AddFishBornEvent(i, {
                fish = {323, 323},      
                fishTypeCount = {2},
                pathwayGroup = "Group_yz",
            })
        end

        for i = 5, 105, 8 do
            scene.AddFishBornEvent(i, {
                fish = {200},      
                fishTypeCount = {1},
                pathway = "line_yz3",
            })
        end

        for i = 1, 105, 1 do
            scene.AddFishBornEvent(i, {
                fish = {0},      -- 指定鱼组
                fishCount = {2},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0.2,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yz4",
            })
        end
        for i = 1, 105, 1 do
            scene.AddFishBornEvent(i, {
                fish = {0},      -- 指定鱼组
                fishCount = {2},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0.2,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yz5",
            })
        end
        for i = 1, 105, 1 do
            scene.AddFishBornEvent(i, {
                fish = {0},      -- 指定鱼组
                fishCount = {2},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0.2,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yz6",
            })
        end
        for i = 1, 105, 1 do
            scene.AddFishBornEvent(i, {
                fish = {0},      -- 指定鱼组
                fishCount = {2},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0.2,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yz7",
            })
        end
    end

    

    -- 场景4：鱼阵2
    do
        local scene = scene4
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0.0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        scene.AddRule(
                {
                startTime = 3,
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
    
        for i = 0, 105, 0.7 do
            scene.AddFishBornEvent(i, {
                fish = {2,2,2,2},      
                fishTypeCount = {4},
                pathwayGroup = "Group_yza",
            })
        end

        for i = 0, 105, 8 do
            scene.AddFishBornEvent(i, {
                fish = {14,14},      
                fishTypeCount = {2},
                pathwayGroup = "Group_yzb",
            })
        end

        for i = 4, 105, 8 do
            scene.AddFishBornEvent(i, {
                fish = {323,323},      
                fishTypeCount = {2},
                pathwayGroup = "Group_yzb",
            })
        end

        for i = 2, 105, 6 do
            scene.AddFishBornEvent(i, {
                fish = {200},      
                fishTypeCount = {1},
                pathway = "line_yzd1",
                speedScale = 1.3
            })
        end

        for i = 1, 105, 6 do
            scene.AddFishBornEvent(i, {
                fish = {10},      -- 指定鱼组
                fishCount = {2},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 1.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yzc1",
            })
        end
        for i = 1, 105, 6 do
            scene.AddFishBornEvent(i, {
                fish = {10},      -- 指定鱼组
                fishCount = {2},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 1.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_yzc2",
            })
        end
        
    end

    

    -- 场景6：鱼阵3 ----鱼阵--------大滚轮-大群小鱼-鱼王--连环炸弹--黄金鲨鱼------
    do
        local scene = scene6
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0.0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
    
            for j = 0, 105, 7 do
                scene.AddFishBornEvent(j, {
                    fish = 323,
                    fishTypeCount = 1,
                    speedScale = 1.88 ,
                    pathway = "line_322",
                    offsets = {{0, 0}},
                })
                
                for i = 1, 51 do
                    scene.AddFishBornEvent(j, {
                        fish = 2,      -- 指定鱼组
                        fishTypeCount = 1,              -- 鱼类型数量
                        pathway = "line_322",
                        offsets = {{0, 0}},
                        subPathway = {
                            {
                                pathway = "line_338",
                                startTime = 0,
                                endTime = 20,
                                offsetTime = 0.4 * i,
                                useAngle = true,
                                speed = 146 ,
                            },
                        },
                    })
                end
                for i = 1, 26 do
                    scene.AddFishBornEvent(j, {
                        fish = 1,      -- 指定鱼组
                        fishTypeCount = 1,              -- 鱼类型数量
                        pathway = "line_322",
                        subPathway = {
                            {
                                pathway = "line_334",
                                startTime = 0,
                                endTime = 20,
                                offsetTime = 0.4 * i,
                                useAngle = true,
                                speed = 160,
                            },
                        },
                    })
                end
            end
            for j = 3.5, 105, 7 do
                scene.AddFishBornEvent(j, {
                    fish = 324 ,
                    fishTypeCount = 1,
                    speedScale = 1.88 ,
                    pathway = "line_322",
                    offsets = {{0, 0}},
                })
                for i = 1, 26 do
                    scene.AddFishBornEvent(j, {
                        fish = 2,      -- 指定鱼组
                        fishTypeCount = 1,              -- 鱼类型数量
                        pathway = "line_322",
                        offsets = {{10, 0}},
                        script = "rotate_sub_pathway.lua",  --旋转这条线
                        subPathway = {
                            {
                                pathway = "line_328",
                                startTime = 0,
                                endTime = 20,
                                offsetTime = 0.4 * i,
                                useAngle = true,
                                speed = 146 ,
                            },
                        },
                    })
                end
                for i = 1, 26 do
                    scene.AddFishBornEvent(j, {
                        fish = 1,      -- 指定鱼组
                        fishTypeCount = 1,              -- 鱼类型数量
                        pathway = "line_322",
                        subPathway = {
                            {
                                pathway = "line_334",
                                startTime = 0,
                                endTime = 20,
                                offsetTime = 0.4 * i,
                                useAngle = true,
                                speed = 160,
                            },
                        },
                    })
                end
            end
            for i = 7.5, 60, 16 do
                scene.AddFishBornEvent(i, {
                    fish = 203 ,                 -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    offsetAngles = {math.pi / -2},  --横着走
                    pathway = "line_33c",
                    offsets = {{0, 0}},
                    speedScale = 1.5 ,
                })
            end
            for i = 2, 105, 4 do
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1,                 -- 前进速度
                    fish = {101,102} ,                     -- 鱼或鱼组
                    fishTypeCount = {1} ,             -- 数量
                    -- intervalTime = 0,             -- 两条鱼的间隔时间
                    pathwayGroup = "Group_fish1",          -- 线或线组
                })
            end
        
        
    end
    

    scene1.PushToGame(true)
    scene2.PushToGame(true)
    scene1.PushToGame(true)
    scene4.PushToGame(true)
    scene1.PushToGame(true)
    scene6.PushToGame(true)

     
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

