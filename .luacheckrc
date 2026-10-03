std = "lua51"
max_line_length = false

globals = {
    "cc", "ccui", "sp", "fairygui", "gNet", "Device", "LoadChunksFromZIP",
    "BuildConfig", "ConfigParam", "Dispatcher", "SettingData", "LoginData",
    "Tools_Base", "BottomLayer", "LanguageLayer", "hotfixJson", "FacebookSingle",
    "LoginLayer", "ObjMgr", "TR", "ResetTranslator", "GetLang", "GetPackageName",
    "dump", "class", "import", "cclog", "DEBUG", "_G", "root_scene", "msgbox",
    "Scheduler", "EnterCasinoGame", "StartGameByGameId", "EnterLobbyPanel",
    "__G__TRACKBACK__", "printLog", "printError", "printInfo",
}

ignore = {
    "111", -- line length
    "113", -- accessing undefined field of global cc/gNet
    "122", -- setting read-only field
    "142", -- setting non-standard global
    "143", -- accessing undefined field
    "431", -- shadowing
    "432", -- shadowing
    "433", -- shadowing
    "611", -- line contains only whitespace
    "612", -- line contains trailing whitespace
    "613", -- trailing whitespace in string
    "621", -- inconsistent indentation
    "631", -- line is too long
}

exclude_files = {
    "scripts/dev/**",
}
