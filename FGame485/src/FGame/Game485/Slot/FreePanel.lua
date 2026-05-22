-- 免费游戏模式选择界面
local Utils = Import(".Utils")
local FreePanel = Class("FreePanel")

function FreePanel:ctor( render )
    self.render = render

    self.loaderCard = render:GetChild("card_loader")
    self.uiWin = render:GetChild("win")

    self.uiNumDouble = render:GetChild("num_double")
    
    self:Init()
end

function FreePanel:Init()
    self.upWin = true
    self.loaderCard.visible = false
    self.uiWin.text = ""
    
    self.render:GetTransition("win_hide"):Play()
    self.render:GetTransition("cardownef_hide"):Play()
    self:HideDouble()
end

function FreePanel:RefreshData( mode, msgData )
    dump( msgData, "FreePanel:RefreshData" )
    self:RefreshCard( mode, msgData )
end

function FreePanel:Update()
    if not self.upWin then
        return
    end
    self.uiWin.text = FCasinoCtx.commonPanel.bottomPanel.text_win.text
end

--显示卡
function FreePanel:ShowCard( mode, msgData )
    -- dump( msgData, "FreePanel:ShowCard" )
    self.render:GetTransition("cardownef_show"):Play()
    self:RefreshCard( mode, msgData )
end

local cfgFreeNum = { [5] = "free5", [7] = "free7", [10] = "free10", [15] = "free15", [20] = "free20" }
local cfgFreeTimes = { [2] = "times2", [3] = "times3", [5] = "times5", [8] = "times8", [10] = "times10" }

--刷新开面
function FreePanel:RefreshCard( mode, msgData )
    dump( msgData, "FreePanel:RefreshCard" )
    self.loaderCard.visible = true
    self.loaderCard.url = "ui://Game485/FreeSelect_Item"
    self.loaderCard.component:GetController("mode").selectedPage = mode

    msgData.scales = msgData.scales or {}
    table.sort(msgData.scales,function (a,b)
        return a < b
    end)

    if mode == "cardrandom" and 
       #msgData.scales>0 and cfgFreeTimes[msgData.scales[1]] and 
       cfgFreeNum[msgData.times] then
        self.loaderCard.component:GetController("mode").selectedPage = "cardcustom"
        self.loaderCard.component:GetController( "modefree" ).selectedPage = cfgFreeNum[msgData.times]
        self.loaderCard.component:GetController( "modetimes" ).selectedPage = cfgFreeTimes[msgData.scales[1]]
    else
        self.loaderCard.component:GetController( "modefree" ).selectedPage = "freeno"
        self.loaderCard.component:GetController( "modetimes" ).selectedPage = "timesno"
    end
end

--结算赢钱
function FreePanel:ShowTotalWin( value )
    self.render:GetTransition("win_show"):Play( function ()
        self.upWin = false        
    end)
end

--显示翻倍
function FreePanel:ShowDouble( value )
    self.uiNumDouble.text = value .. "x"
    self.render:GetTransition("double_show"):Play()
    if value >= 15 then
        FToolSet.PlayFGUISound("ui://Game485/UFCS_FG_MultiReveal_High")
    elseif value >= 8 then
        FToolSet.PlayFGUISound("ui://Game485/UFCS_FG_MultiReveal_Med")
    else
        FToolSet.PlayFGUISound("ui://Game485/UFCS_FG_MultiReveal_Low")
    end
end

--隐藏翻倍
function FreePanel:HideDouble()
    self.render:GetTransition("double_hide"):Play()
end

function FreePanel:__delete()
    self.render:RemoveFromParent(true)
end


return FreePanel