local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local PetVisuals = {}

local player = Players.LocalPlayer
local currentModel = nil
local currentCFrame = nil
local connection = nil

local function part(parent, name, size, position, color, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = CFrame.new(position)
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false

	if shape then
		p.Shape = shape
	end

	p.Parent = parent
	return p
end

local function buildDog(model, pet)
	local body = part(model, "Body", Vector3.new(2.4, 1.5, 3.2), Vector3.new(0, 0, 0), pet.Color)
	part(model, "Head", Vector3.new(1.9, 1.9, 1.9), Vector3.new(0, 0.45, -2), pet.Color, Enum.PartType.Ball)
	part(model, "EarL", Vector3.new(0.5, 1.2, 0.45), Vector3.new(-0.72, 1.1, -2), Color3.fromRGB(102, 67, 42))
	part(model, "EarR", Vector3.new(0.5, 1.2, 0.45), Vector3.new(0.72, 1.1, -2), Color3.fromRGB(102, 67, 42))
	part(model, "Tail", Vector3.new(0.4, 0.4, 1.5), Vector3.new(0, 0.55, 2), Color3.fromRGB(102, 67, 42))
	model.PrimaryPart = body
end

local function buildDuck(model, pet)
	local body = part(model, "Body", Vector3.new(2.5, 2, 2.8), Vector3.new(0, 0, 0), pet.Color, Enum.PartType.Ball)
	part(model, "Head", Vector3.new(1.8, 1.8, 1.8), Vector3.new(0, 1.15, -1.4), pet.Color, Enum.PartType.Ball)
	part(model, "Beak", Vector3.new(1.2, 0.45, 0.8), Vector3.new(0, 1.05, -2.35), Color3.fromRGB(247, 145, 45))
	model.PrimaryPart = body
end

local function buildTurtle(model, pet)
	local body = part(model, "Body", Vector3.new(3.1, 1.2, 3.8), Vector3.new(0, 0, 0), pet.Color, Enum.PartType.Ball)
	part(model, "Shell", Vector3.new(2.8, 1.3, 3.2), Vector3.new(0, 0.55, 0.2), Color3.fromRGB(61, 121, 69), Enum.PartType.Ball)
	part(model, "Head", Vector3.new(1.25, 1.25, 1.25), Vector3.new(0, 0, -2.25), Color3.fromRGB(98, 190, 115), Enum.PartType.Ball)
	model.PrimaryPart = body
end

local function destroyCurrent()
	if connection then
		connection:Disconnect()
		connection = nil
	end

	if currentModel then
		currentModel:Destroy()
		currentModel = nil
	end

	currentCFrame = nil
end

function PetVisuals.SetPet(petId)
	destroyCurrent()

	if not petId or petId == "" then
		return
	end

	local pet = Config.GetPet(petId)
	if not pet then
		return
	end

	local model = Instance.new("Model")
	model.Name = "LocalPet_" .. pet.Id

	if pet.Id == "rescue_dog" then
		buildDog(model, pet)
	elseif pet.Id == "lifeguard_duck" then
		buildDuck(model, pet)
	elseif pet.Id == "rescue_turtle" then
		buildTurtle(model, pet)
	else
		return
	end

	model.Parent = workspace
	currentModel = model

	connection = RunService.RenderStepped:Connect(function(dt)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")

		if not root or not currentModel or not currentModel.Parent then
			return
		end

		local position = (root.CFrame * CFrame.new(3.2, -2.15, 3.5)).Position
		local lookAt = Vector3.new(root.Position.X, position.Y, root.Position.Z)

		local target = CFrame.lookAt(position, lookAt)
		local alpha = math.clamp(dt * 7, 0, 1)

		currentCFrame = currentCFrame and currentCFrame:Lerp(target, alpha) or target
		currentModel:PivotTo(currentCFrame)
	end)
end

return PetVisuals
