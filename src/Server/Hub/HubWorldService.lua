local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local HubLayout = require(ReplicatedStorage.Shared.Hub.HubLayout)
local PlaceType = require(ReplicatedStorage.Shared.PlaceType)

local HubWorldService = {}

local WORLD_FOLDER_NAME = "HubWorld"
local FARM_PORTAL_TAG = "FarmPortal"
local SEASON_ATTR = "HubSeasonPart"

function HubWorldService.init()
	if not PlaceType.isHub() then
		return
	end

	HubWorldService._clearDefaultSpawns()
	HubWorldService._buildWorld()
end

function HubWorldService._clearDefaultSpawns()
	for _, child in workspace:GetChildren() do
		if child:IsA("SpawnLocation") and child.Name ~= "HubSpawn" then
			child:Destroy()
		end
	end

	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate then
		baseplate:Destroy()
	end
end

function HubWorldService._getOrCreateFolder(): Folder
	local folder = workspace:FindFirstChild(WORLD_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = WORLD_FOLDER_NAME
		folder.Parent = workspace
	end
	return folder
end

function HubWorldService._buildWorld()
	local folder = HubWorldService._getOrCreateFolder()
	if folder:FindFirstChild("Ground") then
		return
	end

	local hubConfig = GameConfig.Hub
	local center = hubConfig.Origin
	local platformSize = hubConfig.PlatformSize

	local groundFolder = Instance.new("Folder")
	groundFolder.Name = "Ground"
	groundFolder.Parent = folder

	local natureFolder = Instance.new("Folder")
	natureFolder.Name = "Nature"
	natureFolder.Parent = folder

	local pathsFolder = Instance.new("Folder")
	pathsFolder.Name = "Walkways"
	pathsFolder.Parent = folder

	local buildingsFolder = Instance.new("Folder")
	buildingsFolder.Name = "Buildings"
	buildingsFolder.Parent = folder

	local propsFolder = Instance.new("Folder")
	propsFolder.Name = "Props"
	propsFolder.Parent = folder

	HubWorldService._createGround(groundFolder, center, platformSize)
	HubWorldService._createRiver(groundFolder, HubLayout.RIVER)
	HubWorldService._createWalkways(pathsFolder, HubLayout.WALKWAYS)
	HubWorldService._createBuildings(buildingsFolder, HubLayout.BUILDINGS)
	HubWorldService._createTownSquareProps(propsFolder)
	HubWorldService._createPlayground(propsFolder, HubLayout.PLAYGROUND)
	HubWorldService._createNature(natureFolder, HubLayout.NATURE_CLUSTERS, HubLayout.FLOWER_PATCHES)
	HubWorldService._createSpawn(folder, HubLayout.HUB_SPAWN.position)
	HubWorldService._createFarmPortal(folder, HubLayout.FARM_PORTAL.position)
	HubWorldService._createBoundaryWalls(folder, center, platformSize, hubConfig.WallHeight)
end

function HubWorldService._markSeasonPart(part: BasePart, partType: string)
	part:SetAttribute(SEASON_ATTR, partType)
end

function HubWorldService._createGround(parent: Folder, center: Vector3, platformSize: number)
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Anchored = true
	ground.Size = Vector3.new(platformSize, 1, platformSize)
	ground.Position = center + Vector3.new(0, -0.5, 0)
	ground.Material = Enum.Material.Grass
	ground.Color = Color3.fromRGB(88, 140, 72)
	ground.CanQuery = false
	ground.Parent = parent
	HubWorldService._markSeasonPart(ground, "Grass")
end

function HubWorldService._createRiver(parent: Folder, riverDef)
	local river = Instance.new("Part")
	river.Name = "River"
	river.Anchored = true
	river.Size = riverDef.size
	river.Position = riverDef.position
	river.Material = Enum.Material.Glass
	river.Transparency = 0.35
	river.Color = Color3.fromRGB(72, 130, 185)
	river.CanCollide = false
	river.Parent = parent
	HubWorldService._markSeasonPart(river, "River")

	local sign = Instance.new("Part")
	sign.Name = "RiverSign"
	sign.Anchored = true
	sign.CanCollide = false
	sign.Size = Vector3.new(10, 2, 0.4)
	sign.Position = riverDef.position + Vector3.new(14, 4, 0)
	sign.Color = Color3.fromRGB(55, 42, 32)
	sign.Parent = parent
	HubWorldService._createBillboard(sign, "The River", "Fish for river catches")
end

function HubWorldService._createWalkways(parent: Folder, segments)
	for index, segment in segments do
		local position, size = segment[1], segment[2]
		local path = Instance.new("Part")
		path.Name = `Walkway_{index}`
		path.Anchored = true
		path.Size = size
		path.Position = position
		path.Material = Enum.Material.Cobblestone
		path.Color = Color3.fromRGB(148, 132, 108)
		path.CanCollide = true
		path.Parent = parent
		HubWorldService._markSeasonPart(path, "Path")
	end
end

function HubWorldService._createBuildings(parent: Folder, buildings)
	for _, building in buildings do
		if building.isPlaza then
			HubWorldService._createPlaza(parent, building)
		else
			HubWorldService._createBuilding(parent, building)
		end
	end
end

function HubWorldService._createPlaza(parent: Folder, def)
	local plaza = Instance.new("Part")
	plaza.Name = def.id
	plaza.Anchored = true
	plaza.Size = def.size
	plaza.Position = def.position + Vector3.new(0, def.size.Y / 2, 0)
	plaza.Material = Enum.Material.Slate
	plaza.Color = def.wallColor
	plaza.Parent = parent

	local board = Instance.new("Part")
	board.Name = "NoticeBoard"
	board.Anchored = true
	board.Size = Vector3.new(6, 5, 1)
	board.Position = def.position + Vector3.new(0, 3.5, -8)
	board.Color = Color3.fromRGB(92, 64, 40)
	board.Parent = parent
	HubWorldService._createBillboard(board, "Notice Board", "Seasonal festivals posted here")
end

function HubWorldService._createBuilding(parent: Folder, def)
	local folder = Instance.new("Folder")
	folder.Name = def.id
	folder.Parent = parent

	local width, height, depth = def.size.X, def.size.Y, def.size.Z
	local baseY = def.position.Y + height / 2

	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Anchored = true
	floor.Size = Vector3.new(width, 1, depth)
	floor.Position = Vector3.new(def.position.X, def.position.Y + 0.5, def.position.Z)
	floor.Color = def.wallColor
	floor.Material = Enum.Material.WoodPlanks
	floor.Parent = folder

	local walls = {
		{ Vector3.new(width, height, 1), Vector3.new(0, 0, depth / 2) },
		{ Vector3.new(width, height, 1), Vector3.new(0, 0, -depth / 2) },
		{ Vector3.new(1, height, depth), Vector3.new(width / 2, 0, 0) },
		{ Vector3.new(1, height, depth - 2), Vector3.new(-width / 2, 0, 0) },
	}

	for wallIndex, wallData in walls do
		local wall = Instance.new("Part")
		wall.Name = `Wall_{wallIndex}`
		wall.Anchored = true
		wall.Size = wallData[1]
		wall.Position = Vector3.new(def.position.X, baseY, def.position.Z) + wallData[2]
		wall.Color = def.wallColor
		wall.Material = Enum.Material.Brick
		wall.Parent = folder
	end

	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Anchored = true
	roof.Size = Vector3.new(width + 2, 2, depth + 2)
	roof.Position = Vector3.new(def.position.X, def.position.Y + height + 1, def.position.Z)
	roof.Color = def.roofColor
	roof.Material = Enum.Material.WoodShingles
	roof.Parent = folder

	local signPart = Instance.new("Part")
	signPart.Name = "Sign"
	signPart.Anchored = true
	signPart.CanCollide = false
	signPart.Size = Vector3.new(math.min(width, 12), 2, 0.4)
	signPart.Position = Vector3.new(def.position.X, def.position.Y + height + 4, def.position.Z - depth / 2 - 1)
	signPart.Color = Color3.fromRGB(55, 42, 32)
	signPart.Parent = folder
	HubWorldService._createBillboard(signPart, def.name, def.subtitle)
end

function HubWorldService._createBillboard(adornee: BasePart, title: string, subtitle: string)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(220, 56)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = adornee

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0.55, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(255, 240, 210)
	titleLabel.TextScaled = true
	titleLabel.Parent = billboard

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Position = UDim2.fromScale(0, 0.55)
	subtitleLabel.Size = UDim2.new(1, 0, 0.45, 0)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.Text = subtitle
	subtitleLabel.TextColor3 = Color3.fromRGB(220, 200, 170)
	subtitleLabel.TextScaled = true
	subtitleLabel.Parent = billboard
end

function HubWorldService._createTownSquareProps(parent: Folder)
	local benchPositions = {
		Vector3.new(10, 0, 8),
		Vector3.new(-10, 0, 8),
		Vector3.new(8, 0, -10),
	}

	for index, offset in benchPositions do
		local bench = Instance.new("Part")
		bench.Name = `Bench_{index}`
		bench.Anchored = true
		bench.Size = Vector3.new(5, 1.5, 2)
		bench.Position = offset + Vector3.new(0, 1, 0)
		bench.Color = Color3.fromRGB(102, 72, 44)
		bench.Material = Enum.Material.Wood
		bench.Parent = parent
	end
end

function HubWorldService._createPlayground(parent: Folder, playgroundDef)
	local center = playgroundDef.center

	local sand = Instance.new("Part")
	sand.Name = "PlaygroundSand"
	sand.Anchored = true
	sand.Size = Vector3.new(36, 1, 30)
	sand.Position = center + Vector3.new(0, 0.5, 0)
	sand.Color = Color3.fromRGB(210, 185, 140)
	sand.Material = Enum.Material.Sand
	sand.Parent = parent

	local frame = Instance.new("Part")
	frame.Name = "SwingFrame"
	frame.Anchored = true
	frame.Size = Vector3.new(14, 8, 1)
	frame.Position = center + Vector3.new(0, 4, -6)
	frame.Color = Color3.fromRGB(180, 50, 50)
	frame.Material = Enum.Material.Metal
	frame.Parent = parent

	local seat = Instance.new("Part")
	seat.Name = "SwingSeat"
	seat.Anchored = true
	seat.Size = Vector3.new(3, 0.6, 2)
	seat.Position = center + Vector3.new(0, 3, -2)
	seat.Color = Color3.fromRGB(80, 80, 80)
	seat.Parent = parent

	local sign = Instance.new("Part")
	sign.Name = "PlaygroundSign"
	sign.Anchored = true
	sign.CanCollide = false
	sign.Size = Vector3.new(8, 2, 0.4)
	sign.Position = center + Vector3.new(0, 6, 10)
	sign.Color = Color3.fromRGB(55, 42, 32)
	sign.Parent = parent
	HubWorldService._createBillboard(sign, "Playground", "Swings for the local kids")
end

function HubWorldService._createNature(parent: Folder, clusters, flowerPatches)
	for clusterIndex, cluster in clusters do
		local center, treeCount = cluster[1], cluster[2]
		for treeIndex = 1, treeCount do
			local angle = (treeIndex / treeCount) * math.pi * 2
			local radius = 6 + (treeIndex % 3) * 3
			local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			HubWorldService._createTree(parent, `{clusterIndex}_{treeIndex}`, center + offset)
		end
	end

	for flowerIndex, position in flowerPatches do
		for patch = 1, 4 do
			local flower = Instance.new("Part")
			flower.Name = `Flower_{flowerIndex}_{patch}`
			flower.Anchored = true
			flower.Shape = Enum.PartType.Ball
			flower.Size = Vector3.new(1.2, 1.2, 1.2)
			flower.Position = position + Vector3.new((patch - 2) * 1.5, 0.8, (patch % 2) * 1.2)
			flower.Material = Enum.Material.Grass
			flower.Color = Color3.fromRGB(240, 140, 180)
			flower.CanCollide = false
			flower.Parent = parent
			HubWorldService._markSeasonPart(flower, "Flower")
		end
	end
end

function HubWorldService._createTree(parent: Folder, name: string, position: Vector3)
	local trunk = Instance.new("Part")
	trunk.Name = `{name}_Trunk`
	trunk.Anchored = true
	trunk.Size = Vector3.new(1.6, 6, 1.6)
	trunk.Position = position + Vector3.new(0, 3, 0)
	trunk.Color = Color3.fromRGB(102, 72, 44)
	trunk.Material = Enum.Material.Wood
	trunk.Parent = parent
	HubWorldService._markSeasonPart(trunk, "TreeTrunk")

	local foliage = Instance.new("Part")
	foliage.Name = `{name}_Foliage`
	foliage.Anchored = true
	foliage.Shape = Enum.PartType.Ball
	foliage.Size = Vector3.new(7, 7, 7)
	foliage.Position = position + Vector3.new(0, 8, 0)
	foliage.Color = Color3.fromRGB(72, 150, 68)
	foliage.Material = Enum.Material.Grass
	foliage.CanCollide = false
	foliage.Parent = parent
	HubWorldService._markSeasonPart(foliage, "TreeFoliage")

	local bush = Instance.new("Part")
	bush.Name = `{name}_Bush`
	bush.Anchored = true
	bush.Shape = Enum.PartType.Ball
	bush.Size = Vector3.new(3.5, 2.5, 3.5)
	bush.Position = position + Vector3.new(2, 1.2, 1)
	bush.Color = Color3.fromRGB(64, 130, 58)
	bush.Material = Enum.Material.Grass
	bush.CanCollide = false
	bush.Parent = parent
	HubWorldService._markSeasonPart(bush, "Bush")
end

function HubWorldService._createSpawn(parent: Folder, position: Vector3)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "HubSpawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = position
	spawn.Material = Enum.Material.Cobblestone
	spawn.Color = Color3.fromRGB(148, 132, 108)
	spawn.Neutral = true
	spawn.Parent = parent
end

function HubWorldService._createFarmPortal(parent: Folder, position: Vector3)
	if CollectionService:GetTagged(FARM_PORTAL_TAG)[1] then
		return
	end

	local portal = Instance.new("Part")
	portal.Name = "FarmPortal"
	portal.Anchored = true
	portal.Size = Vector3.new(8, 10, 2)
	portal.Position = position
	portal.Color = Color3.fromRGB(120, 90, 255)
	portal.Material = Enum.Material.Neon
	portal.Parent = parent
	CollectionService:AddTag(portal, FARM_PORTAL_TAG)

	local sign = Instance.new("Part")
	sign.Name = "FarmPortalSign"
	sign.Anchored = true
	sign.CanCollide = false
	sign.Size = Vector3.new(10, 2, 0.4)
	sign.Position = position + Vector3.new(0, 7, 0)
	sign.Color = Color3.fromRGB(55, 42, 32)
	sign.Parent = parent
	HubWorldService._createBillboard(sign, "Bus to Farm", "Touch portal or use Visit My Farm")
end

function HubWorldService._createBoundaryWalls(parent: Folder, center: Vector3, platformSize: number, wallHeight: number)
	local half = platformSize / 2
	local wallThickness = 2
	local walls = {
		{ Vector3.new(platformSize + wallThickness, wallHeight, wallThickness), Vector3.new(0, wallHeight / 2, half) },
		{ Vector3.new(platformSize + wallThickness, wallHeight, wallThickness), Vector3.new(0, wallHeight / 2, -half) },
		{ Vector3.new(wallThickness, wallHeight, platformSize + wallThickness), Vector3.new(half, wallHeight / 2, 0) },
		{ Vector3.new(wallThickness, wallHeight, platformSize + wallThickness), Vector3.new(-half, wallHeight / 2, 0) },
	}

	for index, wallData in walls do
		local wall = Instance.new("Part")
		wall.Name = `BoundaryWall_{index}`
		wall.Anchored = true
		wall.Transparency = 0.5
		wall.Size = wallData[1]
		wall.Position = center + wallData[2]
		wall.Color = Color3.fromRGB(92, 64, 38)
		wall.Material = Enum.Material.Wood
		wall.Parent = parent
	end
end

function HubWorldService.getSeasonAttributeName(): string
	return SEASON_ATTR
end

return HubWorldService
