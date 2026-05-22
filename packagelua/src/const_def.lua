const_def = {}

--登录界面联系方式图标
const_def.ServiceList = {
    ["mm"] = "hall/res/lobby/viber.png",
    ["tha"] = "hall/res/lobby/line.png",
    ["ind"] = "hall/res/lobby/whatsapp.png",
    ["vn"] = "hall/res/lobby/zalo.png",
    ["ms"] = "hall/res/lobby/malaylinks.png",
    ["ina"] = "hall/res/lobby/malaylinks.png",
    ["Gha"] = "hall/res/lobby/whatsapp2.png",
    ["ngr"] = "hall/res/lobby/whatsapp.png",
    ["ph"] = "hall/res/lobby/viber.png",
    ["twn"] = "hall/res/lobby/line.png",
}

const_def.LangList = {
    cn = "简体中文",
    tc = "繁體中文",
    ko = "한국인",
    es = "Nigeria/Brasil",
    pt = "Português",
    da = "dansk",
    bg = "български",
    nl = "Nederlands",
    it = "Italiano",
    de = "Deutsch",
    fr = "Français",
    ja = "日本",
    en = "ENGLISH",
    ina = "हिन्दी",
    ind = "bahasa Indonesia",
    mm = "ဗမာစာ",
    ms = "Bahasa Melayu",
    tha = "ภาษาไทย",
    vn = "Tiếng Việt",
    ph = "PH",
    bd = "বেঙ্গল",         --孟加拉
}

-- 本地默认目录
const_def.DefaultPath = cc.FileUtils:getInstance():getDefaultResourceRootPath()

--下载根目录
const_def.WritablePath = cc.FileUtils:getInstance():getWritablePath() .. 'download/'
