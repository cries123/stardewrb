local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local GridConstants = require(ReplicatedStorage.Shared.Grid.GridConstants)

local GridLogic = {}

function GridLogic.tillCell(cell)
	cell.soil = GridConstants.Soil.Tilled
end

function GridLogic.plantCell(cell, cropId: string, plantedOnDay: number)
	cell.crop = {
		cropId = cropId,
		stage = GridConstants.CropStage.Planted,
		plantedOnDay = plantedOnDay,
		lastWateredDay = nil,
	}
end

function GridLogic.waterCell(cell, currentGameDay: number)
	cell.crop.lastWateredDay = currentGameDay

	if cell.crop.stage == GridConstants.CropStage.Planted then
		cell.crop.stage = GridConstants.CropStage.Growing
	end
end

function GridLogic.harvestCell(cell)
	local cropId = cell.crop.cropId
	cell.crop = nil
	cell.soil = GridConstants.Soil.Empty
	return cropId
end

-- Called when the global day advances to mature watered crops.
function GridLogic.advanceGrowthForDay(grid, currentGameDay: number)
	for x = 1, GameConfig.Farm.GridWidth do
		for y = 1, GameConfig.Farm.GridHeight do
			local cell = grid[x][y]
			local crop = cell.crop

			if crop and crop.stage == GridConstants.CropStage.Growing and crop.lastWateredDay ~= nil then
				local cropConfig = GameConfig.Crops[crop.cropId]
				if cropConfig then
					local daysSinceWatered = currentGameDay - crop.lastWateredDay
					if daysSinceWatered >= cropConfig.GrowthDays then
						crop.stage = GridConstants.CropStage.Ready
					end
				end
			end
		end
	end
end

return GridLogic
