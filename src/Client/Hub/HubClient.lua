local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local Remotes = require(script.Parent.Parent.Net.Remotes)

local HubClient = {}

function HubClient.init()
	if not PlaceType.isHub() then
		return
	end

	local teleportResult = Remotes.waitForEvent("TeleportResult")

	teleportResult.OnClientEvent:Connect(function(success, message)
		if not success then
			warn(`[Hub] Teleport failed: {message}`)
		end
	end)
end

return HubClient
