-- level/game120.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group_cs.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")
    FF_G.SetCsBonusType(3) --打死鱼彩金框的样式
    local scene1 = FishEventHelper.CreateScene(305)
    local scene2 = FishEventHelper.CreateScene(57)
    local scene3 = FishEventHelper.CreateScene(50)
    --local scene4 = FishEventHelper.CreateScene(110)
    --local scene5 = FishEventHelper.CreateScene(935)
    --local scene6 = FishEventHelper.CreateScene(110)

    --场景1:电光水母306 场景6、大王乌贼305 场景9
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 103)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        --出小鱼跟随
        for i = 0.5, 300, 20 do                --出鱼的时间
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_1"],      -- 指定鱼组
                fishCount = {4,3},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,           --忘了，照着填吧
                pathwayGroup = "Group_cs_follow",  --鱼线
                speedScale = 2                 --速度
            })
        end
-- 出小鱼群： 
        for i = 10.5, 300, 20 do
            scene.AddFishBornEvent(i, {
            fish = fishGroup["fish118_14"],                       -- 指定鱼组
            fishCount = {10},                -- 鱼的数量
            offsets = {{0, 0},{30,50},{80,50},{130,50},{180,50},{150,0},{100,0},{50,0},{15,25},{165,25}}, --多鱼的时候位置偏移
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 0,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathwayGroup = "Group_cs_group",
            speedScale = 1.5                 --速度
            })
        end
        --出小鱼单条
        for i = 0, 300, 2 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_2"],      -- 指定鱼组
                fishTypeCount = 1,
                intervalTime = 0.5,
                pathwayGroup = "Group_cs_gfishL", 
                --pathway  = "line_cs_1",
            })
        end

        for i = 0, 300, 4 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_3"],      -- 指定鱼组
                fishTypeCount = 1,
                intervalTime = 0.5,
                pathwayGroup = "Group_cs_gfishR", 
                --pathway  = "line_cs_1",
            })
        end

        

        -- 出普通中型鱼
        for i = 12, 300, 16 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_4"],
                fishTypeCount = {4, 3},
                intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish2L",
            })
        end
        for i = 4, 300, 16 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_4"],
                fishTypeCount = {4, 3},
                intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish2R",
            })
        end

        -- 出普通大鱼 
        for i = 7.5, 300, 30 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_8"],
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3L",
            })
        end
        for i = 0.5, 300, 30 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_8"],
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3R",
            })
        end

        for i = 14.5, 300, 30 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_9"],
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_gfishL",
            })
        end
        for i = 22.5, 300, 30 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_9"],
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_gfishR",
            })
        end

         -- 出boss，打死了会补
         scene.AddRule(              --补鱼专用的函数
         {
         startTime = 5,          --开始时间
         endTime = 300,          --结束时间
         leaveCd = 0,            --自然离开后CD时间
         deathCd = 0,            --被捕获后的CD时间
         groupName = "fish120_1",        --鱼的id
         limit = 1,              --最多有几个同时在   
         }, 
         {
         fish = fishGroup["fish120_1"],             --鱼的ID
         fishTypeCount = {1},    --数量
         pathwayGroup= "Group_cs_boss", --鱼线
         }
     )
        --炸弹
        for i = 8, 300, 21 do
            scene.AddFishBornEvent(i, {
                fish = 20097,
                fishTypeCount = {1},
                pathwayGroup = "Group_cs_shadiansha",
                --offsetAngles = {math.pi / 2},
            })
        end

        --海藻
        for i = 7, 300, 15 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["haizao_53_1"],
                fishTypeCount = {1},
                intervalTime = 5,
                pathwayGroup = "Group_cs_gfish",
            })
        end

        -- 出旋风鱼
        for i = 10, 300, 20 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish120_2"],
                --fish = 30001,
                fishTypeCount = {1},
                pathwayGroup = "Group_cs_BCycle",
            })
        end

        -- 出组合鱼
        for i = 10, 300, 15 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish120_3"],
                --fish = 30001,
                fishTypeCount = {1},
                pathwayGroup = "Group_cs_gfishby",
            })
        end


    end
    
    --场景2:鱼阵1
    do
        
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 106)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

      

        --小黄虫
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
            fish = 10052,      
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
            fish = 10050,      
            fishCount = {3},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 16,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_33", 
            speedScale = 1
        })
        scene.AddFishBornEvent(14, {
            fish = 10041,      
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
            fish = 10052,      
            fishCount = {2},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_34", 
            speedScale = 1
        })
        scene.AddFishBornEvent(48, {
            fish = 10045,      
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
            fish = 10041,      
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_36", 
            speedScale = 1
        })
        scene.AddFishBornEvent(8, {
            fish = 10045,      
            fishCount = {5},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 9,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_35", 
            speedScale = 1
        })
        scene.AddFishBornEvent(5, {
            fish = 10038,      
            fishCount = {6},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 8,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ111_37", 
            speedScale = 1
        })
        
    end

    --场景3：鱼阵2
    do
        
        local scene = scene3
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 110)
        scene.AddSwitchBgMusicEvent(0, "bg_01")

        --刺鲨
        for i = 0, 46, 1 do
            scene.AddFishBornEvent(i, {
                fish = 10035,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB4",
                -- speedScale = 2.5
            })
        end
        for i = 0, 46, 1 do
            scene.AddFishBornEvent(i, {
                fish = 10035,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB8",
                -- speedScale = 2.5
            })
        end
        
        --黄金鲨鱼
        for i = 0, 55, 15 do
            scene.AddFishBornEvent(i, {
                fish = 10041,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB7",
                -- speedScale = 2.5
            })
        end
        for i = 0, 55, 15 do
            scene.AddFishBornEvent(i, {
                fish = 10041,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB3",
                -- speedScale = 2.5
            })
        end
        --白鲨
        for i = 5, 55, 15 do
            scene.AddFishBornEvent(i, {
                fish = 10045,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB7",
                -- speedScale = 2.5
            })
        end
        for i = 5, 55, 15 do
            scene.AddFishBornEvent(i, {
                fish = 10045,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB3",
                -- speedScale = 2.5
            })
        end

        --金鳄鱼
        for i = 10, 55, 15 do
            scene.AddFishBornEvent(i, {
                fish = 10095,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB7",
                -- speedScale = 2.5
            })
        end
        for i = 10, 55, 15 do
            scene.AddFishBornEvent(i, {
                fish = 10095,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB3",
                -- speedScale = 2.5
            })
        end


    end

    scene1.PushToGame(true)
    scene2.PushToGame(true)
    scene1.PushToGame(true)
    scene3.PushToGame(true)
    --scene4.PushToGame(true)
    --scene5.PushToGame(true)
    --scene6.PushToGame(true)

     
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

