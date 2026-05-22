-- level/game102.lua
local root = ...

local FishEventHelper = FF_G.FishEventHelper
local fishGroup = FF_G.LoadLuaFunc("script/config/fish_group.lua")()

-- 初始化场景
local InitTimeline = function()
    print("Init timeline data")

    

    local scene1 = FishEventHelper.CreateScene(1300)
   

    
    do
        
        local scene = scene1
        scene.PushFishGroups(fishGroup)
        scene.AddSwitchBgEvent(0, 15)   
        scene.AddSwitchBgMusicEvent(1, "bg_02")


        for i = 1,1000, 10 do
            scene.AddFishBornEvent(i, {
                fish = 303,
                fishTypeCount = 1,
                pathway="line_411",
                subPathway = {
                    {
                        pathway = "line_348",
                        startTime = 0,
                        endTime = 30,
                        offsetTime = 0.4,
                        useAngle = true,
                        speed = 200,
                    },
                },
            })
            scene.AddFishBornEvent(i, {
                fish = 0,
                fishTypeCount = 1,
                pathway="line_411",
                subPathway = {
                    {
                        pathway = "line_349",
                        startTime = 0,
                        endTime = 30,
                        offsetTime = 0.4,
                        useAngle = true,
                        speed = 200,
                    },
                },
            })
        end

        scene.AddRule(
            {
                startTime =  1,
                endTime = 1200,
                -- cdTime = 3.5,
                leaveCd = 0,
                deathCd = 30,
                groupName = 201, 
                limit = 1,
            },
            {
                fish = 201,      
                fishTypeCount = 1,
                -- pathway= "line_1",
                pathwayGroup = "Group_Storm",
            }
        )

        
    end 
       
    scene1.PushToGame(true)
    

    
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

