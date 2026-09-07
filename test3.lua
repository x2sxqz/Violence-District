-- [[ HyperX Ultra Fast Auto Parry - Optimized Range 8 ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Config = {
    Enabled = true,
    Range = 8, -- ปรับตามคำขอ (Default: 8)
    VisualEnabled = true,
    AttackAnimations = {
        ["139369275981139"] = true, ["121216847022485"] = true, ["78935059863801"] = true,
        ["74968262036854"] = true, ["82666958311998"] = true, ["78432063483146"] = true,
        ["132817836308238"] = true, ["111920872708571"] = true, ["138720291317243"] = true,
        ["130593238885843"] = true, ["106871536134254"] = true, ["109402730355822"] = true
    }
}

-- [ Optimization: Cache ]
local KillerModel = nil
local CachedGuiMob = nil

local function GetGuiMob()
    if CachedGuiMob and CachedGuiMob.Parent then return CachedGuiMob end
    local survivorMob = PlayerGui:FindFirstChild("Survivor-mob")
    local guiMob = survivorMob and survivorMob:FindFirstChild("Gui-mob", true)
    if guiMob then CachedGuiMob = guiMob end
    return guiMob
end

local function FindKiller()
    if KillerModel and KillerModel.Parent then return KillerModel end
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and v ~= LocalPlayer.Character then
            if v:FindFirstChild("Lookscriptkiller", true) then
                KillerModel = v
                return v
            end
        end
    end
    return nil
end

-- [ Visual Ring - Super Slim & Glow ]
local Ring = Instance.new("Part", workspace)
Ring.Name = "HyperX_SlimRing"
Ring.Anchored = true
Ring.CanCollide = false
Ring.Material = Enum.Material.Neon
Ring.Transparency = 0.2
Ring.Size = Vector3.new(1, 1, 1)

local RingMesh = Instance.new("SpecialMesh", Ring)
RingMesh.MeshId = "rbxassetid://3270017"
RingMesh.Scale = Vector3.new(Config.Range * 2, Config.Range * 2, 0.01) -- แก้ความหนาตรงนี้

-- [ Fast Detection ]
local function SetupDetection(killer)
    local hum = killer:WaitForChild("Humanoid", 10)
    local animator = hum and hum:WaitForChild("Animator", 10)
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            if not Config.Enabled then return end
            local id = tostring(track.Animation.AnimationId):match("%d+")
            if Config.AttackAnimations[id] then
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local kRoot = killer:FindFirstChild("HumanoidRootPart")
                if root and kRoot then
                    local dist = (root.Position - kRoot.Position).Magnitude
                    if dist <= Config.Range then
                        local guiMob = GetGuiMob()
                        if guiMob then firesignal(guiMob.MouseButton1Down) end
                    end
                end
            end
        end)
    end
end

-- Monitor Killer Character
task.spawn(function()
    while task.wait(1) do
        local killer = FindKiller()
        if killer then SetupDetection(killer) end
    end
end)

-- Main Visual Loop
RunService.RenderStepped:Connect(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and Config.VisualEnabled then
        Ring.Transparency = 0.2
        Ring.Position = root.Position - Vector3.new(0, 2.95, 0)
        Ring.CFrame = CFrame.new(Ring.Position) * CFrame.Angles(math.rad(90), 0, 0)
        RingMesh.Scale = Vector3.new(Config.Range * 2, Config.Range * 2, 0.001)
        
        local killer = FindKiller()
        if killer and killer:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - killer.HumanoidRootPart.Position).Magnitude
            Ring.Color = dist <= Config.Range and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 30, 30)
        end
    else
        Ring.Transparency = 1
    end
end)

-- UI System
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 160)
Main.Position = UDim2.new(0.5, -90, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "HYPERX PARRY V8"
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
CreateToggle("Glow Range", "VisualEnabled", 75)

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
