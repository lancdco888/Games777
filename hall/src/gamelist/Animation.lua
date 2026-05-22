local AnimCfg = require("hall.src.gamelist.AnimCfg.init")

-- node: 播放动画的节点
-- id: 动画的id 见 AnimCfg
-- loop: 是否循环播放
-- force: 是否强行播放，默认已播放不再播放
function PlayAnimation(node, id, loop, force, ondone)
    if not node then
        print("invalid node")
        return false
    end
    local cfg = AnimCfg[id]
    if not cfg then
        print("no ani cfg")
        return false
    end
    -- 默认不循环播放
    loop = loop or false
    -- 默认只播放一个动画
    if force == nil then
        force = false
    end
    
    local eft = MakeEffect(cfg.skel, cfg.atlas, cfg.name, loop, ondone)

    -- 确定是否使用 mask
    local mask
    if cfg.mask then
        mask = MakeMask(node, cfg.mask)
        if mask then
            local size = mask:getContentSize()
            mask:setLocalZOrder(1)
            mask:addChild(eft)
        else
            node:addChild(eft)
        end
    else
        node:addChild(eft)
    end
    return true
end

function MakeEffect(skelPath, atlasPath, ani_name, isloop, ondone)
    local eft
    if string.find(skelPath, ".json") then
        eft = sp.SkeletonAnimation:createWithJsonFile(skelPath, atlasPath)
    else
        eft = sp.SkeletonAnimation:createWithBinaryFile(skelPath, atlasPath)
	end

    eft:setAnchorPoint(cc.p(0.5, 0.5))
	eft:setOpacityModifyRGB(false)
	local success = eft:setAnimation(0, ani_name, isloop)
    if not isloop then
        eft:registerSpineEventHandler(function(obj)
            -- 移除该动画
            eft:runAction(
                cc.RemoveSelf:create()
            )
            if ondone then
                ondone()
            end
        end, 3)
    end

	return eft
end

-- mask:addChild(node))--node就是被遮罩裁剪的对象
-- 制作模板裁剪
-- parent：模板父节点
-- stencilPath：模板资源路径
function MakeMask(parent, stencilPath)
    --创建遮罩层
    local stencilNode = cc.Node:create()
    local stencil = ccui.ImageView:create(stencilPath)
    stencilNode:addChild(stencil)
    local mask = cc.ClippingNode:create(stencilNode)
    mask:setInverted(false)
    mask:setAlphaThreshold(0)
    parent:addChild(mask)
    return mask
end
