local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local PlayerDataUtil = require(ReplicatedStorage.Shared.Data.PlayerDataUtil)
local DataService = require(script.Parent.Parent.Data.DataService)
local Remotes = require(script.Parent.Parent.Net.Remotes)
local PlayerStateService = require(script.Parent.Parent.Data.PlayerStateService)
local LedgerService = require(script.Parent.LedgerService)

local ShipmentService = {}

local function sendResult(player: Player, success: boolean, message: string)
	Remotes.getEvent("HubActionResult"):FireClient(player, success, message)
end

function ShipmentService.init()
	Remotes.getEvent("ShipItem").OnServerEvent:Connect(function(player, itemId, amount)
		ShipmentService.shipItem(player, itemId, amount)
	end)
end

function ShipmentService.shipItem(player: Player, itemId: string, amount: number)
	if typeof(itemId) ~= "string" or typeof(amount) ~= "number" then
		return
	end

	amount = math.clamp(math.floor(amount), 1, 999)

	local cropConfig = GameConfig.Crops[itemId]
	if not cropConfig or not cropConfig.SellPrice then
		sendResult(player, false, "That item can't be shipped.")
		return
	end

	local data = DataService.getData(player)
	if not data then
		return
	end

	PlayerDataUtil.ensureDefaults(data)

	local owned = data.Inventory.Harvest[itemId] or 0
	if owned < amount then
		sendResult(player, false, "Not enough crops to ship.")
		return
	end

	data.Inventory.Harvest[itemId] = owned - amount
	data.PendingShipment[itemId] = (data.PendingShipment[itemId] or 0) + amount
	PlayerStateService.replicate(player)
	sendResult(player, true, `Shipped {amount}x {cropConfig.DisplayName}. Gold arrives tomorrow morning.`)
end

function ShipmentService.processOvernightForAllPlayers()
	for _, player in Players:GetPlayers() do
		ShipmentService.processOvernightForPlayer(player)
	end
end

function ShipmentService.processOvernightForPlayer(player: Player)
	local data = DataService.getData(player)
	if not data then
		return
	end

	PlayerDataUtil.ensureDefaults(data)

	local totalGold = 0
	local totalCrops = 0
	local shippedItems = {}

	for itemId, amount in data.PendingShipment do
		if amount > 0 then
			local cropConfig = GameConfig.Crops[itemId]
			if cropConfig and cropConfig.SellPrice then
				totalGold += cropConfig.SellPrice * amount
				totalCrops += amount
				table.insert(shippedItems, `{amount}x {cropConfig.DisplayName}`)
			end
			data.PendingShipment[itemId] = 0
		end
	end

	if totalGold > 0 then
		data.Money += totalGold
		LedgerService.recordGoldEarned(data, totalGold)
		LedgerService.recordCropsSold(data, totalCrops)
		PlayerStateService.replicate(player)
		sendResult(player, true, `Overnight shipment: G{totalGold} ({table.concat(shippedItems, ", ")}).`)
	end
end

return ShipmentService
