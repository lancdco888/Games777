local patched = cc.UserDefault:getInstance():getBoolForKey("_PATCH_FOR_GETTRANSLATE_", false)
if patched then return end
cc.UserDefault:getInstance():setBoolForKey("_PATCH_FOR_GETTRANSLATE_", true)

go(function()
	local utils = require("bootstrap.src.utils")
	local req_http_data = utils.req_http_data
	utils.req_http_data = function(url, on_success, on_failed)
		if string.find(url, "translate.bet/api/getTranslate") then
			print("PATCHED TRASNLATE, quit it.")
			return
		end
		return req_http_data(url, on_success, on_failed)
	end
	SleepSecs(30)
	-- 等待所有重试都超时，然后恢复
	utils.req_http_data = req_http_data
end)
