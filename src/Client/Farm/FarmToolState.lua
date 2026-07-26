local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolbarLayout = require(ReplicatedStorage.Shared.Hud.ToolbarLayout)

local FarmToolState = {
	selectedSlot = 1,
	_listeners = {},
}

function FarmToolState.getSelectedSlot(): number
	return FarmToolState.selectedSlot
end

function FarmToolState.setSelectedSlot(slotIndex: number)
	if slotIndex < 1 or slotIndex > ToolbarLayout.SLOT_COUNT then
		return
	end

	if FarmToolState.selectedSlot == slotIndex then
		return
	end

	FarmToolState.selectedSlot = slotIndex
	for _, listener in FarmToolState._listeners do
		task.spawn(listener, slotIndex)
	end
end

function FarmToolState.onChanged(listener)
	table.insert(FarmToolState._listeners, listener)
	return function()
		local index = table.find(FarmToolState._listeners, listener)
		if index then
			table.remove(FarmToolState._listeners, index)
		end
	end
end

function FarmToolState.getSelectedSlotConfig()
	return ToolbarLayout.getSlotConfig(FarmToolState.selectedSlot)
end

function FarmToolState.getSelectedAction(): string?
	local slotConfig = FarmToolState.getSelectedSlotConfig()
	if slotConfig then
		return slotConfig.action
	end
	return nil
end

-- Backwards compatibility for keyboard code paths
function FarmToolState.getSelected()
	local slotConfig = FarmToolState.getSelectedSlotConfig()
	return slotConfig and slotConfig.itemId or "Hoe"
end

function FarmToolState.setSelected(toolId: string)
	for _, slot in ToolbarLayout.HOTBAR do
		if slot.itemId == toolId then
			FarmToolState.setSelectedSlot(slot.slot)
			return
		end
	end
end

function FarmToolState.getActionForTool(_toolId: string): string?
	return FarmToolState.getSelectedAction()
end

return FarmToolState
