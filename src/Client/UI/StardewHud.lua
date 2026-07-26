local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local TimeMath = require(ReplicatedStorage.Shared.Time.TimeMath)
local ToolbarLayout = require(ReplicatedStorage.Shared.Hud.ToolbarLayout)
local UiTheme = require(script.Parent.UiTheme)
local FarmToolState = require(script.Parent.Parent.Farm.FarmToolState)
local Remotes = require(script.Parent.Parent.Net.Remotes)

local StardewHud = {}

local player = Players.LocalPlayer
local screenGui = nil
local slotFrames = {}
local slotCountLabels = {}
local dateLabel = nil
local seasonLabel = nil
local timeLabel = nil
local dialIcon = nil
local moneyLabel = nil
local energyFill = nil
local healthFill = nil
local currentInventory = nil
local currentMoney = 0
local currentStats = nil

function StardewHud.init()
	StardewHud._build()
	StardewHud._bindRemotes()
	StardewHud._bindInput()
	FarmToolState.onChanged(StardewHud._updateToolbarSelection)
end

function StardewHud._build()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StardewRBHud"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	StardewHud._buildDateTimePanel()
	StardewHud._buildMoneyPanel()
	StardewHud._buildToolbar()
	StardewHud._buildStatBars()
	StardewHud._buildSellHint()

	if PlaceType.isFarm() then
		StardewHud._buildReturnButton()
	end
end

function StardewHud._buildDateTimePanel()
	local panel = Instance.new("Frame")
	panel.Name = "DateTimePanel"
	panel.AnchorPoint = Vector2.new(1, 0)
	panel.Position = UDim2.new(1, -12, 0, 12)
	panel.Size = UDim2.fromOffset(150, 88)
	panel.Parent = screenGui
	UiTheme.applyWoodPanel(panel)

	local dial = Instance.new("Frame")
	dial.Name = "Dial"
	dial.Position = UDim2.fromOffset(10, 10)
	dial.Size = UDim2.fromOffset(44, 44)
	dial.BackgroundColor3 = UiTheme.Parchment
	dial.Parent = panel
	UiTheme.applyCorner(dial, UDim.new(1, 0))
	UiTheme.applyStroke(dial, UiTheme.WoodDark, 2)

	dialIcon = UiTheme.createLabel(dial, {
		Size = UDim2.fromScale(1, 1),
		Text = "☀",
		TextSize = 24,
		Font = UiTheme.Font,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	dialIcon.Name = "DialIcon"

	dateLabel = UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(62, 12),
		Size = UDim2.fromOffset(78, 22),
		Text = "Thu. 1",
		Font = UiTheme.Font,
		TextSize = 15,
	})

	seasonLabel = UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(62, 34),
		Size = UDim2.fromOffset(78, 16),
		Text = "Spring",
		TextColor3 = UiTheme.TextMuted,
		TextSize = 12,
	})
	seasonLabel.Name = "SeasonLabel"

	local timeBox = Instance.new("Frame")
	timeBox.Name = "TimeBox"
	timeBox.Position = UDim2.fromOffset(10, 60)
	timeBox.Size = UDim2.new(1, -20, 0, 22)
	timeBox.BackgroundColor3 = UiTheme.Parchment
	timeBox.Parent = panel
	UiTheme.applyCorner(timeBox)
	UiTheme.applyStroke(timeBox, UiTheme.WoodDark, 2)

	timeLabel = UiTheme.createLabel(timeBox, {
		Size = UDim2.fromScale(1, 1),
		Text = "6:00 am",
		Font = UiTheme.Font,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
end

function StardewHud._buildMoneyPanel()
	local panel = Instance.new("Frame")
	panel.Name = "MoneyPanel"
	panel.AnchorPoint = Vector2.new(1, 0)
	panel.Position = UDim2.new(1, -12, 0, 108)
	panel.Size = UDim2.fromOffset(150, 36)
	panel.Parent = screenGui
	UiTheme.applyWoodPanel(panel)

	local coin = Instance.new("Frame")
	coin.Name = "Coin"
	coin.Position = UDim2.fromOffset(8, 6)
	coin.Size = UDim2.fromOffset(24, 24)
	coin.BackgroundColor3 = UiTheme.Gold
	coin.Parent = panel
	UiTheme.applyCorner(coin, UDim.new(1, 0))
	UiTheme.applyStroke(coin, UiTheme.GoldDark, 2)

	UiTheme.createLabel(coin, {
		Size = UDim2.fromScale(1, 1),
		Text = "G",
		Font = UiTheme.Font,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	})

	moneyLabel = UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(40, 0),
		Size = UDim2.new(1, -48, 1, 0),
		Text = "0",
		Font = UiTheme.Font,
		TextSize = 20,
		TextColor3 = Color3.fromRGB(180, 40, 40),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
end

function StardewHud._buildToolbar()
	local toolbar = Instance.new("Frame")
	toolbar.Name = "Toolbar"
	toolbar.AnchorPoint = Vector2.new(0.5, 1)
	toolbar.Position = UDim2.fromScale(0.5, 0.98)
	toolbar.Size = UDim2.fromOffset(12 * 52 + 11 * 4 + 16, 64)
	toolbar.BackgroundColor3 = UiTheme.WoodDark
	toolbar.BorderSizePixel = 0
	toolbar.Parent = screenGui
	UiTheme.applyCorner(toolbar, UDim.new(0, 10))
	UiTheme.applyStroke(toolbar, Color3.fromRGB(50, 30, 15), 3)

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 4)
	layout.Parent = toolbar

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = toolbar

	for slotIndex = 1, ToolbarLayout.SLOT_COUNT do
		local slotConfig = ToolbarLayout.getSlotConfig(slotIndex)

		local slot = Instance.new("TextButton")
		slot.Name = `Slot_{slotIndex}`
		slot.Size = UDim2.fromOffset(52, 52)
		slot.BackgroundColor3 = UiTheme.Slot
		slot.BorderSizePixel = 0
		slot.Text = ""
		slot.AutoButtonColor = false
		slot.LayoutOrder = slotIndex
		slot.Parent = toolbar
		UiTheme.applyCorner(slot)
		UiTheme.applyStroke(slot, UiTheme.WoodDark, 2)

		local hotkey = ToolbarLayout.getHotkeyForSlot(slotIndex)
		if hotkey then
			local keyLabel = UiTheme.createLabel(slot, {
				Position = UDim2.fromOffset(4, 2),
				Size = UDim2.fromOffset(16, 14),
				Text = tostring(slotIndex == 10 and "0" or slotIndex == 11 and "-" or slotIndex == 12 and "=" or slotIndex),
				TextSize = 10,
				TextColor3 = UiTheme.TextMuted,
			})
			keyLabel.Name = "Hotkey"
		end

		local icon = UiTheme.createLabel(slot, {
			Size = UDim2.fromScale(1, 1),
			Text = slotConfig and slotConfig.icon or "",
			Font = UiTheme.Font,
			TextSize = slotConfig and 14 or 0,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
		})
		icon.Name = "Icon"

		local count = UiTheme.createLabel(slot, {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -4, 1, -2),
			Size = UDim2.fromOffset(24, 14),
			Text = "",
			Font = UiTheme.Font,
			TextSize = 12,
			TextColor3 = UiTheme.TextDark,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		count.Name = "Count"

		slot.MouseButton1Click:Connect(function()
			FarmToolState.setSelectedSlot(slotIndex)
		end)

		slotFrames[slotIndex] = slot
		slotCountLabels[slotIndex] = count
	end

	StardewHud._updateToolbarSelection(FarmToolState.getSelectedSlot())
end

function StardewHud._buildStatBars()
	local container = Instance.new("Frame")
	container.Name = "StatBars"
	container.AnchorPoint = Vector2.new(1, 1)
	container.Position = UDim2.new(1, -12, 1, -12)
	container.Size = UDim2.fromOffset(88, 120)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	energyFill, _ = StardewHud._createVerticalBar(container, "Energy", UiTheme.Energy, UiTheme.EnergyBg, UDim2.fromOffset(0, 0), "E")
	healthFill, _ = StardewHud._createVerticalBar(container, "Health", UiTheme.Health, UiTheme.HealthBg, UDim2.fromOffset(44, 0), "♥")
end

function StardewHud._createVerticalBar(parent, name, fillColor, bgColor, position, badgeText)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Position = position
	frame.Size = UDim2.fromOffset(36, 120)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local badge = Instance.new("Frame")
	badge.Size = UDim2.fromOffset(28, 28)
	badge.Position = UDim2.fromOffset(4, 0)
	badge.BackgroundColor3 = UiTheme.WoodMid
	badge.Parent = frame
	UiTheme.applyCorner(badge, UDim.new(1, 0))
	UiTheme.applyStroke(badge, UiTheme.WoodDark, 2)

	UiTheme.createLabel(badge, {
		Size = UDim2.fromScale(1, 1),
		Text = badgeText,
		Font = UiTheme.Font,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	})

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Position = UDim2.fromOffset(10, 34)
	track.Size = UDim2.fromOffset(16, 82)
	track.BackgroundColor3 = bgColor
	track.BorderSizePixel = 0
	track.Parent = frame
	UiTheme.applyCorner(track, UDim.new(0, 4))
	UiTheme.applyStroke(track, UiTheme.WoodDark, 2)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.AnchorPoint = Vector2.new(0, 1)
	fill.Position = UDim2.fromScale(0, 1)
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = fillColor
	fill.BorderSizePixel = 0
	fill.Parent = track
	UiTheme.applyCorner(fill, UDim.new(0, 4))

	return fill, frame
end

function StardewHud._buildSellHint()
	if PlaceType.isFarm() then
		UiTheme.createLabel(screenGui, {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 0.98, -72),
			Size = UDim2.fromOffset(220, 18),
			Text = "Select crops, press R to sell",
			TextColor3 = UiTheme.TextMuted,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	elseif PlaceType.isHub() then
		UiTheme.createLabel(screenGui, {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 0.98, -72),
			Size = UDim2.fromOffset(280, 18),
			Text = "Walk up to shops — slots 5/6 food, press E to eat",
			TextColor3 = UiTheme.TextMuted,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end
end

function StardewHud._buildReturnButton()
	local button = Instance.new("TextButton")
	button.Name = "ReturnToHub"
	button.AnchorPoint = Vector2.new(0, 1)
	button.Position = UDim2.new(0, 12, 1, -12)
	button.Size = UDim2.fromOffset(130, 36)
	button.BackgroundColor3 = UiTheme.AccentFarm
	button.BorderSizePixel = 0
	button.Font = UiTheme.Font
	button.Text = "Return to Hub"
	button.TextColor3 = UiTheme.TextDark
	button.TextSize = 14
	button.Parent = screenGui
	UiTheme.applyCorner(button)
	UiTheme.applyStroke(button, UiTheme.WoodDark, 2)

	button.MouseButton1Click:Connect(function()
		Remotes.waitForEvent("TeleportToHub"):FireServer()
	end)
end

function StardewHud._updateToolbarSelection(selectedSlot: number)
	for slotIndex, slot in slotFrames do
		local stroke = slot:FindFirstChildOfClass("UIStroke")
		if slotIndex == selectedSlot then
			slot.BackgroundColor3 = UiTheme.SlotSelected
			if stroke then
				stroke.Color = Color3.fromRGB(200, 50, 50)
				stroke.Thickness = 3
			end
		else
			slot.BackgroundColor3 = UiTheme.Slot
			if stroke then
				stroke.Color = UiTheme.WoodDark
				stroke.Thickness = 2
			end
		end
	end
end

function StardewHud._updateToolbarCounts()
	for slotIndex = 1, ToolbarLayout.SLOT_COUNT do
		local slotConfig = ToolbarLayout.getSlotConfig(slotIndex)
		local countLabel = slotCountLabels[slotIndex]
		if countLabel and slotConfig and currentInventory then
			local count = ToolbarLayout.getItemCount(currentInventory, slotConfig)
			if slotConfig.kind == "tool" then
				countLabel.Text = count > 0 and "" or ""
			else
				countLabel.Text = count > 1 and tostring(count) or (count == 1 and "1" or "")
			end
		elseif countLabel then
			countLabel.Text = ""
		end
	end
end

function StardewHud._formatClock(clockTime: number): string
	local hour = math.floor(clockTime)
	local minute = math.floor((clockTime - hour) * 60)
	local suffix = "am"
	if hour >= 12 then
		suffix = "pm"
	end
	local displayHour = hour % 12
	if displayHour == 0 then
		displayHour = 12
	end
	return string.format("%d:%02d %s", displayHour, minute, suffix)
end

function StardewHud._updateTime(snapshot)
	if typeof(snapshot) ~= "table" or typeof(snapshot.gameDay) ~= "number" then
		return
	end

	local calendar = TimeMath.getCalendarLabels(snapshot.gameDay)

	if dateLabel then
		dateLabel.Text = `{calendar.weekday}. {calendar.dayNumber}`
	end

	if seasonLabel then
		seasonLabel.Text = calendar.season
	end

	if dialIcon and typeof(snapshot.clockTime) == "number" then
		dialIcon.Text = if snapshot.clockTime >= 18 or snapshot.clockTime < 6 then "🌙" else "☀"
	end

	if timeLabel and typeof(snapshot.clockTime) == "number" then
		timeLabel.Text = StardewHud._formatClock(snapshot.clockTime)
	end
end

function StardewHud._updateStats(stats)
	if not stats then
		return
	end

	if energyFill then
		local ratio = math.clamp(stats.Energy / stats.MaxEnergy, 0, 1)
		energyFill.Size = UDim2.new(1, 0, ratio, 0)
	end

	if healthFill then
		local ratio = math.clamp(stats.Health / stats.MaxHealth, 0, 1)
		healthFill.Size = UDim2.new(1, 0, ratio, 0)
	end
end

function StardewHud._updatePlayerState(payload)
	currentInventory = payload.Inventory
	currentMoney = payload.Money or 0
	currentStats = payload.Stats

	if moneyLabel then
		moneyLabel.Text = tostring(currentMoney)
	end

	StardewHud._updateToolbarCounts()
	StardewHud._updateStats(currentStats)
end

function StardewHud._bindRemotes()
	local timeSync = Remotes.waitForEvent("TimeSync")
	timeSync.OnClientEvent:Connect(StardewHud._updateTime)
	timeSync:FireServer()

	task.spawn(function()
		while screenGui and screenGui.Parent do
			StardewHud._updateTime(TimeMath.getSnapshot())
			task.wait(0.25)
		end
	end)

	local playerState = Remotes.waitForEvent("PlayerStateUpdate")
	playerState.OnClientEvent:Connect(StardewHud._updatePlayerState)

	if PlaceType.isFarm() then
		local teleportResult = Remotes.waitForEvent("TeleportResult")
		teleportResult.OnClientEvent:Connect(function(success, message)
			if not success then
				warn(`[Farm] {message}`)
			end
		end)
	end
end

function StardewHud._bindInput()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		for slotIndex = 1, ToolbarLayout.SLOT_COUNT do
			local hotkey = ToolbarLayout.getHotkeyForSlot(slotIndex)
			if hotkey and input.KeyCode == hotkey then
				FarmToolState.setSelectedSlot(slotIndex)
				return
			end
		end

		if input.KeyCode == Enum.KeyCode.R then
			local slotConfig = FarmToolState.getSelectedSlotConfig()
			if slotConfig and slotConfig.sellable and currentInventory then
				local count = ToolbarLayout.getItemCount(currentInventory, slotConfig)
				if count > 0 then
					Remotes.waitForEvent("SellItem"):FireServer(slotConfig.itemId, 1)
				end
			end
		end

		if input.KeyCode == Enum.KeyCode.E then
			local slotConfig = FarmToolState.getSelectedSlotConfig()
			if slotConfig and slotConfig.consumable and currentInventory then
				local count = ToolbarLayout.getItemCount(currentInventory, slotConfig)
				if count > 0 then
					Remotes.waitForEvent("EatFood"):FireServer(slotConfig.itemId)
				end
			end
		end
	end)
end

return StardewHud
