-- level/game101.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group_cs.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")
    FF_G.SetCsBonusType(4) --打死鱼彩金框的样式
    local scene1 = FishEventHelper.CreateScene(310)
    local scene2 = FishEventHelper.CreateScene(55)
    local scene3 = FishEventHelper.CreateScene(60)
    --local scene4 = FishEventHelper.CreateScene(110)
    --local scene5 = FishEventHelper.CreateScene(935)
    --local scene6 = FishEventHelper.CreateScene(110)

    --场景1:羊鳄大战随机刷鱼
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 106)   
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
        --小鱼
        for i = 0.1, 300, 4 do
            scene.AddFishBornEvent(i, {
                fish = {10002,10004,10006,10010,10011,10015,10034,10035,10037},      -- 指定鱼组
                fishTypeCount = 2,
                pathwayGroup = "Group_cs_follow",
            })
        end
        for i = 3.1, 300, 4 do
            scene.AddFishBornEvent(i, {
                fish = {10002,10004,10006,10010,10011,10015,10034,10035,10037},      -- 指定鱼组
                fishTypeCount = 2,
                pathwayGroup = "Group_cs_gfishR",
            })
        end
        --出中鱼
        for i = 0.1, 300, 4.5 do
            scene.AddFishBornEvent(i, {
                fish = {10013,10042,10018,10039},      -- 指定鱼组
                fishTypeCount = 2,
                pathwayGroup = "Group_cs_gfishL",
            })
        end
        --中鱼
        for i = 0, 300, 7 do
            scene.AddFishBornEvent(i, {
                fish = {10013,10042,10018,10039},
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3R",
            })
        end
        --出大鱼
        for i = 1.1, 300, 4 do
            scene.AddFishBornEvent(i, {
                fish = {10016,10038,10041,10045},      -- 指定鱼组
                fishTypeCount = 1,
                pathwayGroup = "Group_cs_Cbfish",
            })
        end
        --旋风鱼
        for i = 8, 300, 18 do
            scene.AddFishBornEvent(i, {
                fish = {31151,31152,31153,31154,31155,31156,31157,31158,31159},
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3L",
            })
        end
        
        -- -- 出boss，打死了会补
        -- scene.AddRule(              --补鱼专用的函数
        --     {
        --     startTime = 5,          --开始时间
        --     endTime = 300,          --结束时间
        --     leaveCd = 0,            --自然离开后CD时间
        --     deathCd = 0,            --被捕获后的CD时间
        --     groupName = 10029,        --鱼的id
        --     limit = 1,              --最多有几个同时在   
        --     }, 
        --     {
        --     fish = 10029,             --鱼的ID
        --     fishTypeCount = 1,    --数量
        --     pathwayGroup= "Group_cs_boss", --鱼线
        --     }
        -- )
        -- scene.AddRule(              --补鱼专用的函数
        --     {
        --     startTime = 15,          --开始时间
        --     endTime = 300,          --结束时间
        --     leaveCd = 0,            --自然离开后CD时间
        --     deathCd = 0,            --被捕获后的CD时间
        --     groupName = 10072,        --鱼的id
        --     limit = 1,              --最多有几个同时在   
        --     }, 
        --     {
        --     fish = 10072,             --鱼的ID
        --     fishTypeCount = 1,    --数量
        --     pathwayGroup= "Group_cs_boss", --鱼线
        --     }
        -- )
        -- 炸弹鳄鱼
        scene.AddRule(
            {
            startTime = 10,
            endTime = 300,
            -- cdTime = 1,
            leaveCd = 0,
            deathCd = 15,
            groupName = 20073,
            -- mutex = true,
            limit = 1,
            }, 
            {
            fish = 20073,     
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

--场景2：------鱼阵-------------------
    do
     
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 110)
        scene.AddSwitchBgMusicEvent(0, "bg_01")


        scene.AddFishBornEvent(0, {
            fish = 10042,      -- 指定鱼组
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
            fish = 10042,      -- 指定鱼组
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
            fish = 10042,      -- 指定鱼组
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
            fish = 10042,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {4},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 4,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ112_4", 
            speedScale = 0.7
        })
        scene.AddFishBornEvent(17, {
            fish = 10045,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {4},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 6,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ112_5", 
            speedScale = 0.7
        })
        scene.AddFishBornEvent(17, {
            fish = 10041,      -- 指定鱼组
            fishTypeCount = {1},
            fishCount = {4},          -- 鱼的数量
            fishTypeCount = 1,              -- 鱼类型数量
            intervalTime = 6,             -- 两条鱼的间隔时间
            lineCount = 1,                  -- 固定选一条鱼线
            fixedFishType = true,
            pathway = "line_cs_YZ112_6", 
            speedScale = 0.7
        })
    end
--场景3：------鱼阵：-------------------
do
     
    local scene = scene3
    scene.PushFishGroups(fishGroup)
    scene.AddSwitchBgEvent(0, 110)
    scene.AddSwitchBgMusicEvent(0, "bg_01")

        --白鲨
        for i = 0, 60, 8 do
            scene.AddFishBornEvent(i, {
                fish = 10045,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB13",
                -- speedScale = 2.5
            })
        end
        for i = 0, 60, 8 do
            scene.AddFishBornEvent(i, {
                fish = 10045,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB14",
                -- speedScale = 2.5
            })
        end
        for i = 4, 60, 8 do
            scene.AddFishBornEvent(i, {
                fish = 10045,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB10",
                -- speedScale = 2.5
            })
        end
        --小黄虫
        for i = 0, 57, 0.6 do
            scene.AddFishBornEvent(i, {
                fish = 10004,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_121YB1",
                -- speedScale = 2.5
            })
        end
        for i = 0, 57, 0.6 do
            scene.AddFishBornEvent(i, {
                fish = 10004,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_121YB2",
                -- speedScale = 2.5
            })
        end
        for i = 0, 57, 0.6 do
            scene.AddFishBornEvent(i, {
                fish = 10004,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_121YB3",
                -- speedScale = 2.5
            })
        end
        for i = 0, 57, 0.6 do
            scene.AddFishBornEvent(i, {
                fish = 10004,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_121YB4",
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

