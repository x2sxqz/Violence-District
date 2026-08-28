-- [[ 1. REQUIRED SERVICES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [[ 2. VARIABLES & SAFETY ]]
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local KillActive = false

-- ค้นหา Remote โจมตี (กัน Error กรณี Path เปลี่ยน)
local AttackEvent = ReplicatedStorage:FindFirstChild("BasicAttack", true) 
-- หากหาแบบอัตโนมัติไม่เจอ ให้ใช้ Path ตรง
if not AttackEvent then
    AttackEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
end

-- [[ 3. TARGETING FUNCTIONS ]]
local function IsValid(char)
    if not char or not char:Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    -- เช็คทีม (เฉพาะ Survivor)
    local plr = Players:GetPlayerFromCharacter(char)
    if not plr or not plr.Team or plr.Team.Name ~= "Survivors" then return false end
    
    -- เช็คสถานะ อมตะ/ล้ม/โดนแขวน
    local hooked = char:GetAttribute("IsHooked") == true
    local downed = char:GetAttribute("IsDown") == true or char:GetAttribute("Knocked") == true
    
    return not (hooked or downed)
end

local function GetTarget()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and IsValid(plr.Character) then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - myRoot.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = plr.Character
                end
            end
        end
    end
    return closest
end

-- [[ 4. DRAGGABLE UI ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillAll_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 140, 0, 45)
MainFrame.Position = UDim2.new(0.5, -70, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 50, 50)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Text = "KILL ALL: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 13
ToggleBtn.Parent = MainFrame

-- ระบบลาก UI แบบเสถียร
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
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)

-- [[ 5. MAIN LOGIC ]]
ToggleBtn.MouseButton1Click:Connect(function()
    KillActive = not KillActive
    ToggleBtn.Text = KillActive and "KILL ALL: ON" or "KILL ALL: OFF"
    ToggleBtn.TextColor3 = KillActive and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 50, 50)
    UIStroke.Color = KillActive and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 50, 50)
end)

RunService.Heartbeat:Connect(function()
    if not KillActive then return end
    
    -- ต้องอยู่ทีม Killer
    if not (LocalPlayer.Team and LocalPlayer.Team.Name == "Killer") then return end
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local target = GetTarget()
    if target then
        local tHRP = target:FindFirstChild("HumanoidRootPart")
        if tHRP then
            -- วาร์ปไปข้างหลัง 2.5 studs + Prediction
            local vel = tHRP.AssemblyLinearVelocity * 0.12
            local pos = tHRP.CFrame * CFrame.new(0, 0, 2.5)
            
            myRoot.CFrame = CFrame.new(pos.Position + vel, tHRP.Position)
            
            -- โจมตี (ใช้ pcall กัน Error กรณี Remote โดนดัก)
            pcall(function()
                AttackEvent:FireServer(false)
            end)
        end
    end
end)
