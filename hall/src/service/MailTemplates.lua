local MailTemplates = class("MailTemplates")

--此处TR只为标记, 以便工具提取翻译
local TR = function (str_)
    return str_
end

local templates = {
    {
        "mail_regist",
        TR("欢迎"),
        TR("欢迎NNN全新技术打造 多种捕鱼游戏大集合NNN多多推荐朋友来玩哦！")
    },
    {
        "mail_recover",
        TR("金币追回"),
        TR("您好，由于客服人员误操作，导致充值出现错误，现在触发系统金币追回保护功能：误充值[{total_recover_money}]金币,现已追回[{recover_money}]金币,已使用的[{money}]金币将不再进行追回,给您造成的不便，请您谅解。")
    },
    {
        "mail_gift_money_account",
        TR("赠送通知"),
        TR("玩家:  {account_id} 向你赠送 {money}金币，已存入您的保险箱，请查收！")
    },
    {
        "mail_account_gift_money",
        TR("赠送通知"),
        TR("您向玩家:  {account_id} 赠送 {money}金币，已存入他的保险箱，请悉知！")
    },
    {
        "mail_recharge_state_success",
        TR("充值通知"),
        TR("您的订单: {order_num},充值金额: {money} , 已充值成功！")
    },
    {
        -- 额外赠送绑定金币版本
        "mail_recharge_state_success_washcode",
        TR("充值通知"),
        TR("您的订单: {order_num},充值金额: {money} , 已充值成功，额外赠送 {washcode} 绑定金币！")
    },
    {
        "mail_recharge_state_fail",
        TR("充值通知"),
        TR("您的订单: {order_num},充值金额: {money} , 充值失败，失败原因：{msg}, 有任何疑问请联系客服！")
    },
    {
        "mail_return_coin",
        TR("退币消息"),
        TR("退币消息NNN订单号：{refund_id}NNN兑换金额{return_money}NNN已退回您的账户")
    },
    {
        "mail_refund_state_success",
        TR("兑换通知"),
        TR("恭喜您，兑换成功！NNN订单号：{refund_id}NNN申请时间{create_time}NNN详情请在兑换记录中查看！")
    },
    {
        "mail_refund_state_fail",
        TR("兑换通知"),
        TR("抱歉，兑换失败！NNN订单号：{refund_id}NNN申请时间{create_time}NNN详情请在兑换记录中查看！")
    }
}

function MailTemplates:GetTitle(key)
    local tmp = self:GetTemplate(key)
    if tmp then
        return tmp[2]
    else
        print("不存在的邮件模板 key:" .. tostring(key))
        return ""
    end
end

-- dict 为 占表 table
function MailTemplates:FormatContent(key, dict)
    -- 额外赠送绑定金币时，使用另外模板
    if key == "mail_recharge_state_success" and dict.washcode and dict.washcode > 0 then
        key = "mail_recharge_state_success_washcode"
    end

    local tmp = self:GetTemplate(key)
    if not tmp then
        print("不存在的邮件模板 key:" .. tostring(key))
        return ""
    end
    local content = TR_(tmp[3])
    print(content)
    for k, v in pairs(dict) do
        local a = "{" .. k .. "}"
        if a == "{return_money}" or a == "{total_recover_money}"
            or a == "{recover_money}" or  a == "{money}"
            or a == "{washcode}"
        then
            v = v / sGameManager.exchangerate
		end
		content = string.gsub(content, a, v)
    end
    -- 替换NNN为换行符
    content = string.gsub(content,"NNN","\n")
    return content
end

function MailTemplates:GetTemplate(key)
    for _,info in ipairs(templates) do
        if info[1] == key then
            return info
        end
    end
    return nil
end

function MailTemplates:AddTemplate(items)
    for _,item in ipairs(items) do
        table.insert(templates, item)
    end
end

return MailTemplates.new()
