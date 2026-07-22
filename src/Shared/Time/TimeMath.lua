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

return TimeMath
