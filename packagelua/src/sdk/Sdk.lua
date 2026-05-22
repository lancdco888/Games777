local Sdk = class("Sdk")

function Sdk:ctor() end
function Sdk:unload() end
function Sdk:login(user_id) end
function Sdk:registerCompleted() end
function Sdk:firstPurchase(amount) end
function Sdk:purchase(amount) end
function Sdk:firstOpen() end
function Sdk:refund(amount) end
function Sdk:safeWithdraw(amount) end
function Sdk:safeDeposit(amount) end
function Sdk:startTrial() end

return Sdk
