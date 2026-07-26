local GameConfig = require(script.Parent.Parent.GameConfig)

local ToolbarLayout = {
	SLOT_COUNT = 12,
	HOTBAR = {
		{
			slot = 1,
			itemId = "Hoe",
			kind = "tool",
			icon = "Hoe",
			action = "Till",
		},
		{
			slot = 2,
			itemId = "WateringCan",
			kind = "tool",
			icon = "Can",
			action = "Water",
		},
		{
			slot = 3,
			itemId = "TomatoSeed",
			kind = "seed",
			icon = "Seed",
			action = "Plant",
		},
		{
			slot = 4,
			itemId = "Tomato",
			kind = "harvest",
			icon = "Tom",
			action = "Harvest",
			sellable = true,
		},
	},
}

local HOTKEYS = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Zero,
	Enum.KeyCode.Minus,
	Enum.KeyCode.Equals,
}

function ToolbarLayout.getHotkeyForSlot(slotIndex: number): Enum.KeyCode?
	return HOTKEYS[slotIndex]
end

function ToolbarLayout.getSlotConfig(slotIndex: number)
	for _, slot in ToolbarLayout.HOTBAR do
		if slot.slot == slotIndex then
			return slot
		end
	end
	return nil
end

function ToolbarLayout.getItemCount(inventory, slotConfig)
	if not inventory or not slotConfig then
		return 0
	end

	if slotConfig.kind == "tool" then
		return inventory.Tools[slotConfig.itemId] or 0
	elseif slotConfig.kind == "seed" then
		return inventory.Seeds[slotConfig.itemId] or 0
	elseif slotConfig.kind == "harvest" then
		return inventory.Harvest[slotConfig.itemId] or 0
	end

	return 0
end

function ToolbarLayout.getSellPrice(itemId: string): number
	local crop = GameConfig.Crops[itemId]
	if crop and crop.SellPrice then
		return crop.SellPrice
	end
	return 0
end

return ToolbarLayout
