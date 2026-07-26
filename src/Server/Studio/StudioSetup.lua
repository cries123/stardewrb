--[[
	Studio-only helpers for testing Hub vs Farm in a single unpublished place.
	Tag a part with "FarmPortal" in the Hub scene, or set game:SetAttribute("PlaceType", "Farm")
	to simulate the Farm spoke locally.
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local PlaceType = require(ReplicatedStorage.Shared.PlaceType)

local StudioSetup = {}

function StudioSetup.init()
	if not game:GetService("RunService"):IsStudio() then
		return
	end

	if PlaceType.isFarm() then
		StudioSetup._ensureFarmSpawn()
	elseif PlaceType.isHub() then
		StudioSetup._ensureHubPortal()
	end
end

function StudioSetup._ensureFarmSpawn()
	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then
		baseplate.Transparency = 1
		baseplate.CanCollide = false
	end

	local spawn = workspace:FindFirstChild("FarmSpawn")
	if not spawn then
		spawn = Instance.new("SpawnLocation")
		spawn.Name = "FarmSpawn"
		spawn.Anchored = true
		spawn.Size = Vector3.new(6, 1, 6)
		spawn.Position = Vector3.new(0, 1, -10)
		spawn.Parent = workspace
	end
end

function StudioSetup._ensureHubPortal()
	if CollectionService:GetTagged("FarmPortal")[1] then
		return
	end

	local portal = Instance.new("Part")
	portal.Name = "FarmPortal"
	portal.Anchored = true
	portal.Size = Vector3.new(6, 10, 2)
	portal.Position = Vector3.new(0, 5, 0)
	portal.Color = Color3.fromRGB(120, 90, 255)
	portal.Parent = workspace
	CollectionService:AddTag(portal, "FarmPortal")
end

return StudioSetup
