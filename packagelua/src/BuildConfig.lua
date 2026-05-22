-- 新老包兼容
BuildConfig = BuildConfig or {}

-- 是否显示登陆界面的 facebook 按钮
function BuildConfig.IsShowLoginFaceBookButton()
    if BuildConfig.ShowLoginFaceBookButton == nil then
        return true
    end
    return BuildConfig.ShowLoginFaceBookButton
end

return BuildConfig
