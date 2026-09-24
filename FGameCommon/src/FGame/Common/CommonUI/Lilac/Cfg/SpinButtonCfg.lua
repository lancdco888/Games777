local M = {}

-- 开启自动旋转时，spin 按钮图片配置
M.AutoSpinCfg = {
    [FGameMode.NORMAL] = {
        [FSpinStatus.SPIN]  = {
            pageName = "show_stop_auto",
            -- 可以退出自动模式
            can_exit_auto_mode = true,
        },
        [FSpinStatus.STOP]    = {
            pageName = "show_stop_auto",
            -- 可以退出自动模式
            can_exit_auto_mode = true,
        },
    },
    [FGameMode.FREE] = {
        [FSpinStatus.SPIN]  = {
            pageName = "spin_normal",
        },
        [FSpinStatus.STOP]    = {
            pageName = "stop_normal",
        },
    },
    [FGameMode.SPECIAL] = {
        [FSpinStatus.SPIN]  = {
            pageName = "spin_normal",
        },
        [FSpinStatus.STOP]    = {
            pageName = "stop_normal",
        },
    },
}
-- 未开启自动旋转时，spin 按钮图片配置
M.NormalSpinCfg = {
    [FGameMode.NORMAL] = {
        [FSpinStatus.SPIN]  = {
            pageName = "show_auto_spin",

            -- 可以进入自动模式
            can_enter_auto_mode = true,
        },
        [FSpinStatus.STOP]    = {
            pageName = "stop_normal",
        },
    },
    [FGameMode.FREE] = {
        [FSpinStatus.SPIN]  = {
            pageName = "spin_normal",
        },
        [FSpinStatus.STOP]    = {
            pageName = "stop_normal",
        },
    },
    [FGameMode.SPECIAL] = {
        [FSpinStatus.SPIN]  = {
            pageName = "spin_normal",
        },
        [FSpinStatus.STOP]    = {
            pageName = "stop_normal",
        },
    },
}

-- 如果是审核版本，则不使用自动旋转，且不能点击停止按钮
if FConfig.Common.IsReviewVersion then
    -- 未开启自动旋转时，spin 按钮图片配置
    M.NormalSpinCfg = {
        [FGameMode.NORMAL] = {
            [FSpinStatus.SPIN]  = {
                pageName = "spin_normal",
            },
            [FSpinStatus.STOP]    = {
                pageName = "spin_normal",
            },
        },
        [FGameMode.FREE] = {
            [FSpinStatus.SPIN]  = {
                pageName = "spin_normal",
            },
            [FSpinStatus.STOP]    = {
                pageName = "spin_normal",
            },
        },
        [FGameMode.SPECIAL] = {
            [FSpinStatus.SPIN]  = {
                pageName = "spin_normal",
            },
            [FSpinStatus.STOP]    = {
                pageName = "spin_normal",
            },
        },
    }
end

return M

