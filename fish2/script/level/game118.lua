-- level/game118.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group_cs.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")
    FF_G.SetCsBonusType(5) --打死鱼彩金框的样式
    local scene1 = FishEventHelper.CreateScene(305)
    local scene2 = FishEventHelper.CreateScene(60)
    local scene3 = FishEventHelper.CreateScene(60)
    --local scene4 = FishEventHelper.CreateScene(110)
    --local scene5 = FishEventHelper.CreateScene(935)
    --local scene6 = FishEventHelper.CreateScene(110)

    --场景1:普通场景
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 110)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        --出小鱼跟随
        for i = 0.1, 300, 24 do                --出鱼的时间
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_1"],      -- 指定鱼组
                fishCount = {4,3,5},          -- 鱼的数量
                fishTypeCount = 1,              -- 鱼类型数量
                intervalTime = 0.5,             -- 两条鱼的间隔时间
                lineCount = 1,                  -- 固定选一条鱼线
                fixedFishType = true,           --忘了，照着填吧
                pathwayGroup = "Group_cs_follow",  --鱼线
                speedScale = 2                 --速度
            })
        end
        -- 出小鱼群： 
        for i = 12.1, 300, 24 do
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
        for i = 0.1, 300, 3 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_2"],      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                pathwayGroup = "Group_cs_gfishL", 
                --pathway  = "line_cs_1",
            })
        end

        for i = 3.1, 300, 3 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_3"],      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                pathwayGroup = "Group_cs_gfishR", 
                --pathway  = "line_cs_1",
            })
        end

        

        -- 出普通中型鱼
        for i = 12, 300, 16 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_4"],
                fishTypeCount = {2,3},
                intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish2L",
            })
        end
        for i = 4, 300, 16 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_4"],
                fishTypeCount = {2,3},
                intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish2R",
            })
        end

        -- 出普通大鱼
        for i = 0.1 , 300, 28 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_8"],
                fishTypeCount = 1,
                --intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3L",
            })
        end
        for i = 7.1, 300, 28 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_8"],
                fishTypeCount = 1,
                --intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3R",
            })
        end

        for i = 14.1, 300, 28 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_9"],
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_gfishL",
            })
        end
        for i = 21.1, 300, 28 do
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
         groupName = "fish118_10",        --鱼的id
         limit = 1,              --最多有几个同时在   
         }, 
         {
         fish = fishGroup["fish118_10"],             --鱼的ID
         fishTypeCount = {1},    --数量
         pathwayGroup= "Group_cs_boss", --鱼线
         }
     )

        --炸弹
        for i = 8, 300, 20 do
            scene.AddFishBornEvent(i, {
                fish = 20088,
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
                fish = fishGroup["fish118_11"],
                --fish = 30001,
                fishTypeCount = {1},
                pathwayGroup = "Group_cs_BCycle",
            })
        end

        -- 出组合鱼
        for i = 10, 300, 15 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_12"],
                --fish = 30001,
                fishTypeCount = {1},
                pathwayGroup = "Group_cs_gfishby",
            })
        end


    end

    --场景2:鱼阵
    do
        
        local scene = scene2
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 115)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        

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

    --场景3:鱼阵2
    do
        
        local scene = scene3
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 115)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        --灰色鲽鱼
        for i = 0, 60, 10 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB2",
                -- speedScale = 2.5
            })
        end
        for i = 0, 60, 10 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB6",
                -- speedScale = 2.5
            })
        end

        --蝴蝶
        for i = 2, 60, 10 do
            scene.AddFishBornEvent(i, {
                fish = 10039,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB2",
                -- speedScale = 2.5
            })
        end
        for i = 2, 60, 10 do
            scene.AddFishBornEvent(i, {
                fish = 10039,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB6",
                -- speedScale = 2.5
            })
        end
        --炸弹
        for i = 4, 60, 10 do
            scene.AddFishBornEvent(i, {
                fish = 20088,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB1",
                -- speedScale = 2.5
            })
        end
        --乌龟
        for i = 7, 60, 10 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB2",
                -- speedScale = 2.5
            })
        end
        for i = 7, 60, 10 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB6",
                -- speedScale = 2.5
            })
        end
        --小黄鱼
        for i = 0, 57, 1 do
            scene.AddFishBornEvent(i, {
                fish = 10006,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB3",
                -- speedScale = 2.5
            })
        end
        for i = 0, 57, 1 do
            scene.AddFishBornEvent(i, {
                fish = 10006,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB5",
                -- speedScale = 2.5
            })
        end
        for i = 0, 57, 1 do
            scene.AddFishBornEvent(i, {
                fish = 10006,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB7",
                -- speedScale = 2.5
            })
        end
        for i = 0, 57, 1 do
            scene.AddFishBornEvent(i, {
                fish = 10006,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB9",
                -- speedScale = 2.5
            })
        end
        --灯笼
        for i = 0, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10034,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB4",
                -- speedScale = 2.5
            })
        end
        for i = 0, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10034,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB8",
                -- speedScale = 2.5
            })
        end
        --灰色鲽鱼
        for i = 3, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB4",
                -- speedScale = 2.5
            })
        end
        for i = 3, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB8",
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

