-- [[ AUTO KILL ALL - TWEEN VERSION ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- [ CONFIG ]
local TweenSpeed = 150 -- ความเร็วในการ Tween (ยิ่งเยอะยิ่งเร็ว)
local KillActive = false

-- [ TARGETING ]
local function GetBestTarget()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closest = nil
    local shortest = math.huge -- ไม่จำกัดระยะ

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Team and p.Team.Name == "Survivors" and p.Character then
            local c = p.Character
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local hum = c:FindFirstChildOfClass("Humanoid")
            
            -- เช็คสถานะ (Attributes) ข้ามคนล้ม/แขวน
            local invalid = c:GetAttribute("IsHooked") or c:GetAttribute("IsDown") or c:GetAttribute("Knocked")
            
            if hrp and hum and hum.Health > 0 and not invalid then
                local mag = (hrp.Position - root.Position).Magnitude
                if mag < shortest then
                    shortest = mag
                    closest = c
                end
            end
        end
    end
    return closest
end

-- [ GUI SETUP ]
local ScreenGui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
ScreenGui.Name = "TweenKillAll"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 150, 0, 50)
Main.Position = UDim2.new(0.5, -75, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Active = true
Main.Draggable = true

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 100, 0)
Stroke.Thickness = 2

local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(1, 0, 1, 0)
Btn.BackgroundTransparency = 1
Btn.Text = "TWEEN KILL: OFF"
Btn.TextColor3 = Color3.fromRGB(255, 100, 0)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 13

-- [ TWEEN LOGIC ]
local currentTween = nil

local function MoveToTarget(targetPart)
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local distance = (myRoot.Position - targetPart.Position).Magnitude
    local duration = distance / TweenSpeed
    
    -- วาร์ปไปตำแหน่งหลังเป้าหมาย 2.5 studs
    local targetPos = targetPart.CFrame * CFrame.new(0, 0, 2.5)

    if currentTween then currentTween:Cancel() end

    currentTween = TweenService:Create(myRoot, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetPos})
    currentTween:Play()
    return duration
end

-- [ TOGGLE ]
Btn.MouseButton1Click:Connect(function()
    KillActive = not KillActive
    Btn.Text = KillActive and "TWEEN KILL: ON" or "TWEEN KILL: OFF"
    local theme = KillActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 0)
    Btn.TextColor3 = theme
    Stroke.Color = theme
    if not KillActive and currentTween then currentTween:Cancel() end
end)

-- [ MAIN LOOP ]
task.spawn(function()
    while task.wait() do
        if KillActive then
            -- เช็คทีม
            if LP.Team and LP.Team.Name == "Killer" then
                local targetChar = GetBestTarget()
                if targetChar then
                    local tRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        -- เริ่ม Tween
                        MoveToTarget(tRoot)
                        
                        -- โจมตีระว่าง Tween
                        local Remote = ReplicatedStorage:FindFirstChild("BasicAttack", true)
                        if Remote and (LP.Character.HumanoidRootPart.Position - tRoot.Position).Magnitude < 10 then
                            pcall(function() Remote:FireServer(false) end)
                        end
                    end
                end
            end
        end
    end
end)
