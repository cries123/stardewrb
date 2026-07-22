local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage.Shared.Net.RemoteNames)

local Remotes = {}

local function getOrCreateFolder()
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
	return folder
end

function Remotes.getEvent(name: string): RemoteEvent
	local folder = getOrCreateFolder()
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

function Remotes.getFunction(name: string): RemoteFunction
	local folder = getOrCreateFolder()
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

function Remotes.init()
	for _, name in pairs(RemoteNames) do
		if name == "InviteToFarm" then
			Remotes.getFunction(name)
		else
			Remotes.getEvent(name)
		end
	end
end

return Remotes
