-- [[ HyperX Ultra Aggressive Parry - 3D Drawing Circle ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Config = {
    Enabled = true,
    Range = 8,
    VisualEnabled = true,
    AttackAnimations = {
        ["139369275981139"] = true, ["121216847022485"] = true, ["78935059863801"] = true,
        ["74968262036854"] = true, ["82666958311998"] = true, ["78432063483146"] = true,
        ["132817836308238"] = true, ["111920872708571"] = true, ["138720291317243"] = true,
        ["130593238885843"] = true, ["106871536134254"] = true, ["109402730355822"] = true
    }
}

-- [ Drawing Visual Setup ]
local Segments = 16
local CircleLines = {}
for i = 1, Segments do
    local Line = Drawing.new("Line")
    Line.Thickness = 1.5
    Line.Transparency = 1
    CircleLines[i] = Line
end

-- [ Cache Variables ]
local CachedGuiMob = nil
local KillerModel = nil

local function GetGuiMob()
    if CachedGuiMob and CachedGuiMob.Parent then return CachedGuiMob end
    local mob = PlayerGui:FindFirstChild("Survivor-mob")
    CachedGuiMob = mob and mob:FindFirstChild("Gui-mob", true)
    return CachedGuiMob
end

-- [ 3D Circle Drawing Logic ]
local function Update3DCircle(origin, radius, color)
    local points = {}
    local step = (math.pi * 2) / Segments
    
    for i = 0, Segments do
        local angle = i * step
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local screenPos, onScreen = Camera:WorldToViewportPoint(origin + offset)
        points[i+1] = {Pos = Vector2.new(screenPos.X, screenPos.Y), Visible = onScreen}
    end

    for i = 1, Segments do
        local line = CircleLines[i]
        local p1 = points[i]
        local p2 = points[i+1]
        
        if p1.Visible and p2.Visible and Config.VisualEnabled then
            line.Visible = true
            line.From = p1.Pos
            line.To = p2.Pos
            line.Color = color
        else
            line.Visible = false
        end
    end
end

-- [ Killer Listener ]
local function ConnectKiller(killer)
    local hum = killer:WaitForChild("Humanoid", 10)
    local animator = hum and hum:WaitForChild("Animator", 10)
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            if not Config.Enabled then return end
            local id = tostring(track.Animation.AnimationId):match("%d+")
            if Config.AttackAnimations[id] then
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local kRoot = killer:FindFirstChild("HumanoidRootPart")
                if root and kRoot and (root.Position - kRoot.Position).Magnitude <= Config.Range then
                    local btn = GetGuiMob()
                    if btn then firesignal(btn.MouseButton1Down) end
                end
            end
        end)
    end
end

-- [ Killer Scanner ]
task.spawn(function()
    while true do
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Model") and v ~= LocalPlayer.Character and v:FindFirstChild("Lookscriptkiller", true) then
                if KillerModel ~= v then
                    KillerModel = v
                    ConnectKiller(v)
                end
            end
        end
        task.wait(1)
    end
end)

-- [ Fast Performance Loop ]
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        -- Raycast to find actual ground
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        local ray = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), params)
        local groundPos = ray and ray.Position or (root.Position - Vector3.new(0, 3, 0))
        
        -- Check distance for color
        local targetInAttackRange = false
        if KillerModel and KillerModel:FindFirstChild("HumanoidRootPart") then
            if (root.Position - KillerModel.HumanoidRootPart.Position).Magnitude <= Config.Range then
                targetInAttackRange = true
            end
        end
        
        local circleColor = targetInAttackRange and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        Update3DCircle(groundPos, Config.Range, circleColor)
    else
        for _, l in pairs(CircleLines) do l.Visible = false end
    end
end)

-- [ UI System ]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 160)
Main.Position = UDim2.new(0.5, -90, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "HYPERX PARRY V4"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local function CreateToggle(name, prop, pos)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.BackgroundColor3 = Config[prop] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        Config[prop] = not Config[prop]
        btn.BackgroundColor3 = Config[prop] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    end)
end

CreateToggle("Auto Parry", "Enabled", 40)
CreateToggle("Range Visual", "VisualEnabled", 75)

local RangeLabel = Instance.new("TextLabel", Main)
RangeLabel.Size = UDim2.new(1, 0, 0, 20)
RangeLabel.Position = UDim2.new(0, 0, 0, 110)
RangeLabel.Text = "Range: " .. Config.Range
RangeLabel.TextColor3 = Color3.new(1, 1, 1)
RangeLabel.BackgroundTransparency = 1

local RangeSlider = Instance.new("TextButton", Main)
RangeSlider.Size = UDim2.new(0.9, 0, 0, 8)
RangeSlider.Position = UDim2.new(0.05, 0, 0, 135)
RangeSlider.Text = ""
RangeSlider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Instance.new("UICorner", RangeSlider)

local SliderPoint = Instance.new("Frame", RangeSlider)
SliderPoint.Size = UDim2.new(0, 10, 2, 0)
SliderPoint.Position = UDim2.new((Config.Range-1)/31, -5, -0.5, 0)
SliderPoint.BackgroundColor3 = Color3.new(1, 1, 1)

RangeSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local move = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation().X
            local relPos = math.clamp((mousePos - RangeSlider.AbsolutePosition.X) / RangeSlider.AbsoluteSize.X, 0, 1)
            Config.Range = math.floor(1 + (relPos * 31))
            SliderPoint.Position = UDim2.new(relPos, -5, -0.5, 0)
            RangeLabel.Text = "Range: " .. Config.Range
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then move:Disconnect() end
        end)
    end
end)
