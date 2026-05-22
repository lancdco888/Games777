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
        
       
        for i = 0, 1000, 5 do
            for j = 1,8 do
                scene.AddFishBornEvent(i, {
                    fish = 1,
                    fishTypeCount = 1,
                    pathway="line_350",
                    subPathway = {
                        {
                            pathway = "line_348",
                            startTime = 0,
                            endTime = 30,
                            offsetTime = 0.4* j,
                            useAngle = true,
                            speed = 200,
                        },
                    },
                })
                scene.AddFishBornEvent(i, {
                    fish = 1,
                    fishTypeCount = 1,
                    pathway="line_350",
                    subPathway = {
                        {
                            pathway = "line_349",
                            startTime = 0,
                            endTime = 30,
                            offsetTime = 0.4 * j,
                            useAngle = true,
                            speed = 200,
                        },
                    },
                })
            end
            scene.AddFishBornEvent(i, {
                fish = 101,
                fishTypeCount = 1,
                pathway = "line_350",
                -- offsets = {{-20, -55}}, 
                speedScale = 1
            })
        end

        
    end 
       
    scene1.PushToGame(true)
    

    
end

InitTimeline()

--FF_G.TimeLineData = {
--    gameLoopTime = gameLoopTime,
--}

