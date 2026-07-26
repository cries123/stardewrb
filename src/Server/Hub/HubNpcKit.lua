--[[
	Spawns simple static NPC rigs at shop doors with talk prompts.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HubLayout = require(ReplicatedStorage.Shared.Hub.HubLayout)
local HubNpcConfig = require(ReplicatedStorage.Shared.Hub.HubNpcConfig)
local HubInteractionService = require(script.Parent.HubInteractionService)

local HubNpcKit = {}

local GROUND_Y = HubLayout.GROUND_Y
local NPC_ATTR = "HubNpcId"

local function createPart(props): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.Name = props.Name or "Part"
	part.Size = props.Size
	part.Position = props.Position
	part.Color = props.Color or Color3.fromRGB(200, 200, 200)
	part.Material = props.Material or Enum.Material.SmoothPlastic
	part.CanCollide = false
	part.Parent = props.Parent
	return part
end

local function createBillboard(folder: Model, text: string, position: Vector3)
	local anchor = createPart({
		Name = "NameTag",
		Parent = folder,
		Size = Vector3.new(1, 1, 1),
		Position = position + Vector3.new(0, 4.5, 0),
		Transparency = 1,
	})

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(120, 32)
	billboard.StudsOffset = Vector3.new(0, 0, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = anchor

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 240, 210)
	label.TextScaled = true
	label.Parent = billboard
end

function HubNpcKit.spawnAll(parent: Folder, buildingsFolder: Folder)
	local npcsFolder = Instance.new("Folder")
	npcsFolder.Name = "NPCs"
	npcsFolder.Parent = parent

	for npcId, config in HubNpcConfig.getAll() do
		HubNpcKit.spawnNpc(npcsFolder, buildingsFolder, npcId, config)
	end
end

function HubNpcKit.spawnNpc(parent: Folder, buildingsFolder: Folder, npcId: string, config)
	local building = buildingsFolder:FindFirstChild(config.buildingId)
	if not building then
		warn(`[HubNpcKit] Building not found for NPC {npcId}: {config.buildingId}`)
		return
	end

	local door = building:FindFirstChild("Door", true)
	local basePosition
	if door and door:IsA("BasePart") then
		basePosition = door.Position + door.CFrame.LookVector * -3
	else
		local buildingDef = nil
		for _, def in HubLayout.BUILDINGS do
			if def.id == config.buildingId then
				buildingDef = def
				break
			end
		end
		if not buildingDef then
			return
		end
		basePosition = buildingDef.position + Vector3.new(0, GROUND_Y, 0) + Vector3.new(0, 0, -buildingDef.size.Z / 2 - 3)
	end

	local folder = Instance.new("Model")
	folder.Name = npcId
	folder.Parent = parent

	local root = createPart({
		Name = "HumanoidRootPart",
		Parent = folder,
		Size = Vector3.new(2, 2, 1),
		Position = Vector3.new(basePosition.X, GROUND_Y + 3, basePosition.Z),
		Transparency = 1,
	})
	folder.PrimaryPart = root

	createPart({
		Name = "Torso",
		Parent = folder,
		Size = Vector3.new(2.2, 2.4, 1.2),
		Position = root.Position + Vector3.new(0, 0.2, 0),
		Color = config.shirtColor,
	})

	createPart({
		Name = "Head",
		Parent = folder,
		Size = Vector3.new(1.6, 1.6, 1.6),
		Position = root.Position + Vector3.new(0, 2.2, 0),
		Color = Color3.fromRGB(255, 220, 190),
	})

	createPart({
		Name = "Legs",
		Parent = folder,
		Size = Vector3.new(2, 2.2, 1.2),
		Position = root.Position + Vector3.new(0, -2.1, 0),
		Color = config.pantsColor,
	})

	createBillboard(folder, config.displayName, root.Position)

	root:SetAttribute(NPC_ATTR, npcId)
	HubInteractionService.attachNpcPrompt(root, npcId, config.displayName)
end

return HubNpcKit
