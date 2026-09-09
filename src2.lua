-- [[ HYPERX ELITE AIM HUB - NEW DESIGN ]] -- 2
local LP = game:GetService("Players").LocalPlayer
local PG = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")

-- Cleanup
if PG:FindFirstChild("HyperX_Elite") then PG["HyperX_Elite"]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HyperX_Elite"
ScreenGui.Parent = PG
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 250, 0, 350)
Main.Position = UDim2.new(0.5, -125, 0.4, -175)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Color = Color3.fromRGB(255, 0, 50)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "HYPERX | ELITE AIM"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- Container
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -10, 1, -45)
Container.Position = UDim2.new(0, 5, 0, 40)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 400)
Container.Parent = Main

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper: Add Toggle
local function NewToggle(text, flag, side_color)
    local Frame = Instance.new("TextButton")
    Frame.Size = UDim2.new(0.95, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Frame.AutoButtonColor = false
    Frame.Text = ""
    Frame.Parent = Container
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Indicator = Instance.new("Frame", Frame)
    Indicator.Size = UDim2.new(0, 4, 1, 0)
    Indicator.BackgroundColor3 = side_color
    Indicator.BorderSizePixel = 0
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Status = Instance.new("Frame", Frame)
    Status.Size = UDim2.new(0, 30, 0, 16)
    Status.Position = UDim2.new(1, -40, 0.5, -8)
    Status.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Instance.new("UICorner", Status).CornerRadius = UDim.new(1, 0)

    local Dot = Instance.new("Frame", Status)
    Dot.Size = UDim2.new(0, 12, 0, 12)
    Dot.Position = UDim2.new(0, 2, 0.5, -6)
    Dot.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local function Update()
        local enabled = false
        if typeof(flag) == "string" then enabled = getgenv().VD[flag]
        elseif typeof(flag) == "table" then enabled = flag.Enabled end

        Label.TextColor3 = enabled and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
        Status.BackgroundColor3 = enabled and side_color or Color3.fromRGB(40, 40, 45)
        Dot:TweenPosition(enabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), "Out", "Quart", 0.2, true)
    end

    Frame.MouseButton1Click:Connect(function()
        if typeof(flag) == "string" then
            getgenv().VD[flag] = not getgenv().VD[flag]
        elseif typeof(flag) == "table" then
            flag.Enabled = not flag.Enabled
        end
        Update()
    end)
    Update()
end

-- Sections
local function Section(txt)
    local L = Instance.new("TextLabel", Container)
    L.Size = UDim2.new(0.9, 0, 0, 20)
    L.Text = txt:upper()
    L.TextColor3 = Color3.fromRGB(100, 100, 100)
    L.Font = Enum.Font.GothamBold
    L.TextSize = 10
    L.BackgroundTransparency = 1
end

-- Adding Items
Section("Survivor Combat")
AddToggle("ToF Silent Aim", "TOF_SilentAim", Color3.fromRGB(0, 150, 255))
AddToggle("Flashlight Silent", "FLASH_SilentAim", Color3.fromRGB(0, 150, 255))A
AddToggle("Main Aimbot", "AIM_Enabled", Color3.fromRGB(0, 150, 255))

Section("Killer Combat")
if getgenv().VeilConfig then AddToggle("Veil Spear Aim", getgenv().VeilConfig, Color3.fromRGB(255, 0, 50)) end
AddToggle("Cure Flask Aim", "KILLER_SilentAimFlask", Color3.fromRGB(255, 0, 50))
AddToggle("Target Lock", "AimLockButton", Color3.fromRGB(255, 0, 50))

-- Close
local Close = Instance.new("TextButton", Header)
Close.Size = UDim2.new(0, 35, 1, 0)
Close.Position = UDim2.new(1, -35, 0, 0)
Close.Text = "×"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 20
Close.BackgroundTransparency = 1
Close.Font = Enum.Font.Gotham
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
