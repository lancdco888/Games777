-- action/boss_come.lua
local this, lua, root = ...

if not FF_G.IsServer then
    lua:Set_onEvent(function(eventId)
        print("event id:", eventId)
        if eventId == 1201 then
            local id = FF_G.playEffect("jingbao", true)
            FF_G.AddTimerTask(3.0, function(id)
                FF_G.stopEffect(id)
            end, id)
        end
    end)
end
