-- from 0
-- enum class SymbolType : uint8 {
    --  B1 0 钻石,
    --  B2 1 现钞,
    --  B3 2 硬币,
    --  B4 3 铃铛,
    --  B5 4 柠檬,
    --  B6 5 樱桃,
    --  B7 6 四叶草,
    --  A  7,
    --  K  8,
    --  Q  9,
    --  J  10,
    --  WI 11,
    --  SC 12,
    --  End
--  };

local M = {
    [0] = {
        icon = "ui://Game483/h_green",
        zorder = 0,
        blur = "ui://Game483/h_green_blur",
        desc = {100,60,15}
    }, 
    [1] = {
        icon = "ui://Game483/h_red",
        zorder = 0,
        blur = "ui://Game483/h_red_blur",
        desc = {80,40,10}
    }, 
    [2] = {
        icon = "ui://Game483/h_white",
        zorder = 0,
        blur = "ui://Game483/h_white_blur",
        desc = {60,20,8}
    }, 
    [3] = {
        icon = "ui://Game483/h_char_8",
        zorder = 0,
        blur = "ui://Game483/h_char_8_blur",
        desc = {40,15,6}
    }, 
    [4] = {
        icon = "ui://Game483/l_ball_5",
        zorder = 0,
        blur = "ui://Game483/l_ball_5_blur",
        desc = {20,10,4}
    },
    [5] = {
        icon = "ui://Game483/l_bamboo_5",
        zorder = 0,
        blur = "ui://Game483/l_bamboo_5_blur",
        desc = {20,10,4}
    }, 
    [6] = {
        icon = "ui://Game483/l_ball_2",
        zorder = 0,
        blur = "ui://Game483/l_ball_2_blur",
        desc = {10,5,2}
    }, 
    [7] = {
        icon = "ui://Game483/l_bamboo_2",
        zorder = 0,
        blur = "ui://Game483/l_bamboo_2_blur",
        desc = {10,5,2}
    }, 
    [8] = {
        node = "wildAnim",
        zorder = 1,
        desc = "Wild symbol substitutes for all symbols except Scatter symbol.",
    },
    [9] = {
        node = "scat",
        zorder = 1,
        desc = "3 Scatter symbols will trigger free spins.",
        inAnim = "scatIn",
        isSc = true
    }
}
M.nodes = {
    "wildAnim",
    "scat"
}
return M