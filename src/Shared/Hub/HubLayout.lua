--[[
	Stardew Valley-inspired Pelican Town layout (simplified for Roblox MVP).
	Positions are world-space XZ around the town square at the origin.
]]

local HubLayout = {}

HubLayout.TOWN_CENTER = Vector3.new(0, 0, 0)
HubLayout.GROUND_Y = 5 -- all parts sit above the terrain plateau

-- Thin walkway segments: { position (y ignored), size (X, _, Z) }
HubLayout.WALKWAYS = {
	{ Vector3.new(0, 0, 0), Vector3.new(10, 0, 280) },
	{ Vector3.new(0, 0, 0), Vector3.new(260, 0, 10) },
	{ Vector3.new(0, 0, 55), Vector3.new(80, 0, 8) },
	{ Vector3.new(0, 0, -55), Vector3.new(80, 0, 8) },
	{ Vector3.new(55, 0, 0), Vector3.new(8, 0, 70) },
	{ Vector3.new(-55, 0, 0), Vector3.new(8, 0, 90) },
	{ Vector3.new(0, 0, 105), Vector3.new(8, 0, 50) },
	{ Vector3.new(0, 0, -105), Vector3.new(8, 0, 40) },
	{ Vector3.new(-95, 0, 0), Vector3.new(8, 0, 120) },
	{ Vector3.new(95, 0, 0), Vector3.new(8, 0, 90) },
}

HubLayout.LAMP_POSTS = {
	Vector3.new(8, 0, -40),
	Vector3.new(-8, 0, -40),
	Vector3.new(8, 0, 40),
	Vector3.new(-8, 0, 40),
	Vector3.new(40, 0, 8),
	Vector3.new(-40, 0, 8),
	Vector3.new(40, 0, -8),
	Vector3.new(-40, 0, -8),
	Vector3.new(0, 0, -70),
	Vector3.new(0, 0, 70),
	Vector3.new(70, 0, -30),
	Vector3.new(-70, 0, 30),
}

HubLayout.FENCE_LINES = {
	{ Vector3.new(-22, 0, 22), Vector3.new(22, 0, 22) },
	{ Vector3.new(-22, 0, -22), Vector3.new(22, 0, -22) },
}

-- { id, name, subtitle, position, size, wallColor, roofColor, tag? }
HubLayout.BUILDINGS = {
	{
		id = "TownSquare",
		name = "Town Square",
		subtitle = "Festivals & notice board",
		position = Vector3.new(0, 0, 0),
		size = Vector3.new(44, 1, 44),
		wallColor = Color3.fromRGB(160, 145, 120),
		roofColor = Color3.fromRGB(160, 145, 120),
		style = "plaza",
	},
	{
		id = "Pierres",
		name = "Pierre's General Store",
		subtitle = "Open 9:00 AM – 5:00 PM (closed Wed)",
		position = Vector3.new(72, 0, -36),
		size = Vector3.new(26, 14, 20),
		wallColor = Color3.fromRGB(186, 128, 78),
		roofColor = Color3.fromRGB(118, 62, 42),
		style = "pierre",
	},
	{
		id = "Saloon",
		name = "The Stardrop Saloon",
		subtitle = "Gus • Open 12:00 PM – 12:00 AM",
		position = Vector3.new(-58, 0, -32),
		size = Vector3.new(28, 14, 22),
		wallColor = Color3.fromRGB(140, 88, 62),
		roofColor = Color3.fromRGB(88, 48, 36),
		style = "saloon",
	},
	{
		id = "Blacksmith",
		name = "Blacksmith",
		subtitle = "Clint • Open 9:00 AM – 4:00 PM",
		position = Vector3.new(72, 0, 38),
		size = Vector3.new(22, 12, 18),
		wallColor = Color3.fromRGB(110, 108, 104),
		roofColor = Color3.fromRGB(72, 70, 68),
	},
	{
		id = "Museum",
		name = "Museum & Library",
		subtitle = "Gunther • Donate artifacts & minerals",
		position = Vector3.new(-62, 0, 52),
		size = Vector3.new(30, 16, 24),
		wallColor = Color3.fromRGB(168, 152, 128),
		roofColor = Color3.fromRGB(96, 72, 56),
	},
	{
		id = "CommunityCenter",
		name = "Community Center",
		subtitle = "Restore through bundles",
		position = Vector3.new(0, 0, 88),
		size = Vector3.new(36, 18, 28),
		wallColor = Color3.fromRGB(152, 118, 88),
		roofColor = Color3.fromRGB(96, 58, 42),
	},
	{
		id = "JojaMart",
		name = "JojaMart",
		subtitle = "Corporate alternative to the Community Center",
		position = Vector3.new(-88, 0, -88),
		size = Vector3.new(32, 14, 26),
		wallColor = Color3.fromRGB(72, 108, 168),
		roofColor = Color3.fromRGB(48, 72, 120),
	},
	{
		id = "Clinic",
		name = "Harvey's Clinic",
		subtitle = "2 River Road • Medical services",
		position = Vector3.new(-92, 0, 8),
		size = Vector3.new(24, 14, 20),
		wallColor = Color3.fromRGB(220, 220, 228),
		roofColor = Color3.fromRGB(148, 72, 72),
		style = "clinic",
	},
	{
		id = "MayorManor",
		name = "Mayor's Manor",
		subtitle = "Lewis • Lost item recovery & ledger",
		position = Vector3.new(42, 0, -72),
		size = Vector3.new(28, 16, 24),
		wallColor = Color3.fromRGB(178, 140, 98),
		roofColor = Color3.fromRGB(108, 68, 48),
	},
	{
		id = "WillowLane1",
		name = "1 Willow Lane",
		subtitle = "Haley & Emily",
		position = Vector3.new(102, 0, -18),
		size = Vector3.new(20, 12, 18),
		wallColor = Color3.fromRGB(198, 168, 138),
		roofColor = Color3.fromRGB(112, 72, 52),
	},
	{
		id = "WillowLane2",
		name = "2 Willow Lane",
		subtitle = "Jodi, Kent, Sam & Vincent",
		position = Vector3.new(102, 0, 22),
		size = Vector3.new(22, 12, 20),
		wallColor = Color3.fromRGB(188, 158, 128),
		roofColor = Color3.fromRGB(104, 68, 48),
	},
	{
		id = "RiverRoadTrailer",
		name = "1 River Road",
		subtitle = "Pam & Penny's trailer",
		position = Vector3.new(-102, 0, -42),
		size = Vector3.new(18, 10, 14),
		wallColor = Color3.fromRGB(168, 148, 118),
		roofColor = Color3.fromRGB(96, 88, 72),
	},
	{
		id = "RiverRoadGeorge",
		name = "1 River Road",
		subtitle = "George & Evelyn",
		position = Vector3.new(-102, 0, 42),
		size = Vector3.new(22, 12, 18),
		wallColor = Color3.fromRGB(176, 152, 122),
		roofColor = Color3.fromRGB(100, 64, 44),
	},
}

HubLayout.RIVER_SIGN = {
	position = Vector3.new(-118, HubLayout.GROUND_Y + 4, 0),
}

HubLayout.HUB_SPAWN = {
	position = Vector3.new(0, HubLayout.GROUND_Y + 1, -45),
}

HubLayout.FARM_PORTAL = {
	position = Vector3.new(0, HubLayout.GROUND_Y + 5, -62),
}

HubLayout.NATURE_CLUSTERS = {
	{ Vector3.new(-160, 0, -120), 8 },
	{ Vector3.new(-160, 0, 120), 7 },
	{ Vector3.new(150, 0, -110), 9 },
	{ Vector3.new(150, 0, 110), 8 },
	{ Vector3.new(0, 0, 145), 6 },
	{ Vector3.new(-40, 0, -100), 5 },
	{ Vector3.new(40, 0, 100), 5 },
	{ Vector3.new(130, 0, 0), 6 },
	{ Vector3.new(-120, 0, -80), 4 },
	{ Vector3.new(-120, 0, 80), 4 },
}

HubLayout.FLOWER_PATCHES = {
	Vector3.new(18, 0, 18),
	Vector3.new(-20, 0, 14),
	Vector3.new(14, 0, -16),
	Vector3.new(-16, 0, -18),
	Vector3.new(30, 0, 50),
	Vector3.new(-35, 0, 60),
}

HubLayout.PLAYGROUND = {
	center = Vector3.new(0, HubLayout.GROUND_Y, 128),
}

HubLayout.SHIPPING_BIN = {
	position = Vector3.new(28, HubLayout.GROUND_Y + 3, -8),
}

return HubLayout
