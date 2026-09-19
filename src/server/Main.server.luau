local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local MapService = require(script.Parent:WaitForChild("MapService"))
local TowerService = require(script.Parent:WaitForChild("TowerService"))
local PetService = require(script.Parent:WaitForChild("PetService"))
local ShopService = require(script.Parent:WaitForChild("ShopService"))
local AdminService = require(script.Parent:WaitForChild("AdminService"))

local function getOrCreateRemote(folder, className, name)
	local existing = folder:FindFirstChild(name)

	if existing and existing.ClassName ~= className then
		existing:Destroy()
		existing = nil
	end

	if existing then
		return existing
	end

	local remote = Instance.new(className)
	remote.Name = name
	remote.Parent = folder
	return remote
end

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

local remotes = {
	OpenTower = getOrCreateRemote(remotesFolder, "RemoteEvent", "OpenTower"),
	OpenMaps = getOrCreateRemote(remotesFolder, "RemoteEvent", "OpenMaps"),
	TeleportRequest = getOrCreateRemote(remotesFolder, "RemoteEvent", "TeleportRequest"),
	TowerUpgradeRequest = getOrCreateRemote(remotesFolder, "RemoteEvent", "TowerUpgradeRequest"),
	EquipPetRequest = getOrCreateRemote(remotesFolder, "RemoteEvent", "EquipPetRequest"),
	BuyItemRequest = getOrCreateRemote(remotesFolder, "RemoteEvent", "BuyItemRequest"),
	AdminAddMoneyRequest = getOrCreateRemote(remotesFolder, "RemoteEvent", "AdminAddMoneyRequest"),
	Notify = getOrCreateRemote(remotesFolder, "RemoteEvent", "Notify"),
}

local refs = MapService.Build()

TowerService.Init(remotes, refs)
PetService.Init(remotes)
ShopService.Init(remotes)
AdminService.Init(remotes)

local function moveCharacterToStarter(character)
	local target = refs.SpawnPoints.StarterIslandSpawn
	if not target then
		return
	end

	task.wait(0.15)

	if character and character.Parent then
		character:PivotTo(target)
	end
end

local function setupPlayer(player)
	PlayerDataService.CreateProfile(player)

	player.CharacterAdded:Connect(function(character)
		moveCharacterToStarter(character)
	end)

	if player.Character then
		task.defer(moveCharacterToStarter, player.Character)
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(setupPlayer, player)
end

Players.PlayerAdded:Connect(setupPlayer)

if refs.MapsPrompt then
	refs.MapsPrompt.Triggered:Connect(function(player)
		remotes.OpenMaps:FireClient(player)
	end)
end

remotes.TeleportRequest.OnServerEvent:Connect(function(player, mapId)
	if typeof(mapId) ~= "string" then
		return
	end

	local map = Config.GetMap(mapId)
	if not map then
		return
	end

	local level = PlayerDataService.GetLevel(player)

	if not map.Available then
		remotes.Notify:FireClient(player, map.Name .. " jest jeszcze zablokowana.", "warning")
		return
	end

	if level < map.RequiredLevel then
		remotes.Notify:FireClient(
			player,
			"Ta wyspa wymaga poziomu " .. tostring(map.RequiredLevel) .. ".",
			"warning"
		)
		return
	end

	local destination = refs.SpawnPoints[map.SpawnName]
	if not destination then
		remotes.Notify:FireClient(player, "Punkt teleportacji nie jest jeszcze gotowy.", "error")
		return
	end

	local character = player.Character
	if not character then
		return
	end

	character:PivotTo(destination)
	remotes.Notify:FireClient(player, "Teleport: " .. map.Name, "success")
end)

print("==================================================")
print(Config.GameName .. " " .. Config.Version .. " uruchomiony.")
print("Mapa, wieża, NPC, pety, sklep, teleport i admin gotowe.")
print("==================================================")
