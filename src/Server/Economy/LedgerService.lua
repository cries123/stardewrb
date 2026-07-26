local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataUtil = require(ReplicatedStorage.Shared.Data.PlayerDataUtil)

local LedgerService = {}

function LedgerService.recordGoldEarned(data, amount: number)
	if amount <= 0 then
		return
	end

	PlayerDataUtil.ensureDefaults(data)
	data.Ledger.TotalGoldEarned += amount
end

function LedgerService.recordGoldSpent(data, amount: number)
	if amount <= 0 then
		return
	end

	PlayerDataUtil.ensureDefaults(data)
	data.Ledger.TotalGoldSpent += amount
end

function LedgerService.recordCropsSold(data, amount: number)
	if amount <= 0 then
		return
	end

	PlayerDataUtil.ensureDefaults(data)
	data.Ledger.TotalCropsSold += amount
end

return LedgerService
