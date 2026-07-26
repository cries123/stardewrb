local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local FarmTeleportService = require(script.Parent.Parent.Teleport.FarmTeleportService)

local ReturnPortalService = {}

local PORTAL_TAG = "HubPortal"

function ReturnPortalService.init()
	if not PlaceType.isFarm() then
		return
	end

	for _, portal in CollectionService:GetTagged(PORTAL_TAG) do
		ReturnPortalService._bindPortal(portal)
	end

	CollectionService:GetInstanceAddedSignal(PORTAL_TAG):Connect(function(portal)
		ReturnPortalService._bindPortal(portal)
	end)
end

function ReturnPortalService._bindPortal(portal: Instance)
	if not portal:IsA("BasePart") then
		warn(`[ReturnPortalService] Tagged instance {portal:GetFullName()} is not a BasePart`)
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

		FarmTeleportService.teleportPlayerToHub(player)
	end)
end

return ReturnPortalService
