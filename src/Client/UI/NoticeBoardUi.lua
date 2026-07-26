local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local TimeMath = require(ReplicatedStorage.Shared.Time.TimeMath)
local UiTheme = require(script.Parent.UiTheme)
local HubPanelUi = require(script.Parent.HubPanelUi)

local NoticeBoardUi = {}

local player = Players.LocalPlayer

local function getFestivalMessage(gameDay: number): string
	local calendar = TimeMath.getCalendarLabels(gameDay)
	local festivals = GameConfig.Festivals

	if typeof(festivals) == "table" then
		for _, festival in festivals do
			if festival.season == calendar.season and festival.day == calendar.dayNumber then
				return festival.name or "Festival today!"
			end
		end
	end

	return "No festival today."
end

function NoticeBoardUi.open()
	local snapshot = TimeMath.getSnapshot()
	local calendar = TimeMath.getCalendarLabels(snapshot.gameDay)
	local clockText = NoticeBoardUi._formatClock(snapshot.clockTime)

	local screenGui, panel = HubPanelUi.createModal(
		player:WaitForChild("PlayerGui"),
		"HubNoticeBoard",
		"Pelican Town Notice Board",
		Vector2.new(360, 280)
	)

	UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(12, 48),
		Size = UDim2.new(1, -24, 0, 24),
		Text = `{calendar.weekday}, {calendar.season} {calendar.dayNumber}`,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
	})

	UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(12, 78),
		Size = UDim2.new(1, -24, 0, 20),
		Text = `Time: {clockText}`,
		TextSize = 14,
	})

	UiTheme.createLabel(panel, {
		Position = UDim2.fromOffset(12, 110),
		Size = UDim2.new(1, -24, 0, 22),
		Text = getFestivalMessage(snapshot.gameDay),
		TextColor3 = UiTheme.Accent,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
	})

	local notes = {
		"Pierre's is open 9 AM – 5 PM (closed Wed).",
		"Saloon serves food noon – midnight.",
		"Ship crops at the bin near the square for next-day gold.",
		"Visit your farm through the bus stop south of town.",
	}

	for index, line in notes do
		UiTheme.createLabel(panel, {
			Position = UDim2.fromOffset(12, 140 + (index - 1) * 28),
			Size = UDim2.new(1, -24, 0, 26),
			Text = `• {line}`,
			TextColor3 = UiTheme.TextMuted,
			TextSize = 13,
			TextWrapped = true,
		})
	end

	return screenGui
end

function NoticeBoardUi._formatClock(clockTime: number): string
	local hour = math.floor(clockTime)
	local minute = math.floor((clockTime - hour) * 60)
	local suffix = if hour >= 12 then "pm" else "am"
	local displayHour = hour % 12
	if displayHour == 0 then
		displayHour = 12
	end
	return string.format("%d:%02d %s", displayHour, minute, suffix)
end

return NoticeBoardUi
