local UiTheme = {
	Background = Color3.fromRGB(45, 35, 28),
	Panel = Color3.fromRGB(72, 56, 42),
	PanelBorder = Color3.fromRGB(110, 88, 62),
	Accent = Color3.fromRGB(120, 90, 255),
	AccentFarm = Color3.fromRGB(255, 180, 60),
	Text = Color3.fromRGB(255, 248, 230),
	TextMuted = Color3.fromRGB(200, 185, 160),
	Selected = Color3.fromRGB(140, 110, 70),
	Success = Color3.fromRGB(90, 160, 90),
	Error = Color3.fromRGB(200, 80, 80),
	CornerRadius = UDim.new(0, 8),
}

function UiTheme.applyCorner(instance: GuiObject, radius: UDim?)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or UiTheme.CornerRadius
	corner.Parent = instance
	return corner
end

function UiTheme.applyStroke(instance: GuiObject, color: Color3?)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or UiTheme.PanelBorder
	stroke.Thickness = 2
	stroke.Parent = instance
	return stroke
end

function UiTheme.createLabel(parent: Instance, props: { [string]: any }): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.TextColor3 = UiTheme.Text
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left

	for key, value in props do
		label[key] = value
	end

	label.Parent = parent
	return label
end

function UiTheme.createButton(parent: Instance, props: { [string]: any }): TextButton
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = UiTheme.Panel
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = UiTheme.Text
	button.TextSize = 16
	button.AutoButtonColor = true

	for key, value in props do
		button[key] = value
	end

	UiTheme.applyCorner(button)
	UiTheme.applyStroke(button)
	button.Parent = parent
	return button
end

return UiTheme
