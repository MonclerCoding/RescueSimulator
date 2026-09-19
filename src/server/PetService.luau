local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local PetService = {}

function PetService.Init(remotes)
	remotes.EquipPetRequest.OnServerEvent:Connect(function(player, petId)
		if typeof(petId) ~= "string" then
			return
		end

		local current = PlayerDataService.GetEquippedPet(player)

		if current == petId then
			PlayerDataService.SetEquippedPet(player, "")
			remotes.Notify:FireClient(player, "Pet został zdjęty.", "info")
			return
		end

		local pet = Config.GetPet(petId)
		if not pet then
			return
		end

		PlayerDataService.SetEquippedPet(player, pet.Id)
		remotes.Notify:FireClient(player, "Wyposażono: " .. pet.Name, "success")
	end)
end

return PetService
