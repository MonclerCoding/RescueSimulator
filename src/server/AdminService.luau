local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local AdminService = {}

function AdminService.Init(remotes)
	remotes.AdminAddMoneyRequest.OnServerEvent:Connect(function(player, rawAmount)
		if not PlayerDataService.IsAdmin(player) then
			remotes.Notify:FireClient(player, "Brak uprawnień administratora.", "error")
			return
		end

		local amount = tonumber(rawAmount)
		if not amount then
			remotes.Notify:FireClient(player, "Wpisz prawidłową liczbę.", "error")
			return
		end

		amount = math.floor(amount)
		amount = math.clamp(amount, 1, 10000000)

		PlayerDataService.AddMoney(player, amount)
		remotes.Notify:FireClient(
			player,
			"Administrator dodał $" .. tostring(amount) .. ".",
			"success"
		)
	end)
end

return AdminService
