local AwardsHistoryPanel = Class("AwardsHistoryPanel")
local AwardHistoryItem = Import(".AwardHistoryItem")

function AwardsHistoryPanel:ctor(render,game)
    self.game = game
    self.render = render

    self.aniContainer = render:GetChild("aniContainer"):GetChild("n0")

    self.aniContainer:RemoveChildren()

    self.itemsBaseY = 128
    self.itemsDiffY = 32
    self.itemsViewCount = 5
end

function AwardsHistoryPanel:SetCurAwardsData(data)
    self.awardsData = data
    self.matchLen = #data
    self.matchSequence = 1
    self.matchedSymbolCount = 0
    self.curAwardData = {}
    self.hasDownEntireDistance = 0
end

function AwardsHistoryPanel:ClearView()
    self.aniContainer:RemoveChildren()
end

function AwardsHistoryPanel:ShowNewItemAnimation()
    local newItemsData = self.awardsData[self.matchSequence]

    -- if #self.curAwardData >= self.itemsViewCount and #self.curAwardData % self.itemsViewCount == 0 then
    --[[ if #self.curAwardData >= self.itemsViewCount then
        local remainCount = #newItemsData
        if remainCount > 0 then
            remainCount = remainCount > self.itemsViewCount and self.itemsViewCount or remainCount
            self.aniContainer.y = self.aniContainer.y + remainCount * self.itemsDiffY
            self.hasDownEntireDistance = self.hasDownEntireDistance + remainCount * self.itemsDiffY
        end
    end ]]


    if newItemsData == nil then
        return
    end
    for _, itemData in ipairs(newItemsData) do
        table.insert(self.curAwardData, itemData)


        if #self.curAwardData > self.itemsViewCount then
            -- local remainCount = #newItemsData
            -- if remainCount > 0 then
            --     remainCount = remainCount > self.itemsViewCount and self.itemsViewCount or remainCount
                self.aniContainer.y = self.aniContainer.y + self.itemsDiffY
                self.hasDownEntireDistance = self.hasDownEntireDistance + self.itemsDiffY
            -- end
        end 

        local listViewItem = FairyGUI.UIPackage.CreateObject("Game481","AwardHistoryItem")
        AwardHistoryItem.New(listViewItem,itemData)
        self.aniContainer:AddChild(listViewItem)
        listViewItem.y = -32 - self.hasDownEntireDistance
        
        local targetY = self.itemsBaseY - self.matchedSymbolCount * self.itemsDiffY
    
        FTween.Start(
            listViewItem,
            FTween.To(FairyGUI.TweenPropType.Y, listViewItem.y, targetY, 0.3),
            FTween.CallFunc(function()
            end)
        )
        self.matchedSymbolCount = self.matchedSymbolCount + 1
    end
    self.matchSequence = self.matchSequence + 1
    
end

function AwardsHistoryPanel:ResetListView()
    local childrenLen = self.aniContainer.numChildren
    for i = 0, childrenLen - 1 do
        local child = self.aniContainer:GetChildAt(i)
        local targetY = child.y + self.aniContainer.height + 50 -- Move below viewport
        FTween.Start(
            child,
            FTween.Delay(i * 0.05), -- Add delay based on index
            FTween.To(FairyGUI.TweenPropType.Y, child.y, targetY, 0.3),
            FTween.CallFunc(function()
                -- Remove child after tween completes
                if i == childrenLen - 1 then
                    -- Reset aniContainer y position when all items are removed
                    self.aniContainer.y = 0
                end
                self.aniContainer:RemoveChild(child)
            end)
        )
    end
end

return AwardsHistoryPanel