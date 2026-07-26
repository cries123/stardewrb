local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local GridMath = require(ReplicatedStorage.Shared.Grid.GridMath)
local PlaceType = require(ReplicatedStorage.Shared.PlaceType)

local FarmWorldService = {}

local PORTAL_TAG = "HubPortal"
local WORLD_FOLDER_NAME = "FarmWorld"

function FarmWorldService.init()
	if not PlaceType.isFarm() then
		return
	end

	FarmWorldService._clearDefaultSpawns()
	FarmWorldService._buildWorld()
end

function FarmWorldService._clearDefaultSpawns()
	for _, child in workspace:GetChildren() do
		if child:IsA("SpawnLocation") and child.Name ~= "FarmSpawn" then
			child:Destroy()
		end
	end

	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate then
		baseplate:Destroy()
	end
end

function FarmWorldService._getOrCreateFolder(): Folder
	local folder = workspace:FindFirstChild(WORLD_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = WORLD_FOLDER_NAME
		folder.Parent = workspace
	end
	return folder
end

function FarmWorldService._buildWorld()
	local folder = FarmWorldService._getOrCreateFolder()
	if folder:FindFirstChild("Platform") then
		return
	end

	local center = GridMath.getGridCenter()
	local platformSize = GameConfig.Farm.PlatformSize
	local wallHeight = GameConfig.Farm.WallHeight

	local platform = Instance.new("Part")
	platform.Name = "Platform"
	platform.Anchored = true
	platform.Size = Vector3.new(platformSize, 1, platformSize)
	platform.Position = center + Vector3.new(0, -0.5, 0)
	platform.Material = Enum.Material.Grass
	platform.Color = Color3.fromRGB(76, 120, 68)
	platform.CanQuery = false
	platform.Parent = folder

	FarmWorldService._createWalls(folder, center, platformSize, wallHeight)
	FarmWorldService._createSpawn(folder, center)
	FarmWorldService._createReturnPortal(folder, center)
end

function FarmWorldService._createWalls(folder: Folder, center: Vector3, platformSize: number, wallHeight: number)
	local half = platformSize / 2
	local wallThickness = 2

	local walls = {
		{ size = Vector3.new(platformSize + wallThickness, wallHeight, wallThickness), offset = Vector3.new(0, wallHeight / 2, half) },
		{ size = Vector3.new(platformSize + wallThickness, wallHeight, wallThickness), offset = Vector3.new(0, wallHeight / 2, -half) },
		{ size = Vector3.new(wallThickness, wallHeight, platformSize + wallThickness), offset = Vector3.new(half, wallHeight / 2, 0) },
		{ size = Vector3.new(wallThickness, wallHeight, platformSize + wallThickness), offset = Vector3.new(-half, wallHeight / 2, 0) },
	}

	for index, wallData in walls do
		local wall = Instance.new("Part")
		wall.Name = `BoundaryWall_{index}`
		wall.Anchored = true
		wall.CanCollide = true
		wall.Transparency = 0.4
		wall.Material = Enum.Material.Wood
		wall.Color = Color3.fromRGB(92, 64, 38)
		wall.Size = wallData.size
		wall.Position = center + wallData.offset
		wall.Parent = folder
	end
end

function FarmWorldService._createSpawn(folder: Folder, center: Vector3)
	local halfGrid = (GameConfig.Farm.GridWidth * GameConfig.Farm.CellSize) / 2
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "FarmSpawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = center + Vector3.new(0, 0.5, -halfGrid - 10)
	spawn.Material = Enum.Material.Cobblestone
	spawn.Color = Color3.fromRGB(140, 140, 140)
	spawn.Neutral = true
	spawn.Parent = folder
end

function FarmWorldService._createReturnPortal(folder: Folder, center: Vector3)
	if CollectionService:GetTagged(PORTAL_TAG)[1] then
		return
	end

	local halfGrid = (GameConfig.Farm.GridWidth * GameConfig.Farm.CellSize) / 2

	local portal = Instance.new("Part")
	portal.Name = "HubPortal"
	portal.Anchored = true
	portal.Size = Vector3.new(6, 10, 2)
	portal.Position = center + Vector3.new(-halfGrid - 8, 5, 0)
	portal.Color = Color3.fromRGB(255, 180, 60)
	portal.Material = Enum.Material.Neon
	portal.Parent = folder
	CollectionService:AddTag(portal, PORTAL_TAG)

	local sign = Instance.new("Part")
	sign.Name = "PortalSign"
	sign.Anchored = true
	sign.CanCollide = false
	sign.Size = Vector3.new(8, 2, 0.4)
	sign.Position = portal.Position + Vector3.new(0, 7, 0)
	sign.Color = Color3.fromRGB(55, 42, 32)
	sign.Parent = folder

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(200, 50)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = sign

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = "Return to Hub"
	label.TextColor3 = Color3.fromRGB(255, 230, 180)
	label.TextScaled = true
	label.Parent = billboard
end

return FarmWorldService
