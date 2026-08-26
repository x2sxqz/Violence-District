--1
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- SETTINGS
local AutoParryEnabled = false
local ParryRadius = 15
local ParryFaceSensitivity = 0.7 -- 0.1 to 1.0

local VALID_PARRY_IDS = {
    ["122812055447896"] = "Veil lunge", ["133963973694098"] = "Mayers Basic",
    ["117042998468241"] = "Mayers lunge", ["135002183282873"] = "cure lunge",
    ["121216847022485"] = "cure Basic", ["132817836308238"] = "Jeff Basic",
    ["129784271201071"] = "Jeff lunge", ["82666958311998"] = "Jeff Frenzy",
    ["78432063483146"] = "Abyssal Basic", ["118907603246885"] = "Abyssal lunge",
    ["139369275981139"] = "Jason Basic", ["110355011987939"] = "Jason lunge",
    ["111920872708571"] = "Masked Basic", ["105374834496520"] = "Masked lunge",
    ["138720291317243"] = "Masked Tony", ["106871536134254"] = "Masked Alex",
    ["130593238885843"] = "Masked Cobra", ["115244153053858"] = "Masked Cobra lunge",
    ["74968262036854"] = "Hidden Basic", ["113255068724446"] = "Hidden lunge",
    ["98163597193511"] = "Hidden S1", ["80411309607666"] = "Abyssal S1"
}

local ParryState = { Cooldown = false, Attached = {} }

-- FUNCTIONS
local function ExecuteParry()
    if ParryState.Cooldown then return end
    pcall(function()
        local parryRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
        if parryRemote then
            for i = 1, 5 do parryRemote:FireServer() end
        end
        -- Simulating Button Press
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    end)
end

local function AttachParrySensor(kChar)
    if not kChar or ParryState.Attached[kChar] then return end
    local animator = kChar:WaitForChild("Humanoid"):WaitForChild("Animator")
    ParryState.Attached[kChar] = true

    animator.AnimationPlayed:Connect(function(track)
        if not AutoParryEnabled or ParryState.Cooldown then return end
        local id = track.Animation.AnimationId:match("%d+")
        if not VALID_PARRY_IDS[id] then return end

        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end

        local dist = (myHRP.Position - kHRP.Position).Magnitude
        if dist <= ParryRadius then
            -- Facing Check
            local dot = kHRP.CFrame.LookVector:Dot((myHRP.Position - kHRP.Position).Unit)
            if dot >= ParryFaceSensitivity then
                ExecuteParry()
            end
        end
    end)
end

-- UI CREATION (DRAGGABLE BUTTON)
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "AutoParryToggleUI"

local MainButton = Instance.new("TextButton", ScreenGui)
MainButton.Size = UDim2.new(0, 120, 0, 40)
MainButton.Position = UDim2.new(0.5, -60, 0.5, -20)
MainButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
MainButton.Text = "Auto Parry: OFF"
MainButton.TextColor3 = Color3.new(1, 1, 1)
MainButton.Font = Enum.Font.GothamBold
MainButton.TextSize = 14
MainButton.AutoButtonColor = true

local UICorner = Instance.new("UICorner", MainButton)
UICorner.CornerRadius = UDim.new(0, 8)

-- DRAGGING LOGIC
local dragging, dragInput, dragStart, startPos
MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainButton.Position
    end
end)

MainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- TOGGLE LOGIC
MainButton.MouseButton1Click:Connect(function()
    AutoParryEnabled = not AutoParryEnabled
    if AutoParryEnabled then
        MainButton.Text = "Auto Parry: ON"
        MainButton.BackgroundColor3 = Color3.fromRGB(60, 255, 120)
    else
        MainButton.Text = "Auto Parry: OFF"
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    end
end)

-- INITIALIZE SENSOR
local function SetupKillers()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Team and p.Team.Name == "Killer" and p.Character then
            AttachParrySensor(p.Character)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(1)
        if p.Team and p.Team.Name == "Killer" then AttachParrySensor(char) end
    end)
end)

RunService.Heartbeat:Connect(SetupKillers)
