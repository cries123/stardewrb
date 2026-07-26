local UiTheme = {
	WoodDark = Color3.fromRGB(92, 58, 30),
	WoodMid = Color3.fromRGB(139, 90, 43),
	WoodLight = Color3.fromRGB(196, 148, 84),
	Slot = Color3.fromRGB(228, 198, 138),
	SlotSelected = Color3.fromRGB(255, 235, 180),
	Parchment = Color3.fromRGB(245, 230, 200),
	TextDark = Color3.fromRGB(70, 45, 25),
	TextMuted = Color3.fromRGB(110, 78, 48),
	Gold = Color3.fromRGB(255, 204, 60),
	GoldDark = Color3.fromRGB(200, 140, 30),
	Energy = Color3.fromRGB(70, 185, 75),
	EnergyBg = Color3.fromRGB(35, 70, 38),
	Health = Color3.fromRGB(215, 55, 55),
	HealthBg = Color3.fromRGB(80, 30, 30),
	Accent = Color3.fromRGB(120, 90, 255),
	AccentFarm = Color3.fromRGB(255, 180, 60),
	Success = Color3.fromRGB(90, 160, 90),
	Error = Color3.fromRGB(200, 80, 80),
	Panel = Color3.fromRGB(139, 90, 43),
	Text = Color3.fromRGB(70, 45, 25),
	CornerRadius = UDim.new(0, 6),
	Font = Enum.Font.GothamBold,
	FontBody = Enum.Font.GothamMedium,
}

function UiTheme.applyWoodPanel(instance: GuiObject)
	instance.BackgroundColor3 = UiTheme.WoodMid
	instance.BorderSizePixel = 0
	UiTheme.applyCorner(instance, UDim.new(0, 8))
	UiTheme.applyStroke(instance, UiTheme.WoodDark, 3)
end

function UiTheme.applyCorner(instance: GuiObject, radius: UDim?)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or UiTheme.CornerRadius
	corner.Parent = instance
	return corner
end

function UiTheme.applyStroke(instance: GuiObject, color: Color3?, thickness: number?)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or UiTheme.WoodDark
	stroke.Thickness = thickness or 2
	stroke.Parent = instance
	return stroke
end

function UiTheme.createLabel(parent: Instance, props: { [string]: any }): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = UiTheme.FontBody
	label.TextColor3 = UiTheme.TextDark
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
	button.BackgroundColor3 = UiTheme.WoodLight
	button.BorderSizePixel = 0
	button.Font = UiTheme.Font
	button.TextColor3 = UiTheme.TextDark
	button.TextSize = 16
	button.AutoButtonColor = true

	for key, value in props do
		button[key] = value
	end

	UiTheme.applyCorner(button)
	UiTheme.applyStroke(button, UiTheme.WoodDark, 2)
	button.Parent = parent
	return button
end

return UiTheme
