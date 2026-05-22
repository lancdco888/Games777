gSound = gSound or {}

g_AudioIds = {}
g_AudioInfos = {}

local bgmSoundID	 = -1
local soundPath  	 = ""

gSound.bEffectOn = true
gSound.bMusicOn = true

gSound.init = function()
	cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		if #g_AudioIds <= 0 then return end
		local ids = {}
		for _, id in pairs(g_AudioIds) do
			if ccexp.AudioEngine:getState(id) ~= -1 then
				table.insert(ids, id)
			end
		end
		g_AudioIds = ids
	end, 1, false)

	gSound.bEffectOn = cc.UserDefault:getInstance():getBoolForKey("effect", true)
	gSound.bMusicOn = cc.UserDefault:getInstance():getBoolForKey("music", true)

	-- 预加载大厅音乐音效
	gSound.preloadBgm("sound/bg_lobby.mp3")	
	gSound.preloadEffect("sound/click.mp3")
end

gSound.isEffectOn = function()
	return gSound.bEffectOn
end

gSound.isMusicOn = function()
	return gSound.bMusicOn
end

--设置音效开关
gSound.setEffectOn = function(bOpen)
	if gSound.bEffectOn == bOpen then return end
	gSound.bEffectOn = bOpen

	local volume = 0
	if bOpen then volume = 1 end

	for _, id in pairs(g_AudioIds) do
		ccexp.AudioEngine:setVolume(id, volume)
	end

	cc.UserDefault:getInstance():setBoolForKey("effect", bOpen)
end

--设置背景音效开关
gSound.setMusicOn = function (bOpen)
	if gSound.bMusicOn == bOpen then return end
	gSound.bMusicOn = bOpen

	if bOpen then
		gSound.resumeBgm()
	else
		gSound.pauseBgm()
	end

	cc.UserDefault:getInstance():setBoolForKey("music", bOpen)
end

--播放音乐
gSound.playBgm = function(path, loop)
	if loop == nil then loop = true end
	if path == nil then path = soundPath end

	-- 相同音效不重新播放了
	if soundPath == path and bgmSoundID ~= -1 then
		return bgmSoundID
	end

	if bgmSoundID ~= -1 then
		ccexp.AudioEngine:stop(bgmSoundID)
	end

	--有没有都要播放，只是把音量设置一下
	bgmSoundID = ccexp.AudioEngine:play2d(path, loop)
	
	if gSound.isMusicOn() then
		gSound.resumeBgm()
	else
		gSound.pauseBgm()
	end

	soundPath = path
	return bgmSoundID
end

--播放音效
gSound.playEffect = function(path, loop)
	if loop == nil then loop = false end
	--音效
	local id = ccexp.AudioEngine:play2d(path, loop)
	table.insert(g_AudioIds, id)
	g_AudioInfos[id] = {
		path,
		trace = debug.traceback(),
		loop = loop
	}

	if not gSound.isEffectOn() then
		ccexp.AudioEngine:setVolume(id, 0)
	end

	return id
end

--关闭音效
gSound.stopEffect = function(id)
	if id then
		ccexp.AudioEngine:stop(id)
		for i=#g_AudioIds,1,-1 do
			if g_AudioIds[i] == id then
				table.remove(g_AudioIds, i)
			end
		end
	end
end

--关闭
gSound.stopAll = function()
	g_AudioIds = {}
	g_AudioInfos = {}
	gSound.stopBgm()
	ccexp.AudioEngine:stopAll()
end

-- 获取当前背景音乐id
gSound.getBgmSoundID = function()
	return bgmSoundID
end

-- 恢复背景音乐
gSound.resumeBgm = function()
    ccexp.AudioEngine:setVolume(bgmSoundID, 1)
end

-- 暂停背景音乐
gSound.pauseBgm = function()
	ccexp.AudioEngine:setVolume(bgmSoundID, 0)
end

--停止音乐
gSound.stopBgm = function()
	-- https://forum.cocos.org/t/cc-audioengine-playmusic-cc-audioengine-stopmusic/48896
	-- https://forum.cocos.org/t/topic/148579
	local soundId = bgmSoundID
	go(function()
		ccexp.AudioEngine:stop(soundId)
	end)
	bgmSoundID = -1
	soundPath = ""
end

--预加载音乐
gSound.preloadBgm = function(path)
	ccexp.AudioEngine:preload(path)
end

--预加载音效
gSound.preloadEffect = function(path)
	ccexp.AudioEngine:preload(path)
end

--释放大厅音源
gSound.UnPreloadMusic = function(path)
	ccexp.AudioEngine:uncache(path)
end	

--释放音源
gSound.Close = function()
	-- 卸载大厅音乐音效
	gSound.UnPreloadMusic("sound/bg_lobby.mp3")	
	gSound.UnPreloadMusic("sound/click.mp3")
end

--点击音效
gSound.clickSound = function()
	if gSound.isEffectOn() then
		return ccexp.AudioEngine:play2d("sound/click.mp3", false, 0.6)
	end
end

gSound.getStat = function()
	local stat = {}
	for _,id in pairs(g_AudioIds) do
		local info = g_AudioInfos[id]
		info.state = ccexp.AudioEngine:getState(id)
		stat[id] = info
	end
	return stat
end

--------------------------------------------------------
-- 暂时兼容接口，线上更新完成即可去除。

gSound.stopbgm = gSound.stopBgm
gSound.openBgm = function(id, volume)
	gSound.playBgm()
end

--------------------------------------------------------

gSound.init()
