local M = {
    [1] = {--1-替代
        icon = "ui://Game336/slots_336_wild",
        zorder = 0,
        animation = "",
        -- loaderScale = vec2(1, 1),
        wildRes = {
            [1] = {animIntro = "ui://Game336/Wild1UP_Intro_00000", animLoop = "ui://Game336/Wild1UP_Loop_00000", zorder = 98},
            [2] = {animIntro = "ui://Game336/Wild2UP_Intro_00000", animLoop = "ui://Game336/Wild2UP_Loop_00000", zorder = 99},
            [3] = {animIntro = "ui://Game336/Wild3UP_Intro_0000", animLoop = "ui://Game336/Wild3UP_Loop_0000", zorder = 100},
        },
        loaderScale = vec2(1, 1.25),
        loaderpositionY = -36,
        soundURL = "ui://Game336/SND_Wild_%d"
        
        
    }, 
    [2] = {--2-灯笼
        icon = "ui://Game336/slots_336_symbol_denglong",
        zorder = 2,
        animation = "ui://Game336/Corona_00000",
        -- loaderScale = vec2(1, 1),
        -- SymbolType不同的显示
        LDRes = {
            [1] = {numShow = true, spriteFontShow = false, sprite1Url = "", sprite2Url = ""},
            [2] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game336/slots_336_symbol_mini", sprite2Url = "ui://Game336/slots_336_symbol_bonus"},
            [3] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game336/slots_336_symbol_minor", sprite2Url = "ui://Game336/slots_336_symbol_bonus"},
            [4] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game336/slots_336_symbol_major", sprite2Url = "ui://Game336/slots_336_symbol_jackpot"},
            [5] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game336/slots_336_symbol_grand", sprite2Url = "ui://Game336/slots_336_symbol_jackpot"},
        },
        keepInTopupBouns = true
    }, 
    [3] = {--3-免费
        icon = "ui://Game336/slots_336_ssc",
        zorder = 0,
        animation = "ui://Game336/Scat_Loop_0000",
        animScale = vec2(1.35, 1.35),
        animPosition = vec2(-50,-15),
        --loaderScale = vec2(1, 1.25),
        --loaderpositionY = -36,

    }, 
    [4] = {--4-兔子
        icon = "ui://Game336/slots_336_sh1",
        zorder = 0,
        animation = "ui://Game336/Pic1_0000",
        -- loaderScale = vec2(0.9, 0.9),
        fourSoundURL = "ui://Game336/SND_Pic1"
    }, 
    [5] = {--5-月饼
        icon = "ui://Game336/slots_336_sh2",
        zorder = 0,
        animation = "ui://Game336/Pic2_00000",
        -- loaderScale = vec2(0.9, 0.9),
        fourSoundURL = "ui://Game336/SND_Pic2"
    },
    [6] = {--6-扇子
        icon = "ui://Game336/slots_336_sh3",
        zorder = 0,
        animation = "ui://Game336/Pic3_00000",
        -- loaderScale = vec2(1.36, 1.2),
        fourSoundURL = "ui://Game336/SND_Pic3"
    }, 
    [7] = {--7-琵琶
        icon = "ui://Game336/slots_336_sh4",
        zorder = 0,
        animation = "ui://Game336/Pic4_00000",
       -- loaderScale = vec2(0.85, 0.85),
        fourSoundURL = "ui://Game336/SND_Pic4"
    }, 
    [8] = {--8-K
        index = 8,
        icon = "ui://Game336/slots_336_sl1",
        zorder = 0,
        animation = "",
        loaderScale = vec2(0.85, 0.85),

    }, 
    [9] = {--9-Q
        index = 9,
        icon = "ui://Game336/slots_336_sl2",
        zorder = 0,
        animation = "",
        loaderScale = vec2(0.85, 0.85),

    }, 
    [10] = {--10-J
        index = 10,
        icon = "ui://Game336/slots_336_sl3",
        zorder = 0,
        animation = "",
        loaderScale = vec2(0.85, 0.85),

    }, 
    [11] = {--11-10
        index = 11,
        icon = "ui://Game336/slots_336_sl4",
        zorder = 0,
        animation = "",
        loaderScale = vec2(0.85, 0.85),

    }, 
    [12] = {--12-9
        index = 12,
        icon = "ui://Game336/slots_336_sl5",
        zorder = 0,
        animation = "",
        loaderScale = vec2(0.85, 0.85),
    }, 
    
}

return M

