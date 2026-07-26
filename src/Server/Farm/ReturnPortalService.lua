local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local FarmTeleportService = require(script.Parent.Parent.Teleport.FarmTeleportService)

local ReturnPortalService = {}

local PORTAL_TAG = "HubPortal"

local function ensureDefaultPortal()
	if CollectionService:GetTagged(PORTAL_TAG)[1] then
		return
	end

	local portal = Instance.new("Part")
	portal.Name = "HubPortal"
	portal.Anchored = true
	portal.Size = Vector3.new(6, 10, 2)
	portal.Position = Vector3.new(-20, 5, 0)
	portal.Color = Color3.fromRGB(255, 180, 60)
	portal.Parent = workspace
	CollectionService:AddTag(portal, PORTAL_TAG)
end

function ReturnPortalService.init()
	if not PlaceType.isFarm() then
		return
	end

	ensureDefaultPortal()

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
