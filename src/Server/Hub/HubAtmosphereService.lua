local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local TimeMath = require(ReplicatedStorage.Shared.Time.TimeMath)
local HubNatureKit = require(script.Parent.HubNatureKit)

local HubAtmosphereService = {}

local LAMP_TAG = HubNatureKit.getLampTag()

function HubAtmosphereService.init()
	if not PlaceType.isHub() then
		return
	end

	HubAtmosphereService._applyLightingPreset()

	task.spawn(function()
		while true do
			HubAtmosphereService._updateStreetLamps(TimeMath.getClockTime())
			task.wait(0.5)
		end
	end)
end

function HubAtmosphereService._applyLightingPreset()
	-- Technology is place-level only; scripts lack RobloxScript capability in Studio.
	pcall(function()
		Lighting.Technology = Enum.Technology.Future
	end)
	Lighting.GlobalShadows = true
	Lighting.EnvironmentDiffuseScale = 0.4
	Lighting.EnvironmentSpecularScale = 0.6
	Lighting.Ambient = Color3.fromRGB(55, 62, 78)
	Lighting.OutdoorAmbient = Color3.fromRGB(70, 82, 98)
	Lighting.Brightness = 2.2
	Lighting.ClockTime = TimeMath.getClockTime()

	if not Lighting:FindFirstChild("HubBloom") then
		local bloom = Instance.new("BloomEffect")
		bloom.Name = "HubBloom"
		bloom.Intensity = 0.35
		bloom.Size = 24
		bloom.Threshold = 1.1
		bloom.Parent = Lighting
	end

	if not Lighting:FindFirstChild("HubColorCorrection") then
		local correction = Instance.new("ColorCorrectionEffect")
		correction.Name = "HubColorCorrection"
		correction.Brightness = 0.02
		correction.Contrast = 0.08
		correction.Saturation = 0.12
		correction.TintColor = Color3.fromRGB(255, 245, 230)
		correction.Parent = Lighting
	end

	if not Lighting:FindFirstChild("HubAtmosphere") then
		local atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "HubAtmosphere"
		atmosphere.Density = 0.32
		atmosphere.Offset = 0.1
		atmosphere.Color = Color3.fromRGB(190, 210, 235)
		atmosphere.Decay = Color3.fromRGB(120, 140, 180)
		atmosphere.Glare = 0.1
		atmosphere.Haze = 1.2
		atmosphere.Parent = Lighting
	end
end

function HubAtmosphereService._updateStreetLamps(clockTime: number)
	local lampsOn = clockTime >= 18 or clockTime < 6

	local hubWorld = workspace:FindFirstChild("HubWorld")
	if not hubWorld then
		return
	end

	for _, descendant in hubWorld:GetDescendants() do
		if descendant:GetAttribute(LAMP_TAG) then
			if descendant:IsA("PointLight") or descendant:IsA("SurfaceLight") or descendant:IsA("SpotLight") then
				descendant.Enabled = lampsOn
				descendant.Brightness = if lampsOn then 1.6 else 0
			elseif descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
				descendant.Transparency = if lampsOn then 0.1 else 0.55
			end
		end
	end
end

function HubAtmosphereService.applySeasonLighting(seasonName: string)
	local correction = Lighting:FindFirstChild("HubColorCorrection")
	local atmosphere = Lighting:FindFirstChild("HubAtmosphere")

	if seasonName == "Summer" then
		Lighting.Brightness = 2.8
		if correction then
			correction.Brightness = 0.08
			correction.Saturation = 0.22
			correction.TintColor = Color3.fromRGB(255, 248, 220)
		end
		if atmosphere then
			atmosphere.Density = 0.22
			atmosphere.Haze = 0.6
		end
	elseif seasonName == "Winter" then
		Lighting.Brightness = 1.9
		if correction then
			correction.Brightness = 0.04
			correction.Saturation = -0.05
			correction.TintColor = Color3.fromRGB(220, 230, 255)
		end
		if atmosphere then
			atmosphere.Density = 0.38
			atmosphere.Haze = 1.8
			atmosphere.Color = Color3.fromRGB(210, 220, 240)
		end
	elseif seasonName == "Fall" then
		Lighting.Brightness = 2.1
		if correction then
			correction.Brightness = 0.03
			correction.Saturation = 0.15
			correction.TintColor = Color3.fromRGB(255, 235, 200)
		end
		if atmosphere then
			atmosphere.Density = 0.3
			atmosphere.Haze = 1.0
		end
	else
		Lighting.Brightness = 2.2
		if correction then
			correction.Brightness = 0.02
			correction.Saturation = 0.12
			correction.TintColor = Color3.fromRGB(255, 245, 230)
		end
		if atmosphere then
			atmosphere.Density = 0.32
			atmosphere.Haze = 1.2
		end
	end
end

return HubAtmosphereService
