local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local GridMath = {}

function GridMath.isInBounds(x: number, y: number): boolean
	return x >= 1
		and x <= GameConfig.Farm.GridWidth
		and y >= 1
		and y <= GameConfig.Farm.GridHeight
end

function GridMath.getGridCenter(): Vector3
	local widthStuds = GameConfig.Farm.GridWidth * GameConfig.Farm.CellSize
	local heightStuds = GameConfig.Farm.GridHeight * GameConfig.Farm.CellSize
	local origin = GameConfig.Farm.Origin

	return Vector3.new(
		origin.X + widthStuds / 2,
		origin.Y,
		origin.Z + heightStuds / 2
	)
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
	local GridConstants = require(script.Parent.GridConstants)
	return cell.soil == GridConstants.Soil.Empty and cell.crop == nil
end

function GridMath.canPlant(cell): boolean
	local GridConstants = require(script.Parent.GridConstants)
	return cell.soil == GridConstants.Soil.Tilled and cell.crop == nil
end

function GridMath.canWater(cell, currentGameDay: number): boolean
	if cell.crop == nil then
		return false
	end

	local GridConstants = require(script.Parent.GridConstants)
	local stage = cell.crop.stage
	if stage == GridConstants.CropStage.Ready then
		return false
	end

	if cell.crop.lastWateredDay == currentGameDay then
		return false
	end

	return stage == GridConstants.CropStage.Planted or stage == GridConstants.CropStage.Growing
end

function GridMath.canHarvest(cell): boolean
	local GridConstants = require(script.Parent.GridConstants)
	return cell.crop ~= nil and cell.crop.stage == GridConstants.CropStage.Ready
end

return GridMath
