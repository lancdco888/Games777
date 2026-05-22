local GiveHistoryLayer = class("GiveHistoryLayer", function()
    return Tools.CreateLayer('csb/Give/GiveHistoryLayer.csb')
end)

function GiveHistoryLayer:ctor()
    self.records = {}           --所有记录
end

function GiveHistoryLayer:onEnter()
    self:InitUI()
    -- Tools.AdjustUI(self)
end

function GiveHistoryLayer:InitUI()
   --关闭
   local btn_close = self:findChild("btn_close")
   Tools.AddClickEvent(btn_close, function()
       self:Close()
   end, true)

   self.btn_give = self:findChild("btn_give")
   Tools.AddClickEvent(self.btn_give, function()
       self:OnBtnGiveClick()
   end, false)
   


   self.btn_receive = self:findChild("btn_receive")
   Tools.AddClickEvent(self.btn_receive, function()
       self:OnBtnReciveClick()
   end, false)

   local list = self:findChild("list")
   local item = list:findChild("item")
   self.list = cc.TableListViewPro.new(list,item)
   self.list:setLoadCellFun(handler(self,self.SetRecordInfo))
   self:OnBtnGiveClick()
end

function GiveHistoryLayer:OnBtnGiveClick()
    self.btn_give:setEnabled(false)
    self.btn_receive:setEnabled(true)
    self.bGive = true
    self:UpdateList()
end

function GiveHistoryLayer:OnBtnReciveClick()
    self.btn_give:setEnabled(true)
    self.btn_receive:setEnabled(false)
    self.bGive = false
    self:UpdateList()
end

--设置记录列表
function GiveHistoryLayer:SetRecordList(show_records)
    self.records = show_records
    self.list:setData(self.records)
end

function GiveHistoryLayer:SetRecordInfo(cell, index)
    local item = cell:getChildByName("item")
	local record = self.records[index]

    local account = item:findChild("account")

    if self.bGive then
        account:setString(record.received_account_id)
    else
        account:setString(record.give_account_id)
    end

    local show_money = record.money
    show_money = math.abs(show_money)

    local money = item:findChild("money")
    money:setString(tostring(Tools.CoinToString(show_money)))
    local date = item:findChild("date")
    local str = Tools.FormatTime(record.create_time)
    date:setString(str)
end

--------------------------------------------------------

function GiveHistoryLayer:SetRecords(result)
    self.giftRecords = result.gift_record
    self.reciveRecords = result.receive_record
    if self.list then
        self:UpdateList()
    end
end

function GiveHistoryLayer:UpdateList()
    local records
    if self.bGive then
        records = self.giftRecords or {}
    else
        records = self.reciveRecords or {}
    end
    -- dump(records)
    self:SetRecordList(records)
end

return GiveHistoryLayer
