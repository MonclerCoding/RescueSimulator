local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local GuiFactory = require(script.Parent:WaitForChild("GuiFactory"))
local PetVisuals = require(script.Parent:WaitForChild("PetVisuals"))

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")

local OpenTower = remotesFolder:WaitForChild("OpenTower")
local OpenMaps = remotesFolder:WaitForChild("OpenMaps")
local TeleportRequest = remotesFolder:WaitForChild("TeleportRequest")
local TowerUpgradeRequest = remotesFolder:WaitForChild("TowerUpgradeRequest")
local EquipPetRequest = remotesFolder:WaitForChild("EquipPetRequest")
local BuyItemRequest = remotesFolder:WaitForChild("BuyItemRequest")
local AdminAddMoneyRequest = remotesFolder:WaitForChild("AdminAddMoneyRequest")
local Notify = remotesFolder:WaitForChild("Notify")

local leaderstats = player:WaitForChild("leaderstats")
local moneyValue = leaderstats:WaitForChild("Money")
local levelValue = leaderstats:WaitForChild("Level")
local xpValue = leaderstats:WaitForChild("XP")
local rankValue = leaderstats:WaitForChild("Rank")

local function moneyText(amount)
	amount = tonumber(amount) or 0
	if amount >= 1000000 then
		return string.format("%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("%.1fK", amount / 1000)
	end
	return tostring(math.floor(amount))
end

local screen = Instance.new("ScreenGui")
screen.Name = "RescueSimulatorUI"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = player:WaitForChild("PlayerGui")

-- TOP HUD
local hud = Instance.new("Frame")
hud.Position = UDim2.fromOffset(18, 18)
hud.Size = UDim2.fromOffset(540, 118)
hud.BackgroundColor3 = GuiFactory.Theme.Panel
hud.BorderSizePixel = 0
hud.Parent = screen
GuiFactory.Round(hud, 16)
GuiFactory.Stroke(hud, 2, 0.25)

local gameTitle = GuiFactory.MakeLabel(
	hud,
	"RESCUE SIMULATOR  •  TEST BUILD",
	UDim2.new(1, -24, 0, 25),
	UDim2.fromOffset(14, 7),
	15,
	true
)
gameTitle.TextColor3 = GuiFactory.Theme.Accent

local moneyLabel = GuiFactory.MakeLabel(
	hud,
	"",
	UDim2.fromOffset(145, 34),
	UDim2.fromOffset(14, 34),
	16,
	true
)
moneyLabel.BackgroundColor3 = Color3.fromRGB(35, 72, 55)
moneyLabel.BackgroundTransparency = 0
GuiFactory.Round(moneyLabel, 9)
GuiFactory.Padding(moneyLabel, 10, 6, 0, 0)

local levelLabel = GuiFactory.MakeLabel(
	hud,
	"",
	UDim2.fromOffset(120, 34),
	UDim2.fromOffset(168, 34),
	16,
	true
)
levelLabel.BackgroundColor3 = Color3.fromRGB(65, 57, 103)
levelLabel.BackgroundTransparency = 0
GuiFactory.Round(levelLabel, 9)
GuiFactory.Padding(levelLabel, 10, 6, 0, 0)

local rankLabel = GuiFactory.MakeLabel(
	hud,
	"",
	UDim2.fromOffset(230, 34),
	UDim2.fromOffset(297, 34),
	14,
	true
)
rankLabel.BackgroundColor3 = Color3.fromRGB(43, 73, 99)
rankLabel.BackgroundTransparency = 0
GuiFactory.Round(rankLabel, 9)
GuiFactory.Padding(rankLabel, 10, 6, 0, 0)

local xpBack = Instance.new("Frame")
xpBack.Position = UDim2.fromOffset(14, 79)
xpBack.Size = UDim2.new(1, -28, 0, 24)
xpBack.BackgroundColor3 = GuiFactory.Theme.Panel3
xpBack.BorderSizePixel = 0
xpBack.Parent = hud
GuiFactory.Round(xpBack, 8)

local xpFill = Instance.new("Frame")
xpFill.Size = UDim2.new(0, 0, 1, 0)
xpFill.BackgroundColor3 = GuiFactory.Theme.Accent2
xpFill.BorderSizePixel = 0
xpFill.Parent = xpBack
GuiFactory.Round(xpFill, 8)

local xpLabel = GuiFactory.MakeLabel(
	xpBack,
	"",
	UDim2.fromScale(1, 1),
	UDim2.fromOffset(0, 0),
	12,
	true
)
xpLabel.TextXAlignment = Enum.TextXAlignment.Center
xpLabel.ZIndex = 3

-- NAV
local nav = Instance.new("Frame")
nav.AnchorPoint = Vector2.new(0.5, 1)
nav.Position = UDim2.new(0.5, 0, 1, -18)
nav.Size = UDim2.fromOffset(880, 82)
nav.BackgroundColor3 = GuiFactory.Theme.Panel
nav.BorderSizePixel = 0
nav.Parent = screen
GuiFactory.Round(nav, 16)
GuiFactory.Stroke(nav, 2, 0.25)
GuiFactory.Padding(nav, 10, 10, 9, 9)
GuiFactory.AddListLayout(nav, 8, true)

local mapsButton = GuiFactory.MakeIconButton(nav, "MAP", "MAPS", "Teleport", GuiFactory.Theme.Accent)
local towerButton = GuiFactory.MakeIconButton(nav, "TWR", "TOWER", "Upgrade", GuiFactory.Theme.Orange)
local rankButton = GuiFactory.MakeIconButton(nav, "RANK", "RANKS", "Progress", GuiFactory.Theme.Accent2)
local petsButton = GuiFactory.MakeIconButton(nav, "PET", "PETS", "Companions", GuiFactory.Theme.Purple)
local shopButton = GuiFactory.MakeIconButton(nav, "SHOP", "SHOP", "Equipment", GuiFactory.Theme.Green)

local adminButton = GuiFactory.MakeIconButton(nav, "ADM", "ADMIN", "Tools", GuiFactory.Theme.Red)
adminButton.Visible = player:GetAttribute("IsAdmin") == true

local panels = {}
local dims = {}

local function closeAll()
	for _, panel in pairs(panels) do
		panel.Visible = false
	end
	for _, dim in pairs(dims) do
		dim.Visible = false
	end
end

local function openPanel(name)
	closeAll()
	if panels[name] then
		panels[name].Visible = true
	end
	if dims[name] then
		dims[name].Visible = true
	end
end

-- MAPS
local mapsPanel, mapsContent, _, _, mapsDim = GuiFactory.MakePanel(screen, "MAPS / TELEPORT", 620, 500)
panels.Maps = mapsPanel
dims.Maps = mapsDim
GuiFactory.AddListLayout(mapsContent, 10)

for _, map in ipairs(Config.Maps) do
	local card = GuiFactory.MakeCard(mapsContent, 90)

	local title = GuiFactory.MakeLabel(card, map.Name, UDim2.new(1, -180, 0, 28), UDim2.fromOffset(14, 10), 16, true)
	local desc = GuiFactory.MakeLabel(card, map.Description, UDim2.new(1, -180, 0, 40), UDim2.fromOffset(14, 39), 11, false)
	desc.TextWrapped = true
	desc.TextYAlignment = Enum.TextYAlignment.Top
	desc.TextColor3 = GuiFactory.Theme.MutedText

	local button = GuiFactory.MakeButton(card, "TELEPORT", UDim2.fromOffset(135, 46), GuiFactory.Theme.Accent)
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -14, 0.5, 0)

	if not map.Available then
		button.Text = "LOCKED"
		button.BackgroundColor3 = GuiFactory.Theme.Panel3
		button.Active = false
	end

	button.MouseButton1Click:Connect(function()
		if map.Available then
			TeleportRequest:FireServer(map.Id)
			closeAll()
		end
	end)
end

-- TOWER
local towerPanel, towerContent, _, _, towerDim = GuiFactory.MakePanel(screen, "TOWER SYSTEM", 560, 390)
panels.Tower = towerPanel
dims.Tower = towerDim
GuiFactory.AddListLayout(towerContent, 12)

local towerLevel = GuiFactory.MakeCard(towerContent, 82)
local towerLevelText = GuiFactory.MakeLabel(towerLevel, "", UDim2.new(1, -24, 1, 0), UDim2.fromOffset(14, 0), 18, true)

local towerUpgrade = GuiFactory.MakeButton(towerContent, "UPGRADE TOWER", UDim2.new(1, -4, 0, 58), GuiFactory.Theme.Green)

-- RANKS / LEVEL
local ranksPanel, ranksContent, _, _, ranksDim = GuiFactory.MakePanel(screen, "LEVEL & RANK SYSTEM", 620, 540)
panels.Ranks = ranksPanel
dims.Ranks = ranksDim

local progressCard = GuiFactory.MakeCard(ranksContent, 105)
local progressTitle = GuiFactory.MakeLabel(progressCard, "", UDim2.new(1, -24, 0, 34), UDim2.fromOffset(14, 10), 19, true)
local progressInfo = GuiFactory.MakeLabel(progressCard, "", UDim2.new(1, -24, 0, 42), UDim2.fromOffset(14, 48), 13, false)
progressInfo.TextColor3 = GuiFactory.Theme.MutedText

local rankScroll = Instance.new("ScrollingFrame")
rankScroll.Position = UDim2.fromOffset(0, 118)
rankScroll.Size = UDim2.new(1, 0, 1, -118)
rankScroll.BackgroundTransparency = 1
rankScroll.BorderSizePixel = 0
rankScroll.ScrollBarThickness = 6
rankScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
rankScroll.CanvasSize = UDim2.new()
rankScroll.Parent = ranksContent
GuiFactory.AddListLayout(rankScroll, 8)

for _, rank in ipairs(Config.Ranks) do
	local card = GuiFactory.MakeCard(rankScroll, 60)
	local name = GuiFactory.MakeLabel(card, rank.Name, UDim2.new(0.65, 0, 1, 0), UDim2.fromOffset(14, 0), 15, true)
	local req = GuiFactory.MakeLabel(card, "LEVEL " .. tostring(rank.MinLevel), UDim2.new(0.3, -14, 1, 0), UDim2.new(0.7, 0, 0, 0), 12, true)
	req.TextXAlignment = Enum.TextXAlignment.Right
	req.TextColor3 = GuiFactory.Theme.Accent2
end

-- PETS
local petsPanel, petsContent, _, _, petsDim = GuiFactory.MakePanel(screen, "PETS", 580, 470)
panels.Pets = petsPanel
dims.Pets = petsDim
GuiFactory.AddListLayout(petsContent, 10)

local petButtons = {}
for _, pet in ipairs(Config.Pets) do
	local card = GuiFactory.MakeCard(petsContent, 78)
	local title = GuiFactory.MakeLabel(card, pet.Name .. "  •  " .. pet.Rarity, UDim2.new(1, -170, 1, 0), UDim2.fromOffset(14, 0), 15, true)
	local button = GuiFactory.MakeButton(card, "EQUIP", UDim2.fromOffset(130, 44), pet.Color)
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -14, 0.5, 0)
	button.MouseButton1Click:Connect(function()
		EquipPetRequest:FireServer(pet.Id)
	end)
	petButtons[pet.Id] = button
end

-- SHOP
local shopPanel, shopContent, _, _, shopDim = GuiFactory.MakePanel(screen, "RESCUE SHOP", 620, 520)
panels.Shop = shopPanel
dims.Shop = shopDim

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.fromScale(1, 1)
shopScroll.BackgroundTransparency = 1
shopScroll.BorderSizePixel = 0
shopScroll.ScrollBarThickness = 6
shopScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
shopScroll.CanvasSize = UDim2.new()
shopScroll.Parent = shopContent
GuiFactory.AddListLayout(shopScroll, 8)

local shopButtons = {}
for _, item in ipairs(Config.ShopItems) do
	local card = GuiFactory.MakeCard(shopScroll, 76)
	local title = GuiFactory.MakeLabel(card, item.Name, UDim2.new(1, -180, 0, 28), UDim2.fromOffset(14, 9), 15, true)
	local desc = GuiFactory.MakeLabel(card, item.Description, UDim2.new(1, -180, 0, 27), UDim2.fromOffset(14, 38), 11, false)
	desc.TextColor3 = GuiFactory.Theme.MutedText

	local button = GuiFactory.MakeButton(card, "$" .. tostring(item.Price), UDim2.fromOffset(130, 44), GuiFactory.Theme.Green)
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -14, 0.5, 0)
	button.MouseButton1Click:Connect(function()
		BuyItemRequest:FireServer(item.Id)
	end)
	shopButtons[item.Id] = button
end

-- ADMIN
local adminPanel, adminContent, _, _, adminDim = GuiFactory.MakePanel(screen, "ADMIN", 520, 330)
panels.Admin = adminPanel
dims.Admin = adminDim
GuiFactory.AddListLayout(adminContent, 12)

local adminInfo = GuiFactory.MakeLabel(
	adminContent,
	"Test panel. Na razie: dodawanie pieniędzy. Level/XP i rangi mają gotową bazę pod kolejne narzędzia.",
	UDim2.new(1, -4, 0, 70),
	UDim2.fromOffset(0, 0),
	13,
	false
)
adminInfo.TextWrapped = true
adminInfo.TextColor3 = GuiFactory.Theme.MutedText

local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -4, 0, 50)
amountBox.BackgroundColor3 = GuiFactory.Theme.Panel2
amountBox.BorderSizePixel = 0
amountBox.PlaceholderText = "Money amount"
amountBox.Text = ""
amountBox.TextColor3 = GuiFactory.Theme.Text
amountBox.PlaceholderColor3 = GuiFactory.Theme.MutedText
amountBox.TextSize = 15
amountBox.Font = Enum.Font.Gotham
amountBox.Parent = adminContent
GuiFactory.Round(amountBox, 10)

local addMoney = GuiFactory.MakeButton(adminContent, "ADD MONEY", UDim2.new(1, -4, 0, 52), GuiFactory.Theme.Green)

-- TOAST
local toast = Instance.new("TextLabel")
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, -70)
toast.Size = UDim2.fromOffset(420, 48)
toast.BackgroundColor3 = GuiFactory.Theme.Panel2
toast.BorderSizePixel = 0
toast.TextColor3 = GuiFactory.Theme.Text
toast.Font = Enum.Font.GothamBold
toast.TextSize = 13
toast.TextWrapped = true
toast.ZIndex = 100
toast.Parent = screen
GuiFactory.Round(toast, 11)

local toastId = 0
local function showToast(message, kind)
	toastId += 1
	local id = toastId

	if kind == "success" then
		toast.BackgroundColor3 = Color3.fromRGB(39, 118, 79)
	elseif kind == "error" then
		toast.BackgroundColor3 = Color3.fromRGB(139, 55, 59)
	elseif kind == "warning" then
		toast.BackgroundColor3 = Color3.fromRGB(145, 101, 43)
	else
		toast.BackgroundColor3 = GuiFactory.Theme.Panel2
	end

	toast.Text = tostring(message)
	TweenService:Create(toast, TweenInfo.new(0.18), { Position = UDim2.new(0.5, 0, 0, 18) }):Play()

	task.delay(2.5, function()
		if id == toastId then
			TweenService:Create(toast, TweenInfo.new(0.18), { Position = UDim2.new(0.5, 0, 0, -70) }):Play()
		end
	end)
end

local function updateHUD()
	local level = levelValue.Value
	local xp = xpValue.Value
	local rank = rankValue.Value
	local needed = Config.GetXPForNextLevel(level)

	moneyLabel.Text = "$  " .. moneyText(moneyValue.Value)
	levelLabel.Text = "LEVEL  " .. tostring(level)
	rankLabel.Text = "RANK  " .. rank

	if needed <= 0 then
		xpLabel.Text = "MAX LEVEL"
		xpFill.Size = UDim2.fromScale(1, 1)
	else
		local progress = math.clamp(xp / needed, 0, 1)
		xpLabel.Text = tostring(xp) .. " / " .. tostring(needed) .. " XP"
		xpFill.Size = UDim2.new(progress, 0, 1, 0)
	end

	progressTitle.Text = "Level " .. tostring(level) .. "  •  " .. rank
	progressInfo.Text = needed > 0
		and ("XP: " .. tostring(xp) .. " / " .. tostring(needed) .. "  •  kolejna ranga wg progów poniżej")
		or "Osiągnięto maksymalny poziom."
end

local function updateTower()
	local level = player:GetAttribute("TowerLevel") or 1
	local raw = Config.Tower.BaseUpgradeCost * (Config.Tower.CostMultiplier ^ (level - 1))
	local cost = math.floor(raw / 10 + 0.5) * 10

	towerLevelText.Text = "Tower Level: " .. tostring(level) .. " / " .. tostring(Config.Tower.MaxLevel)

	if level >= Config.Tower.MaxLevel then
		towerUpgrade.Text = "MAX LEVEL"
		towerUpgrade.Active = false
		towerUpgrade.BackgroundColor3 = GuiFactory.Theme.Panel3
	else
		towerUpgrade.Text = "UPGRADE  •  $" .. tostring(cost)
		towerUpgrade.Active = true
		towerUpgrade.BackgroundColor3 = GuiFactory.Theme.Green
	end
end

local function updatePets()
	local equipped = player:GetAttribute("EquippedPet") or ""
	for _, pet in ipairs(Config.Pets) do
		local button = petButtons[pet.Id]
		if button then
			if equipped == pet.Id then
				button.Text = "EQUIPPED"
				button.BackgroundColor3 = GuiFactory.Theme.Green
			else
				button.Text = "EQUIP"
				button.BackgroundColor3 = pet.Color
			end
		end
	end
	PetVisuals.SetPet(equipped)
end

local function updateShop()
	for _, item in ipairs(Config.ShopItems) do
		local button = shopButtons[item.Id]
		if button then
			if player:GetAttribute("Owned_" .. item.Id) == true then
				button.Text = "OWNED"
				button.BackgroundColor3 = GuiFactory.Theme.Panel3
			else
				button.Text = "$" .. tostring(item.Price)
				button.BackgroundColor3 = GuiFactory.Theme.Green
			end
		end
	end
end

mapsButton.MouseButton1Click:Connect(function() openPanel("Maps") end)
towerButton.MouseButton1Click:Connect(function() openPanel("Tower") end)
rankButton.MouseButton1Click:Connect(function() openPanel("Ranks") end)
petsButton.MouseButton1Click:Connect(function() openPanel("Pets") end)
shopButton.MouseButton1Click:Connect(function() openPanel("Shop") end)
adminButton.MouseButton1Click:Connect(function()
	if player:GetAttribute("IsAdmin") == true then
		openPanel("Admin")
	end
end)

towerUpgrade.MouseButton1Click:Connect(function()
	if towerUpgrade.Active then
		TowerUpgradeRequest:FireServer()
	end
end)

addMoney.MouseButton1Click:Connect(function()
	if amountBox.Text ~= "" then
		AdminAddMoneyRequest:FireServer(amountBox.Text)
		amountBox.Text = ""
	end
end)

OpenTower.OnClientEvent:Connect(function() openPanel("Tower") end)
OpenMaps.OnClientEvent:Connect(function() openPanel("Maps") end)
Notify.OnClientEvent:Connect(showToast)

moneyValue:GetPropertyChangedSignal("Value"):Connect(updateHUD)
levelValue:GetPropertyChangedSignal("Value"):Connect(updateHUD)
xpValue:GetPropertyChangedSignal("Value"):Connect(updateHUD)
rankValue:GetPropertyChangedSignal("Value"):Connect(updateHUD)

player:GetAttributeChangedSignal("TowerLevel"):Connect(updateTower)
player:GetAttributeChangedSignal("EquippedPet"):Connect(updatePets)
player:GetAttributeChangedSignal("IsAdmin"):Connect(function()
	adminButton.Visible = player:GetAttribute("IsAdmin") == true
end)

for _, item in ipairs(Config.ShopItems) do
	player:GetAttributeChangedSignal("Owned_" .. item.Id):Connect(updateShop)
end

updateHUD()
updateTower()
updatePets()
updateShop()
showToast("Rescue Simulator v0.3 • Level + Rank systems ready", "success")
