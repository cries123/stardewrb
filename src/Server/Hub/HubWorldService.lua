local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local HubLayout = require(ReplicatedStorage.Shared.Hub.HubLayout)
local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local HubTerrainBuilder = require(script.Parent.HubTerrainBuilder)
local HubBuildingKit = require(script.Parent.HubBuildingKit)
local HubNatureKit = require(script.Parent.HubNatureKit)

local HubWorldService = {}

local WORLD_FOLDER_NAME = "HubWorld"
local FARM_PORTAL_TAG = "FarmPortal"
local SEASON_ATTR = "HubSeasonPart"
local BUILD_VERSION = 4

local function runStep(label: string, callback): boolean
	local ok, err = pcall(callback)
	if not ok then
		warn(`[HubWorldService] Step failed ({label}):`, err)
		return false
	end
	return true
end

function HubWorldService.init()
	if not PlaceType.isHub() then
		print("[HubWorldService] Skipped — place is not Hub")
		return
	end

	print("[HubWorldService] Building Pelican Town (visual pass v4)...")

	local ok, err = pcall(function()
		HubWorldService._clearDefaultSpawns()
		HubWorldService._buildWorld()
	end)

	if not ok then
		warn("[HubWorldService] Failed to build town:", err)
		return
	end

	local folder = workspace:FindFirstChild(WORLD_FOLDER_NAME)
	local buildingCount = 0
	if folder then
		local buildings = folder:FindFirstChild("Buildings")
		if buildings then
			buildingCount = #buildings:GetChildren()
		end
	end

	if buildingCount == 0 then
		warn("[HubWorldService] Town built but no buildings — check Output for step errors above")
	else
		print(`[HubWorldService] Pelican Town ready — {buildingCount} buildings placed`)
	end
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

function HubWorldService._shouldSkipBuild(folder: Folder): boolean
	if folder:GetAttribute("BuildVersion") ~= BUILD_VERSION then
		return false
	end

	local buildings = folder:FindFirstChild("Buildings")
	return buildings ~= nil and #buildings:GetChildren() > 0
end

function HubWorldService._createTownPlatform(parent: Folder, platformSize: number)
	local platform = Instance.new("Part")
	platform.Name = "TownPlatform"
	platform.Anchored = true
	platform.Size = Vector3.new(platformSize - 40, 1, platformSize - 40)
	platform.Position = Vector3.new(0, HubLayout.GROUND_Y - 0.5, 0)
	platform.Color = Color3.fromRGB(148, 132, 108)
	platform.Material = Enum.Material.Cobblestone
	platform.Parent = parent
end

function HubWorldService._buildBuilding(buildingsFolder: Folder, buildingDef)
	local ok, err = pcall(function()
		HubBuildingKit.build(buildingsFolder, buildingDef)
	end)
	if ok then
		return true
	end

	warn(`[HubWorldService] Building failed ({buildingDef.id}), using fallback:`, err)
	local fallbackOk, fallbackErr = pcall(function()
		HubBuildingKit.buildFallback(buildingsFolder, buildingDef)
	end)
	if not fallbackOk then
		warn(`[HubWorldService] Fallback building failed ({buildingDef.id}):`, fallbackErr)
	end
	return fallbackOk
end

function HubWorldService._buildWorld()
	local folder = HubWorldService._getOrCreateFolder()
	if HubWorldService._shouldSkipBuild(folder) then
		print(`[HubWorldService] Town already built (v{BUILD_VERSION})`)
		return
	end

	folder:ClearAllChildren()
	HubTerrainBuilder.reset(folder)

	local hubConfig = GameConfig.Hub
	local platformSize = hubConfig.PlatformSize

	local pathsFolder = Instance.new("Folder")
	pathsFolder.Name = "Walkways"
	pathsFolder.Parent = folder

	local buildingsFolder = Instance.new("Folder")
	buildingsFolder.Name = "Buildings"
	buildingsFolder.Parent = folder

	local natureFolder = Instance.new("Folder")
	natureFolder.Name = "Nature"
	natureFolder.Parent = folder

	local propsFolder = Instance.new("Folder")
	propsFolder.Name = "Props"
	propsFolder.Parent = folder

	runStep("spawn and portal", function()
		HubWorldService._createSpawn(folder, HubLayout.HUB_SPAWN.position)
		HubWorldService._createFarmPortal(folder, HubLayout.FARM_PORTAL.position)
	end)

	runStep("town platform", function()
		HubWorldService._createTownPlatform(folder, platformSize)
	end)

	runStep("walkways", function()
		for index, segment in HubLayout.WALKWAYS do
			local position, size = segment[1], segment[2]
			HubNatureKit.createPathSegment(pathsFolder, index, position, Vector3.new(size.X, 0.12, size.Z))
		end
	end)

	local builtCount = 0
	runStep("buildings", function()
		for _, building in HubLayout.BUILDINGS do
			if HubWorldService._buildBuilding(buildingsFolder, building) then
				builtCount += 1
			end
		end
	end)

	runStep("props", function()
		for index, lampPosition in HubLayout.LAMP_POSTS do
			HubNatureKit.createLampPost(propsFolder, lampPosition, index)
		end

		for index, line in HubLayout.FENCE_LINES do
			HubNatureKit.createFenceLine(propsFolder, line[1], line[2], index)
		end

		HubWorldService._createRiverSign(propsFolder, HubLayout.RIVER_SIGN)
		HubWorldService._createPlayground(propsFolder, HubLayout.PLAYGROUND)
	end)

	runStep("nature", function()
		HubWorldService._createNature(natureFolder, HubLayout.NATURE_CLUSTERS, HubLayout.FLOWER_PATCHES)
	end)

	runStep("terrain", function()
		HubTerrainBuilder.build(folder, platformSize)
	end)

	if builtCount > 0 then
		folder:SetAttribute("BuildVersion", BUILD_VERSION)
	end
end

function HubWorldService._createRiverSign(parent: Folder, riverSignDef)
	local sign = Instance.new("Part")
	sign.Name = "RiverSign"
	sign.Anchored = true
	sign.CanCollide = false
	sign.Size = Vector3.new(10, 2, 0.4)
	sign.Position = riverSignDef.position
	sign.Color = Color3.fromRGB(55, 42, 32)
	sign.Material = Enum.Material.Wood
	sign.Parent = parent
	HubWorldService._createBillboard(sign, "The River", "Fish for river catches")
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

function HubWorldService._createPlayground(parent: Folder, playgroundDef)
	local center = playgroundDef.center

	local sand = Instance.new("Part")
	sand.Name = "PlaygroundSand"
	sand.Anchored = true
	sand.Size = Vector3.new(36, 0.4, 30)
	sand.Position = center + Vector3.new(0, 0.2, 0)
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
			HubNatureKit.createTree(parent, `{clusterIndex}_{treeIndex}`, center + offset)
		end
	end

	for flowerIndex, position in flowerPatches do
		HubNatureKit.createFlowerPatch(parent, position, flowerIndex)
	end
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
	for _, tagged in CollectionService:GetTagged(FARM_PORTAL_TAG) do
		if tagged:IsA("BasePart") then
			tagged:Destroy()
		end
	end

	local arch = Instance.new("Part")
	arch.Name = "FarmPortalArch"
	arch.Anchored = true
	arch.Size = Vector3.new(10, 12, 2)
	arch.Position = position
	arch.Color = Color3.fromRGB(92, 64, 40)
	arch.Material = Enum.Material.Wood
	arch.Parent = parent

	local portal = Instance.new("Part")
	portal.Name = "FarmPortal"
	portal.Anchored = true
	portal.Size = Vector3.new(6, 8, 1)
	portal.Position = position + Vector3.new(0, -1, 0)
	portal.Color = Color3.fromRGB(120, 90, 255)
	portal.Material = Enum.Material.Neon
	portal.Transparency = 0.15
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

function HubWorldService.getSeasonAttributeName(): string
	return SEASON_ATTR
end

return HubWorldService
