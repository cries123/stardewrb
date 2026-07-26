--[[
	Static hub NPC definitions: dialogue and shop links.
]]

local HubNpcConfig = {}

HubNpcConfig.NPCS = {
	Pierre = {
		displayName = "Pierre",
		shopId = "Pierres",
		buildingId = "Pierres",
		doorOffset = Vector3.new(0, 0, -4),
		shirtColor = Color3.fromRGB(52, 110, 58),
		pantsColor = Color3.fromRGB(60, 60, 80),
		lines = {
			"Welcome to Pierre's! Fresh seeds and produce.",
			"Closed on Wednesdays — farmer's holiday.",
		},
	},
	Gus = {
		displayName = "Gus",
		shopId = "Saloon",
		buildingId = "Saloon",
		doorOffset = Vector3.new(0, 0, -4),
		shirtColor = Color3.fromRGB(180, 50, 50),
		pantsColor = Color3.fromRGB(50, 50, 55),
		lines = {
			"Hey there! Hungry? I've got hot meals ready.",
			"Salad and bread restore your energy before a long day on the farm.",
		},
	},
	Clint = {
		displayName = "Clint",
		shopId = "Blacksmith",
		buildingId = "Blacksmith",
		doorOffset = Vector3.new(0, 0, -4),
		shirtColor = Color3.fromRGB(110, 108, 104),
		pantsColor = Color3.fromRGB(70, 70, 75),
		lines = {
			"*clang* Oh! Didn't hear you come in.",
			"Tool upgrades are coming soon. For now, keep your hoe sharp.",
		},
	},
	Lewis = {
		displayName = "Lewis",
		shopId = nil,
		buildingId = "MayorManor",
		doorOffset = Vector3.new(0, 0, -4),
		shirtColor = Color3.fromRGB(178, 140, 98),
		pantsColor = Color3.fromRGB(60, 55, 50),
		lines = {
			"Good to see you, farmer. Pelican Town is proud of your work.",
			"Check the ledger inside for your earnings record.",
		},
		opensLedger = true,
	},
}

function HubNpcConfig.get(npcId: string)
	return HubNpcConfig.NPCS[npcId]
end

function HubNpcConfig.getAll()
	return HubNpcConfig.NPCS
end

return HubNpcConfig
