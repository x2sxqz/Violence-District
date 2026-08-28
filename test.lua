-- ============== AUTO KILL ALL : COMPLETE STANDALONE MODULE ==============

-- [ 1. ALL NECESSARY SERVICES & VARIABLES ]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- [ 2. GAME SPECIFIC VARIABLES ]
-- เช็คว่า Remote มีอยู่จริงเพื่อป้องกันสคริปต์ Error
local AttackEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
local KillActive = false

-- [ 3. TARGET VALIDATION LOGIC ]
local function IsAttackable(char)
    if not char or not char:Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    -- เช็ค Team (ต้องเป็น Survivors เท่านั้น)
    local plr = Players:GetPlayerFromCharacter(char)
    if not plr or not plr.Team or plr.Team.Name ~= "Survivors" then return false end
    
    -- เช็ค Attributes: ข้ามคนล้ม (Knocked/Down) และคนบน Hook (IsHooked)
    -- เพราะการวาร์ปไปตีคนกลุ่มนี้จะทำให้เราเสียเวลาและดาเมจไม่เข้า
    local isHooked = char:GetAttribute("IsHooked") == true
    local isDowned = char:GetAttribute("IsDown") == true or char:GetAttribute("Knocked") == true
    
    if isHooked or isDowned then return false end
    
    return true
end

local function GetClosestTarget()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and IsAttackable(plr.Character) then
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

-- [ 4. DRAGGABLE UI CONSTRUCTION ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HyperX_KillModule"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 55)
MainFrame.Position = UDim2.new(0.5, -80, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 50, 50)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -10, 1, -10)
ToggleBtn.Position = UDim2.new(0, 5, 0, 5)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Text = "KILL ALL: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

-- [ 5. STABLE DRAG SYSTEM ]
local dragToggle, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)

-- [ 6. MAIN KILLER LOGIC ]
ToggleBtn.MouseButton1Click:Connect(function()
    KillActive = not KillActive
    if KillActive then
        ToggleBtn.Text = "KILL ALL: ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(50, 255, 120)
        UIStroke.Color = Color3.fromRGB(50, 255, 120)
    else
        ToggleBtn.Text = "KILL ALL: OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
        UIStroke.Color = Color3.fromRGB(255, 50, 50)
    end
end)

RunService.Heartbeat:Connect(function()
    if not KillActive then return end
    
    -- ตรวจสอบทีม: ต้องเป็น Killer เท่านั้น
    if not (LocalPlayer.Team and LocalPlayer.Team.Name == "Killer") then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local target = GetClosestTarget()
    if target then
        local tHRP = target:FindFirstChild("HumanoidRootPart")
        if tHRP then
            -- Prediction: คำนวณความเร็วเป้าหมายเพื่อวาร์ปดักหน้า/หลังให้แม่น
            local predict = tHRP.AssemblyLinearVelocity * 0.12
            
            -- วาร์ปไปตำแหน่ง "ด้านหลัง" ของเป้าหมาย (2.5 studs) เพื่อเลี่ยงการโดน Parry
            local behindPosition = tHRP.CFrame * CFrame.new(0, 0, 2.5)
            
            -- อัปเดตตำแหน่ง Killer
            myRoot.CFrame = CFrame.new(behindPosition.Position + predict, tHRP.Position)
            
            -- ส่งคำสั่งโจมตีรัวๆ ผ่าน Remote
            pcall(function()
                AttackEvent:FireServer(false)
            end)
        end
    end
end)
