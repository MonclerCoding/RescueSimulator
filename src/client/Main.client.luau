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

local function formatMoney(amount)
	amount = tonumber(amount) or 0

	if amount >= 1000000000 then
		return string.format("%.1fB", amount / 1000000000)
	elseif amount >= 1000000 then
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

-- =========================================================
-- TOP HUD
-- =========================================================

local hud = Instance.new("Frame")
hud.Position = UDim2.fromOffset(18, 18)
hud.Size = UDim2.fromOffset(420, 92)
hud.BackgroundColor3 = GuiFactory.Theme.Panel
hud.BorderSizePixel = 0
hud.Parent = screen
GuiFactory.Round(hud, 15)
GuiFactory.Stroke(hud, 2, 0.28, GuiFactory.Theme.DarkStroke)

local badge = Instance.new("Frame")
badge.Size = UDim2.fromOffset(64, 64)
badge.Position = UDim2.fromOffset(13, 14)
badge.BackgroundColor3 = GuiFactory.Theme.Accent
badge.BorderSizePixel = 0
badge.Parent = hud
GuiFactory.Round(badge, 15)

local badgeIcon = GuiFactory.MakeLabel(
	badge,
	"🛟",
	UDim2.fromScale(1, 1),
	UDim2.fromOffset(0, 0),
	30,
	true
)
badgeIcon.TextXAlignment = Enum.TextXAlignment.Center

local title = GuiFactory.MakeLabel(
	hud,
	"RESCUE SIMULATOR",
	UDim2.fromOffset(190, 25),
	UDim2.fromOffset(91, 12),
	16,
	true
)
title.TextColor3 = GuiFactory.Theme.Accent

local subtitle = GuiFactory.MakeLabel(
	hud,
	"TEST BUILD • STARTER ISLAND",
	UDim2.fromOffset(220, 22),
	UDim2.fromOffset(91, 35),
	11,
	false
)
subtitle.TextColor3 = GuiFactory.Theme.MutedText

local moneyChip = Instance.new("Frame")
moneyChip.Size = UDim2.fromOffset(125, 34)
moneyChip.Position = UDim2.fromOffset(91, 55)
moneyChip.BackgroundColor3 = Color3.fromRGB(36, 69, 54)
moneyChip.BorderSizePixel = 0
moneyChip.Parent = hud
GuiFactory.Round(moneyChip, 10)

local moneyLabel = GuiFactory.MakeLabel(
	moneyChip,
	"💰 $" .. formatMoney(moneyValue.Value),
	UDim2.fromScale(1, 1),
	UDim2.fromOffset(10, 0),
	15,
	true
)

local levelChip = Instance.new("Frame")
levelChip.Size = UDim2.fromOffset(112, 34)
levelChip.Position = UDim2.fromOffset(224, 55)
levelChip.BackgroundColor3 = Color3.fromRGB(68, 58, 105)
levelChip.BorderSizePixel = 0
levelChip.Parent = hud
GuiFactory.Round(levelChip, 10)

local levelLabel = GuiFactory.MakeLabel(
	levelChip,
	"⭐ LVL " .. tostring(levelValue.Value),
	UDim2.fromScale(1, 1),
	UDim2.fromOffset(10, 0),
	15,
	true
)

local adminMini = Instance.new("TextLabel")
adminMini.Size = UDim2.fromOffset(72, 26)
adminMini.Position = UDim2.new(1, -84, 0, 14)
adminMini.BackgroundColor3 = GuiFactory.Theme.Red
adminMini.Text = "ADMIN"
adminMini.TextColor3 = GuiFactory.Theme.Text
adminMini.TextSize = 11
adminMini.Font = Enum.Font.GothamBold
adminMini.Visible = player:GetAttribute("IsAdmin") == true
adminMini.Parent = hud
GuiFactory.Round(adminMini, 8)

-- =========================================================
-- QUICK TELEPORT (TOP RIGHT)
-- =========================================================

local quick = Instance.new("Frame")
quick.AnchorPoint = Vector2.new(1, 0)
quick.Position = UDim2.new(1, -18, 0, 18)
quick.Size = UDim2.fromOffset(245, 92)
quick.BackgroundColor3 = GuiFactory.Theme.Panel
quick.BorderSizePixel = 0
quick.Parent = screen
GuiFactory.Round(quick, 15)
GuiFactory.Stroke(quick, 2, 0.28, GuiFactory.Theme.DarkStroke)

local quickTitle = GuiFactory.MakeLabel(
	quick,
	"QUICK TELEPORT",
	UDim2.new(1, -24, 0, 24),
	UDim2.fromOffset(12, 8),
	13,
	true
)
quickTitle.TextColor3 = GuiFactory.Theme.Accent2

local quickButton = GuiFactory.MakeButton(
	quick,
	"🏝  STARTER ISLAND",
	UDim2.new(1, -24, 0, 44),
	GuiFactory.Theme.Accent
)
quickButton.Position = UDim2.fromOffset(12, 38)

-- =========================================================
-- BOTTOM NAVIGATION
-- =========================================================

local nav = Instance.new("Frame")
nav.AnchorPoint = Vector2.new(0.5, 1)
nav.Position = UDim2.new(0.5, 0, 1, -20)
nav.Size = UDim2.fromOffset(830, 84)
nav.BackgroundColor3 = GuiFactory.Theme.Panel
nav.BorderSizePixel = 0
nav.Parent = screen
GuiFactory.Round(nav, 17)
GuiFactory.Stroke(nav, 2, 0.22, GuiFactory.Theme.DarkStroke)
GuiFactory.Padding(nav, 12, 12, 10, 10)

local navLayout = GuiFactory.AddListLayout(nav, 10, true)

local mapsButton = GuiFactory.MakeIconButton(nav, "🗺", "MAPS", "Teleporty", GuiFactory.Theme.Accent)
local towerButton = GuiFactory.MakeIconButton(nav, "🏖", "TOWER", "Ulepszenia", GuiFactory.Theme.Orange)
local petsButton = GuiFactory.MakeIconButton(nav, "🐾", "PETS", "Towarzysze", GuiFactory.Theme.Purple)
local shopButton = GuiFactory.MakeIconButton(nav, "🛟", "SHOP", "Ekwipunek", GuiFactory.Theme.Green)
local adminButton = GuiFactory.MakeIconButton(nav, "⚙", "ADMIN", "Narzędzia", GuiFactory.Theme.Red)
adminButton.Visible = player:GetAttribute("IsAdmin") == true

-- =========================================================
-- STATUS HINT
-- =========================================================

local statusHint = Instance.new("Frame")
statusHint.AnchorPoint = Vector2.new(0.5, 1)
statusHint.Position = UDim2.new(0.5, 0, 1, -114)
statusHint.Size = UDim2.fromOffset(500, 34)
statusHint.BackgroundColor3 = GuiFactory.Theme.Panel2
statusHint.BackgroundTransparency = 0.08
statusHint.BorderSizePixel = 0
statusHint.Parent = screen
GuiFactory.Round(statusHint, 10)

local statusText = GuiFactory.MakeLabel(
	statusHint,
	"💡 Podejdź do NPC lub wieży, albo użyj przycisków na dole.",
	UDim2.fromScale(1, 1),
	UDim2.fromOffset(0, 0),
	12,
	false
)
statusText.TextXAlignment = Enum.TextXAlignment.Center
statusText.TextColor3 = GuiFactory.Theme.MutedText

-- =========================================================
-- PANEL HELPERS
-- =========================================================

local panels = {}
local dims = {}

local function closeAllPanels()
	for _, panel in pairs(panels) do
		panel.Visible = false
	end
	for _, dim in pairs(dims) do
		dim.Visible = false
	end
end

local function openPanel(name)
	closeAllPanels()

	local panel = panels[name]
	local dim = dims[name]

	if panel then
		panel.Visible = true
	end
	if dim then
		dim.Visible = true
	end
end

-- =========================================================
-- TOWER PANEL
-- =========================================================

local towerPanel, towerContent, _, _, towerDim = GuiFactory.MakePanel(
	screen,
	"🏖  TWOJA WIEŻA RATOWNIKA",
	620,
	530
)
panels.Tower = towerPanel
dims.Tower = towerDim
GuiFactory.AddListLayout(towerContent, 12)

local towerHero = GuiFactory.MakeCard(towerContent, 118)
towerHero.BackgroundColor3 = Color3.fromRGB(39, 50, 62)

local towerHeroTitle = GuiFactory.MakeLabel(
	towerHero,
	"RESCUE TOWER",
	UDim2.new(1, -28, 0, 34),
	UDim2.fromOffset(16, 12),
	22,
	true
)
towerHeroTitle.TextColor3 = GuiFactory.Theme.Orange

local towerHeroText = GuiFactory.MakeLabel(
	towerHero,
	"Wieża jest Twoją główną bazą. W kolejnych wersjach poziom będzie odblokowywał lepszy sprzęt, bonusy i nowe akcje ratunkowe.",
	UDim2.new(1, -32, 0, 56),
	UDim2.fromOffset(16, 50),
	13,
	false
)
towerHeroText.TextWrapped = true
towerHeroText.TextYAlignment = Enum.TextYAlignment.Top
towerHeroText.TextColor3 = GuiFactory.Theme.MutedText

local towerLevelCard = GuiFactory.MakeCard(towerContent, 82)

local towerLevelText = GuiFactory.MakeLabel(
	towerLevelCard,
	"Poziom wieży: 1",
	UDim2.new(0.58, 0, 1, 0),
	UDim2.fromOffset(16, 0),
	20,
	true
)

local towerCostText = GuiFactory.MakeLabel(
	towerLevelCard,
	"Koszt: $500",
	UDim2.new(0.36, -16, 1, 0),
	UDim2.new(0.64, 0, 0, 0),
	15,
	true
)
towerCostText.TextXAlignment = Enum.TextXAlignment.Right
towerCostText.TextColor3 = GuiFactory.Theme.Green

local towerUpgradeButton = GuiFactory.MakeButton(
	towerContent,
	"⬆  ULEPSZ WIEŻĘ",
	UDim2.new(1, -4, 0, 58),
	GuiFactory.Theme.Green
)

local towerFeatures = GuiFactory.MakeCard(towerContent, 148)
local featuresTitle = GuiFactory.MakeLabel(
	towerFeatures,
	"Planowane funkcje wieży",
	UDim2.new(1, -24, 0, 28),
	UDim2.fromOffset(14, 9),
	15,
	true
)

local featuresText = GuiFactory.MakeLabel(
	towerFeatures,
	"• większy zasięg patroli\n• bonus do pieniędzy\n• odblokowanie lepszego ekwipunku\n• szybsza reakcja na zgłoszenia\n• kosmetyczne ulepszenia wieży",
	UDim2.new(1, -24, 0, 100),
	UDim2.fromOffset(14, 39),
	13,
	false
)
featuresText.TextYAlignment = Enum.TextYAlignment.Top
featuresText.TextColor3 = GuiFactory.Theme.MutedText

-- =========================================================
-- MAPS PANEL
-- =========================================================

local mapsPanel, mapsContent, _, _, mapsDim = GuiFactory.MakePanel(
	screen,
	"🗺  MAPS / WYSPY",
	650,
	540
)
panels.Maps = mapsPanel
dims.Maps = mapsDim

local mapsHeader = GuiFactory.MakeCard(mapsContent, 72)
local mapsHeaderTitle = GuiFactory.MakeLabel(
	mapsHeader,
	"Wybierz wyspę",
	UDim2.new(1, -24, 0, 26),
	UDim2.fromOffset(14, 8),
	16,
	true
)
local mapsHeaderText = GuiFactory.MakeLabel(
	mapsHeader,
	"Dostępne mapy zależą od poziomu gracza i etapu rozwoju gry.",
	UDim2.new(1, -24, 0, 28),
	UDim2.fromOffset(14, 35),
	12,
	false
)
mapsHeaderText.TextColor3 = GuiFactory.Theme.MutedText

local mapsScroll = Instance.new("ScrollingFrame")
mapsScroll.Position = UDim2.fromOffset(0, 84)
mapsScroll.Size = UDim2.new(1, 0, 1, -84)
mapsScroll.BackgroundTransparency = 1
mapsScroll.BorderSizePixel = 0
mapsScroll.ScrollBarThickness = 6
mapsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
mapsScroll.CanvasSize = UDim2.new()
mapsScroll.Parent = mapsContent
GuiFactory.AddListLayout(mapsScroll, 10)

local mapButtons = {}

for index, map in ipairs(Config.Maps) do
	local card = GuiFactory.MakeCard(mapsScroll, 108)
	card.LayoutOrder = index

	local numberBadge = Instance.new("Frame")
	numberBadge.Size = UDim2.fromOffset(52, 52)
	numberBadge.Position = UDim2.fromOffset(12, 27)
	numberBadge.BackgroundColor3 = map.Available and GuiFactory.Theme.Accent or GuiFactory.Theme.Panel3
	numberBadge.BorderSizePixel = 0
	numberBadge.Parent = card
	GuiFactory.Round(numberBadge, 12)

	local numberLabel = GuiFactory.MakeLabel(
		numberBadge,
		tostring(index),
		UDim2.fromScale(1, 1),
		UDim2.fromOffset(0, 0),
		22,
		true
	)
	numberLabel.TextXAlignment = Enum.TextXAlignment.Center

	local name = GuiFactory.MakeLabel(
		card,
		map.Name,
		UDim2.new(1, -240, 0, 28),
		UDim2.fromOffset(78, 13),
		17,
		true
	)

	local levelReq = GuiFactory.MakeLabel(
		card,
		"Required Level: " .. tostring(map.RequiredLevel),
		UDim2.new(1, -240, 0, 22),
		UDim2.fromOffset(78, 41),
		11,
		true
	)
	levelReq.TextColor3 = GuiFactory.Theme.Accent2

	local description = GuiFactory.MakeLabel(
		card,
		map.Description,
		UDim2.new(1, -240, 0, 39),
		UDim2.fromOffset(78, 63),
		12,
		false
	)
	description.TextWrapped = true
	description.TextYAlignment = Enum.TextYAlignment.Top
	description.TextColor3 = GuiFactory.Theme.MutedText

	local button = GuiFactory.MakeButton(card, "TELEPORT", UDim2.fromOffset(140, 48))
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -14, 0.5, 0)

	button.MouseButton1Click:Connect(function()
		if map.Available and levelValue.Value >= map.RequiredLevel then
			TeleportRequest:FireServer(map.Id)
			closeAllPanels()
		end
	end)

	mapButtons[map.Id] = button
end

-- =========================================================
-- PETS PANEL
-- =========================================================

local petsPanel, petsContent, _, _, petsDim = GuiFactory.MakePanel(
	screen,
	"🐾  PETS",
	620,
	520
)
panels.Pets = petsPanel
dims.Pets = petsDim

local petsTop = GuiFactory.MakeCard(petsContent, 72)
local petsTopTitle = GuiFactory.MakeLabel(
	petsTop,
	"Twoi testowi towarzysze",
	UDim2.new(1, -24, 0, 28),
	UDim2.fromOffset(14, 8),
	16,
	true
)
local petsTopText = GuiFactory.MakeLabel(
	petsTop,
	"Na start wszystkie 3 pety są dostępne do testów.",
	UDim2.new(1, -24, 0, 26),
	UDim2.fromOffset(14, 36),
	12,
	false
)
petsTopText.TextColor3 = GuiFactory.Theme.MutedText

local petsScroll = Instance.new("ScrollingFrame")
petsScroll.Position = UDim2.fromOffset(0, 84)
petsScroll.Size = UDim2.new(1, 0, 1, -84)
petsScroll.BackgroundTransparency = 1
petsScroll.BorderSizePixel = 0
petsScroll.ScrollBarThickness = 6
petsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
petsScroll.CanvasSize = UDim2.new()
petsScroll.Parent = petsContent
GuiFactory.AddListLayout(petsScroll, 10)

local petButtons = {}

for index, pet in ipairs(Config.Pets) do
	local card = GuiFactory.MakeCard(petsScroll, 92)
	card.LayoutOrder = index

	local iconBox = Instance.new("Frame")
	iconBox.Size = UDim2.fromOffset(58, 58)
	iconBox.Position = UDim2.fromOffset(12, 17)
	iconBox.BackgroundColor3 = pet.Color
	iconBox.BorderSizePixel = 0
	iconBox.Parent = card
	GuiFactory.Round(iconBox, 14)

	local icon = GuiFactory.MakeLabel(
		iconBox,
		pet.Icon,
		UDim2.fromScale(1, 1),
		UDim2.fromOffset(0, 0),
		29,
		true
	)
	icon.TextXAlignment = Enum.TextXAlignment.Center

	local name = GuiFactory.MakeLabel(
		card,
		pet.Name,
		UDim2.new(1, -240, 0, 28),
		UDim2.fromOffset(84, 17),
		17,
		true
	)

	local rarity = GuiFactory.MakeLabel(
		card,
		"Rarity: " .. pet.Rarity,
		UDim2.new(1, -240, 0, 24),
		UDim2.fromOffset(84, 48),
		12,
		false
	)
	rarity.TextColor3 = GuiFactory.Theme.MutedText

	local button = GuiFactory.MakeButton(card, "EQUIP", UDim2.fromOffset(126, 46), pet.Color)
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -14, 0.5, 0)

	button.MouseButton1Click:Connect(function()
		EquipPetRequest:FireServer(pet.Id)
	end)

	petButtons[pet.Id] = button
end

-- =========================================================
-- SHOP PANEL
-- =========================================================

local shopPanel, shopContent, _, _, shopDim = GuiFactory.MakePanel(
	screen,
	"🛟  SKLEP RATOWNIKA",
	680,
	560
)
panels.Shop = shopPanel
dims.Shop = shopDim

local shopTop = GuiFactory.MakeCard(shopContent, 72)
local shopTopTitle = GuiFactory.MakeLabel(
	shopTop,
	"Rescue Equipment",
	UDim2.new(1, -24, 0, 26),
	UDim2.fromOffset(14, 8),
	16,
	true
)
local shopTopText = GuiFactory.MakeLabel(
	shopTop,
	"Kup sprzęt ratownika za pieniądze zdobyte w grze.",
	UDim2.new(1, -24, 0, 26),
	UDim2.fromOffset(14, 36),
	12,
	false
)
shopTopText.TextColor3 = GuiFactory.Theme.MutedText

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Position = UDim2.fromOffset(0, 84)
shopScroll.Size = UDim2.new(1, 0, 1, -84)
shopScroll.BackgroundTransparency = 1
shopScroll.BorderSizePixel = 0
shopScroll.ScrollBarThickness = 6
shopScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
shopScroll.CanvasSize = UDim2.new()
shopScroll.Parent = shopContent
GuiFactory.AddListLayout(shopScroll, 10)

local shopButtons = {}

for index, item in ipairs(Config.ShopItems) do
	local card = GuiFactory.MakeCard(shopScroll, 102)
	card.LayoutOrder = index

	local iconBox = Instance.new("Frame")
	iconBox.Size = UDim2.fromOffset(60, 60)
	iconBox.Position = UDim2.fromOffset(12, 21)
	iconBox.BackgroundColor3 = item.Color
	iconBox.BorderSizePixel = 0
	iconBox.Parent = card
	GuiFactory.Round(iconBox, 14)

	local icon = GuiFactory.MakeLabel(
		iconBox,
		item.Icon,
		UDim2.fromScale(1, 1),
		UDim2.fromOffset(0, 0),
		29,
		true
	)
	icon.TextXAlignment = Enum.TextXAlignment.Center

	local name = GuiFactory.MakeLabel(
		card,
		item.Name,
		UDim2.new(1, -250, 0, 28),
		UDim2.fromOffset(84, 15),
		16,
		true
	)

	local description = GuiFactory.MakeLabel(
		card,
		item.Description,
		UDim2.new(1, -250, 0, 42),
		UDim2.fromOffset(84, 47),
		12,
		false
	)
	description.TextWrapped = true
	description.TextYAlignment = Enum.TextYAlignment.Top
	description.TextColor3 = GuiFactory.Theme.MutedText

	local button = GuiFactory.MakeButton(
		card,
		"$" .. tostring(item.Price),
		UDim2.fromOffset(130, 48),
		GuiFactory.Theme.Green
	)
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -14, 0.5, 0)

	button.MouseButton1Click:Connect(function()
		BuyItemRequest:FireServer(item.Id)
	end)

	shopButtons[item.Id] = button
end

-- =========================================================
-- ADMIN PANEL
-- =========================================================

local adminPanel, adminContent, _, _, adminDim = GuiFactory.MakePanel(
	screen,
	"⚙  PANEL ADMINISTRATORA",
	590,
	420
)
panels.Admin = adminPanel
dims.Admin = adminDim
GuiFactory.AddListLayout(adminContent, 12)

local adminInfo = GuiFactory.MakeCard(adminContent, 104)

local adminInfoTitle = GuiFactory.MakeLabel(
	adminInfo,
	"Developer tools",
	UDim2.new(1, -24, 0, 30),
	UDim2.fromOffset(14, 11),
	17,
	true
)
adminInfoTitle.TextColor3 = GuiFactory.Theme.Red

local adminInfoText = GuiFactory.MakeLabel(
	adminInfo,
	"Na ten moment panel pozwala dodawać pieniądze do własnego konta. Kolejne narzędzia dodamy później.",
	UDim2.new(1, -24, 0, 52),
	UDim2.fromOffset(14, 43),
	13,
	false
)
adminInfoText.TextWrapped = true
adminInfoText.TextYAlignment = Enum.TextYAlignment.Top
adminInfoText.TextColor3 = GuiFactory.Theme.MutedText

local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -4, 0, 54)
amountBox.BackgroundColor3 = GuiFactory.Theme.Panel2
amountBox.BorderSizePixel = 0
amountBox.PlaceholderText = "Ilość pieniędzy, np. 10000"
amountBox.Text = ""
amountBox.TextColor3 = GuiFactory.Theme.Text
amountBox.PlaceholderColor3 = GuiFactory.Theme.MutedText
amountBox.TextSize = 16
amountBox.Font = Enum.Font.Gotham
amountBox.ClearTextOnFocus = false
amountBox.Parent = adminContent
GuiFactory.Round(amountBox, 11)
GuiFactory.Stroke(amountBox, 1, 0.45)

local addMoneyButton = GuiFactory.MakeButton(
	adminContent,
	"💰  ADD MONEY",
	UDim2.new(1, -4, 0, 56),
	GuiFactory.Theme.Green
)

-- =========================================================
-- TOAST
-- =========================================================

local toast = Instance.new("Frame")
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, -90)
toast.Size = UDim2.fromOffset(450, 62)
toast.BackgroundColor3 = GuiFactory.Theme.Panel2
toast.BorderSizePixel = 0
toast.Parent = screen
toast.ZIndex = 100
GuiFactory.Round(toast, 13)
GuiFactory.Stroke(toast, 2, 0.25)

local toastText = GuiFactory.MakeLabel(
	toast,
	"",
	UDim2.new(1, -28, 1, 0),
	UDim2.fromOffset(14, 0),
	14,
	true
)
toastText.TextXAlignment = Enum.TextXAlignment.Center
toastText.TextWrapped = true
toastText.ZIndex = 101

local toastGeneration = 0

local function showToast(message, kind)
	toastGeneration += 1
	local generation = toastGeneration

	if kind == "success" then
		toast.BackgroundColor3 = Color3.fromRGB(39, 118, 79)
	elseif kind == "error" then
		toast.BackgroundColor3 = Color3.fromRGB(139, 55, 59)
	elseif kind == "warning" then
		toast.BackgroundColor3 = Color3.fromRGB(145, 101, 43)
	else
		toast.BackgroundColor3 = GuiFactory.Theme.Panel2
	end

	toastText.Text = tostring(message)
	toast.Position = UDim2.new(0.5, 0, 0, -90)

	TweenService:Create(
		toast,
		TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, 0, 0, 20) }
	):Play()

	task.delay(3, function()
		if toastGeneration ~= generation then
			return
		end

		TweenService:Create(
			toast,
			TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Position = UDim2.new(0.5, 0, 0, -90) }
		):Play()
	end)
end

-- =========================================================
-- UPDATE FUNCTIONS
-- =========================================================

local function updateHud()
	moneyLabel.Text = "💰 $" .. formatMoney(moneyValue.Value)
	levelLabel.Text = "⭐ LVL " .. tostring(levelValue.Value)
end

local function getTowerCost(level)
	local raw = Config.Tower.BaseUpgradeCost * (Config.Tower.CostMultiplier ^ (level - 1))
	return math.floor(raw / 10 + 0.5) * 10
end

local function updateTower()
	local level = player:GetAttribute("TowerLevel") or 1

	towerLevelText.Text =
		"Poziom wieży: " .. tostring(level) .. " / " .. tostring(Config.Tower.MaxLevel)

	if level >= Config.Tower.MaxLevel then
		towerCostText.Text = "MAX LEVEL"
		towerUpgradeButton.Text = "✓  MAKSYMALNY POZIOM"
		towerUpgradeButton.BackgroundColor3 = GuiFactory.Theme.Panel3
		towerUpgradeButton.Active = false
	else
		local cost = getTowerCost(level)
		towerCostText.Text = "Koszt: $" .. tostring(cost)
		towerUpgradeButton.Text = "⬆  ULEPSZ WIEŻĘ  •  $" .. tostring(cost)
		towerUpgradeButton.BackgroundColor3 = GuiFactory.Theme.Green
		towerUpgradeButton.Active = true
	end
end

local function updateMaps()
	for _, map in ipairs(Config.Maps) do
		local button = mapButtons[map.Id]

		if button then
			if not map.Available then
				button.Text = "🔒 LOCKED"
				button.BackgroundColor3 = GuiFactory.Theme.Panel3
				button.Active = false
			elseif levelValue.Value < map.RequiredLevel then
				button.Text = "⭐ LVL " .. tostring(map.RequiredLevel)
				button.BackgroundColor3 = GuiFactory.Theme.Orange
				button.Active = false
			else
				button.Text = "TELEPORT"
				button.BackgroundColor3 = GuiFactory.Theme.Accent
				button.Active = true
			end
		end
	end
end

local function updatePets()
	local equipped = player:GetAttribute("EquippedPet") or ""

	for _, pet in ipairs(Config.Pets) do
		local button = petButtons[pet.Id]

		if button then
			if equipped == pet.Id then
				button.Text = "✓ EQUIPPED"
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
		local owned = player:GetAttribute("Owned_" .. item.Id) == true

		if button then
			if owned then
				button.Text = "✓ OWNED"
				button.BackgroundColor3 = GuiFactory.Theme.Panel3
			else
				button.Text = "$" .. tostring(item.Price)
				button.BackgroundColor3 = GuiFactory.Theme.Green
			end
		end
	end
end

local function updateAdmin()
	local isAdmin = player:GetAttribute("IsAdmin") == true
	adminButton.Visible = isAdmin
	adminMini.Visible = isAdmin

	if not isAdmin and adminPanel.Visible then
		closeAllPanels()
	end
end

-- =========================================================
-- BUTTON ACTIONS
-- =========================================================

mapsButton.MouseButton1Click:Connect(function()
	openPanel("Maps")
end)

towerButton.MouseButton1Click:Connect(function()
	openPanel("Tower")
end)

petsButton.MouseButton1Click:Connect(function()
	openPanel("Pets")
end)

shopButton.MouseButton1Click:Connect(function()
	openPanel("Shop")
end)

adminButton.MouseButton1Click:Connect(function()
	if player:GetAttribute("IsAdmin") == true then
		openPanel("Admin")
	end
end)

quickButton.MouseButton1Click:Connect(function()
	TeleportRequest:FireServer("starter_island")
end)

towerUpgradeButton.MouseButton1Click:Connect(function()
	if towerUpgradeButton.Active then
		TowerUpgradeRequest:FireServer()
	end
end)

addMoneyButton.MouseButton1Click:Connect(function()
	if amountBox.Text ~= "" then
		AdminAddMoneyRequest:FireServer(amountBox.Text)
		amountBox.Text = ""
	end
end)

-- =========================================================
-- SERVER EVENTS
-- =========================================================

OpenTower.OnClientEvent:Connect(function()
	openPanel("Tower")
end)

OpenMaps.OnClientEvent:Connect(function()
	openPanel("Maps")
end)

Notify.OnClientEvent:Connect(function(message, kind)
	showToast(message, kind)
end)

-- =========================================================
-- LIVE UPDATES
-- =========================================================

moneyValue:GetPropertyChangedSignal("Value"):Connect(updateHud)

levelValue:GetPropertyChangedSignal("Value"):Connect(function()
	updateHud()
	updateMaps()
end)

player:GetAttributeChangedSignal("TowerLevel"):Connect(updateTower)
player:GetAttributeChangedSignal("EquippedPet"):Connect(updatePets)
player:GetAttributeChangedSignal("IsAdmin"):Connect(updateAdmin)

for _, item in ipairs(Config.ShopItems) do
	player:GetAttributeChangedSignal("Owned_" .. item.Id):Connect(updateShop)
end

updateHud()
updateTower()
updateMaps()
updatePets()
updateShop()
updateAdmin()

showToast("GUI v0.2 załadowane • Rescue Simulator gotowy!", "success")
