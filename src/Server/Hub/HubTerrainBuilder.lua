--[[
	Procedural terrain: flat town plateau, western river, corner hills only.
	Hills are kept away from roads/spawn so buildings are not buried.
]]

local HubTerrainBuilder = {}

local TERRAIN_FLAG = "HubTerrainBuilt"

function HubTerrainBuilder.isBuilt(folder: Folder): boolean
	return folder:GetAttribute(TERRAIN_FLAG) == true
end

function HubTerrainBuilder.markBuilt(folder: Folder)
	folder:SetAttribute(TERRAIN_FLAG, true)
end

function HubTerrainBuilder.reset(folder: Folder)
	folder:SetAttribute(TERRAIN_FLAG, nil)
end

function HubTerrainBuilder.build(folder: Folder, platformSize: number)
	HubTerrainBuilder.reset(folder)

	local terrainFolder = Instance.new("Folder")
	terrainFolder.Name = "Terrain"
	terrainFolder.Parent = folder

	local terrain = workspace.Terrain
	terrain:Clear()

	local half = platformSize / 2

	-- Flat playable plateau for the whole town (top surface ~Y=0)
	terrain:FillBlock(CFrame.new(0, -5, 0), Vector3.new(platformSize, 10, platformSize), Enum.Material.Grass)

	-- Western river (outside main roads)
	terrain:FillBlock(CFrame.new(-half + 24, -9, 0), Vector3.new(40, 18, platformSize - 20), Enum.Material.Water)

	-- Corner hills only — never on the N/S road where spawn and bus stop sit
	local cornerHills = {
		{ Vector3.new(half - 30, 0, half - 30), 34 },
		{ Vector3.new(half - 30, 0, -half + 30), 34 },
		{ Vector3.new(-half + 70, 0, half - 30), 30 },
		{ Vector3.new(-half + 70, 0, -half + 30), 30 },
	}

	for index, spec in cornerHills do
		local position, radius = spec[1], spec[2]
		terrain:FillBall(CFrame.new(position + Vector3.new(0, 4, 0)), radius, Enum.Material.Grass)
		local marker = Instance.new("Part")
		marker.Name = `HillMarker_{index}`
		marker.Anchored = true
		marker.CanCollide = false
		marker.Transparency = 1
		marker.Size = Vector3.new(1, 1, 1)
		marker.Position = position
		marker.Parent = terrainFolder
	end

	HubTerrainBuilder.markBuilt(folder)
end

return HubTerrainBuilder
