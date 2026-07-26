local FarmToolState = {
	selected = "Hoe",
	_listeners = {},
}

local TOOL_ORDER = { "Hoe", "WateringCan", "TomatoSeed", "Harvest" }

function FarmToolState.getSelected()
	return FarmToolState.selected
end

function FarmToolState.setSelected(toolId: string)
	if FarmToolState.selected == toolId then
		return
	end

	FarmToolState.selected = toolId
	for _, listener in FarmToolState._listeners do
		task.spawn(listener, toolId)
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

function FarmToolState.getToolOrder()
	return TOOL_ORDER
end

function FarmToolState.getActionForTool(toolId: string): string?
	if toolId == "Hoe" then
		return "Till"
	elseif toolId == "WateringCan" then
		return "Water"
	elseif toolId == "TomatoSeed" then
		return "Plant"
	elseif toolId == "Harvest" then
		return "Harvest"
	end
	return nil
end

return FarmToolState
