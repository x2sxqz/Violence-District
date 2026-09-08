-- [[ HyperX Ultra God-Speed + UI Edition ]] --
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
    Segments = 64,
    PreFireBuffer = 5,
    AttackAnimations = {
        ["139369275981139"] = true, ["121216847022485"] = true, ["78935059863801"] = true,
        ["74968262036854"] = true, ["82666958311998"] = true, ["78432063483146"] = true,
        ["132817836308238"] = true, ["111920872708571"] = true, ["138720291317243"] = true,
        ["130593238885843"] = true, ["106871536134254"] = true, ["109402730355822"] = true
    }
}

-- [ Procedural Visual Circle ]
local Attachments = {}
local Beams = {}
for i = 1, Config.Segments do
    Attachments[i] = Instance.new("Attachment", workspace.Terrain)
    Beams[i] = Instance.new("Beam", workspace.Terrain)
    Beams[i].Width0 = 0.4
    Beams[i].Width1 = 0.4
    Beams[i].FaceCamera = true
    Beams[i].Transparency = NumberSequence.new(0.1)
end

for i = 1, Config.Segments do
    Beams[i].Attachment0 = Attachments[i]
    Beams[i].Attachment1 = Attachments[i == Config.Segments and 1 or i + 1]
end

-- [ Core Logic ]
local function GetParryButton()
    local mob = PlayerGui:FindFirstChild("Survivor-mob")
    return mob and mob:FindFirstChild("Gui-mob", true)
end

local function PerformAction(kRoot)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not kRoot then return end

    -- Snap Face Target ทันที
    root.CFrame = CFrame.lookAt(root.Position, Vector3.new(kRoot.Position.X, root.Position.Y, kRoot.Position.Z))

    -- Burst Fire Parry
    local btn = GetParryButton()
    if btn then
        firesignal(btn.MouseButton1Down)
        task.spawn(function()
            for i = 1, 2 do
                firesignal(btn.MouseButton1Down)
                task.wait()
            end
        end)
    end
end

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
                if root and kRoot and (root.Position - kRoot.Position).Magnitude <= (Config.Range + Config.PreFireBuffer) then
                    PerformAction(kRoot)
                end
            end
        end)
    end
end

local KillerModel = nil
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

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and Config.VisualEnabled then
        local basePos = root.Position - Vector3.new(0, 2.9, 0)
        local inDanger = false
        if KillerModel and KillerModel:FindFirstChild("HumanoidRootPart") then
            if (root.Position - KillerModel.HumanoidRootPart.Position).Magnitude <= Config.Range then
                inDanger = true
            end
        end
        local color = inDanger and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(255, 20, 20)
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

-- [ GUI SYSTEM ]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 180)
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "HYPERX ULTRA V5"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local function CreateToggle(name, prop, pos)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.BackgroundColor3 = Config[prop] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        Config[prop] = not Config[prop]
        btn.BackgroundColor3 = Config[prop] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    end)
end

CreateToggle("Auto Parry", "Enabled", 45)
CreateToggle("Dis Range", "VisualEnabled", 80)

local RangeLabel = Instance.new("TextLabel", Main)
RangeLabel.Size = UDim2.new(1, 0, 0, 20)
RangeLabel.Position = UDim2.new(0, 0, 0, 115)
RangeLabel.Text = "Attack Range: " .. Config.Range
RangeLabel.TextColor3 = Color3.new(1, 1, 1)
RangeLabel.BackgroundTransparency = 1
RangeLabel.Font = Enum.Font.Gotham
RangeLabel.TextSize = 12

local RangeSlider = Instance.new("TextButton", Main)
RangeSlider.Size = UDim2.new(0.8, 0, 0, 4)
RangeSlider.Position = UDim2.new(0.1, 0, 0, 145)
RangeSlider.Text = ""
RangeSlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
RangeSlider.BorderSizePixel = 0

local SliderPoint = Instance.new("Frame", RangeSlider)
SliderPoint.Size = UDim2.new(0, 14, 0, 14)
SliderPoint.AnchorPoint = Vector2.new(0.5, 0.5)
SliderPoint.Position = UDim2.new((Config.Range-5)/25, 0, 0.5, 0)
SliderPoint.BackgroundColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SliderPoint).CornerRadius = UDim.new(1, 0)

RangeSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local move = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation().X
            local relPos = math.clamp((mousePos - RangeSlider.AbsolutePosition.X) / RangeSlider.AbsoluteSize.X, 0, 1)
            Config.Range = math.floor(5 + (relPos * 25))
            SliderPoint.Position = UDim2.new(relPos, 0, 0.5, 0)
            RangeLabel.Text = "Range: " .. Config.Range
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then move:Disconnect() end
        end)
    end
end)
