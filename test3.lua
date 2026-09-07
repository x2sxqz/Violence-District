-- [[ HyperX Optimized Auto Parry ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // configuration
local Config = {
    Enabled = true,
    Range = 15,
    VisualEnabled = true,
    AttackAnimations = {
        ["139369275981139"] = true, ["121216847022485"] = true, ["78935059863801"] = true,
        ["74968262036854"] = true, ["82666958311998"] = true, ["78432063483146"] = true,
        ["132817836308238"] = true, ["111920872708571"] = true, ["138720291317243"] = true,
        ["130593238885843"] = true, ["106871536134254"] = true, ["109402730355822"] = true
    }
}

-- // references
local function GetGuiMob()
    local survivorMob = PlayerGui:FindFirstChild("Survivor-mob")
    if survivorMob then
        local controls = survivorMob:FindFirstChild("Controls")
        if controls then
            return controls:FindFirstChild("Gui-mob")
        end
    end
    return nil
end

-- // visual ring
local Ring = Instance.new("Part")
Ring.Name = "ParryRangeVisual"
Ring.Anchored = true
Ring.CanCollide = false
Ring.CastShadow = false
Ring.Transparency = 0.5
Ring.Material = Enum.Material.Neon
Ring.Color = Color3.fromRGB(255, 0, 0)
Ring.Shape = Enum.PartType.Cylinder
Ring.Size = Vector3.new(0.2, Config.Range * 2, Config.Range * 2)
Ring.Orientation = Vector3.new(0, 0, 90)
Ring.Parent = workspace

-- // logic
local function TriggerParry()
    local guiMob = GetGuiMob()
    if guiMob and firesignal then
        firesignal(guiMob.MouseButton1Down)
    end
end

local function IsKiller(char)
    return char:FindFirstChild("Lookscriptkiller", true) ~= nil
end

-- // detection
RunService.Heartbeat:Connect(function()
    if not Config.Enabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Ring.Transparency = 1
        return
    end

    local root = LocalPlayer.Character.HumanoidRootPart
    Ring.Transparency = Config.VisualEnabled and 0.5 or 1
    Ring.Position = root.Position - Vector3.new(0, 2.8, 0)
    Ring.Size = Vector3.new(0.1, Config.Range * 2, Config.Range * 2)

    local targetFound = false
    
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and v ~= LocalPlayer.Character and IsKiller(v) then
            local kRoot = v:FindFirstChild("HumanoidRootPart")
            local kHum = v:FindFirstChildOfClass("Humanoid")
            
            if kRoot and kHum then
                local distance = (root.Position - kRoot.Position).Magnitude
                if distance <= Config.Range then
                    -- Check Animations
                    local animator = kHum:FindFirstChildOfClass("Animator")
                    if animator then
                        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                            local id = tostring(track.Animation.AnimationId):match("%d+")
                            if Config.AttackAnimations[id] then
                                targetFound = true
                                TriggerParry()
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    Ring.Color = targetFound and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- // UI system (Mobile Friendly & Draggable)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "HyperX_AutoParry"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 180)
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- Standard draggable for simplicity

local UICorner = Instance.new("UICorner", Main)
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "HYPERX AUTO PARRY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local function CreateToggle(name, default, pos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.BackgroundColor3 = default and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    btn.Text = name .. (default and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    local corner = Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        local state = not (btn.BackgroundColor3 == Color3.fromRGB(50, 150, 50))
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
        btn.Text = name .. (state and ": ON" or ": OFF")
        callback(state)
    end)
end

local RangeLabel = Instance.new("TextLabel", Main)
RangeLabel.Size = UDim2.new(1, 0, 0, 20)
RangeLabel.Position = UDim2.new(0, 0, 0, 110)
RangeLabel.BackgroundTransparency = 1
RangeLabel.Text = "Range: " .. Config.Range
RangeLabel.TextColor3 = Color3.new(1, 1, 1)
RangeLabel.Font = Enum.Font.Gotham
RangeLabel.TextSize = 12

local RangeSlider = Instance.new("TextButton", Main)
RangeSlider.Size = UDim2.new(0.9, 0, 0, 10)
RangeSlider.Position = UDim2.new(0.05, 0, 0, 135)
RangeSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RangeSlider.Text = ""
Instance.new("UICorner", RangeSlider)

local SliderPoint = Instance.new("Frame", RangeSlider)
SliderPoint.Size = UDim2.new(0, 10, 2, 0)
SliderPoint.Position = UDim2.new((Config.Range-1)/31, -5, -0.5, 0)
SliderPoint.BackgroundColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SliderPoint)

local function UpdateSlider(input)
    local pos = math.clamp((input.Position.X - RangeSlider.AbsolutePosition.X) / RangeSlider.AbsoluteSize.X, 0, 1)
    Config.Range = math.floor(1 + (pos * 31))
    SliderPoint.Position = UDim2.new(pos, -5, -0.5, 0)
    RangeLabel.Text = "Range: " .. Config.Range
end

local sliding = false
RangeSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = true
        UpdateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)

CreateToggle("Auto Parry", true, 40, function(v) Config.Enabled = v end)
CreateToggle("Visual Range", true, 75, function(v) Config.VisualEnabled = v end)
