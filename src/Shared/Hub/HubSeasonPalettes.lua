--[[
	Seasonal color palettes for hub nature and ground accents.
	HubSeasonService applies these when the in-game season changes.
]]

local HubSeasonPalettes = {
	Spring = {
		Grass = Color3.fromRGB(88, 140, 72),
		Path = Color3.fromRGB(148, 132, 108),
		TreeFoliage = Color3.fromRGB(72, 150, 68),
		TreeTrunk = Color3.fromRGB(102, 72, 44),
		Bush = Color3.fromRGB(64, 130, 58),
		Flower = Color3.fromRGB(240, 140, 180),
		River = Color3.fromRGB(72, 130, 185),
		GroundAccent = Color3.fromRGB(110, 165, 90),
	},
	Summer = {
		Grass = Color3.fromRGB(76, 128, 58),
		Path = Color3.fromRGB(140, 124, 98),
		TreeFoliage = Color3.fromRGB(48, 120, 52),
		TreeTrunk = Color3.fromRGB(96, 66, 40),
		Bush = Color3.fromRGB(52, 110, 48),
		Flower = Color3.fromRGB(255, 210, 80),
		River = Color3.fromRGB(58, 118, 175),
		GroundAccent = Color3.fromRGB(92, 145, 72),
	},
	Fall = {
		Grass = Color3.fromRGB(98, 118, 62),
		Path = Color3.fromRGB(132, 116, 90),
		TreeFoliage = Color3.fromRGB(200, 110, 48),
		TreeTrunk = Color3.fromRGB(92, 60, 36),
		Bush = Color3.fromRGB(170, 95, 42),
		Flower = Color3.fromRGB(210, 130, 60),
		River = Color3.fromRGB(64, 108, 160),
		GroundAccent = Color3.fromRGB(140, 100, 50),
	},
	Winter = {
		Grass = Color3.fromRGB(210, 215, 220),
		Path = Color3.fromRGB(175, 180, 188),
		TreeFoliage = Color3.fromRGB(120, 100, 88),
		TreeTrunk = Color3.fromRGB(88, 62, 38),
		Bush = Color3.fromRGB(140, 150, 158),
		Flower = Color3.fromRGB(200, 210, 220),
		River = Color3.fromRGB(120, 155, 190),
		GroundAccent = Color3.fromRGB(230, 235, 240),
	},
}

function HubSeasonPalettes.getPalette(seasonName: string)
	return HubSeasonPalettes[seasonName] or HubSeasonPalettes.Spring
end

return HubSeasonPalettes
