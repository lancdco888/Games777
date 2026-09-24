function DownloadingHall(loading_layer)
    local hall_module = "hall"
    local packagelua_module = "packagelua"

	if not sDownloadMgr.CheckModule(hall_module)
        and not sDownloadMgr.CheckModule(packagelua_module)
    then
        return true
	end

    loading_layer:setVisible(true)
    loading_layer:showLoading(true)
    loading_layer:setRate(0.0)

    local info = hotfixJson:GetServerInfosByModule(hall_module)
    local version = nil
    if info and info.version then
        version = info.version
        loading_layer:setTips(TR("正在更新大厅...") .. "(v" .. version .. ")")
    else
        loading_layer:setTips(TR("正在更新大厅..."))
    end

    local count = 0
    local done_hall = true
    local result_hall = true
    local percent_hall = 0
    local percent_packagelua = 0
    local last_p = 0
    if sDownloadMgr.CheckModule(hall_module) then
        local module_ = hall_module
        done_hall = false
        result_hall = false
        count = count + 1

        local updateFunc = function(module_)
            local p = sDownloadMgr.updateTask[module_].percent
            release_print("hall p:" .. p)
            if p > percent_hall then
                percent_hall = p
            end
            local percent = (percent_hall + percent_packagelua) / count
            if percent < last_p then
                percent = last_p
            end
            last_p = percent

            if not tolua.isnull(loading_layer) then
                loading_layer:setRate(percent / 100.0)
            end
        end

        sDownloadMgr.UpdatingCallBack[module_] = updateFunc
        local endFunc = function(module_)
            sDownloadMgr.UpdatingCallBack[module_] = nil
            print("update done:" .. module_)
            done_hall = true
            result_hall = true
        end
        sDownloadMgr.EndCallBack[module_] = endFunc
        sDownloadMgr.StartDownloadTask(module_)
    end

    local done_packagelua = true
    local result_packagelua = true
    if sDownloadMgr.CheckModule(packagelua_module) then
        local module_ = packagelua_module
        count = count + 1
        done_packagelua = false
        result_packagelua = false
        local updateFunc = function(module_)
            local p = sDownloadMgr.updateTask[module_].percent
            release_print("packagelua p:" .. p)
            if p > percent_packagelua then
                percent_packagelua = p
            end

            local percent = (percent_hall + percent_packagelua) / count
            if percent < last_p then
                percent = last_p
            end
            last_p = percent
            if not tolua.isnull(loading_layer) then
                loading_layer:setRate(percent / 100.0)
            end
        end

        sDownloadMgr.UpdatingCallBack[module_] = updateFunc
        local endFunc = function(module_)
            sDownloadMgr.UpdatingCallBack[module_] = nil
            print("update done:" .. module_)
            done_packagelua = true
            result_packagelua = true
            ReLoadPackageLua()
        end
        sDownloadMgr.EndCallBack[module_] = endFunc
        sDownloadMgr.StartDownloadTask(module_)
    end

    while not done_hall or not done_packagelua do
        coroutine.yield()
        SleepSecs(0.1)
    end

    if not tolua.isnull(loading_layer) then
        if last_p < 100 then
            loading_layer:setRate(1.0)
            SleepSecs(0.4)
        end

        loading_layer:setVisible(false)
    end
    return result_hall and result_packagelua
end

-- 更新资源之后重新刷新 packagelua 模块
function ReLoadPackageLua()
    package.loaded["packagelua.src.base.BaseInfo"] = nil
    package.loaded["packagelua.src.base.generic"] = nil
    package.loaded["packagelua.src.base.class_def"] = nil
    package.loaded["packagelua.src.base.client_login"] = nil
    package.loaded["packagelua.src.base.client_lobby"] = nil
    package.loaded["packagelua.src.base.Lobby_Slots"] = nil
    package.loaded["packagelua.src.base.SupportOther"] = nil
    package.loaded["packagelua.src.const_def"] = nil

    require "packagelua.src.base.BaseInfo"
    require "packagelua.src.base.generic"
    require "packagelua.src.base.class_def"
    require "packagelua.src.base.client_login"
    require "packagelua.src.base.client_lobby"
    require "packagelua.src.base.Lobby_Slots"
    require "packagelua.src.base.SupportOther"
    require("packagelua.src.const_def")

    package.loaded["packagelua.src.base.Device"] = nil
    Device = require("packagelua.src.base.Device")

    package.loaded["packagelua.src.base.Tools_Base"] = nil
    Tools_Base      = require("packagelua.src.base.Tools_Base")

    for k,v in pairs(_G) do
		if (string.find(k, "PKG_")) then
			if v.Create then
				local old = v.Create
				local Create = function(...)
					local o = old(...)
					o.__proto = v
					return o
				end
				v.Create = Create
			end
		end
	end
end
