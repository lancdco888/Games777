local CasinoItem = require "casino_common.src.CasinoItem"
local AfricanBuffalo_Item = class("AfricanBuffalo_Item",CasinoItem)

AfricanBuffalo_Item.iconData = {
	wild_icon = 1 ,		--wild
	scatter_icon = 2 ,	--硬币
	ox_icon = 3 ,		--牛
}
function AfricanBuffalo_Item:ctor(cell,showNode,cellIndex,iconNumber,logic)
	self.super.ctor(self,cell,showNode,cellIndex,iconNumber,logic)
	--弹性效果移动的位置
	self.elasticity = {
		0.09,0.07,0.05,0.04,0.03,0.01,
		-0.01,-0.02,-0.03,-0.03,-0.04,-0.04,-0.06,-0.06
	}
	self.iconSpriteTXK = {}
end
function AfricanBuffalo_Item:RandomChildTuData()
	local tuData = {}
	--图片id
	tuData.icon = math.random(1,13)
	return tuData
end

--显示完整的图
function AfricanBuffalo_Item:Show()
	--循环调整绘制
	for i = 1, self.iconNumber do
		self.iconSprite[i]:removeFromParent()
		local iconTem = self.showTuData[i].icon
		local picIdTem = Casino_Func.GetIconPicIdData(Def_Casino.Icon_Type,iconTem)
		local zorder = 1
		self.iconSprite[i] = cc.Sprite:createWithSpriteFrameName(picIdTem)
		if iconTem == AfricanBuffalo_Item.iconData.scatter_icon then--钱币
			zorder = 3
			self.iconSprite[i] = sp.SkeletonAnimation:createWithJsonFile("casino332/newres/spine/Scatter.json","casino332/newres/spine/Scatter.atlas",1)
			self.iconSprite[i]:setOpacityModifyRGB(true)
			self.iconSprite[i]:setAnimation(0,"Scatter_Intro",false)
		elseif iconTem == AfricanBuffalo_Item.iconData.ox_icon then--钱币
			zorder = 2
		end
		Casino_Func.IconAddShowIconSN_4_5(self.showNode,0,13,self.iconSprite[i],self.index + (i-1)*5,zorder+i+self.index)
	end
end
--隐藏/恢复
function AfricanBuffalo_Item:Hide()
	--循环调整绘制
	for i = 1, self.iconNumber do
		self:DeleteTeXiaoKuang(i)
		self.iconSprite[i]:removeFromParent()
		local iconTem = self.showTuData[i].icon
		local picIdTem = Casino_Func.GetIconPicIdData(Def_Casino.Icon_Type,iconTem)
		local zorder = 1

		self.iconSprite[i] = cc.Sprite:createWithSpriteFrameName(picIdTem)
		self.iconSprite[i]:setPosition(cc.p(self.tuPosX[i],self.tuPosY[i]))
		self.myCell:addChild(self.iconSprite[i],zorder+i+self.index)
	end
end
--对当前格子对应下标替换精灵
function AfricanBuffalo_Item:ReplaceSprite(node,index,zorder)
		self.iconSprite[index]:removeFromParent()
		self.iconSprite[index] = node
		Casino_Func.IconAddShowIconSN_4_5(self.showNode,0,13,self.iconSprite[index],self.index + (index-1)*5,zorder+index+self.index)
end
--[[--添加特效框
function CandyItem:AddTeXiaoKuang(index)
	if self.iconSpriteTXK[index] ~= nil then
		self.iconSpriteTXK[index]:removeFromParent()
		self.iconSpriteTXK[index] = nil
	end
	self.iconSpriteTXK[index] = sp.SkeletonAnimation:createWithJsonFile(
		"casinof/newres/Glow_lizi.json","casinof/newres/Glow_lizi.atlas",1)
	self.iconSpriteTXK[index]:setOpacityModifyRGB(true)
	self.iconSpriteTXK[index]:setAnimation(0,"Glow_lizi",true)
	Casino_Func.IconAddShowIconSN_3_5(self.showNode,0,0,self.iconSpriteTXK[index],self.index + (index-1)*5,
		CandyItem.CandyData.TXKzorder+index+self.index)
end--]]
--添加特效框
function AfricanBuffalo_Item:AddTeXiaoKuang(index,zorder)
	if self.iconSpriteTXK[index] ~= nil then
		self.iconSpriteTXK[index]:removeFromParent()
		self.iconSpriteTXK[index] = nil
	end
	self.iconSpriteTXK[index] = sp.SkeletonAnimation:createWithJsonFile(
		"casino332/newres/spine/YingFenKuang.json","casino332/newres/spine/YingFenKuang.atlas",1)
	self.iconSpriteTXK[index]:setOpacityModifyRGB(true)
	self.iconSpriteTXK[index]:setAnimation(0,"YingFenKuang",true)
	Casino_Func.IconAddShowIconSN_4_5(self.showNode,0,13,self.iconSpriteTXK[index],self.index + (index-1)*5,zorder+index+self.index)
end
--删除特效框
function AfricanBuffalo_Item:DeleteTeXiaoKuang(index)
	if index < 0 or index > self.iconNumber then
		return
	end
	if self.iconSpriteTXK[index] ~= nil then
		self.iconSpriteTXK[index]:removeFromParent()
		self.iconSpriteTXK[index] = nil
	end
end
--[[function AfricanBuffalo_Item:CreateIconSprite(index)
	--初始化图标精灵 和 背景精灵
	local icon = self.showTuData[index].icon
	self.iconSprite[index] = cc.Sprite:createWithSpriteFrameName(
	Casino_Func.GetIconPicIdData(Def_Casino.Icon_Type,icon)
	)
	self.myCell:addChild(self.iconSprite[index])
end--]]


return AfricanBuffalo_Item
