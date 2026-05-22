local OtherPanel = Class("OtherPanel")
function OtherPanel:ctor(render,game)
    self.render = render
    self.game = game
    self.freecountpanel = self.render:GetChild("freecountpanel")
    self.silkbagpanel = self.render:GetChild("silkbagpanel")
    self.flowerpanel = self.render:GetChild("flowerpanel")
    self.redbagPanel = self.render:GetChild("redbagPanel")
end


function OtherPanel:__delete()
   self.render:RemoveFromParent(true)
end

function OtherPanel:SetCount(count,allcount)
    if not count then
        self.freecountpanel.visible = false
        return
    end
    self.freecountpanel.visible = true
    self.freecountpanel:GetChild("free_count").text = count.."/"..allcount
end
function OtherPanel:showsilkbagpanel(wildmultipl,callback)
    callback = callback or function () end
    if not wildmultipl then
        self.silkbagpanel.visible = false
        return
    end
    self.silkbagpanel.visible = true
    self.silkbagpanel:GetChild("bao_multipl").url = "ui://Game465/multiplx"..wildmultipl
    self.silkbagpanel:GetTransition("showanim"):Play(function ()
        callback()
   end)
end
function OtherPanel:showflowerpanel(wildmultipl,callback)
    callback = callback or function () end
    if not wildmultipl then
        self.flowerpanel.visible = false
        return
    end
    self.flowerpanel.visible = true
    self.flowerpanel:GetChild("flower_multipl").url = "ui://Game465/multiplx"..wildmultipl
    self.flowerpanel:GetTransition("showanim"):Play(function ()
        callback()
   end)
end
function OtherPanel:showredbagPanel(wildmultipl,callback,recover)
    callback = callback or function () end
    if not wildmultipl then
        self.redbagPanel.visible = false
        return
    end
    self.redbagPanel.visible = true
    self.redbagPanel:GetChild("newfreetime").text = "X"..wildmultipl
    if recover then
        callback()
        self.redbagPanel:GetTransition("recoveranim"):Play()
    else
        self.redbagPanel:GetTransition("showanim"):Play(function ()
            callback()
       end)
    end
end

return OtherPanel