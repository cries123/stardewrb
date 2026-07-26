local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local ShopHours = require(ReplicatedStorage.Shared.Time.ShopHours)
local TimeMath = require(ReplicatedStorage.Shared.Time.TimeMath)
local PlayerDataUtil = require(ReplicatedStorage.Shared.Data.PlayerDataUtil)
local DataService = require(script.Parent.Parent.Data.DataService)
local Remotes = require(script.Parent.Parent.Net.Remotes)
local PlayerStateService = require(script.Parent.Parent.Data.PlayerStateService)

local ShopService = {}

local function sendResult(player: Player, success: boolean, message: string)
	Remotes.getEvent("HubActionResult"):FireClient(player, success, message)
end

local function getShopSchedule(shopId: string)
	return GameConfig.Shops[shopId]
end

local function isShopOpen(shopId: string): boolean
	local schedule = getShopSchedule(shopId)
	if not schedule then
		return false
	end

	local snapshot = TimeMath.getSnapshot()
	local calendar = TimeMath.getCalendarLabels(snapshot.gameDay)
	return ShopHours.isOpen(snapshot.clockTime, calendar.weekday, schedule)
end

local function getBuyPrice(itemId: string, kind: string): number?
	if kind == "seed" then
		local seedConfig = GameConfig.Seeds[itemId]
		return seedConfig and seedConfig.BuyPrice
	elseif kind == "food" then
		local foodConfig = GameConfig.Food[itemId]
		return foodConfig and foodConfig.BuyPrice
	end

	return nil
end

function ShopService.init()
	Remotes.getEvent("BuyShopItem").OnServerEvent:Connect(function(player, shopId, itemId, amount)
		ShopService.buyItem(player, shopId, itemId, amount)
	end)

	Remotes.getEvent("EatFood").OnServerEvent:Connect(function(player, foodId)
		ShopService.eatFood(player, foodId)
	end)
end

function ShopService.buyItem(player: Player, shopId: string, itemId: string, amount: number)
	if typeof(shopId) ~= "string" or typeof(itemId) ~= "string" or typeof(amount) ~= "number" then
		return
	end

	amount = math.clamp(math.floor(amount), 1, 99)

	local schedule = getShopSchedule(shopId)
	if not schedule then
		sendResult(player, false, "Unknown shop.")
		return
	end

	if not isShopOpen(shopId) then
		local snapshot = TimeMath.getSnapshot()
		local calendar = TimeMath.getCalendarLabels(snapshot.gameDay)
		sendResult(player, false, ShopHours.getClosedReason(snapshot.clockTime, calendar.weekday, schedule))
		return
	end

	local catalogEntry = nil
	for _, entry in schedule.Items do
		if entry.itemId == itemId then
			catalogEntry = entry
			break
		end
	end

	if not catalogEntry then
		sendResult(player, false, "Item not sold here.")
		return
	end

	local unitPrice = getBuyPrice(itemId, catalogEntry.kind)
	if not unitPrice then
		sendResult(player, false, "Item has no price.")
		return
	end

	local data = DataService.getData(player)
	if not data then
		return
	end

	PlayerDataUtil.ensureDefaults(data)

	local totalCost = unitPrice * amount
	if data.Money < totalCost then
		sendResult(player, false, `Not enough gold (need G{totalCost}).`)
		return
	end

	if catalogEntry.kind == "seed" then
		if not GameConfig.Seeds[itemId] then
			sendResult(player, false, "Unknown seed.")
			return
		end

		data.Money -= totalCost
		data.Inventory.Seeds[itemId] = (data.Inventory.Seeds[itemId] or 0) + amount
	elseif catalogEntry.kind == "food" then
		local foodConfig = GameConfig.Food[itemId]
		if not foodConfig or foodConfig.ShopId ~= shopId then
			sendResult(player, false, "Unknown food.")
			return
		end

		data.Money -= totalCost
		data.Inventory.Food[itemId] = (data.Inventory.Food[itemId] or 0) + amount
	else
		sendResult(player, false, "Unsupported item type.")
		return
	end

	PlayerStateService.replicate(player)

	local displayName = if catalogEntry.kind == "seed"
		then GameConfig.Seeds[itemId].DisplayName
		else GameConfig.Food[itemId].DisplayName
	sendResult(player, true, `Bought {amount}x {displayName} for G{totalCost}.`)
end

function ShopService.eatFood(player: Player, foodId: string)
	if typeof(foodId) ~= "string" then
		return
	end

	local foodConfig = GameConfig.Food[foodId]
	if not foodConfig then
		sendResult(player, false, "Unknown food.")
		return
	end

	local data = DataService.getData(player)
	if not data then
		return
	end

	PlayerDataUtil.ensureDefaults(data)

	local owned = data.Inventory.Food[foodId] or 0
	if owned <= 0 then
		sendResult(player, false, "You don't have any of that food.")
		return
	end

	if data.Stats.Energy >= data.Stats.MaxEnergy then
		sendResult(player, false, "Energy is already full.")
		return
	end

	data.Inventory.Food[foodId] = owned - 1
	data.Stats.Energy = math.min(data.Stats.MaxEnergy, data.Stats.Energy + foodConfig.EnergyRestore)
	PlayerStateService.replicate(player)
	sendResult(player, true, `Ate {foodConfig.DisplayName} (+{foodConfig.EnergyRestore} energy).`)
end

return ShopService
