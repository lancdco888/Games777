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

        for i = 1,1000, 1 do
            scene.AddFishBornEvent(i, {
                fish = 1,
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
        end
       
        scene.AddRule(
            {
                startTime =  1,
                endTime = 1200,
                -- cdTime = 3.5,
                leaveCd = 2,
                deathCd = 0,
                groupName = 213,
                limit = 1,
            },
            {
                fish = 213,
                fishTypeCount = 1,
                -- pathway= "line_1",
                pathwayGroup = "Group_mdy",
                createPrams = 
                    {
                        fadeInSecs = 5,             -- 淡入持续时间
                        fadeOutStartTime = 40,      -- 淡出开始时间
                        fadeOutSecs = 3,            -- 淡出持续时间
                        -- scaleInSec = 0.5,             -- 从小变大入场
                    },
            }
        )

        
    end 
       
    scene1.PushToGame(true)
    

    
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

