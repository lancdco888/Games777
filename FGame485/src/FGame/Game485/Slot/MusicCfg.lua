local MusicCfg = {}

--收分声音配置
MusicCfg.CfgWinChipSound = {
    [1]     = { ratio=0,         time=1.0,      isOpenFire = false,    url = "ui://Game485/ModernClassic_CR_1", urlSc = "ui://Game485/UFCS_FG_CR_Sync", urlScStop = "ui://Game485/UFCS_FG_CR_Stop" },
    [2]     = { ratio=0.4,       time=2.0,      isOpenFire = false,    url = "ui://Game485/ModernClassic_CR_2", urlSc = "ui://Game485/UFCS_FG_CR_Sync", urlScStop = "ui://Game485/UFCS_FG_CR_Stop" },
    [3]     = { ratio=3,         time=6.0,      isOpenFire = false,    url = "ui://Game485/ModernClassic_CR_3", urlSc = "ui://Game485/UFCS_FG_CR_Sync", urlScStop = "ui://Game485/UFCS_FG_CR_Stop" },
    [4]     = { ratio=15,        time=14.0,     isOpenFire = true,  playFire = "bigwini",  url = "ui://Game485/ModernClassic_CR_4", urlSc = "ui://Game485/UFCS_FG_CR_Sync", urlScStop = "ui://Game485/UFCS_FG_CR_Stop" },
    [5]     = { ratio=45,        time=14.0,     isOpenFire = true,  playFire = "bigwinii",  url = "ui://Game485/ModernClassic_CR_4", urlSc = "ui://Game485/UFCS_FG_CR_Sync", urlScStop = "ui://Game485/UFCS_FG_CR_Stop" },
}

-- @brief 获取对应收分配置
function MusicCfg:GetWinChipCfg(winMoney)
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

return MusicCfg