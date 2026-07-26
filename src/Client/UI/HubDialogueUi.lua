local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HubNpcConfig = require(ReplicatedStorage.Shared.Hub.HubNpcConfig)
local UiTheme = require(script.Parent.UiTheme)
local HubPanelUi = require(script.Parent.HubPanelUi)
local HubShopUi = require(script.Parent.HubShopUi)
local LedgerUi = require(script.Parent.LedgerUi)

local HubDialogueUi = {}

local player = Players.LocalPlayer

function HubDialogueUi.open(npcId: string)
	local config = HubNpcConfig.get(npcId)
	if not config then
		return
	end

	local screenGui, panel, statusLabel = HubPanelUi.createModal(
		player:WaitForChild("PlayerGui"),
		`HubDialogue_{npcId}`,
		config.displayName,
		Vector2.new(380, 260)
	)

	local y = 48
	for _, line in config.lines do
		UiTheme.createLabel(panel, {
			Position = UDim2.fromOffset(12, y),
			Size = UDim2.new(1, -24, 0, 40),
			Text = line,
			TextWrapped = true,
			TextSize = 14,
		})
		y += 44
	end

	if config.opensLedger then
		UiTheme.createButton(panel, {
			Position = UDim2.fromOffset(12, y + 8),
			Size = UDim2.new(1, -24, 0, 36),
			Text = "View Mayor's Ledger",
			BackgroundColor3 = UiTheme.AccentFarm,
		}).MouseButton1Click:Connect(function()
			screenGui:Destroy()
			LedgerUi.open()
		end)
	elseif config.shopId then
		UiTheme.createButton(panel, {
			Position = UDim2.fromOffset(12, y + 8),
			Size = UDim2.new(1, -24, 0, 36),
			Text = "Browse Shop",
			BackgroundColor3 = UiTheme.Success,
		}).MouseButton1Click:Connect(function()
			screenGui:Destroy()
			HubShopUi.open(config.shopId)
		end)
	end

	statusLabel.Text = ""
end

return HubDialogueUi
