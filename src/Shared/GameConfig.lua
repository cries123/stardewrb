--[[
	Central configuration for the StardewRB universe.
	Replace PlaceId values after publishing Hub and Farm places.
]]

local GameConfig = {
	-- Studio testing: set to "Hub" or "Farm" when PlaceIds are unpublished (0).
	StudioPlaceTypeOverride = nil,
	TimeEpoch = 1753228800, -- 2025-07-23 00:00:00 UTC (example)

	RealSecondsPerGameDay = 1200, -- 20 real minutes = 1 in-game day
	DayStartHour = 6, -- 6 AM when a new day begins visually
	DaysPerSeason = 28,
	Seasons = { "Spring", "Summer", "Fall", "Winter" },
	Weekdays = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" },

	ActionEnergyCost = {
		Till = 2,
		Water = 2,
		Plant = 2,
		Harvest = 1,
	},

	StartingMoney = 140,

	Places = {
		Hub = {
			PlaceId = 0, -- TODO: replace with published Hub place id
			MaxPlayers = 50,
		},
		Farm = {
			PlaceId = 0, -- TODO: replace with published Farm place id
			MaxPlayers = 4,
		},
	},

	DataStore = {
		ProfileKeyPrefix = "Player_",
		ProfileStoreName = "PlayerData_v1",
	},

	Farm = {
		GridWidth = 8,
		GridHeight = 8,
		CellSize = 4, -- studs per grid cell
		Origin = Vector3.new(0, 0, 0), -- world-space origin of cell (1,1)
		PlatformSize = 96, -- large safe ground so players do not fall off
		WallHeight = 16,
	},

	Hub = {
		Origin = Vector3.new(0, 0, 0),
		PlatformSize = 320,
		WallHeight = 20,
	},

	Crops = {
		Tomato = {
			DisplayName = "Tomato",
			GrowthDays = 1, -- days after watering to become harvestable
			HarvestItemId = "Tomato",
			HarvestAmount = 1,
			SellPrice = 20,
		},
	},

	Tools = {
		Hoe = "Hoe",
		WateringCan = "WateringCan",
	},

	Seeds = {
		TomatoSeed = {
			CropId = "Tomato",
			DisplayName = "Tomato Seeds",
			BuyPrice = 20,
		},
	},

	Food = {
		Salad = {
			DisplayName = "Salad",
			BuyPrice = 150,
			EnergyRestore = 40,
			ShopId = "Saloon",
		},
		Bread = {
			DisplayName = "Bread",
			BuyPrice = 80,
			EnergyRestore = 20,
			ShopId = "Saloon",
		},
	},

	Shops = {
		Pierres = {
			DisplayName = "Pierre's General Store",
			OpenHour = 9,
			CloseHour = 17,
			ClosedWeekdays = { "Wed" },
			Items = {
				{ itemId = "TomatoSeed", kind = "seed" },
			},
		},
		Saloon = {
			DisplayName = "The Stardrop Saloon",
			OpenHour = 12,
			CloseHour = 24,
			ClosedWeekdays = {},
			Items = {
				{ itemId = "Salad", kind = "food" },
				{ itemId = "Bread", kind = "food" },
			},
		},
	},

	Festivals = {},
}

if not GameConfig.ActionEnergyCost then
	GameConfig.ActionEnergyCost = {
		Till = 2,
		Water = 2,
		Plant = 2,
		Harvest = 1,
	}
end

if not GameConfig.Hub then
	GameConfig.Hub = {
		Origin = Vector3.new(0, 0, 0),
		PlatformSize = 320,
		WallHeight = 20,
	}
end

local privateConfigModule = script.Parent:FindFirstChild("GameConfig.Private")
if privateConfigModule and privateConfigModule:IsA("ModuleScript") then
	local ok, privateConfig = pcall(require, privateConfigModule)
	if ok and type(privateConfig) == "table" then
		if privateConfig.Places then
			if privateConfig.Places.Hub and privateConfig.Places.Hub.PlaceId then
				GameConfig.Places.Hub.PlaceId = privateConfig.Places.Hub.PlaceId
			end
			if privateConfig.Places.Farm and privateConfig.Places.Farm.PlaceId then
				GameConfig.Places.Farm.PlaceId = privateConfig.Places.Farm.PlaceId
			end
		end
		if privateConfig.StudioPlaceTypeOverride ~= nil then
			GameConfig.StudioPlaceTypeOverride = privateConfig.StudioPlaceTypeOverride
		end
	end
end

return GameConfig
