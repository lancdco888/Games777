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
        
       
        scene.AddRule(
            {
                startTime =  1,
                endTime = 1200,
                -- cdTime = 3.5,
                leaveCd = 2,
                deathCd = 0,
                groupName = 336, 
                limit = 1,
            },
            {
                fish = 336,      
                fishTypeCount = 1,
                -- pathway= "line_1",
                pathwayGroup = "Group_niu",
            }
        )

        
    end 
       
    scene1.PushToGame(true)
    

    
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

