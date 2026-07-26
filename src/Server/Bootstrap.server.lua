local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function start()
	local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
	local DataService = require(script.Parent.Data.DataService)
	local TimeService = require(script.Parent.Time.TimeService)
	local FarmTeleportService = require(script.Parent.Teleport.FarmTeleportService)
	local FarmGridService = require(script.Parent.Farm.FarmGridService)
	local PortalService = require(script.Parent.Hub.PortalService)
	local ReturnPortalService = require(script.Parent.Farm.ReturnPortalService)
	local FarmWorldService = require(script.Parent.Farm.FarmWorldService)
	local HubWorldService = require(script.Parent.Hub.HubWorldService)
	local HubSeasonService = require(script.Parent.Hub.HubSeasonService)
	local HubInteractionService = require(script.Parent.Hub.HubInteractionService)
	local StudioSetup = require(script.Parent.Studio.StudioSetup)
	local PlayerStateService = require(script.Parent.Data.PlayerStateService)
	local SellService = require(script.Parent.Economy.SellService)
	local ShopService = require(script.Parent.Economy.ShopService)
	local ShipmentService = require(script.Parent.Economy.ShipmentService)

	DataService.init()
	TimeService.init()
	FarmTeleportService.init()
	FarmGridService.init()
	SellService.init()
	ShopService.init()
	ShipmentService.init()
	FarmWorldService.init()
	HubWorldService.init()
	HubSeasonService.init()
	HubAtmosphereService.init()
	HubInteractionService.init()
	PortalService.init()
	ReturnPortalService.init()
	StudioSetup.init()

	Players.PlayerAdded:Connect(function(player)
		DataService.waitForProfile(player)
		PlayerStateService.replicate(player)

		if PlaceType.isFarm() then
			local payload = FarmTeleportService.getTeleportPayload(player)
			if payload then
				print(`[Bootstrap] {player.Name} joined farm server {payload.accessCode}`)
			end
			FarmGridService.sendInitialGrid(player)
		end
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			DataService.waitForProfile(player)
			PlayerStateService.replicate(player)
			if PlaceType.isFarm() then
				FarmGridService.sendInitialGrid(player)
			end
		end)
	end

	local resolvedPlaceType = PlaceType.getCurrent()
	print(`[Bootstrap] StardewRB server started as {resolvedPlaceType}`)

	local debugInfo = PlaceType.getDebugInfo()
	print(
		`[Bootstrap] PlaceId={debugInfo.gamePlaceId} HubId={debugInfo.hubPlaceId} FarmId={debugInfo.farmPlaceId} GameAttr={debugInfo.gameAttribute} RsAttr={debugInfo.replicatedStorageAttribute} Project={debugInfo.projectPlaceType}`
	)

	if resolvedPlaceType == "Unknown" then
		warn("[Bootstrap] Place type is Unknown — set PlaceIds in GameConfig or use rojo serve farm.project.json")
	elseif resolvedPlaceType == "Hub" and debugInfo.projectPlaceType == "Farm" then
		warn("[Bootstrap] Farm project is synced but server resolved as Hub — check GameConfig place ids")
	elseif PlaceType.isFarm() and not workspace:FindFirstChild("FarmWorld") then
		warn("[Bootstrap] Farm place detected but FarmWorld was not created — check server output for errors")
	elseif PlaceType.isHub() and not workspace:FindFirstChild("HubWorld") then
		warn("[Bootstrap] Hub place detected but HubWorld was not created — check server output for errors")
	elseif PlaceType.isHub() then
		local hubWorld = workspace:FindFirstChild("HubWorld")
		local buildings = hubWorld and hubWorld:FindFirstChild("Buildings")
		if not buildings or #buildings:GetChildren() == 0 then
			warn(
				"[Bootstrap] HubWorld exists but Buildings folder is empty — pull latest hub branch, use rojo serve default.project.json, Stop then Play"
			)
		end
	end
end

local ok, err = xpcall(start, debug.traceback)
if not ok then
	warn("[Bootstrap] StardewRB failed to start:", err)
	error(err)
end
