-- level/game107.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")

    

    local scene1 = FishEventHelper.CreateScene(1750)
    local scene2 = FishEventHelper.CreateScene(115)
    -- local scene3 = FishEventHelper.CreateScene(870)
    local scene4 = FishEventHelper.CreateScene(115)
    -- local scene5 = FishEventHelper.CreateScene(870)
    local scene6 = FishEventHelper.CreateScene(115)

    --场景1：随机出所有boss
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 15)   
        scene.AddSwitchBgMusicEvent(1, "bg_06")
        
        -- 持续时间段定义    
            local t1 = 60
            
        -- 觉醒霸王蟹 211 1~3
            scene.AddHaiwanglaixiEvent(t1, FF_G.Haiwanglaixi_FishType_Wakeup)
            scene.AddHaiwanglaixiEvent(t1 + 2, FF_G.Haiwanglaixi_FishType_WakeupKingCrab) 
            scene.AddSwitchBgMusicEvent(t1 + 1, "fk_bg_king_02")
            scene.AddSwitchBgMusicEvent(3*t1-5, "bg_06")
            scene.AddSwitchBgEvent(t1 + 3, 10)
            scene.AddSetPlayBgAnimEvent(t1 + 4, "scar", true)
            scene.AddBossWarningEvent(t1-2, FF_G.BossWarning_Red)
            scene.AddRule(
                    {
                        startTime =  t1 + 5,
                        endTime = 3*t1-30,
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
        -- 出牛 3~5
            -- scene.AddBossWarningEvent(3*t1, FF_G.BossWarning_BisonComing)
            -- scene.AddSwitchBgEvent(3*t1+3, 16)
            -- scene.AddBossWarningEvent(3*t1-2, FF_G.BossWarning_Red)
            -- scene.AddRule(
            --     {
            --     startTime = 3*t1+5,
            --     endTime = 5*t1-5,
            --     -- cdTime = 0,
            --     leaveCd = 0,
            --     deathCd = 0,
            --     groupName = 336,  
            --     limit = 1,
            --     }, 
            --     {
            --     fish = 336,      
            --     fishTypeCount = {1}, 
            --     pathwayGroup= "Group_niu",
            --     }
            -- )
        -- 出觉醒的暗夜巨兽 5~7
            scene.AddHaiwanglaixiEvent(5*t1, FF_G.Haiwanglaixi_FishType_Wakeup)
            scene.AddHaiwanglaixiEvent(5*t1 + 2, FF_G.Haiwanglaixi_FishType_WakeupNightBeast)
            scene.AddSwitchBgEvent(5*t1 + 5-2, 3)
            -- scene.AddSwitchBgMusicEvent(5*t1 + 5-2, "bg_02")
            scene.AddRule(
                {
                startTime = 5*t1 + 5,
                endTime = 7*t1-10,
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
        -- 出金蟾 7~9
            -- scene.AddSwitchBgEvent(7*t1 + 5-3, 15)
            -- scene.AddRule(
            --     {
            --     startTime = 7*t1 + 5,
            --     endTime = 9*t1-15,
            --     -- cdTime = 0,
            --     leaveCd = 2,
            --     deathCd = 2,
            --     groupName = 327,  
            --     limit = 1,
            --     }, 
            --     {
            --     fish = 327,      
            --     fishTypeCount = {1}, 
            --     createPrams = 
            --     {
            --         fadeInSecs = 3,             -- 淡入持续时间
            --         -- fadeOutStartTime = 30,      -- 淡出开始时间
            --         -- fadeOutSecs = 3,            -- 淡出持续时间
            --         -- scaleInSec = 0.5,             -- 从小变大入场
            --     },
            --     pathwayGroup= "Group_jinchan",
            --     }
            -- )

        -- 出觉醒史前巨鳄 9~11
            scene.AddHaiwanglaixiEvent(9*t1, FF_G.Haiwanglaixi_FishType_Wakeup)
            scene.AddHaiwanglaixiEvent(9*t1 + 2, FF_G.Haiwanglaixi_FishType_WakeupCrocodile)
            scene.AddSwitchBgEvent(9*t1 + 5-2, 4)
            scene.AddRule(
                {
                startTime = 9*t1 + 5,
                endTime = 11*t1-10,
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
        -- 出人鱼 11~13
            -- scene.AddSwitchBgEvent(11*t1 + 10-3, 17)
            -- scene.AddRule(
            --     {
            --         startTime =  11*t1 + 10,
            --         endTime = 13*t1-10,
            --         -- cdTime = 3.5,
            --         leaveCd = 0,
            --         deathCd = 45,
            --         groupName = "Mermaid", 
            --         limit = 1,
            --     },
            --     {
            --         fish = fishGroup["Mermaid"],      
            --         fishTypeCount = 1,
            --         pathwayGroup= "Group_Mermaid",
            --     }
            -- )

        -- 随机出通用boss 13~15
            -- scene.AddSwitchBgEvent(13*t1 + 5-2, 15)
            -- -- scene.AddSwitchBgMusicEvent(13*t1 + 5-2, "bg_04")
            -- scene.AddRule(
            --     {
            --     startTime = 13*t1 + 5,
            --     endTime = 15*t1-15,
            --     -- cdTime = 0,
            --     leaveCd = 0,
            --     deathCd = 0,
            --     groupName = "boss",  
            --     limit = 1,
            --     }, 
            --     {
            --     fish = fishGroup["boss"],      
            --     fishTypeCount = {1}, 
            --     pathwayGroup= "Group_boss",
            --     }
            -- )
            

        -- 出凤凰 15~17
            -- scene.AddSwitchBgEvent(15*t1 + 10-3, 6)
            -- scene.AddRule(
            --     {
            --     startTime = 15*t1 + 10,
            --     endTime = 17*t1-8,
            --     cdTime = 0,
            --     leaveCd = 0,
            --     deathCd = 60,
            --     groupName = 207,  
            --     limit = 1,
            --     }, 
            --     {
            --     fish = 207,      
            --     fishTypeCount = {1}, 
            --     pathwayGroup= "Group_phoenex",
            --     }
            -- )
            -- -- 凤凰阶段补小鱼
            -- for i = 15*t1, 17*t1-2, 3 do
            --     scene.AddFishBornEvent(i, {
            --         -- fish = fishGroup["fish1"], 
            --         fish = {0,0,1,1,1,2,2,2,1,1,1,2,2,2,1,1,1,2,2,2,2}, 
            --         fishTypeCount = {4},
            --         intervalTime = 0.5,
            --         pathwayGroup = "Group_fish1",
            --     })
            -- end
            -- -- 凤凰阶段出中型鱼
            -- for i = 15*t1, 17*t1-2, 4 do
            --     scene.AddFishBornEvent(i, {
            --         -- fish = fishGroup["fish2"],
            --         fish = {3,4,5,6,7,8,9,10,11,12,3,4,5,6,7,8,9,10,12},
            --         fishTypeCount = {3},
            --         intervalTime = 0.5,
            --         pathwayGroup = "Group_fish2",
            --     })
            -- end

        -- 随机出通用boss 17~19
            -- scene.AddSwitchBgEvent(17*t1 + 5-2, 18)
            -- scene.AddRule(
            --     {
            --     startTime = 17*t1 + 5,
            --     endTime = 19*t1-10,
            --     -- cdTime = 0,
            --     leaveCd = 0,
            --     deathCd = 0,
            --     groupName = "boss",  
            --     limit = 1,
            --     }, 
            --     {
            --     fish = fishGroup["boss"],      
            --     fishTypeCount = {1}, 
            --     pathwayGroup= "Group_boss",
            --     }
            -- )    
        -- 出龙龟 19~21
            -- scene.AddSwitchBgEvent(19*t1+3, 7)
            -- scene.AddRule(
            --     {
            --     startTime = 19*t1+5,
            --     endTime = 21*t1-15,
            --     -- cdTime = 0,
            --     leaveCd = 2,
            --     deathCd = 2,
            --     groupName = 304,  
            --     limit = 1,
            --     }, 
            --     {
            --     fish = 304,      
            --     fishTypeCount = {1}, 
            --     pathwayGroup= "Group_longgui",
            --     }
            -- )
        -- 随机出通用boss 21~23
            -- scene.AddSwitchBgEvent(21*t1 + 5-2, 16)
            -- scene.AddRule(
            --     {
            --     startTime = 21*t1 + 5,
            --     endTime = 23*t1-10,
            --     -- cdTime = 0,
            --     leaveCd = 0,
            --     deathCd = 0,
            --     groupName = "boss",  
            --     limit = 1,
            --     }, 
            --     {
            --     fish = fishGroup["boss"],      
            --     fishTypeCount = {1}, 
            --     pathwayGroup= "Group_boss",
            --     }
            -- )
        -- 出觉醒八爪章鱼 23~25
            scene.AddHaiwanglaixiEvent(23*t1-1, FF_G.Haiwanglaixi_FishType_Wakeup)
            scene.AddHaiwanglaixiEvent(23*t1+5-4, FF_G.Haiwanglaixi_FishType_WakeupKingOctopus)
            scene.AddSwitchBgMusicEvent(23*t1+5-4, "fk_bg_king_02")
            scene.AddSwitchBgEvent(23*t1+5-3, 11)
            scene.AddBossWarningEvent(23*t1-2, FF_G.BossWarning_Red)
            scene.AddRule(
                {
                    startTime =  23*t1+5,
                    endTime = 25*t1-15,
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

            for i = 23*t1+5+3, 25*t1, 60 do
                scene.AddSetPlayBgAnimEvent(i, "turn1")
                scene.AddSetPlayBgAnimEvent(i + 15, "turn2")
                scene.AddSetPlayBgAnimEvent(i + 30, "turn3")
                scene.AddSetPlayBgAnimEvent(i + 45, "turn4")
            end
        -- 随机出通用boss 25~27
            -- scene.AddSwitchBgEvent(25*t1 + 5-2, 19)
            -- scene.AddSwitchBgMusicEvent(25*t1 + 5-2, "bg_06")
            -- scene.AddRule(
            --     {
            --     startTime = 25*t1 + 5,
            --     endTime = 27*t1-10,
            --     -- cdTime = 0,
            --     leaveCd = 0,
            --     deathCd = 0,
            --     groupName = "boss",  
            --     limit = 1,
            --     }, 
            --     {
            --     fish = fishGroup["boss"],      
            --     fishTypeCount = {1}, 
            --     pathwayGroup= "Group_boss",
            --     }
            -- )

        
        -- 出觉醒霸王蟹 27~29
            scene.AddHaiwanglaixiEvent(27*t1, FF_G.Haiwanglaixi_FishType_Wakeup)
            scene.AddHaiwanglaixiEvent(27*t1 + 2, FF_G.Haiwanglaixi_FishType_WakeupKingCrab) 
            scene.AddSwitchBgMusicEvent(27*t1 + 2, "fk_bg_king_02")
            scene.AddSwitchBgMusicEvent(29*t1-30, "bg_06")
            scene.AddSwitchBgEvent(27*t1 + 3, 10)
            scene.AddSetPlayBgAnimEvent(27*t1 + 4, "scar", true)
            scene.AddBossWarningEvent(27*t1-2, FF_G.BossWarning_Red)
            scene.AddRule(
                    {
                        startTime =  27*t1 + 5,
                        endTime = 29*t1-30,
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

        
        -- 出special
            scene.AddRule(
                {
                startTime = 10,
                endTime = 29*t1-3,
                cdTime = 1,
                leaveCd = 0,
                deathCd = 0,
                groupName = "special142",  
                limit = 1,
                }, 
                {
                -- fish = 205, 
                fish = fishGroup["special142"],     
                fishTypeCount = {1}, 
                pathwayGroup= "Group_special",
                }
            )
        -- 猫大爷
            
            for i = 110, 29*t1-2, 133 do
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
            
            for i = 55, 29*t1-2, 133 do
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
            for i = 7, 29*t1-2, 20 do
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
            for i = 5, 29*t1-2, 30 do
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
            for i = 35, 29*t1-2, 140 do
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
            for i = 0, 29*t1-2, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish1"],      -- 指定鱼组
                    fishTypeCount = {5, 4},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_fish1",
                })
            end
            

        -- 出普通中型鱼：SetFishGroup("fish2", {3,4,6,7,8,9,10,11,12})
            for i = 0, 29*t1-2, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2L",
                })
            end
            for i = 4, 29*t1-2, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish2"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish2R",
                })
            end
            
        -- 出普通大鱼：SetFishGroup("fish3", {13,14,15,16,17})
            for i = 0, 29*t1-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_fish3L",
                })
            end
            for i = 8, 29*t1-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish3"],
                    fishTypeCount = {1},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_fish3R",
                })
            end

        -- 出彩金鱼：SetFishGroup("goldedfish", {320,321,322,323,324})
            for i = 4, 29*t1-2, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["goldedfish"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_gfishL",
                })
            end
            for i = 12, 29*t1-2, 15 do
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
                    endTime = 29*t1-50,
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
        
            for i = 38, 29*t1-2, 190 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["combinedfish"],      -- 指定鱼组
                    fishTypeCount = {1},
                    pathwayGroup = "Group_Cbfish",
                })
            end
            
        -- 出比目鱼：5
            for i = 2, 29*t1-2, 20 do
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
                endTime = 29*t1-40,
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
                    endTime = 29*t1-2,
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
            
            for i = 90, 29*t1-2, 120 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["kingfish"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_BCycle",
                })
            end
           

        -- 出辅助线-----

            for i = 89, 29*t1, 180 do
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

            for i = 30, 29*t1, 185 do
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

            for i = 420,29*t1, 180 do
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
            
            for i = 155, 29*t1, 180 do
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

            for i = 788, 29*t1, 180 do
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

            for i = 525, 29*t1, 180 do
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

    --场景2：
    ------鱼阵：小丑鱼和黄金小丑鱼池--------------------
    do
     
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        -- scene.AddRule(
        --         {
        --         startTime = 5,
        --         endTime = 80,
        --         -- cdTime = 0,
        --         leaveCd = 0,
        --         deathCd = 0,
        --         groupName = "Carb",  
        --         limit = 1,
        --         }, 
        --         {
        --         fish = fishGroup["Carb"],      
        --         fishTypeCount = {1}, 
        --         pathwayGroup= "Group_Carb",
        --         }
        -- )
        for i = 5, 60, 20 do
            scene.AddFishBornEvent(i, {
                fish = 201,
                fishTypeCount = 1,
                pathwayGroup = "Group_Carb",
            })
        end
        for i = 17, 80, 18 do
            scene.AddFishBornEvent(i, {
                fish = {202,203},
                fishTypeCount = 1,
                pathwayGroup = "Group_Carb",
            })
        end

        for i = 0, 105, 7 do
            scene.AddFishBornEvent(i, {
                fish = {14,14,14},
                fishTypeCount = {3},
                pathwayGroup = "Group_yzxcyL",
            })
        end
        for i = 3, 105, 7 do
            scene.AddFishBornEvent(i, {
                fish = {14,14,14},
                fishTypeCount = {3},
                pathwayGroup = "Group_yzxcyR",
            })
        end
        for i = 3, 105, 7 do
            scene.AddFishBornEvent(i, {
                fish = {320,320,320},
                fishTypeCount = {3},
                pathwayGroup = "Group_yzhjxcyL",
            })
        end
        for i = 1, 105, 7 do
            scene.AddFishBornEvent(i, {
                fish = {320,320,320},
                fishTypeCount = {3},
                pathwayGroup = "Group_yzhjxcyR",
            })
        end
        
    end

    

    --场景4：--------------------鱼阵:中间出螺旋形状河豚，伴随闪电鲨和炸弹蟹----------------------
    do
     
        local scene = scene4
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        
        for i = 0 , 105, 0.5 do
            if i % 10 == 6 then
            scene.AddFishBornEvent(i, {
                fish = {200,200},                       -- 指定鱼组
                fishTypeCount = 2,                      -- 鱼类型数量
                pathwayGroup = "Group_yzzxsd",
                speedScale = 1
            })
            end
            if i>=10 and i % 10 == 0 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 2,                     -- 前进速度
                    fish = 103,                         -- 鱼或鱼组
                    pathwayGroup = "Group_zhognxin",    -- 线或线组
                    fishCount = 8,
                    intervalTime = 0,  
                    fixedFishType = true,
                    createPrams = 
                    {
                        -- fadeInSecs = 3,             -- 淡入持续时间
                        -- fadeOutStartTime = 30,      -- 淡出开始时间
                        -- fadeOutSecs = 3,            -- 淡出持续时间
                        scaleInSec = 0.6,             -- 从小变大入场
                    },
                })
            end
            if i>=10 and i % 10 < 5 then
                scene.AddFishBornEvent(i+0.5, 
                {
                    speedScale = 2,                     -- 前进速度
                    fish = 3,                           -- 鱼或鱼组
                    pathwayGroup = "Group_zhognxin",    -- 线或线组
                    fishCount = 8,
                    intervalTime = 0,  
                    fixedFishType = true,
                    createPrams = 
                    {
                        -- fadeInSecs = 3,             -- 淡入持续时间
                        -- fadeOutStartTime = 30,      -- 淡出开始时间
                        -- fadeOutSecs = 3,            -- 淡出持续时间
                        scaleInSec = 0.6,             -- 从小变大入场
                    },
                })
            end
            if i>=10 and i % 10 == 0 and i<80 then
                scene.AddFishBornEvent(i, {
                    fish = {202,203},                    -- 指定鱼组
                    fishTypeCount = 1,                   -- 鱼类型数量
                    --pathwayGroup = "Group_Carb",
                    pathway = "line_yzzxcarb",
                    offsetAngles = {math.pi / -2},
                    speedScale = 0.7
                })
            end
            
        end
        for i = 0 , 105 , 25 do
            if  i % 50 == 0 then
                scene.AddFishBornEvent(i, {
                    fish = 102,                     -- 指定鱼组
                    fishTypeCount = 1,              -- 鱼类型数量
                    pathway = "line_yzzxL",
                    speedScale = 1.5
                })
                scene.AddFishBornEvent(i+0.5, {
                    fish = 2,                       -- 指定鱼组
                    fishCount = {25},               -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_yzzxL",
                    speedScale = 1.5
                })
            else
                scene.AddFishBornEvent(i, {
                    fish = 102,                     -- 指定鱼组
                    fishTypeCount = 1,              -- 鱼类型数量
                    pathway = "line_yzzxR",
                    speedScale = 1.5
                })
                scene.AddFishBornEvent(i, {
                    fish = 2,                       -- 指定鱼组
                    fishCount = {25},               -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 0.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_yzzxR",
                    speedScale = 1.5
                })
            end
        end
    end

    

    --场景6：--------------鱼阵15-花两朵-鱼王()-------------  20210709优化
    do
     
        local scene = scene6
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 1)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        scene.AddRule(
                {
                    startTime = 5,
                    endTime =100,
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

        for i = 0, 105, 1 do
            if i % 30 > 0 and i % 30 < 15 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1 ,                 -- 前进速度
                    fish = {4,4,4,104} ,                     -- 鱼或鱼组
                    fishTypeCount = {4} ,             -- 数量
                -- lineCount = 1 ,                  -- 固定选一条鱼线
                    pathwayGroup = "Group_hua2",           -- 线或线组
                })
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1.5 ,                 -- 前进速度
                    fish = {3,3,3,103} ,                     -- 鱼或鱼组
                    fishTypeCount = {4} ,             -- 数量
                -- lineCount = 1 ,                  -- 固定选一条鱼线
                    pathwayGroup = "Group_hua3",           -- 线或线组
                })
            end
            if i % 30 > 15 and i % 30 < 30 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1 ,                 -- 前进速度
                    fish = {4,4,4,104} ,                     -- 鱼或鱼组
                    fishTypeCount = {4} ,             -- 数量
                -- lineCount = 1 ,                  -- 固定选一条鱼线
                    pathwayGroup = "Group_hua3",           -- 线或线组
                })
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1.5 ,                 -- 前进速度
                    fish = {3,3,3,103} ,                     -- 鱼或鱼组
                    fishTypeCount = {4} ,             -- 数量
                -- lineCount = 1 ,                  -- 固定选一条鱼线
                    pathwayGroup = "Group_hua2",           -- 线或线组
                })
            end
            if i % 8 == 5 and i<70 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 0.7,                   -- 前进速度
                    fish = {202,201} ,                  -- 鱼或鱼组
                    fishTypeCount = 1 ,
                    pathway = "line_yzd1",              -- 线或线组
                    offsetAngles = {math.pi / -2},
                })
            end
            if i % 3 == 2 then
                scene.AddFishBornEvent(i, 
                {
                    speedScale = 1,                 -- 前进速度
                    fish = {14,320} ,                      -- 鱼或鱼组
                    fishTypeCount = 1 ,             -- 数量
                    pathwayGroup = "Group_BCycle",           -- 线或线组
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

