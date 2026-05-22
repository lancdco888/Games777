-- level/game109.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group_cs.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")
    FF_G.SetCsBonusType(1) --打死鱼彩金框的样式
    local scene1 = FishEventHelper.CreateScene(305)
    local scene2 = FishEventHelper.CreateScene(50)
    local scene3 = FishEventHelper.CreateScene(50)
    --local scene4 = FishEventHelper.CreateScene(50)
    -- local scene5 = FishEventHelper.CreateScene(935)
    -- local scene6 = FishEventHelper.CreateScene(110)

    
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 106)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        
             
        
        -- 出boss-循环出-随机二选一
        for i = 10, 300, 12 do
            scene.AddFishBornEvent(i, {
                fish = {10051,10052},      -- 指定鱼组
                fishTypeCount = {1},
                intervalTime = 1,
                pathwayGroup = "Group_cs_boss",
            })
            
        end
            -- scene.AddRule(
            --     {
            --     startTime = 10,
            --     endTime = 55,
            --     cdTime = 1,
            --     leaveCd = 0,
            --     deathCd = 0,
            --     groupName = 10051,
            --     limit = 1,
            --     }, 
            --     {
            --     fish = 10051,      
            --     fishTypeCount = {1}, 
            --     pathwayGroup= "Group_cs_boss",
            --     }
            -- )
            -- scene.AddRule(
            --     {
            --     startTime = 60,
            --     endTime = 105,
            --     cdTime = 1,
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
            for i = 1, 300, 24 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_S"],      -- 指定鱼组
                    fishCount = {4,5,3},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_cs_follow",
                })
            end
            
        -- 出小鱼群：
            for i = 13, 300, 24 do
                scene.AddFishBornEvent(i, {
                fish = fishGroup["fish_1_S"],                       -- 指定鱼组
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
                    fish = fishGroup["fish_1_S"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_cs_fish1",
                })
            end
            

        -- 出普通中型鱼：
            for i = 4, 300, 16 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_M"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish2L",
                })
            end
            for i = 11, 300, 16 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_M"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish2R",
                })
            end
            
        
        -- 出普通大鱼：
        
            for i = 1, 300, 14 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_L"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish3L",
                })
            end
            for i = 8, 100, 14 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_L"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish3R",
                })
            end
            
               
       --出组合鱼：
        
            for i = 28, 300, 12 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_109_cb"],      -- 指定鱼组
                    fishTypeCount = {1},
                    intervalTime = 4,
                    pathwayGroup = "Group_cs_Cbfish",
                })
            end
            
        
            
            
        -- 炸弹
            for i = 18, 300, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_109_Bomb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_cs_shadiansha",
                    --offsetAngles = {math.pi / 2},
                })
            end

        
        --海藻
        for i = 7, 300, 16 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["haizao_53_1"],
                fishTypeCount = {1},
                intervalTime = 5,
                pathwayGroup = "Group_cs_gfish",
            })
        end
            
            
        
            
        -- 出旋风鱼
            
            for i = 10, 150, 24 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_109_cyc1"],                       -- 指定鱼组
                    fishCount = {2},                -- 鱼的数量
                    offsets = {{0, 85}, {0, -85}}, --多鱼的时候位置偏移
                    fishTypeCount = 2,              -- 鱼类型数量
                    intervalTime = 0,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = false,
                    pathwayGroup = "Group_cs_BCycle",
                })
            end
            for i = 175, 300, 24 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_109_cyc2"],                       -- 指定鱼组
                    fishCount = {2},                -- 鱼的数量
                    offsets = {{0, 85}, {0, -85}}, --多鱼的时候位置偏移
                    fishTypeCount = 2,              -- 鱼类型数量
                    intervalTime = 0,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = false,
                    pathwayGroup = "Group_cs_BCycle",
                })
            end
            

            


    end
    
    do
        
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 110)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")
         
        --------- 鱼阵109-1 -4横线，两边出小鱼，中间出大鱼----------------------
        for i = 0, 42, 1 do
                scene.AddFishBornEvent(i, {
                    fish = 10004,      -- 指定鱼组
                    fishTypeCount = {1},
                    fishCount = {1},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_cs_YZ109_1", 
                    speedScale = 1
                })
                scene.AddFishBornEvent(i, {
                    fish = 10004,      -- 指定鱼组
                    fishTypeCount = {1},
                    fishCount = {1},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 1,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathway = "line_cs_YZ109_2", 
                    speedScale = 1
                })
        end
        
            scene.AddFishBornEvent(3, {
                fish = 10038,      -- 指定鱼组
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
                fish = 10038,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {3},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 2.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_4", 
                speedScale = 1
            })
            scene.AddFishBornEvent(11, {
                fish = 10045,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {3},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 3.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_3", 
                speedScale = 1
            })
            scene.AddFishBornEvent(11, {
                fish = 10045,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {3},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 3.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_4", 
                speedScale = 1
            })
            scene.AddFishBornEvent(21.5, {
                fish = 10041,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {3},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 3.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_3", 
                speedScale = 1
            })
            scene.AddFishBornEvent(21.5, {
                fish = 10041,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {3},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 3.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_4", 
                speedScale = 1
            })
            scene.AddFishBornEvent(33, {
                fish = 10052,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {1},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 3.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_3", 
                speedScale = 1
            })
            scene.AddFishBornEvent(33, {
                fish = 10052,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {1},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 3.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_4", 
                speedScale = 1
            })
            scene.AddFishBornEvent(38.5, {
                fish = 10051,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {1},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 3.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_3", 
                speedScale = 1
            })
            scene.AddFishBornEvent(38.5, {
                fish = 10051,      -- 指定鱼组
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

    
    do
        
        local scene = scene3
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 110)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")
         
        --------- 鱼阵109-2 -8条斜线，组成菱形----------------------
            scene.AddFishBornEvent(0, {
                fish = 10052,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {6},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 8,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_5", 
                speedScale = 1
            })
            scene.AddFishBornEvent(0, {
                fish = 10041,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {8},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 6,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_6", 
                speedScale = 1
            })
            scene.AddFishBornEvent(0, {
                fish = 10045,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {8},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 6,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_7", 
                speedScale = 1
            })
            scene.AddFishBornEvent(0, {
                fish = 10038,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {8},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 6,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_8", 
                speedScale = 1
            })
            scene.AddFishBornEvent(0.5, {
                fish = 10016,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {8},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 6,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_7c", 
                speedScale = 1
            })
            scene.AddFishBornEvent(0.5, {
                fish = 10039,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {8},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 6,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_8c", 
                speedScale = 1
            })
            scene.AddFishBornEvent(0.5, {
                fish = 10018,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {8},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 6,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,
                pathway = "line_cs_YZ109_5c", 
                speedScale = 1
            })
            scene.AddFishBornEvent(0, {
                fish = 10051,      -- 指定鱼组
                fishTypeCount = {1},
                fishCount = {6},          -- 鱼的数量
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
    scene3.PushToGame(true)
    -- scene5.PushToGame(true)
    -- scene6.PushToGame(true)

     
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

