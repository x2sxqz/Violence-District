-- ============== AUTO KILL ALL : HYPER-STABLE EDITION ==============

-- [ 1. SERVICES ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ 2. CORE VARIABLES ]
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local KillActive = false

-- [ 3. SAFETY REMOTE CHECK ]
-- ใช้การหาแบบ Recursive และวนลูปจนกว่าจะเจอ เพื่อป้องกัน Nil Error
local AttackEvent = nil
task.spawn(function()
    while not AttackEvent do
        AttackEvent = ReplicatedStorage:FindFirstChild("BasicAttack", true)
        if not AttackEvent then
            -- ลองหาตาม Path ตรงหากหาแบบอัตโนมัติไม่เจอ
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local attacks = remotes and remotes:FindFirstChild("Attacks")
            AttackEvent = attacks and attacks:FindFirstChild("BasicAttack")
        end
        task.wait(1)
    end
end)

-- [ 4. TARGETING SYSTEM (ANTI-NIL) ]
local function IsValidTarget(char)
    if not char or not char:Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local plr = Players:GetPlayerFromCharacter(char)
    -- เช็ค Team แบบกัน Nil (ถ้าไม่มีทีมจะไม่ Error)
    if not plr or not plr.Team or plr.Team.Name ~= "Survivors" then return false end
    
    -- เช็ค Attributes (กันคนล้ม/คนโดนแขวน)
    local isHooked = char:GetAttribute("IsHooked") == true
    local isDowned = char:GetAttribute("IsDown") == true or char:GetAttribute("Knocked") == true
    
    return not (isHooked or isDowned)
end

local function GetTarget()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and IsValidTarget(plr.Character) then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = plr.Character
                end
            end
        end
    end
    return closest
end

-- [ 5. DRAGGABLE UI (STABLE) ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HyperX_StableKill"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 50)
MainFrame.Position = UDim2.new(0.5, -75, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner", MainFrame)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(255, 50, 50)
Stroke.Thickness = 2

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Text = "KILL ALL: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

-- ระบบลาก UI (Drag Logic)
local dragToggle, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) dragToggle = false end)

-- [ 6. MAIN EXECUTION LOOP ]
ToggleBtn.MouseButton1Click:Connect(function()
    KillActive = not KillActive
    ToggleBtn.Text = KillActive and "KILL ALL: ON" or "KILL ALL: OFF"
    local color = KillActive and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 50, 50)
    ToggleBtn.TextColor3 = color
    Stroke.Color = color
end)

RunService.Heartbeat:Connect(function()
    if not KillActive then return end
    
    -- เช็ค Team ความปลอดภัยสูง
    local myTeam = LocalPlayer.Team
    if not myTeam or myTeam.Name ~= "Killer" then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local target = GetTarget()
    if target then
        local tHRP = target:FindFirstChild("HumanoidRootPart")
        if tHRP then
            -- Prediction + Position Backstab
            local vel = tHRP.AssemblyLinearVelocity * 0.12
            local targetPos = tHRP.CFrame * CFrame.new(0, 0, 2.5)
            
            root.CFrame = CFrame.new(targetPos.Position + vel, tHRP.Position)
            
            -- โจมตี (เช็ค AttackEvent ว่ามีค่าหรือไม่ก่อนเรียกใช้)
            if AttackEvent then
                pcall(function()
                    AttackEvent:FireServer(false)
                end)
            end
        end
    end
end)
