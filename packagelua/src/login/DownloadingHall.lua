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

        local failedFunc = function(module_)
            print("update failed:" .. module_)
            done_hall = true
            result_hall = false
        end
        sDownloadMgr.FailedCallBack[module_] = failedFunc

        if not sDownloadMgr.StartDownloadTask(module_) then
            done_hall = true
            result_hall = false
        end
    end

    local done_packagelua = true
    local result_packagelua = true
    local update_packagelua = false
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
            update_packagelua = true
        end
        sDownloadMgr.EndCallBack[module_] = endFunc

        local failedFunc = function(module_)
            print("update failed:" .. module_)
            done_packagelua = true
            result_packagelua = false
        end
        sDownloadMgr.FailedCallBack[module_] = failedFunc

        if hotfixJson.ClearZipDone then
            hotfixJson:ClearZipDone(module_)
        end
        if not sDownloadMgr.StartDownloadTask(module_) then
            done_packagelua = true
            result_packagelua = false
        end
    end

    while not done_hall or not done_packagelua do
        coroutine.yield()
        SleepSecs(0.1)
    end

    if not tolua.isnull(loading_layer) then
        loading_layer:setRate(1.0)
        SleepSecs(0.4)

        loading_layer:setVisible(false)
    end

    if update_packagelua then
        ReLoadPackageLua()
    end
    return result_hall and result_packagelua
end
