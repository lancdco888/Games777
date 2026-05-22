local GetTranslate = class("GetTranslate")

GetTranslate.Lang2HttpLang={
    -------------- tools/update_src_lang/ 需要该行做标记，请不要删除 --------------------------------
    cn    =   "zh_CN",
    en    =   "en",
    ind   =   "id",
    mm    =   "my2",
    tha   =   "th",
    vn    =   "vi",
    -------------- tools/update_src_lang/ 需要该行做标记，请不要删除 --------------------------------
    bd   =   "bd",
    bg    =   "bg",
	da    =   "da",
    de    =   "de",
    es    =   "es",
    fr    =   "fr",
    ina   =   "hi",
    it    =   "it",
    ja    =   "ja",
    ko    =   "ko",
    nl    =   "nl",
    ph    =   "phl",
    pt    =   "pt",
    tc    =   "zh_TW",
}

function GetTranslate:RequireTR()
end

return GetTranslate
