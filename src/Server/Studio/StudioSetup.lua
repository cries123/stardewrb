--[[
	Studio-only helpers for local testing.
	Farm world geometry is built by FarmWorldService on all farm servers.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)

local StudioSetup = {}

function StudioSetup.init()
	if not game:GetService("RunService"):IsStudio() then
		return
	end

	if PlaceType.isHub() then
		-- Hub portal is created by PortalService on all hub servers.
	end
end

return StudioSetup
