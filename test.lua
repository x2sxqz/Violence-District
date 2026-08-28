-- ============== AUTO KILL ALL : BUG-FIXED EDITION (NO NIL) ==============

-- [ 1. SERVICES ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ 2. CORE VARIABLES ]
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local KillActive = false

-- [ 3. TARGETING FUNCTION (STRICT CHECK) ]
local function IsValid(char)
    if not char or not char:Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local plr = Players:GetPlayerFromCharacter(char)
    if not plr or not plr.Team or plr.Team.Name ~= "Survivors" then return false end
    
    -- Attributes เช็คสถานะพิเศษ
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
        if plr ~= LocalPlayer and plr.Character and IsValid(plr.Character) then
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

-- [ 4. DRAGGABLE UI (FIXED) ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HyperX_KillFinal"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 140, 0, 45)
MainFrame.Position = UDim2.new(0.5, -70, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.Parent = MainFrame
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 50, 50)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Text = "KILL ALL: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 13
ToggleBtn.Parent = MainFrame

-- ระบบลากแบบสมบูรณ์
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

-- [ 5. EXECUTION LOGIC (SAFETY FIRST) ]
ToggleBtn.MouseButton1Click:Connect(function()
    KillActive = not KillActive
    ToggleBtn.Text = KillActive and "KILL ALL: ON" or "KILL ALL: OFF"
    local color = KillActive and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(255, 50, 50)
    ToggleBtn.TextColor3 = color
    Stroke.Color = color
end)

RunService.Heartbeat:Connect(function()
    if not KillActive then return end
    
    -- Safety Check ทีม
    local myTeam = LocalPlayer.Team
    if not myTeam or myTeam.Name ~= "Killer" then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local target = GetTarget()
    if target then
        local tHRP = target:FindFirstChild("HumanoidRootPart")
        if tHRP then
            -- วาร์ป
            local vel = tHRP.AssemblyLinearVelocity * 0.12
            local pos = tHRP.CFrame * CFrame.new(0, 0, 2.5)
            myRoot.CFrame = CFrame.new(pos.Position + vel, tHRP.Position)
            
            -- ค้นหา Remote แบบระบุเจาะจงเพื่อกัน Nil Call
            local Remote = ReplicatedStorage:FindFirstChild("BasicAttack", true)
            
            if Remote then
                -- เช็คว่าเป็น RemoteEvent หรือ RemoteFunction และมีฟังก์ชันให้เรียกจริงไหม
                if Remote:IsA("RemoteEvent") then
                    Remote:FireServer(false)
                elseif Remote:IsA("RemoteFunction") then
                    Remote:InvokeServer(false)
                end
            end
        end
    end
end)
