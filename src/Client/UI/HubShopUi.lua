local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local ShopHours = require(ReplicatedStorage.Shared.Time.ShopHours)
local TimeMath = require(ReplicatedStorage.Shared.Time.TimeMath)
local UiTheme = require(script.Parent.UiTheme)
local HubPanelUi = require(script.Parent.HubPanelUi)
local Remotes = require(script.Parent.Parent.Net.Remotes)

local HubShopUi = {}

local player = Players.LocalPlayer
local currentMoney = 0

local function getItemDisplay(itemId: string, kind: string): (string, number?)
	if kind == "seed" then
		local seed = GameConfig.Seeds[itemId]
		return seed and seed.DisplayName or itemId, seed and seed.BuyPrice
	elseif kind == "food" then
		local food = GameConfig.Food[itemId]
		return food and food.DisplayName or itemId, food and food.BuyPrice
	end

	return itemId, nil
end

local function isShopOpen(shopId: string): boolean
	local schedule = GameConfig.Shops[shopId]
	if not schedule then
		return false
	end

	local snapshot = TimeMath.getSnapshot()
	local calendar = TimeMath.getCalendarLabels(snapshot.gameDay)
	return ShopHours.isOpen(snapshot.clockTime, calendar.weekday, schedule)
end

local function getClosedMessage(shopId: string): string
	local schedule = GameConfig.Shops[shopId]
	local snapshot = TimeMath.getSnapshot()
	local calendar = TimeMath.getCalendarLabels(snapshot.gameDay)
	return ShopHours.getClosedReason(snapshot.clockTime, calendar.weekday, schedule)
end

function HubShopUi.init()
	Remotes.waitForEvent("PlayerStateUpdate").OnClientEvent:Connect(function(payload)
		currentMoney = payload.Money or 0
	end)

	Remotes.waitForEvent("HubActionResult").OnClientEvent:Connect(function(success, message)
		if HubShopUi._statusLabel then
			HubPanelUi.setStatus(HubShopUi._statusLabel, message, not success)
		end
	end)
end

function HubShopUi.open(shopId: string)
	local schedule = GameConfig.Shops[shopId]
	if not schedule then
		return
	end

	local screenGui, panel, statusLabel = HubPanelUi.createModal(
		player:WaitForChild("PlayerGui"),
		`HubShop_{shopId}`,
		schedule.DisplayName,
		Vector2.new(340, 320)
	)
	HubShopUi._statusLabel = statusLabel

	local open = isShopOpen(shopId)
	if not open then
		HubPanelUi.setStatus(statusLabel, getClosedMessage(shopId), true)
	end

	UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(12, 42),
		Size = UDim2.new(1, -24, 0, 18),
		Text = `Your gold: G{currentMoney}`,
		TextColor3 = UiTheme.GoldDark,
		TextSize = 14,
	})

	local list = Instance.new("ScrollingFrame")
	list.Name = "ItemList"
	list.Position = UDim2.fromOffset(12, 68)
	list.Size = UDim2.new(1, -24, 1, -110)
	list.BackgroundColor3 = UiTheme.Parchment
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 6
	list.CanvasSize = UDim2.fromOffset(0, 0)
	list.Parent = panel
	UiTheme.applyCorner(list)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = list

	for index, entry in schedule.Items do
		local displayName, price = getItemDisplay(entry.itemId, entry.kind)
		if not price then
			continue
		end

		local row = Instance.new("Frame")
		row.Name = entry.itemId
		row.Size = UDim2.new(1, -8, 0, 52)
		row.BackgroundTransparency = 1
		row.LayoutOrder = index
		row.Parent = list

		local detail = if entry.kind == "food"
			then `+{GameConfig.Food[entry.itemId].EnergyRestore} energy`
			else "Plant on your farm"

		UiTheme.createLabel(row, {
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.new(1, -100, 0, 20),
			Text = displayName,
			Font = Enum.Font.GothamBold,
			TextSize = 15,
		})

		UiTheme.createLabel(row, {
			Position = UDim2.fromOffset(4, 24),
			Size = UDim2.new(1, -100, 0, 18),
			Text = `G{price} • {detail}`,
			TextColor3 = UiTheme.TextMuted,
			TextSize = 12,
		})

		local buyButton = UiTheme.createButton(row, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -4, 0.5, 0),
			Size = UDim2.fromOffset(80, 34),
			Text = "Buy",
			TextSize = 14,
			BackgroundColor3 = if open then UiTheme.Success else UiTheme.Slot,
		})
		buyButton.Active = open
		buyButton.AutoButtonColor = open

		buyButton.MouseButton1Click:Connect(function()
			if not isShopOpen(shopId) then
				HubPanelUi.setStatus(statusLabel, getClosedMessage(shopId), true)
				return
			end

			Remotes.waitForEvent("BuyShopItem"):FireServer(shopId, entry.itemId, 1)
		end)
	end

	task.defer(function()
		list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
	end)

	screenGui.Destroying:Connect(function()
		if HubShopUi._statusLabel == statusLabel then
			HubShopUi._statusLabel = nil
		end
	end)
end

return HubShopUi
