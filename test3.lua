-- [[ HyperX Fully Integrated Auto Parry System ]] --
-- Integrated with ViolenceDistrict Codex Context

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer

-- [[ Config Initialization ]] --
getgenv().v = getgenv().v or {
    ["AutoParry"] = true,
    ["ParryRange"] = 8.5,
    ["ParryPingCompensation"] = true,
    ["ParryFacingCheck"] = true,
    ["FrenzyParry"] = false,
    ["IgnoreAbysswalkerLunge"] = true,
    ["ParryDelay"] = 0
}

-- Required Tables from Context
local Kb = {} -- Attack Animation IDs
local Lb = {["102746205979822"] = true, ["84093948968516"] = true, ["86266790353635"] = true} -- Ignore IDs
local Mb = {} -- Tracked Models
local activeLoop = true
local connections = {}

local function registerConnection(conn)
    table.insert(connections, conn)
end

-- [[ Integrated Parry Logic ]] --
local Parry = {
    remote = nil,
    lastParryTime = 0,
    cooldownUntil = 0
}

-- [ Logic: Range & Ping ]
function Parry.getPing()
    local ping = 80
    pcall(function()
        ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ping
end

local function effectiveParryRange()
    local range = math.clamp(v["ParryRange"] or 8.5, 5, 9.5)
    if v["ParryPingCompensation"] then
        local ping = Parry.getPing()
        range = math.clamp(range + (ping * 0.012), 5, 9.8)
    end
    return range
end

-- [ Logic: Killer Detection (From Context) ]
function Parry.getKillerModels()
    local result = {}
    -- Player Killers
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local isKiller = player:GetAttribute("Role") == "Killer" or player:GetAttribute("IsKiller") == true
            if isKiller then table.insert(result, player.Character) end
        end
    end
    -- Workspace Killers
    local killerFolder = workspace:FindFirstChild("Killers")
    if killerFolder then
        for _, m in ipairs(killerFolder:GetChildren()) do
            if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") then table.insert(result, m) end
        end
    end
    return result
end

-- [ Logic: Animation & Tool Helpers ]
function Parry.animationId(value) return string.match(tostring(value), "%d+") or "" end

function Parry.findParryTool()
    local character = localPlayer.Character
    if not character then return nil end
    return character:FindFirstChild("Parrying Dagger") or character:FindFirstChild("Parry Dagger") or localPlayer.Backpack:FindFirstChild("Parrying Dagger")
end

-- [ Logic: Execution (The Core) ]
function Parry.execute(reason, distance, attacker)
    if not v.AutoParry or tick() < Parry.cooldownUntil then return end
    local tool = Parry.findParryTool()
    if not tool then return end

    Parry.lastParryTime = tick()
    Parry.cooldownUntil = tick() + 0.8 -- Base Cooldown

    if v.ParryDelay > 0 then task.wait(v.ParryDelay) end

    task.spawn(function()
        -- Auto Equip
        if tool.Parent ~= localPlayer.Character then
            local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(tool) end
        end
        -- Fire Remote
        local remote = tool:FindFirstChild("parry") or tool:FindFirstChild("Parry")
        if remote then remote:FireServer() end
        tool:Activate()
        print("[HyperX] Parry Executed: " .. reason)
    end)
end

-- [[ MODERN CUSTOM UI ]] --
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
local TopBar = Instance.new("Frame", MainFrame)
local Title = Instance.new("TextLabel", TopBar)
local Content = Instance.new("ScrollingFrame", MainFrame)
local StatusFrame = Instance.new("Frame", MainFrame)
local StatusLabel = Instance.new("TextLabel", StatusFrame)

-- Styling
MainFrame.Size = UDim2.new(0, 280, 0, 400)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "HYPERX PREMIUM PARRIER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

StatusFrame.Size = UDim2.new(1, -20, 0, 80)
StatusFrame.Position = UDim2.new(0, 10, 0, 50)
StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", StatusFrame)

StatusLabel.Size = UDim2.new(1, -10, 1, -10)
StatusLabel.Position = UDim2.new(0, 10, 0, 5)
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = "Left"

Content.Size = UDim2.new(1, -10, 1, -140)
Content.Position = UDim2.new(0, 5, 0, 135)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
local List = Instance.new("UIListLayout", Content)
List.Padding = UDim.new(0, 5)

-- UI Interactive Elements
local function AddToggle(text, key)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = v[key] and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(40, 40, 40)
    btn.Text = text .. ": " .. (v[key] and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        v[key] = not v[key]
        btn.Text = text .. ": " .. (v[key] and "ON" or "OFF")
        btn.BackgroundColor3 = v[key] and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(40, 40, 40)
    end)
end

local function AddSlider(text, key, min, max)
    local box = Instance.new("TextBox", Content)
    box.Size = UDim2.new(1, -10, 0, 35)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.Text = text .. ": " .. tostring(v[key])
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text:match("%d+%.?%d*"))
        if val then
            v[key] = math.clamp(val, min, max)
        end
        box.Text = text .. ": " .. tostring(v[key])
    end)
end

-- Init UI Components
AddToggle("Auto Parry", "AutoParry")
AddToggle("Ping Compensation", "ParryPingCompensation")
AddToggle("Facing Check", "ParryFacingCheck")
AddToggle("Ignore Abysswalker", "IgnoreAbysswalkerLunge")
AddSlider("Range", "ParryRange", 5, 10)
AddSlider("Delay", "ParryDelay", 0, 1)

-- [[ DRAG SYSTEM ]] --
local dragStart, startPos, dragging
TopBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then 
    local delta = i.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- [[ REAL-TIME MONITORING & SCANNER ]] --
task.spawn(function()
    while task.wait(0.1) do
        local killers = Parry.getKillerModels()
        local nearestDist = math.huge
        local targetName = "None"
        local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

        for _, k in ipairs(killers) do
            if k:FindFirstChild("HumanoidRootPart") and myRoot then
                local d = (k.HumanoidRootPart.Position - myRoot.Position).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    targetName = k.Name
                end
            end
        end

        local ping = Parry.getPing()
        local range = effectiveParryRange()
        
        StatusLabel.Text = string.format(
            "PING: %d ms\nEFF. RANGE: %.2f\nNEAREST: %s\nDIST: %.1f studs\nSTATUS: %s",
            ping, range, targetName, nearestDist,
            (nearestDist <= range) and "!!! DANGER !!!" or "STANDBY"
        )
        StatusLabel.TextColor3 = (nearestDist <= range) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0.6)
    end
end)

-- [[ HITBOX LISTENER (CONTEXT REBUILD) ]] --
registerConnection(workspace.DescendantAdded:Connect(function(obj)
    if v.AutoParry and obj.Name:find("WallHitboxCollider_") then
        local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and (obj.Position - myRoot.Position).Magnitude <= effectiveParryRange() then
            Parry.execute("Hitbox Detected", 0, nil)
        end
    end
end))

-- [[ INITIALIZE ALL CONTEXT SERVICES ]] --
print("HyperX: System Fully Integrated.")
