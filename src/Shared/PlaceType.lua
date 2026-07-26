local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local PlaceType = {}

local function readAttributePlaceType(): string?
	for _, instance in { game, ReplicatedStorage } do
		local placeTypeAttr = instance:GetAttribute("PlaceType")
		if placeTypeAttr == "Farm" or placeTypeAttr == "Hub" then
			return placeTypeAttr
		end
	end

	return nil
end

local function readProjectPlaceType(): string?
	local placeConfigModule = ReplicatedStorage:FindFirstChild("PlaceConfig")
	if not placeConfigModule or not placeConfigModule:IsA("ModuleScript") then
		return nil
	end

	local ok, placeConfig = pcall(require, placeConfigModule)
	if not ok or type(placeConfig) ~= "table" then
		return nil
	end

	local placeType = placeConfig.placeType
	if placeType == "Farm" or placeType == "Hub" then
		return placeType
	end

	return nil
end

function PlaceType.getCurrent()
	local attributePlaceType = readAttributePlaceType()
	if attributePlaceType then
		return attributePlaceType
	end

	local projectPlaceType = readProjectPlaceType()
	if projectPlaceType then
		return projectPlaceType
	end

	if GameConfig.StudioPlaceTypeOverride == "Farm" then
		return "Farm"
	end
	if GameConfig.StudioPlaceTypeOverride == "Hub" then
		return "Hub"
	end

	local placeId = game.PlaceId

	-- Check farm before hub so a duplicated farm id in the hub slot still works.
	if GameConfig.Places.Farm.PlaceId ~= 0 and placeId == GameConfig.Places.Farm.PlaceId then
		return "Farm"
	end

	if GameConfig.Places.Hub.PlaceId ~= 0 and placeId == GameConfig.Places.Hub.PlaceId then
		return "Hub"
	end

	-- Two-place universe: if hub is configured and we're not on it, we're on the farm.
	if GameConfig.Places.Hub.PlaceId ~= 0 and placeId ~= GameConfig.Places.Hub.PlaceId then
		return "Farm"
	end

	-- Studio fallback when place ids are still zero.
	if RunService:IsStudio() then
		return "Hub"
	end

	return "Unknown"
end

function PlaceType.isHub()
	return PlaceType.getCurrent() == "Hub"
end

function PlaceType.isFarm()
	return PlaceType.getCurrent() == "Farm"
end

function PlaceType.getDebugInfo()
	return {
		gamePlaceId = game.PlaceId,
		hubPlaceId = GameConfig.Places.Hub.PlaceId,
		farmPlaceId = GameConfig.Places.Farm.PlaceId,
		gameAttribute = game:GetAttribute("PlaceType"),
		replicatedStorageAttribute = ReplicatedStorage:GetAttribute("PlaceType"),
		projectPlaceType = readProjectPlaceType(),
		resolved = PlaceType.getCurrent(),
	}
end

return PlaceType
