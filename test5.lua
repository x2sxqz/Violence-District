--5
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GUI_NAME = "ReaperMiniStatus"

local Colors = {
	Background = Color3.fromRGB(8, 8, 10),
	Background2 = Color3.fromRGB(13, 13, 16),

	Red = Color3.fromRGB(255, 30, 50),
	RedDark = Color3.fromRGB(100, 12, 22),

	White = Color3.fromRGB(245, 245, 247),
	Muted = Color3.fromRGB(75, 75, 83),

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

local Old = PlayerGui:FindFirstChild(GUI_NAME)

if Old then
	Old:Destroy()
end

local Screen = Instance.new("ScreenGui")
Screen.Name = GUI_NAME
Screen.ResetOnSpawn = false
Screen.IgnoreGuiInset = true
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen.Parent = PlayerGui

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

local Glow = Stroke(
	Main,
	Colors.Red,
	7,
	0.82
)

local Edge = Stroke(
	Main,
	Colors.Red,
	1.5,
	0.04
)

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
TopBar.Size = UDim2.new(1, -2, 0, 27)
TopBar.Position = UDim2.fromOffset(1, 1)
TopBar.BackgroundColor3 = Colors.Background2
TopBar.BackgroundTransparency = 0.15
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

Corner(TopBar, 13)

-- Traffic Lights
local Traffic = Instance.new("Frame")
Traffic.Size = UDim2.fromOffset(45, 10)
Traffic.Position = UDim2.fromOffset(12, 8)
Traffic.BackgroundTransparency = 1
Traffic.Parent = TopBar

local TrafficColors = {
	Colors.TrafficRed,
	Colors.TrafficYellow,
	Colors.TrafficGreen
}

for i, color in ipairs(TrafficColors) do
	local Dot = Instance.new("Frame")
	Dot.Size = UDim2.fromOffset(8, 8)
	Dot.Position = UDim2.fromOffset((i - 1) * 15, 1)
	Dot.BackgroundColor3 = color
	Dot.BorderSizePixel = 0
	Dot.Parent = Traffic

	Corner(Dot, 8)
end

-- Header
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -75, 1, 0)
Header.Position = UDim2.fromOffset(58, 0)
Header.BackgroundTransparency = 1
Header.Text = "REAPER HUB"
Header.TextColor3 = Colors.White
Header.TextTransparency = 0.35
Header.TextSize = 9
Header.Font = Enum.Font.GothamBold
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = TopBar

-- Top Right Accent
local TopAccent = Instance.new("Frame")
TopAccent.Name = "TopRightAccent"
TopAccent.Size = UDim2.fromOffset(55, 2)
TopAccent.Position = UDim2.new(1, -75, 0, 0)
TopAccent.BackgroundColor3 = Colors.Red
TopAccent.BorderSizePixel = 0
TopAccent.Parent = Main

Stroke(
	TopAccent,
	Colors.Red,
	4,
	0.65
)

-- Status Area
local StatusArea = Instance.new("Frame")
StatusArea.Name = "StatusArea"
StatusArea.Size = UDim2.new(1, -34, 1, -40)
StatusArea.Position = UDim2.fromOffset(17, 34)
StatusArea.BackgroundTransparency = 1
StatusArea.Parent = Main

-- Status Indicator
local Indicator = Instance.new("Frame")
Indicator.Name = "Indicator"
Indicator.Size = UDim2.fromOffset(7, 7)
Indicator.Position = UDim2.fromOffset(1, 8)
Indicator.BackgroundColor3 = Colors.Red
Indicator.BorderSizePixel = 0
Indicator.Parent = StatusArea

Corner(Indicator, 7)

local IndicatorGlow = Stroke(
	Indicator,
	Colors.Red,
	3,
	0.45
)

-- Status Title
local StatusTitle = Instance.new("TextLabel")
StatusTitle.Size = UDim2.new(1, -18, 0, 13)
StatusTitle.Position = UDim2.fromOffset(17, 2)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "STATUS"
StatusTitle.TextColor3 = Colors.Muted
StatusTitle.TextSize = 8
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.Parent = StatusArea

-- Main Status
local StatusText = Instance.new("TextLabel")
StatusText.Name = "Status"
StatusText.Size = UDim2.new(1, -4, 0, 30)
StatusText.Position = UDim2.fromOffset(0, 19)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Initializing..."
StatusText.TextColor3 = Colors.White
StatusText.TextSize = 14
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextYAlignment = Enum.TextYAlignment.Center
StatusText.TextTruncate = Enum.TextTruncate.AtEnd
StatusText.Parent = StatusArea

-- Bottom Left Accent
local BottomAccent = Instance.new("Frame")
BottomAccent.Name = "BottomLeftAccent"
BottomAccent.Size = UDim2.fromOffset(70, 2)
BottomAccent.Position = UDim2.new(0, 18, 1, -2)
BottomAccent.BackgroundColor3 = Colors.Red
BottomAccent.BorderSizePixel = 0
BottomAccent.Parent = Main

Stroke(
	BottomAccent,
	Colors.Red,
	4,
	0.7
)

-- Status Function
local function SetStatus(text)
	Tween(
		StatusText,
		{
			TextTransparency = 1
		},
		0.12
	)

	task.wait(0.12)

	StatusText.Text = tostring(text)

	Tween(
		StatusText,
		{
			TextTransparency = 0
		},
		0.18
	)
end

-- Drag System
local Dragging = false
local DragStart
local StartPosition

TopBar.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true
		DragStart = Input.Position
		StartPosition = Main.Position
	end
end)

UserInputService.InputChanged:Connect(function(Input)
	if not Dragging then
		return
	end

	if Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch then

		local Delta = Input.Position - DragStart

		Main.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		Dragging = false
	end
end)

-- Opening Animation
Main.Size = UDim2.fromOffset(0, 0)
Main.BackgroundTransparency = 1

Tween(
	Main,
	{
		Size = UDim2.fromOffset(320, 105),
		BackgroundTransparency = 0
	},
	0.45,
	Enum.EasingStyle.Back,
	Enum.EasingDirection.Out
)

-- Main Glow Pulse
task.spawn(function()
	while Main.Parent do
		Tween(
			Glow,
			{
				Transparency = 0.90
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

-- Indicator Pulse
task.spawn(function()
	while Main.Parent do
		Tween(
			IndicatorGlow,
			{
				Transparency = 0.75
			},
			0.8,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		)

		task.wait(0.8)

		Tween(
			IndicatorGlow,
			{
				Transparency = 0.35
			},
			0.8,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		)

		task.wait(0.8)
	end
end)

SetStatus("test...")
