
-- 公共UI主题

local FTheme = {}

-- @brief 设置当前主题配置
function FTheme.SetThemeCfg(cfg)
    local name = cfg.name

    if name == nil or FThemeType[name] == nil then
        name = FGameDefaultThemeName
    end

    -- 使用默认主题
    if name == nil or FThemeType[name] == nil then
        name = FThemeType.Lilac
    end
    
    -- 当前主题名称
    FTheme.curThemName = name
    -- 当前主题配置
    FTheme.curThemCfg  = cfg
    -- 当前主题FGUI包名称
    FTheme.curPkgName = "Theme_" .. name
    
	FairyGUI.UIPackage.AddPackage("Basics/Basics")
	FairyGUI.UIPackage.AddPackage(string.format("%s/%s", FTheme.curPkgName, FTheme.curPkgName))

    if name == "CrimsonCartoon" then
        -- 巴西语需要带前缀
        if FairyGUI.UIPackage.branch == "pt" then
            FTheme.curThemCfg.moneyTextPrefix = "R$"
        else
            FTheme.curThemCfg.moneyTextPrefix = ""
        end
        -- 需要显示小数
        FConfig.Common.GameScoreForceToInt = false
    end
end

function FTheme.Require(path)
    return require(string.format("FGame.Common.CommonUI.%s.%s", FTheme.curThemName, path))
end

return FTheme
