local Workspace = game:GetService("Workspace")

local MapService = {}

local refs = {
	SpawnPoints = {},
}

local function makePart(parent, name, size, cframe, color, material, transparency, canCollide)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Transparency = transparency or 0
	part.Anchored = true
	part.CanCollide = canCollide ~= false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeLabel(adornee, text, width)
	local gui = Instance.new("BillboardGui")
	gui.Name = "WorldLabel"
	gui.Size = UDim2.fromOffset(width or 220, 46)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Adornee = adornee
	gui.Parent = adornee

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(19, 29, 40)
	label.BackgroundTransparency = 0.18
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.65
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = text
	label.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label
end

local function makeTree(parent, position, scale)
	scale = scale or 1

	local trunk = makePart(
		parent,
		"TreeTrunk",
		Vector3.new(2.5, 9, 2.5) * scale,
		CFrame.new(position + Vector3.new(0, 4.5 * scale, 0)),
		Color3.fromRGB(118, 79, 50),
		Enum.Material.Wood
	)

	local leaves = makePart(
		parent,
		"TreeLeaves",
		Vector3.new(9, 8, 9) * scale,
		CFrame.new(position + Vector3.new(0, 11 * scale, 0)),
		Color3.fromRGB(63, 145, 75),
		Enum.Material.Grass,
		0,
		false
	)
	leaves.Shape = Enum.PartType.Ball

	return trunk
end

local function makeRock(parent, position, size)
	local rock = makePart(
		parent,
		"Rock",
		size,
		CFrame.new(position) * CFrame.Angles(math.rad(8), math.rad(24), math.rad(5)),
		Color3.fromRGB(105, 111, 117),
		Enum.Material.Slate
	)
	rock.Shape = Enum.PartType.Ball
	return rock
end

local function makeNpc(parent, position)
	local npc = Instance.new("Model")
	npc.Name = "IslandManager"
	npc.Parent = parent

	local root = makePart(
		npc,
		"HumanoidRootPart",
		Vector3.new(2, 2, 1),
		CFrame.new(position + Vector3.new(0, 3, 0)),
		Color3.fromRGB(35, 77, 125),
		Enum.Material.SmoothPlastic,
		1,
		false
	)

	local torso = makePart(
		npc,
		"Torso",
		Vector3.new(3, 4, 1.5),
		CFrame.new(position + Vector3.new(0, 4.5, 0)),
		Color3.fromRGB(30, 105, 173),
		Enum.Material.SmoothPlastic
	)

	local head = makePart(
		npc,
		"Head",
		Vector3.new(2.4, 2.4, 2.4),
		CFrame.new(position + Vector3.new(0, 7.7, 0)),
		Color3.fromRGB(238, 198, 156),
		Enum.Material.SmoothPlastic
	)
	head.Shape = Enum.PartType.Ball

	makePart(
		npc,
		"LeftArm",
		Vector3.new(1, 4, 1),
		CFrame.new(position + Vector3.new(-2, 4.5, 0)),
		Color3.fromRGB(238, 198, 156),
		Enum.Material.SmoothPlastic
	)

	makePart(
		npc,
		"RightArm",
		Vector3.new(1, 4, 1),
		CFrame.new(position + Vector3.new(2, 4.5, 0)),
		Color3.fromRGB(238, 198, 156),
		Enum.Material.SmoothPlastic
	)

	makePart(
		npc,
		"LeftLeg",
		Vector3.new(1.2, 4, 1.2),
		CFrame.new(position + Vector3.new(-0.8, 1.5, 0)),
		Color3.fromRGB(31, 49, 68),
		Enum.Material.SmoothPlastic
	)

	makePart(
		npc,
		"RightLeg",
		Vector3.new(1.2, 4, 1.2),
		CFrame.new(position + Vector3.new(0.8, 1.5, 0)),
		Color3.fromRGB(31, 49, 68),
		Enum.Material.SmoothPlastic
	)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "MapsPrompt"
	prompt.ActionText = "Wybierz wyspę"
	prompt.ObjectText = "Manager Wysp"
	prompt.HoldDuration = 0.15
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = torso

	makeLabel(head, "MANAGER WYSP", 210)

	npc.PrimaryPart = root
	refs.MapsPrompt = prompt
	return npc
end

local function makeTower(parent, position)
	local tower = Instance.new("Model")
	tower.Name = "LifeguardTower"
	tower.Parent = parent

	local wood = Color3.fromRGB(210, 164, 102)
	local red = Color3.fromRGB(218, 70, 70)
	local white = Color3.fromRGB(245, 245, 240)

	for _, x in ipairs({ -6.5, 6.5 }) do
		for _, z in ipairs({ -4.5, 4.5 }) do
			makePart(
				tower,
				"TowerPost",
				Vector3.new(1.2, 13, 1.2),
				CFrame.new(position + Vector3.new(x, 6.5, z)),
				wood,
				Enum.Material.WoodPlanks
			)
		end
	end

	local platform = makePart(
		tower,
		"TowerPlatform",
		Vector3.new(17, 1, 13),
		CFrame.new(position + Vector3.new(0, 12, 0)),
		wood,
		Enum.Material.WoodPlanks
	)

	makePart(
		tower,
		"TowerCabinBack",
		Vector3.new(13, 6, 1),
		CFrame.new(position + Vector3.new(0, 15.5, 4.5)),
		white,
		Enum.Material.WoodPlanks
	)

	makePart(
		tower,
		"TowerCabinLeft",
		Vector3.new(1, 6, 8),
		CFrame.new(position + Vector3.new(-6, 15.5, 0.5)),
		white,
		Enum.Material.WoodPlanks
	)

	makePart(
		tower,
		"TowerCabinRight",
		Vector3.new(1, 6, 8),
		CFrame.new(position + Vector3.new(6, 15.5, 0.5)),
		white,
		Enum.Material.WoodPlanks
	)

	local roof = makePart(
		tower,
		"TowerRoof",
		Vector3.new(16, 1.2, 12),
		CFrame.new(position + Vector3.new(0, 19, 0.8)),
		red,
		Enum.Material.Metal
	)

	local sign = makePart(
		tower,
		"TowerSign",
		Vector3.new(9, 2.5, 0.6),
		CFrame.new(position + Vector3.new(0, 16, -5)),
		red,
		Enum.Material.SmoothPlastic
	)
	makeLabel(sign, "RESCUE TOWER", 190)

	for y = 2, 11, 2 do
		makePart(
			tower,
			"LadderStep",
			Vector3.new(4.5, 0.35, 0.5),
			CFrame.new(position + Vector3.new(0, y, -6)),
			Color3.fromRGB(110, 88, 65),
			Enum.Material.WoodPlanks
		)
	end

	makePart(
		tower,
		"LadderLeft",
		Vector3.new(0.45, 11, 0.45),
		CFrame.new(position + Vector3.new(-2, 6, -6)),
		Color3.fromRGB(110, 88, 65),
		Enum.Material.WoodPlanks
	)

	makePart(
		tower,
		"LadderRight",
		Vector3.new(0.45, 11, 0.45),
		CFrame.new(position + Vector3.new(2, 6, -6)),
		Color3.fromRGB(110, 88, 65),
		Enum.Material.WoodPlanks
	)

	local interactionPart = makePart(
		tower,
		"TowerInteraction",
		Vector3.new(6, 5, 3),
		CFrame.new(position + Vector3.new(0, 2.5, -8)),
		Color3.new(1, 1, 1),
		Enum.Material.SmoothPlastic,
		1,
		false
	)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "TowerPrompt"
	prompt.ActionText = "Ustawienia wieży"
	prompt.ObjectText = "Twoja wieża ratownika"
	prompt.HoldDuration = 0.15
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = interactionPart

	refs.TowerPrompt = prompt
	refs.TowerPlatform = platform
	refs.TowerRoof = roof

	return tower
end

function MapService.Build()
	local old = Workspace:FindFirstChild("GeneratedRescueMap")
	if old then
		old:Destroy()
	end

	local map = Instance.new("Model")
	map.Name = "GeneratedRescueMap"
	map.Parent = Workspace

	Workspace.FallenPartsDestroyHeight = -80

	local sand = makePart(
		map,
		"IslandSand",
		Vector3.new(340, 8, 340),
		CFrame.new(0, 0, 0),
		Color3.fromRGB(223, 200, 139),
		Enum.Material.Sand
	)

	local grass = makePart(
		map,
		"IslandGrass",
		Vector3.new(302, 3, 302),
		CFrame.new(0, 5.5, 0),
		Color3.fromRGB(91, 156, 78),
		Enum.Material.Grass
	)

	local water = makePart(
		map,
		"LakeWater",
		Vector3.new(78, 1.2, 58),
		CFrame.new(5, 7.3, -28),
		Color3.fromRGB(50, 155, 211),
		Enum.Material.Glass,
		0.2,
		false
	)

	local lakeBottom = makePart(
		map,
		"LakeBottom",
		Vector3.new(84, 1, 64),
		CFrame.new(5, 6.5, -28),
		Color3.fromRGB(54, 101, 111),
		Enum.Material.Sand
	)

	for i = -4, 4 do
		makeRock(
			map,
			Vector3.new(-38 + i * 10, 8.8, -58 + math.abs(i) * 2.2),
			Vector3.new(4.5, 3.5, 4.5)
		)
	end

	local dockStart = Vector3.new(35, 8.5, -28)
	for i = 0, 5 do
		makePart(
			map,
			"DockPlank",
			Vector3.new(6, 0.8, 5),
			CFrame.new(dockStart + Vector3.new(i * 5.5, 0, 0)),
			Color3.fromRGB(147, 103, 67),
			Enum.Material.WoodPlanks
		)
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "StarterIslandSpawn"
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.CFrame = CFrame.new(-105, 8, 88)
	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(71, 197, 255)
	spawn.Transparency = 0.12
	spawn.Parent = map

	makeLabel(spawn, "START", 130)
	refs.SpawnPoints.StarterIslandSpawn = spawn.CFrame + Vector3.new(0, 5, 0)

	local towerPosition = Vector3.new(92, 7, 62)
	makeTower(map, towerPosition)

	makeNpc(map, Vector3.new(-66, 7, -58))

	local infoBoard = makePart(
		map,
		"InfoBoard",
		Vector3.new(18, 9, 1),
		CFrame.new(-86, 12, 38),
		Color3.fromRGB(25, 55, 78),
		Enum.Material.WoodPlanks
	)
	makeLabel(infoBoard, "RESCUE SIMULATOR\nTEST ISLAND", 270)

	local trees = {
		Vector3.new(-120, 7, -105),
		Vector3.new(-100, 7, -125),
		Vector3.new(-65, 7, -120),
		Vector3.new(105, 7, -110),
		Vector3.new(125, 7, -72),
		Vector3.new(125, 7, 110),
		Vector3.new(76, 7, 125),
		Vector3.new(-115, 7, 118),
		Vector3.new(-50, 7, 126),
	}

	for i, position in ipairs(trees) do
		makeTree(map, position, 0.9 + (i % 3) * 0.12)
	end

	for i = 1, 14 do
		local angle = math.rad((i - 1) * (360 / 14))
		local radius = 145
		makeRock(
			map,
			Vector3.new(math.cos(angle) * radius, 7.8, math.sin(angle) * radius),
			Vector3.new(5, 3, 6)
		)
	end

	local ocean = makePart(
		map,
		"Ocean",
		Vector3.new(1100, 3, 1100),
		CFrame.new(0, -5.7, 0),
		Color3.fromRGB(42, 129, 188),
		Enum.Material.Glass,
		0.16,
		false
	)
	ocean.CastShadow = false

	map.PrimaryPart = grass
	refs.MapModel = map

	return refs
end

function MapService.GetRefs()
	return refs
end

return MapService
