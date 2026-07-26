local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local GridMath = require(ReplicatedStorage.Shared.Grid.GridMath)
local GridConstants = require(ReplicatedStorage.Shared.Grid.GridConstants)
local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local Remotes = require(script.Parent.Parent.Net.Remotes)
local FarmToolState = require(script.Parent.FarmToolState)

local FarmClient = {}

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local currentGrid = nil
local plotFolder = nil

local SOIL_COLORS = {
	Empty = Color3.fromRGB(88, 130, 59),
	Tilled = Color3.fromRGB(101, 67, 33),
}

local CROP_COLORS = {
	[GridConstants.CropStage.Planted] = Color3.fromRGB(60, 120, 40),
	[GridConstants.CropStage.Growing] = Color3.fromRGB(40, 160, 50),
	[GridConstants.CropStage.Ready] = Color3.fromRGB(220, 60, 40),
}

function FarmClient.init()
	if not PlaceType.isFarm() then
		return
	end

	plotFolder = workspace:FindFirstChild("FarmPlot")
	if not plotFolder then
		plotFolder = Instance.new("Folder")
		plotFolder.Name = "FarmPlot"
		plotFolder.Parent = workspace
	end

	FarmClient._buildPlotTiles()
	FarmClient._bindInput()
	FarmClient._bindRemotes()
end

function FarmClient._prepareGround()
	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then
		baseplate.Transparency = 1
		baseplate.CanCollide = false
	end
end

function FarmClient._buildPlotTiles()
	FarmClient._prepareGround()

	local tileHeight = 0.5
	local tileCenterY = GameConfig.Farm.Origin.Y + tileHeight / 2 + 0.05

	for x = 1, GameConfig.Farm.GridWidth do
		for y = 1, GameConfig.Farm.GridHeight do
			local tile = Instance.new("Part")
			tile.Name = `Cell_{x}_{y}`
			tile.Anchored = true
			tile.CanCollide = true
			tile.Size = Vector3.new(GameConfig.Farm.CellSize - 0.2, tileHeight, GameConfig.Farm.CellSize - 0.2)
			local worldPos = GridMath.cellToWorld(x, y)
			tile.Position = Vector3.new(worldPos.X, tileCenterY, worldPos.Z)
			tile.Material = Enum.Material.Ground
			tile.Color = SOIL_COLORS.Empty
			tile.Parent = plotFolder
		end
	end
end

function FarmClient._bindRemotes()
	local gridUpdate = Remotes.waitForEvent("FarmGridUpdate")
	gridUpdate.OnClientEvent:Connect(function(grid)
		currentGrid = grid
		FarmClient._renderGrid()
	end)
end

function FarmClient._renderGrid()
	if not currentGrid or not plotFolder then
		return
	end

	for x = 1, GameConfig.Farm.GridWidth do
		for y = 1, GameConfig.Farm.GridHeight do
			local tile = plotFolder:FindFirstChild(`Cell_{x}_{y}`)
			local cell = currentGrid[x] and currentGrid[x][y]
			if tile and cell then
				tile.Color = SOIL_COLORS[cell.soil] or SOIL_COLORS.Empty

				local cropIndicator = tile:FindFirstChild("CropIndicator")
				if cell.crop then
					if not cropIndicator then
						cropIndicator = Instance.new("Part")
						cropIndicator.Name = "CropIndicator"
						cropIndicator.Anchored = true
						cropIndicator.CanCollide = false
						cropIndicator.Size = Vector3.new(1.5, 2, 1.5)
						cropIndicator.Position = tile.Position + Vector3.new(0, 1.5, 0)
						cropIndicator.Parent = tile
					end
					cropIndicator.Color = CROP_COLORS[cell.crop.stage] or CROP_COLORS[GridConstants.CropStage.Planted]
					cropIndicator.Transparency = 0
				elseif cropIndicator then
					cropIndicator:Destroy()
				end
			end
		end
	end
end

function FarmClient._getTargetCell(): (number?, number?)
	if mouse.Target and mouse.Target:IsDescendantOf(plotFolder) then
		local name = mouse.Target.Name
		local xStr, yStr = string.match(name, "^Cell_(%d+)_(%d+)$")
		if xStr and yStr then
			return tonumber(xStr), tonumber(yStr)
		end
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		return GridMath.worldToCell(root.Position)
	end

	return nil, nil
end

function FarmClient._performAction()
	local x, y = FarmClient._getTargetCell()
	if not x then
		return
	end

	local action = FarmToolState.getActionForTool(FarmToolState.getSelected())

	if action then
		Remotes.waitForEvent("FarmAction"):FireServer(action, x, y)
	end
end

function FarmClient._bindInput()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if input.KeyCode == Enum.KeyCode.One then
			FarmToolState.setSelected("Hoe")
		elseif input.KeyCode == Enum.KeyCode.Two then
			FarmToolState.setSelected("WateringCan")
		elseif input.KeyCode == Enum.KeyCode.Three then
			FarmToolState.setSelected("TomatoSeed")
		elseif input.KeyCode == Enum.KeyCode.Four then
			FarmToolState.setSelected("Harvest")
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			FarmClient._performAction()
		end
	end)
end

return FarmClient
