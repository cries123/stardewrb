local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local TimeMath = require(ReplicatedStorage.Shared.Time.TimeMath)
local UiTheme = require(script.Parent.UiTheme)
local FarmToolState = require(script.Parent.Parent.Farm.FarmToolState)
local Remotes = require(script.Parent.Parent.Net.Remotes)

local FarmUi = {}

local player = Players.LocalPlayer
local screenGui = nil
local toolButtons = {}
local clockLabel = nil
local dayLabel = nil
local inventoryLabel = nil

local TOOL_LABELS = {
	Hoe = "Hoe [1]",
	WateringCan = "Water [2]",
	TomatoSeed = "Seeds [3]",
	Harvest = "Harvest [4]",
}

function FarmUi.init()
	if not PlaceType.isFarm() then
		return
	end

	FarmUi._build()
	FarmUi._bindRemotes()
	FarmUi._bindToolState()
end

function FarmUi._build()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StardewRBFarmUi"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.AnchorPoint = Vector2.new(0.5, 0)
	topBar.Position = UDim2.fromScale(0.5, 0.02)
	topBar.Size = UDim2.fromOffset(320, 56)
	topBar.BackgroundColor3 = UiTheme.Panel
	topBar.BorderSizePixel = 0
	topBar.Parent = screenGui
	UiTheme.applyCorner(topBar)
	UiTheme.applyStroke(topBar)

	dayLabel = UiTheme.createLabel(topBar, {
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 0, 20),
		Text = "Day 1",
		TextSize = 18,
		Font = Enum.Font.GothamBold,
	})

	clockLabel = UiTheme.createLabel(topBar, {
		Position = UDim2.fromOffset(12, 30),
		Size = UDim2.new(1, -24, 0, 18),
		Text = "6:00 AM",
		TextColor3 = UiTheme.TextMuted,
		TextSize = 14,
	})

	local inventoryPanel = Instance.new("Frame")
	inventoryPanel.Name = "Inventory"
	inventoryPanel.AnchorPoint = Vector2.new(1, 0)
	inventoryPanel.Position = UDim2.new(1, -16, 0, 16)
	inventoryPanel.Size = UDim2.fromOffset(180, 72)
	inventoryPanel.BackgroundColor3 = UiTheme.Panel
	inventoryPanel.BorderSizePixel = 0
	inventoryPanel.Parent = screenGui
	UiTheme.applyCorner(inventoryPanel)
	UiTheme.applyStroke(inventoryPanel)

	UiTheme.createLabel(inventoryPanel, {
		Position = UDim2.fromOffset(10, 8),
		Size = UDim2.new(1, -20, 0, 18),
		Text = "Inventory",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
	})

	inventoryLabel = UiTheme.createLabel(inventoryPanel, {
		Position = UDim2.fromOffset(10, 30),
		Size = UDim2.new(1, -20, 1, -36),
		Text = "Tomato Seeds: 0\nTomatoes: 0",
		TextColor3 = UiTheme.TextMuted,
		TextSize = 13,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	})

	local toolbar = Instance.new("Frame")
	toolbar.Name = "Toolbar"
	toolbar.AnchorPoint = Vector2.new(0.5, 1)
	toolbar.Position = UDim2.fromScale(0.5, 0.97)
	toolbar.Size = UDim2.fromOffset(420, 52)
	toolbar.BackgroundColor3 = UiTheme.Panel
	toolbar.BorderSizePixel = 0
	toolbar.Parent = screenGui
	UiTheme.applyCorner(toolbar)
	UiTheme.applyStroke(toolbar)

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = toolbar

	for _, toolId in FarmToolState.getToolOrder() do
		local button = UiTheme.createButton(toolbar, {
			Name = toolId,
			Size = UDim2.fromOffset(96, 36),
			Text = TOOL_LABELS[toolId] or toolId,
			TextSize = 13,
		})

		button.MouseButton1Click:Connect(function()
			FarmToolState.setSelected(toolId)
		end)

		toolButtons[toolId] = button
	end

	local returnButton = UiTheme.createButton(screenGui, {
		Name = "ReturnToHub",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 16, 1, -16),
		Size = UDim2.fromOffset(140, 40),
		BackgroundColor3 = UiTheme.AccentFarm,
		Text = "Return to Hub",
	})

	returnButton.MouseButton1Click:Connect(function()
		Remotes.waitForEvent("TeleportToHub"):FireServer()
	end)

	FarmUi._updateToolHighlight(FarmToolState.getSelected())
end

function FarmUi._bindToolState()
	FarmToolState.onChanged(function(toolId)
		FarmUi._updateToolHighlight(toolId)
	end)
end

function FarmUi._updateToolHighlight(selectedToolId: string)
	for toolId, button in toolButtons do
		if toolId == selectedToolId then
			button.BackgroundColor3 = UiTheme.Selected
		else
			button.BackgroundColor3 = UiTheme.Panel
		end
	end
end

function FarmUi._formatClock(clockTime: number): string
	local hour = math.floor(clockTime)
	local minute = math.floor((clockTime - hour) * 60)
	local suffix = "AM"
	if hour >= 12 then
		suffix = "PM"
	end
	local displayHour = hour % 12
	if displayHour == 0 then
		displayHour = 12
	end
	return string.format("%d:%02d %s", displayHour, minute, suffix)
end

function FarmUi._updateTime(snapshot)
	if not snapshot then
		return
	end

	if dayLabel then
		dayLabel.Text = `Day {snapshot.gameDay + 1}`
	end
	if clockLabel then
		clockLabel.Text = FarmUi._formatClock(snapshot.clockTime)
	end
end

function FarmUi._updateInventory(inventory)
	if not inventoryLabel or not inventory then
		return
	end

	local seedCount = inventory.Seeds and inventory.Seeds.TomatoSeed or 0
	local tomatoCount = inventory.Harvest and inventory.Harvest.Tomato or 0
	inventoryLabel.Text = `Tomato Seeds: {seedCount}\nTomatoes: {tomatoCount}`
end

function FarmUi._bindRemotes()
	local timeSync = Remotes.waitForEvent("TimeSync")
	timeSync.OnClientEvent:Connect(FarmUi._updateTime)
	timeSync:FireServer()

	task.spawn(function()
		while screenGui and screenGui.Parent do
			FarmUi._updateTime(TimeMath.getSnapshot())
			task.wait(0.25)
		end
	end)

	local playerState = Remotes.waitForEvent("PlayerStateUpdate")
	playerState.OnClientEvent:Connect(function(payload)
		FarmUi._updateInventory(payload.Inventory)
	end)
end

return FarmUi
