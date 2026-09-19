local Config = {}

Config.GameName = "Rescue Simulator"
Config.Version = "0.1.0"

Config.StartingMoney = 2500
Config.StartingLevel = 1

-- W Roblox Studio panel administratora jest dostępny automatycznie,
-- żeby łatwo testować grę.
Config.AllowStudioAdmin = true

-- Przed publikacją dodaj tutaj Roblox UserId administratorów.
Config.AdminUserIds = {
	-- 123456789,
}

Config.Tower = {
	BaseUpgradeCost = 500,
	CostMultiplier = 1.65,
	MaxLevel = 25,
}

Config.Maps = {
	{
		Id = "starter_island",
		Name = "Starter Rescue Island",
		Description = "Główna wyspa testowa z wieżą ratownika i jeziorkiem.",
		RequiredLevel = 1,
		Available = true,
		SpawnName = "StarterIslandSpawn",
	},
	{
		Id = "harbor_island",
		Name = "Harbor Island",
		Description = "Wyspa portowa - przygotowana pod kolejny etap projektu.",
		RequiredLevel = 5,
		Available = false,
		SpawnName = "HarborIslandSpawn",
	},
	{
		Id = "storm_island",
		Name = "Storm Island",
		Description = "Trudniejsza wyspa ratownicza - wkrótce.",
		RequiredLevel = 10,
		Available = false,
		SpawnName = "StormIslandSpawn",
	},
}

Config.Pets = {
	{
		Id = "rescue_dog",
		Name = "Rescue Dog",
		Icon = "🐶",
		Rarity = "Common",
		Color = Color3.fromRGB(191, 129, 79),
	},
	{
		Id = "lifeguard_duck",
		Name = "Lifeguard Duck",
		Icon = "🦆",
		Rarity = "Rare",
		Color = Color3.fromRGB(255, 221, 64),
	},
	{
		Id = "rescue_turtle",
		Name = "Rescue Turtle",
		Icon = "🐢",
		Rarity = "Epic",
		Color = Color3.fromRGB(75, 180, 105),
	},
}

Config.ShopItems = {
	{
		Id = "rescue_buoy",
		Name = "Rescue Buoy",
		Description = "Podstawowa bojka ratownicza.",
		Icon = "🛟",
		Price = 600,
		Color = Color3.fromRGB(235, 72, 72),
	},
	{
		Id = "rescue_vest",
		Name = "Rescue Vest",
		Description = "Kamizelka ratownika.",
		Icon = "🦺",
		Price = 900,
		Color = Color3.fromRGB(255, 143, 48),
	},
	{
		Id = "binoculars",
		Name = "Lifeguard Binoculars",
		Description = "Lornetka do obserwacji plaży.",
		Icon = "🔭",
		Price = 1250,
		Color = Color3.fromRGB(60, 67, 75),
	},
	{
		Id = "sun_cream",
		Name = "Sun Cream",
		Description = "Krem przeciwsłoneczny ratownika.",
		Icon = "🧴",
		Price = 350,
		Color = Color3.fromRGB(239, 235, 211),
	},
	{
		Id = "megaphone",
		Name = "Rescue Megaphone",
		Description = "Megafon do kierowania akcją ratowniczą.",
		Icon = "📣",
		Price = 1500,
		Color = Color3.fromRGB(240, 240, 240),
	},
}

function Config.GetMap(mapId)
	for _, map in ipairs(Config.Maps) do
		if map.Id == mapId then
			return map
		end
	end
	return nil
end

function Config.GetPet(petId)
	for _, pet in ipairs(Config.Pets) do
		if pet.Id == petId then
			return pet
		end
	end
	return nil
end

function Config.GetShopItem(itemId)
	for _, item in ipairs(Config.ShopItems) do
		if item.Id == itemId then
			return item
		end
	end
	return nil
end

return Config
