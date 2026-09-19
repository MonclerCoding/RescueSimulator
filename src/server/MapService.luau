local Workspace = game:GetService("Workspace")

local MapService = {}

local refs = {
	SpawnPoints = {},
}

local function ensurePrompt(parent, name, actionText, objectText)
	local prompt = parent:FindFirstChild(name)

	if prompt and prompt:IsA("ProximityPrompt") then
		return prompt
	end

	if prompt then
		prompt:Destroy()
	end

	prompt = Instance.new("ProximityPrompt")
	prompt.Name = name
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0.15
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent

	return prompt
end

function MapService.Build()
	Workspace.FallenPartsDestroyHeight = -80

	local map = Workspace:WaitForChild("GeneratedRescueMap", 10)
	if not map then
		error("[RescueSimulator] GeneratedRescueMap is missing. Rojo project was not synchronized correctly.")
	end

	local spawn = map:FindFirstChild("StarterIslandSpawn")
	if not spawn or not spawn:IsA("BasePart") then
		error("[RescueSimulator] StarterIslandSpawn is missing.")
	end

	local manager = map:FindFirstChild("IslandManager")
	local managerTorso = manager and manager:FindFirstChild("Torso")
	if not managerTorso or not managerTorso:IsA("BasePart") then
		error("[RescueSimulator] IslandManager.Torso is missing.")
	end

	local tower = map:FindFirstChild("LifeguardTower")
	local towerInteraction = tower and tower:FindFirstChild("TowerInteraction")
	if not towerInteraction or not towerInteraction:IsA("BasePart") then
		error("[RescueSimulator] LifeguardTower.TowerInteraction is missing.")
	end

	refs.MapModel = map
	refs.SpawnPoints.StarterIslandSpawn = spawn.CFrame + Vector3.new(0, 5, 0)

	refs.MapsPrompt = ensurePrompt(
		managerTorso,
		"MapsPrompt",
		"Wybierz wyspę",
		"Manager Wysp"
	)

	refs.TowerPrompt = ensurePrompt(
		towerInteraction,
		"TowerPrompt",
		"Ustawienia wieży",
		"Twoja wieża ratownika"
	)

	refs.TowerPlatform = tower:FindFirstChild("TowerPlatform")
	refs.TowerRoof = tower:FindFirstChild("TowerRoof")

	print("[RescueSimulator] STATIC WORLD READY:", map:GetFullName())

	return refs
end

function MapService.GetRefs()
	return refs
end

return MapService
