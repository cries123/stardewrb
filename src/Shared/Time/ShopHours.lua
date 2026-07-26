--[[
	Shared shop open/closed logic for hub stores.
]]

local ShopHours = {}

local function formatHour(hour: number): string
	local suffix = if hour >= 12 then "PM" else "AM"
	local display = hour % 12
	if display == 0 then
		display = 12
	end
	return `{display}:00 {suffix}`
end

function ShopHours.isWeekdayClosed(weekday: string, closedWeekdays: { string }?): boolean
	if not closedWeekdays then
		return false
	end

	for _, closedDay in closedWeekdays do
		if closedDay == weekday then
			return true
		end
	end

	return false
end

function ShopHours.isOpen(clockTime: number, weekday: string, schedule): boolean
	if ShopHours.isWeekdayClosed(weekday, schedule.ClosedWeekdays) then
		return false
	end

	local openHour = schedule.OpenHour
	local closeHour = schedule.CloseHour

	if closeHour == 24 then
		return clockTime >= openHour
	end

	if closeHour > openHour then
		return clockTime >= openHour and clockTime < closeHour
	end

	return clockTime >= openHour or clockTime < closeHour
end

function ShopHours.getClosedReason(clockTime: number, weekday: string, schedule): string
	if ShopHours.isWeekdayClosed(weekday, schedule.ClosedWeekdays) then
		return `Closed on {weekday}`
	end

	local openHour = schedule.OpenHour
	local closeHour = schedule.CloseHour
	if closeHour == 24 then
		closeHour = 0
	end

	if ShopHours.isOpen(clockTime, weekday, schedule) then
		return "Open"
	end

	return `Closed — open {formatHour(openHour)} – {formatHour(closeHour)}`
end

return ShopHours
