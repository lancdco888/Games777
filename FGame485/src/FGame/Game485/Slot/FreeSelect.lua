-- 免费游戏模式选择界面
local Utils = Import(".Utils")
local FreeSelect = Class("FreeSelect")

function FreeSelect:ctor( parent, xy )
    self.render = FairyGUI.UIPackage.CreateObject("Game485", "FreeSelect")
    parent:AddChild( self.render )
    self.render.xy = xy
    self.render.scale = vec2(0.8,0.8)

    self.cfgCard = FCasinoCtx:GetGame().cfgCard

    --进入动画
    for _index, info in pairs( self.cfgCard ) do
        local render = self.render:GetChild( info.node )

        render:GetChild("card_1").visible = false
        render:GetController("mode").selectedPage = info.mode
        render:GetTransition( info.enterAnim ):Play( function ()
            APIGateway.AddEventListener( render:GetChild("btn"), FGUIEventKey.onClick, function()
                self:OnSelectMode( _index )
            end, true )
            if self.soundBg == nil then
                self.soundBg = FToolSet.PlayFGUISound("ui://Game485/UFCS_FG_WaitLoop")                
            end
        end )

        FToolSet.PlayFGUISound("ui://Game485/UFCS_FG_TransIn")

        self.cfgCard[_index].render = render
    end

    -- self.render:MakeFullScreen()
    -- FCasinoCtx:GetGame().render:AddChild(self.render)

    self:DelaySelect()
end

function FreeSelect:ShowPickOne( index, msgData )    
    if self.isShowPickOne then
        print("FreeSelect:ShowPickOne 已经运行")
        return
    end
    FToolSet.PlayFGUISound("ui://Game485/UFCS_FG_Touch")
    self.isShowPickOne = true
    for _index, info in pairs( self.cfgCard ) do
        local selectName = _index==index and 
                            self.cfgCard[_index].seleAnim or self.cfgCard[_index].notSeleAim
        self.cfgCard[_index].render:GetTransition( selectName ):Play()
    end

    --翻牌缩小2
    local function callOpeniiAim( cardRender )
        --隐藏
        local nodes = Utils.GetChildrenList( self.render )
        for _, node in pairs(nodes) do
            if node.name ~= cardRender.name then
                node.visible = false
            end
        end
        --动画
        if self.onCardCoverCallback then
            self.onCardCoverCallback( msgData )
            self.onCardCoverCallback = nil
        end
        local toPos = self.render:GetChild("pos_cardi").xy
        FTween.Start( cardRender,
            FTween.Delay(0.25, function() end),
            FTween.CallFunc(function()
                cardRender:GetTransition( self.cfgCard[index].openiiAim ):Play( function ()
                    if self.onCardDownCallback then
                        self.onCardDownCallback( self.cfgCard[index], msgData )
                        self.onCardDownCallback = nil
                        self:Delete()
                    end
                end)
            end),
            FTween.Parallel({
                FTween.To(FairyGUI.TweenPropType.Scale, cardRender.scale, vec2(1.1,1.1), 0.5 ),
                FTween.To(FairyGUI.TweenPropType.Position, cardRender.xy, toPos, 0.5),
            }),
            FTween.CallFunc(function()
                FCasinoCtx:GetGame():ShowEfStar( false )
            end)
        )
    end

    --翻牌放大1
    local function callOpeniAim( cardRender )
        FCasinoCtx:GetGame():DelayFunc(0.5, function ()
            FToolSet.PlayFGUISound("ui://Game485/UFCS_FG_CardFlipTransition")
        end)

        FCasinoCtx:GetGame():ShowEfStar( true )
        local count = 0
        local function _finishCall()
            count = count + 1
            if count == 2 then
                callOpeniiAim( cardRender )                
            end
        end
        cardRender:GetTransition( self.cfgCard[index].openiAim ):Play( function ()
            _finishCall()
        end)
        FTween.Start( cardRender,
            FTween.Parallel({
                FTween.To(FairyGUI.TweenPropType.Scale, cardRender.scale, vec2(1.35,1.35), 1 ),
                FTween.To(FairyGUI.TweenPropType.Y, cardRender.y, -60, 1),
            }),
            FTween.CallFunc(function()
                _finishCall()
            end)
        )
    end

    --选中
    local cardRender = self.cfgCard[index].render
    cardRender.sortingOrder = 20
    FTween.Start( cardRender,
        FTween.To(FairyGUI.TweenPropType.X, cardRender.x, self.render.width/2, 1.2),
        FTween.CallFunc(function()
            callOpeniAim( cardRender )
        end)
    )
end

function FreeSelect:OnSelectMode(index)
    print( "FreeSelect:OnSelectMode:"..index )
    APIGateway.StopSound( self.soundBg )

    if self.isSelect then return end
    self.isSelect = index

    local sendmsg = {
        _msgName_ = "PB.Client_Slots.FireLinkSelectType",
        type = index
    }
    APIGateway.SendExactRequest(sendmsg, "PB.Slots_Client.FireLinkSelectRet", function(ok, msg)
        if ok then
            dump( msg, "FreeSelect:OnSelectMode" )
            self:ShowPickOne( index, msg.selectType )
        else
            print("FreeSelect:OnSelectMode no ok")
            self.isSelect = nil
            self:DelaySelect()
        end
    end)
end

function FreeSelect:DelaySelect()
    local delay = 16

    local ids = {}
    for index, _ in pairs( self.cfgCard ) do
        table.insert( ids, index )
    end
    local selectIndex = ids[ math.random(1,#ids) ]

    if DebugSlots and cc then
        -- selectIndex = 4
        delay = 4*cc.Director:getInstance():getScheduler():getTimeScale()/3
    end

    FTween.Start( self.render, FTween.Delay( delay, function ()
        self:OnSelectMode( selectIndex )
    end ) )
end

function FreeSelect:__delete()
    self.onCardCoverCallback = nil
    self.onCardDownCallback = nil
    if APIGateway.IsInvalidObject( self.render ) then
        return
    end
    self.render:RemoveFromParent(true)
end

function FreeSelect:SetCardCoverCallback(cb)
    self.onCardCoverCallback = cb
end

function FreeSelect:SetCardDownCallback(cb)
    self.onCardDownCallback = cb
end


return FreeSelect