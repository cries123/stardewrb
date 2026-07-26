local GameConfig = require(script.Parent.GameConfig)

local function createEmptyGrid()
	local grid = {}
	for x = 1, GameConfig.Farm.GridWidth do
		grid[x] = {}
		for y = 1, GameConfig.Farm.GridHeight do
			grid[x][y] = {
				soil = "Empty", -- Empty | Tilled
				crop = nil, -- nil | { cropId, stage, plantedOnDay, lastWateredDay }
			}
		end
	end
	return grid
end

local ProfileTemplate = {
	Money = GameConfig.StartingMoney,

	Stats = {
		Energy = 100,
		MaxEnergy = 100,
		Health = 100,
		MaxHealth = 100,
	},

	Inventory = {
		Tools = {
			Hoe = 1,
			WateringCan = 1,
		},
		Seeds = {
			TomatoSeed = 5,
		},
		Harvest = {
			Tomato = 0,
		},
		Food = {},
	},

	PendingShipment = {},

	Ledger = {
		TotalGoldEarned = 0,
		TotalGoldSpent = 0,
		TotalCropsSold = 0,
	},

	FarmState = {
		-- Reserved-server access code for this player's private farm instance.
		PrivateServerCode = nil,
		Grid = createEmptyGrid(),
	},
}

return ProfileTemplate
