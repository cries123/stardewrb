local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileTemplate = require(ReplicatedStorage.Shared.ProfileTemplate)

local PlayerDataUtil = {}

function PlayerDataUtil.ensureDefaults(data)
	if data.Money == nil then
		data.Money = ProfileTemplate.Money
	end

	if data.Stats == nil then
		data.Stats = {
			Energy = ProfileTemplate.Stats.Energy,
			MaxEnergy = ProfileTemplate.Stats.MaxEnergy,
			Health = ProfileTemplate.Stats.Health,
			MaxHealth = ProfileTemplate.Stats.MaxHealth,
		}
	else
		if data.Stats.MaxEnergy == nil then
			data.Stats.MaxEnergy = ProfileTemplate.Stats.MaxEnergy
		end
		if data.Stats.Energy == nil then
			data.Stats.Energy = data.Stats.MaxEnergy
		end
		if data.Stats.MaxHealth == nil then
			data.Stats.MaxHealth = ProfileTemplate.Stats.MaxHealth
		end
		if data.Stats.Health == nil then
			data.Stats.Health = data.Stats.MaxHealth
		end
	end
end

return PlayerDataUtil
