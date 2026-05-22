local Game = import(".Game")
local cfGame = Game:new()

local game = {}

function game.start()
    cfGame:Start()
end

function game.exit()
end

return game
