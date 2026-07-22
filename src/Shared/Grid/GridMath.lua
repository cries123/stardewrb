local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local GridConstants = require(ReplicatedStorage.Shared.Grid.GridConstants)

local GridMath = {}

function GridMath.isInBounds(x: number, y: number): boolean
	return x >= 1
		and x <= GameConfig.Farm.GridWidth
		and y >= 1
		and y <= GameConfig.Farm.GridHeight
end

function GridMath.worldToCell(worldPosition: Vector3): (number?, number?)
	local origin = GameConfig.Farm.Origin
	local cellSize = GameConfig.Farm.CellSize

	local x = math.floor((worldPosition.X - origin.X) / cellSize) + 1
	local y = math.floor((worldPosition.Z - origin.Z) / cellSize) + 1

	if not GridMath.isInBounds(x, y) then
		return nil, nil
	end

	return x, y
end

function GridMath.cellToWorld(x: number, y: number): Vector3
	local origin = GameConfig.Farm.Origin
	local cellSize = GameConfig.Farm.CellSize

	return Vector3.new(
		origin.X + (x - 0.5) * cellSize,
		origin.Y,
		origin.Z + (y - 0.5) * cellSize
	)
end

function GridMath.getCell(grid, x: number, y: number)
	if not GridMath.isInBounds(x, y) then
		return nil
	end
	return grid[x][y]
end

function GridMath.canTill(cell): boolean
	return cell.soil == GridConstants.Soil.Empty and cell.crop == nil
end

function GridMath.canPlant(cell): boolean
	return cell.soil == GridConstants.Soil.Tilled and cell.crop == nil
end

function GridMath.canWater(cell, currentGameDay: number): boolean
	if cell.crop == nil then
		return false
	end

	local stage = cell.crop.stage
	if stage == GridConstants.CropStage.Ready then
		return false
	end

	-- One watering action per in-game day.
	if cell.crop.lastWateredDay == currentGameDay then
		return false
	end

	return stage == GridConstants.CropStage.Planted or stage == GridConstants.CropStage.Growing
end

function GridMath.canHarvest(cell): boolean
	return cell.crop ~= nil and cell.crop.stage == GridConstants.CropStage.Ready
end

return GridMath
