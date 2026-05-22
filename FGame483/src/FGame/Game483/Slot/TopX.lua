local TopX = Class("TopX")
local Utils = Import(".Utils")
local MusicCfg = Import(".MusicCfg")
TopX.Cfgs = {
    n1 = {"x1","x1_g"},
    n2 = {"x2","x2_g"},
    n3 = {"x3","x3_g"},
    n4 = {"x5","x5_g"},

    f1 = {"x2_b","x2_g"},
    f2 = {"x4","x4_g"},
    f3 = {"x6","x6_g"},
    f4 = {"x10","x10_g"},
}


function TopX:ctor(render)
    self.render = render
    self.render.visible = true
    self:InitUI() 

    self.normalIndex = 1
    self.freeIndex = 1
    self:NormalTypeAnim()
end

function TopX:__delete()
    self.normals = {}
    self.frees = {}
end

function TopX:InitUI()
    self.normals = {}
    local cfg = TopX.Cfgs
    for i = 1, 4, 1 do
        local n = self.render:GetChild("normal"..i)
        table.insert(self.normals,n)
        local c1 = n:GetChildAt(0)
        c1.url = "ui://Game483/"..cfg["n"..i][1]
        local c2 = n:GetChildAt(2)
        c2.url = "ui://Game483/"..cfg["n"..i][2]
        c2.visible = false
    end
    self.frees = {}
    for i = 1, 4, 1 do
        local f = self.render:GetChild("free"..i)
        table.insert(self.frees,f)
        local c1 = f:GetChildAt(0)
        c1.url = "ui://Game483/"..cfg["f"..i][1]
        local c2 = f:GetChildAt(2)
        c2.url = "ui://Game483/"..cfg["f"..i][2]
        c2.visible = false
    end
end

-- 切换普通
function TopX:NormalTypeAnim()
    for _, v in pairs(self.normals) do
        v.visible = true
    end
    for _, v in pairs(self.frees) do
        v.visible = false
    end
    self.mode = FGameMode.NORMAL
    self:IndexReset()
end

-- 免费模式动画
function TopX:FreeTypeAnim(callback)
    self.mode = FGameMode.FREE
    local count = 0
    self.freeIndex = 0
    FToolSet.PlayFGUISound(MusicCfg.free_fold_change)
    for index, node in ipairs(self.frees) do
        count = count + 1
        Utils.Delay(node,(count-1)*0.15,function ()
            node.visible = true
            if self.freeIndex > 1 then
                self:_setLight(self.mode,false)
            end
            self.freeIndex = self.freeIndex + 1
            local i = self.freeIndex
            self:_setLight(self.mode,true,function ()
                if i == 4 then
                    self:IndexReset(true)
                    if callback then
                        callback()
                    end
                end
            end)
            self:_setLight(FGameMode.NORMAL,false)
            self.normals[index].visible = false
        end)
    end
end

-- 单次旋转每轮赢调用
function TopX:IndexAdd(index)
    FToolSet.PlayFGUISound(MusicCfg.fold_change..index)
    if self.mode == FGameMode.NORMAL then
        if self.normalIndex > 4 then
            print("IndexAdd error")
            return
        end
        FToolSet.PlayFGUISound(MusicCfg.vocals_X_Normal[index])
        self:_setLight(self.mode,false)
        self.normalIndex = index
        self:_setLight(self.mode,true)
    else
        if self.freeIndex > 4 then
            print("IndexAdd error")
            return
        end
        FToolSet.PlayFGUISound(MusicCfg.vocals_X_Free[index])
        self:_setLight(self.mode,false)
        self.freeIndex = index
        self:_setLight(self.mode,true)
    end
end

-- 单次旋转结束调用 (spin按钮点击调用)
function TopX:IndexReset(dontSetLight)
    self:_setLight(FGameMode.NORMAL,false)
    self:_setLight(FGameMode.FREE,false)
    self.normalIndex = 1
    self.freeIndex = 1
    if not dontSetLight then
        self:_setLight(FGameMode.NORMAL,true)
        self:_setLight(FGameMode.FREE,true)
    end
    if FCasinoCtx.curGameMode == FGameMode.FREE then
        FToolSet.PlayFGUISound(MusicCfg.vocals_X_Free[1])
    end
end

-- 点亮或关掉某个X
function TopX:_setLight(mode,isVisible,callback)
    local node
    if mode == FGameMode.NORMAL then
        node = self.normals[self.normalIndex]
    else
        node = self.frees[self.freeIndex]
    end
    if not node then
        print("_setLight not node ")
        return
    end
    node:GetTransition(isVisible and "turnOn" or "turnOff"):Play(function ()
        if callback then
            callback()
        end
    end)
end

return TopX