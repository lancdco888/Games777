local M = {
    ["tbStart"] = {
        url = "ui://Game336/selectspin",
        animation = false,
        showNum = false,
    }, 
    ["tb3"] = {
        url = "ui://Game336/specialcount3",
        animation = true,
        showNum = false,
        music = "SND_GrandStrike"
    }, 
    ["tb2"] = {
        url = "ui://Game336/specailcount2",
        animation = false,
        showNum = false,
    }, 
    ["tb1"] = {
        url = "ui://Game336/specailcount",
        animation = false,
        showNum = false,
    }, 
    ["tbEnd"] = {
        url = "ui://Game336/specialendtitle",
        animation = false,
        showNum = false,
    }, 

    ["win"] = {
        url = "ui://Game336/specialendwin",
        animation = false,
        winanimation = true,
        showNum = true,
    }, 
    ["freecount"] = {
        url = "ui://Game336/freecount",
        animation = false,
        showNum = false,
        scale = vec2(1,1),
        freePosX = 600,
    }, 
    ["freeendbg"] = {
        url = "ui://Game336/freeendbg",
        animation = false,
        scale = vec2(0.8,0.8),
        showNum = false,
    }, 
    
}

return M

