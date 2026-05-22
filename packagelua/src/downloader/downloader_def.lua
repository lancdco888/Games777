downloader_def = {}

downloader_def.DownLoad_TurnOn = true --是否开启热更新
downloader_def.CheckMD5_TurnOn = true --MD5检测开关
downloader_def.Debug_So = true --so更新(true更新，false不更新)

--热更新状态
downloader_def.UpdateInit = 0
downloader_def.Checking = 1
downloader_def.Updating = 2

-- 本地默认目录
downloader_def.DefaultPath = cc.FileUtils:getInstance():getDefaultResourceRootPath()

--下载根目录
downloader_def.WritablePath = cc.FileUtils:getInstance():getWritablePath() .. 'download/'

--热更新界面状态
downloader_def.Check_Download = 0
downloader_def.Update_Download = 1
downloader_def.Finish_Download = 2
downloader_def.Fail_Download = 3
downloader_def.LobbyManifest_Download = 4
downloader_def.CheckMD5_Update_File = 5
downloader_def.CheckMD5_All_File = 6
downloader_def.Need_Download = 7
downloader_def.Strat_Send = 8
downloader_def.End_Send = 9

--热更新返回值
downloader_def.Update_NoUpdate = 1
downloader_def.Update_NewVersion = 2
downloader_def.Update_Finished = 3
downloader_def.Update_Failed = 4
downloader_def.Update_NoManifest = 5
downloader_def.Update_ErrorDlMF = 6
downloader_def.Update_ErrorPMF = 7
downloader_def.Update_FailedExplode = 12

downloader_def.CheackMD5Time = 5 --MD5对比次数限制
downloader_def.DownloadTimeout = 3 --下载失败次数限制

-- 获取版本返回错误，其实是这个账号找不到，需要提示 用户名密码错误
downloader_def.getVersionError = "account_or_password_error"

downloader_def.soJson = {
    assets = {
        ['res/libcocos2dlua.so'] = {
            md5 = '%s'
        }
    }
}
