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
	prompt.HoldDuration = 0.1
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent

	return prompt
end

function MapService.Build()
	Workspace.FallenPartsDestroyHeight = -80

	local map = Workspace:WaitForChild("GeneratedRescueMap", 10)
	if not map then
		error("[RescueSimulator] GeneratedRescueMap missing. Run UPDATE_I_START.bat and rebuild place.")
	end

	local spawn = map:FindFirstChild("StarterIslandSpawn")
	local manager = map:FindFirstChild("IslandManager")
	local managerTorso = manager and manager:FindFirstChild("Torso")
	local tower = map:FindFirstChild("LifeguardTower")
	local towerInteraction = tower and tower:FindFirstChild("TowerInteraction")

	if not spawn or not spawn:IsA("BasePart") then
		error("[RescueSimulator] StarterIslandSpawn missing.")
	end
	if not managerTorso or not managerTorso:IsA("BasePart") then
		error("[RescueSimulator] IslandManager.Torso missing.")
	end
	if not towerInteraction or not towerInteraction:IsA("BasePart") then
		error("[RescueSimulator] LifeguardTower.TowerInteraction missing.")
	end

	refs.MapModel = map
	refs.SpawnPoints.StarterIslandSpawn = spawn.CFrame + Vector3.new(0, 4, 0)
	refs.MapsPrompt = ensurePrompt(managerTorso, "MapsPrompt", "Wybierz mapę", "Manager Map")
	refs.TowerPrompt = ensurePrompt(towerInteraction, "TowerPrompt", "Ustawienia wieży", "Wieża ratownika")
	refs.TowerPlatform = tower:FindFirstChild("TowerPlatform")
	refs.TowerRoof = tower:FindFirstChild("TowerRoof")

	print("[RescueSimulator] Compact 10x10 test map ready.")

	return refs
end

function MapService.GetRefs()
	return refs
end

return MapService
