-- [[ HyperX Ultra Fast Auto Parry - Hollow Ring Update ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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

-- Caching Gui
local CachedGuiMob = nil
local function GetGuiMob()
    if CachedGuiMob and CachedGuiMob.Parent then return CachedGuiMob end
    local survivorMob = PlayerGui:FindFirstChild("Survivor-mob")
    local guiMob = survivorMob and survivorMob:FindFirstChild("Gui-mob", true)
    if guiMob then CachedGuiMob = guiMob end
    return guiMob
end

-- // Optimized Hollow Ring Visual
local Ring = Instance.new("Part")
Ring.Name = "ParryRangeVisual"
Ring.Anchored = true
Ring.CanCollide = false
Ring.CastShadow = false
Ring.Transparency = 0.5
Ring.Material = Enum.Material.Neon
Ring.Size = Vector3.new(1, 1, 1)
Ring.Parent = workspace

local RingMesh = Instance.new("SpecialMesh", Ring)
RingMesh.MeshId = "rbxassetid://3270017" -- Torus Mesh (Hollow Ring)
RingMesh.Scale = Vector3.new(Config.Range * 2, Config.Range * 2, 0.5)

-- Core Logic
RunService.RenderStepped:Connect(function()
    if not Config.Enabled or not LocalPlayer.Character then 
        Ring.Transparency = 1
        return 
    end
    
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Update Ring Visual
    Ring.Transparency = Config.VisualEnabled and 0.2 or 1
    Ring.Position = root.Position - Vector3.new(0, 2.9, 0)
    Ring.CFrame = CFrame.new(Ring.Position) * CFrame.Angles(math.rad(90), 0, 0)
    RingMesh.Scale = Vector3.new(Config.Range * 2, Config.Range * 2, 0.1) -- ความหนาของเส้นปรับที่แกน Z

    local guiMob = GetGuiMob()
    local targetInAttack = false

    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and v ~= LocalPlayer.Character and v:FindFirstChild("Lookscriptkiller", true) then
            local kRoot = v:FindFirstChild("HumanoidRootPart")
            local kHum = v:FindFirstChildOfClass("Humanoid")
            
            if kRoot and kHum then
                local dist = (root.Position - kRoot.Position).Magnitude
                if dist <= Config.Range then
                    local animator = kHum:FindFirstChildOfClass("Animator")
                    if animator then
                        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                            local id = tostring(track.Animation.AnimationId):match("%d+")
                            if Config.AttackAnimations[id] then
                                targetInAttack = true
                                if guiMob and firesignal then
                                    firesignal(guiMob.MouseButton1Down)
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    Ring.Color = targetInAttack and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

-- UI System
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 180)
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "HYPERX FAST PARRY"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local function CreateToggle(name, default, pos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.BackgroundColor3 = default and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    btn.Text = name .. (default and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        local state = not (btn.BackgroundColor3 == Color3.fromRGB(46, 204, 113))
        btn.BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        btn.Text = name .. (state and ": ON" or ": OFF")
        callback(state)
    end)
end

CreateToggle("Auto Parry", true, 40, function(v) Config.Enabled = v end)
CreateToggle("Visual Range", true, 75, function(v) Config.VisualEnabled = v end)

local RangeLabel = Instance.new("TextLabel", Main)
RangeLabel.Size = UDim2.new(1, 0, 0, 20)
RangeLabel.Position = UDim2.new(0, 0, 0, 110)
RangeLabel.Text = "Range: " .. Config.Range
RangeLabel.TextColor3 = Color3.new(1, 1, 1)
RangeLabel.BackgroundTransparency = 1

local RangeSlider = Instance.new("TextButton", Main)
RangeSlider.Size = UDim2.new(0.9, 0, 0, 10)
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
