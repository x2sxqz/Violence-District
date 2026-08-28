-- [[ FIX LINE 1: ZERO-NIL STARTUP ]]
task.wait(0.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- รอจนกว่า LocalPlayer และ PlayerGui จะมีตัวตนจริง
local LP = Players.LocalPlayer
while not LP do
    task.wait(0.1)
    LP = Players.LocalPlayer
end

local PGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 10)
if not PGui then return end -- ป้องกัน Error หากหา PlayerGui ไม่เจอ

-- [ ตัวแปรหลัก ]
local KillActive = false
local AttackEvent = nil

-- [ ฟังก์ชันเช็คเป้าหมาย ]
local function GetValidTarget()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closest, shortest = nil, 300
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Team and p.Team.Name == "Survivors" and p.Character then
            local targetChar = p.Character
            local tRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local tHum = targetChar:FindFirstChildOfClass("Humanoid")
            
            local invalid = targetChar:GetAttribute("IsHooked") or targetChar:GetAttribute("IsDown") or targetChar:GetAttribute("Knocked")

            if tRoot and tHum and tHum.Health > 0 and not invalid then
                local mag = (tRoot.Position - root.Position).Magnitude
                if mag < shortest then
                    shortest = mag
                    closest = targetChar
                end
            end
        end
    end
    return closest
end

-- [ การสร้าง UI แบบปลอดภัย 100% ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillAll_Final_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 140, 0, 45)
Main.Position = UDim2.new(0.5, -70, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true 
Main.Parent = ScreenGui

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 60, 60)
Stroke.Thickness = 2
Stroke.Parent = Main

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Main

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(1, 0, 1, 0)
Btn.BackgroundTransparency = 1
Btn.Text = "AUTO KILL: OFF"
Btn.TextColor3 = Color3.fromRGB(255, 60, 60)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 13
Btn.Parent = Main

-- [ ระบบ Toggle ]
Btn.MouseButton1Click:Connect(function()
    KillActive = not KillActive
    Btn.Text = KillActive and "AUTO KILL: ON" or "AUTO KILL: OFF"
    local color = KillActive and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 60, 60)
    Btn.TextColor3 = color
    Stroke.Color = color
end)

-- [ MAIN LOOP ]
RunService.Heartbeat:Connect(function()
    if not KillActive then return end
    
    -- เช็คทีม Killer
    local myTeam = LP.Team
    if not myTeam or myTeam.Name ~= "Killer" then return end
    
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local targetChar = GetValidTarget()
    if targetChar then
        local tRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if tRoot then
            -- ค้นหา Remote แบบกัน Nil
            if not AttackEvent then
                AttackEvent = ReplicatedStorage:FindFirstChild("BasicAttack", true)
            end

            -- วาร์ป + โจมตี
            local vel = tRoot.AssemblyLinearVelocity * 0.12
            local pos = tRoot.CFrame * CFrame.new(0, 0, 2.5)
            myRoot.CFrame = CFrame.new(pos.Position + vel, tRoot.Position)
            
            if AttackEvent and AttackEvent:IsA("RemoteEvent") then
                pcall(function() AttackEvent:FireServer(false) end)
            end
        end
    end
end)
