--[[
	Cozy procedural buildings for key Pelican Town POIs.
]]

local HubBuildingKit = {}

local SIGN_WOOD = Color3.fromRGB(55, 42, 32)
local WINDOW_GLASS = Color3.fromRGB(140, 180, 210)
local DOOR_WOOD = Color3.fromRGB(92, 64, 40)

local function createPart(props): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.Name = props.Name or "Part"
	part.Size = props.Size
	part.Position = props.Position
	part.Color = props.Color or Color3.fromRGB(200, 200, 200)
	part.Material = props.Material or Enum.Material.SmoothPlastic
	part.CanCollide = props.CanCollide ~= false
	part.Transparency = props.Transparency or 0
	part.Parent = props.Parent
	return part
end

local function createWedgeRoof(parent: Instance, center: Vector3, width: number, depth: number, height: number, color: Color3)
	local roof = Instance.new("WedgePart")
	roof.Name = "Roof"
	roof.Anchored = true
	roof.Size = Vector3.new(width + 2, height, depth + 2)
	roof.CFrame = CFrame.new(center + Vector3.new(0, height / 2, 0)) * CFrame.Angles(0, 0, math.rad(180))
	roof.Color = color
	roof.Material = Enum.Material.WoodPlanks
	roof.Parent = parent
end

local function createBillboard(adornee: BasePart, title: string, subtitle: string)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(240, 58)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = adornee

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0.55, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(255, 240, 210)
	titleLabel.TextScaled = true
	titleLabel.Parent = billboard

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Position = UDim2.fromScale(0, 0.55)
	subtitleLabel.Size = UDim2.new(1, 0, 0.45, 0)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.Text = subtitle
	subtitleLabel.TextColor3 = Color3.fromRGB(220, 200, 170)
	subtitleLabel.TextScaled = true
	subtitleLabel.Parent = billboard
end

local function addWindows(parent: Instance, origin: Vector3, width: number, height: number, depth: number, wallColor: Color3)
	local windowY = origin.Y + height * 0.55
	for _, xOffset in { -width * 0.25, width * 0.25 } do
		createPart({
			Name = "Window",
			Parent = parent,
			Size = Vector3.new(3, 3, 0.4),
			Position = Vector3.new(origin.X + xOffset, windowY, origin.Z - depth / 2 - 0.2),
			Color = WINDOW_GLASS,
			Material = Enum.Material.Glass,
			Transparency = 0.35,
		})
	end
end

local function addDoor(parent: Instance, origin: Vector3, depth: number, height: number)
	createPart({
		Name = "Door",
		Parent = parent,
		Size = Vector3.new(4, 7, 0.5),
		Position = Vector3.new(origin.X, origin.Y + 3.5, origin.Z - depth / 2 - 0.2),
		Color = DOOR_WOOD,
		Material = Enum.Material.Wood,
	})
end

function HubBuildingKit.build(parent: Folder, def)
	local style = def.style or "generic"
	if style == "plaza" then
		HubBuildingKit.buildTownSquare(parent, def)
	elseif style == "pierre" then
		HubBuildingKit.buildPierres(parent, def)
	elseif style == "saloon" then
		HubBuildingKit.buildSaloon(parent, def)
	elseif style == "clinic" then
		HubBuildingKit.buildClinic(parent, def)
	else
		HubBuildingKit.buildGeneric(parent, def)
	end
end

function HubBuildingKit.buildTownSquare(parent: Folder, def)
	local folder = Instance.new("Folder")
	folder.Name = def.id
	folder.Parent = parent

	local origin = def.position + Vector3.new(0, 3, 0)
	local size = def.size

	createPart({
		Name = "Plaza",
		Parent = folder,
		Size = Vector3.new(size.X, 0.4, size.Z),
		Position = origin,
		Color = Color3.fromRGB(168, 152, 128),
		Material = Enum.Material.Slate,
	})

	-- Fountain
	local basin = createPart({
		Name = "FountainBasin",
		Parent = folder,
		Size = Vector3.new(10, 1.2, 10),
		Position = origin + Vector3.new(0, 0.8, 0),
		Color = Color3.fromRGB(140, 140, 150),
		Material = Enum.Material.Marble,
	})
	basin.Shape = Enum.PartType.Cylinder
	basin.Orientation = Vector3.new(0, 0, 90)

	createPart({
		Name = "FountainWater",
		Parent = folder,
		Size = Vector3.new(7, 0.6, 7),
		Position = origin + Vector3.new(0, 1.1, 0),
		Color = Color3.fromRGB(90, 150, 210),
		Material = Enum.Material.Glass,
		Transparency = 0.25,
	})

	createPart({
		Name = "FountainSpout",
		Parent = folder,
		Size = Vector3.new(1.2, 4, 1.2),
		Position = origin + Vector3.new(0, 2.5, 0),
		Color = Color3.fromRGB(160, 160, 170),
		Material = Enum.Material.Metal,
	})

	-- Notice board
	local board = createPart({
		Name = "NoticeBoard",
		Parent = folder,
		Size = Vector3.new(8, 6, 0.8),
		Position = origin + Vector3.new(0, 4, -14),
		Color = SIGN_WOOD,
		Material = Enum.Material.Wood,
	})
	createBillboard(board, def.name, def.subtitle)

	-- Planters
	for _, offset in { Vector3.new(14, 0, 10), Vector3.new(-14, 0, 10), Vector3.new(14, 0, -10), Vector3.new(-14, 0, -10) } do
		HubBuildingKit._createPlanter(folder, origin + offset)
	end
end

function HubBuildingKit.buildPierres(parent: Folder, def)
	local folder = Instance.new("Folder")
	folder.Name = def.id
	folder.Parent = parent

	local origin = def.position + Vector3.new(0, 3, 0)
	local width, height, depth = def.size.X, def.size.Y, def.size.Z

	createPart({
		Name = "Foundation",
		Parent = folder,
		Size = Vector3.new(width + 4, 1, depth + 6),
		Position = origin + Vector3.new(0, -0.5, 1),
		Color = Color3.fromRGB(130, 130, 130),
		Material = Enum.Material.Concrete,
	})

	createPart({
		Name = "MainHall",
		Parent = folder,
		Size = Vector3.new(width, height, depth),
		Position = origin + Vector3.new(0, height / 2, 0),
		Color = def.wallColor,
		Material = Enum.Material.Brick,
	})

	createWedgeRoof(folder, origin + Vector3.new(0, height + 2, 0), width, depth, 5, def.roofColor)

	-- Green awning over porch
	createPart({
		Name = "Awning",
		Parent = folder,
		Size = Vector3.new(width + 2, 0.4, 5),
		Position = origin + Vector3.new(0, 5, -depth / 2 - 2),
		Color = Color3.fromRGB(52, 110, 58),
		Material = Enum.Material.Fabric,
	})

	createPart({
		Name = "Porch",
		Parent = folder,
		Size = Vector3.new(width, 0.5, 4),
		Position = origin + Vector3.new(0, 0.25, -depth / 2 - 2),
		Color = Color3.fromRGB(150, 120, 90),
		Material = Enum.Material.WoodPlanks,
	})

	addDoor(folder, origin, depth, height)
	addWindows(folder, origin, width, height, depth, def.wallColor)

	local sign = createPart({
		Name = "Sign",
		Parent = folder,
		Size = Vector3.new(12, 3, 0.5),
		Position = origin + Vector3.new(0, height + 6, -depth / 2 - 3),
		Color = Color3.fromRGB(52, 110, 58),
		Material = Enum.Material.Wood,
		CanCollide = false,
	})
	createBillboard(sign, def.name, def.subtitle)
end

function HubBuildingKit.buildSaloon(parent: Folder, def)
	local folder = Instance.new("Folder")
	folder.Name = def.id
	folder.Parent = parent

	local origin = def.position + Vector3.new(0, 3, 0)
	local width, height, depth = def.size.X, def.size.Y, def.size.Z

	createPart({
		Name = "MainHall",
		Parent = folder,
		Size = Vector3.new(width, height, depth),
		Position = origin + Vector3.new(0, height / 2, 0),
		Color = def.wallColor,
		Material = Enum.Material.Brick,
	})

	createPart({
		Name = "Roof",
		Parent = folder,
		Size = Vector3.new(width + 3, 2, depth + 3),
		Position = origin + Vector3.new(0, height + 1, 0),
		Color = def.roofColor,
		Material = Enum.Material.WoodShingles,
	})

	-- Saloon front windows (warm glow)
	for _, xOffset in { -6, 0, 6 } do
		local window = createPart({
			Name = "SaloonWindow",
			Parent = folder,
			Size = Vector3.new(4, 4, 0.4),
			Position = origin + Vector3.new(xOffset, 6, -depth / 2 - 0.2),
			Color = Color3.fromRGB(255, 200, 120),
			Material = Enum.Material.Neon,
			Transparency = 0.15,
		})
		window:SetAttribute("HubStreetLamp", true)
	end

	addDoor(folder, origin, depth, height)

	local sign = createPart({
		Name = "NeonSign",
		Parent = folder,
		Size = Vector3.new(14, 3, 0.5),
		Position = origin + Vector3.new(0, height + 4, -depth / 2 - 2),
		Color = Color3.fromRGB(255, 90, 60),
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	sign:SetAttribute("HubStreetLamp", true)
	createBillboard(sign, def.name, def.subtitle)
end

function HubBuildingKit.buildClinic(parent: Folder, def)
	local folder = Instance.new("Folder")
	folder.Name = def.id
	folder.Parent = parent

	local origin = def.position + Vector3.new(0, 3, 0)
	local width, height, depth = def.size.X, def.size.Y, def.size.Z

	createPart({
		Name = "MainHall",
		Parent = folder,
		Size = Vector3.new(width, height, depth),
		Position = origin + Vector3.new(0, height / 2, 0),
		Color = def.wallColor,
		Material = Enum.Material.SmoothPlastic,
	})

	createWedgeRoof(folder, origin + Vector3.new(0, height + 2, 0), width, depth, 4, def.roofColor)

	-- Red cross
	createPart({
		Name = "CrossV",
		Parent = folder,
		Size = Vector3.new(1.2, 5, 0.4),
		Position = origin + Vector3.new(0, height - 2, -depth / 2 - 0.3),
		Color = Color3.fromRGB(200, 50, 50),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
	createPart({
		Name = "CrossH",
		Parent = folder,
		Size = Vector3.new(4, 1.2, 0.4),
		Position = origin + Vector3.new(0, height - 2, -depth / 2 - 0.3),
		Color = Color3.fromRGB(200, 50, 50),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})

	addDoor(folder, origin, depth, height)
	addWindows(folder, origin, width, height, depth, def.wallColor)

	local sign = createPart({
		Name = "Sign",
		Parent = folder,
		Size = Vector3.new(11, 2.5, 0.5),
		Position = origin + Vector3.new(0, height + 5, -depth / 2 - 2),
		Color = SIGN_WOOD,
		CanCollide = false,
	})
	createBillboard(sign, def.name, def.subtitle)
end

function HubBuildingKit.buildGeneric(parent: Folder, def)
	local folder = Instance.new("Folder")
	folder.Name = def.id
	folder.Parent = parent

	local origin = def.position + Vector3.new(0, 3, 0)
	local width, height, depth = def.size.X, def.size.Y, def.size.Z

	createPart({
		Name = "MainHall",
		Parent = folder,
		Size = Vector3.new(width, height, depth),
		Position = origin + Vector3.new(0, height / 2, 0),
		Color = def.wallColor,
		Material = Enum.Material.Brick,
	})

	createWedgeRoof(folder, origin + Vector3.new(0, height + 2, 0), width, depth, 4, def.roofColor)
	addDoor(folder, origin, depth, height)

	local sign = createPart({
		Name = "Sign",
		Parent = folder,
		Size = Vector3.new(math.min(width, 12), 2, 0.4),
		Position = origin + Vector3.new(0, height + 5, -depth / 2 - 1),
		Color = SIGN_WOOD,
		CanCollide = false,
	})
	createBillboard(sign, def.name, def.subtitle)
end

function HubBuildingKit._createPlanter(parent: Instance, position: Vector3)
	local box = createPart({
		Name = "Planter",
		Parent = parent,
		Size = Vector3.new(4, 1.2, 4),
		Position = position + Vector3.new(0, 0.6, 0),
		Color = Color3.fromRGB(102, 72, 44),
		Material = Enum.Material.Wood,
	})
	box:SetAttribute("HubSeasonPart", "Bush")

	for i = 1, 3 do
		local flower = createPart({
			Name = `PlanterFlower_{i}`,
			Parent = parent,
			Size = Vector3.new(1.4, 1.4, 1.4),
			Position = position + Vector3.new((i - 2) * 1.1, 1.6, 0),
			Color = Color3.fromRGB(240, 140, 180),
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
		flower.Shape = Enum.PartType.Ball
		flower:SetAttribute("HubSeasonPart", "Flower")
	end
end

return HubBuildingKit
