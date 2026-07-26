local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local DataService = require(script.Parent.Parent.Data.DataService)
local Remotes = require(script.Parent.Parent.Net.Remotes)
local PlayerStateService = require(script.Parent.Parent.Data.PlayerStateService)
local LedgerService = require(script.Parent.LedgerService)

local SellService = {}

function SellService.init()
	Remotes.getEvent("SellItem").OnServerEvent:Connect(function(player, itemId, amount)
		SellService.sellItem(player, itemId, amount)
	end)
end

function SellService.sellItem(player: Player, itemId: string, amount: number)
	if typeof(itemId) ~= "string" or typeof(amount) ~= "number" then
		return
	end

	amount = math.clamp(math.floor(amount), 1, 999)

	local data = DataService.getData(player)
	if not data then
		return
	end

	local cropConfig = GameConfig.Crops[itemId]
	if not cropConfig or not cropConfig.SellPrice then
		return
	end

	local owned = data.Inventory.Harvest[itemId] or 0
	if owned < amount then
		return
	end

	data.Inventory.Harvest[itemId] = owned - amount
	local gold = cropConfig.SellPrice * amount
	data.Money += gold
	LedgerService.recordGoldEarned(data, gold)
	LedgerService.recordCropsSold(data, amount)
	PlayerStateService.replicate(player)
end

return SellService
