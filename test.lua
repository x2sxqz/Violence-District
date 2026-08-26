--9
-- ========================================================
-- [STANDALONE] HYPERX AUTO PARRY - REAL ITEM & DUAL UI
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============== CONFIG & STATE ==============
local Config = {
    Enabled = false,
    Radius = 10,
    FaceSensitivity = 0.7,
    Aggressive = false
}

local State = {
    Cooldown = false,
    CD_Time = 0,
    Attached = {},
    Adornment = nil
}

local VALID_PARRY_IDS = {
    ["122812055447896"] = "Veil lunge", ["133963973694098"] = "Mayers Basic",
    ["117042998468241"] = "Mayers lunge", ["135002183282873"] = "cure lunge",
    ["121216847022485"] = "cure Basic", ["132817836308238"] = "Jeff Basic",
    ["129784271201071"] = "Jeff lunge", ["82666958311998"] = "Jeff Frenzy",
    ["78432063483146"] = "Abyssal Basic", ["118907603246885"] = "Abyssal lunge",
    ["139369275981139"] = "Jason Basic", ["110355011987939"] = "Jason lunge",
    ["111920872708571"] = "Masked Basic", ["105374834496520"] = "Masked lunge",
    ["138720291317243"] = "Masked Tony", ["106871536134254"] = "Masked Alex",
    ["130593238885843"] = "Masked Cobra", ["115244153053858"] = "Masked Cobra lunge",
    ["74968262036854"] = "Hidden Basic", ["113255068724446"] = "Hidden lunge",
    ["98163597193511"] = "Hidden S1", ["80411309607666"] = "Abyssal S1"
}

-- ============== DRAG LOGIC ==============
local function MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end

-- ============== UI: DUAL PANEL ==============
local MainGui = Instance.new("ScreenGui", PlayerGui)
MainGui.Name = "HyperX_ParrySystem"; MainGui.ResetOnSpawn = false

-- 1. ปุ่ม Toggle (ลากได้)
local ToggleBtn = Instance.new("TextButton", MainGui)
ToggleBtn.Size = UDim2.new(0, 130, 0, 45); ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ToggleBtn.Text = "PARRY: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 70, 70); ToggleBtn.Font = "GothamBold"; ToggleBtn.TextSize = 13
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
local BtnStroke = Instance.new("UIStroke", ToggleBtn); BtnStroke.Thickness = 2; BtnStroke.Color = Color3.fromRGB(255, 70, 70)
MakeDraggable(ToggleBtn)

-- 2. Status Panel (ลากได้)
local StatusFrame = Instance.new("Frame", MainGui)
StatusFrame.Size = UDim2.new(0, 170, 0, 85); StatusFrame.Position = UDim2.new(0.05, 0, 0.5, 0)
StatusFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); StatusFrame.BorderSizePixel = 0
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 10)
local FrameStroke = Instance.new("UIStroke", StatusFrame); FrameStroke.Thickness = 1.5; FrameStroke.Color = Color3.fromRGB(60, 60, 60)
MakeDraggable(StatusFrame)

local function CreateLbl(parent, pos, color, size)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, -20, 0, 18); l.Position = pos; l.BackgroundTransparency = 1
    l.TextColor3 = color; l.Font = "GothamBold"; l.TextSize = size or 11; l.TextXAlignment = "Left"
    return l
end

local StatLbl = CreateLbl(StatusFrame, UDim2.new(0, 10, 0, 12), Color3.new(1,0,0), 12)
local CDLbl = CreateLbl(StatusFrame, UDim2.new(0, 10, 0, 35), Color3.new(1,1,1))
local DistLbl = CreateLbl(StatusFrame, UDim2.new(0, 10, 0, 58), Color3.new(0.8,0.8,0.8))

-- ============== CORE: EXECUTION (ใช้ไอเท็มจริง) ==============
local function Execute()
    if State.Cooldown then return end
    local char = LocalPlayer.Character
    if not char then return end

    -- ค้นหาไอเท็มจริง
    local dagger = char:FindFirstChild("Parrying Dagger") or LocalPlayer.Backpack:FindFirstChild("Parrying Dagger")
    if not dagger then return end

    pcall(function()
        -- 1. บังคับให้ถือดาบ (ถ้าจำเป็นเพื่อให้ Activate ทำงาน)
        if dagger.Parent ~= char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(dagger) end
        end
        
        -- 2. สั่งใช้งาน Tool จริง (แอนิเมชั่นจะขึ้น คูลดาวน์ดาบจะหมุน)
        dagger:Activate()

        -- 3. ส่ง Remote ย้ำเพื่อให้เซิร์ฟเวอร์ยอมรับผลทันที
        local remote = dagger:FindFirstChild("parry") or ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
        if remote then remote:FireServer() end
    end)
end

-- ============== SENSOR & LOOP ==============
local function Attach(kChar)
    if not kChar or State.Attached[kChar] then return end
    local anim = kChar:WaitForChild("Humanoid", 10):WaitForChild("Animator", 10)
    if not anim then return end
    State.Attached[kChar] = true
    anim.AnimationPlayed:Connect(function(track)
        if not Config.Enabled or State.Cooldown then return end
        local id = track.Animation.AnimationId:match("%d+")
        if id and VALID_PARRY_IDS[id] then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local kHRP = kChar:FindFirstChild("HumanoidRootPart")
            if myHRP and kHRP then
                local d = (myHRP.Position - kHRP.Position).Magnitude
                if d <= Config.Radius then
                    if Config.Aggressive or kHRP.CFrame.LookVector:Dot((myHRP.Position - kHRP.Position).Unit) >= Config.FaceSensitivity then
                        Execute()
                    end
                end
            end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    -- Sync UI
    ToggleBtn.Text = "AUTO PARRY: " .. (Config.Enabled and "ON" or "OFF")
    ToggleBtn.TextColor3 = Config.Enabled and Color3.fromRGB(80, 255, 150) or Color3.fromRGB(255, 70, 70)
    BtnStroke.Color = ToggleBtn.TextColor3
    
    StatLbl.Text = "SYSTEM: " .. (Config.Enabled and "ACTIVE" or "DISABLED")
    StatLbl.TextColor3 = ToggleBtn.TextColor3
    CDLbl.Text = State.Cooldown and string.format("CD: %.1fs", State.CD_Time) or "CD: READY"
    CDLbl.TextColor3 = State.Cooldown and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(80, 255, 150)

    -- Tracker Distance
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local closest = 999
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Killer" and p.Character then
            Attach(p.Character)
            local khrp = p.Character:FindFirstChild("HumanoidRootPart")
            if khrp and root then 
                local d = (root.Position - khrp.Position).Magnitude
                if d < closest then closest = d end
            end
        end
    end
    DistLbl.Text = string.format("KILLER: %.1f m.", closest)
    DistLbl.TextColor3 = (closest <= Config.Radius) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(200, 200, 200)

    -- Ring Rendering
    if Config.Enabled and root then
        if not State.Adornment or State.Adornment.Parent ~= root then
            if State.Adornment then State.Adornment:Destroy() end
            State.Adornment = Instance.new("CylinderHandleAdornment", root)
            State.Adornment.Height = 0.05; State.Adornment.Transparency = 0.3; State.Adornment.Adornee = root
        end
        State.Adornment.Radius = Config.Radius; State.Adornment.InnerRadius = Config.Radius - 0.12
        State.Adornment.CFrame = CFrame.new(0, -2.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
        State.Adornment.Color3 = State.Cooldown and Color3.fromRGB(255, 130, 0) or (Config.Aggressive and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 255))
    elseif State.Adornment then State.Adornment:Destroy(); State.Adornment = nil end
end)

ToggleBtn.MouseButton1Click:Connect(function() Config.Enabled = not Config.Enabled end)

-- Cooldown Listener จากไอเท็มจริง
task.spawn(function()
    local res = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Parrying Dagger"):WaitForChild("parryResult")
    res.OnClientEvent:Connect(function(_, cd)
        State.CD_Time = tonumber(cd) or 0.6
        State.Cooldown = true
        while State.CD_Time > 0 do task.wait(0.1); State.CD_Time = State.CD_Time - 0.1 end
        State.Cooldown = false; State.CD_Time = 0
    end)
end)

print("HyperX Stable Dual-UI Loaded.")
