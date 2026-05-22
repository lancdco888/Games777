-- level/game145.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")

    

    local scene1 = FishEventHelper.CreateScene(1810)
    local scene2 = FishEventHelper.CreateScene(66)
    -- local scene3 = FishEventHelper.CreateScene(870)
    local scene4 = FishEventHelper.CreateScene(65)
    -- local scene5 = FishEventHelper.CreateScene(870)
    local scene6 = FishEventHelper.CreateScene(65)

    --场景1：固定出所有boss
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 19)   
        scene.AddSwitchBgMusicEvent(1, "bg_05")
        -- 持续时间段定义    
            local t1 = 60

        -- 出人鱼 0~2
            scene.AddRule(
                {
                    startTime = 3,
                    endTime = 2*t1-17,
                    -- cdTime = 3.5,
                    leaveCd = 0,
                    deathCd = 45,
                    groupName = "Mermaid", 
                    limit = 1,
                },
                {
                    fish = fishGroup["Mermaid"],      
                    fishTypeCount = 1,
                    pathwayGroup= "Group_Mermaid",
                }
            )
        -- 出金蟾 2~4
            -- scene.AddSwitchBgMusicEvent(2*t1-8, "bg_04")
            scene.AddSwitchBgEvent(2*t1-8, 15)
            scene.AddRule(
                {
                startTime = 2*t1-5 ,
                endTime = 4*t1-20,
                -- cdTime = 0,
                leaveCd = 2,
                deathCd = 2,
                groupName = 327,  
                limit = 1,
                }, 
                {
                fish = 327,      
                fishTypeCount = {1}, 
                createPrams = 
                {
                    fadeInSecs = 3,             -- 淡入持续时间
                    -- fadeOutStartTime = 30,      -- 淡出开始时间
                    -- fadeOutSecs = 3,            -- 淡出持续时间
                    -- scaleInSec = 0.5,             -- 从小变大入场
                },
                pathwayGroup= "Group_jinchan",
                }
            )

        -- 出牛 4~6
            scene.AddSwitchBgMusicEvent(4*t1-14, "Buffalo_Madness_StartBGM")
            scene.AddBossWarningEvent(4*t1-13, FF_G.BossWarning_BisonComing)
            scene.AddBossWarningEvent(4*t1-15, FF_G.BossWarning_Red) --预警泛红
            scene.AddSwitchBgEvent(4*t1-15, 16)
            scene.AddRule(
                {
                startTime = 4*t1-9,
                endTime = 6*t1-5,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 336,  
                limit = 1,
                }, 
                {
                fish = 336,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_niu",
                }
            )
        -- 冥焰赤龙 6~8
            scene.AddSwitchBgMusicEvent(6*t1, "bg_05")
            scene.AddSwitchBgEvent(6*t1, 7)
            scene.AddRule(
                {
                startTime = 6*t1+2,
                endTime = 8*t1-5,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 333,  
                limit = 1,
                }, 
                {
                fish = 333,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_dragon",
                }
            )
        -- 金色龙虾将军 8~10
            scene.AddSwitchBgEvent(8*t1+10-3, 18)
            scene.AddRule(
                {
                startTime = 8*t1+10,
                endTime = 10*t1-15,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 314,  
                limit = 1,
                }, 
                {
                fish = 314,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_boss",
                }
            )
        -- 暗夜炬兽 10~12
            scene.AddSwitchBgMusicEvent(10*t1, "bg_05")
            scene.AddSwitchBgEvent(10*t1, 8)   -- 切换场景
            for i = 10*t1+5, 12*t1, 115 do
                scene.AddSetPlayBgAnimEvent(i, "xunhuan") --背景动画
            end
            scene.AddShakeEvent(10*t1, 2.5, 8) --震动
            scene.AddHaiwanglaixiEvent(10*t1 +2, FF_G.Haiwanglaixi_FishType_NightBeast) -- boss 预警
            scene.AddBossWarningEvent(10*t1-2, FF_G.BossWarning_Red) --预警泛红
            scene.AddRule(
                {
                startTime = 10*t1+4,
                endTime = 12*t1-40,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 300,  
                limit = 1,
                }, 
                {
                fish = 300,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_long",
                }
            )


        -- 出霸王蟹 303 12~14
            scene.AddSwitchBgMusicEvent(12*t1, "bg_king")
            scene.AddHaiwanglaixiEvent(12*t1 + 2, FF_G.Haiwanglaixi_FishType_KingCrab) 
            scene.AddSwitchBgEvent(12*t1 + 3, 10)
            scene.AddSetPlayBgAnimEvent(12*t1+4, "scar", true)
            scene.AddBossWarningEvent(12*t1-2, FF_G.BossWarning_Red) --预警泛红
            scene.AddRule(
                    {
                        startTime =  12*t1 + 5,
                        endTime = 14*t1-30,
                        cdTime = 3.5,
                        leaveCd = 0,
                        deathCd = 0,
                        groupName = 303, 
                        limit = 2,
                    },
                    {
                        fish = 303,      
                        fishTypeCount = 1,
                        pathway= "line_pang1",
                    }
            )

        -- 出龙龟 14~16
            scene.AddSwitchBgMusicEvent(14*t1+2, "bg_05")
            scene.AddSwitchBgEvent(14*t1+5-2, 5)
            scene.AddRule(
                {
                startTime = 14*t1+5,
                endTime = 16*t1-15,
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

        -- 出八爪章鱼 16~18
            scene.AddSwitchBgMusicEvent(16*t1, "fk_bg_king_02")
            scene.AddHaiwanglaixiEvent(16*t1+5-4, FF_G.Haiwanglaixi_FishType_KingOctopus)
            scene.AddSwitchBgEvent(16*t1+5-3, 11)
            scene.AddBossWarningEvent(16*t1-2, FF_G.BossWarning_Red) --预警泛红
            scene.AddRule(
                {
                    startTime =  16*t1+5,
                    endTime = 18*t1-15,
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
            -- 旋转场景 八爪章鱼场景

            for i = 16*t1+5+3, 18*t1, 60 do
                scene.AddSetPlayBgAnimEvent(i, "turn1")
                scene.AddSetPlayBgAnimEvent(i + 15, "turn2")
                scene.AddSetPlayBgAnimEvent(i + 30, "turn3")
                scene.AddSetPlayBgAnimEvent(i + 45, "turn4")
            end

        -- 出凤凰 18~20
            scene.AddSwitchBgMusicEvent(18*t1, "bossstage")
            scene.AddSwitchBgEvent(18*t1 + 10-3, 6)
            scene.AddRule(
                {
                startTime = 18*t1 + 10,
                endTime = 20*t1-8,
                cdTime = 0,
                leaveCd = 0,
                deathCd = 60,
                groupName = 207,  
                limit = 1,
                }, 
                {
                fish = 207,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_phoenex",
                }
            )
            -- 凤凰阶段补小鱼
            for i = 18*t1, 20*t1-2, 3 do
                scene.AddFishBornEvent(i, {
                    -- fish = fishGroup["fish1"], 
                    fish = {0,0,1,1,1,2,2,2,1,1,1,2,2,2,1,1,1,2,2,2,2}, 
                    fishTypeCount = {4},
                    intervalTime = 0.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            -- 凤凰阶段出中型鱼
            for i = 18*t1, 20*t1-2, 4 do
                scene.AddFishBornEvent(i, {
                    -- fish = fishGroup["fish2"],
                    fish = {3,4,5,6,7,8,9,10,11,12,3,4,5,6,7,8,9,10,12},
                    fishTypeCount = {3},
                    intervalTime = 0.5,
                    pathwayGroup = "Group_fish2",
                })
            end
        -- 史前巨鳄 20~22
            scene.AddSwitchBgEvent(20*t1-2, 3)   -- 切换场景
            scene.AddShakeEvent(20*t1, 2.5, 8) --震动
            scene.AddSetPlayBgAnimEvent(20*t1, "open1") --背景动画
            scene.AddSetPlayBgAnimEvent(22*t1-2, "close") --背景动画
            scene.AddHaiwanglaixiEvent(20*t1 +2, FF_G.Haiwanglaixi_FishType_Crocodile) -- boss 预警
            scene.AddBossWarningEvent(20*t1-2, FF_G.BossWarning_Red) --预警泛红
            scene.AddRule(
                {
                startTime = 20*t1+4,
                endTime = 22*t1-15,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 308,  
                limit = 1,
                }, 
                {
                fish = 308,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_long",
                }
            )
        -- 出通用boss 8个，22~29
            scene.AddSwitchBgMusicEvent(22*t1, "tournament_waiting")
            local ids = fishGroup["generalboss"]
            local index = 1
            for i = 22, 29 do
                local id = ids[index]
                local startTime = i*t1+5
                index = index + 1
                scene.AddRule(
                    {
                    startTime = startTime,
                    endTime = startTime + t1-20,
                    -- cdTime = 0,
                    leaveCd = 0,
                    deathCd = 0,
                    groupName = id,  
                    limit = 1,
                    }, 
                    {
                    fish = id,      
                    fishTypeCount = {1}, 
                    pathwayGroup= "Group_boss",
                    }
                )             
            end
            -- 换场景 8个
            local ids1 ={18,19,15,16,17,9,7,5}
            for i = 22, 29 do
                scene.AddSwitchBgEvent(i*60, ids1[i-21])             
            end
        -- 出special
            scene.AddRule(
                {
                startTime = t1+10,
                endTime = 30*t1-3,
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
            
            for i = 113, 30*t1-2, 133 do
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
            
            for i = 55, 30*t1-2, 133 do
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
            for i = 7, 30*t1-2, 20 do
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
            for i = 5, 30*t1-2, 20 do
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
            for i = 10, 30*t1-2, 140 do
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
            for i = 0, 30*t1-2, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {5, 4},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            

        -- 出普通中型鱼：SetFishGroup("fish2", {3,4,6,7,8,9,10,11,12})
            for i = 0, 30*t1-2, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2L",
                })
            end
            for i = 4, 30*t1-2, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2R",
                })
            end
            
            

        -- 出普通大鱼：SetFishGroup("fish3", {13,14,15,16,17})
            for i = 0, 30*t1-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3L",
                })
            end
            for i = 8, 30*t1-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3R",
                })
            end    

        -- 出彩金鱼：SetFishGroup("goldedfish", {320,321,322,323,324})
            for i = 4, 30*t1-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishL",
                })
            end
            for i = 12, 30*t1-2, 15 do
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
                    endTime = 30*t1-50,
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
        
            for i = 38, 30*t1-2, 180 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            
        -- 出比目鱼：5
            for i = 2, 30*t1-2, 20 do
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
                endTime = 30*t1-40,
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
            -- for i = 8, 30*t1-2, 15 do
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
                    endTime = 30*t1-2,
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
            
            for i = 40, 30*t1-2, 100 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
           

        -- 出辅助线-----

            for i = 89, 30*t1, 180 do
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

            for i = 30, 30*t1, 185 do
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

            for i = 420,30*t1, 180 do
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
            
            for i = 155, 30*t1, 180 do
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

            for i = 788, 30*t1, 180 do
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

            for i = 525, 30*t1, 180 do
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
   
    --场景2： --  --------------鱼阵10-中心圆-------------
    do
     
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        scene.AddRule(
                {
                    startTime = 3,
                    endTime =60,
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

       
        --  --------------鱼阵10-中心圆-------------       
        for i = 0, 60, 0.3 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 1 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_128",           -- 线或线组
            })
         end
         for i = 0, 60, 0.4 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 2 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_129",           -- 线或线组
            })
         end
         for i = 0, 60, 0.3 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 0 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_130",           -- 线或线组
            })
         end
         for i = 0, 60, 0.6 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 4 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_131",           -- 线或线组
            })
         end
         for i = 0, 60, 6 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 323 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_132",           -- 线或线组
            })
         end
         for i = 0, 60, 6 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 16 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_133",           -- 线或线组
            })
         end
         for i = 2.7, 60, 6 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 16 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_132",           -- 线或线组
            })
         end
         for i = 2.7, 60, 6 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1.5,                 -- 前进速度
                fish = 323 ,                      -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_133",           -- 线或线组
            })
         end
         for i = 6, 46, 10 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = 202 ,                     -- 鱼或鱼组
                fishTypeCount = 1 ,             -- 数量
                pathway = "line_yz3",           -- 线或线组
                offsetAngles = {math.pi / 2},
            })
         end
    end
    


    --场景4： --------------鱼阵11-两圆上下-------------
    do
     
        local scene = scene4
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        scene.AddRule(
                {
                    startTime = 3,
                    endTime =60,
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

       
         --------------鱼阵11-两圆上下-------------   
        for j = 0, 60, 16 do
            for i = 1, 8 do
                scene.AddFishBornEvent(j, {
                    fish = 11,                       -- 指定鱼组
                    fishTypeCount = 1,              -- 鱼类型数量
                    pathway = "line_136",
                    subPathway = {
                        {
                            pathway = "line_334",
                            startTime = 0,
                            endTime = 20,
                            offsetTime = 0.95 * i,
                            useAngle = false,
                            speed = 200 ,
                        },
                    },
                })
            end
                scene.AddFishBornEvent(j, {
                    fish = 111,                     -- 指定鱼组
                    fishTypeCount = 1,              -- 鱼类型数量
                    offsets = {{0, 0}},        -- 刷鱼的位置
                    intervalTime = 0,               -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_136",
                }) 
            for i = 1, 8 do
                scene.AddFishBornEvent(j, {
                    fish = 12,                       -- 指定鱼组
                    fishTypeCount = 1,              -- 鱼类型数量
                    pathway = "line_137",
                    subPathway = {
                        {
                            pathway = "line_334",
                            startTime = 0,
                            endTime = 20,
                            offsetTime = 0.95 * i,
                            useAngle = false,
                            speed = 200 ,
                        },
                    },
                })
            end
                scene.AddFishBornEvent(j, {
                    fish = 112,                     -- 指定鱼组
                    fishTypeCount = 1,              -- 鱼类型数量
                    offsets = {{0, 0}},        -- 刷鱼的位置
                    intervalTime = 0,               -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_137",
                }) 
        end
        for j = 8, 60, 16 do
            for i = 1, 8 do
                scene.AddFishBornEvent(j, {
                    fish = 12,                       -- 指定鱼组
                    fishTypeCount = 1,              -- 鱼类型数量
                    pathway = "line_136",
                    subPathway = {
                        {
                            pathway = "line_334",
                            startTime = 0,
                            endTime = 20,
                            offsetTime = 0.95 * i,
                            useAngle = false,
                            speed = 200 ,
                        },
                    },
                })
            end
                scene.AddFishBornEvent(j, {
                    fish = 112,                     -- 指定鱼组
                    fishTypeCount = 1,              -- 鱼类型数量
                    offsets = {{0, 0}},        -- 刷鱼的位置
                    intervalTime = 0,               -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_136",
                }) 
            for i = 1, 8 do
                scene.AddFishBornEvent(j, {
                    fish = 11,                       -- 指定鱼组
                    fishTypeCount = 1,              -- 鱼类型数量
                    pathway = "line_137",
                    subPathway = {
                        {
                            pathway = "line_334",
                            startTime = 0,
                            endTime = 20,
                            offsetTime = 0.95 * i,
                            useAngle = false,
                            speed = 200 ,
                        },
                    },
                })
            end
                scene.AddFishBornEvent(j, {
                    fish = 111,                     -- 指定鱼组
                    fishTypeCount = 1,              -- 鱼类型数量
                    offsets = {{0, 0}},        -- 刷鱼的位置
                    intervalTime = 0,               -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_137",
                }) 
        end
        for i = 7.5, 40, 16 do
            scene.AddFishBornEvent(i, {
                fish = 202 ,                 -- 鱼或鱼组
                fishTypeCount = 1 ,
                offsetAngles = {math.pi / -2},  --横着走
                pathway = "line_318",
            })
         end
         for i = 15.5, 40, 16 do
            scene.AddFishBornEvent(i, {
                fish = 202 ,                 -- 鱼或鱼组
                fishTypeCount = 1 ,
                offsetAngles = {math.pi / -2},  --横着走
                pathway = "line_319",
            })
         end
        for i = 0, 60, 6 do
            scene.AddFishBornEvent(i, 
            {
                speedScale = 1,                 -- 前进速度
                fish = {0,1,2,1,2,0,1,2} ,                     -- 鱼或鱼组
                fishTypeCount = {5} ,             -- 数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                --lineCount = 8 ,
                fixedFishType = true,
                pathwayGroup = "Group_fish1",          -- 线或线组
            })
        end
    end
 

    --场景6：--------------鱼阵16-中心出鱼-鱼王--------20210709优化----- 
    do
     
        local scene = scene6
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        for i = 0 , 59 , 1 do
            if i == 30 or i == 31 or i == 32 or i == 34 or i == 35 or i == 36 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1.25,                          -- 前进速度
                    fish = {3,3,3,3,3,3,3,3}  ,                 -- 鱼或鱼组
                    fishTypeCount = {8} ,                       -- 数量
                    intervalTime = 0,                           -- 两条鱼的间隔时间
                    --lineCount = 8 ,
                    fixedFishType = true,
                    pathwayGroup = "Group_zhognxin",            -- 线或线组
                    createPrams = 
                    {
                        -- fadeInSecs = 3,             -- 淡入持续时间
                        -- fadeOutStartTime = 30,      -- 淡出开始时间
                        -- fadeOutSecs = 3,            -- 淡出持续时间
                        scaleInSec = 0.7,             -- 从小变大入场
                    },
                })
            end
            if i == 33 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1.25,                          -- 前进速度
                    fish = {103,103,103,103,103,103,103,103} ,                     -- 鱼或鱼组
                    fishTypeCount = {8} ,                       -- 数量
                    intervalTime = 0,                           -- 两条鱼的间隔时间
                    --lineCount = 8 ,
                    fixedFishType = true,
                    pathwayGroup = "Group_zhognxin",          -- 线或线组
                    createPrams = 
                    {
                        -- fadeInSecs = 3,             -- 淡入持续时间
                        -- fadeOutStartTime = 30,      -- 淡出开始时间
                        -- fadeOutSecs = 3,            -- 淡出持续时间
                        scaleInSec = 0.7,             -- 从小变大入场
                    },
                })
            end
            if i == 10 or i == 11 or i == 12 or i == 14 or i == 15 or i == 16 or i == 50 or i == 51 or i == 52 or i == 54 or i == 55 or i==56 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1,                             -- 前进速度
                    fish = {4,4,4,4,4,4,4,4}  ,                 -- 鱼或鱼组
                    fishTypeCount = {8} ,                       -- 数量
                    intervalTime = 0,                           -- 两条鱼的间隔时间
                    --lineCount = 8 ,
                    fixedFishType = true,
                    pathwayGroup = "Group_zhognxin",            -- 线或线组
                    createPrams = 
                    {
                        -- fadeInSecs = 3,             -- 淡入持续时间
                        -- fadeOutStartTime = 30,      -- 淡出开始时间
                        -- fadeOutSecs = 3,            -- 淡出持续时间
                        scaleInSec = 1,             -- 从小变大入场
                    },
                })
            end
            if i == 13 or i == 53 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1,                         -- 前进速度
                    fish = {104,104,104,104,104,104,104,104} ,                     -- 鱼或鱼组
                    fishTypeCount = {8} ,                   -- 数量
                    intervalTime = 0,                       -- 两条鱼的间隔时间
                    --lineCount = 8 ,
                    fixedFishType = true,
                    pathwayGroup = "Group_zhognxin",        -- 线或线组
                    createPrams = 
                    {
                        -- fadeInSecs = 3,             -- 淡入持续时间
                        -- fadeOutStartTime = 30,      -- 淡出开始时间
                        -- fadeOutSecs = 3,            -- 淡出持续时间
                        scaleInSec = 1,             -- 从小变大入场
                    },
                })
            end
            if i == 0 or i == 4 or i == 40 or i == 44 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1
                    ,                                       -- 前进速度
                    fish = {323,323,323,323,323,323,323,323} ,                     -- 鱼或鱼组
                    fishTypeCount = {8} ,                   -- 数量
                    intervalTime = 0,                       -- 两条鱼的间隔时间
                    --lineCount = 8 ,
                    fixedFishType = true,
                    pathwayGroup = "Group_zhognxin",        -- 线或线组
                    createPrams = 
                    {
                        -- fadeInSecs = 3,             -- 淡入持续时间
                        -- fadeOutStartTime = 30,      -- 淡出开始时间
                        -- fadeOutSecs = 3,            -- 淡出持续时间
                        scaleInSec = 3,             -- 从小变大入场
                    },
                })
            end
            if i == 20 or i == 24 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1,                         -- 前进速度
                    fish = {324,324,324,324,324,324,324,324} ,                     -- 鱼或鱼组
                    fishTypeCount = {8} ,                   -- 数量
                    intervalTime = 0,                       -- 两条鱼的间隔时间
                    --lineCount = 8 ,
                    fixedFishType = true,
                    pathwayGroup = "Group_zhognxin",        -- 线或线组
                    createPrams = 
                    {
                        -- fadeInSecs = 3,             -- 淡入持续时间
                        -- fadeOutStartTime = 30,      -- 淡出开始时间
                        -- fadeOutSecs = 3,            -- 淡出持续时间
                        scaleInSec = 4,             -- 从小变大入场
                    },
                })
            end
            if i % 20 == 4 and i < 40 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 0.7,                   -- 前进速度
                    fish =  202 ,                  -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    pathway = "line_yzd1",              -- 线或线组
                    offsetAngles = {math.pi / -2},
                })
            end
            if i % 20 == 14 and i < 40 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1,                     -- 前进速度
                    fish = 203 ,                  -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    pathway = "line_yz3",               -- 线或线组
                    offsetAngles = {math.pi / -2},
                })
            end
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

