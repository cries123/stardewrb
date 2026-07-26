local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local TimeMath = {}

function TimeMath.getElapsedRealSeconds(now: number?): number
	local timestamp = now or os.time()
	return timestamp - GameConfig.TimeEpoch
end

function TimeMath.getGameDay(now: number?): number
	local elapsed = TimeMath.getElapsedRealSeconds(now)
	return math.floor(elapsed / GameConfig.RealSecondsPerGameDay)
end

function TimeMath.getDayProgress(now: number?): number
	local elapsed = TimeMath.getElapsedRealSeconds(now)
	local dayFraction = (elapsed % GameConfig.RealSecondsPerGameDay) / GameConfig.RealSecondsPerGameDay
	return dayFraction
end

-- Returns a 24-hour clock value (0-24) aligned across all universe servers.
function TimeMath.getClockTime(now: number?): number
	local dayProgress = TimeMath.getDayProgress(now)
	local hoursInDay = 24
	local startHour = GameConfig.DayStartHour

	local clock = startHour + dayProgress * hoursInDay
	if clock >= 24 then
		clock -= 24
	end

	return clock
end

function TimeMath.getSnapshot(now: number?)
	local timestamp = now or os.time()
	return {
		epoch = GameConfig.TimeEpoch,
		realSecondsPerGameDay = GameConfig.RealSecondsPerGameDay,
		serverTimestamp = timestamp,
		gameDay = TimeMath.getGameDay(timestamp),
		dayProgress = TimeMath.getDayProgress(timestamp),
		clockTime = TimeMath.getClockTime(timestamp),
	}
end

local DEFAULT_WEEKDAYS = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" }
local DEFAULT_SEASONS = { "Spring", "Summer", "Fall", "Winter" }

function TimeMath.getCalendarLabels(gameDay: number)
	local weekdays = GameConfig.Weekdays
	if typeof(weekdays) ~= "table" or #weekdays == 0 then
		weekdays = DEFAULT_WEEKDAYS
	end

	local seasons = GameConfig.Seasons
	if typeof(seasons) ~= "table" or #seasons == 0 then
		seasons = DEFAULT_SEASONS
	end

	local daysPerSeason = GameConfig.DaysPerSeason
	if typeof(daysPerSeason) ~= "number" or daysPerSeason <= 0 then
		daysPerSeason = 28
	end

	local dayNumber = math.max(1, math.floor(gameDay) + 1)
	local weekdayIndex = (dayNumber % #weekdays) + 1
	local seasonIndex = (math.floor(gameDay / daysPerSeason) % #seasons) + 1

	return {
		dayNumber = dayNumber,
		weekday = weekdays[weekdayIndex],
		season = seasons[seasonIndex],
	}
end

return TimeMath
