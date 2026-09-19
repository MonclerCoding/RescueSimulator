local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local PlayerDataService = {}

local profiles = {}

local function isConfiguredAdmin(userId)
	return table.find(Config.AdminUserIds, userId) ~= nil
end

function PlayerDataService.IsAdmin(player)
	if RunService:IsStudio() and Config.AllowStudioAdmin then
		return true
	end

	return isConfiguredAdmin(player.UserId)
end

function PlayerDataService.CreateProfile(player)
	if profiles[player] then
		return profiles[player]
	end

	local profile = {
		Money = Config.StartingMoney,
		Level = Config.StartingLevel,
		TowerLevel = 1,
		EquippedPet = "",
		OwnedItems = {},
	}

	for _, item in ipairs(Config.ShopItems) do
		profile.OwnedItems[item.Id] = false
	end

	profiles[player] = profile

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = profile.Money
	money.Parent = leaderstats

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = profile.Level
	level.Parent = leaderstats

	player:SetAttribute("TowerLevel", profile.TowerLevel)
	player:SetAttribute("EquippedPet", profile.EquippedPet)
	player:SetAttribute("IsAdmin", PlayerDataService.IsAdmin(player))

	for _, item in ipairs(Config.ShopItems) do
		player:SetAttribute("Owned_" .. item.Id, false)
	end

	return profile
end

function PlayerDataService.RemoveProfile(player)
	profiles[player] = nil
end

function PlayerDataService.GetProfile(player)
	return profiles[player]
end

function PlayerDataService.GetMoney(player)
	local profile = profiles[player]
	return profile and profile.Money or 0
end

function PlayerDataService.GetLevel(player)
	local profile = profiles[player]
	return profile and profile.Level or 1
end

function PlayerDataService.GetTowerLevel(player)
	local profile = profiles[player]
	return profile and profile.TowerLevel or 1
end

function PlayerDataService.GetEquippedPet(player)
	local profile = profiles[player]
	return profile and profile.EquippedPet or ""
end

function PlayerDataService.SetMoney(player, amount)
	local profile = profiles[player]
	if not profile then
		return false
	end

	amount = math.max(0, math.floor(tonumber(amount) or 0))
	profile.Money = amount

	local leaderstats = player:FindFirstChild("leaderstats")
	local moneyValue = leaderstats and leaderstats:FindFirstChild("Money")
	if moneyValue then
		moneyValue.Value = amount
	end

	return true
end

function PlayerDataService.AddMoney(player, amount)
	amount = math.floor(tonumber(amount) or 0)
	return PlayerDataService.SetMoney(player, PlayerDataService.GetMoney(player) + amount)
end

function PlayerDataService.TrySpendMoney(player, amount)
	amount = math.max(0, math.floor(tonumber(amount) or 0))

	local current = PlayerDataService.GetMoney(player)
	if current < amount then
		return false
	end

	PlayerDataService.SetMoney(player, current - amount)
	return true
end

function PlayerDataService.SetTowerLevel(player, level)
	local profile = profiles[player]
	if not profile then
		return false
	end

	profile.TowerLevel = math.max(1, math.floor(level))
	player:SetAttribute("TowerLevel", profile.TowerLevel)
	return true
end

function PlayerDataService.SetEquippedPet(player, petId)
	local profile = profiles[player]
	if not profile then
		return false
	end

	profile.EquippedPet = petId or ""
	player:SetAttribute("EquippedPet", profile.EquippedPet)
	return true
end

function PlayerDataService.OwnsItem(player, itemId)
	local profile = profiles[player]
	return profile and profile.OwnedItems[itemId] == true
end

function PlayerDataService.MarkItemOwned(player, itemId)
	local profile = profiles[player]
	if not profile then
		return false
	end

	profile.OwnedItems[itemId] = true
	player:SetAttribute("Owned_" .. itemId, true)
	return true
end

Players.PlayerRemoving:Connect(function(player)
	PlayerDataService.RemoveProfile(player)
end)

return PlayerDataService
