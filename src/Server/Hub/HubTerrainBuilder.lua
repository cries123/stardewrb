--[[
	Procedural terrain: grass valley, western river trench, raised tree-line hills.
]]

local HubTerrainBuilder = {}

local TERRAIN_FLAG = "HubTerrainBuilt"

function HubTerrainBuilder.isBuilt(folder: Folder): boolean
	return folder:GetAttribute(TERRAIN_FLAG) == true
end

function HubTerrainBuilder.markBuilt(folder: Folder)
	folder:SetAttribute(TERRAIN_FLAG, true)
end

function HubTerrainBuilder.build(folder: Folder, platformSize: number)
	if HubTerrainBuilder.isBuilt(folder) then
		return
	end

	local terrainFolder = Instance.new("Folder")
	terrainFolder.Name = "Terrain"
	terrainFolder.Parent = folder

	local terrain = workspace.Terrain
	terrain:Clear()

	local half = platformSize / 2

	-- Base grass bowl
	terrain:FillBlock(CFrame.new(0, -10, 0), Vector3.new(platformSize + 40, 20, platformSize + 40), Enum.Material.Grass)

	-- Western river trench
	terrain:FillBlock(CFrame.new(-half + 18, -14, 0), Vector3.new(36, 24, platformSize + 20), Enum.Material.Water)

	-- Raised hills around the perimeter (hides world edge)
	local hillSpecs = {
		{ Vector3.new(half - 20, 0, half - 20), 42 },
		{ Vector3.new(-half + 50, 0, half - 20), 38 },
		{ Vector3.new(half - 20, 0, -half + 20), 40 },
		{ Vector3.new(-half + 50, 0, -half + 20), 36 },
		{ Vector3.new(0, 0, half - 8), 50 },
		{ Vector3.new(0, 0, -half + 8), 48 },
		{ Vector3.new(half - 8, 0, 0), 46 },
	}

	for index, spec in hillSpecs do
		local position, radius = spec[1], spec[2]
		terrain:FillBall(CFrame.new(position + Vector3.new(0, 6, 0)), radius, Enum.Material.Grass)
		local marker = Instance.new("Part")
		marker.Name = `HillMarker_{index}`
		marker.Anchored = true
		marker.CanCollide = false
		marker.Transparency = 1
		marker.Size = Vector3.new(1, 1, 1)
		marker.Position = position
		marker.Parent = terrainFolder
	end

	-- Flatten town center for buildings
	terrain:FillBlock(CFrame.new(0, -6, 0), Vector3.new(120, 12, 120), Enum.Material.Grass)

	HubTerrainBuilder.markBuilt(folder)
end

return HubTerrainBuilder
