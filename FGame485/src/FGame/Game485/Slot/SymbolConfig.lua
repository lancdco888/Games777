local M = {
    [10] = {--1 wild
        icon = "ui://Game485/SWD",
        zorder = 0,
        animation = "ui://Game485/Wild_anim",
    }, 
    [9] = {---2 bonus
        icon = "ui://Game485/Bonus_anim",
        zorder = 0,
        animation = "ui://Game485/Bonus_anim",
    }, 
    [11] = {--3 scatter
        icon = "ui://Game485/SSC",
        zorder = 0,
        animation = "ui://Game485/Scatter_anim",
        stopPlayName = "stop",
    }, 

    [0] = {--sh1
        icon = "ui://Game485/SH1",
        zorder = 0,
        animation = "ui://Game485/SH1_anim",
        showMaskInTopupBouns = true
    }, 
    [1] = {--sh2
        icon = "ui://Game485/SH2",
        zorder = 0,
        animation = "ui://Game485/SH2_anim",
        showMaskInTopupBouns = true
    },
    [2] = {--sh3
        icon = "ui://Game485/SH3",
        zorder = 0,
        animation = "ui://Game485/SH3_anim",
        showMaskInTopupBouns = true
    }, 


    [3] = {--A
        icon = "ui://Game485/SL1",
        zorder = 0,
        animation = "ui://Game485/SL1_anim",
        showMaskInTopupBouns = true
    },
    [4] = {--K
        icon = "ui://Game485/SL2",
        zorder = 0,
        animation = "ui://Game485/SL2_anim",
        showMaskInTopupBouns = true
    },
    [5] = {--Q
        icon = "ui://Game485/SL3",
        zorder = 0,
        animation = "ui://Game485/SL3_anim",
        showMaskInTopupBouns = true
    },
    [6] = {--J
        icon = "ui://Game485/SL4",
        zorder = 0,
        animation = "ui://Game485/SL4_anim",
        showMaskInTopupBouns = true
    }, 
    [7] = {--10
        icon = "ui://Game485/SL5",
        zorder = 0,
        animation = "ui://Game485/SL5_anim",
        showMaskInTopupBouns = true
    }, 
    [8] = {--9
        icon = "ui://Game485/SL6",
        zorder = 0,
        animation = "ui://Game485/SL6_anim",
        showMaskInTopupBouns = true,
        -- isBlink = true,
    }, 


    [113] = {--113 百变
        icon = "ui://Game485/SH1",
        zorder = 0,
        animation = "ui://Game485/SH1_anim",
    },
}

return M

