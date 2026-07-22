local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local PlaceType = {}

function PlaceType.getCurrent()
	local placeId = game.PlaceId

	if GameConfig.Places.Hub.PlaceId ~= 0 and placeId == GameConfig.Places.Hub.PlaceId then
		return "Hub"
	end

	if GameConfig.Places.Farm.PlaceId ~= 0 and placeId == GameConfig.Places.Farm.PlaceId then
		return "Farm"
	end

	-- Studio fallback: treat unpublished places using override or default Hub.
	if GameConfig.Places.Hub.PlaceId == 0 and GameConfig.Places.Farm.PlaceId == 0 then
		local runService = game:GetService("RunService")
		if runService:IsStudio() then
			if GameConfig.StudioPlaceTypeOverride == "Farm" then
				return "Farm"
			end
			if GameConfig.StudioPlaceTypeOverride == "Hub" then
				return "Hub"
			end
			local attr = game:GetAttribute("PlaceType")
			if attr == "Farm" then
				return "Farm"
			end
			return "Hub"
		end
	end

	return "Unknown"
end

function PlaceType.isHub()
	return PlaceType.getCurrent() == "Hub"
end

function PlaceType.isFarm()
	return PlaceType.getCurrent() == "Farm"
end

return PlaceType
