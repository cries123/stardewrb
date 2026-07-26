local UiTheme = require(script.Parent.UiTheme)

local HubPanelUi = {}

function HubPanelUi.createModal(playerGui: PlayerGui, name: string, title: string, size: Vector2): (ScreenGui, Frame, TextLabel)
	local screenGui = playerGui:FindFirstChild(name)
	if screenGui then
		screenGui:Destroy()
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = name
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local backdrop = Instance.new("TextButton")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 0.45
	backdrop.BorderSizePixel = 0
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.Parent = screenGui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(size.X, size.Y)
	panel.Parent = screenGui
	UiTheme.applyWoodPanel(panel)

	UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(12, 10),
		Size = UDim2.new(1, -56, 0, 28),
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
	})

	local closeButton = UiTheme.createButton(panel, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 10),
		Size = UDim2.fromOffset(32, 28),
		Text = "X",
		TextSize = 16,
	})

	local statusLabel = UiTheme.createLabel(panel, {
		Name = "Status",
		Position = UDim2.new(0, 12, 1, -34),
		Size = UDim2.new(1, -24, 0, 24),
		Text = "",
		TextColor3 = UiTheme.TextMuted,
		TextSize = 12,
		TextWrapped = true,
	})

	closeButton.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	backdrop.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	return screenGui, panel, statusLabel
end

function HubPanelUi.setStatus(statusLabel: TextLabel, message: string, isError: boolean?)
	statusLabel.Text = message
	statusLabel.TextColor3 = if isError then UiTheme.Error else UiTheme.Success
end

return HubPanelUi
