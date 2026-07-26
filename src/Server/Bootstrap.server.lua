local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local DataService = require(script.Parent.Data.DataService)
local TimeService = require(script.Parent.Time.TimeService)
local FarmTeleportService = require(script.Parent.Teleport.FarmTeleportService)
local FarmGridService = require(script.Parent.Farm.FarmGridService)
local PortalService = require(script.Parent.Hub.PortalService)
local ReturnPortalService = require(script.Parent.Farm.ReturnPortalService)
local FarmWorldService = require(script.Parent.Farm.FarmWorldService)
local StudioSetup = require(script.Parent.Studio.StudioSetup)
local PlayerStateService = require(script.Parent.Data.PlayerStateService)

local DataServiceModule = DataService
local TimeServiceModule = TimeService
local FarmTeleportServiceModule = FarmTeleportService
local FarmGridServiceModule = FarmGridService
local PortalServiceModule = PortalService

DataServiceModule.init()
TimeServiceModule.init()
FarmTeleportServiceModule.init()
FarmGridServiceModule.init()
FarmWorldService.init()
PortalServiceModule.init()
ReturnPortalService.init()
StudioSetup.init()

Players.PlayerAdded:Connect(function(player)
	DataServiceModule.waitForProfile(player)
	PlayerStateService.replicate(player)

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
		PlayerStateService.replicate(player)
		if PlaceType.isFarm() then
			FarmGridServiceModule.sendInitialGrid(player)
		end
	end)
end

print(`[Bootstrap] StardewRB server started as {PlaceType.getCurrent()}`)
