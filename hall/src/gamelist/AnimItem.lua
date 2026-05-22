local Animation = require("hall.src.gamelist.Animation")
local AniCfg = import(".AniCfg")
local GameGroup = import(".GameGroup")

local ANIM_NODE_TAG = 1000

local AnimItem = class("AnimItem")

function AnimItem:ctor(icon)
	self.icon = icon
	self.gameId = -1

	self.playing = false		-- 旋转动画是否在播放
	self.casinoAni = nil				-- 旋转动画
end

function AnimItem:setGameId(gameId)
	if self.gameId == gameId then return end
	self.gameId = gameId

	self:clear()

	local res = GameData:GetGameID(gameId)
	local cfg = const_game.Param[res] or {}
	
	local icon = self.icon
	local anims = cfg.anims or {}
	for i, anim in ipairs(anims) do
		local ani = cc.Node:create()
		ani:setTag(ANIM_NODE_TAG)
		icon:addChild(ani)
		local size = icon:getContentSize()
		ani:setPosition(cc.p(size.width/2, size.height/2))
		PlayAnimation(ani, anim, true)
		ani:setCascadeOpacityEnabled(true)
		ani:setOpacity(0)
		ani:runAction(cc.EaseIn:create(cc.FadeIn:create(1.5), 1))
	end

	-- 老虎机的 ani
    if GameData:IsCasino(gameId) then
		local cfg = AniCfg:getCfg(res) or {}
		local ani2 = cc.Node:create()
		ani2:setTag(ANIM_NODE_TAG)
		icon:addChild(ani2)
		ani2:setPosition(cc.p(cfg.x or 0, cfg.y or 0))
		ani2:setScaleX(cfg.scale_x or 1.0)
		ani2:setScaleY(cfg.scale_y or 1.0)

		local prefix = string.format("hall/res/lobby/game_list_spine/jjj_slot_%d/jjj_slot_%d", res, res)
		local json = prefix .. ".json"
		local atlas = prefix .. ".atlas"
		local fu = cc.FileUtils:getInstance()
		if fu:fullPathForFilename(json) ~= "" and fu:fullPathForFilename(atlas) ~= "" then
			if sp38 then
				local anim = sp38.SkeletonAnimation:createWithJsonFile(json, atlas, 1)

				anim:registerSpineEventHandler(function(obj)
					anim:runAction(
						cc.CallFunc:create(function()
							self:delayPlay()
						end)
					)
				end, 3)

				anim:enableNodeEvents()
				anim:registerScriptHandler(function(state)
					if state == "exit" then
						if self.casinoAni == anim then
							self.casinoAni = nil
							self.playing = false
						end
					end
				end)

				ani2:removeAllChildren()
				ani2:addChild(anim)
				self.casinoAni = anim

				self:delayPlay()
			end
		end
	end

    if GameGroup:isGroupId(gameId) then
        local group_id = gameId
        local ani2 = GameGroup:makeAnimNode(icon, group_id)
        ani2:setTag(ANIM_NODE_TAG)
    end
end

function AnimItem:delayPlay()
	self.playing = false
	if self.casinoAni then
		self.casinoAni:setVisible(false)
	end

	local secs = math.random(0, 4000)
	self.icon:runAction(cc.Sequence:create(
		cc.DelayTime:create(secs / 1000),
		cc.CallFunc:create(function()
			self:tryPlay()
		end)
	))
end

function AnimItem:tryPlay()
	local casinoAni = self.casinoAni
	if not casinoAni then return end
	if self.playing then return end

	local res = GameData:GetGameID(self.gameId)
	casinoAni:setVisible(true)
	casinoAni:setAnimation(0, tostring(res), false)
	self.playing = true
end

function AnimItem:clear()
	self.icon:removeChildByTag(ANIM_NODE_TAG)

	if not tolua.isnull(self.casinoAni) then
		self.casinoAni:removeFromParent()
		self.casinoAni = nil
	end

	self.playing = false
end

return AnimItem
