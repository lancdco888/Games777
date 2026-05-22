local AniCfg = class("AniCfg")

function AniCfg:ctor()
	self.cfgs = {}

	local cfg_path = cc.FileUtils:getInstance():fullPathForFilename("hall/res/lobby/gamelist.cfg.json")
	if cfg_path == "" then
		print("no cfg path: gamelist.cfg.json")
		return
	end

	local file = io.open(cfg_path, "r")
	if (file == nil) then return end
	local t = file:read("*all")
	file:close()
	self.cfgs = json.decode(t)
end

function AniCfg:getCfg(game_id)
	local cfg = self.cfgs[tostring(game_id)]
	if not cfg then
		return {
			scale_x = 1.0,
			scale_y = 1.0,
			x = 0,
			y = 0
		}
	else
		return cfg
	end
end

return AniCfg.new()