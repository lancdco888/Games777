-- level/game112.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group_cs.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")
    FF_G.SetCsBonusType(2) --打死鱼彩金框的样式
    local scene1 = FishEventHelper.CreateScene(305)
    local scene2 = FishEventHelper.CreateScene(60)
    local scene3 = FishEventHelper.CreateScene(305)
    local scene4 = FishEventHelper.CreateScene(60)
    -- local scene5 = FishEventHelper.CreateScene(935)
    -- local scene6 = FishEventHelper.CreateScene(110)

    
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 102)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        
             
        
        -- 出boss
        -- 出boss-循环出-随机二选一
        for i = 10, 300, 12 do
            scene.AddFishBornEvent(i, {
                fish = {10050,10052},      -- 指定鱼组
                fishTypeCount = {1},
                intervalTime = 1,
                pathwayGroup = "Group_cs_boss",
            })
            
        end
            -- scene.AddRule(
            --     {
            --     startTime = 10,
            --     endTime = 300,
            --     -- cdTime = 0,
            --     leaveCd = 0,
            --     deathCd = 0,
            --     groupName = 10050,  
            --     limit = 1,
            --     }, 
            --     {
            --     fish = 10050,      
            --     fishTypeCount = {1}, 
            --     pathwayGroup= "Group_cs_boss",
            --     }
            -- )
            -- scene.AddRule(
            --     {
            --     startTime = 15,
            --     endTime = 300,
            --     -- cdTime = 0,
            --     leaveCd = 0,
            --     deathCd = 0,
            --     groupName = 10052,  
            --     limit = 1,
            --     }, 
            --     {
            --     fish = 10052,      
            --     fishTypeCount = {1}, 
            --     pathwayGroup= "Group_cs_special",
            --     }
            -- )
      
        
        
        -- 出小鱼跟随
            for i = 2, 300, 24 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_S"],      -- 指定鱼组
                    fishCount = {4,5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_cs_follow",
                })
            end
            
        -- 出小鱼群：
            for i = 14, 300, 24 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish_2_S"],                       -- 指定鱼组
                fishCount = {5},                -- 鱼的数量
                offsets = {{0, 0}, {100, 0}, {-100, 0}, {0, 100}, {0, -100}}, --多鱼的时候位置偏移
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathwayGroup = "Group_cs_group",
                })
            end
            
            
        

        -- 出小鱼单条:
            for i = 0, 300, 6 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_S"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_cs_fish1",
                })
            end
            

        -- 出普通中型鱼：
            for i = 0, 300, 16 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_M"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish2L",
                })
            end
            for i = 8, 300, 16 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_M"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish2R",
                })
            end
            
        
        -- 出普通大鱼：
        
            for i = 7, 300, 16 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_L"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish3L",
                })
            end
            for i = 15, 300, 16 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_L"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish3R",
                })
            end

        -- 出黄金鱼：
        
            for i = 6, 300, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_112_Gold"],
                    fishTypeCount = {1,2},
                    intervalTime = 7.5,
                    pathwayGroup = "Group_cs_gfish",
                })
            end
            
            
               
        
        
            
            
        -- 炸弹
            for i = 18, 300, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_112_Bomb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_cs_shadiansha",
                    --offsetAngles = {math.pi / 2},
                })
            end

        
        --海藻
        for i = 7, 300, 15 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["haizao_53_2"],
                fishTypeCount = {1},
                intervalTime = 5,
                pathwayGroup = "Group_cs_gfish",
            })
        end
            
            
        
            
        -- 出旋风鱼
            
            for i = 10, 300, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_112_cyc"],
                    --fish = 30001,
                    fishTypeCount = {1},
                    pathwayGroup = "Group_cs_BCycle",
                })
            end

        end
            
        --场景2:鱼阵
    do
        
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 108)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")



        scene.AddFishBornEvent(0, {
            fish = 10064,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {4},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 4,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ112_1", 
            speedScale = 0.7
        })
        scene.AddFishBornEvent(0, {
            fish = 10064,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {4},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 4,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ112_2", 
            speedScale = 0.7
        })
        scene.AddFishBornEvent(0, {
            fish = 10064,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {4},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 4,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ112_3", 
            speedScale = 0.7
        })
        scene.AddFishBornEvent(0, {
            fish = 10064,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {4},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 4,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ112_4", 
            speedScale = 0.7
        })
        scene.AddFishBornEvent(18, {
            fish = 10056,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {4},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 7,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ112_5", 
            speedScale = 0.7
        })
        scene.AddFishBornEvent(18, {
            fish = 10056,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {4},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 7,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ112_6", 
            speedScale = 0.7
        })

    end
    do
        
        local scene = scene3
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 102)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        
             
        
        -- 出boss
            scene.AddRule(
                {
                startTime = 10,
                endTime = 300,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 10050,  
                limit = 1,
                }, 
                {
                fish = 10050,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_cs_boss",
                }
            )
            scene.AddRule(
                {
                startTime = 15,
                endTime = 300,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 10052,  
                limit = 1,
                }, 
                {
                fish = 10052,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_cs_special",
                }
            )
      
        
        
        -- 出小鱼跟随
            for i = 2, 300, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_S"],      -- 指定鱼组
                    fishCount = {4,5},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1.5,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_cs_follow",
                })
            end
            
        -- 出小鱼群：
            for i = 5, 300, 20 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish_2_S"],                       -- 指定鱼组
                fishCount = {5},                -- 鱼的数量
                offsets = {{0, 0}, {100, 0}, {-100, 0}, {0, 100}, {0, -100}}, --多鱼的时候位置偏移
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathwayGroup = "Group_cs_group",
                })
            end
            
            
        

        -- 出小鱼单条:
            for i = 0, 300, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_S"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_cs_fish1",
                })
            end
            

        -- 出普通中型鱼：
            for i = 0, 300, 10 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_M"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish2L",
                })
            end
            for i = 14, 300, 10 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_M"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish2R",
                })
            end
            
        
        -- 出普通大鱼：
        
            for i = 7, 300, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_L"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish3L",
                })
            end
            for i = 17, 300, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_2_L"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish3R",
                })
            end

        -- 出黄金鱼：
        
            for i = 6, 300, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_112_Gold"],
                    fishTypeCount = {2,3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_cs_gfish",
                })
            end
            
            
               
        
        
            
            
        -- 炸弹
            for i = 18, 300, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_112_Bomb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_cs_shadiansha",
                    --offsetAngles = {math.pi / 2},
                })
            end

        
        --海藻
        for i = 7, 300, 15 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["haizao_53_2"],
                fishTypeCount = {1,2},
                intervalTime = 5,
                pathwayGroup = "Group_cs_gfish",
            })
        end
            
            
        
            
        -- 出旋风鱼
            
            for i = 10, 300, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_112_cyc"],
                    --fish = 30001,
                    fishTypeCount = {1},
                    pathwayGroup = "Group_cs_BCycle",
                })
            end

        end
            
        --场景2:鱼阵
    do
        
        local scene = scene4
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 108)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        --------- 鱼阵109-2 -8条斜线，组成菱形----------------------
        scene.AddFishBornEvent(0, {
            fish = 10052,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {7},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_5", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0, {
            fish = 10022,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {9},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 6,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_6", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0, {
            fish = 10065,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {9},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 6,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_7", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0, {
            fish = 10068,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {9},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 6,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_8", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0.5, {
            fish = 10066,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {9},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 6,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_7c", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0.5, {
            fish = 10064,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {9},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 6,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_8c", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0.5, {
            fish = 10027,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {9},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 6,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_5c", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0, {
            fish = 10050,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {7},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ109_6c", 
            speedScale = 1
        })

    end
    scene1.PushToGame(true)
    scene2.PushToGame(true)
    scene1.PushToGame(true)
    scene4.PushToGame(true)
    -- scene5.PushToGame(true)
    -- scene6.PushToGame(true)
    
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

