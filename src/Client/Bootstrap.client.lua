local Client = script.Parent

local TimeClient = require(Client.Time.TimeClient)
local FarmClient = require(Client.Farm.FarmClient)
local HubClient = require(Client.Hub.HubClient)
local StardewHud = require(Client.UI.StardewHud)
local HubUi = require(Client.UI.HubUi)

TimeClient.init()
FarmClient.init()
HubClient.init()
StardewHud.init()
HubUi.init()
