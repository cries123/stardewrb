--[[
	Procedural farmhouse for the player's private farm plot.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local GridMath = require(ReplicatedStorage.Shared.Grid.GridMath)

local FarmBuildingKit = {}

local WALL_COLOR = Color3.fromRGB(210, 185, 150)
local ROOF_COLOR = Color3.fromRGB(120, 70, 45)
local TRIM_COLOR = Color3.fromRGB(92, 64, 40)

local function createPart(props): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.Name = props.Name or "Part"
	part.Size = props.Size
	part.Position = props.Position
	part.Color = props.Color or Color3.fromRGB(200, 200, 200)
	part.Material = props.Material or Enum.Material.SmoothPlastic
	part.CanCollide = props.CanCollide ~= false
	part.Transparency = props.Transparency or 0
	part.Parent = props.Parent
	return part
end

function FarmBuildingKit.buildFarmhouse(parent: Folder)
	local house = GameConfig.Farm.Farmhouse
	local cellSize = GameConfig.Farm.CellSize
	local origin = GameConfig.Farm.Origin

	local widthStuds = house.CellWidth * cellSize
	local depthStuds = house.CellHeight * cellSize
	local centerX = origin.X + (house.CellX - 1 + house.CellWidth / 2) * cellSize
	local centerZ = origin.Z + (house.CellY - 1 + house.CellHeight / 2) * cellSize
	local floorY = origin.Y + 0.5

	local folder = Instance.new("Folder")
	folder.Name = "Farmhouse"
	folder.Parent = parent

	local wallHeight = 14

	createPart({
		Name = "Foundation",
		Parent = folder,
		Size = Vector3.new(widthStuds + 4, 1, depthStuds + 4),
		Position = Vector3.new(centerX, floorY - 0.5, centerZ),
		Color = Color3.fromRGB(130, 130, 130),
		Material = Enum.Material.Concrete,
	})

	createPart({
		Name = "MainHall",
		Parent = folder,
		Size = Vector3.new(widthStuds, wallHeight, depthStuds),
		Position = Vector3.new(centerX, floorY + wallHeight / 2, centerZ),
		Color = WALL_COLOR,
		Material = Enum.Material.Brick,
	})

	createPart({
		Name = "Roof",
		Parent = folder,
		Size = Vector3.new(widthStuds + 3, 3, depthStuds + 3),
		Position = Vector3.new(centerX, floorY + wallHeight + 1.5, centerZ),
		Color = ROOF_COLOR,
		Material = Enum.Material.WoodPlanks,
	})

	createPart({
		Name = "Chimney",
		Parent = folder,
		Size = Vector3.new(3, 6, 3),
		Position = Vector3.new(centerX + widthStuds * 0.25, floorY + wallHeight + 4, centerZ - depthStuds * 0.2),
		Color = Color3.fromRGB(150, 150, 150),
		Material = Enum.Material.Brick,
	})

	createPart({
		Name = "Porch",
		Parent = folder,
		Size = Vector3.new(widthStuds * 0.6, 0.5, 4),
		Position = Vector3.new(centerX, floorY + 0.25, centerZ - depthStuds / 2 - 2),
		Color = TRIM_COLOR,
		Material = Enum.Material.WoodPlanks,
	})

	createPart({
		Name = "Door",
		Parent = folder,
		Size = Vector3.new(4, 7, 0.5),
		Position = Vector3.new(centerX, floorY + 3.5, centerZ - depthStuds / 2 - 0.2),
		Color = TRIM_COLOR,
		Material = Enum.Material.Wood,
	})

	for _, xOffset in { -widthStuds * 0.22, widthStuds * 0.22 } do
		createPart({
			Name = "Window",
			Parent = folder,
			Size = Vector3.new(3, 3, 0.4),
			Position = Vector3.new(centerX + xOffset, floorY + 8, centerZ - depthStuds / 2 - 0.2),
			Color = Color3.fromRGB(140, 180, 210),
			Material = Enum.Material.Glass,
			Transparency = 0.35,
		})
	end

	local sign = createPart({
		Name = "Sign",
		Parent = folder,
		Size = Vector3.new(10, 2.5, 0.4),
		Position = Vector3.new(centerX, floorY + wallHeight + 5, centerZ - depthStuds / 2 - 2),
		Color = TRIM_COLOR,
		CanCollide = false,
	})

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(200, 50)
	billboard.StudsOffset = Vector3.new(0, 1, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = sign

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = "Farmhouse"
	label.TextColor3 = Color3.fromRGB(255, 240, 210)
	label.TextScaled = true
	label.Parent = billboard

	return folder
end

function FarmBuildingKit.getFarmhouseWorldBounds()
	local house = GameConfig.Farm.Farmhouse
	return GridMath.getCellRegionBounds(house.CellX, house.CellY, house.CellWidth, house.CellHeight)
end

return FarmBuildingKit
