local utils = {}

function utils.req_http_data(url, on_success, on_failed)
    local xhr = nil
    local jsondata = nil
    xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr.timeout = 4
    xhr:open("GET", url)
    xhr:registerScriptHandler(
        function ()
            xpcall(
                function()
                    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                        on_success(xhr.response)
                    else
                        on_failed()
                    end
                end,
                __G__TRACKBACK__
            )
        end
    )
    
    xhr:send()
end

function utils.write_file(file_path, data_)
   local dir_ = utils.get_parent_dir(file_path)
   if not cc.FileUtils:getInstance():isDirectoryExist(dir_) then
       cc.FileUtils:getInstance():createDirectory(dir_)
   end
   -- 创建新的文件
   local tmp_path = file_path .. ".tmp"
   -- local tmp_path = file_path
   local f = io.open(tmp_path, "wb")
   if not f then
       print("创建文件失败:" .. tmp_path)
       return false
   end

   -- 写入数据
   f:write(data_)
   f:close()

   return cc.FileUtils:getInstance():renameFile(tmp_path, file_path)
end

-- 不考虑目录
function utils.get_parent_dir(file_path)
   local pos = string.len(file_path)
   for i = string.len(file_path), 1, -1 do
       if string.sub(file_path, i, i) == "/" then
           pos = i
           break
       end
   end
   return string.sub(file_path, 1, pos)
end

-- 按钮是件
function utils.add_click_event(btn, handler)
    btn:addTouchEventListener(
        function(btn, type)
            if type == ccui.TouchEventType.began then
                btn:setScale(0.95)
            elseif type == ccui.TouchEventType.ended then
                -- gSound.clickSound()
                btn:setScale(1.0)
				if handler then handler() end
            elseif type == ccui.TouchEventType.canceled then
            	btn:setScale(1.0)
            elseif type == ccui.TouchEventType.moved then
                btn:setScale(0.95)
            end
		end
	)
end

function utils.show_msgbox(msg, on_confirm, on_cancel)
    local MsgBoxBaseLayer =  require("bootstrap.src.MsgBoxBaseLayer")
    msgbox = MsgBoxBaseLayer.new()
    return msgbox:ShowMsgBox(msg, on_confirm, on_cancel)
end

--------------------------------------------------------------

local entry = nil
local cos = {}
function utils.go(handler)
    if entry == nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        entry = scheduler:scheduleScriptFunc(
            utils.on_tick,
            0.01,
            false
        )
    end
    local co = coroutine.create(
        function()
            xpcall(handler, __G__TRACKBACK__)
        end
    )
    table.insert(cos, co)
end

function utils.on_tick()
    for i = #cos, 1, -1 do
        local co = cos[i]
        if coroutine.status(co) == "dead" then
            table.remove(cos, i)
        else
            local ok, msg = coroutine.resume(co)
            if not ok then
                print("coroutine.resume error:", msg)
            end
        end
    end
    if #cos == 0 then
        print("co is empty, kill scheduler")
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(entry)
        entry = nil
    end
end

return utils
