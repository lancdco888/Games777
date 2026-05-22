local AwardHistoryItem = Class("AwardHistoryItem")

function AwardHistoryItem:ctor(render,data)
    self.render = render
    if data.icon ~= 9 and data.icon ~= 10 then
        self:initUIItem(data)
    end
end


function AwardHistoryItem:initUIItem(data)
    self.icon_loader = self.render:GetChild("icon_loader")
    self.lbl_count = self.render:GetChild("lbl_count")
    self.lbl_score = self.render:GetChild("lbl_score")

    
    self.icon_loader.url = data.iconUrl
    self.lbl_count.text = tostring(data.count)
    self.lbl_score.text = tostring(data.score)
end

return AwardHistoryItem