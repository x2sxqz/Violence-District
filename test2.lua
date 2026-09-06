local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- [ CONFIG & REMOTES ]
local KillActive = false
local CarryActive = false
local AttackRemote = ReplicatedStorage:FindFirstChild("BasicAttack", true)
local CarryRemote = ReplicatedStorage:FindFirstChild("CarrySurvivorEvent", true)

-- [ UTILS ]
local function IsOccupied(hook)
    -- เช็คทั้ง Attribute และเช็คว่ามีตัวละครห้อยอยู่หรือไม่
    if hook:GetAttribute("Occupied") or hook:GetAttribute("InUse") then return true end
    for _, child in ipairs(hook:GetChildren()) do
        if child:IsA("Model") or child.Name == "Occupant" then return true end
    end
    return false
end

local function GetKillTarget()
    local shortest = math.huge
    local target = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Team and p.Team.Name == "Survivors" and p.Character then
            local c = p.Character
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 
            and not c:GetAttribute("Knocked") 
            and not c:GetAttribute("IsHooked") 
            and not c:GetAttribute("IsGrabbed") then
                local mag = (hrp.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if mag < shortest then
                    shortest = mag
                    target = hrp
                end
            end
        end
    end
    return target
end

local function GetDownedTarget()
    local shortest = math.huge
    local target = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local c = p.Character
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp and (c:GetAttribute("Knocked") == true or c:FindFirstChild("Downed")) and not c:GetAttribute("IsHooked") then
                local mag = (hrp.Position - LP.Character.HumanoidRootPart.Position).Magnitude
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
    local shortest = math.huge
    local target = nil
    for _, v in ipairs(workspace:GetDescendants()) do
        if (v.Name:lower():find("hook") or v.Name:lower():find("rocket")) and v:IsA("BasePart") then
            if not IsOccupied(v) then
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

-- [ MODERN GUI SETUP ]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 180, 0, 120)
MainFrame.Position = UDim2.new(0.5, -90, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(45, 45, 45)
UIStroke.Thickness = 2

local UIList = Instance.new("UIListLayout", MainFrame)
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.VerticalAlignment = Enum.VerticalAlignment.Center

local function CreateBtn(text, color)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0, 150, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.Text = text
    b.TextColor3 = color
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.AutoButtonColor = true
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 6)
    return b
end

local KillBtn = CreateBtn("KILLER: OFF", Color3.fromRGB(255, 80, 80))
local CarryBtn = CreateBtn("CARRY: OFF", Color3.fromRGB(80, 150, 255))

KillBtn.MouseButton1Click:Connect(function()
    KillActive = not KillActive
    KillBtn.Text = KillActive and "KILLER: ON" or "KILLER: OFF"
    KillBtn.TextColor3 = KillActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 80, 80)
end)

CarryBtn.MouseButton1Click:Connect(function()
    CarryActive = not CarryActive
    CarryBtn.Text = CarryActive and "CARRY: ON" or "CARRY: OFF"
    CarryBtn.TextColor3 = CarryActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(80, 150, 255)
end)

-- [ MAIN LOOP ]
task.spawn(function()
    while task.wait() do
        local char = LP.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end

        -- เช็คทีม (ปรับตามชื่อทีมในเกมจริง)
        local isKiller = (LP.Team and (LP.Team.Name == "Killer" or LP.Team.Name == "Slasher"))
        if not isKiller then continue end

        -- เช็คว่าอุ้มอยู่หรือไม่
        local isCarrying = char:GetAttribute("Carrying") or char:GetAttribute("IsCarrying") or char:FindFirstChild("CarryValue") or char:FindFirstChild("CarryingSurvivor")

        if CarryActive then
            if isCarrying then
                local hook = GetNearestHook()
                if hook then
                    myRoot.CFrame = hook.CFrame * CFrame.new(0, 3, 0)
                end
            else
                local target = GetDownedTarget()
                if target and target:FindFirstChild("HumanoidRootPart") then
                    myRoot.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    if CarryRemote then CarryRemote:FireServer(target) end
                end
            end
        end

        if KillActive and not isCarrying then
            local targetHRP = GetKillTarget()
            if targetHRP then
                -- วาร์ปไปตำแหน่งที่เหมาะสม (เยื้องหลังเล็กน้อย)
                local targetPos = targetHRP.Position + (targetHRP.CFrame.LookVector * -2.8)
                myRoot.CFrame = CFrame.lookAt(targetPos, targetHRP.Position)
                
                if AttackRemote then 
                    AttackRemote:FireServer(false)
                end
            end
        end
    end
end)
