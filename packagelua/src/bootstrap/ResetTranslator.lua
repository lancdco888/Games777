function ResetTranslator()
    local lang_ = GetLang()

    if lang_ ~= 'cn' then
        Translator:clear()
        local file_ = "bootstrap/res/i18n/" .. "bootstrap_" .. lang_ .. ".json"
        file_ = cc.FileUtils:getInstance():fullPathForFilename(file_)
        if file_ ~= "" then
            Translator:addFile(file_)
        end

        -- https language
        local Langs = GetTranslate.Lang2HttpLang[lang_]
		local local_lang = "packagelua/res/i18n/{lang}.json"
		LoadHttpLang(local_lang, Langs)
    else
        Translator:clear()
    end
end

-- path : assets/src/{lang}.json
function LoadHttpLang(path, lang)
    if type(lang) == "table" then
        for __,language in ipairs(lang) do
            if not LoadHttpLang(path, language) then
                return false
            end
        end
        return true
    else
        local file_ = string.gsub(path, "{lang}", lang)
        local exists = cc.FileUtils:getInstance():isFileExist(file_)
        if not exists then
            return false
        end

        Translator:clear()
        Translator:addFile(file_)
        return true
    end
end
