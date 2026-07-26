local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiTheme = require(script.Parent.UiTheme)
local HubPanelUi = require(script.Parent.HubPanelUi)
local Remotes = require(script.Parent.Parent.Net.Remotes)

local LedgerUi = {}

local player = Players.LocalPlayer
local currentMoney = 0
local currentLedger = {
	TotalGoldEarned = 0,
	TotalGoldSpent = 0,
	TotalCropsSold = 0,
}

function LedgerUi.init()
	Remotes.waitForEvent("PlayerStateUpdate").OnClientEvent:Connect(function(payload)
		currentMoney = payload.Money or 0
		currentLedger = payload.Ledger or currentLedger
	end)
end

function LedgerUi.open()
	local screenGui, panel = HubPanelUi.createModal(
		player:WaitForChild("PlayerGui"),
		"HubMayorLedger",
		"Mayor's Ledger",
		Vector2.new(360, 280)
	)

	UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(12, 48),
		Size = UDim2.new(1, -24, 0, 22),
		Text = "Pelican Town farming record",
		TextColor3 = UiTheme.TextMuted,
		TextSize = 13,
	})

	local rows = {
		{ "Current gold", `G{currentMoney}` },
		{ "Total gold earned", `G{currentLedger.TotalGoldEarned or 0}` },
		{ "Total gold spent", `G{currentLedger.TotalGoldSpent or 0}` },
		{ "Crops sold (lifetime)", tostring(currentLedger.TotalCropsSold or 0) },
	}

	for index, row in rows do
		UiTheme.createLabel(panel, {
			Position = UDim2.fromOffset(12, 78 + (index - 1) * 36),
			Size = UDim2.new(1, -24, 0, 20),
			Text = row[1],
			Font = Enum.Font.GothamBold,
			TextSize = 15,
		})

		UiTheme.createLabel(panel, {
			Position = UDim2.fromOffset(12, 96 + (index - 1) * 36),
			Size = UDim2.new(1, -24, 0, 18),
			Text = row[2],
			TextColor3 = UiTheme.GoldDark,
			TextSize = 14,
		})
	end

	UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(12, 230),
		Size = UDim2.new(1, -24, 0, 36),
		Text = "Earn on your farm, sell or ship in town, and spend at Pierre's and the Saloon.",
		TextColor3 = UiTheme.TextMuted,
		TextSize = 12,
		TextWrapped = true,
	})

	return screenGui
end

return LedgerUi
