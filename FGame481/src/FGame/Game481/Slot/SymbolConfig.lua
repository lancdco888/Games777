-- from 0
-- enum class SymbolType : uint8 {
    --  B1 0 皇冠,
    --  B2 1 沙漏,
    --  B3 2 戒指,
    --  B4 3 圣杯,
    --  A  4 红宝石,
    --  K  5 紫宝石,
    --  Q  6 黄宝石,
    --  J  7 绿宝石,
    --  10 8 蓝宝石,
    --  SC 9,
    --  JP 10
    --  End
--  };

local M = {
    [0] = {
        icon = "ui://Game481/huangguan",
        icon_bg = "",
        zorder = 0,
        animation = "ui://Game481/gool_hv_1_SkeletonData",
    }, 
    [1] = {
        icon = "ui://Game481/shalou",
        icon_bg = "",
        zorder = 0,
        animation = "ui://Game481/gool_hv_2_SkeletonData",
    }, 
    [2] = {
        icon = "ui://Game481/jiezhi",
        icon_bg = "",
        zorder = 0,
        animation = "ui://Game481/gool_hv_3_SkeletonData",
    }, 
    [3] = {
        icon = "ui://Game481/shengbei",
        icon_bg = "",
        zorder = 0,
        animation = "ui://Game481/gool_hv_4_SkeletonData",
    }, 
    [4] = {
        icon = "ui://Game481/hongbaoshi",
        icon_bg = "",
        zorder = 0,
        animation = "ui://Game481/gool_lv_1_orange_SkeletonData",
    },
    [5] = {
        icon = "ui://Game481/zibaoshi",
        icon_bg = "",
        zorder = 0,
        animation = "ui://Game481/gool_lv_2_purple_SkeletonData",
    }, 
    [6] = {
        icon = "ui://Game481/huangbaoshi",
        icon_bg = "",
        zorder = 0,
        animation = "ui://Game481/gool_lv_3_yellow_SkeletonData",
    }, 
    [7] = {
        icon = "ui://Game481/lvbaoshi",
        icon_bg = "",
        zorder = 0,
        animation = "ui://Game481/gool_lv_4_green_SkeletonData",
    }, 
    [8] = {
        icon = "ui://Game481/lanbaoshi",
        icon_bg = "",
        zorder = 0,
        animation = "ui://Game481/gool_lv_5_blue_SkeletonData",
    }, 
    [9] = {
        icon = "ui://Game481/sc",
        icon_bg = "",
        zorder = 0,
        animation = "ui://Game481/gool_scatter_fg_SkeletonData",
    }, 
    [10] = {
        icon = {
            "ui://Game481/beishu_green",
            "ui://Game481/beishu_blue",
            "ui://Game481/beishu_purple",
            "ui://Game481/beishu_red",
            "ui://Game481/beishu_diamond"
        },
        icon_bg = "",
        zorder = 0,
        animation = {
            "ui://Game481/gool_wild_multiplier_SkeletonData",
            "ui://Game481/gaoo_1000_multiplier_SkeletonData"
        }
    }
}

return M