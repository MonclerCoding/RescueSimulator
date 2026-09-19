local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local TowerService = {}

local lastRequest = {}

function TowerService.GetUpgradeCost(currentLevel)
	currentLevel = math.max(1, tonumber(currentLevel) or 1)

	local raw = Config.Tower.BaseUpgradeCost * (Config.Tower.CostMultiplier ^ (currentLevel - 1))
	return math.floor(raw / 10 + 0.5) * 10
end

function TowerService.Init(remotes, refs)
	if refs.TowerPrompt then
		refs.TowerPrompt.Triggered:Connect(function(player)
			remotes.OpenTower:FireClient(player)
		end)
	end

	remotes.TowerUpgradeRequest.OnServerEvent:Connect(function(player)
		local now = os.clock()
		if lastRequest[player] and now - lastRequest[player] < 0.35 then
			return
		end
		lastRequest[player] = now

		local currentLevel = PlayerDataService.GetTowerLevel(player)

		if currentLevel >= Config.Tower.MaxLevel then
			remotes.Notify:FireClient(player, "Wieża ma już maksymalny poziom.", "warning")
			return
		end

		local cost = TowerService.GetUpgradeCost(currentLevel)

		if not PlayerDataService.TrySpendMoney(player, cost) then
			remotes.Notify:FireClient(
				player,
				"Potrzebujesz $" .. tostring(cost) .. " na ulepszenie wieży.",
				"error"
			)
			return
		end

		PlayerDataService.SetTowerLevel(player, currentLevel + 1)

		remotes.Notify:FireClient(
			player,
			"Wieża ulepszona do poziomu " .. tostring(currentLevel + 1) .. "!",
			"success"
		)
	end)
end

return TowerService
