local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local ShopService = {}

local function toolExists(container, itemId)
	if not container then
		return false
	end

	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Tool") and child:GetAttribute("ShopItemId") == itemId then
			return true
		end
	end

	return false
end

local function makeTool(item)
	local tool = Instance.new("Tool")
	tool.Name = item.Name
	tool.ToolTip = item.Description
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("ShopItemId", item.Id)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1.1, 1.1, 2.4)
	handle.Color = item.Color
	handle.Material = Enum.Material.SmoothPlastic
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	if item.Id == "rescue_buoy" then
		handle.Shape = Enum.PartType.Cylinder
		handle.Size = Vector3.new(0.55, 2.4, 2.4)
		handle.Orientation = Vector3.new(0, 0, 90)
	elseif item.Id == "megaphone" then
		handle.Size = Vector3.new(1.6, 1.6, 2.4)
	elseif item.Id == "binoculars" then
		handle.Size = Vector3.new(1.8, 1.2, 1.2)
	elseif item.Id == "sun_cream" then
		handle.Size = Vector3.new(0.8, 1.8, 0.8)
	elseif item.Id == "rescue_vest" then
		handle.Size = Vector3.new(1.8, 2.2, 0.7)
	end

	return tool
end

function ShopService.GiveTool(player, item)
	local backpack = player:FindFirstChildOfClass("Backpack")
	local starterGear = player:FindFirstChild("StarterGear")

	if backpack and not toolExists(backpack, item.Id) then
		makeTool(item).Parent = backpack
	end

	if starterGear and not toolExists(starterGear, item.Id) then
		makeTool(item).Parent = starterGear
	end
end

function ShopService.Init(remotes)
	remotes.BuyItemRequest.OnServerEvent:Connect(function(player, itemId)
		if typeof(itemId) ~= "string" then
			return
		end

		local item = Config.GetShopItem(itemId)
		if not item then
			return
		end

		if PlayerDataService.OwnsItem(player, itemId) then
			ShopService.GiveTool(player, item)
			remotes.Notify:FireClient(player, "Ten przedmiot już posiadasz.", "info")
			return
		end

		if not PlayerDataService.TrySpendMoney(player, item.Price) then
			remotes.Notify:FireClient(
				player,
				"Za mało pieniędzy. Potrzebujesz $" .. tostring(item.Price) .. ".",
				"error"
			)
			return
		end

		PlayerDataService.MarkItemOwned(player, itemId)
		ShopService.GiveTool(player, item)

		remotes.Notify:FireClient(player, "Kupiono: " .. item.Name, "success")
	end)
end

return ShopService
