local GuiFactory = {}

GuiFactory.Theme = {
	Background = Color3.fromRGB(10, 16, 24),
	Panel = Color3.fromRGB(18, 27, 39),
	Panel2 = Color3.fromRGB(27, 39, 54),
	Panel3 = Color3.fromRGB(34, 48, 65),

	Accent = Color3.fromRGB(36, 176, 240),
	Accent2 = Color3.fromRGB(70, 216, 198),
	AccentDark = Color3.fromRGB(23, 120, 170),

	Green = Color3.fromRGB(66, 196, 122),
	Red = Color3.fromRGB(230, 86, 86),
	Orange = Color3.fromRGB(244, 166, 73),
	Purple = Color3.fromRGB(126, 103, 220),

	Text = Color3.fromRGB(245, 249, 252),
	MutedText = Color3.fromRGB(170, 186, 201),
	Stroke = Color3.fromRGB(75, 100, 122),
	DarkStroke = Color3.fromRGB(48, 65, 82),
}

function GuiFactory.Round(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = instance
	return corner
end

function GuiFactory.Stroke(instance, thickness, transparency, color)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or GuiFactory.Theme.Stroke
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0.35
	stroke.Parent = instance
	return stroke
end

function GuiFactory.Padding(instance, left, right, top, bottom)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)
	padding.Parent = instance
	return padding
end

function GuiFactory.MakeLabel(parent, text, size, position, textSize, bold)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = size
	label.Position = position or UDim2.fromOffset(0, 0)
	label.Text = text
	label.TextColor3 = GuiFactory.Theme.Text
	label.TextSize = textSize or 18
	label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	return label
end

function GuiFactory.MakeButton(parent, text, size, color)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = true
	button.BackgroundColor3 = color or GuiFactory.Theme.Accent
	button.Size = size or UDim2.fromOffset(150, 42)
	button.Text = text
	button.TextColor3 = GuiFactory.Theme.Text
	button.TextSize = 15
	button.Font = Enum.Font.GothamBold
	button.BorderSizePixel = 0
	button.Parent = parent

	GuiFactory.Round(button, 11)
	GuiFactory.Stroke(button, 1, 0.5)

	return button
end

function GuiFactory.MakeIconButton(parent, icon, title, subtitle, color)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = true
	button.BackgroundColor3 = GuiFactory.Theme.Panel2
	button.Size = UDim2.fromOffset(156, 62)
	button.Text = ""
	button.BorderSizePixel = 0
	button.Parent = parent

	GuiFactory.Round(button, 12)
	GuiFactory.Stroke(button, 1, 0.48)

	local iconBox = Instance.new("Frame")
	iconBox.Size = UDim2.fromOffset(42, 42)
	iconBox.Position = UDim2.fromOffset(10, 10)
	iconBox.BackgroundColor3 = color or GuiFactory.Theme.Accent
	iconBox.BorderSizePixel = 0
	iconBox.Parent = button
	GuiFactory.Round(iconBox, 11)

	local iconLabel = GuiFactory.MakeLabel(
		iconBox,
		icon,
		UDim2.fromScale(1, 1),
		UDim2.fromOffset(0, 0),
		22,
		true
	)
	iconLabel.TextXAlignment = Enum.TextXAlignment.Center

	local titleLabel = GuiFactory.MakeLabel(
		button,
		title,
		UDim2.new(1, -64, 0, 24),
		UDim2.fromOffset(62, 8),
		14,
		true
	)

	local subLabel = GuiFactory.MakeLabel(
		button,
		subtitle or "",
		UDim2.new(1, -64, 0, 22),
		UDim2.fromOffset(62, 31),
		11,
		false
	)
	subLabel.TextColor3 = GuiFactory.Theme.MutedText

	return button
end

function GuiFactory.MakePanel(screenGui, title, width, height)
	local dim = Instance.new("TextButton")
	dim.Name = "Dim"
	dim.Text = ""
	dim.AutoButtonColor = false
	dim.BackgroundColor3 = Color3.new(0, 0, 0)
	dim.BackgroundTransparency = 0.45
	dim.Size = UDim2.fromScale(1, 1)
	dim.Visible = false
	dim.ZIndex = 20
	dim.Parent = screenGui

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(width or 590, height or 520)
	panel.BackgroundColor3 = GuiFactory.Theme.Panel
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.ZIndex = 21
	panel.Parent = screenGui

	GuiFactory.Round(panel, 16)
	GuiFactory.Stroke(panel, 2, 0.18, GuiFactory.Theme.DarkStroke)

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 64)
	titleBar.BackgroundColor3 = GuiFactory.Theme.Panel2
	titleBar.BorderSizePixel = 0
	titleBar.ZIndex = 22
	titleBar.Parent = panel
	GuiFactory.Round(titleBar, 16)

	local titleLabel = GuiFactory.MakeLabel(
		titleBar,
		title,
		UDim2.new(1, -96, 1, 0),
		UDim2.fromOffset(18, 0),
		21,
		true
	)
	titleLabel.ZIndex = 23

	local close = GuiFactory.MakeButton(
		titleBar,
		"✕",
		UDim2.fromOffset(42, 38),
		GuiFactory.Theme.Red
	)
	close.AnchorPoint = Vector2.new(1, 0.5)
	close.Position = UDim2.new(1, -13, 0.5, 0)
	close.ZIndex = 23

	local content = Instance.new("Frame")
	content.BackgroundTransparency = 1
	content.Position = UDim2.fromOffset(14, 77)
	content.Size = UDim2.new(1, -28, 1, -91)
	content.ZIndex = 22
	content.Parent = panel

	local function closePanel()
		panel.Visible = false
		dim.Visible = false
	end

	close.MouseButton1Click:Connect(closePanel)
	dim.MouseButton1Click:Connect(closePanel)

	return panel, content, close, titleLabel, dim
end

function GuiFactory.MakeCard(parent, height)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -4, 0, height or 78)
	card.BackgroundColor3 = GuiFactory.Theme.Panel2
	card.BorderSizePixel = 0
	card.Parent = parent

	GuiFactory.Round(card, 12)
	GuiFactory.Stroke(card, 1, 0.55, GuiFactory.Theme.DarkStroke)

	return card
end

function GuiFactory.AddListLayout(parent, padding, horizontal)
	local layout = horizontal and Instance.new("UIListLayout") or Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, padding or 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
	layout.HorizontalAlignment = horizontal and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = horizontal and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top
	layout.Parent = parent
	return layout
end

return GuiFactory
