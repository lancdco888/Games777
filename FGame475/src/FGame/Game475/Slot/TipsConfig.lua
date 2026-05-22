local M = {
    ["tbStart"] = {
        url = "ui://Game475/selectspin",
        animation = false,
        showNum = false,
    }, 
    ["tb3"] = {
        url = "ui://Game475/specialcount3",
        animation = true,
        showNum = false,
        -- music = "SND_GrandStrike"
    }, 
    ["tb2"] = {
        url = "ui://Game475/specailcount2",
        animation = false,
        showNum = false,
    }, 
    ["tb1"] = {
        url = "ui://Game475/specailcount",
        animation = false,
        showNum = false,
    }, 
    ["tbEnd"] = {
        url = "ui://Game475/specialendtitle",
        animation = false,
        showNum = false,
    }, 

    ["win"] = {
        url = "ui://Game475/specialendwin",
        animation = false,
        showNum = true,
    }, 

    ["freecount"] = {
        url = "ui://Game475/freecount",
        animation = false,
        showNum = false,
        scale = vec2(0.7,0.7),
        freePosX = 600,
    }, 
    ["freeendbg"] = {
        url = "ui://Game475/freeendbg",
        animation = false,
        showNum = false,
    }, 
    
}

return M

