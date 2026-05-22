-- utils/fish_maker.lua
local root = ...

local FishMaker = {}

---- 废弃
--local CreateNormalFish = function(actionName, luaName, coin, typeId, priority)
--    luaName = luaName or "fish0.lua"
--    --print("lua name:", actionName, luaName, coin, typeId, priority)
--    local fish = root:CreateFish(actionName, luaName)
--    fish:SetPriority(priority)
--    fish:SetTypeId(typeId)
--    fish:SetCoin(coin)
--    return fish
--end

-- luaName 可选
local CreateNormalFish1 = function(info, rand, luaName, actionName, createPrams)
    local z = info.z or 0
    if not luaName then
        if info.isCycleFish then
            luaName = FF_G.IsCSGaming and "cs_cycle.lua" or "cycle.lua"
        else
            luaName = info.luaName or "fish0.lua"
        end
        --luaName = info.isCycleFish and "cycle.lua" or info.luaName or "fish0.lua"
    end
    if not rand then
        rand = root:NextInt()
    end
    --print("create fish:", info.actionFile, luaName, info.isCycleFish)
    FF_PRAMS = {
        --cycleBgScale = info.cycleBgScale,
        --cycleBgOffset = info.cycleBgOffset,
        createPrams = createPrams
    }
    local fish = root:CreateFishWithoutInit(luaName)
    --local fish = root:CreateFish(info.actionFile, luaName)
    local coin = 0
    local coinList = info.coinList
    if coinList then
        local len = #coinList
        coin = coinList[root:NextInt() % len + 1]
    else
        coin = info.coin[1]
        if coin ~= info.coin[2] then
            coin = coin + rand % (info.coin[2] - coin + 1)
            local base = info.coin[3] or 1
            coin = coin - coin % base
        end
    end
    assert(coin > 0)
    local offsetAngle = info.offsetAngle
    if offsetAngle then
        fish:SetOffsetAngle(offsetAngle)
    end
    fish:SetTypeId(info.typeId)
    fish:SetPriority(info.priority)
    fish:SetCoin(coin)
    fish:Init(root, info.actionFile)
    if FF_G.IsServer then
        local types = info.bindFishTypes
        if types then
            fish:SetBindFishTypes(types)
        end
    end
    actionName = actionName or info.actionName
    if actionName then
        fish:GetActionNode():SetAction(actionName)
    end
    local anim = fish:GetAnimNode()
    local offset = info.offset
    if offset then
        anim:SetPainterOffset(offset[1], offset[2])
    end
    local scale = info.scale
    if scale then
        anim:SetScale(scale, scale);
    end
    if info.ignoreZOnCreate ~= true then
        anim:SetZ(z * 10)
        for _, subFish in ipairs(fish:GetChildren()) do
            subFish:GetAnimNode():SetZ(z * 10)
        end
    end
    return fish
end

local FishInfo = FF_G.LoadLuaFunc("script/config/fish_info.lua")()

------------------------------普通鱼(general)-----------------------------------
-- 迦魶鱼
FishMaker.CreateGhanaFish = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/jianayu.actions", luaName, 2, 1, 2)
    local info = isCycleFish and FishInfo.Cycle_GhanaFish or FishInfo.GhanaFish
    return CreateNormalFish1(info, rand, luaName)
end

-- 小丑鱼
FishMaker.CreateClownFish = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/xiaochouyu.actions", luaName, 3, 2, 3)
    local info = isCycleFish and FishInfo.Cycle_ClownFish or FishInfo.ClownFish
    return CreateNormalFish1(info, rand, luaName)
end

-- 碟鱼
FishMaker.CreateDishFish = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/dieyu.actions", luaName, 4, 3, 4)
    local info = isCycleFish and FishInfo.Cycle_DishFish or FishInfo.DishFish
    return CreateNormalFish1(info, rand, luaName)
end

-- 河豚
FishMaker.CreatePuffer = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/xiaohetun.actions", luaName, 5, 4, 5)
    local info = isCycleFish and FishInfo.Cycle_Puffer or FishInfo.Puffer
    return CreateNormalFish1(info, rand, luaName)
end

-- 狮子鱼
FishMaker.CreateLionFish = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/shiziyu.actions", luaName, 6, 5, 6)
    local info = isCycleFish and FishInfo.Cycle_LionFish or FishInfo.LionFish
    return CreateNormalFish1(info, rand, luaName)
end

-- 比目鱼
FishMaker.CreateOtterFish = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/bimuyu.actions", luaName, 7, 6, 7)
    local info = isCycleFish and FishInfo.Cycle_OtterFish or FishInfo.OtterFish
    return CreateNormalFish1(info, rand, luaName)
end

-- 龙虾
FishMaker.CreateLobster = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/longxia.actions", luaName, 8, 7, 8)
    local info = isCycleFish and FishInfo.Cycle_Lobster or FishInfo.Lobster
    return CreateNormalFish1(info, rand, luaName)
end

-- 旗鱼
FishMaker.CreateSailFish = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/qiyu.actions", luaName, 9, 8, 9)
    local info = isCycleFish and FishInfo.Cycle_SailFish or FishInfo.SailFish
    return CreateNormalFish1(info, rand, luaName)
end

-- 小水母
FishMaker.CreateJellyFish = function(rand, _, luaName)
    --return CreateNormalFish("actions/general/xiaoshuimu.actions", luaName, 10, 9, 10)
    local info = FishInfo.JellyFish
    return CreateNormalFish1(info, rand, luaName)
end

-- 章鱼
FishMaker.CreateOctopusFish = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/zhangyu.actions", luaName, 10, 10, 10)
    local info = isCycleFish and FishInfo.Cycle_OctopusFish or FishInfo.OctopusFish
    return CreateNormalFish1(info, rand, luaName)
end

-- 灯笼鱼
FishMaker.CreateLanternFish = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/lantern.actions", luaName, 12, 11, 12)
    local info = isCycleFish and FishInfo.Cycle_LanternFish or FishInfo.LanternFish
    return CreateNormalFish1(info, rand, luaName)
end

-- 乌龟
FishMaker.CreateTortoise = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/seaturtle.actions", luaName, 15, 12, 15)
    local info = isCycleFish and FishInfo.Cycle_Tortoise or FishInfo.Tortoise
    return CreateNormalFish1(info, rand, luaName)
end

-- 锯齿鲨
FishMaker.CreateSawtoothShark = function(rand, isCycleFish, luaName)
    --return CreateNormalFish("actions/general/juchiyu.actions", luaName, 18, 13, 18)
    local info = isCycleFish and FishInfo.Cycle_SawtoothShark or FishInfo.SawtoothShark
    return CreateNormalFish1(info, rand, luaName)
end

-- 蝠鲼
FishMaker.CreateMantaRay = function(rand, _, luaName)
    --return CreateNormalFish("actions/general/fuyu.actions", luaName, 20, 14, 20)
    local info = FishInfo.MantaRay
    return CreateNormalFish1(info, rand, luaName)
end

-- 巨大小丑鱼[10, 25]
FishMaker.CreateGiantClownFish = function(rand, _, luaName)
    --local coin = 10 + rand % 16;
    --return CreateNormalFish("actions/general/judaxiaochouyu.actions", luaName, coin, 15, 25)
    local info = FishInfo.GiantClownFish
    return CreateNormalFish1(info, rand, luaName)
end

-- 巨大鲽鱼[15, 30]
FishMaker.CreateGiantDishFish = function(rand, _, luaName)
    --local coin = 15 + rand % 16;
    --return CreateNormalFish("actions/general/judadieyu.actions", luaName, coin, 16, 30)
    local info = FishInfo.GiantDishFish
    return CreateNormalFish1(info, rand, luaName)
end

-- 鲨鱼[25, 40]
FishMaker.CreateShark = function(rand, _, luaName)
    --local coin = 25 + rand % 16;
    --return CreateNormalFish("actions/general/shark.actions", luaName, coin, 17, 40)
    local info = FishInfo.Shark
    return CreateNormalFish1(info, rand, luaName)
end

-- 鲸鱼[30, 60]
FishMaker.CreateWhale = function(rand, _, luaName)
    --local coin = 30 + rand % 31;
    --return CreateNormalFish("actions/general/whale.actions", luaName, coin, 18, 60)
    local info = FishInfo.Whale
    return CreateNormalFish1(info, rand, luaName)
end

------------------------------特殊鱼-----------------------------------

-- 闪电鲨[100, 100]
FishMaker.CreateLightningShark = function(rand, _, luaName)
    luaName = luaName or "shandiansha.lua"
    local info = FishInfo.LightningShark
    return CreateNormalFish1(info, rand, luaName)
end

-- 钻头蟹[500, 500]
FishMaker.CreateDrillCarb = function(rand, _, luaName)
    luaName = luaName or "zuantouxie.lua"
    local info = FishInfo.DrillCarb
    return CreateNormalFish1(info, rand, luaName)
end

-- 炸弹蟹[300, 300]
FishMaker.CreateBombCarb = function(rand, _, luaName)
    luaName = luaName or "zhadanxie.lua"
    local info = FishInfo.BombCarb
    return CreateNormalFish1(info, rand, luaName)
end

-- 连环炸弹蟹[300, 900]
FishMaker.CreateMultipleBombCarb = function(rand, _, luaName)
    luaName = luaName or "zhadanxie.lua"
    local info = FishInfo.MultipleBombCarb
    return CreateNormalFish1(info, rand, luaName)
end

------------------------------彩金鱼-----------------------------------
-- 暗夜炬兽[100, 500]
FishMaker.CreateNightBeast = function(rand, _, luaName)
    luaName = luaName or "anyejushou.lua"
    local info = FishInfo.NightBeast
    return CreateNormalFish1(info, rand, luaName)
end

-- 暗夜炬兽[100, 500]
FishMaker.CreateScreamingTiger = function(rand, _, luaName)
    luaName = luaName or "hutousha.lua"
    local info = FishInfo.ScreamingTiger
    return CreateNormalFish1(info, rand, luaName)
end

------------------------------普通鱼-----------------------------------
local GeneralCreator = {
    FishMaker.CreateGhanaFish,
    FishMaker.CreateClownFish,
    FishMaker.CreateDishFish,
    FishMaker.CreatePuffer,
    FishMaker.CreateLionFish,
    FishMaker.CreateOtterFish,
    FishMaker.CreateLobster,
    FishMaker.CreateSailFish,
    FishMaker.CreateJellyFish,
    FishMaker.CreateOctopusFish,
    FishMaker.CreateLanternFish,
    FishMaker.CreateTortoise,
    FishMaker.CreateSawtoothShark,
    FishMaker.CreateMantaRay,
    FishMaker.CreateGiantClownFish,
    FishMaker.CreateGiantDishFish,
    FishMaker.CreateShark,
    FishMaker.CreateWhale,
}

local GeneralCreatorSmall = {
    FishMaker.CreateGhanaFish,
    FishMaker.CreateClownFish,
    FishMaker.CreateDishFish,
    FishMaker.CreatePuffer,
    FishMaker.CreateLionFish,
    FishMaker.CreateOtterFish,
    FishMaker.CreateLobster,
    FishMaker.CreateSailFish,
    FishMaker.CreateJellyFish,
    FishMaker.CreateOctopusFish,
    FishMaker.CreateLanternFish,
    FishMaker.CreateTortoise,
    FishMaker.CreateSawtoothShark,
}

local GeneralCreatorBig = {
    FishMaker.CreateGiantClownFish,
    FishMaker.CreateGiantDishFish,
    FishMaker.CreateShark,
    FishMaker.CreateWhale,
}

-- 随机生成一个普通鱼(默认luaName使用fish0.lua)
FishMaker.RandomGeneralFishCreator = function(rand1)
    rand1 = rand1 or root:NextInt()
    local index = rand1 % #GeneralCreator + 1
    return GeneralCreator[index]()
end

-- 随机生成一个普通小鱼(默认luaName使用fish0.lua)
FishMaker.RandomGeneralSmallFishCreator = function(rand1)
    rand1 = rand1 or root:NextInt()
    local index = rand1 % #GeneralCreatorSmall + 1
    return GeneralCreatorSmall[index]()
end

-- 随机生成一个普通大鱼(默认luaName使用fish0.lua)
FishMaker.RandomGeneralBigFishCreator = function(rand1)
    rand1 = rand1 or root:NextInt()
    local index = rand1 % #GeneralCreatorBig + 1
    return GeneralCreatorBig[index]()
end

local TypeIdToFishCreator = {}
for _, info in pairs(FishInfo) do
    TypeIdToFishCreator[info.typeId] = info
    --TypeIdToFishCreator[info.name] = info
end

FF_G.GetMaxRatioByFishTypeId = function(fishTypeId)
    local info = FF_G.TypeIdToFishCreator[fishTypeId]
    assert(info, "invalid fish type id:" .. tostring(fishTypeId))
    local coinList = info.coinList
    if coinList then
        return coinList[#coinList]
    end
    return info.coin[2]
end

FF_G.FishMaker = FishMaker
FF_G.TypeIdToFishCreator = TypeIdToFishCreator
FF_G.FishCreator = CreateNormalFish1
