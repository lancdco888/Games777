local M = {}

-- 游戏分数显示强制转换成整形
M.GameScoreForceToInt = true

-- 游戏彩金使用大厅汇率显示时是否强制取整
M.LotteryLobbyRateConvertInt = false
-- 游戏彩金使用大厅汇率显示时文本前缀
M.LotteryLobbyRateTextPrefix = ""
-- 游戏彩金更新频率
M.LotteryUpdateInterval = 24
-- 游戏顶部显示大厅汇率时固定小数位
M.TopLobbyRateTextDecimalPlaces = 2
-- 点击加减押注是否可以改变选C
M.BetStepChangeCLevel = false
-- 显示选C菜单
M.ShowBetCLevelMenu = true


if RUNTIME_IN_CREATOR then
    -- 自动spin间隔时长
    M.AutoSpinInterval = {
        [FGameMode.NORMAL]  = 2,
        [FGameMode.FREE]    = 1,
        [FGameMode.SPECIAL] = 5,
    }
else
    -- 自动spin间隔时长
    M.AutoSpinInterval = {
        [FGameMode.NORMAL]  = 2,
        [FGameMode.FREE]    = 1,
        [FGameMode.SPECIAL] = 1,
    }
end

function M:GetRellStopInterval(index)
    local rellStopInterval = FCasinoCtx.gameCfg.Reel.rellStopInterval
    local interval = rellStopInterval[FCasinoCtx.curGameMode]
    if index == nil then
        return interval
    end
    return interval * (index - 1)
end


--收分声音配置
M.CfgWinChipSound = {
    [1]     = { ratio=0,        time=1.0,      url="ui://Basics/win1"     },
    [2]     = { ratio=1,        time=2.0,      url="ui://Basics/win2"     },
    [3]     = { ratio=2,        time=2.5,      url="ui://Basics/win3"     },
    [4]     = { ratio=3,        time=3.5,      url="ui://Basics/win4"     },
    [5]     = { ratio=5,        time=4.5,      url="ui://Basics/win5"     },
    [6]     = { ratio=10,       time=6.5,      url="ui://Basics/win6"     },
    [7]     = { ratio=15,       time=7,        url="ui://Basics/win7"     },
    [8]     = { ratio=20,       time=7.5,      url="ui://Basics/win8"     },
    [9]     = { ratio=30,       time=8.5,      url="ui://Basics/win9"     },
    [10]    = { ratio=40,       time=10.0,     url="ui://Basics/win10"    },
    [11]    = { ratio=60,       time=13.0,     url="ui://Basics/win11"    },
    [12]    = { ratio=80,       time=15.0,     url="ui://Basics/win12"    },
    [13]    = { ratio=100,      time=18.0,     url="ui://Basics/win13"    },
    [14]    = { ratio=200,      time=20.0,     url="ui://Basics/win14"    },
    [15]    = { ratio=500,      time=30.0,     url="ui://Basics/win15"    },
    [16]    = { ratio=1000,     time=45.0,     url="ui://Basics/win16"    },
}

-- @brief 获取对应收分配置
function M:GetWinChipCfg(winMoney)
    local ratio = winMoney / FCasinoCtx.commonPanel:GetBetMoney()
    local len = #self.CfgWinChipSound

    for i = 1, len - 1 do
        local curCfg  = self.CfgWinChipSound[i]
        local nextCfg = self.CfgWinChipSound[i + 1]
        if ratio >= curCfg.ratio and ratio < nextCfg.ratio then
            return curCfg
        end
    end

    return self.CfgWinChipSound[len]
end

M.FaFaFaAudioData =
{   -- 中奖比例      中奖类型等级         是否需要喷金币           资源url                         播放时间
    {ratio= 0.0001, bigWinLevel = 1,    isOpenFire = false,     url = "ui://Basics/wintune01", time = 0.1},
    {ratio= 0.1,    bigWinLevel = 1,    isOpenFire = false,     url = "ui://Basics/wintune02", time = 0.2},
    {ratio= 0.2,    bigWinLevel = 1,    isOpenFire = false,     url = "ui://Basics/wintune03", time = 0.3},
    {ratio= 0.3,    bigWinLevel = 1,    isOpenFire = false,     url = "ui://Basics/wintune04", time = 0.4},
    {ratio= 0.4,    bigWinLevel = 1,    isOpenFire = false,     url = "ui://Basics/wintune05", time = 0.5},
    {ratio= 0.5,    bigWinLevel = 1,    isOpenFire = false,     url = "ui://Basics/wintune06", time = 0.6},
    {ratio= 0.6,    bigWinLevel = 1,    isOpenFire = false,     url = "ui://Basics/wintune07", time = 0.7},
    {ratio= 0.7,    bigWinLevel = 1,    isOpenFire = false,     url = "ui://Basics/wintune08", time = 0.8},
    {ratio= 0.8,    bigWinLevel = 1,    isOpenFire = false,     url = "ui://Basics/wintune09", time = 0.9},
    {ratio= 0.9,    bigWinLevel = 2,    isOpenFire = false,     url = "ui://Basics/wintune10", time = 1.25},
    {ratio= 1,      bigWinLevel = 2,    isOpenFire = false,     url = "ui://Basics/wintune11", time = 2.25},
    {ratio= 2,      bigWinLevel = 2,    isOpenFire = false,     url = "ui://Basics/wintune12", time = 1.5},
    {ratio= 3,      bigWinLevel = 3,    isOpenFire = false,     url = "ui://Basics/wintune13", time = 1.9},
    {ratio= 5,      bigWinLevel = 3,    isOpenFire = false,     url = "ui://Basics/wintune14", time = 2.25},
    {ratio= 7,      bigWinLevel = 3,    isOpenFire = false,     url = "ui://Basics/wintune15", time = 4.1},
    {ratio= 10,     bigWinLevel = 4,    isOpenFire = true,      url = "ui://Basics/wintune16", time = 4.05},
    {ratio= 15,     bigWinLevel = 4,    isOpenFire = true,      url = "ui://Basics/wintune17", time = 5.2},
    {ratio= 20,     bigWinLevel = 4,    isOpenFire = true,      url = "ui://Basics/wintune18", time = 6.45},
    {ratio= 30,     bigWinLevel = 5,    isOpenFire = true,      url = "ui://Basics/wintune19", time = 7.65},
    {ratio= 40,     bigWinLevel = 5,    isOpenFire = true,      url = "ui://Basics/wintune20", time = 9.15},
    {ratio= 60,     bigWinLevel = 5,    isOpenFire = true,      url = "ui://Basics/wintune21", time = 12.45},
    {ratio= 80,     bigWinLevel = 5,    isOpenFire = true,      url = "ui://Basics/wintune22", time = 14.7},
    {ratio= 100,    bigWinLevel = 6,    isOpenFire = true,      url = "ui://Basics/wintune23", time = 15},
    {ratio= 200,    bigWinLevel = 6,    isOpenFire = true,      url = "ui://Basics/wintune24", time = 18.7},
    {ratio= 500,    bigWinLevel = 6,    isOpenFire = true,      url = "ui://Basics/wintune25", time = 19.5},
    {ratio= 1000,   bigWinLevel = 6,    isOpenFire = true,      url = "ui://Basics/wintune26", time = 25.7},
    {ratio= 2000,   bigWinLevel = 6,    isOpenFire = true,      url = "ui://Basics/wintune27", time = 30.9},
    {ratio= 3000,   bigWinLevel = 6,    isOpenFire = true,      url = "ui://Basics/wintune28", time = 35.9},
    {ratio= 4000,   bigWinLevel = 6,    isOpenFire = true,      url = "ui://Basics/wintune29", time = 39.1},
    {ratio= 5000,   bigWinLevel = 6,    isOpenFire = true,      url = "ui://Basics/wintune30", time = 45.3},
    {ratio= 6000,   bigWinLevel = 6,    isOpenFire = true,      url = "ui://Basics/wintune31", time = 52.5},
    {ratio= 8000,   bigWinLevel = 6,    isOpenFire = true,      url = "ui://Basics/wintune32", time = 57.6},
}


function M:GetFaFaFaAudioData(winMoney)
    if winMoney == 0 then
        return nil
    end
    local ratio = winMoney / FCasinoCtx.commonPanel:GetBetMoney()
    local len = #self.FaFaFaAudioData

    for i = 1, len - 1 do
        local curCfg  = self.FaFaFaAudioData[i]
        local nextCfg = self.FaFaFaAudioData[i + 1]
        if ratio >= curCfg.ratio and ratio < nextCfg.ratio then
            return curCfg
        end
    end

    return self.FaFaFaAudioData[len]
end

M.BigWinLevelRes = {
    [0] = {
        res = {
            "ui://Basics/zlyckk",
        },
        type = 1
    },
    [1] = {
        res = {
            "ui://Basics/cygg",
            "ui://Basics/dyj",
            "ui://Basics/hyd",
            "ui://Basics/nhxy",
            "ui://Basics/ryyc",
            "ui://Basics/wxhzg",
            "ui://Basics/yqll",
            "ui://Basics/zdbc",
            "ui://Basics/zhzdyl",
            "ui://Basics/zlmf",
            "ui://Basics/zsgmxk",
            "ui://Basics/zyjncg",
        },
        type = 1
    },
    [2] = {
        res = {
            "ui://Basics/dj",
            "ui://Basics/dsjdyj",
            "ui://Basics/fxgz",
            "ui://Basics/gdpl",
            "ui://Basics/jgzmz",
        },
        type = 2
    },
    [3] = {
        res = {
            "ui://Basics/ffxz",
            "ui://Basics/jzjsms",
            "ui://Basics/ntkl",
            "ui://Basics/ysll",
            "ui://Basics/zsjc",
        },
        type = 2
    },
    [4] = {
        res = {
            "ui://Basics/bksy",
            "ui://Basics/cjlh",
            "ui://Basics/mmjl",
            "ui://Basics/ybl",
            "ui://Basics/yxbd",
        },
        type = 4
    },
    [5] = {
        res = {
            "ui://Basics/fbxc",
            "ui://Basics/hjl",
            "ui://Basics/jcff",
            "ui://Basics/nyzx",
            "ui://Basics/zb",
        },
        type = 5
    },
    [6] = {
        res = {
            "ui://Basics/nzsjxwj",
            "ui://Basics/wnyl",
        },
        type = 3
    },
}

-- return type, url
function M:GetBigWinTipsData(level)
    if not self.BigWinLevelRes[level] then
        return nil
    end
    local datas = self.BigWinLevelRes[level]
    return datas.type, datas.res[math.random(1,#datas.res)] 
end
return M

