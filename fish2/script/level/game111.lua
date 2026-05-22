-- level/game111.lua
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
    local scene4 = FishEventHelper.CreateScene(55)
    -- local scene5 = FishEventHelper.CreateScene(935)
    -- local scene6 = FishEventHelper.CreateScene(110)

    
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 106)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        
             
        
        
        -- 出boss-循环出-随机二选一
         for i = 10, 300, 13 do
            scene.AddFishBornEvent(i, {
                fish = {10060,10062,10061,12018},      -- 指定鱼组
                fishTypeCount = {1},
                intervalTime = 1,
                pathwayGroup = "Group_cs_boss",
            })
            
        end
        --     scene.AddRule(
        --         {
        --         startTime = 20,
        --         endTime = 300,
        --         -- cdTime = 0,
        --         leaveCd = 0,
        --         deathCd = 0,
        --         groupName = 10060,  
        --         limit = 1,
        --         }, 
        --         {
        --         fish = 10060,      
        --         fishTypeCount = {1}, 
        --         pathwayGroup= "Group_cs_special",
        --         }
        --     )
        -- scene.AddRule(
        --         {
        --         startTime = 10,
        --         endTime = 300,
        --         -- cdTime = 0,
        --         leaveCd = 0,
        --         deathCd = 0,
        --         groupName = "fish_111_Boss",  
        --         limit = 1,
        --         }, 
        --         {
        --         fish = fishGroup["fish_111_Boss"],      
        --         fishTypeCount = {1}, 
        --         pathwayGroup= "Group_cs_boss",
        --         }
        --     )
      
        
        
        -- 出小鱼跟随
            for i = 2, 300, 24 do
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
            for i = 14, 300, 24 do
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
            for i = 3, 300, 16 do
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
        
            for i = 4, 300, 14 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_L"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish3L",
                })
            end
            for i = 11, 300, 14 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_L"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish3R",
                })
            end
            
               
        -- 出组合鱼：
        
        for i = 28, 300, 13 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish_111_cb"],      -- 指定鱼组
                fishTypeCount = {1},
                intervalTime = 4,
                pathwayGroup = "Group_cs_Cbfish",
            })
        end
        
            
            
        -- 炸弹
            for i = 18, 300, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_111_Bomb"],
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
            
            for i = 10, 300, 24 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_111_cyc"],
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
        scene.AddSwitchBgEvent(0, 117)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")






        scene.AddFishBornEvent(1, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_1", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_2", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_3", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0.5, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_4", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_5", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_6", 
            speedScale = 1
        })
        scene.AddFishBornEvent(3, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_7", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2.5, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_8", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_9", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_10", 
            speedScale = 1
        })
        scene.AddFishBornEvent(3, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_11", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_12", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_13", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2.5, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_14", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_15", 
            speedScale = 1
        })scene.AddFishBornEvent(3, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_16", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_17", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_18", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_19", 
            speedScale = 1
        })
        scene.AddFishBornEvent(3, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_20", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2.5, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_21", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_22", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_23", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_24", 
            speedScale = 1
        })
        scene.AddFishBornEvent(2.5, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_25", 
            speedScale = 1
        })
        scene.AddFishBornEvent(3, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_26", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_27", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_28", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10004,      -- 指定鱼组
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_29", 
            speedScale = 1
        })
        scene.AddFishBornEvent(1.5, {
            fish = 10004,      -- 指定鱼组
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
            fish = 10062,      
            fishCount = {1},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 1,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_32", 
            speedScale = 1
        })
        scene.AddFishBornEvent(7, {
            fish = 10038,      
            fishCount = {7},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 7,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_32", 
            speedScale = 1
        })
        scene.AddFishBornEvent(6, {
            fish = 10061,      
            fishCount = {3},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 16,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_33", 
            speedScale = 1
        })
        scene.AddFishBornEvent(14, {
            fish = 10062,      
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
            fish = 10045,      
            fishCount = {2},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_34", 
            speedScale = 1
        })
        scene.AddFishBornEvent(48, {
            fish = 10060,      
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
            fish = 10060,      
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_36", 
            speedScale = 1
        })
        scene.AddFishBornEvent(8, {
            fish = 10038,      
            fishCount = {5},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_35", 
            speedScale = 1
        })
        scene.AddFishBornEvent(5, {
            fish = 10045,      
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_37", 
            speedScale = 1
        })
        
    end









    do
        
        local scene = scene3
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 106)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        
             
        
        -- 出boss
            
            scene.AddRule(
                {
                startTime = 20,
                endTime = 300,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = 10060,  
                limit = 1,
                }, 
                {
                fish = 10060,      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_cs_special",
                }
            )
        scene.AddRule(
                {
                startTime = 10,
                endTime = 300,
                -- cdTime = 0,
                leaveCd = 0,
                deathCd = 0,
                groupName = "fish_111_Boss",  
                limit = 1,
                }, 
                {
                fish = fishGroup["fish_111_Boss"],      
                fishTypeCount = {1}, 
                pathwayGroup= "Group_cs_boss",
                }
            )
      
        
        
        -- 出小鱼跟随
            for i = 2, 300, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_S"],      -- 指定鱼组
                    fishCount = {4,5,3},          -- 鱼的数量
                    fishTypeCount = 1,              -- 鱼类型数量
                    intervalTime = 2,             -- 两条鱼的间隔时间
                    lineCount = 1,                  -- 固定选一条鱼线
                    fixedFishType = true,
                    pathwayGroup = "Group_cs_follow",
                })
            end
            
        -- 出小鱼群：
            for i = 5, 300, 20 do
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
            for i = 0, 300, 5 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_S"],      -- 指定鱼组
                    fishTypeCount = {3, 2},
                    intervalTime = 1.5,
                    pathwayGroup = "Group_cs_fish1",
                })
            end
            

        -- 出普通中型鱼：
            for i = 4, 300, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_M"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish2L",
                })
            end
            for i = 7, 300, 8 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_M"],
                    fishTypeCount = {4, 3},
                    intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish2R",
                })
            end
            
        
        -- 出普通大鱼：
        
            for i = 3, 300, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_L"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish3L",
                })
            end
            for i = 7, 300, 15 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_1_L"],
                    fishTypeCount = {1},
                    -- intervalTime = 2.5,
                    pathwayGroup = "Group_cs_fish3R",
                })
            end
            
               
        -- 出组合鱼：
        
        for i = 28, 300, 8 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish_111_cb"],      -- 指定鱼组
                fishTypeCount = {1,2},
                intervalTime = 4,
                pathwayGroup = "Group_cs_Cbfish",
            })
        end
        
            
            
        -- 炸弹
            for i = 18, 300, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_111_Bomb"],
                    fishTypeCount = {1},
                    pathwayGroup = "Group_cs_shadiansha",
                    --offsetAngles = {math.pi / 2},
                })
            end

        
        --海藻
        for i = 7, 300, 15 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["haizao_53_1"],
                fishTypeCount = {1,2},
                intervalTime = 5,
                pathwayGroup = "Group_cs_gfish",
            })
        end
            
            
        
            
        -- 出旋风鱼
            
            for i = 10, 300, 20 do
                scene.AddFishBornEvent(i, {
                    fish = fishGroup["fish_111_cyc"],
                    --fish = 30001,
                    fishTypeCount = {1},
                    pathwayGroup = "Group_cs_BCycle",
                })
            end

    end
        --场景4:鱼阵
    do
        
        local scene = scene4
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 117)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        --------- 鱼阵109-2 -8条斜线，组成菱形----------------------
        scene.AddFishBornEvent(0, {
            fish = 10061,      -- 指定鱼组
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
            fish = 10062,      -- 指定鱼组
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
            fish = 10060,      -- 指定鱼组
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
    scene4.PushToGame(true)
    -- scene5.PushToGame(true)
    -- scene6.PushToGame(true)

     
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

