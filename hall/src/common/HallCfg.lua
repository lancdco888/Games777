local HallCfg = class("HallCfg")

function HallCfg:ctor()
	local str_ = cc.FileUtils:getInstance():getStringFromFile("hall/res/cfgs/hall.cfg.json")
	local json = require("json")
	local data_ = json.decode(str_)

	dump(data_, " ** data_ hall.cfg.json ** ")
	local cfg
	if data_ == nil then
		cfg = {}
	else
		cfg = data_
	end

	if cfg["service.show_btn_agent"] == nil then
		cfg["service.show_btn_agent"] = false
	end

	self.cfg = cfg
end

function HallCfg:isShowServiceAgentButton()
	return self.cfg["service.show_btn_agent"] == true
end

return HallCfg
