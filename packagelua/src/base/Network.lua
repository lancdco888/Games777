local Network = class("Network")

function Network:ctor()
    self.host = ""
    self.port = 0
	self.retry_times = 1
end

function Network:SetHost(host, port)
    self.host = host
    self.port = port
end

----------------------------------------------------------------
-- 内部函数
function Network:ConnectServer()
    local port = self.port
    local host = self.host

	local socket = require("socket")
    local t = socket.gettime()
	local ips = self:_ResolveHost(host, port)
	
    if (#ips == 0) then
        return false
    end
	
	--过滤IPv6
	local new_ips = {}
	for _index,ip in pairs(ips) do
		local bool_ = string.find(ip, ":")
		if not bool_ then
			table.insert(new_ips,ip)
		end
	end
	ips = new_ips

	gNet_ClearAddresses()
	for _index,ip in pairs(ips) do
		gNet_AddAddress(ip, port)
	end
	
    local ret = self:_CreateNet(ips, port)
    if not ret then
        print("_CreateNet Error.")
        return false
    end
    return true
end

--网络处理相关函数, 将一个域名解析成ip地址
function Network:_ResolveHost(domain)
	local ret_ips = {}
	local r = gNet:Resolve(domain, 3000)

	if r ~= 0 then
		return ret_ips
	end

	while gNet:Busy() do
		yield()
	end
	ret_ips = gNet:GetIPList()
    return ret_ips
end

function Network:_CreateNet(ips, port)
	local yield = coroutine.yield
	local RETRY_CNT = self.retry_times
::LABLE_DIAL::
	if RETRY_CNT <= 0 then
		return false
	end
	RETRY_CNT = RETRY_CNT - 1

	yield()
	-- 停掉拨号断开连接

	local socket = require("socket")
    local t = socket.gettime()
	gNet:Cancel()

	local socket = require("socket")
    local t = socket.gettime()
	gNet:Disconnect()

	-- 必要的小睡( 防止拨号频繁，以及留出各种断开后的 callback 的执行时机 )
	SleepSecsByClock(0.01)

	if port == 21000 then
		if gNet.SetEncryptEnabled then
			gNet:SetEncryptEnabled(true)
		else
			release_print("using gNet.SetEncryptEnabled failed")
		end
	end

	-- 拨号并立刻判断是否出问题
    local t = socket.gettime()
	local r = gNet:Dial()
	if r ~= 0 then
		print("gNet_Dial r = "..r)
		goto LABLE_DIAL
	end

	-- 等拨号器变得不忙
    while gNet:Busy() do
        yield()
    end

	-- 检查连接状态
	if not gNet:Alive() then
		print("dial timeout or peer disconnected.")
		goto LABLE_DIAL
	end

    -- 连上了：带 5 秒超时 等 0 号服务 open
    local nowMS = NowSteadyEpochMS();
    while NowSteadyEpochMS() - nowMS < 5000 do
        yield()

        -- 如果断线, 重新拨号
		if not gNet:Alive() then
			print("peer disconnected.")
			goto LABLE_DIAL
		end

        -- 如果检测到 0 号服务已 open 就跳出循环
        if gNet:IsOpened(0) then
			print("dial success")
			print("Dial:" .. socket.gettime() - t)
			return true
		end
    end

	-- 等 0 号服务 open 超时: 重连
	print("WAIT 0 OPEN TIMEOUT")
    goto LABLE_DIAL
end
----------------------------------------------------------------

return Network:new()
