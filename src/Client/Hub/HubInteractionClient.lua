local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceType = require(ReplicatedStorage.Shared.PlaceType)
local HubShopUi = require(script.Parent.Parent.UI.HubShopUi)
local NoticeBoardUi = require(script.Parent.Parent.UI.NoticeBoardUi)
local ShippingBinUi = require(script.Parent.Parent.UI.ShippingBinUi)

local HubInteractionClient = {}

local HUB_INTERACTION_ATTR = "HubInteraction"

function HubInteractionClient.init()
	if not PlaceType.isHub() then
		return
	end

	HubInteractionClient._watchWorkspace()
end

function HubInteractionClient._watchWorkspace()
	local function bindPart(part: BasePart)
		local interactionId = part:GetAttribute(HUB_INTERACTION_ATTR)
		if typeof(interactionId) ~= "string" then
			return
		end

		local prompt = part:FindFirstChildOfClass("ProximityPrompt")
		if not prompt then
			part.ChildAdded:Connect(function(child)
				if child:IsA("ProximityPrompt") then
					HubInteractionClient._bindPrompt(child, interactionId)
				end
			end)
			return
		end

		HubInteractionClient._bindPrompt(prompt, interactionId)
	end

	local function scanFolder(folder: Instance)
		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BasePart") and descendant:GetAttribute(HUB_INTERACTION_ATTR) then
				bindPart(descendant)
			elseif descendant:IsA("ProximityPrompt") then
				local parent = descendant.Parent
				if parent and parent:IsA("BasePart") then
					local interactionId = parent:GetAttribute(HUB_INTERACTION_ATTR)
					if interactionId then
						HubInteractionClient._bindPrompt(descendant, interactionId)
					end
				end
			end
		end

		folder.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("BasePart") and descendant:GetAttribute(HUB_INTERACTION_ATTR) then
				bindPart(descendant)
			elseif descendant:IsA("ProximityPrompt") then
				local parent = descendant.Parent
				if parent and parent:IsA("BasePart") then
					local interactionId = parent:GetAttribute(HUB_INTERACTION_ATTR)
					if interactionId then
						HubInteractionClient._bindPrompt(descendant, interactionId)
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

function HubInteractionClient._bindPrompt(prompt: ProximityPrompt, interactionId: string)
	if prompt:GetAttribute("HubInteractionBound") then
		return
	end

	prompt:SetAttribute("HubInteractionBound", true)
	prompt.Triggered:Connect(function()
		if interactionId == "Pierres" or interactionId == "Saloon" then
			HubShopUi.open(interactionId)
		elseif interactionId == "NoticeBoard" then
			NoticeBoardUi.open()
		elseif interactionId == "ShippingBin" then
			ShippingBinUi.open()
		end
	end)
end

return HubInteractionClient
