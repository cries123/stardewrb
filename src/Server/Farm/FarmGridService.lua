local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local GridMath = require(ReplicatedStorage.Shared.Grid.GridMath)
local GridLogic = require(ReplicatedStorage.Shared.Grid.GridLogic)
local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local DataService = require(script.Parent.Parent.Data.DataService)
local TimeService = require(script.Parent.Parent.Time.TimeService)
local Remotes = require(script.Parent.Parent.Net.Remotes)
local PlayerStateService = require(script.Parent.Parent.Data.PlayerStateService)

local FarmGridService = {}

function FarmGridService.init()
	if not PlaceType.isFarm() then
		return
	end

	Remotes.getEvent("FarmAction").OnServerEvent:Connect(function(player, action, x, y)
		FarmGridService.handleAction(player, action, x, y)
	end)
end

function FarmGridService.onNewGameDay(gameDay: number)
	for _, player in game:GetService("Players"):GetPlayers() do
		local data = DataService.getData(player)
		if data then
			GridLogic.advanceGrowthForDay(data.FarmState.Grid, gameDay)
			FarmGridService._replicateGrid(player)
		end
	end
end

function FarmGridService._replicateGrid(player: Player)
	local data = DataService.getData(player)
	if not data then
		return
	end

	Remotes.getEvent("FarmGridUpdate"):FireClient(player, data.FarmState.Grid)
	PlayerStateService.replicate(player)
end

function FarmGridService._validateCell(player: Player, x, y)
	if typeof(x) ~= "number" or typeof(y) ~= "number" then
		return nil, "Invalid coordinates"
	end

	if not GridMath.isInBounds(x, y) then
		return nil, "Out of bounds"
	end

	local data = DataService.getData(player)
	if not data then
		return nil, "Profile not loaded"
	end

	local cell = GridMath.getCell(data.FarmState.Grid, x, y)
	if not cell then
		return nil, "Cell not found"
	end

	return data, cell
end

function FarmGridService.handleAction(player: Player, action: string, x: number, y: number)
	local data, cell = FarmGridService._validateCell(player, x, y)
	if not data then
		return
	end

	local currentDay = TimeService.getCurrentGameDay()

	if action == "Till" then
		if data.Inventory.Tools.Hoe < 1 then
			return
		end
		if not GridMath.canTill(cell) then
			return
		end
		GridLogic.tillCell(cell)
	elseif action == "Plant" then
		local seedId = "TomatoSeed"
		local seedConfig = GameConfig.Seeds[seedId]
		if not seedConfig then
			return
		end
		if (data.Inventory.Seeds[seedId] or 0) < 1 then
			return
		end
		if not GridMath.canPlant(cell) then
			return
		end

		data.Inventory.Seeds[seedId] -= 1
		GridLogic.plantCell(cell, seedConfig.CropId, currentDay)
	elseif action == "Water" then
		if data.Inventory.Tools.WateringCan < 1 then
			return
		end
		if not GridMath.canWater(cell, currentDay) then
			return
		end
		GridLogic.waterCell(cell, currentDay)
	elseif action == "Harvest" then
		if not GridMath.canHarvest(cell) then
			return
		end

		local cropId = GridLogic.harvestCell(cell)
		local cropConfig = GameConfig.Crops[cropId]
		if cropConfig then
			local itemId = cropConfig.HarvestItemId
			data.Inventory.Harvest[itemId] = (data.Inventory.Harvest[itemId] or 0) + cropConfig.HarvestAmount
		end
	else
		return
	end

	FarmGridService._replicateGrid(player)
end

function FarmGridService.sendInitialGrid(player: Player)
	FarmGridService._replicateGrid(player)
end

return FarmGridService
