local M = { -- 
    [1] = { -- 替代
        nodeNames ={
            Intro = "wildIntro",
            Loop = "wildLoop"
        },
        zorder = 2,
        isTop = true,
        soundURL = "ui://Game341/SND_Wild",
        soundTime = 3.5
    },
    [2] = { -- 免费
        nodeNames ={
            Intro = "scIntro",
            Loop = "scLoop"
        },
        zorder = 1,
        isTop = true,
    }, 
    [3] = { -- 灯笼 
        url = "ui://Game341/341_Corona",
        animUrl = "ui://Game341/Corona_00000",
        zorder = 1,
        isTop = true,
        keepInTopupBouns = true,
        LDRes = {
            [1] = {numShow = true, spriteFontShow = false, sprite1Url = "", sprite2Url = ""},
            [2] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game341/slots_341_symbol_mini", sprite2Url = "ui://Game341/slots_341_symbol_bonus"},
            [3] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game341/slots_341_symbol_minor", sprite2Url = "ui://Game341/slots_341_symbol_bonus"},
            [4] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game341/slots_341_symbol_major", sprite2Url = "ui://Game341/slots_341_symbol_jackpot"},
            [5] = {numShow = false, spriteFontShow = true, sprite1Url = "ui://Game341/slots_341_symbol_grand", sprite2Url = "ui://Game341/slots_341_symbol_jackpot"},
        },
    }, 
    [4] = {
        url = "ui://Game341/341_laohu",
        animUrl = "ui://Game341/Pic1_0000",
        zorder = 0,
        isTop = true,
        fourSoundURL = "ui://Game341/SND_Pic1",
        soundTime = 2.5
    }, 
    [5] = {
        url = "ui://Game341/341_ji",
        animUrl = "ui://Game341/Pic2_0000",
        zorder = 0,
        isTop = true,
        fourSoundURL = "ui://Game341/SND_Pic2",
        soundTime = 2.5
    }, 
    [6] = {
        url = "ui://Game341/341_chuan",
        animUrl = "ui://Game341/Pic3_0000",
        zorder = 0,
        isTop = true,
        fourSoundURL = "ui://Game341/SND_Pic3",
        soundTime = 2.5
    }, 
    [7] = {
        url = "ui://Game341/341_hehua",
        animUrl = "ui://Game341/Pic4_0000",
        zorder = 0,
        isTop = true,
        fourSoundURL = "ui://Game341/SND_Pic4",
        soundTime = 2.5
    }, 

    [8] = {
        url = "ui://Game341/341_k",
        zorder = 0,
        needBlink = true,
        scale = vec2(0.9,0.9)
    }, 
    [9] = {
        url = "ui://Game341/341_q",
        zorder = 0,
        needBlink = true,
        scale = vec2(0.9,0.9)
    }, 
    [10] = {
        url = "ui://Game341/341_j",
        zorder = 0,
        needBlink = true,
        scale = vec2(0.9,0.9)
    }, 
    [11] = {
        url = "ui://Game341/341_10",
        zorder = 0,
        needBlink = true,
        scale = vec2(0.9,0.9)
    }, 
    [12] = {
        url = "ui://Game341/341_9",
        zorder = 0,
        needBlink = true,
        scale = vec2(0.9,0.9)
    }, 
}
M["name"] = {
    "wildIntro",
    "wildLoop",
    "scIntro",
    "scLoop"
}
return M

