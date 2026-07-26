local CollectionService = game:GetService("CollectionService")

local HubInteractionService = {}

local HUB_INTERACTION_ATTR = "HubInteraction"
local PROMPT_TAG = "HubInteractionPrompt"

local INTERACTIONS = {
	Pierres = { actionText = "Shop", objectText = "Pierre's General Store" },
	Saloon = { actionText = "Enter", objectText = "Stardrop Saloon" },
	NoticeBoard = { actionText = "Read", objectText = "Notice Board" },
	ShippingBin = { actionText = "Ship", objectText = "Shipping Bin" },
	Blacksmith = { actionText = "Enter", objectText = "Blacksmith" },
	MayorManor = { actionText = "Visit", objectText = "Mayor's Manor" },
}

function HubInteractionService.init()
	HubInteractionService._bindExisting()
	CollectionService:GetInstanceAddedSignal(PROMPT_TAG):Connect(HubInteractionService._bindPrompt)
end

function HubInteractionService._bindExisting()
	for _, prompt in CollectionService:GetTagged(PROMPT_TAG) do
		HubInteractionService._bindPrompt(prompt)
	end
end

function HubInteractionService._bindPrompt(prompt: Instance)
	if not prompt:IsA("ProximityPrompt") then
		return
	end

	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 12
end

function HubInteractionService.attachPrompt(part: BasePart, interactionId: string)
	local config = INTERACTIONS[interactionId]
	if not config then
		return
	end

	part:SetAttribute(HUB_INTERACTION_ATTR, interactionId)

	local prompt = part:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = "HubPrompt"
		prompt.Parent = part
	end

	prompt.ActionText = config.actionText
	prompt.ObjectText = config.objectText
	prompt.HoldDuration = 0
	CollectionService:AddTag(prompt, PROMPT_TAG)
end

function HubInteractionService.attachNpcPrompt(part: BasePart, npcId: string, displayName: string)
	part:SetAttribute("HubNpcId", npcId)

	local prompt = part:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = "NpcPrompt"
		prompt.Parent = part
	end

	prompt.ActionText = "Talk"
	prompt.ObjectText = displayName
	prompt.HoldDuration = 0
	CollectionService:AddTag(prompt, PROMPT_TAG)
end

return HubInteractionService
