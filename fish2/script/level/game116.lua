-- level/game119.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group_cs.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")
    FF_G.SetCsBonusType(2) --打死鱼彩金框的样式
    local scene1 = FishEventHelper.CreateScene(310)
    local scene2 = FishEventHelper.CreateScene(60)
    --local scene3 = FishEventHelper.CreateScene(310)
    local scene4 = FishEventHelper.CreateScene(60)
    --local scene5 = FishEventHelper.CreateScene(935)
    --local scene6 = FishEventHelper.CreateScene(110)

    --场景1:海盗船随机刷鱼
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 115)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")
        --海草
        for i = 7, 300, 15 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["haizao_53_1"],
                fishTypeCount = {1},
                intervalTime = 5,
                pathwayGroup = "Group_cs_gfish",
            })
        end
        --出小鱼
        for i = 0.1, 300, 9 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_1"],      -- 指定鱼组
                fishTypeCount = {4,3},
                intervalTime = 0.5,
                pathwayGroup = "Group_cs_follow", 
                --pathway  = "line_cs_1",
            })
        end

        for i = 3, 300, 9 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_2"],      -- 指定鱼组
                fishTypeCount = 1,
                intervalTime = 0.5,
                pathwayGroup = "Group_cs_gfishL", 
                --pathway  = "line_cs_1",
            })
        end
        
        for i = 6, 300, 9 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_3"],      -- 指定鱼组
                fishTypeCount = 1,
                intervalTime = 0.5,
                pathwayGroup = "Group_cs_gfishR", 
                --pathway  = "line_cs_1",
            })
        end

        -- 出普通中型鱼
        for i = 3, 300, 16 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_4"],
                fishTypeCount = {4, 3},
                intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish2L",
            })
        end
        for i = 11, 300, 16 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_4"],
                fishTypeCount = {4, 3},
                intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish2R",
            })
        end

        -- 出普通大鱼
        for i = 9, 300, 14 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_8"],
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3L",
            })
        end
        
        for i = 2, 300, 14 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_9"],
                fishTypeCount = 2,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_gfishR",
            })
        end
        --出海豚
        for i = 10, 300, 17 do
            scene.AddFishBornEvent(i, {
                fish = 10009,
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_gfishR",
            })
        end
        --出组合鱼
        for i = 0, 300, 16 do
            scene.AddFishBornEvent(i, {
                fish = {10009,12021,12022,12023,12024,12025,12026,12027,12028,12029},
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3R",
            })
        end
        --出旋风鱼
        for i = 8, 300, 20 do
            scene.AddFishBornEvent(i, {
                fish = {31161,31162,31163,31164,31165,31166,31167},
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_gfishL",
            })
        end
        -- 出boss-循环出-随机选一
        for i = 10, 300, 14 do
            scene.AddFishBornEvent(i, {
                fish = {10047,12030},      -- 指定鱼组
                fishTypeCount = {1},
                intervalTime = 1,
                pathwayGroup = "Group_cs_boss",
            })
            
        end
    --      -- 出boss鳄鱼，打死了会补
    --      scene.AddRule(              --补鱼专用的函数
    --      {
    --      startTime = 5,          --开始时间
    --      endTime = 300,          --结束时间
    --      leaveCd = 0,            --自然离开后CD时间
    --      deathCd = 0,            --被捕获后的CD时间
    --      groupName = 10047,        --鱼的id
    --      limit = 1,              --最多有几个同时在   
    --      }, 
    --      {
    --      fish = 10047,             --鱼的ID
    --      fishTypeCount = {1},       --数量
    --      pathwayGroup= "Group_cs_boss", --鱼线
    --      }
    --     )
    --     -- 出boss船，打死了会补
    --     scene.AddRule(              --补鱼专用的函数
    --     {
    --     startTime = 15,          --开始时间
    --     endTime = 300,          --结束时间
    --     leaveCd = 0,            --自然离开后CD时间
    --     deathCd = 0,            --被捕获后的CD时间
    --     groupName = 12030,        --鱼的id
    --     limit = 1,              --最多有几个同时在   
    --     }, 
    --     {
    --     fish = 12030,             --鱼的ID
    --     fishTypeCount = {1},       --数量
    --     pathwayGroup= "Group_cs_boss", --鱼线
    --     }
    --    )
        --定时炸弹
        
        scene.AddRule(
            {
            startTime = 10,
            endTime = 300,
            -- cdTime = 1,
            leaveCd = 0,
            deathCd = 15,
            groupName = 20059,
            -- mutex = true,
            limit = 1,
            }, 
            {
            fish = 20059,     
            fishTypeCount = {1}, 
            pathwayGroup= "Group_cs_Cbfish",
            }
        )
        -- 出跟随： 
        for i = 0, 300, 24 do                --出鱼的时间
            scene.AddFishBornEvent(i, {
                fish = {10004,10011},      -- 指定鱼组
                fishCount = {4,5},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0.7,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,           --忘了，照着填吧
                pathwayGroup = "Group_cs_BCycle",  --鱼线
            })
        end
        -- 出小鱼群： 
        for i = 12, 300, 24 do
            scene.AddFishBornEvent(i, {
            fish = 10004,                       -- 指定鱼组
            fishCount = {5},                -- 鱼的数量
            offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 0,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathwayGroup = "Group_cs_Carb",
            })
        end
        -- -- 出小鱼群： 
        -- for i = 2.5, 300, 20 do
        --     scene.AddFishBornEvent(i, {
        --     fish = 10011,                       -- 指定鱼组
        --     fishCount = {5},                -- 鱼的数量
        --     offsets = {{0, 0}, {50, 0}, {-50, 0}, {0, 50}, {0, -50}}, --多鱼的时候位置偏移
        --     fishTypeCount = 1,              -- 鱼类型数量
        --     intervalTime = 0,             -- 两条鱼的间隔时间
        --     lineCount = 1,                  -- 固定选一条鱼线
        --     fixedFishType = true,
        --     pathwayGroup = "Group_cs_lxfollow",
        --     })
        -- end

    end

--场景2：------鱼阵：-------------------
    do
        
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 113)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        
        scene.AddFishBornEvent(0, {
            fish = 10006,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {45},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 1,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_1", 
            speedScale = 1
        })
        scene.AddFishBornEvent(0, {
            fish = 10006,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {45},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 1,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_3", 
            speedScale = 1
        })
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
   

--场景4：------鱼阵：快艇向前-------------------
    do
        
        local scene = scene4
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 113)
        scene.AddSwitchBgMusicEvent(0, "bg_01")
        
        --小黄虫
        for i = 0, 55, 1 do
            scene.AddFishBornEvent(i, {
                fish = 10004,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB2",
                -- speedScale = 2.5
            })
        end
        for i = 0, 55, 1 do
            scene.AddFishBornEvent(i, {
                fish = 10004,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB6",
                -- speedScale = 2.5
            })
        end

        --小绿鱼
        for i = 0, 55, 1 do
            scene.AddFishBornEvent(i, {
                fish = 10011,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB4",
                -- speedScale = 2.5
            })
        end
        for i = 0, 55, 1 do
            scene.AddFishBornEvent(i, {
                fish = 10011,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB8",
                -- speedScale = 2.5
            })
        end
        
        --金鲨1
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
        --银鲨2
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

        --鳄鱼
        for i = 10, 55, 15 do
            scene.AddFishBornEvent(i, {
                fish = 10071,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB7",
                -- speedScale = 2.5
            })
        end
        for i = 10, 55, 15 do
            scene.AddFishBornEvent(i, {
                fish = 10071,      -- 指定鱼组
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
    scene4.PushToGame(true)
    --scene5.PushToGame(true)
    --scene6.PushToGame(true)

     
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

