local Config = {}

Config.GameName = "Rescue Simulator"
Config.Version = "0.3.0"

Config.StartingMoney = 2500
Config.StartingLevel = 1
Config.StartingXP = 0

Config.Progression = {
	MaxLevel = 100,
	BaseXP = 100,
	Growth = 1.18,
}

Config.Ranks = {
	{ MinLevel = 1, Name = "Rookie", ShortName = "ROOKIE" },
	{ MinLevel = 5, Name = "Junior Lifeguard", ShortName = "JUNIOR" },
	{ MinLevel = 10, Name = "Lifeguard", ShortName = "LIFEGUARD" },
	{ MinLevel = 20, Name = "Senior Lifeguard", ShortName = "SENIOR" },
	{ MinLevel = 35, Name = "Rescue Specialist", ShortName = "SPECIALIST" },
	{ MinLevel = 50, Name = "Rescue Captain", ShortName = "CAPTAIN" },
	{ MinLevel = 75, Name = "Rescue Commander", ShortName = "COMMANDER" },
	{ MinLevel = 100, Name = "Rescue Legend", ShortName = "LEGEND" },
}

Config.AllowStudioAdmin = true

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
		Name = "Compact Test Island",
		Description = "Kompaktowa mapa testowa 10x10 pól. Wieża, NPC, spawn i jeziorko są obok siebie.",
		RequiredLevel = 1,
		Available = true,
		SpawnName = "StarterIslandSpawn",
	},
	{
		Id = "harbor_island",
		Name = "Harbor Island",
		Description = "Mapa przygotowana pod kolejny etap.",
		RequiredLevel = 5,
		Available = false,
		SpawnName = "HarborIslandSpawn",
	},
	{
		Id = "storm_island",
		Name = "Storm Island",
		Description = "Trudniejsza mapa ratownicza - później.",
		RequiredLevel = 10,
		Available = false,
		SpawnName = "StormIslandSpawn",
	},
}

Config.Pets = {
	{
		Id = "rescue_dog",
		Name = "Rescue Dog",
		Icon = "DOG",
		Rarity = "Common",
		Color = Color3.fromRGB(191, 129, 79),
	},
	{
		Id = "lifeguard_duck",
		Name = "Lifeguard Duck",
		Icon = "DUCK",
		Rarity = "Rare",
		Color = Color3.fromRGB(255, 221, 64),
	},
	{
		Id = "rescue_turtle",
		Name = "Rescue Turtle",
		Icon = "TURTLE",
		Rarity = "Epic",
		Color = Color3.fromRGB(75, 180, 105),
	},
}

Config.ShopItems = {
	{
		Id = "rescue_buoy",
		Name = "Rescue Buoy",
		Description = "Podstawowa bojka ratownicza.",
		Icon = "BUOY",
		Price = 600,
		Color = Color3.fromRGB(235, 72, 72),
	},
	{
		Id = "rescue_vest",
		Name = "Rescue Vest",
		Description = "Kamizelka ratownika.",
		Icon = "VEST",
		Price = 900,
		Color = Color3.fromRGB(255, 143, 48),
	},
	{
		Id = "binoculars",
		Name = "Lifeguard Binoculars",
		Description = "Lornetka do obserwacji.",
		Icon = "VIEW",
		Price = 1250,
		Color = Color3.fromRGB(60, 67, 75),
	},
	{
		Id = "sun_cream",
		Name = "Sun Cream",
		Description = "Krem przeciwsłoneczny.",
		Icon = "SPF",
		Price = 350,
		Color = Color3.fromRGB(239, 235, 211),
	},
	{
		Id = "megaphone",
		Name = "Rescue Megaphone",
		Description = "Megafon ratownika.",
		Icon = "MEGA",
		Price = 1500,
		Color = Color3.fromRGB(240, 240, 240),
	},
}

function Config.GetXPForNextLevel(level)
	level = math.max(1, math.floor(tonumber(level) or 1))

	if level >= Config.Progression.MaxLevel then
		return 0
	end

	local raw = Config.Progression.BaseXP * (Config.Progression.Growth ^ (level - 1))
	return math.max(1, math.floor(raw + 0.5))
end

function Config.GetRankForLevel(level)
	level = math.max(1, math.floor(tonumber(level) or 1))
	local current = Config.Ranks[1]

	for _, rank in ipairs(Config.Ranks) do
		if level >= rank.MinLevel then
			current = rank
		else
			break
		end
	end

	return current
end

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
