local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local FarmTeleportService = require(script.Parent.Teleport.FarmTeleportService)

local PortalService = {}

local PORTAL_TAG = "FarmPortal"

function PortalService.init()
	if not PlaceType.isHub() then
		return
	end

	for _, portal in CollectionService:GetTagged(PORTAL_TAG) do
		PortalService._bindPortal(portal)
	end

	CollectionService:GetInstanceAddedSignal(PORTAL_TAG):Connect(function(portal)
		PortalService._bindPortal(portal)
	end)
end

function PortalService._bindPortal(portal: Instance)
	if not portal:IsA("BasePart") then
		warn(`[PortalService] Tagged instance {portal:GetFullName()} is not a BasePart`)
		return
	end

	local debounce = {}

	portal.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = game:GetService("Players"):GetPlayerFromCharacter(character)
		if not player or debounce[player] then
			return
		end

		debounce[player] = true
		task.delay(3, function()
			debounce[player] = nil
		end)

		FarmTeleportService.teleportPlayerToFarm(player)
	end)
end

return PortalService
