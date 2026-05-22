local Tools = Import(".Tools")
local MusicCfg = require("FGame.Game388.Slot.MusicCfg")

-- 落地牌次数增加面板
local LuodiAddPanel = Class("LuodiAddPanel")

function LuodiAddPanel:ctor(render)

    self.render = render

    self.ques1 = render:GetChild("ques1")
    self.ques2 = render:GetChild("ques2")
    self.ques3 = render:GetChild("ques3")
    self.res1 = render:GetChild("res1")
    self.res2 = render:GetChild("res2")
    self.res3 = render:GetChild("res3")
    
    self.ques1:AddEventListener(FGUIEventKey.onClick,function()
        if self.hasChosen then return end
        self.hasChosen = true
        self:ShowResByIdx(1)
    end)
    self.ques2:AddEventListener(FGUIEventKey.onClick,function()
        if self.hasChosen then return end
        self.hasChosen = true
        self:ShowResByIdx(2)
    end)
    self.ques3:AddEventListener(FGUIEventKey.onClick,function()
        if self.hasChosen then return end
        self.hasChosen = true
        self:ShowResByIdx(3)
    end)
end


function LuodiAddPanel:DisableQuesBtns()
    self.ques1.touchable = false
    self.ques2.touchable = false
    self.ques3.touchable = false
end

function LuodiAddPanel:EnableQuesBtns()
    self.ques1.touchable = true
    self.ques2.touchable = true
    self.ques3.touchable = true
end

function LuodiAddPanel:ShowResByIdx(btnIdx)
    FToolSet.PlayFGUISound(MusicCfg.LUODI_ADDITIONAL_TIME_OUT)
    
    if btnIdx == 1 then
        self:ShowRes(self.res1,{self.res2,self.res3},1)
    elseif btnIdx == 2 then
        self:ShowRes(self.res2,{self.res1,self.res3},2)
    elseif btnIdx == 3 then
        self:ShowRes(self.res3,{self.res1,self.res2},3)
    end
end

function LuodiAddPanel:ShowRandomRes()
    self.hasChosen = true
    local randomIdx = math.random(1,3)
    self:ShowResByIdx(randomIdx)
end

function LuodiAddPanel:SetData(resCount,callBack,intoLuodiSymbolCount)
    self:EnableQuesBtns()
    self.callBack = callBack
    self:SetResCount(resCount)
    self.intoLuodiSymbolCount = intoLuodiSymbolCount
    self.hasChosen = false
end

function LuodiAddPanel:SetResCount(resCount)
    self.resCount = resCount
end

function LuodiAddPanel:ResetView()
    self.render:GetTransition("reset"):Play()
end

function LuodiAddPanel:ShowRes(resLoader, otherLoaders, resNodeIdx)
    local is1to3Config = self.intoLuodiSymbolCount and self.intoLuodiSymbolCount < 8
    local candidateCounts = is1to3Config and {1,2,3} or {2,3,4}
    local resGoldUrls = {
        "ui://Game388/addres_1_y",
        "ui://Game388/addres_2_y",
        "ui://Game388/addres_3_y",
        "ui://Game388/addres_4_y"
    } 
    local grayUrls = {
        "ui://Game388/addres_1",
        "ui://Game388/addres_2",
        "ui://Game388/addres_3",
        "ui://Game388/addres_4"
    }
    
    local resLoaderUrl = resGoldUrls[self.resCount]
    resLoader.url = resLoaderUrl
    
    local otherLoadersUrls = {}
    for i, url in ipairs(grayUrls) do
        if i ~= self.resCount and Tools.itemExists(candidateCounts,i) then
            table.insert(otherLoadersUrls, url)
        end
    end

    for i = #otherLoadersUrls, 1, -1 do
        local j = math.random(i)
        otherLoadersUrls[i], otherLoadersUrls[j] = otherLoadersUrls[j], otherLoadersUrls[i]
    end

    for idx, loader in ipairs(otherLoaders) do
        loader.url = otherLoadersUrls[idx]
    end

    -- self.ques1.visible = false
    -- self.ques2.visible = false
    -- self.ques3.visible = false

    self.render:GetTransition("res_"..resNodeIdx):Play()

    self.render:GetTransition("fade_questions"):Play()


    -- StartOnceTimer(function()
    if self.callBack then self.callBack() end
    -- end,2)
end

function LuodiAddPanel:__delete()

end

return LuodiAddPanel