local Client = script.Parent

local TimeClient = require(Client.Time.TimeClient)
local FarmClient = require(Client.Farm.FarmClient)
local HubClient = require(Client.Hub.HubClient)
local HubInteractionClient = require(Client.Hub.HubInteractionClient)
local StardewHud = require(Client.UI.StardewHud)
local HubUi = require(Client.UI.HubUi)
local HubShopUi = require(Client.UI.HubShopUi)
local ShippingBinUi = require(Client.UI.ShippingBinUi)

TimeClient.init()
FarmClient.init()
HubClient.init()
HubInteractionClient.init()
StardewHud.init()
HubUi.init()
HubShopUi.init()
ShippingBinUi.init()
