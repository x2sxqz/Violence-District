-- [[ HyperX Ultra Aggressive Parry - Optimized Face Target & Rapid Trigger ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Config = {
    Enabled = true,
    Range = 12,
    VisualEnabled = true,
    Segments = 24,
    AttackAnimations = {
        ["139369275981139"] = true, ["121216847022485"] = true, ["78935059863801"] = true,
        ["74968262036854"] = true, ["82666958311998"] = true, ["78432063483146"] = true,
        ["132817836308238"] = true, ["111920872708571"] = true, ["138720291317243"] = true,
        ["130593238885843"] = true, ["106871536134254"] = true, ["109402730355822"] = true
    }
}

-- [ Procedural Visual Setup ]
local Attachments = {}
local Beams = {}
for i = 1, Config.Segments do
    Attachments[i] = Instance.new("Attachment", workspace.Terrain)
    Beams[i] = Instance.new("Beam", workspace.Terrain)
    Beams[i].Width0 = 0.3
    Beams[i].Width1 = 0.3
    Beams[i].FaceCamera = true
    Beams[i].Transparency = NumberSequence.new(0.1)
end

for i = 1, Config.Segments do
    Beams[i].Attachment0 = Attachments[i]
    Beams[i].Attachment1 = Attachments[i == Config.Segments and 1 or i + 1]
end

-- [ Functions ]
local function GetGuiMob()
    local mob = PlayerGui:FindFirstChild("Survivor-mob")
    return mob and mob:FindFirstChild("Gui-mob", true)
end

-- [ Killer Logic & Instant Face ]
local KillerModel = nil
local function ConnectKiller(killer)
    local hum = killer:WaitForChild("Humanoid", 10)
    local animator = hum and hum:WaitForChild("Animator", 10)
    
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            if not Config.Enabled then return end
            
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            if Config.AttackAnimations[animId] then
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local kRoot = killer:FindFirstChild("HumanoidRootPart")
                
                if root and kRoot then
                    local dist = (root.Position - kRoot.Position).Magnitude
                    if dist <= Config.Range + 3 then
                        -- [ Force Face Killer ]
                        local targetPos = Vector3.new(kRoot.Position.X, root.Position.Y, kRoot.Position.Z)
                        root.CFrame = CFrame.lookAt(root.Position, targetPos)
                        
                        -- [ Rapid Trigger to Beat Latency ]
                        local btn = GetGuiMob()
                        if btn then
                            firesignal(btn.MouseButton1Down)
                            task.wait() -- Smallest delay
                            firesignal(btn.MouseButton1Down)
                        end
                    end
                end
            end
        end)
    end
end

-- [ Scanner ]
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
        task.wait(0.3)
    end
end)

-- [ Loop Update ]
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root and Config.VisualEnabled then
        local basePos = root.Position - Vector3.new(0, 2.9, 0)
        local isTargeting = false
        
        if KillerModel and KillerModel:FindFirstChild("HumanoidRootPart") then
            if (root.Position - KillerModel.HumanoidRootPart.Position).Magnitude <= Config.Range then
                isTargeting = true
            end
        end
        
        local color = isTargeting and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 40, 40)
        
        for i = 1, Config.Segments do
            local angle = (i - 1) * (math.pi * 2 / Config.Segments)
            local offset = Vector3.new(math.cos(angle) * Config.Range, 0, math.sin(angle) * Config.Range)
            Attachments[i].Position = basePos + offset
            Beams[i].Enabled = true
            Beams[i].Color = ColorSequence.new(color)
        end
    else
        for i = 1, Config.Segments do Beams[i].Enabled = false end
    end
end)

-- [ Simplified UI ]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 160)
Main.Position = UDim2.new(0.5, -90, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local function CreateToggle(name, prop, pos)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.BackgroundColor3 = Config[prop] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        Config[prop] = not Config[prop]
        btn.BackgroundColor3 = Config[prop] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    end)
end

CreateToggle("Auto Parry", "Enabled", 40)
CreateToggle("Show Circle", "VisualEnabled", 75)

local RangeLabel = Instance.new("TextLabel", Main)
RangeLabel.Size = UDim2.new(1, 0, 0, 20)
RangeLabel.Position = UDim2.new(0, 0, 0, 110)
RangeLabel.Text = "Range: " .. Config.Range
RangeLabel.TextColor3 = Color3.new(1, 1, 1)
RangeLabel.BackgroundTransparency = 1
RangeLabel.Font = Enum.Font.Gotham

local RangeSlider = Instance.new("TextButton", Main)
RangeSlider.Size = UDim2.new(0.9, 0, 0, 6)
RangeSlider.Position = UDim2.new(0.05, 0, 0, 135)
RangeSlider.Text = ""
RangeSlider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Instance.new("UICorner", RangeSlider)

local SliderPoint = Instance.new("Frame", RangeSlider)
SliderPoint.Size = UDim2.new(0, 12, 0, 12)
SliderPoint.AnchorPoint = Vector2.new(0.5, 0.5)
SliderPoint.Position = UDim2.new((Config.Range-1)/34, 0, 0.5, 0)
SliderPoint.BackgroundColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SliderPoint).CornerRadius = UDim.new(1, 0)

RangeSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local move = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation().X
            local relPos = math.clamp((mousePos - RangeSlider.AbsolutePosition.X) / RangeSlider.AbsoluteSize.X, 0, 1)
            Config.Range = math.floor(1 + (relPos * 34))
            SliderPoint.Position = UDim2.new(relPos, 0, 0.5, 0)
            RangeLabel.Text = "Range: " .. Config.Range
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then move:Disconnect() end
        end)
    end
end)
