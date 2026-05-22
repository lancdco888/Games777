function GetLang()
    local lang_
    if Tools_Base and Tools_Base.Languages then
        if SettingData and SettingData.language and Tools_Base.Languages[SettingData.language] and Tools_Base.Languages[SettingData.language].name then
            lang_ = Tools_Base.Languages[SettingData.language].name
            -- print("Tools_Base.Languages")
        end
    elseif ConfigParam and ConfigParam.Language then
        lang_ = ConfigParam.Language[ConfigParam.default_Language]
    end

    if not lang_ or lang_ == "" then
        print("Default Language")
        lang_ = "en"
    end
    return lang_
end
