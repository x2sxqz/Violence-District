-- ============== AUTO KILL ALL : FINAL FIXED (NO NIL ERROR) ==============

-- [ 1. ALL REQUIRED SERVICES ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ 2. CORE VARIABLES ]
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local KillActive = false

-- [ 3. STABLE TARGETING FUNCTION ]
local function GetValidTarget()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local closest, shortest = nil, math.huge
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Team and plr.Team.Name == "Survivors" then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            -- เช็คสถานะดาเมจ (Attributes)
            local isHooked = char:GetAttribute("IsHooked") == true
            local isDowned = char:GetAttribute("IsDown") == true or char:GetAttribute("Knocked") == true
            
            if hum and hrp and hum.Health > 0 and not isHooked and not isDowned then
                local dist = (hrp.Position - myRoot.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = char
                end
            end
        end
    end
    return closest
end

-- [ 4. DRAGGABLE UI CONSTRUCTION ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HyperX_KillFix"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 50)
MainFrame.Position = UDim2.new(0.5, -75, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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

-- ระบบลาก (Draggable)
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

-- [ 5. TOGGLE LOGIC ]
ToggleBtn.MouseButton1Click:Connect(function()
    KillActive = not KillActive
    ToggleBtn.Text = KillActive and "KILL ALL: ON" or "KILL ALL: OFF"
    local color = KillActive and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 60, 60)
    ToggleBtn.TextColor3 = color
    Stroke.Color = color
end)

-- [ 6. MAIN HEARTBEAT LOOP (NO ERROR EDITION) ]
RunService.Heartbeat:Connect(function()
    if not KillActive then return end
    
    -- 1. เช็คทีม (ป้องกัน Nil)
    local myTeam = LocalPlayer.Team
    if not myTeam or myTeam.Name ~= "Killer" then return end
    
    -- 2. เช็คตัวละครเรา
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- 3. ค้นหาเป้าหมาย
    local target = GetValidTarget()
    if target then
        local tHRP = target:FindFirstChild("HumanoidRootPart")
        if tHRP then
            -- 4. หา Remote แบบ Real-time เพื่อกัน Nil
            local AttackRemote = ReplicatedStorage:FindFirstChild("BasicAttack", true)
            
            -- 5. ทำการวาร์ปและโจมตี
            local predict = tHRP.AssemblyLinearVelocity * 0.12
            local behindPos = tHRP.CFrame * CFrame.new(0, 0, 2.5)
            
            myRoot.CFrame = CFrame.new(behindPos.Position + predict, tHRP.Position)
            
            if AttackRemote and AttackRemote:IsA("RemoteEvent") then
                pcall(function()
                    AttackRemote:FireServer(false)
                end)
            end
        end
    end
end)
