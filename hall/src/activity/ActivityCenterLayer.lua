local ActivityCenterLayer = class("ActivityCenterLayer", function()
    return Tools.CreateLayer("csb/lobby/ActivityCenterLayer.csb")
end)

function ActivityCenterLayer:onEnter()
	self:InitUI()
    self:AdjustUI()
end

function ActivityCenterLayer:InitUI()
    local btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:Close()
    end, true)

    
    local btns = self:findChild("btns")
    local btn_cell = btns:getChildByName("cell")
    btn_cell:retain()
    btns:removeAllItems()
    
    local content = self:findChild("content")
    local content_cell = content:getChildByName("cell")
    content_cell:retain()
    content:removeAllItems()
    -- content:addEventListener(
    --     function (_,type)
    --         if type == 1 then
    --             -- body
    --         end
    
    --     end
    -- )
    local acts = {}
    
    if activity.logic:IsOpenFirstRecharge() then
        table.insert(
        acts, {
            name = TR("首充"),
            layer = activity.RechargeFirstLayer,
            dotFunc = function()
                return false
            end,
            updateFunc = function(layer)
            end,
            scale = sGameManager.Uicfg.RechargeFirstLayer or 0.7,
            y_shifting = sGameManager.Uicfg.RechargeF_Y or -50,
            x_shifting = sGameManager.Uicfg.RechargeF_X or 0,
        }
        )
    end

    if activity.logic:IsScreenshotOpen() and activity.SpreadLogic:SupportSaveToPhoto() then
        table.insert(acts, {
            name = TR("官方地址"),
            layer = activity.SpreadLayer,
            closeFunc = function ()
                self:Close()
            end,
            dotFunc = function()
                return false
            end,
            updateFunc = function(layer)
            end,
            scale = sGameManager.Uicfg.SpreadLayer or 0.8,
            y_shifting = sGameManager.Uicfg.Spread_Y or -50,
            x_shifting = sGameManager.Uicfg.Spread_X or 0,
        }
    )
    end

    local rebate_ids = activity.logic:GetRebateIds()
    for __, rebate_id in ipairs(rebate_ids) do
        if activity.logic:IsRebateOpen(rebate_id) then
            table.insert(acts, {
                name = TR("VIP福利"),
                layer = activity.RebateLayer,
                closeFunc = function ()
                    self:Close()
                end,
                dotFunc = function()
                    return activity.logic:CanGiveByID(rebate_id)
                end,
                initFunc = function(layer)
                    layer:setRebateId(rebate_id)
                end,
                updateFunc = function(layer)
                    layer:InitUI()
                end,
                scale = sGameManager.Uicfg.RebateLayer or 0.7,
                y_shifting = sGameManager.Uicfg.Rebate_Y or -50,
                x_shifting = sGameManager.Uicfg.Rebate_X or 0,
            })
        end
    end

    local left_btns = {}
    for index, act in ipairs(acts) do
        local btn_cell_clone = btn_cell:clone()
        local name = btn_cell_clone:findChild("name")
        name:setString(act.name)
        btns:pushBackCustomItem(btn_cell_clone)
        local btn = btn_cell_clone:findChild("btn")
        table.insert(left_btns,btn)
        btn:addTouchEventListener(
            function(btn, type)
                if type == ccui.TouchEventType.ended then
                    gSound.clickSound()
                    for _, b in pairs(left_btns) do
                        local isself = b == btn
                        b:setEnabled(not isself)
	                    b:setBright(not isself)
                    end
                    content:scrollToItem(index-1,cc.p(0, 0), cc.p(0, 0))
                end
            end
        )
        local content_cell_clone = content_cell:clone()
        local layer = act.layer.new()
        layer:SetCloseFunc(false, act.closeFunc)
        content_cell_clone:addChild(layer)
        content:pushBackCustomItem(content_cell_clone)
        local conts = content_cell_clone:getContentSize()
        layer:setScale(act.scale or 1.0)
        layer:setAnchorPoint(0.5,0.5)
        layer:setPosition(cc.p(conts.width/2 + act.x_shifting,conts.height/2 + act.y_shifting))
        if layer.showCenterTitle then
            layer:showCenterTitle(true)
        end
        if act.initFunc then
            act.initFunc(layer)
        end

        -- 保存 button 用作红点控制
        act.button = btn
        act.layer = layer
    end
    if #left_btns > 0 then
        left_btns[1]:setEnabled(false)
        left_btns[1]:setBright(false)
    end
    
    btn_cell:release()
    content_cell:release()
    self.content = content

    self.activities = acts
    self:UpdateDot()

    Dispatcher:Register(activity.logic,
        function()
            self:UpdateDot()
            self:UpdateLayers()
        end,
        self
    )

    go(function()
        activity.logic:ReqRebateCanGives()

        if tolua.isnull(self) then return end
        self:UpdateDot()
        self:UpdateLayers()
    end)
end

function ActivityCenterLayer:UpdateLayers()
    for _, act in ipairs(self.activities) do
        local updateFunc = act.updateFunc
        local layer = act.layer
        if updateFunc and layer then
            updateFunc(layer)
        end
    end
end

function ActivityCenterLayer:UpdateDot()
    for _, act in ipairs(self.activities) do
        local button = act.button
        local dotFunc = act.dotFunc
        local show_dot
        if not dotFunc then
            show_dot = false
        else
            show_dot = dotFunc()
        end
        local dot_node = button:findChild("tip")
        if dot_node then
            dot_node:setVisible(show_dot)
        end
    end
end

function ActivityCenterLayer:AdjustUI()
    local scaleX = Def.ScaleX / Def.ScaleMin
    local scaleY = Def.ScaleY / Def.ScaleMin
    local bg = self:findChild("bg")
    if bg then
        bg:setScaleX(scaleX)
        bg:setScaleY(scaleY)
    end
    local btns = self:findChild("btns")
    if btns then
        local x,y = btns:getPosition()
        btns:setPosition(x*scaleX, y*scaleY)
    end
    local btn_close = self:findChild("btn_close")
    if btn_close then
        local x,y = btn_close:getPosition()
        btn_close:setPosition(x*scaleX, y*scaleY)
    end
end

return ActivityCenterLayer
