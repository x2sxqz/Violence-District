-- [[ HyperX Ultra Aggressive Parry - Beam & Face Target Edition ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

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

-- [ Visual Setup: Beam + Attachment ]
local VisualPart = Instance.new("Part")
VisualPart.Name = "HyperX_RangeVisual"
VisualPart.Anchored = true
VisualPart.CanCollide = false
VisualPart.CanTouch = false
VisualPart.Transparency = 1
VisualPart.Size = Vector3.new(1, 1, 1)
VisualPart.Parent = workspace

local Att0 = Instance.new("Attachment", VisualPart)
local Att1 = Instance.new("Attachment", VisualPart)

local RangeBeam = Instance.new("Beam", VisualPart)
RangeBeam.Attachment0 = Att0
RangeBeam.Attachment1 = Att1
RangeBeam.Texture = "rbxassetid://11413804300" -- Circular Texture
RangeBeam.TextureMode = Enum.TextureMode.Static
RangeBeam.FaceCamera = true
RangeBeam.Width0 = Config.Range * 2
RangeBeam.Width1 = Config.Range * 2
RangeBeam.Transparency = NumberSequence.new(0.5)
RangeBeam.LightEmission = 1

-- [ Cache Variables ]
local CachedGuiMob = nil
local KillerModel = nil

local function GetGuiMob()
    if CachedGuiMob and CachedGuiMob.Parent then return CachedGuiMob end
    local mob = PlayerGui:FindFirstChild("Survivor-mob")
    CachedGuiMob = mob and mob:FindFirstChild("Gui-mob", true)
    return CachedGuiMob
end

-- [ Killer Listener & Auto Face ]
local function ConnectKiller(killer)
    local hum = killer:WaitForChild("Humanoid", 10)
    local animator = hum and hum:WaitForChild("Animator", 10)
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            if not Config.Enabled then return end
            local id = tostring(track.Animation.AnimationId):match("%d+")
            if Config.AttackAnimations[id] then
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local kRoot = killer:FindFirstChild("HumanoidRootPart")
                
                if root and kRoot and (root.Position - kRoot.Position).Magnitude <= Config.Range then
                    -- Face Killer Immediately
                    root.CFrame = CFrame.lookAt(root.Position, Vector3.new(kRoot.Position.X, root.Position.Y, kRoot.Position.Z))
                    
                    -- Trigger Parry
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
    
    if root and Config.VisualEnabled then
        -- Update Visual Position
        local groundPos = root.Position - Vector3.new(0, 2.8, 0)
        VisualPart.CFrame = CFrame.new(groundPos) * CFrame.Angles(math.rad(90), 0, 0)
        
        -- Update Beam Range
        RangeBeam.Width0 = Config.Range * 2
        RangeBeam.Width1 = Config.Range * 2
        
        -- Check Range Color
        local targetInAttackRange = false
        if KillerModel and KillerModel:FindFirstChild("HumanoidRootPart") then
            if (root.Position - KillerModel.HumanoidRootPart.Position).Magnitude <= Config.Range then
                targetInAttackRange = true
            end
        end
        
        RangeBeam.Enabled = true
        RangeBeam.Color = ColorSequence.new(targetInAttackRange and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 50, 50))
    else
        RangeBeam.Enabled = false
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
