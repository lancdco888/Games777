local M = {
    [1] = {--1-替代
        icon = "ui://Game475/slots_321_wild",
        zorder = 0,
        animation = "",
        -- loaderScale = vec2(1, 1),
        wildRes = {
            [1] = {animIntro = "ui://Game475/Wild1UP_Intro_0000", animLoop = "ui://Game475/Wild1UP_Loop_0000", zorder = 98},
            [2] = {animIntro = "ui://Game475/Wild2UP_Intro_0000", animLoop = "ui://Game475/Wild2UP_Loop_0000", zorder = 99},
            [3] = {animIntro = "ui://Game475/Wild3UP_Intro_0000", animLoop = "ui://Game475/Wild3UP_Loop_0000", zorder = 100},
        },
        soundURL = "ui://Game475/SND_Wild_%d",
        soundTime = 3.5
    }, 
    [2] = {--2-灯笼
        icon = "ui://Game475/slots_321_symbol_denglong",
        zorder = 2,
        -- animation = "ui://Game475/Corona_00000",
        -- loaderScale = vec2(1, 1),
        -- SymbolType不同的显示
        LDRes = {
            [1] = {numShow = true, spriteFontShow = false, sprite1Url = "", sprite2Url = ""},
            [2] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game475/slots_321_symbol_mini"},
            [3] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game475/slots_321_symbol_minor"},
            [4] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game475/slots_321_symbol_major"},
            [5] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game475/slots_321_symbol_grand"},
        },
        keepInTopupBouns = true
    }, 
    [3] = {--3-免费
        icon = "ui://Game475/slots_321_ssc",
        zorder = 0,
        isSC = true,
        animation = "ui://Game475/Scatter_0000",
        -- loaderScale =, vec2(1, 1),

    }, 
    [4] = {--4-兔子
        icon = "ui://Game475/slots_321_sh1",
        zorder = 0,
        -- animation = "ui://Game475/Pic1_0000",
        -- loaderScale = vec2(0.9, 0.9),
        fourSoundURL = "ui://Game475/SND_Pic1",
        soundTime = 2.5,
        needBlink = true
    }, 
    [5] = {--5-月饼
        icon = "ui://Game475/slots_321_sh2",
        zorder = 0,
        -- animation = "ui://Game475/Pic2_Loop_0000",
        -- animations = {animIntro = "ui://Game475/Pic2_Intro_0000", animLoop = "ui://Game475/Pic2_Loop_0000", time = 39/60},
        -- loaderScale = vec2(0.9, 0.9),
        fourSoundURL = "ui://Game475/SND_Pic2",
        soundTime = 2.5,
        needBlink = true
    },
    [6] = {--6-扇子
        icon = "ui://Game475/slots_321_sh3",
        zorder = 0,
        -- animation = "ui://Game475/Pic3_0000",
        -- loaderScale = vec2(0.9, 0.9),
        fourSoundURL = "ui://Game475/SND_Pic3",
        soundTime = 2.5,
        needBlink = true
    }, 
    [7] = {--7-琵琶
        icon = "ui://Game475/slots_321_sh4",
        zorder = 0,
        -- animation = "ui://Game475/Pic4_Loop_0000",
        -- animations = {animIntro = "ui://Game475/Pic4_Intro_0000", animLoop = "ui://Game475/Pic4_Loop_0000", time = 9/60},
        -- loaderScale = vec2(0.9, 0.9),
        fourSoundURL = "ui://Game475/SND_Pic4",
        soundTime = 2.5,
        needBlink = true
    }, 
    [8] = {--8-K
        icon = "ui://Game475/slots_321_sl1",
        zorder = 0,
        animation = "",
        -- loaderScale = vec2(0.85, 0.85),
        needBlink = true
    }, 
    [9] = {--9-Q
        icon = "ui://Game475/slots_321_sl2",
        zorder = 0,
        animation = "",
        -- loaderScale = vec2(0.85, 0.85),
        needBlink = true
    }, 
    [10] = {--10-J
        icon = "ui://Game475/slots_321_sl3",
        zorder = 0,
        animation = "",
        -- loaderScale = vec2(0.85, 0.85),
        needBlink = true
    }, 
    [11] = {--11-10
        icon = "ui://Game475/slots_321_sl4",
        zorder = 0,
        animation = "",
        -- loaderScale = vec2(0.85, 0.85),
        needBlink = true
    }, 
    [12] = {--12-9
        icon = "ui://Game475/slots_321_sl5",
        zorder = 0,
        animation = "",
        -- loaderScale = vec2(0.85, 0.85),
        needBlink = true
    }, 
    [13] = {
        icon = "ui://Game475/slots_321_hidebg",
        zorder = 30,
        animation = "ui://Game475/Reveal_0000",
        -- loaderScale = vec2(1, 1),
    },
    
}

return M

