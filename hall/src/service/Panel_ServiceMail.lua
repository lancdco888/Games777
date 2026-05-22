local this = {}
this.stateGroupName = "Panel_ServiceMail"
this.stateName = "Panel_ServiceMail"

this.Open = function()
    this.default_ui_type = service.ServiceLogic.SERVICE

    local layer = PopLayer:Pop(service.ServiceMailLayer)
    PopLayer:SetCached(service.ServiceMailLayer, true)
    if layer then
        layer:ShowType(this.default_ui_type)
    end
end

this.Close = function()
end

return this
