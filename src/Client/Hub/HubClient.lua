local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local Remotes = require(script.Parent.Net.Remotes)

local HubClient = {}

function HubClient.init()
	if not PlaceType.isHub() then
		return
	end

	local teleportToFarm = Remotes.waitForEvent("TeleportToFarm")
	local teleportResult = Remotes.waitForEvent("TeleportResult")

	teleportResult.OnClientEvent:Connect(function(success, message)
		if not success then
			warn(`[Hub] Teleport failed: {message}`)
		end
	end)

	-- Optional: bind a GUI button named "FarmPortalButton" in PlayerGui.
	local player = Players.LocalPlayer
	player.PlayerGui.ChildAdded:Connect(function(child)
		if child.Name == "FarmPortalButton" and child:IsA("TextButton") then
			child.MouseButton1Click:Connect(function()
				teleportToFarm:FireServer()
			end)
		end
	end)

	for _, child in player.PlayerGui:GetChildren() do
		if child.Name == "FarmPortalButton" and child:IsA("TextButton") then
			child.MouseButton1Click:Connect(function()
				teleportToFarm:FireServer()
			end)
		end
	end
end

return HubClient
