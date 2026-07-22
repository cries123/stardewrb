local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage.Shared.Net.RemoteNames)

local Remotes = {}

local function getFolder()
	return ReplicatedStorage:WaitForChild("Remotes", 30)
end

function Remotes.waitForEvent(name: string): RemoteEvent
	local folder = getFolder()
	return folder:WaitForChild(name, 30)
end

function Remotes.waitForFunction(name: string): RemoteFunction
	local folder = getFolder()
	return folder:WaitForChild(name, 30)
end

function Remotes.getNames()
	return RemoteNames
end

return Remotes
