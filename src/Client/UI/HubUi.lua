local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local UiTheme = require(script.Parent.UiTheme)
local Remotes = require(script.Parent.Parent.Net.Remotes)

local HubUi = {}

local player = Players.LocalPlayer
local screenGui = nil
local statusLabel = nil
local inviteList = nil

function HubUi.init()
	if not PlaceType.isHub() then
		return
	end

	HubUi._build()
	HubUi._bindRemotes()
	HubUi._refreshInviteList()

	Players.PlayerAdded:Connect(HubUi._refreshInviteList)
	Players.PlayerRemoving:Connect(HubUi._refreshInviteList)
end

function HubUi._setStatus(message: string, isError: boolean?)
	if not statusLabel then
		return
	end
	statusLabel.Text = message
	statusLabel.TextColor3 = if isError then UiTheme.Error else UiTheme.Success
end

function HubUi._build()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StardewRBHubUi"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local panel = Instance.new("Frame")
	panel.Name = "HubPanel"
	panel.AnchorPoint = Vector2.new(0, 0)
	panel.Position = UDim2.fromOffset(16, 160)
	panel.Size = UDim2.fromOffset(260, 260)
	panel.BackgroundColor3 = UiTheme.WoodMid
	panel.BorderSizePixel = 0
	panel.Parent = screenGui
	UiTheme.applyWoodPanel(panel)

	UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(12, 10),
		Size = UDim2.new(1, -24, 0, 24),
		Text = "StardewRB Town",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
	})

	local farmButton = UiTheme.createButton(panel, {
		Position = UDim2.fromOffset(12, 44),
		Size = UDim2.new(1, -24, 0, 40),
		BackgroundColor3 = UiTheme.Accent,
		Text = "Visit My Farm",
	})

	farmButton.MouseButton1Click:Connect(function()
		HubUi._setStatus("Traveling to your farm...")
		Remotes.waitForEvent("TeleportToFarm"):FireServer()
	end)

	UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(12, 96),
		Size = UDim2.new(1, -24, 0, 18),
		Text = "Invite to Farm",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
	})

	inviteList = Instance.new("ScrollingFrame")
	inviteList.Name = "InviteList"
	inviteList.Position = UDim2.fromOffset(12, 120)
	inviteList.Size = UDim2.new(1, -24, 0, 110)
	inviteList.BackgroundColor3 = UiTheme.Background
	inviteList.BorderSizePixel = 0
	inviteList.ScrollBarThickness = 6
	inviteList.CanvasSize = UDim2.fromOffset(0, 0)
	inviteList.Parent = panel
	UiTheme.applyCorner(inviteList)

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 6)
	listLayout.Parent = inviteList

	statusLabel = UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(12, 238),
		Size = UDim2.new(1, -24, 0, 36),
		Text = "Walk into the purple portal or use Visit My Farm.",
		TextColor3 = UiTheme.TextMuted,
		TextSize = 12,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
end

function HubUi._refreshInviteList()
	if not inviteList then
		return
	end

	for _, child in inviteList:GetChildren() do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end

	local inviteRemote = Remotes.waitForFunction("InviteToFarm")
	local otherPlayers = {}

	for _, otherPlayer in Players:GetPlayers() do
		if otherPlayer ~= player then
			table.insert(otherPlayers, otherPlayer)
		end
	end

	if #otherPlayers == 0 then
		local emptyLabel = UiTheme.createLabel(inviteList, {
			Size = UDim2.new(1, -8, 0, 32),
			Text = "No other players in town.",
			TextColor3 = UiTheme.TextMuted,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
		emptyLabel.Position = UDim2.fromOffset(4, 4)
		inviteList.CanvasSize = UDim2.fromOffset(0, 40)
		return
	end

	for index, otherPlayer in otherPlayers do
		local row = Instance.new("Frame")
		row.Name = otherPlayer.Name
		row.Size = UDim2.new(1, -8, 0, 34)
		row.BackgroundTransparency = 1
		row.LayoutOrder = index
		row.Parent = inviteList

		UiTheme.createLabel(row, {
			Position = UDim2.fromOffset(4, 0),
			Size = UDim2.new(1, -88, 1, 0),
			Text = otherPlayer.DisplayName,
			TextSize = 14,
		})

		local inviteButton = UiTheme.createButton(row, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -4, 0.5, 0),
			Size = UDim2.fromOffset(72, 28),
			Text = "Invite",
			TextSize = 12,
		})

		inviteButton.MouseButton1Click:Connect(function()
			HubUi._setStatus(`Inviting {otherPlayer.DisplayName}...`)
			local ok, message = inviteRemote:InvokeServer(otherPlayer)
			if ok then
				HubUi._setStatus(message or "Invite sent!", false)
			else
				HubUi._setStatus(message or "Invite failed.", true)
			end
		end)
	end

	task.defer(function()
		local layout = inviteList:FindFirstChildOfClass("UIListLayout")
		if layout then
			inviteList.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
		end
	end)
end

function HubUi._bindRemotes()
	local teleportResult = Remotes.waitForEvent("TeleportResult")
	teleportResult.OnClientEvent:Connect(function(success, message)
		if success then
			HubUi._setStatus(message or "Teleporting...", false)
		else
			HubUi._setStatus(message or "Teleport failed.", true)
		end
	end)
end

return HubUi
