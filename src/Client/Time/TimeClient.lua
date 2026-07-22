local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TimeMath = require(ReplicatedStorage.Shared.Time.TimeMath)
local Remotes = require(script.Parent.Parent.Net.Remotes)

local TimeClient = {}

function TimeClient.init()
	local timeSync = Remotes.waitForEvent("TimeSync")

	timeSync.OnClientEvent:Connect(function(snapshot)
		if typeof(snapshot) == "table" and snapshot.clockTime then
			Lighting.ClockTime = snapshot.clockTime
		end
	end)

	-- Request an immediate sync on join.
	timeSync:FireServer()

	-- Local interpolation between server broadcasts.
	task.spawn(function()
		while true do
			Lighting.ClockTime = TimeMath.getClockTime()
			task.wait(0.25)
		end
	end)
end

return TimeClient
