local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local TimeMath = require(ReplicatedStorage.Shared.Time.TimeMath)

local FestivalMath = {}

function FestivalMath.getActiveFestival(gameDay: number)
	local calendar = TimeMath.getCalendarLabels(gameDay)
	local dayInSeason = calendar.dayInSeason or TimeMath.getDayInSeason(gameDay)
	local festivals = GameConfig.Festivals

	if typeof(festivals) ~= "table" then
		return nil
	end

	for _, festival in festivals do
		if festival.season == calendar.season and festival.day == dayInSeason then
			return festival
		end
	end

	return nil
end

function FestivalMath.getUpcomingFestival(gameDay: number)
	local calendar = TimeMath.getCalendarLabels(gameDay)
	local dayInSeason = calendar.dayInSeason or TimeMath.getDayInSeason(gameDay)
	local festivals = GameConfig.Festivals
	local daysPerSeason = GameConfig.DaysPerSeason or 28

	if typeof(festivals) ~= "table" then
		return nil
	end

	local best = nil
	local bestDays = daysPerSeason + 1

	for _, festival in festivals do
		if festival.season == calendar.season and festival.day > dayInSeason then
			local daysAway = festival.day - dayInSeason
			if daysAway < bestDays then
				bestDays = daysAway
				best = festival
			end
		end
	end

	return best, bestDays
end

function FestivalMath.getNoticeMessage(gameDay: number): string
	local active = FestivalMath.getActiveFestival(gameDay)
	if active then
		local detail = active.description or "Join the festivities in the town square!"
		return `🎉 {active.name} today! {detail}`
	end

	local upcoming, daysAway = FestivalMath.getUpcomingFestival(gameDay)
	if upcoming and daysAway then
		return `Next up: {upcoming.name} in {daysAway} day(s).`
	end

	return "No festival today."
end

return FestivalMath
