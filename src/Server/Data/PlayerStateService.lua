local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local Remotes = require(script.Parent.Parent.Net.Remotes)

local PlayerStateService = {}

function PlayerStateService.replicate(player: Player)
	local data = DataService.getData(player)
	if not data then
		return
	end

	Remotes.getEvent("PlayerStateUpdate"):FireClient(player, {
		Inventory = data.Inventory,
		Money = data.Money,
		Stats = data.Stats,
		PendingShipment = data.PendingShipment,
	})
end

return PlayerStateService
