local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GUI_NAME = "ReaperMiniStatus"

local Icons = {
	Reaper = "rbxassetid://131279093559313"
}

local Colors = {
	Background = Color3.fromRGB(8, 8, 10),
	Background2 = Color3.fromRGB(13, 13, 16),

	Red = Color3.fromRGB(255, 35, 55),
	RedDark = Color3.fromRGB(110, 15, 25),

	White = Color3.fromRGB(245, 245, 247),
	Gray = Color3.fromRGB(145, 145, 152),
	Muted = Color3.fromRGB(80, 80, 88),

	TrafficRed = Color3.fromRGB(255, 95, 87),
	TrafficYellow = Color3.fromRGB(254, 188, 46),
	TrafficGreen = Color3.fromRGB(40, 200, 64)
}

local function Tween(object, properties, duration, style, direction)
	local tween = TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.25,
			style or Enum.EasingStyle.Quint,
			direction or Enum.EasingDirection.Out
		),
		properties
	)

	tween:Play()
	return tween
end

local function Corner(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = object
	return corner
end

local function Stroke(object, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = object
	return stroke
end

local old = PlayerGui:FindFirstChild(GUI_NAME)

if old then
	old:Destroy()
end

local Screen = Instance.new("ScreenGui")
Screen.Name = GUI_NAME
Screen.ResetOnSpawn = false
Screen.IgnoreGuiInset = true
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen.Parent = PlayerGui

-- Main Window
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(320, 105)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Colors.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = false
Main.Parent = Screen

Corner(Main, 14)

-- Outer Red Glow
local Glow = Stroke(
	Main,
	Colors.Red,
	7,
	0.82
)

-- Main Red Edge
local Edge = Stroke(
	Main,
	Colors.Red,
	1.5,
	0.05
)

-- Inner Border
local Inner = Instance.new("Frame")
Inner.Name = "Inner"
Inner.Size = UDim2.new(1, -12, 1, -12)
Inner.Position = UDim2.fromOffset(6, 6)
Inner.BackgroundTransparency = 1
Inner.BorderSizePixel = 0
Inner.Parent = Main

Corner(Inner, 10)

Stroke(
	Inner,
	Colors.RedDark,
	1,
	0.25
)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, -2, 0, 28)
TopBar.Position = UDim2.fromOffset(1, 1)
TopBar.BackgroundColor3 = Colors.Background2
TopBar.BackgroundTransparency = 0.15
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

Corner(TopBar, 13)

-- Traffic Lights
local Traffic = Instance.new("Frame")
Traffic.Size = UDim2.fromOffset(42, 10)
Traffic.Position = UDim2.fromOffset(12, 9)
Traffic.BackgroundTransparency = 1
Traffic.Parent = TopBar

local trafficColors = {
	Colors.TrafficRed,
	Colors.TrafficYellow,
	Colors.TrafficGreen
}

for i, color in ipairs(trafficColors) do
	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(8, 8)
	dot.Position = UDim2.fromOffset((i - 1) * 15, 1)
	dot.BackgroundColor3 = color
	dot.BorderSizePixel = 0
	dot.Parent = Traffic

	Corner(dot, 8)
end

-- Header
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -80, 1, 0)
Header.Position = UDim2.fromOffset(55, 0)
Header.BackgroundTransparency = 1
Header.Text = "REAPER HUB"
Header.TextColor3 = Colors.White
Header.TextTransparency = 0.35
Header.TextSize = 9
Header.Font = Enum.Font.GothamBold
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = TopBar

-- Red Top Accent
local TopAccent = Instance.new("Frame")
TopAccent.Size = UDim2.fromOffset(55, 2)
TopAccent.Position = UDim2.new(1, -70, 0, 0)
TopAccent.BackgroundColor3 = Colors.Red
TopAccent.BorderSizePixel = 0
TopAccent.Parent = Main

Stroke(
	TopAccent,
	Colors.Red,
	4,
	0.65
)

-- Status Container
local StatusContainer = Instance.new("Frame")
StatusContainer.Name = "StatusContainer"
StatusContainer.Size = UDim2.new(1, -28, 0, 58)
StatusContainer.Position = UDim2.fromOffset(14, 36)
StatusContainer.BackgroundTransparency = 1
StatusContainer.Parent = Main

-- Icon Area
local IconHolder = Instance.new("Frame")
IconHolder.Size = UDim2.fromOffset(42, 42)
IconHolder.Position = UDim2.new(0, 0, 0.5, 0)
IconHolder.AnchorPoint = Vector2.new(0, 0.5)
IconHolder.BackgroundColor3 = Colors.RedDark
IconHolder.BackgroundTransparency = 0.7
IconHolder.BorderSizePixel = 0
IconHolder.Parent = StatusContainer

Corner(IconHolder, 12)

Stroke(
	IconHolder,
	Colors.Red,
	1,
	0.45
)

local Icon = Instance.new("ImageLabel")
Icon.Size = UDim2.fromOffset(27, 27)
Icon.Position = UDim2.fromScale(0.5, 0.5)
Icon.AnchorPoint = Vector2.new(0.5, 0.5)
Icon.BackgroundTransparency = 1
Icon.Image = Icons.Reaper
Icon.ScaleType = Enum.ScaleType.Fit
Icon.ImageColor3 = Colors.White
Icon.Parent = IconHolder

-- Status Label
local StatusTitle = Instance.new("TextLabel")
StatusTitle.Size = UDim2.new(1, -58, 0, 14)
StatusTitle.Position = UDim2.fromOffset(56, 7)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "STATUS"
StatusTitle.TextColor3 = Colors.Muted
StatusTitle.TextSize = 8
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.Parent = StatusContainer

local StatusText = Instance.new("TextLabel")
StatusText.Name = "Status"
StatusText.Size = UDim2.new(1, -58, 0, 30)
StatusText.Position = UDim2.fromOffset(56, 20)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Initializing..."
StatusText.TextColor3 = Colors.White
StatusText.TextSize = 13
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextYAlignment = Enum.TextYAlignment.Center
StatusText.TextTruncate = Enum.TextTruncate.AtEnd
StatusText.Parent = StatusContainer

-- Bottom Red Accent
local BottomAccent = Instance.new("Frame")
BottomAccent.Size = UDim2.fromOffset(70, 2)
BottomAccent.Position = UDim2.new(0, 18, 1, -2)
BottomAccent.BackgroundColor3 = Colors.Red
BottomAccent.BorderSizePixel = 0
BottomAccent.Parent = Main

-- Status Function
local function SetStatus(text)
	StatusText.TextTransparency = 1

	Tween(
		StatusText,
		{
			TextTransparency = 0
		},
		0.2
	)

	StatusText.Text = tostring(text)
end

-- Drag System
local dragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false
	end
end)

-- Open Animation
Main.Size = UDim2.fromOffset(0, 0)
Main.BackgroundTransparency = 1

Tween(
	Main,
	{
		Size = UDim2.fromOffset(320, 105),
		BackgroundTransparency = 0
	},
	0.45,
	Enum.EasingStyle.Back
)

-- Subtle Red Pulse
task.spawn(function()
	while Main.Parent do
		Tween(
			Glow,
			{
				Transparency = 0.9
			},
			1.2,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		)

		task.wait(1.2)

		Tween(
			Glow,
			{
				Transparency = 0.76
			},
			1.2,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		)

		task.wait(1.2)
	end
end)

-- Example
SetStatus("Initializing...")
