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

	StartingMoney = 100,

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
		},
	},
}

if not GameConfig.ActionEnergyCost then
	GameConfig.ActionEnergyCost = {
		Till = 2,
		Water = 2,
		Plant = 2,
		Harvest = 1,
	}
end

return GameConfig
