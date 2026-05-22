local mdy_shell = class("mdy_shell", function()
    local node = cc.CSLoader:createNode("csb/MdyShell.csb")
    node:enableNodeEvents()
    return node
end)

function mdy_shell:ctor()
    self.closed = nil
    self.open1 = nil
    self.open2 = nil
    self.snake = nil
    self.coin = nil
    self.coin_bg = nil
end

function mdy_shell:onEnter()
    self.closed = self:findChild("closed"):hide()
    self.open1 = self:findChild("open1"):hide()
    self.open2 = self:findChild("open2"):hide()
    self.snake = self:findChild("snake"):hide()
    self.coin_bg = self:findChild("coin_bg"):hide()
    self.coin = self:findChild("coin"):hide()
    
    add_click_event(self.closed, function()
        if self.on_shell_clicked then
            self:on_shell_clicked()
        end
    end)
end

-- 展示关闭状态
function mdy_shell:close_shell()
    self.closed:setVisible(true)
    self.open1:setVisible(false)
    self.open2:setVisible(false)
    self.snake:setVisible(false)
    self.coin:setVisible(false)
    self.coin_bg:setVisible(false)

    self.closed:setTouchEnabled(true)
    self:setOpacity(255)
end

-- 播放点击效果
function mdy_shell:play_sel_ani()
    self.closed:runAction(
        cc.Sequence:create(
            cc.ScaleTo:create(0.1, 0.6),
            cc.DelayTime:create(0.05),
            cc.ScaleTo:create(0.08, 1)
        )
    )
end

-- 设置金币
-- coin == 0 时，展示毒蛇
-- is_selected 选中时, 展示高粱选中框
function mdy_shell:show_with_coin(coin, is_selected)
    self.closed:setVisible(false)
    self.open1:setVisible(not is_selected)
    self.open2:setVisible(is_selected)
    if coin == 0 then   --此处毒蛇
        self.snake:setVisible(true)
        self.coin:setVisible(false)
        self.coin_bg:setVisible(false)
    else
        self.snake:setVisible(false)
        self.coin:setVisible(true)
        -- self.coin:setString(Tools.CoinToShowString(coin))
        self.coin:setString(coin)
        self.coin_bg:setVisible(true)
    end
end

-- 展示未选中的 shell 金币动画
function mdy_shell:play_show_ani(delay)
    local scale = self.coin_bg:getScale()
    local scale2 = self.coin:getScale()
    self.coin:setScale(0)
    self.coin_bg:setScale(0)
    self:setOpacity(180)

    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(delay or 0.0),
        cc.CallFunc:create(function()
            self.coin_bg:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.2, 1.20 * scale),
                cc.ScaleTo:create(0.1, 1.0 * scale)
            ))
            self.coin:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.2, 1.20 * scale2),
                cc.ScaleTo:create(0.1, 1.0 * scale2)
            ))
        end)
    ))
end

return mdy_shell
