package.loaded["packagelua.src.base.Device"] = nil
Device = require("packagelua.src.base.Device")

package.loaded["packagelua.src.base.Tools_Base"] = nil
Tools_Base      = require("packagelua.src.base.Tools_Base")

package.loaded["hall.src.common.const_game"] = nil
require "hall.src.common.const_game"

package.preload["hall.src.hallnew.layers.LobbyLayer.GameList.BonusesEventsListener"] = function()
    return require("hall.src.patch.BonusesEventsListener")
end

require("hall.src.patch.ReLoadPackageLua")
local called = cc.UserDefault:getInstance():getBoolForKey("CalledPatchReLoadPackageLua", false)
if not called then
    print("call ReLoadPackageLua")
    cc.UserDefault:getInstance():setBoolForKey("CalledPatchReLoadPackageLua", true)
    xpcall(ReLoadPackageLua, __G__TRACKBACK__)
else
    print("call ReLoadPackageLua skiped")
end

-------------------------------------------------------------------

local HotfixJson = require("packagelua.src.downloader.hotfixJson")
function HotfixJson:ClearZipDone(module_)
    if self.local_infos[module_] then
        if self.local_infos[module_].is_zipdone ~= false then
            self.local_infos[module_].is_zipdone = false
            self:SaveLocalInfo()
        else
            print("no need ClearZipDone.")
        end
    end
end

if hotfixJson then
    hotfixJson:ClearZipDone("packagelua")
end
