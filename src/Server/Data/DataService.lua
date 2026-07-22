local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileService = require(ServerScriptService.Vendor.ProfileService)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local ProfileTemplate = require(ReplicatedStorage.Shared.ProfileTemplate)

local DataService = {}
DataService._profileStore = nil
DataService._profiles = {} -- [Player] = Profile

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, child in value do
		copy[key] = deepCopy(child)
	end
	return copy
end

function DataService.init()
	DataService._profileStore = ProfileService.GetProfileStore(
		GameConfig.DataStore.ProfileStoreName,
		deepCopy(ProfileTemplate)
	)

	Players.PlayerAdded:Connect(function(player)
		DataService._loadProfile(player)
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(DataService._loadProfile, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		DataService._releaseProfile(player)
	end)

	game:BindToClose(function()
		for player, _ in pairs(DataService._profiles) do
			DataService._releaseProfile(player)
		end
	end)
end

function DataService._loadProfile(player: Player)
	local profileKey = GameConfig.DataStore.ProfileKeyPrefix .. player.UserId
	local profile = DataService._profileStore:LoadProfileAsync(profileKey, "ForceLoad")

	if profile == nil then
		player:Kick("Failed to load player data. Please rejoin.")
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile:ListenToRelease(function()
		DataService._profiles[player] = nil
		if player.Parent then
			player:Kick("Your data session was released. Please rejoin.")
		end
	end)

	if player.Parent == nil then
		profile:Release()
		return
	end

	DataService._profiles[player] = profile
end

function DataService._releaseProfile(player: Player)
	local profile = DataService._profiles[player]
	if profile then
		profile:Release()
	end
	DataService._profiles[player] = nil
end

function DataService.waitForProfile(player: Player, timeout: number?)
	local deadline = os.clock() + (timeout or 15)
	while os.clock() < deadline do
		local profile = DataService._profiles[player]
		if profile and profile:IsActive() then
			return profile
		end
		if player.Parent == nil then
			return nil
		end
		task.wait(0.1)
	end
	return nil
end

function DataService.getProfile(player: Player)
	local profile = DataService._profiles[player]
	if profile and profile:IsActive() then
		return profile
	end
	return nil
end

function DataService.getData(player: Player)
	local profile = DataService.getProfile(player)
	if profile then
		return profile.Data
	end
	return nil
end

-- Releases the session lock before a cross-place teleport to prevent duplication.
function DataService.releaseForTeleport(player: Player): boolean
	local profile = DataService.getProfile(player)
	if not profile then
		return false
	end

	profile:Release()
	DataService._profiles[player] = nil
	return true
end

return DataService
