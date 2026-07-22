local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local DataService = require(script.Parent.Parent.Data.DataService)
local Remotes = require(script.Parent.Parent.Net.Remotes)

local FarmTeleportService = {}

local TELEPORT_DATA_KEY = "StardewRB"

function FarmTeleportService.init()
	if PlaceType.isHub() then
		Remotes.getEvent("TeleportToFarm").OnServerEvent:Connect(function(player)
			FarmTeleportService.teleportPlayerToFarm(player)
		end)

		Remotes.getFunction("InviteToFarm").OnServerInvoke = function(player, targetPlayer)
			return FarmTeleportService.inviteFriendToFarm(player, targetPlayer)
		end
	end

	TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
		warn(`[FarmTeleport] Init failed for {player.Name}: {result} {errorMessage}`)
		Remotes.getEvent("TeleportResult"):FireClient(player, false, tostring(result))
	end)
end

function FarmTeleportService._buildTeleportData(player: Player, accessCode: string)
	return {
		[TELEPORT_DATA_KEY] = {
			userId = player.UserId,
			accessCode = accessCode,
			sentAt = os.time(),
		},
	}
end

function FarmTeleportService._getOrCreateAccessCode(player: Player, data)
	if data.FarmState.PrivateServerCode then
		return data.FarmState.PrivateServerCode
	end

	local farmPlaceId = GameConfig.Places.Farm.PlaceId
	if farmPlaceId == 0 then
		error("GameConfig.Places.Farm.PlaceId is not configured")
	end

	local accessCode = TeleportService:ReserveServer(farmPlaceId)
	data.FarmState.PrivateServerCode = accessCode
	return accessCode
end

function FarmTeleportService.teleportPlayerToFarm(player: Player)
	local profile = DataService.waitForProfile(player)
	if not profile then
		Remotes.getEvent("TeleportResult"):FireClient(player, false, "Profile not loaded")
		return
	end

	local data = profile.Data
	local farmPlaceId = GameConfig.Places.Farm.PlaceId

	if farmPlaceId == 0 then
		Remotes.getEvent("TeleportResult"):FireClient(player, false, "Farm place is not configured")
		return
	end

	local success, accessCodeOrError = pcall(function()
		return FarmTeleportService._getOrCreateAccessCode(player, data)
	end)

	if not success then
		Remotes.getEvent("TeleportResult"):FireClient(player, false, tostring(accessCodeOrError))
		return
	end

	local accessCode = accessCodeOrError
	local teleportData = FarmTeleportService._buildTeleportData(player, accessCode)

	if not DataService.releaseForTeleport(player) then
		Remotes.getEvent("TeleportResult"):FireClient(player, false, "Failed to release data session")
		return
	end

	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = accessCode
	teleportOptions:SetTeleportData(teleportData)

	local ok, err = pcall(function()
		TeleportService:TeleportAsync(farmPlaceId, { player }, teleportOptions)
	end)

	if not ok then
		warn(`[FarmTeleport] TeleportAsync failed: {err}`)
		Remotes.getEvent("TeleportResult"):FireClient(player, false, tostring(err))
	end
end

function FarmTeleportService.inviteFriendToFarm(hostPlayer: Player, guestPlayer: Player)
	if typeof(guestPlayer) ~= "Instance" or not guestPlayer:IsA("Player") then
		return false, "Invalid guest player"
	end

	if guestPlayer == hostPlayer then
		return false, "Cannot invite yourself"
	end

	local profile = DataService.getProfile(hostPlayer)
	if not profile then
		return false, "Host profile not loaded"
	end

	local accessCode = profile.Data.FarmState.PrivateServerCode
	if not accessCode then
		return false, "Host has no active farm server. Enter your farm first."
	end

	local farmPlaceId = GameConfig.Places.Farm.PlaceId
	if farmPlaceId == 0 then
		return false, "Farm place is not configured"
	end

	local guestProfile = DataService.waitForProfile(guestPlayer, 5)
	if not guestProfile then
		return false, "Guest profile not loaded"
	end

	if not DataService.releaseForTeleport(guestPlayer) then
		return false, "Failed to release guest data session"
	end

	local teleportData = FarmTeleportService._buildTeleportData(guestPlayer, accessCode)
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = accessCode
	teleportOptions:SetTeleportData(teleportData)

	local ok, err = pcall(function()
		TeleportService:TeleportAsync(farmPlaceId, { guestPlayer }, teleportOptions)
	end)

	if not ok then
		return false, tostring(err)
	end

	return true, "Teleporting guest to farm"
end

function FarmTeleportService.getTeleportPayload(player: Player)
	local joinData = player:GetJoinData()
	local teleportData = joinData and joinData.TeleportData
	if typeof(teleportData) ~= "table" then
		return nil
	end
	return teleportData[TELEPORT_DATA_KEY]
end

return FarmTeleportService
