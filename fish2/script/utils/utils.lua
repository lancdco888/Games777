-- utils/utils.lua
-- 全局工具函数(客户端+服务端)
local root = ...

FF_G.GetNextLuaBulletId = function(playerId)
    local player = FF_G.players[playerId]
    local bulletId = player and player.GetNextLuaBulletId() or 0
    --print("next lua bullet id:", bulletId, " player id:", playerId)
    return bulletId
end

FF_G.IsInBottomSit = function(sitId)
    return sitId < 2
end

-- 修正炮台角度
FF_G.fixedCannonAngle = function(isBottomSit, angle)
    if isBottomSit then
        if angle < -math.pi / 2 then
            angle = math.pi - 0.0001
        elseif angle < 0 then
            angle = 0.0001
        end
    else
        if angle > math.pi / 2 then
            angle = math.pi + 0.0001
        elseif angle > 0 then
            angle = math.pi * 2 - 0.0001
        end
    end
    return angle
end

FF_G.kNodeIndex_Root = 0
FF_G.kNodeIndex_Bg0 = 1
FF_G.kNodeIndex_Bg = 2
FF_G.kNodeIndex_BgMid = 3
FF_G.kNodeIndex_Bg2 = 4
FF_G.kNodeIndex_EffectBottom = 5
FF_G.kNodeIndex_Fish = 6
FF_G.kNodeIndex_FishTop = 7
FF_G.kNodeIndex_Bullet = 8
FF_G.kNodeIndex_FishFront = 9
FF_G.kNodeIndex_Lock = 10
FF_G.kNodeIndex_EffectTop = 11
FF_G.kNodeIndex_Fishnet = 12
FF_G.kNodeIndex_Top = 13
FF_G.kNodeIndex_UiRoot = 14
FF_G.kNodeIndex_UiBottom = 15
FF_G.kNodeIndex_Ui = 16
FF_G.kNodeIndex_UiTop = 17
FF_G.kNodeIndex_SubUi = 18
FF_G.kNodeIndex_Dialog = 19
FF_G.kNodeIndex_Debug = 100

FF_G.kState_Normal = 0
FF_G.kState_Lock = 1
FF_G.kState_Clean = 100

if not FF_G.IsCSGaming then
    -- 钻头蟹
    FF_G.kStuff_DrillCarb           = FF_G.FishInfo.DrillCarb.typeId
    -- 烈焰风暴
    FF_G.kStuff_FlamesStorm         = FF_G.FishInfo.FlamesStorm.typeId
    -- 炸弹蟹
    FF_G.kStuff_BombCarb            = FF_G.FishInfo.BombCarb.typeId
    -- 连环炸弹蟹
    FF_G.kStuff_MultipleBombCarb    = FF_G.FishInfo.MultipleBombCarb.typeId
end

FF_G.kAILockType_Unlock              = 0
FF_G.kAILockType_RatioRange          = 1
FF_G.kAILockType_WithOtherPlayer     = 2

local musicRoot
local musicFormat
local isWindows = false
if not FF_G.IsServer then
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        isWindows = true
    end
    --local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    --if cc.PLATFORM_OS_ANDROID == targetPlatform then
    --    musicRoot = "music/oggformat/"
    --    musicFormat = ".ogg"
    --elseif cc.PLATFORM_OS_WINDOWS == targetPlatform then
    --    musicRoot = "music/wavformat/"
    --    musicFormat = ".wav"
    --    isWindows = true
    --else
    --    musicRoot = "music/m4aformat/"
    --    musicFormat = ".m4a"
    --end
    musicRoot = "music/mp3format/"
    musicFormat = ".mp3"
end

local GetPath = function(name)
    return musicRoot .. name .. musicFormat
end

local prevBgMusicIndex
FF_G.PlayBgMusic = function(name, loop)
    FF_G.rootTable.currentBgName = name
    --if true then return end
    if not FF_G.IsServer then
        if not name or string.len(name) == 0 then return end
        loop = loop or true
        local path = GetPath(name)
        --print("play bg music:" .. path)
        if not isWindows then
            if prevBgMusicIndex then
                FF_G.stopEffect(prevBgMusicIndex)
                prevBgMusicIndex = nil
            end
        else
            cc.SimpleAudioEngine:getInstance():stopMusic()
        end
        prevBgMusicIndex = gSound.playBgm(path, loop)
    end
end

FF_G.playEffect = function(name, loop)
    if not FF_G.IsServer then
        if not name or string.len(name) == 0 then return end
        --if true then return end
        loop = loop or false
        local path = GetPath(name)
        --print("play bg effect:" .. path)
        return gSound.playEffect(path, loop)
    end
end

FF_G.stopEffect = function(index)
    if not FF_G.IsServer then
        if index == nil then return end
        --print("stop effect:" .. index)
        gSound.stopEffect(index)
    end
end

FF_G.GetCannonBasePosBySrcPos = function(x, y)
    if y < 0 then
        y = y - 30
    else
        y = y + 30
    end
    return x, y
end

FF_G.AwayTo = function(x1, y1, x2, y2)
    if x1 > 0 then
        x1 = x1 + x2
    else
        x1 = x2 - x2
    end
    if y1 > 0 then
        y1 = y1 + y2
    else
        y1 = y1 - y2
    end
    return x1, y1
end

FF_G.NearTo = function(x1, y1, x2, y2)
    if x1 < 0 then
        x1 = x1 + x2
    else
        x1 = x1 - x2
    end
    if y1 < 0 then
        y1 = y1 + y2
    else
        y1 = y1 - y2
    end
    return x1, y1
end

local sitPos = {}
FF_G.GetPosBySit = function(sitId)
    local pos = sitPos[sitId]
    if pos then return pos end
    local gw, gh = root:GetGSize()

    local w = gw / 2 - 380;
    local h = gh / 2 - 50;
    if sitId == 0 then
        pos = {x = -w, y = -h}
    elseif sitId == 1 then
        pos = {x = w, y = -h}
    elseif sitId == 2 then
        pos = {x = -w, y = h}
    elseif sitId == 3 then
        pos = {x = w, y = h}
    end
    sitPos[sitId] = pos
    return pos
end

-- 炮台基座位置
FF_G.GetCannonBasePos = function(cannon)
    local x, y = cannon:GetPos()
    if y < 0 then
        y = y - 30
    else
        y = y + 30
    end
    return x, y
end

FF_G.GetRandomCannonAngle = function(isBottomSit)
    local num = math.random(1, math.floor(math.pi * 100))
    local angle = num / 100
    if not isBottomSit then angle = angle + math.pi end
    return angle
end

FF_G.CloneFuncs = function(src, dest)
    for k, v in pairs(src) do
        if type(v) == "function" then
            dest[k] = v
        end
    end
end

-- 获取两个点中指定百分比的位置
FF_G.GetPercentPos = function(p1, p2, percent)
    return {
        x = p1.x + (p2.x - p1.x) * percent,
        y = p1.y + (p2.y - p1.y) * percent,
    }
end

FF_G.IsCSNormalFish = function(fishType)
    return fishType >= 10000 and fishType < 11000
end

FF_G.IsCSCombinedFish = function(fishType)
    return fishType >= 12000 and fishType < 13000
end

FF_G.IsCSBombFish = function(fishType)
    return fishType >= 20000 and fishType < 21000
end

FF_G.IsCSCycloneFish = function(fishType)
    return fishType >= 100001 and fishType < 1000000
end

-- 昌盛彩金动画效果
FF_G.CsBonusType = 1
FF_G.SetCsBonusType = function(type)
    FF_G.CsBonusType = type
end
