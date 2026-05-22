local Defined = Import("..Cfgs.Defined")

local M = {
    ["tbStart"] = {
        url = "ui://" .. Defined.GameName .. "/selectspin",
        animation = false,
        showNum = false
    },
    ["tb3"] = {
        url = "ui://" .. Defined.GameName .. "/specialcount3",
        animation = true,
        showNum = false,
        music = "SND_GrandStrike"
    },
    ["tb2"] = {
        url = "ui://" .. Defined.GameName .. "/specailcount2",
        animation = false,
        showNum = false
    },
    ["tb1"] = {
        url = "ui://" .. Defined.GameName .. "/specailcount",
        animation = false,
        showNum = false
    },
    ["tbEnd"] = {
        url = "ui://" .. Defined.GameName .. "/specialendtitle",
        animation = false,
        showNum = false
    },
    ["win"] = {
        url = "ui://" .. Defined.GameName .. "/specialendwin",
        animation = false,
        showNum = true
    },
    ["freecount"] = {
        url = "ui://" .. Defined.GameName .. "/freecount",
        animation = false,
        showNum = false,
        scale = vec2(0.8, 0.8),
        freePosX = 600
    },
    ["freeendbg"] = {
        url = "ui://" .. Defined.GameName .. "/freeendbg",
        animation = false,
        showNum = false
    }
}

return M
