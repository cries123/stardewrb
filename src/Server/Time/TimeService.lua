local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TimeMath = require(ReplicatedStorage.Shared.Time.TimeMath)
local Remotes = require(script.Parent.Parent.Net.Remotes)

local TimeService = {}
TimeService._lastGameDay = nil

function TimeService.init()
	Remotes.init()

	local timeSync = Remotes.getEvent("TimeSync")
	local lastBroadcast = 0

	local function broadcast()
		local snapshot = TimeMath.getSnapshot()
		timeSync:FireAllClients(snapshot)

		local currentDay = snapshot.gameDay
		if TimeService._lastGameDay ~= nil and currentDay > TimeService._lastGameDay then
			TimeService._onNewDay(currentDay)
		end
		TimeService._lastGameDay = currentDay
	end

	local function applyLighting()
		Lighting.ClockTime = TimeMath.getClockTime()
	end

	broadcast()
	applyLighting()

	task.spawn(function()
		while true do
			applyLighting()
			if os.clock() - lastBroadcast >= 1 then
				broadcast()
				lastBroadcast = os.clock()
			end
			task.wait(0.25)
		end
	end)

	timeSync.OnServerEvent:Connect(function(player)
		timeSync:FireClient(player, TimeMath.getSnapshot())
	end)
end

function TimeService._onNewDay(gameDay: number)
	local farmGridService = require(script.Parent.Farm.FarmGridService)
	farmGridService.onNewGameDay(gameDay)
end

function TimeService.getCurrentGameDay(): number
	return TimeMath.getGameDay()
end

return TimeService
