local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local DataService = require(script.Data.DataService)
local TimeService = require(script.Time.TimeService)
local FarmTeleportService = require(script.Teleport.FarmTeleportService)
local FarmGridService = require(script.Farm.FarmGridService)
local PortalService = require(script.Hub.PortalService)
local StudioSetup = require(script.Studio.StudioSetup)

local DataServiceModule = DataService
local TimeServiceModule = TimeService
local FarmTeleportServiceModule = FarmTeleportService
local FarmGridServiceModule = FarmGridService
local PortalServiceModule = PortalService

DataServiceModule.init()
TimeServiceModule.init()
FarmTeleportServiceModule.init()
FarmGridServiceModule.init()
PortalServiceModule.init()
StudioSetup.init()

Players.PlayerAdded:Connect(function(player)
	DataServiceModule.waitForProfile(player)

	if PlaceType.isFarm() then
		local payload = FarmTeleportServiceModule.getTeleportPayload(player)
		if payload then
			print(`[Bootstrap] {player.Name} joined farm server {payload.accessCode}`)
		end
		FarmGridServiceModule.sendInitialGrid(player)
	end
end)

for _, player in Players:GetPlayers() do
	task.spawn(function()
		DataServiceModule.waitForProfile(player)
		if PlaceType.isFarm() then
			FarmGridServiceModule.sendInitialGrid(player)
		end
	end)
end

print(`[Bootstrap] StardewRB server started as {PlaceType.getCurrent()}`)
