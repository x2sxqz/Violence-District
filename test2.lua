local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- [ CONFIG ] 1
local KillActive = false
local CarryActive = false
local AttackRemote = ReplicatedStorage:FindFirstChild("BasicAttack", true)
local CarryRemote = ReplicatedStorage:FindFirstChild("CarrySurvivorEvent", true)

-- [ UTILS ]
local function IsHookOccupied(hook)
    if hook:GetAttribute("Occupied") or hook:GetAttribute("InUse") then return true end
    -- เช็คว่ามีคนถูกมัดอยู่ไหม (ตรวจสอบหา HumanoidRootPart ของคนอื่นใน Hook)
    for _, item in ipairs(hook:GetDescendants()) do
        if item:IsA("Weld") and item.Part1 and item.Part1.Parent:FindFirstChild("Humanoid") then
            return true
        end
    end
    return false
end

local function GetKillTarget()
    local target, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local c = p.Character
            local hum = c:FindFirstChildOfClass("Humanoid")
            -- ตรวจสอบว่าไม่ใช่พวกเดียวกันและยังมีชีวิต/ไม่ล้ม
            if hum and hum.Health > 0 and not c:GetAttribute("Knocked") and not c:GetAttribute("IsHooked") then
                local mag = (c.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if mag < shortest then
                    shortest = mag
                    target = c.HumanoidRootPart
                end
            end
        end
    end
    return target
end

local function GetDownedTarget()
    local target, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local c = p.Character
            -- เช็คสถานะล้ม (ปรับตามชื่อ Attribute ของเกมนั้นๆ)
            if (c:GetAttribute("Knocked") or c:FindFirstChild("Downed")) and not c:GetAttribute("IsHooked") and not c:GetAttribute("IsGrabbed") then
                local mag = (c.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if mag < shortest then
                    shortest = mag
                    target = c
                end
            end
        end
    end
    return target
end

local function GetNearestHook()
    local target, shortest = nil, math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if (v.Name:lower():find("hook") or v.Name:lower():find("rocket")) and v:IsA("BasePart") then
            if not IsHookOccupied(v) then
                local mag = (v.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if mag < shortest then
                    shortest = mag
                    target = v
                end
            end
        end
    end
    return target
end

-- [ UI SETUP - MODERN DARK ]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 130)
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner", Main)
local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Color = Color3.fromRGB(50, 50, 50)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "HYPERX - INTERNAL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local Layout = Instance.new("UIListLayout", Main)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom

local function MakeBtn(text, color)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 180, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = text
    b.TextColor3 = color
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local KillBtn = MakeBtn("AUTO KILL: OFF", Color3.fromRGB(255, 70, 70))
local CarryBtn = MakeBtn("AUTO CARRY: OFF", Color3.fromRGB(70, 150, 255))

KillBtn.MouseButton1Click:Connect(function()
    KillActive = not KillActive
    KillBtn.Text = KillActive and "AUTO KILL: ON" or "AUTO KILL: OFF"
    KillBtn.TextColor3 = KillActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 70, 70)
end)

CarryBtn.MouseButton1Click:Connect(function()
    CarryActive = not CarryActive
    CarryBtn.Text = CarryActive and "AUTO CARRY: ON" or "AUTO CARRY: OFF"
    CarryBtn.TextColor3 = CarryActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(70, 150, 255)
end)

-- [ MAIN LOGIC ]
task.spawn(function()
    while task.wait(0.05) do
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        -- เช็คสถานะการอุ้ม
        local isCarrying = char:GetAttribute("Carrying") or char:FindFirstChild("CarryingSurvivor") or char:FindFirstChild("CarryValue")

        if CarryActive then
            if isCarrying then
                -- ถ้าอุ้มอยู่ให้ไป Hook ที่ว่าง
                local hook = GetNearestHook()
                if hook then
                    root.CFrame = hook.CFrame * CFrame.new(0, 3.5, 0)
                end
            else
                -- ถ้าไม่อุ้มให้ไปหาคนล้ม
                local target = GetDownedTarget()
                if target then
                    root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 3.5, 0)
                    if CarryRemote then CarryRemote:FireServer(target) end
                end
            end
        end

        if KillActive and not isCarrying then
            local targetHRP = GetKillTarget()
            if targetHRP then
                -- วาร์ปไปจุดที่เหมาะสมและหันหน้าหาเป้าหมาย
                local offset = targetHRP.CFrame.LookVector * -2.5
                root.CFrame = CFrame.lookAt(targetHRP.Position + offset, targetHRP.Position)
                
                if AttackRemote then 
                    AttackRemote:FireServer(false) -- ส่ง Remote โจมตี
                end
            end
        end
    end
end)
