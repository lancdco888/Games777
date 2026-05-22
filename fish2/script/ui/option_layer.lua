-- 选项设置界面
module("option_layer", package.seeall)

local layer = nil               -- 根节点
local btn_music = nil           -- 音乐
local btn_sound = nil           -- 音效
local btn_joystick = nil        -- 遥杆
local btn_notice = nil          -- 滚动报喜?
local btn_shadow = nil          -- 是否显示鱼影

function pop()
    layer = cc.CSLoader:createNode("csb/OptionLayer.csb")
    layer:enableNodeEvents()
    -- pop_layer(layer)
    local root = check_ui_root()
    root:addChild(layer)
    if not init() then
        print("init layer failed")
    end
    return layer
end

function init()
    if not layer then return false end
    -- 关闭按钮
    local btn_close = layer:findChild("btn_close")
    add_click_event(btn_close, on_close_clicked)
    adjust_layer()
    -- 音乐按钮
    btn_music = layer:findChild("btn_music")
    add_click_event(btn_music, on_music_clicked)
	local value = cc.UserDefault:getInstance():getBoolForKey("music", true)
    set_btn_on(btn_music, value)

    -- 音效按钮
    btn_sound = layer:findChild("btn_sound")
    add_click_event(btn_sound, on_sound_clicked)
	value = cc.UserDefault:getInstance():getBoolForKey("effect", true)
    set_btn_on(btn_sound, value)
    
    -- 遥杆按钮
    btn_joystick = layer:findChild("btn_joystick")
    add_click_event(btn_joystick, on_joystick_clicked)
    local showjoy = get_joy_show()
    set_btn_on(btn_joystick, showjoy)

    -- 客服按钮
    local btn_service = layer:findChild("btn_service")
    add_click_event(btn_service, on_service_clicked)

    -- 鱼种按钮
    local btn_fish = layer:findChild("btn_fish")
    add_click_event(btn_fish, on_fish_clicked)

    -- 炮台按钮
    local btn_canno = layer:findChild("btn_canno")
    add_click_event(btn_canno, on_canno_clicked)
    if FF_G.IsCSGaming then
        btn_canno:setVisible(false)
    end
    
    -- 离开按钮
    local btn_leave = layer:findChild("btn_leave")
    add_click_event(btn_leave, on_leave_clicked)

    -- 滚动报喜
    btn_notice = layer:findChild("btn_notice")
    add_click_event(btn_notice, on_notice_clicked)
    local value = get_notice_enabled()
    set_btn_on(btn_notice, value)

    -- 鱼影按钮
    btn_shadow = layer:findChild("btn_shadow")
    add_click_event(btn_shadow, on_shadow_clicked)
    if FF_G.IsCSGaming then
        btn_shadow:setVisible(false)
    end

    local value = get_fish_shadow()
    set_btn_on(btn_shadow, value)

    -- 测试按钮
    local btn_test = layer:findChild("btn_test")
    add_click_event(btn_test, on_test_clicked)

    -- 导出鱼数据按钮
    local btn_export_fish = layer:findChild("btn_export_fish")
    add_click_event(btn_export_fish, on_export_fish_clicked)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform or cc.PLATFORM_OS_MAC == targetPlatform then
        btn_test:setVisible(true)
        btn_export_fish:setVisible(true)
    else
        btn_test:setVisible(false)
        btn_export_fish:setVisible(false)
    end

    translate_ui()
    return true
end

function translate_ui()
    -- 控件与翻译 id 映射关系
    local map = {
        ["_lang_return"] = TR("返回"),
        ["_lang_service"] = TR("客服"),
        ["_lang_leave"] =  TR("返回大厅"),
        ["_lang_func"] =  TR("功能"),
        ["_lang_setting"] =  TR("设置"),
        ["_lang_fishes"] = TR("鱼种表"),
        ["_lang_canno"] = TR("炮台"),
        ["_lang_rolling"] = TR("滚动报喜"),
        ["_lang_shadow"] = TR("鱼影"),
        ["_lang_music"] = TR("音乐"),
        ["_lang_effect"] = TR("音效"),
        ["_lang_joystick"] = TR("摇杆")
    }
    for name, txt in pairs(map) do
        local node = layer:findChild(name)
        if node then
            node:setString(txt)
        end
    end
end

function adjust_layer()
    local bg = layer:findChild("bg")
    adjust_bg(bg)
    bg:setPosition(cc.p(0,0))
    local size = bg:getContentSize()
    local topbg = layer:findChild("topbg")
    topbg:setPosition(cc.p(0,size.height))
    local leftbg = layer:findChild("leftbg")
    leftbg:setPosition(cc.p(0,size.height-topbg:getContentSize().height+5))
    local midline = layer:findChild("midline")
    midline:setPosition(cc.p(size.width/2,size.height/2))
end

function on_close_clicked()
    print("on close clicked")
    -- close_layer(layer)
    layer:removeFromParent()
    layer = nil
end

function on_music_clicked()
    print("on music clicked")
    local on = get_btn_on(btn_music)
    local new_value = not on
    set_btn_on(btn_music, new_value)
    cc.UserDefault:getInstance():setBoolForKey("music", new_value)
    
    if new_value then
        FF_G.uiInfo.PlayCurrentBgMusic()
    else
        gSound.stopbgm()
    end
end

-- 按钮当前为打开 还是 关闭?
function get_btn_on(btn)
    local off = btn:findChild("off")
    if off then
        return not off:isVisible()
    end
    return true
end

-- 将按钮设置为 开 或者 关
function set_btn_on(btn, bOn)
    local off = btn:findChild("off")
    if off then
        if bOn then
            off:setVisible(false)
        else
            off:setVisible(true)
        end
    end
end

function on_sound_clicked()
    print("on sound clicked")
    local on = get_btn_on(btn_sound)
    local new_value = not on
    set_btn_on(btn_sound, new_value)
    if new_value then
    else
    end
	cc.UserDefault:getInstance():setBoolForKey("effect", new_value)
end

function on_joystick_clicked()
    print("on joystick clicked")
    local on = get_btn_on(btn_joystick)
    local value = not on
    set_joy_show(value)
    set_btn_on(btn_joystick, value)
end

function get_joy_show()
    if FF_G and FF_G.uiInfo and FF_G.uiInfo.showJoy then
        return FF_G.uiInfo.showJoy
    else
        return false
    end
end

function set_joy_show(show)
    if FF_G and FF_G.uiInfo and FF_G.uiInfo.onJoyVisibleChanged then
        FF_G.uiInfo.onJoyVisibleChanged(show)
        FF_G.uiInfo.showJoy = show
    else
        print("set joy show:" .. tostring(show))
    end
end

function on_service_clicked()
    print("on service clicked")
    local panel = require "hall.src.hallnew.layers.lobby.service.Panel_ServiceMail"
    panel.default_ui_type = ServiceMailLogic.SERVICE
    gStates_SetAsync(panel)
end

function on_fish_clicked()
    print("on fish clicked")
    fish_layer.pop()
end

function on_canno_clicked()
    print("on canno clicked")
    canno_layer.pop()
end

function on_leave_clicked()
    print("on leave clicked")
    FF_G.uiInfo.RequestExit()
end

function on_notice_clicked()
    print("on notice clicked")
    local on = get_btn_on(btn_notice)
    set_btn_on(btn_notice, not on)
    set_notice_enabled(not on)
end

function get_notice_enabled()
	return cc.UserDefault:getInstance():getBoolForKey("notice", true)
end

function set_notice_enabled(enable)
    print(" set_notice_enabled " .. tostring(enable))
	cc.UserDefault:getInstance():setBoolForKey("notice", enable)
	MarqueeLogic:SetVisible_(enable)
end

function on_shadow_clicked()
    print("on shadow clicked")
    local on = get_btn_on(btn_shadow)
    local value = not on
    if set_fish_shadow(value) then
        set_btn_on(btn_shadow, value)
    else
        print("set fish shadow failed.")
    end
end

function get_fish_shadow()
    if FF_G and FF_G.uiInfo then
        return FF_G.uiInfo.fishShadow
    else
        print("get fish shadow value failed.")
        return true
    end
end

function set_fish_shadow(value)
    if FF_G and FF_G.uiInfo then
        FF_G.uiInfo.onFishShadowChanged(value)
        return true
    else
        print("set fish shadow failed.")
        return false
    end
end

function on_test_clicked()
    print("btn test clicked.")
    require("script.ui.mdy_layer")
    mdy_layer.pop(100, 100)
    on_close_clicked()
end

function on_export_fish_clicked()
    print("btn export fish clicked.")

    -- 分析游戏 id 需要的鱼 id
    local games = {}
    for i=101,108 do
        games[tostring(i)] = collect_games_fishes(i)
    end
    for i=140,146 do
        games[tostring(i)] = collect_games_fishes(i)
    end
    local f_path_1 = "src/hall/src/hallnew/cfgs/fish/game_fishs.json"
    f_path_1 = cc.FileUtils:getInstance():fullPathForFilename(f_path_1)
    local fp = io.open(f_path_1, "wt")
    local json = require("json")
    local data_ = json.encode(games)
    fp:write(data_)
    fp:close()

    -- 鱼 id 对应的 资源数据
    local fishs = {}
    for name,info in pairs(FF_G.FishInfo) do
        local assets = get_assets_for_action_file(info.actionFile)
        local ext_res = info.extRes or {}
        for _, r in ipairs(ext_res) do
            local assets_ext = get_assets_for_file(r)
            for _,e in ipairs(assets_ext) do
                table.insert(assets, e)
            end
        end

        for _, a in ipairs(assets) do
            fishs[tostring(info.typeId)] = assets
        end
    end

    local f_path_2 = "src/hall/src/hallnew/cfgs/fish/fish_assets.json"
    f_path_2 = cc.FileUtils:getInstance():fullPathForFilename(f_path_2)
    local fp = io.open(f_path_2, "wt")
    local json = require("json")
    local data_ = json.encode(fishs)
    fp:write(data_)
    fp:close()

    --美化一下 json 文件
    local path_ = cc.FileUtils:getInstance():fullPathForFilename("beautify_fish_json.py")
    local cmd = "python " .. path_ .. " " .. f_path_1 .. " " .. f_path_2
    print(cmd)
    os.execute(cmd)
end

function get_assets_for_file(file_name)
    if string.find(file_name, ".plist") then
        local assets = {}
        print("file_name:" .. file_name)
        table.insert(assets, file_name)

        local png_file_name = string.gsub(file_name, ".plist", ".png")
        print("png:" .. png_file_name)
        table.insert(assets, png_file_name)
        return assets
    else
        return get_assets_for_action_file(file_name)
    end
end

function get_assets_for_action_file(action_file_name)
    local res_file_name = get_res_file_name_from_actions(action_file_name)
    print("res_file_name:" .. tostring(res_file_name))
    if not res_file_name then
        return {}
    end

    local assets
    if string.find(res_file_name, ".frames") then
        local frame_file = res_file_name
        print("frame_file:" .. frame_file)
        assets = collect_assets_in_frame_file(frame_file)
        table.insert(assets, frame_file)
        local anims = string.gsub(action_file_name, ".actions", ".anims")
        table.insert(assets, anims)
    elseif string.find(res_file_name, ".atlas") then
        local atlas_file = res_file_name
        print("atlas_file:" .. atlas_file)
        assets = collect_assets_in_atlas_file(atlas_file)
        table.insert(assets, atlas_file)
        local anims = string.gsub(action_file_name, ".actions", ".anims")
        table.insert(assets, anims)
        local skel = string.gsub(action_file_name, ".actions", ".skel")
        table.insert(assets, skel)
    else
        print("unknown res file type..")
        return {}
    end
    return assets
end

function get_res_file_name_from_actions(action_file_name)
    local anims = string.gsub(action_file_name, ".actions", ".anims")
    local full_path = cc.FileUtils:getInstance():fullPathForFilename(anims)
    if full_path == "" then
        return nil
    end

    -- 从 anims 文件提取需要用到的资源
    local fp = io.open(full_path, "rt")
    local str_ = fp:read("*a")
    fp:close()
    local json = require("json")
    print("anims:" .. anims)
    print("str_:" .. str_)
    local ani_cfg = json.decode(str_)
    
    local res_file_name = ani_cfg["resFileName"]
    if not res_file_name then
        return nil
    end

    local ret = string.gsub(action_file_name, "([%w_]*%.%w*)", res_file_name)
    return ret
end

function collect_games_fishes(game_id)
    package.loaded["script.level.game" .. game_id] = nil
    local fishs = {}
    _G.FilterBornEvent = function(time, info)
        local fish = info
        if type(fish) ~= type({}) then
            fish = {fish}
        end
        for k,f in pairs(fish) do
            fishs[f] = true
        end
    end
    require("script.level.game" .. game_id)
    local ret = {}
    for id,_ in pairs(fishs) do
        table.insert(ret, id)
    end

    -- 特殊鱼组需要展开
    local group = {
        [ 351 ] = { 16, 7 },
        [ 354 ] = { 320, 14 },
        [ 355 ] = { 321, 15 },
        [ 356 ] = { 323, 16 }
    }
    local new_ret = {}
    for __,fish_id in ipairs(ret) do
        local group_ids = group[fish_id]
        if not group_ids then
            table.insert(new_ret, fish_id)
        else
            for _,idx in ipairs(group_ids) do
                table.insert(new_ret, idx)
            end
        end
    end
    ret = new_ret

    table.sort(ret)

    -- 去重复
    local new_ret2 = {}
    local last_id = -1
    for _, id in ipairs(ret) do
        if id ~= last_id then
            table.insert(new_ret2, id)
            last_id = id
        end
    end
    ret = new_ret2

    dump(ret, " ** fish ** ")
    return ret
end

function collect_assets_in_frame_file(frame_file)
    local full_frame_path_ = cc.FileUtils:getInstance():fullPathForFilename(frame_file)
    print("full_frame_path_:" .. full_frame_path_)
    
    local fp = io.open(full_frame_path_, "rt")
    local data_ = fp:read("*a")
    fp:close()
    local json = require("json")
    local info = json.decode(data_)
    local plists = info.plists
    local ret = {}
    for __,name in pairs(plists) do
        local png_f = string.gsub(name, ".plist", ".png")
        table.insert(ret, name)
        table.insert(ret, png_f)
    end
    return ret
end

function collect_assets_in_atlas_file(atlas_file)
    local full_frame_path_ = cc.FileUtils:getInstance():fullPathForFilename(atlas_file)
    -- print("full_frame_path_:" .. full_frame_path_)
    print(atlas_file)
    local fp = io.open(full_frame_path_, "rt")
    local data_ = fp:read("*a")
    local files = {}

    print("atlas_file:" .. atlas_file)
    local dir_ = string.gsub(atlas_file, "([%-_%w*%.]*atlas)", "")
    print("dir_:" .. dir_)

    for w in string.gmatch(data_, "([%-_%w*%.]*png)") do
        w = dir_ .. w
        table.insert(files, w)
    end
    return files
end
