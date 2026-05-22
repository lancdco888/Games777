local AwardPopLayer = class("AwardPopLayer", function()
    return Tools.CreateLayer("csb/lobby/AwardPopLayer.csb")
end)

function AwardPopLayer:onEnter()
    self:InitUI()
end

function AwardPopLayer:InitUI()
    local _lang_tips = self:findChild("_lang_tips")
    _lang_tips:setString(TR("已自动加到金币"))
    local btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:Close()
    end, true)

    self.num = self:findChild("num")
    self.start_number = 0
    self.num:setString(Tools.CoinToShowString(self.start_number))
end

-- isCoin无效 根据配置显示
function AwardPopLayer:RunToSafeBoxNum(number,isCoin)
    local isbj = UserData.activity_give_type == 0
    if isbj then
        local coin = self:findChild("coin")
        coin:loadTexture("common/coin_2.png")
    end
    local t
    if number - self.start_number < 20 then
        t = 0.4
    else
        t = 1.0
    end

    self:RunToNumber(self.num, t, number)
end

--从一个数字变化到另外一个数字
function AwardPopLayer:RunToNumber(node, time, number)
	local from, to = self.start_number, number
    local MAX_TIMES = time*30 -- 最大变化次数 变成帧率2倍
    local lerp_value = to - from -- 插值
    if lerp_value == 0 then
        return
    end
    local times = 0 --准备变化多少次
    if lerp_value > MAX_TIMES then
        times = MAX_TIMES
    else
        times = lerp_value
    end 
    local delta = (lerp_value / times == 0) and 1 or lerp_value / times
    local index = 0     --当前第几次
    node:runAction(
        cc.Sequence:create(
            cc.Repeat:create(
                cc.Sequence:create(
                    cc.DelayTime:create(time/times),
                    cc.CallFunc:create(
                        function()
                            index = index + 1
                            local num = Tools.CoinToShowString(math.floor(from + delta*index))
                            node:setString(num)
                            if index >= times then
                                local num = Tools.CoinToShowString(math.floor(to))
                                local strTem = Tools.ShuZi_Exchangerate(to,true)
                                node:setString(num)
                            end
                        end
                    )
                ),
                times
            )
        )
    )
end

return AwardPopLayer
