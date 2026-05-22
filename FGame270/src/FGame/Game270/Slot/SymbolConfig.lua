local Defined = Import("..Cfgs.Defined")

local M = {
    [1] = {
        icon = "wild", --WI
        zorder = 0,
        animation = "",
        wildRes = {
            [1] = {
                animIntro = "ui://" .. Defined.GameName .. "/Wild1UP_Loop",
                zorder = 98
            },
        },


        soundURL = "ui://" .. Defined.GameName .. "/SND_Wild",
        soundTime = 2,

        soundURLWin = "ui://" .. Defined.GameName .. "/SND_ExpandWin",
        soundWinTime = 2,

        soundURLNoWin = "ui://" .. Defined.GameName .. "/SND_ExpandNoWin",
        soundNoWinTime = 1,
    },
    [2] = {
        icon = "scatter", --SC
        zorder = 500,
        animation = "scatter_loop",
    },
    [3] = {
        icon = "ui://" .. Defined.GameName .. "/slots_symbol_denglong", --JP
        zorder = 2,
        animation = "",
        LDRes = {
            [1] = { numShow = true, spriteFontShow = false, sprite1Url = "", sprite2Url = "" },
            [2] = {
                numShow = false,
                spriteFontShow = true,
                sprite1Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_mini",
                sprite2Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_bonus"
            },
            [3] = {
                numShow = false,
                spriteFontShow = true,
                sprite1Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_minor",
                sprite2Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_bonus"
            },
            [4] = {
                numShow = false,
                spriteFontShow = true,
                sprite1Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_major",
                sprite2Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_jackpot"
            },
            [5] = {
                numShow = false,
                spriteFontShow = true,
                sprite1Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_grand",
                sprite2Url = "ui://" .. Defined.GameName .. "/slots_345_symbol_jackpot"
            }
        },
        keepInTopupBouns = true
    },
    [4] = {
        icon = "pic1", --佛图
        zorder = 0,
        -- animation = "ui://Game346/Ani_Sym_Wild",
        animation = "pic1_loop",
        fourSoundURL = "ui://" .. Defined.GameName .. "/SND_Pic1",
        soundTime = 2.5
    },
    [5] = {
        icon = "pic2", --布匹
        zorder = 0,
        animation = "pic2_loop",
        fourSoundURL = "ui://" .. Defined.GameName .. "/SND_Pic2",
        soundTime = 2.5
    },
    [6] = {
        icon = "pic3", --酒罐
        zorder = 0,
        animation = "pic3_loop",
        fourSoundURL = "ui://" .. Defined.GameName .. "/SND_Pic3",
        soundTime = 2.5
    },
    [7] = {
        icon = "pic4", --蝎子
        zorder = 0,
        animation = "pic4_loop",
        fourSoundURL = "ui://" .. Defined.GameName .. "/SND_Pic4",
        soundTime = 2.5
    },
    [8] = {
        icon = "ui://" .. Defined.GameName .. "/slots_345_sl1", --K
        zorder = 0,
        animation = "",
        needBlink = true,
    },
    [9] = {
        icon = "ui://" .. Defined.GameName .. "/slots_345_sl2", --Q
        zorder = 0,
        animation = "",
        needBlink = true,
    },
    [10] = {
        icon = "ui://" .. Defined.GameName .. "/slots_345_sl3", --J
        zorder = 0,
        animation = "",
        needBlink = true,
    },
    [11] = {
        icon = "ui://" .. Defined.GameName .. "/slots_345_sl4", --10
        zorder = 0,
        animation = "",
        needBlink = true,
    },
    [12] = {
        icon = "ui://" .. Defined.GameName .. "/slots_345_sl5", --9
        zorder = 0,
        animation = "",
        needBlink = true,
    }
}

return M
