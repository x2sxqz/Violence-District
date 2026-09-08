-- [[ AUTO PARRY STANDALONE - BY HYPERX ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local Config = {
    Enabled = true,
    Aggressive = false,
    Distance = 8,
    ShowCircle = true,
    CircleColor = Color3.fromRGB(255, 0, 0)
}

-- Animation IDs to Parry
local ATTACK_ANIMS = {
    ["113255068724446"] = true, ["74968262036854"] = true, ["110355011987939"] = true,
    ["139369275981139"] = true, ["132817836308238"] = true, ["129784271201071"] = true,
    ["133963973694098"] = true, ["117042998468241"] = true, ["105374834496520"] = true,
    ["111920872708571"] = true, ["78432063483146"] = true, ["118907603246885"] = true,
    ["138720291317243"] = true, ["115244153053858"] = true, ["130593238885843"] = true,
    ["122812055447896"] = true, ["78935059863801"] = true, ["135002183282873"] = true,
    ["121216847022485"] = true
}

-- Internal State
local ParryState = { Cooldown = false, Attached = {} }

-- UI Creation
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "HyperX_ParryGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 180)
MainFrame.Position = UDim2.new(0.5, -100, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "HYPER-X PARRY"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Font = Enum.Font.GothamBold

-- Toggle Helper
local function CreateToggle(name, pos, flag)
    local Btn = Instance.new("TextButton", MainFrame)
    Btn.Size = UDim2.new(0.9, 0, 0, 30)
    Btn.Position = pos
    Btn.Text = name .. ": " .. (Config[flag] and "ON" or "OFF")
    Btn.BackgroundColor3 = Config[flag] and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", Btn)
    
    Btn.MouseButton1Click:Connect(function()
        Config[flag] = not Config[flag]
        Btn.Text = name .. ": " .. (Config[flag] and "ON" or "OFF")
        Btn.BackgroundColor3 = Config[flag] and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    end)
end

CreateToggle("Auto Parry", UDim2.new(0.05, 0, 0, 40), "Enabled")
CreateToggle("Aggressive", UDim2.new(0.05, 0, 0, 75), "Aggressive")
CreateToggle("Show Range", UDim2.new(0.05, 0, 0, 110), "ShowCircle")

-- Range Circle
local RangeAdorn = Instance.new("CylinderHandleAdornment", ScreenGui)
RangeAdorn.Height = 0.1
RangeAdorn.Color3 = Config.CircleColor
RangeAdorn.Transparency = 0.5
RangeAdorn.AlwaysOnTop = false

-- Core Functions
local function ExecuteParry()
    if ParryState.Cooldown then return end
    pcall(function()
        local remote = ReplicatedStorage.Remotes.Items["Parrying Dagger"].parry
        for i=1, 5 do remote:FireServer() end
        -- Mobile Tap Simulation
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    end)
    ParryState.Cooldown = true
    task.delay(0.8, function() ParryState.Cooldown = false end) -- Anti-spam cd
end

local function AttachSensor(char)
    if not char or ParryState.Attached[char] then return end
    local anim = char:WaitForChild("Humanoid", 5):WaitForChild("Animator", 5)
    ParryState.Attached[char] = anim.AnimationPlayed:Connect(function(track)
        if not Config.Enabled then return end
        local id = track.Animation.AnimationId:match("%d+")
        if ATTACK_ANIMS[id] or ATTACK_ANIMS["rbxassetid://"..id] then
            local myChar = LocalPlayer.Character
            if not myChar or myChar:GetAttribute("State") == "Downed" then return end
            
            local dist = (myChar.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude
            if Config.Aggressive and dist <= 12 then
                ExecuteParry()
            elseif dist <= Config.Distance then
                ExecuteParry()
            end
        end
    end)
end

-- Monitor Players
local function SetupPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(AttachSensor)
    if p.Character then AttachSensor(p.Character) end
end

Players.PlayerAdded:Connect(SetupPlayer)
for _, p in pairs(Players:GetPlayers()) do SetupPlayer(p) end

-- Rendering Loop
RunService.RenderStepped:Connect(function()
    if Config.ShowCircle and Config.Enabled and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        RangeAdorn.Visible = true
        RangeAdorn.Radius = Config.Distance
        RangeAdorn.InnerRadius = Config.Distance - 0.2
        RangeAdorn.Adornee = workspace.Terrain
        RangeAdorn.CFrame = CFrame.new(LocalPlayer.Character.PrimaryPart.Position - Vector3.new(0, 2.9, 0)) * CFrame.Angles(math.pi/2, 0, 0)
    else
        RangeAdorn.Visible = false
    end
end)
