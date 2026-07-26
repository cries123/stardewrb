--[[
	Nature props: layered trees, lamp posts, thin path decals.
]]

local HubNatureKit = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HubLayout = require(ReplicatedStorage.Shared.Hub.HubLayout)
local GROUND_Y = HubLayout.GROUND_Y

local SEASON_ATTR = "HubSeasonPart"
local LAMP_TAG = "HubStreetLamp"

function HubNatureKit.getLampTag(): string
	return LAMP_TAG
end

function HubNatureKit.markSeasonPart(part: BasePart, partType: string)
	part:SetAttribute(SEASON_ATTR, partType)
end

function HubNatureKit.createTree(parent: Instance, name: string, position: Vector3)
	local base = position + Vector3.new(0, GROUND_Y, 0)

	local trunk = Instance.new("Part")
	trunk.Name = `{name}_Trunk`
	trunk.Anchored = true
	trunk.Shape = Enum.PartType.Cylinder
	trunk.Size = Vector3.new(1.8, 7, 1.8)
	trunk.CFrame = CFrame.new(base + Vector3.new(0, 3.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
	trunk.Color = Color3.fromRGB(102, 72, 44)
	trunk.Material = Enum.Material.Wood
	trunk.Parent = parent
	HubNatureKit.markSeasonPart(trunk, "TreeTrunk")

	local foliageSizes = { 8, 6, 4.5 }
	local foliageOffsets = { 8.5, 10.5, 12 }
	for index, radius in foliageSizes do
		local foliage = Instance.new("Part")
		foliage.Name = `{name}_Foliage_{index}`
		foliage.Anchored = true
		foliage.Shape = Enum.PartType.Ball
		foliage.Size = Vector3.new(radius, radius, radius)
		foliage.Position = base + Vector3.new(0, foliageOffsets[index], 0)
		foliage.Color = Color3.fromRGB(72, 150, 68)
		foliage.Material = Enum.Material.Grass
		foliage.CanCollide = false
		foliage.Parent = parent
		HubNatureKit.markSeasonPart(foliage, "TreeFoliage")
	end
end

function HubNatureKit.createLampPost(parent: Instance, position: Vector3, index: number)
	local base = position + Vector3.new(0, GROUND_Y, 0)
	local folder = Instance.new("Folder")
	folder.Name = `LampPost_{index}`
	folder.Parent = parent

	local pole = Instance.new("Part")
	pole.Name = "Pole"
	pole.Anchored = true
	pole.Size = Vector3.new(0.6, 10, 0.6)
	pole.Position = base + Vector3.new(0, 5, 0)
	pole.Color = Color3.fromRGB(40, 40, 45)
	pole.Material = Enum.Material.Metal
	pole.Parent = folder

	local arm = Instance.new("Part")
	arm.Name = "Arm"
	arm.Anchored = true
	arm.Size = Vector3.new(2.5, 0.4, 0.4)
	arm.Position = base + Vector3.new(1, 9.8, 0)
	arm.Color = Color3.fromRGB(40, 40, 45)
	arm.Material = Enum.Material.Metal
	arm.Parent = folder

	local lamp = Instance.new("Part")
	lamp.Name = "Lamp"
	lamp.Anchored = true
	lamp.Size = Vector3.new(1.4, 0.8, 1.4)
	lamp.Position = base + Vector3.new(2.2, 9.6, 0)
	lamp.Color = Color3.fromRGB(255, 220, 150)
	lamp.Material = Enum.Material.Neon
	lamp.Transparency = 0.2
	lamp.Parent = folder
	lamp:SetAttribute(LAMP_TAG, true)

	local light = Instance.new("PointLight")
	light.Name = "LampLight"
	light.Brightness = 0
	light.Range = 22
	light.Color = Color3.fromRGB(255, 210, 140)
	light.Parent = lamp
	light:SetAttribute(LAMP_TAG, true)
end

function HubNatureKit.createPathSegment(parent: Instance, index: number, position: Vector3, size: Vector3)
	local path = Instance.new("Part")
	path.Name = `Path_{index}`
	path.Anchored = true
	path.Size = Vector3.new(size.X, 0.12, size.Z)
	path.Position = position + Vector3.new(0, GROUND_Y + 0.08, 0)
	path.Material = Enum.Material.Cobblestone
	path.Color = Color3.fromRGB(148, 132, 108)
	path.CanCollide = false
	path.Parent = parent
	HubNatureKit.markSeasonPart(path, "Path")

	local decal = Instance.new("Texture")
	decal.Face = Enum.NormalId.Top
	decal.Transparency = 0.15
	decal.StudsPerTileU = 4
	decal.StudsPerTileV = 4
	decal.Texture = "rbxasset://textures/terrain/rockyground.png"
	decal.Parent = path
end

function HubNatureKit.createFenceLine(parent: Instance, startPos: Vector3, endPos: Vector3, index: number)
	local direction = endPos - startPos
	local length = direction.Magnitude
	local mid = startPos + direction / 2
	local count = math.max(2, math.floor(length / 4))

	for i = 0, count do
		local alpha = i / count
		local pos = startPos:Lerp(endPos, alpha) + Vector3.new(0, 3, 0)
		local post = Instance.new("Part")
		post.Name = `FencePost_{index}_{i}`
		post.Anchored = true
		post.Size = Vector3.new(0.5, 3, 0.5)
		post.Position = pos + Vector3.new(0, 1.5, 0)
		post.Color = Color3.fromRGB(102, 72, 44)
		post.Material = Enum.Material.Wood
		post.Parent = parent
	end
end

function HubNatureKit.createFlowerPatch(parent: Instance, position: Vector3, index: number)
	local base = position + Vector3.new(0, GROUND_Y, 0)
	for patch = 1, 5 do
		local flower = Instance.new("Part")
		flower.Name = `Flower_{index}_{patch}`
		flower.Anchored = true
		flower.Shape = Enum.PartType.Ball
		flower.Size = Vector3.new(1.1, 1.1, 1.1)
		flower.Position = base + Vector3.new((patch - 3) * 1.2, 0.6, ((patch % 2) * 2 - 1) * 0.8)
		flower.Material = Enum.Material.Grass
		flower.Color = Color3.fromRGB(240, 140, 180)
		flower.CanCollide = false
		flower.Parent = parent
		HubNatureKit.markSeasonPart(flower, "Flower")
	end
end

return HubNatureKit
