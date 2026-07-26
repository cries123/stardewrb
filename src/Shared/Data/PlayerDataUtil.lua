local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local ProfileTemplate = require(ReplicatedStorage.Shared.ProfileTemplate)

local PlayerDataUtil = {}

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, child in value do
		copy[key] = deepCopy(child)
	end
	return copy
end

function PlayerDataUtil.createEmptyGrid()
	local grid = {}
	for x = 1, GameConfig.Farm.GridWidth do
		grid[x] = {}
		for y = 1, GameConfig.Farm.GridHeight do
			grid[x][y] = {
				soil = "Empty",
				crop = nil,
			}
		end
	end
	return grid
end

function PlayerDataUtil.ensureDefaults(data)
	if data.Money == nil then
		data.Money = ProfileTemplate.Money
	end

	if data.Stats == nil then
		data.Stats = deepCopy(ProfileTemplate.Stats)
	else
		if data.Stats.MaxEnergy == nil then
			data.Stats.MaxEnergy = ProfileTemplate.Stats.MaxEnergy
		end
		if data.Stats.Energy == nil then
			data.Stats.Energy = data.Stats.MaxEnergy
		end
		if data.Stats.MaxHealth == nil then
			data.Stats.MaxHealth = ProfileTemplate.Stats.MaxHealth
		end
		if data.Stats.Health == nil then
			data.Stats.Health = data.Stats.MaxHealth
		end
	end

	if data.Inventory == nil then
		data.Inventory = deepCopy(ProfileTemplate.Inventory)
	else
		if data.Inventory.Tools == nil then
			data.Inventory.Tools = deepCopy(ProfileTemplate.Inventory.Tools)
		else
			if data.Inventory.Tools.Hoe == nil then
				data.Inventory.Tools.Hoe = ProfileTemplate.Inventory.Tools.Hoe
			end
			if data.Inventory.Tools.WateringCan == nil then
				data.Inventory.Tools.WateringCan = ProfileTemplate.Inventory.Tools.WateringCan
			end
		end

		if data.Inventory.Seeds == nil then
			data.Inventory.Seeds = deepCopy(ProfileTemplate.Inventory.Seeds)
		end

		if data.Inventory.Harvest == nil then
			data.Inventory.Harvest = deepCopy(ProfileTemplate.Inventory.Harvest)
		end

		if data.Inventory.Food == nil then
			data.Inventory.Food = deepCopy(ProfileTemplate.Inventory.Food)
		end
	end

	if data.PendingShipment == nil then
		data.PendingShipment = deepCopy(ProfileTemplate.PendingShipment)
	end

	if data.Ledger == nil then
		data.Ledger = deepCopy(ProfileTemplate.Ledger)
	else
		if data.Ledger.TotalGoldEarned == nil then
			data.Ledger.TotalGoldEarned = 0
		end
		if data.Ledger.TotalGoldSpent == nil then
			data.Ledger.TotalGoldSpent = 0
		end
		if data.Ledger.TotalCropsSold == nil then
			data.Ledger.TotalCropsSold = 0
		end
	end

	if data.FarmState == nil then
		data.FarmState = {
			PrivateServerCode = nil,
			Grid = PlayerDataUtil.createEmptyGrid(),
		}
	elseif data.FarmState.Grid == nil then
		data.FarmState.Grid = PlayerDataUtil.createEmptyGrid()
	end

	PlayerDataUtil.ensureGridSize(data.FarmState.Grid)
end

function PlayerDataUtil.ensureGridSize(grid)
	local targetWidth = GameConfig.Farm.GridWidth
	local targetHeight = GameConfig.Farm.GridHeight

	for x = 1, targetWidth do
		if grid[x] == nil then
			grid[x] = {}
		end
		for y = 1, targetHeight do
			if grid[x][y] == nil then
				grid[x][y] = {
					soil = "Empty",
					crop = nil,
				}
			end
		end
	end
end

return PlayerDataUtil
