-- [[ AUTO KILL ALL - NO NIL VERSION ]]

-- 1. ล้าง Error Line 1 ด้วยการรอโหลด (Safety Wait)
if not game:IsLoaded() then game.Loaded:Wait() end

-- 2. ประกาศ Services แบบปลอดภัย
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 3. ตัวแปรหลัก (ดัก Nil)
local LP = Players.LocalPlayer
while not LP do task.wait() LP = Players.LocalPlayer end

local KillActive = false

-- 4. ฟังก์ชันเช็คเป้าหมาย (Strict Validation)
local function GetValidTarget()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closest, shortest = nil, 250 -- ระยะสูงสุดที่ต้องการ

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Team and p.Team.Name == "Survivors" then
            local c = p.Character
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local hum = c:FindFirstChildOfClass("Humanoid")
            
            -- เช็คสถานะดาเมจ (Attributes)
            local isHooked = c:GetAttribute("IsHooked") == true
            local isDowned = c:GetAttribute("IsDown") == true or c:GetAttribute("Knocked") == true
            
            if hrp and hum and hum.Health > 0 and not isHooked and not isDowned then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = c
                end
            end
        end
    end
    return closest
end

-- 5. สร้าง GUI (Draggable)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FinalKillAll"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 140, 0, 45)
Frame.Position = UDim2.new(0.5, -70, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true
Frame.Draggable = true -- ระบบลากมาตรฐาน
Frame.Parent = ScreenGui

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 50, 50)
Stroke.Thickness = 2
Stroke.Parent = Frame

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(1, 0, 1, 0)
Btn.BackgroundTransparency = 1
Btn.Text = "AUTO KILL: OFF"
Btn.TextColor3 = Color3.fromRGB(255, 50, 50)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 13
Btn.Parent = Frame

-- 6. ระบบ Toggle
Btn.MouseButton1Click:Connect(function()
    KillActive = not KillActive
    Btn.Text = KillActive and "AUTO KILL: ON" or "AUTO KILL: OFF"
    Btn.TextColor3 = KillActive and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 50, 50)
    Stroke.Color = KillActive and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 50, 50)
end)

-- 7. Main Loop (ดัก Nil ทุกลมหายใจ)
RunService.Heartbeat:Connect(function()
    if not KillActive then return end
    
    -- เช็คทีม (กัน Nil)
    local myTeam = LP.Team
    if not myTeam or myTeam.Name ~= "Killer" then return end
    
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local target = GetValidTarget()
    if target then
        local tRoot = target:FindFirstChild("HumanoidRootPart")
        if tRoot then
            -- วาร์ป
            local vel = tRoot.AssemblyLinearVelocity * 0.12
            local behind = tRoot.CFrame * CFrame.new(0, 0, 2.5)
            myRoot.CFrame = CFrame.new(behind.Position + vel, tRoot.Position)
            
            -- ค้นหา Remote (ดัก Nil 100%)
            local Remote = ReplicatedStorage:FindFirstChild("BasicAttack", true)
            if Remote and Remote:IsA("RemoteEvent") then
                pcall(function()
                    Remote:FireServer(false)
                end)
            end
        end
    end
end)
