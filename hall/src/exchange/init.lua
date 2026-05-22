RechargeLogic               = import(".RechargeLogic").new()
exutils                     = import(".exutils")

BankCardChoicePopUpLayer    = import(".exchange.BankCardChoicePopUpLayer")
BindCardOrPhoneLayer        = import(".exchange.BindCardOrPhoneLayer")
ConfirmBindLayer            = import(".exchange.ConfirmBindLayer")
ExchangeLayer               = import(".exchange.ExchangeLayer")
ExchangePopUpLayer          = import(".exchange.ExchangePopUpLayer")
RecordDatailsLayer          = import(".exchange.RecordDatailsLayer")
RecordExchangeLayer         = import(".exchange.RecordExchangeLayer")

BindCardAndPhoneLayer   = import(".exchange.BindCardAndPhoneLayer")
BindInfoLayer           = import(".exchange.BindInfoLayer")

LobbyRechargeLayer      = import(".exchange.LobbyRechargeLayer")
RechargeLayerPopup      = import(".exchange.RechargeLayerPopup")
RechargePopup_ind       = import(".exchange.RechargePopup_ind")
RechargePopup_ind2       = import(".exchange.RechargePopup_ind2")
RechargePopup_mm        = import(".exchange.RechargePopup_mm")
RechargePopup_VN        = import(".exchange.RechargePopup_VN")
BindVirtualCoinLayer    = import(".exchange.BindVirtualCoinLayer")
RechargePopup_VirtualCoin    = import(".exchange.RechargePopup_VirtualCoin")
RechargePopup_bankcard  = import(".exchange.RechargePopup_bankcard")

RechargePopup_rechargeCard = import(".exchange.RechargePopup_rechargeCard")
RechargePopup_tha_qr  = import(".exchange.RechargePopup_tha_qr")
WebLayer  = import(".exchange.WebLayer")

import(".GameInfoManager")

local requireRegion =  function ()
    local ok = pcall(
        function()
            require("hall.src.exchange.region." .. ConfigParam.Region)
        end
    )
    if not ok then
        require("hall.src.exchange.region.mm")
    end
end

requireRegion()
