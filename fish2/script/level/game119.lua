-- level/game119.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group_cs.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")
    FF_G.SetCsBonusType(2) --打死鱼彩金框的样式
    local scene1 = FishEventHelper.CreateScene(305)
    local scene2 = FishEventHelper.CreateScene(60)
    local scene3 = FishEventHelper.CreateScene(38)
    --local scene4 = FishEventHelper.CreateScene(60)
    --local scene5 = FishEventHelper.CreateScene(935)
    --local scene6 = FishEventHelper.CreateScene(110)

    --场景1：普通场景
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 101)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        --出小鱼跟随
        for i = 0, 300, 24 do                --出鱼的时间
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
        for i = 5, 300, 24 do
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
        for i = 0, 300, 3 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_2"],      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                pathwayGroup = "Group_cs_gfishL", 
                --pathway  = "line_cs_1",
            })
        end

        for i = 3, 300, 3 do
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
        for i = 7.9, 300, 28 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_8"],
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3L",
            })
        end
        for i = 0.9, 300, 28 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_8"],
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_fish3R",
            })
        end

        for i = 14.9, 300, 28 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish118_9"],
                fishTypeCount = 1,
                -- intervalTime = 2.5,
                pathwayGroup = "Group_cs_gfishL",
            })
        end
        for i = 21.9, 300, 28 do
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
         groupName = "fish119_1",        --鱼的id
         limit = 1,              --最多有几个同时在   
         }, 
         {
         fish = fishGroup["fish119_1"],             --鱼的ID
         fishTypeCount = {1},    --数量
         pathwayGroup= "Group_cs_boss", --鱼线
         }
     )
        --炸弹
        for i = 8, 300, 21 do
            scene.AddFishBornEvent(i, {
                fish = 20093,
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
                fish = fishGroup["fish119_2"],
                --fish = 30001,
                fishTypeCount = {1},
                pathwayGroup = "Group_cs_BCycle",
            })
        end

        -- 出组合鱼
        for i = 10, 300, 15 do
            scene.AddFishBornEvent(i, {
                fish = fishGroup["fish119_3"],
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
        scene.AddSwitchBgEvent(0, 107)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        

        --位移小丑鱼
        for j = 0, 60, 6 do
            for i = 0, 0 do
                scene.AddFishBornEvent(j, {
                    fish = 10002,      
                    fishTypeCount = 1,              
                    pathway = "line_cs_122YB11",
                    subPathway = {
                        {
                            pathway = "line_cs_122YB19",
                            startTime = 0,
                            endTime = 2,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 100 ,
                        },
                        {
                            pathway = "line_cs_122YB20",
                            startTime = 4.5,
                            endTime = 5.5,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 100 ,
                        },
                        {
                            pathway = "line_cs_122YB20_p",
                            startTime = 5.25,
                            endTime = 7.5,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 100 ,
                        },
                        {
                            pathway = "line_cs_122YB19",
                            startTime = 7.5,
                            endTime = 8.5,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 100 ,
                        },
                        {
                            pathway = "line_cs_122YB19_p",
                            startTime = 8.25,
                            endTime = 10.5,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 100 ,
                        }
                        
                    },
                    
                })
            end
        end
        for j = 0, 60, 6 do
            for i = 0, 0 do
                scene.AddFishBornEvent(j, {
                    fish = 10002,      
                    fishTypeCount = 1,              
                    pathway = "line_cs_122YB12",
                    subPathway = {
                        {
                            pathway = "line_cs_122YB21",
                            startTime = 0,
                            endTime = 2,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 100 ,
                        },
                        {
                            pathway = "line_cs_122YB22",
                            startTime = 4.5,
                            endTime = 5.5,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 100 ,
                        },
                        {
                            pathway = "line_cs_122YB20_p",
                            startTime = 5.25,
                            endTime = 7.5,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 100 ,
                        },
                        {
                            pathway = "line_cs_122YB21",
                            startTime = 7.5,
                            endTime = 8.5,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 100 ,
                        },
                        {
                            pathway = "line_cs_122YB21_p",
                            startTime = 8.25,
                            endTime = 10.5,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 100 ,
                        }
                       
                    },
                    
                })
            end
        end
        for j = 0.5, 60, 6 do
            for i = 0, 0 do
                scene.AddFishBornEvent(j, {
                    fish = 10002,      
                    fishTypeCount = 1,              
                    pathway = "line_cs_122YB11",
                    subPathway = {
                        {
                            pathway = "line_cs_122YB23",
                            startTime = 0,
                            endTime = 2,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 80 ,
                        },
                        {
                            pathway = "line_cs_122YB24",
                            startTime = 4,
                            endTime = 5,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 80 ,
                        },
                        {
                            pathway = "line_cs_122YB20_p",
                            startTime = 4.7,
                            endTime = 7,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 80 ,
                        },
                        {
                            pathway = "line_cs_122YB23",
                            startTime = 7,
                            endTime = 8,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 80 ,
                        },
                        {
                            pathway = "line_cs_122YB23_p",
                            startTime = 7.7,
                            endTime = 9,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 80 ,
                        }
                        
                    },
                    
                })
            end
        end
        for j = 0.5, 60, 6 do
            for i = 0, 0 do
                scene.AddFishBornEvent(j, {
                    fish = 10002,      
                    fishTypeCount = 1,              
                    pathway = "line_cs_122YB12",
                    subPathway = {
                        {
                            pathway = "line_cs_122YB25",
                            startTime = 0,
                            endTime = 2,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 80 ,
                        },
                        {
                            pathway = "line_cs_122YB26",
                            startTime = 4,
                            endTime = 5,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 80 ,
                        },
                        {
                            pathway = "line_cs_122YB20_p",
                            startTime = 4.7,
                            endTime = 7,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 80 ,
                        },
                        {
                            pathway = "line_cs_122YB25",
                            startTime = 7,
                            endTime = 8,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 80 ,
                        },
                        {
                            pathway = "line_cs_122YB25_p",
                            startTime = 7.7,
                            endTime = 9,
                            --offsetTime = 0.1 * i,
                            useAngle = false,
                            speed = 80 ,
                        }
                    }, 
                    
                })
            end
        end
        --中线小丑鱼
        for i = 1.5, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10002,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB10",
                -- speedScale = 2.5
            })
        end
        for i = 3, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10002,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB10",
                -- speedScale = 2.5
            })
        end
        --100位置小黄虫
        for i = 1.5, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10002,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB13",
                -- speedScale = 2.5
            })
        end
        for i = 1.5, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10002,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB14",
                -- speedScale = 2.5
            })
        end
        for i = 2, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10002,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB13",
                -- speedScale = 2.5
            })
        end
        for i = 2, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10002,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB14",
                -- speedScale = 2.5
            })
        end
        --80位置小丑鱼
        for i = 2.5, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10002,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB17",
                -- speedScale = 2.5
            })
        end
        for i = 2.5, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10002,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB18",
                -- speedScale = 2.5
            })
        end
        --40位置小丑鱼
        for i = 2.75, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10002,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB15",
                -- speedScale = 2.5
            })
        end
        for i = 2.75, 60, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10002,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB16",
                -- speedScale = 2.5
            })
        end
        --蝴蝶
        for i = 5, 57, 6 do
            scene.AddFishBornEvent(i, {
                fish = 10039,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_122YB10",
                -- speedScale = 2.5
            })
        end
        
    end
    
    --场景3：鱼阵2
    do
        
        local scene = scene3
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 107)   
        scene.AddSwitchBgMusicEvent(1, "09_bg1")

        --中心点-乌龟
        for i = 0, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB1",
                speedScale = 2
            })
        end
        for i = 0.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB2",
                speedScale = 2
            })
        end
        for i = 1, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB3",
                speedScale = 2
            })
        end
        for i = 1.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB4",
                speedScale = 2
            })
        end
        for i = 2, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB5",
                speedScale = 2
            })
        end
        for i = 2.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB6",
                speedScale = 2
            })
        end
        for i = 3, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB7",
                speedScale = 2
            })
        end
        for i = 3.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB8",
                speedScale = 2
            })
        end
        for i = 4, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB9",
                speedScale = 2
            })
        end
        for i = 4.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB10",
                speedScale = 2
            })
        end
        for i = 5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB12",
                speedScale = 2
            })
        end
        for i = 5.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB13",
                speedScale = 2
            })
        end
        for i = 6, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB14",
                speedScale = 2
            })
        end
        for i = 6.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB15",
                speedScale = 2
            })
        end
        for i = 7, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB16",
                speedScale = 2
            })
        end
        for i = 7.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB18",
                speedScale = 2
            })
        end
        for i = 8, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB19",
                speedScale = 2
            })
        end
        for i = 8.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB20",
                speedScale = 2
            })
        end
        for i = 9, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB21",
                speedScale = 2
            })
        end
        for i = 9.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB22",
                speedScale = 2
            })
        end
        for i = 10, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB23",
                speedScale = 2
            })
        end
        for i = 10.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB24",
                speedScale = 2
            })
        end
        for i = 11, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB25",
                speedScale = 2
            })
        end
        for i = 11.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB26",
                speedScale = 2
            })
        end
        for i = 12, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB27",
                speedScale = 2
            })
        end
        for i = 12.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB28",
                speedScale = 2
            })
        end
        for i = 13, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB29",
                speedScale = 2
            })
        end
        for i = 13.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB30",
                speedScale = 2
            })
        end
        for i = 14, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB31",
                speedScale = 2
            })
        end
        for i = 14.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB32",
                speedScale = 2
            })
        end
        for i = 15, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB33",
                speedScale = 2
            })
        end
        for i = 15.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB34",
                speedScale = 2
            })
        end
        for i = 16, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB35",
                speedScale = 2
            })
        end
        for i = 16.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB36",
                speedScale = 2
            })
        end
        for i = 17, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB37",
                speedScale = 2
            })
        end
        for i = 17.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB38",
                speedScale = 2
            })
        end
        --灰色鲽鱼
        for i = 18, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB1",
                speedScale = 2
            })
        end
        for i = 18.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB2",
                speedScale = 2
            })
        end
        for i = 19, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB3",
                speedScale = 2
            })
        end
        for i = 19.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB4",
                speedScale = 2
            })
        end
        for i = 20, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB5",
                speedScale = 2
            })
        end
        for i = 20.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB6",
                speedScale = 2
            })
        end
        for i = 21, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB7",
                speedScale = 2
            })
        end
        for i = 21.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB8",
                speedScale = 2
            })
        end
        for i = 22, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB9",
                speedScale = 2
            })
        end
        for i = 22.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB10",
                speedScale = 2
            })
        end
        for i = 23, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB12",
                speedScale = 2
            })
        end
        for i = 23.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB13",
                speedScale = 2
            })
        end
        for i = 24, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB14",
                speedScale = 2
            })
        end
        for i = 24.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB15",
                speedScale = 2
            })
        end
        for i = 25, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB16",
                speedScale = 2
            })
        end
        for i = 25.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB18",
                speedScale = 2
            })
        end
        for i = 26, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB19",
                speedScale = 2
            })
        end
        for i = 26.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB20",
                speedScale = 2
            })
        end
        for i = 27, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB21",
                speedScale = 2
            })
        end
        for i = 27.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB22",
                speedScale = 2
            })
        end
        for i = 28, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB23",
                speedScale = 2
            })
        end
        for i = 28.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB24",
                speedScale = 2
            })
        end
        for i = 29, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB25",
                speedScale = 2
            })
        end
        for i = 29.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB26",
                speedScale = 2
            })
        end
        for i = 30, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB27",
                speedScale = 2
            })
        end
        for i = 30.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB28",
                speedScale = 2
            })
        end
        for i = 31, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB29",
                speedScale = 2
            })
        end
        for i = 31.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB30",
                speedScale = 2
            })
        end
        for i = 32, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB31",
                speedScale = 2
            })
        end
        for i = 32.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB32",
                speedScale = 2
            })
        end
        for i = 33, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB33",
                speedScale = 2
            })
        end
        for i = 33.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB34",
                speedScale = 2
            })
        end
        for i = 34, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB35",
                speedScale = 2
            })
        end
        for i = 34.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB36",
                speedScale = 2
            })
        end
        for i = 35, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB37",
                speedScale = 2
            })
        end
        for i = 35.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB38",
                speedScale = 2
            })
        end

        --左侧点-乌龟
        for i = 0, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB39",
                speedScale = 2
            })
        end
        for i = 0.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB40",
                speedScale = 2
            })
        end
        for i = 1, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB41",
                speedScale = 2
            })
        end
        for i = 1.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB42",
                speedScale = 2
            })
        end
        for i = 2, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB43",
                speedScale = 2
            })
        end
        for i = 2.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB44",
                speedScale = 2
            })
        end
        for i = 3, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB45",
                speedScale = 2
            })
        end
        for i = 3.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB46",
                speedScale = 2
            })
        end
        for i = 4, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB47",
                speedScale = 2
            })
        end
        for i = 4.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB48",
                speedScale = 2
            })
        end
        for i = 5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB49",
                speedScale = 2
            })
        end
        for i = 5.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB50",
                speedScale = 2
            })
        end
        for i = 6, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB51",
                speedScale = 2
            })
        end
        for i = 6.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB52",
                speedScale = 2
            })
        end
        for i = 7, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB53",
                speedScale = 2
            })
        end
        for i = 7.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB54",
                speedScale = 2
            })
        end
        for i = 8, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB55",
                speedScale = 2
            })
        end
        for i = 8.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB56",
                speedScale = 2
            })
        end
        for i = 9, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB57",
                speedScale = 2
            })
        end
        for i = 9.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB58",
                speedScale = 2
            })
        end
        for i = 10, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB59",
                speedScale = 2
            })
        end
        for i = 10.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB60",
                speedScale = 2
            })
        end
        for i = 11, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB61",
                speedScale = 2
            })
        end
        for i = 11.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB62",
                speedScale = 2
            })
        end
        for i = 12, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB63",
                speedScale = 2
            })
        end
        for i = 12.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB64",
                speedScale = 2
            })
        end
        for i = 13, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB65",
                speedScale = 2
            })
        end
        for i = 13.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB66",
                speedScale = 2
            })
        end
        for i = 14, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB67",
                speedScale = 2
            })
        end
        for i = 14.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB68",
                speedScale = 2
            })
        end
        for i = 15, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB69",
                speedScale = 2
            })
        end
        for i = 15.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB70",
                speedScale = 2
            })
        end
        for i = 16, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB71",
                speedScale = 2
            })
        end
        for i = 16.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB72",
                speedScale = 2
            })
        end
        for i = 17, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB73",
                speedScale = 2
            })
        end
        for i = 17.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB74",
                speedScale = 2
            })
        end
        --灰色鲽鱼
        for i = 18, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB39",
                speedScale = 2
            })
        end
        for i = 18.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB40",
                speedScale = 2
            })
        end
        for i = 19, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB41",
                speedScale = 2
            })
        end
        for i = 19.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB42",
                speedScale = 2
            })
        end
        for i = 20, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB43",
                speedScale = 2
            })
        end
        for i = 20.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB44",
                speedScale = 2
            })
        end
        for i = 21, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB45",
                speedScale = 2
            })
        end
        for i = 21.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB46",
                speedScale = 2
            })
        end
        for i = 22, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB47",
                speedScale = 2
            })
        end
        for i = 22.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB48",
                speedScale = 2
            })
        end
        for i = 23, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB49",
                speedScale = 2
            })
        end
        for i = 23.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB50",
                speedScale = 2
            })
        end
        for i = 24, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB51",
                speedScale = 2
            })
        end
        for i = 24.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB52",
                speedScale = 2
            })
        end
        for i = 25, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB53",
                speedScale = 2
            })
        end
        for i = 25.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB54",
                speedScale = 2
            })
        end
        for i = 26, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB55",
                speedScale = 2
            })
        end
        for i = 26.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB56",
                speedScale = 2
            })
        end
        for i = 27, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB57",
                speedScale = 2
            })
        end
        for i = 27.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB58",
                speedScale = 2
            })
        end
        for i = 28, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB59",
                speedScale = 2
            })
        end
        for i = 28.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB60",
                speedScale = 2
            })
        end
        for i = 29, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB61",
                speedScale = 2
            })
        end
        for i = 29.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB62",
                speedScale = 2
            })
        end
        for i = 30, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB63",
                speedScale = 2
            })
        end
        for i = 30.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB64",
                speedScale = 2
            })
        end
        for i = 31, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB65",
                speedScale = 2
            })
        end
        for i = 31.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB66",
                speedScale = 2
            })
        end
        for i = 32, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB67",
                speedScale = 2
            })
        end
        for i = 32.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB68",
                speedScale = 2
            })
        end
        for i = 33, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB69",
                speedScale = 2
            })
        end
        for i = 33.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB70",
                speedScale = 2
            })
        end
        for i = 34, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB71",
                speedScale = 2
            })
        end
        for i = 34.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB72",
                speedScale = 2
            })
        end
        for i = 35, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB73",
                speedScale = 2
            })
        end
        for i = 35.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB74",
                speedScale = 2
            })
        end

        --右侧点-乌龟
        for i = 0, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB75",
                speedScale = 2
            })
        end
        for i = 0.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB76",
                speedScale = 2
            })
        end
        for i = 1, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB77",
                speedScale = 2
            })
        end
        for i = 1.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB78",
                speedScale = 2
            })
        end
        for i = 2, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB79",
                speedScale = 2
            })
        end
        for i = 2.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB80",
                speedScale = 2
            })
        end
        for i = 3, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB81",
                speedScale = 2
            })
        end
        for i = 3.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB82",
                speedScale = 2
            })
        end
        for i = 4, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB83",
                speedScale = 2
            })
        end
        for i = 4.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB84",
                speedScale = 2
            })
        end
        for i = 5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB85",
                speedScale = 2
            })
        end
        for i = 5.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB86",
                speedScale = 2
            })
        end
        for i = 6, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB87",
                speedScale = 2
            })
        end
        for i = 6.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB88",
                speedScale = 2
            })
        end
        for i = 7, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB89",
                speedScale = 2
            })
        end
        for i = 7.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB90",
                speedScale = 2
            })
        end
        for i = 8, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB91",
                speedScale = 2
            })
        end
        for i = 8.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB92",
                speedScale = 2
            })
        end
        for i = 9, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB93",
                speedScale = 2
            })
        end
        for i = 9.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB94",
                speedScale = 2
            })
        end
        for i = 10, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB95",
                speedScale = 2
            })
        end
        for i = 10.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB96",
                speedScale = 2
            })
        end
        for i = 11, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB97",
                speedScale = 2
            })
        end
        for i = 11.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB98",
                speedScale = 2
            })
        end
        for i = 12, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB99",
                speedScale = 2
            })
        end
        for i = 12.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB100",
                speedScale = 2
            })
        end
        for i = 13, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB101",
                speedScale = 2
            })
        end
        for i = 13.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB102",
                speedScale = 2
            })
        end
        for i = 14, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB103",
                speedScale = 2
            })
        end
        for i = 14.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB104",
                speedScale = 2
            })
        end
        for i = 15, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB105",
                speedScale = 2
            })
        end
        for i = 15.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB106",
                speedScale = 2
            })
        end
        for i = 16, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB107",
                speedScale = 2
            })
        end
        for i = 16.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB108",
                speedScale = 2
            })
        end
        for i = 17, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB109",
                speedScale = 2
            })
        end
        for i = 17.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10013,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB110",
                speedScale = 2
            })
        end
        --灰色鲽鱼
        for i = 18, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB75",
                speedScale = 2
            })
        end
        for i = 18.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB76",
                speedScale = 2
            })
        end
        for i = 19, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB77",
                speedScale = 2
            })
        end
        for i = 19.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB78",
                speedScale = 2
            })
        end
        for i = 20, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB79",
                speedScale = 2
            })
        end
        for i = 20.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB80",
                speedScale = 2
            })
        end
        for i = 21, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB81",
                speedScale = 2
            })
        end
        for i = 21.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB82",
                speedScale = 2
            })
        end
        for i = 22, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB83",
                speedScale = 2
            })
        end
        for i = 22.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB84",
                speedScale = 2
            })
        end
        for i = 23, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB85",
                speedScale = 2
            })
        end
        for i = 23.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB86",
                speedScale = 2
            })
        end
        for i = 24, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB87",
                speedScale = 2
            })
        end
        for i = 24.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB88",
                speedScale = 2
            })
        end
        for i = 25, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB89",
                speedScale = 2
            })
        end
        for i = 25.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB90",
                speedScale = 2
            })
        end
        for i = 26, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB91",
                speedScale = 2
            })
        end
        for i = 26.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB92",
                speedScale = 2
            })
        end
        for i = 27, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB93",
                speedScale = 2
            })
        end
        for i = 27.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB94",
                speedScale = 2
            })
        end
        for i = 28, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB95",
                speedScale = 2
            })
        end
        for i = 28.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB96",
                speedScale = 2
            })
        end
        for i = 29, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB97",
                speedScale = 2
            })
        end
        for i = 29.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB98",
                speedScale = 2
            })
        end
        for i = 30, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB99",
                speedScale = 2
            })
        end
        for i = 30.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB100",
                speedScale = 2
            })
        end
        for i = 31, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB101",
                speedScale = 2
            })
        end
        for i = 31.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB102",
                speedScale = 2
            })
        end
        for i = 32, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB103",
                speedScale = 2
            })
        end
        for i = 32.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB104",
                speedScale = 2
            })
        end
        for i = 33, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB105",
                speedScale = 2
            })
        end
        for i = 33.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB106",
                speedScale = 2
            })
        end
        for i = 34, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB107",
                speedScale = 2
            })
        end
        for i = 34.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB108",
                speedScale = 2
            })
        end
        for i = 35, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB109",
                speedScale = 2
            })
        end
        for i = 35.5, 60, 60 do
            scene.AddFishBornEvent(i, {
                fish = 10042,      -- 指定鱼组
                fishTypeCount = 1,
                --intervalTime = 0.5,
                --pathwayGroup = "Group_cs_follow", 
                pathway  = "line_cs_119YB110",
                speedScale = 2
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

