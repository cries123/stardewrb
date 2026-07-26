local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local UiTheme = require(script.Parent.UiTheme)
local HubPanelUi = require(script.Parent.HubPanelUi)
local Remotes = require(script.Parent.Parent.Net.Remotes)

local ShippingBinUi = {}

local player = Players.LocalPlayer
local currentInventory = nil
local currentPending = {}

function ShippingBinUi.init()
	Remotes.waitForEvent("PlayerStateUpdate").OnClientEvent:Connect(function(payload)
		currentInventory = payload.Inventory
		currentPending = payload.PendingShipment or {}
	end)

	Remotes.waitForEvent("HubActionResult").OnClientEvent:Connect(function(success, message)
		if ShippingBinUi._statusLabel then
			HubPanelUi.setStatus(ShippingBinUi._statusLabel, message, not success)
		end
	end)
end

function ShippingBinUi.open()
	local screenGui, panel, statusLabel = HubPanelUi.createModal(
		player:WaitForChild("PlayerGui"),
		"HubShippingBin",
		"Shipping Bin",
		Vector2.new(360, 340)
	)
	ShippingBinUi._statusLabel = statusLabel

	UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(12, 42),
		Size = UDim2.new(1, -24, 0, 36),
		Text = "Ship crops from your inventory. Gold is delivered tomorrow morning.",
		TextColor3 = UiTheme.TextMuted,
		TextSize = 12,
		TextWrapped = true,
	})

	local pendingText = ShippingBinUi._formatPending()
	UiTheme.createLabel(panel, {
		Name = "PendingLabel",
		Position = UDim2.fromOffset(12, 78),
		Size = UDim2.new(1, -24, 0, 18),
		Text = `Pending: {pendingText}`,
		TextSize = 13,
		TextColor3 = UiTheme.GoldDark,
	})

	local list = Instance.new("ScrollingFrame")
	list.Name = "CropList"
	list.Position = UDim2.fromOffset(12, 104)
	list.Size = UDim2.new(1, -24, 1, -146)
	list.BackgroundColor3 = UiTheme.Parchment
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 6
	list.CanvasSize = UDim2.fromOffset(0, 0)
	list.Parent = panel
	UiTheme.applyCorner(list)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = list

	local hasItems = false
	if currentInventory and currentInventory.Harvest then
		for itemId, count in currentInventory.Harvest do
			if count > 0 then
				local crop = GameConfig.Crops[itemId]
				if crop then
					hasItems = true
					ShippingBinUi._createRow(list, itemId, crop.DisplayName, count, crop.SellPrice, statusLabel)
				end
			end
		end
	end

	if not hasItems then
		UiTheme.createLabel(list, {
			Size = UDim2.new(1, -8, 0, 40),
			Text = "No crops to ship. Harvest on your farm first!",
			TextColor3 = UiTheme.TextMuted,
			TextSize = 13,
			TextWrapped = true,
		})
	end

	task.defer(function()
		list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
	end)

	screenGui.Destroying:Connect(function()
		if ShippingBinUi._statusLabel == statusLabel then
			ShippingBinUi._statusLabel = nil
		end
	end)
end

function ShippingBinUi._formatPending(): string
	local parts = {}
	for itemId, amount in currentPending do
		if amount > 0 then
			local crop = GameConfig.Crops[itemId]
			table.insert(parts, `{amount}x {crop and crop.DisplayName or itemId}`)
		end
	end

	if #parts == 0 then
		return "none"
	end

	return table.concat(parts, ", ")
end

function ShippingBinUi._createRow(
	parent: Instance,
	itemId: string,
	displayName: string,
	count: number,
	sellPrice: number,
	statusLabel: TextLabel
)
	local row = Instance.new("Frame")
	row.Name = itemId
	row.Size = UDim2.new(1, -8, 0, 52)
	row.BackgroundTransparency = 1
	row.Parent = parent

	UiTheme.createLabel(row, {
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, -100, 0, 20),
		Text = `{displayName} x{count}`,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
	})

	UiTheme.createLabel(row, {
		Position = UDim2.fromOffset(4, 24),
		Size = UDim2.new(1, -100, 0, 18),
		Text = `G{sellPrice} each tomorrow`,
		TextColor3 = UiTheme.TextMuted,
		TextSize = 12,
	})

	local shipButton = UiTheme.createButton(row, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		Size = UDim2.fromOffset(72, 34),
		Text = "Ship 1",
		TextSize = 13,
		BackgroundColor3 = UiTheme.AccentFarm,
	})

	shipButton.MouseButton1Click:Connect(function()
		Remotes.waitForEvent("ShipItem"):FireServer(itemId, 1)
	end)

	if count > 1 then
		local shipAllButton = UiTheme.createButton(row, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -82, 0.5, 0),
			Size = UDim2.fromOffset(72, 34),
			Text = `All ({count})`,
			TextSize = 12,
		})

		shipAllButton.MouseButton1Click:Connect(function()
			Remotes.waitForEvent("ShipItem"):FireServer(itemId, count)
		end)
	end
end

return ShippingBinUi
