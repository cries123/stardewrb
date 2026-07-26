local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local HubShopUi = require(script.Parent.Parent.UI.HubShopUi)
local HubDialogueUi = require(script.Parent.Parent.UI.HubDialogueUi)
local NoticeBoardUi = require(script.Parent.Parent.UI.NoticeBoardUi)
local ShippingBinUi = require(script.Parent.Parent.UI.ShippingBinUi)
local LedgerUi = require(script.Parent.Parent.UI.LedgerUi)

local HubInteractionClient = {}

local HUB_INTERACTION_ATTR = "HubInteraction"
local HUB_NPC_ATTR = "HubNpcId"

function HubInteractionClient.init()
	if not PlaceType.isHub() then
		return
	end

	HubInteractionClient._watchWorkspace()
end

function HubInteractionClient._watchWorkspace()
	local function bindPart(part: BasePart)
		local npcId = part:GetAttribute(HUB_NPC_ATTR)
		if typeof(npcId) == "string" then
			local prompt = part:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				HubInteractionClient._bindNpcPrompt(prompt, npcId)
			end
			return
		end

		local interactionId = part:GetAttribute(HUB_INTERACTION_ATTR)
		if typeof(interactionId) ~= "string" then
			return
		end

		local prompt = part:FindFirstChildOfClass("ProximityPrompt")
		if not prompt then
			part.ChildAdded:Connect(function(child)
				if child:IsA("ProximityPrompt") then
					if part:GetAttribute(HUB_NPC_ATTR) then
						HubInteractionClient._bindNpcPrompt(child, part:GetAttribute(HUB_NPC_ATTR))
					else
						HubInteractionClient._bindPrompt(child, interactionId)
					end
				end
			end)
			return
		end

		HubInteractionClient._bindPrompt(prompt, interactionId)
	end

	local function scanFolder(folder: Instance)
		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BasePart") then
				if descendant:GetAttribute(HUB_NPC_ATTR) then
					bindPart(descendant)
				elseif descendant:GetAttribute(HUB_INTERACTION_ATTR) then
					bindPart(descendant)
				end
			elseif descendant:IsA("ProximityPrompt") then
				local parent = descendant.Parent
				if parent and parent:IsA("BasePart") then
					local npcId = parent:GetAttribute(HUB_NPC_ATTR)
					if npcId then
						HubInteractionClient._bindNpcPrompt(descendant, npcId)
					else
						local interactionId = parent:GetAttribute(HUB_INTERACTION_ATTR)
						if interactionId then
							HubInteractionClient._bindPrompt(descendant, interactionId)
						end
					end
				end
			end
		end

		folder.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("BasePart") and (descendant:GetAttribute(HUB_NPC_ATTR) or descendant:GetAttribute(HUB_INTERACTION_ATTR)) then
				bindPart(descendant)
			elseif descendant:IsA("ProximityPrompt") then
				local parent = descendant.Parent
				if parent and parent:IsA("BasePart") then
					local npcId = parent:GetAttribute(HUB_NPC_ATTR)
					if npcId then
						HubInteractionClient._bindNpcPrompt(descendant, npcId)
					else
						local interactionId = parent:GetAttribute(HUB_INTERACTION_ATTR)
						if interactionId then
							HubInteractionClient._bindPrompt(descendant, interactionId)
						end
					end
				end
			end
		end)
	end

	local hubWorld = workspace:WaitForChild("HubWorld", 30)
	if hubWorld then
		scanFolder(hubWorld)
	end

	workspace.ChildAdded:Connect(function(child)
		if child.Name == "HubWorld" then
			scanFolder(child)
		end
	end)
end

function HubInteractionClient._bindNpcPrompt(prompt: ProximityPrompt, npcId: string)
	if prompt:GetAttribute("HubNpcBound") then
		return
	end

	prompt:SetAttribute("HubNpcBound", true)
	prompt.Triggered:Connect(function()
		HubDialogueUi.open(npcId)
	end)
end

function HubInteractionClient._bindPrompt(prompt: ProximityPrompt, interactionId: string)
	if prompt:GetAttribute("HubInteractionBound") then
		return
	end

	prompt:SetAttribute("HubInteractionBound", true)
	prompt.Triggered:Connect(function()
		if interactionId == "Pierres" or interactionId == "Saloon" then
			HubShopUi.open(interactionId)
		elseif interactionId == "Blacksmith" then
			HubDialogueUi.open("Clint")
		elseif interactionId == "MayorManor" then
			LedgerUi.open()
		elseif interactionId == "NoticeBoard" then
			NoticeBoardUi.open()
		elseif interactionId == "ShippingBin" then
			ShippingBinUi.open()
		end
	end)
end

return HubInteractionClient
