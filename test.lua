local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- [ CONFIG ]
local KillActive = false
local CarryActive = false
local AttackRemote = ReplicatedStorage:FindFirstChild("BasicAttack", true)
local CarryRemote = ReplicatedStorage:FindFirstChild("CarrySurvivorEvent", true)

-- [ TARGETING FUNCTIONS ]
local function GetKillTarget()
    local shortest = math.huge
    local target = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Team and p.Team.Name == "Survivors" and p.Character then
            local c = p.Character
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 and not c:GetAttribute("Knocked") and not c:GetAttribute("IsHooked") then
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
            if hrp and c:GetAttribute("Knocked") == true and not c:GetAttribute("IsHooked") then
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
            if not v:GetAttribute("Occupied") then
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

-- [ GUI SETUP ]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 160, 0, 110)
Frame.Position = UDim2.new(0.5, -80, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.Active = true
Frame.Draggable = true
local UIList = Instance.new("UIListLayout", Frame)
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(text, color)
    local b = Instance.new("TextButton", Frame)
    b.Size = UDim2.new(0, 140, 0, 45)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.Text = text
    b.TextColor3 = color
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    Instance.new("UICorner", b)
    return b
end

local KillBtn = CreateBtn("FAST KILL: OFF", Color3.fromRGB(255, 80, 80))
local CarryBtn = CreateBtn("FAST CARRY: OFF", Color3.fromRGB(80, 150, 255))

KillBtn.MouseButton1Click:Connect(function()
    KillActive = not KillActive
    KillBtn.Text = KillActive and "FAST KILL: ON" or "FAST KILL: OFF"
    KillBtn.TextColor3 = KillActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 80, 80)
end)

CarryBtn.MouseButton1Click:Connect(function()
    CarryActive = not CarryActive
    CarryBtn.Text = CarryActive and "FAST CARRY: ON" or "FAST CARRY: OFF"
    CarryBtn.TextColor3 = CarryActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(80, 150, 255)
end)

-- [ MAIN LOOP ]
task.spawn(function()
    while task.wait() do
        local char = LP.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        if not myRoot or (LP.Team and LP.Team.Name ~= "Killer") then continue end

        -- à¹à¸à¹à¸à¸à¸²à¸£à¸­à¸¸à¹à¸¡ (à¹à¸à¸´à¹à¸¡à¹à¸à¸·à¹à¸­à¸à¹à¸ IsCarrying à¹à¸¥à¸°à¸«à¸² Object à¹à¸à¸à¸±à¸§)
        local isCarrying = char:GetAttribute("Carrying") or char:GetAttribute("IsCarrying") or char:FindFirstChild("CarryValue") or char:FindFirstChild("CarryingSurvivor")

        if CarryActive then
            if isCarrying then
                -- à¹à¸«à¸¡à¸à¸­à¸¸à¹à¸¡à¸­à¸¢à¸¹à¹: à¹à¸ Hook (à¹à¸à¸´à¹à¸¡à¸à¸§à¸²à¸¡à¸ªà¸¹à¸à¹à¸à¸·à¹à¸­à¹à¸¡à¹à¹à¸«à¹à¸à¸¡à¸à¸´à¸)
                local hook = GetNearestHook()
                if hook then
                    local hookPos = hook.Position
                    myRoot.CFrame = CFrame.new(hookPos + Vector3.new(0, 3, 0), Vector3.new(hookPos.X, myRoot.Position.Y, hookPos.Z))
                end
            else
                -- à¹à¸«à¸¡à¸à¸«à¸²à¸à¸: à¹à¸à¸«à¸²à¸à¸à¸¥à¹à¸¡ (à¹à¸à¸´à¹à¸¡à¸à¸§à¸²à¸¡à¸ªà¸¹à¸ +3 à¸à¸±à¸à¸¡à¸¸à¸à¸à¸·à¹à¸)
                local target = GetDownedTarget()
                if target then
                    local tRoot = target.HumanoidRootPart
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 3, 0)
                    CarryRemote:FireServer(target)
                end
            end
        end

        if KillActive and not isCarrying then
            local targetHRP = GetKillTarget()
            if targetHRP then
                -- à¸§à¸²à¸£à¹à¸à¹à¸à¸«à¸¥à¸±à¸à¹à¸à¹à¸²à¸«à¸¡à¸²à¸¢à¹à¸¥à¸°à¸«à¸±à¸à¸«à¸à¹à¸²à¸¡à¸­à¸
                local targetPos = targetHRP.Position + (targetHRP.CFrame.LookVector * -2.5)
                myRoot.CFrame = CFrame.lookAt(targetPos, targetHRP.Position)
                if AttackRemote then AttackRemote:FireServer(false) end
            end
        end
    end
end)
