local M = {
    {--
    index = 11,
    icon = "ui://Game353/sh1",
    zorder = 0,
    animation ="ui://Game353/buffaloanim",
    
    },
     {--
    index = 11,
    icon = "ui://Game353/sh2",
    zorder = 0,
    animation ="",
    
    }, 
    {--
       index = 11,
       icon = "ui://Game353/sh3",
       zorder = -1,
       animation ="",
    
    }, 
    {--
       index = 10,
       icon = "ui://Game353/sh4",
       zorder = 0,
       animation ="",
    
    }, 
    {--
       index = 9,
       icon = "ui://Game353/sh5",
       zorder = -1,
       animation ="",
    
    }, 
    {--
    icon = "ui://Game353/sl1",
    zorder = 2,
    animation ="",
    },

    {--
        icon = "ui://Game353/sl2",
        zorder = 2,
        animation ="",
    },
    {--
        icon = "ui://Game353/sl3",
        zorder = 2,
        animation ="",
    }, 
     {--
     icon = "ui://Game353/sl4",
     zorder = 0,
     animation ="",
    }, 
    {--
        icon = "ui://Game353/sl5",
        zorder = 0,
        animation ="",
    }, 
    {--
        index = 8,
        icon = "ui://Game353/sl6",
        animation ="",
        zorder = 0,
        

    }, 
    {--
        index = 11,
        icon = "ui://Game353/wild",
        zorder = 0,
        animation ="ui://Game353/wildanim",
        wild = true

    },
    {--
        index = 13,
        icon = "ui://Game353/ssc",
        zorder = 2,
        animation = "ui://Game353/sscanim2",
        ssc = true
    }, 
    {--
        index = 12,
        icon = "ui://Game353/jp",
        zorder = 10,
        animation ="ui://Game353/jpanim",
        LDRes = {
            [1] = { numShow = true, spriteFontShow = false, sprite1Url = "", sprite2Url = "" },
            [11] = {
                numShow = false,
                spriteFontShow = true,
                -- sprite1Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_mini",
                -- sprite2Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_bonus"
            },
            [12] = {
                numShow = false,
                spriteFontShow = true,
                -- sprite1Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_minor",
                -- sprite2Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_bonus"
            },
            [13] = {
                numShow = false,
                spriteFontShow = true,
                -- sprite1Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_major",
                -- sprite2Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_jackpot"
            },
            [14] = {
                numShow = false,
                spriteFontShow = true,
                -- sprite1Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_grand",
                -- sprite2Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_jackpot"
            },
            [88] = {
                numShow = false,
            },
            [99] = {
                numShow = false,
            },
        },
    }, 
}

return M

