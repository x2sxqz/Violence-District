-- [[ HYPER-X AUTO PARRY - WIDE MULTI-RAY V2.3 ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- // Configuration
local Config = {
    Enabled = true,
    Aggressive = false,
    Distance = 8,
    ShowCircle = true,
    CircleColor = Color3.fromRGB(255, 0, 0)
}

-- // Data & Remotes
local State = {
    Cooldown = false,
    Connections = {},
    ParryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Parrying Dagger"):WaitForChild("parry"),
    ResultRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Parrying Dagger"):WaitForChild("parryResult")
}

local ATTACK_ANIMS = {
    ["113255068724446"] = true, ["74968262036854"] = true, ["110355011987939"] = true,
    ["139369275981139"] = true, ["132817836308238"] = true, ["129784271201071"] = true,
    ["133963973694098"] = true, ["117042998468241"] = true, ["105374834496520"] = true,
    ["111920872708571"] = true, ["78432063483146"] = true, ["118907603246885"] = true,
    ["138720291317243"] = true, ["115244153053858"] = true, ["130593238885843"] = true,
    ["122812055447896"] = true, ["78935059863801"] = true, ["135002183282873"] = true,
    ["121216847022485"] = true
}

-- // Updated Threat Logic (7-Ray Wide Fan)
local function IsThreatening(killer, victim, range)
    local kPart = killer.PrimaryPart
    local vPart = victim.PrimaryPart
    if not kPart or not vPart then return false end

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {killer, workspace.CurrentCamera}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    
    -- กาง Ray 7 เส้น ครอบคลุม 180 องศาด้านหน้า Killer (ซ้าย 90 ถึง ขวา 90)
    -- ปรับมุมให้ละเอียดขึ้นเพื่อดักจับ Hitbox ของเราไม่ว่าจะหันหน้าทางไหน
    local angles = {-90, -60, -30, 0, 30, 60, 90} 
    local origin = kPart.Position

    for _, angle in ipairs(angles) do
        -- คำนวณทิศทางจากด้านหน้าของ Killer กระจายออกเป็นพัด
        local direction = (kPart.CFrame * CFrame.Angles(0, math.rad(angle), 0)).LookVector
        
        -- ยิง Ray โดยเพิ่มระยะ Buffer เล็กน้อย
        local rayResult = workspace:Raycast(origin, direction * (range + 3), rayParams)
        
        if rayResult and rayResult.Instance:IsDescendantOf(victim) then
            return true -- Ray ชนตัวเรา (Victim)
        end
    end
    
    return false
end

-- // Core Input
local function PerformInput()
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local mobBtn = playerGui and playerGui:FindFirstChild("Survivor-mob", true) and playerGui["Survivor-mob"]:FindFirstChild("Gui-mob", true)

        if mobBtn and mobBtn.Visible then
            firesignal(mobBtn.MouseButton1Down)
        else
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end
    end)
end

-- // Parry Execution
local function ExecuteParry()
    if State.Cooldown then return end
    State.Cooldown = true
    
    task.spawn(function()
        for i = 1, 10 do 
            State.ParryRemote:FireServer() 
        end
        PerformInput()
    end)
end

-- Server Cooldown Sync
State.ResultRemote.OnClientEvent:Connect(function(_, cd)
    task.delay(tonumber(cd) or 0.8, function() State.Cooldown = false end)
end)

-- // Character Sensor
local function AttachSensor(char)
    if not char or State.Connections[char] then return end
    local hum = char:WaitForChild("Humanoid", 10)
    local animator = hum:WaitForChild("Animator", 10)
    
    State.Connections[char] = animator.AnimationPlayed:Connect(function(track)
        if not Config.Enabled or State.Cooldown then return end
        
        local id = track.Animation.AnimationId:match("%d+")
        if ATTACK_ANIMS[id] then
            local myChar = LocalPlayer.Character
            if not myChar or myChar:GetAttribute("State") == "Downed" then return end
            
            local kRoot = char.PrimaryPart
            local vRoot = myChar.PrimaryPart
            if not kRoot or not vRoot then return end

            local dist = (vRoot.Position - kRoot.Position).Magnitude
            local maxRange = Config.Aggressive and 12 or Config.Distance
            
            -- เงื่อนไข: ระยะถึง -> อยู่ในแนวโจมตี (Multi-Ray) -> Parry
            if dist <= maxRange then
                if IsThreatening(char, myChar, maxRange) then
                    ExecuteParry()
                end
            end
        end
    end)
end

-- // GUI & Visuals
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "HyperX_V2.3"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 195)
Main.Position = UDim2.new(0.5, -110, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 0, 0)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "HYPER-X PARRY V2.3"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.TextSize = 14

local function AddToggle(text, y, flag)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0.9, 0, 0, 35)
    Btn.Position = UDim2.new(0.05, 0, 0, y)
    Btn.BackgroundColor3 = Config[flag] and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    Btn.Text = text .. ": " .. (Config[flag] and "ON" or "OFF")
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Instance.new("UICorner", Btn)

    Btn.MouseButton1Click:Connect(function()
        Config[flag] = not Config[flag]
        Btn.Text = text .. ": " .. (Config[flag] and "ON" or "OFF")
        Btn.BackgroundColor3 = Config[flag] and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    end)
end

AddToggle("Auto Parry", 45, "Enabled")
AddToggle("Aggressive Mode", 90, "Aggressive")
AddToggle("Show Range", 135, "ShowCircle")

local RangeAdorn = Instance.new("CylinderHandleAdornment", ScreenGui)
RangeAdorn.Height = 0.1
RangeAdorn.Color3 = Config.CircleColor
RangeAdorn.Transparency = 0.7

RunService.RenderStepped:Connect(function()
    if Config.ShowCircle and Config.Enabled and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        RangeAdorn.Visible = true
        RangeAdorn.Radius = Config.Aggressive and 12 or Config.Distance
        RangeAdorn.InnerRadius = RangeAdorn.Radius - 0.2
        RangeAdorn.Adornee = workspace.Terrain
        RangeAdorn.CFrame = CFrame.new(LocalPlayer.Character.PrimaryPart.Position - Vector3.new(0, 2.9, 0)) * CFrame.Angles(math.pi/2, 0, 0)
    else
        RangeAdorn.Visible = false
    end
end)

local function Setup(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(AttachSensor)
    if p.Character then AttachSensor(p.Character) end
end

Players.PlayerAdded:Connect(Setup)
for _, p in pairs(Players:GetPlayers()) do Setup(p) end
