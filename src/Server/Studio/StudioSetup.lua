--[[
	Studio-only helpers for testing Hub vs Farm in a single unpublished place.
	Tag a part with "FarmPortal" in the Hub scene, or set game:SetAttribute("PlaceType", "Farm")
	to simulate the Farm spoke locally.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)

local StudioSetup = {}

function StudioSetup.init()
	if not game:GetService("RunService"):IsStudio() then
		return
	end

	if PlaceType.isFarm() then
		StudioSetup._ensureFarmSpawn()
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

return StudioSetup
