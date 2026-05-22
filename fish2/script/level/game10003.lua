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
        scene.AddSwitchBgEvent(0, 11)   
        scene.AddSwitchBgMusicEvent(1, "bg_02")

        
        -- 持续时间段定义    
            local t1 = 60
        
           
        -- 旋转场景 八爪章鱼场景
            for i = 4, 1200, 60 do
                scene.AddSetPlayBgAnimEvent(i, "turn1")
                scene.AddSetPlayBgAnimEvent(i + 15, "turn2")
                scene.AddSetPlayBgAnimEvent(i + 30, "turn3")
                scene.AddSetPlayBgAnimEvent(i + 45, "turn4")
            end
    
            scene.AddRule(
                {
                    startTime =  1,
                    endTime = 1200,
                    cdTime = 3.5,
                    leaveCd = 0,
                    deathCd = 0,
                    groupName = 312, 
                    limit = 3,
                },
                {
                    fish = 312,      
                    fishTypeCount = 1,
                    pathway= "line_1",
                }
            )

        
    end 
       
    scene1.PushToGame(true)
    

    
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

