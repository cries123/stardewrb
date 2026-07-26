local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HubSeasonPalettes = require(ReplicatedStorage.Shared.Hub.HubSeasonPalettes)
local TimeMath = require(ReplicatedStorage.Shared.Time.TimeMath)
local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local HubSeasonEffects = require(script.Parent.HubSeasonEffects)

local HubWorldService = require(script.Parent.HubWorldService)

local HubSeasonService = {}

HubSeasonService._currentSeason = nil

function HubSeasonService.init()
	if not PlaceType.isHub() then
		return
	end

	local calendar = TimeMath.getCalendarLabels(TimeMath.getGameDay())
	HubSeasonService.applySeason(calendar.season)
end

function HubSeasonService.applySeason(seasonName: string, forceEffects: boolean?)
	if HubSeasonService._currentSeason == seasonName and not forceEffects then
		return
	end

	HubSeasonService._currentSeason = seasonName
	local palette = HubSeasonPalettes.getPalette(seasonName)
	local seasonAttr = HubWorldService.getSeasonAttributeName()

	local hubWorld = workspace:FindFirstChild("HubWorld")
	if not hubWorld then
		return
	end

	for _, descendant in hubWorld:GetDescendants() do
		if descendant:IsA("BasePart") then
			local partType = descendant:GetAttribute(seasonAttr)
			local color = palette[partType]
			if typeof(color) == "Color3" then
				descendant.Color = color
			end
		end
	end

	print(`[HubSeasonService] Applied {seasonName} palette to town`)
	HubSeasonEffects.apply(seasonName)
end

function HubSeasonService.onNewGameDay(gameDay: number)
	local calendar = TimeMath.getCalendarLabels(gameDay)
	HubSeasonService.applySeason(calendar.season)
end

return HubSeasonService
