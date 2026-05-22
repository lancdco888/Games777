-- 睡指定帧数
-- 适合在 coro 环境使用
Sleep = function(frames)
	local yield = coroutine.yield
	for i = 1, frames do
		yield()
	end
end

-- 睡指定秒( 保底睡3帧 )
-- 适合在 coro 环境使用
SleepSecsByClock = function(secs)
	local yield = coroutine.yield
	local over =NowSteadyEpochMS()+secs*1000
	yield()
	yield()
	yield()
	while over>NowSteadyEpochMS() do 
		yield()
	end
end

SleepSecs = function(secs)
	Sleep(math.floor(secs*60))
end

-- Int64转number
function Int64ToNumber(number)
	local str = Int64ToString(number)
	local num = tonumber(str)
	return num 
end