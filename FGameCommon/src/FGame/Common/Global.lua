if cc or ax then
    RUNTIME_IN_COCOS = true
elseif CREATOR then
    RUNTIME_IN_CREATOR = true
else
    RUNTIME_IN_UNITY = true
end

-- 使用h5协议
if RUNTIME_IN_CREATOR or RUNTIME_IN_COCOS_H5 then
    RUNTIME_USE_H5_PROTO = true
end

require("FGame.Common.Functions.Import")

Import(".Logic.Enums")

FConfig = {
    Debug = true,
    Common          = Import(".Cfgs.Common"),
    Lang            = Import(".Cfgs.Lang"),
    WinLineConfigs  = Import(".Cfgs.WinLineConfigs"),
}


-- class追踪器
ClassTracker = Import(".Utils.Tracker").New("class")

-- 常用函数导入
Import(".Functions.Misc")
Import(".Functions.Class")
Import(".Functions.Table")
-- 兼容层导入
Import(".Special.Init")

-- 缓动
Import(".Utils.Tween")
Import(".Utils.ToolSet")
Import(".Utils.EventEmitter")
Import(".Utils.IteratorExternal")

-- 常用基础类
---@type BaseGame
BaseGame = Import(".Base.BaseGame")
---@type BaseReel
BaseReel = Import(".Base.BaseReel")

-- FGUI功能部分主题
FTheme = Import(".FTheme")

-- 入口函数
Import(".Entry")
