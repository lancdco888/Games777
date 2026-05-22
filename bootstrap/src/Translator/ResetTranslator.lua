function ResetTranslator()
    lang_ = GetLang()
    if lang_ ~= 'cn' then
        Translator:clear()
        local file_ = "bootstrap/res/i18n/" .. "bootstrap_" .. lang_ .. ".json"
        file_ = cc.FileUtils:getInstance():fullPathForFilename(file_)
        if file_ ~= "" then
            Translator:addFile(file_)
        end
    else
        Translator:clear()
    end
end
