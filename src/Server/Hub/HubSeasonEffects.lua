--[[
	Seasonal VFX: particles, roof snow, ties into HubAtmosphereService lighting.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HubLayout = require(ReplicatedStorage.Shared.Hub.HubLayout)
local HubAtmosphereService = require(script.Parent.HubAtmosphereService)

local HubSeasonEffects = {}

local EFFECTS_FOLDER = "SeasonEffects"
local ROOF_ATTR = "HubSeasonRoof"
local SNOW_ATTR = "HubSeasonSnowCap"
local GROUND_Y = HubLayout.GROUND_Y

function HubSeasonEffects.apply(seasonName: string)
	HubSeasonEffects._clear()
	HubAtmosphereService.applySeasonLighting(seasonName)

	local hubWorld = workspace:FindFirstChild("HubWorld")
	if not hubWorld then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = EFFECTS_FOLDER
	folder.Parent = hubWorld

	if seasonName == "Spring" then
		HubSeasonEffects._createSquareEmitter(folder, "CherryBlossoms", Vector3.new(0, GROUND_Y + 8, 0), {
			Color = ColorSequence.new(Color3.fromRGB(255, 190, 210)),
			Size = NumberSequence.new(0.25),
			Rate = 18,
			Lifetime = NumberRange.new(4, 7),
			Speed = NumberRange.new(2, 5),
			SpreadAngle = Vector2.new(45, 45),
		})
	elseif seasonName == "Fall" then
		for _, descendant in hubWorld:GetDescendants() do
			if descendant:IsA("BasePart") and descendant:GetAttribute("HubSeasonPart") == "TreeFoliage" then
				HubSeasonEffects._attachLeafEmitter(descendant, folder)
			end
		end
	elseif seasonName == "Winter" then
		HubSeasonEffects._toggleRoofSnow(hubWorld, true)
		HubSeasonEffects._createSquareEmitter(folder, "Snowfall", Vector3.new(0, GROUND_Y + 40, 0), {
			Color = ColorSequence.new(Color3.fromRGB(240, 245, 255)),
			Size = NumberSequence.new(0.35),
			Rate = 40,
			Lifetime = NumberRange.new(6, 10),
			Speed = NumberRange.new(8, 14),
			SpreadAngle = Vector2.new(60, 60),
			Acceleration = Vector3.new(0, -6, 0),
		})
	else
		HubSeasonEffects._toggleRoofSnow(hubWorld, false)
	end

	if seasonName ~= "Winter" then
		HubSeasonEffects._toggleRoofSnow(hubWorld, false)
	end
end

function HubSeasonEffects._clear()
	local hubWorld = workspace:FindFirstChild("HubWorld")
	if not hubWorld then
		return
	end

	local existing = hubWorld:FindFirstChild(EFFECTS_FOLDER)
	if existing then
		existing:Destroy()
	end
end

function HubSeasonEffects._createSquareEmitter(parent: Folder, name: string, position: Vector3, config)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(80, 1, 80)
	part.Position = position
	part.Parent = parent

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Particles"
	emitter.Color = config.Color
	emitter.Size = config.Size
	emitter.Rate = config.Rate
	emitter.Lifetime = config.Lifetime
	emitter.Speed = config.Speed
	emitter.SpreadAngle = config.SpreadAngle
	emitter.LightEmission = 0.2
	emitter.Transparency = NumberSequence.new(0.1, 1)
	if config.Acceleration then
		emitter.Acceleration = config.Acceleration
	end
	emitter.Parent = part
end

function HubSeasonEffects._attachLeafEmitter(treePart: BasePart, parent: Folder)
	local marker = Instance.new("Part")
	marker.Name = `LeafEmitter_{treePart.Name}`
	marker.Anchored = true
	marker.CanCollide = false
	marker.Transparency = 1
	marker.Size = Vector3.new(1, 1, 1)
	marker.Position = treePart.Position
	marker.Parent = parent

	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Color3.fromRGB(210, 120, 40))
	emitter.Size = NumberSequence.new(0.3)
	emitter.Rate = 6
	emitter.Lifetime = NumberRange.new(3, 5)
	emitter.Speed = NumberRange.new(2, 4)
	emitter.SpreadAngle = Vector2.new(30, 30)
	emitter.LightEmission = 0.1
	emitter.Transparency = NumberSequence.new(0, 1)
	emitter.Parent = marker
end

function HubSeasonEffects._toggleRoofSnow(hubWorld: Folder, enabled: boolean)
	for _, descendant in hubWorld:GetDescendants() do
		if descendant:IsA("BasePart") and descendant:GetAttribute(SNOW_ATTR) then
			descendant.Transparency = if enabled then 0 else 1
			descendant.CanCollide = false
		end
	end
end

function HubSeasonEffects.markRoofSnowCap(roofPart: BasePart, width: number, depth: number)
	local hubWorld = workspace:FindFirstChild("HubWorld")
	local parent = roofPart.Parent
	if not parent then
		return
	end

	local snow = Instance.new("Part")
	snow.Name = "SnowCap"
	snow.Anchored = true
	snow.CanCollide = false
	snow.Size = Vector3.new(width, 0.4, depth)
	snow.Position = roofPart.Position + Vector3.new(0, roofPart.Size.Y / 2 + 0.2, 0)
	snow.Color = Color3.fromRGB(245, 248, 252)
	snow.Material = Enum.Material.Snow
	snow.Transparency = 1
	snow:SetAttribute(SNOW_ATTR, true)
	snow.Parent = parent
end

return HubSeasonEffects
