--7
-- ========================================================
-- [STANDALONE] HYPERX AUTO PARRY - DUAL UI EDITION
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
    Radius = 12,
    FaceSensitivity = 0.7,
    Aggressive = false
}

local State = {
    Cooldown = false,
    CD_Time = 0,
    Adornment = nil,
    Attached = {}
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

-- ============== DRAG FUNCTION ==============
local function MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end

-- ============== UI: NOTIFICATION ==============
local function NotifySuccess()
    task.spawn(function()
        local sg = Instance.new("ScreenGui", PlayerGui)
        local lbl = Instance.new("TextLabel", sg)
        lbl.Size = UDim2.new(0, 400, 0, 50); lbl.Position = UDim2.new(0.5, -200, 0.3, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = "⚡ PARRY SUCCESS ⚡"
        lbl.TextColor3 = Color3.fromRGB(0, 255, 255); lbl.Font = "GothamBlack"; lbl.TextSize = 28
        lbl.TextStrokeTransparency = 0
        local t = TweenService:Create(lbl, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, -200, 0.2, 0), TextTransparency = 1, TextStrokeTransparency = 1})
        t:Play(); t.Completed:Connect(function() sg:Destroy() end)
    end)
end

-- ============== UI: DUAL PANEL SETUP ==============
local MainGui = Instance.new("ScreenGui", PlayerGui)
MainGui.Name = "HyperX_ParrySystem"; MainGui.ResetOnSpawn = false

-- 1. ปุ่มเปิด-ปิด (Toggle Button)
local ToggleBtn = Instance.new("TextButton", MainGui)
ToggleBtn.Size = UDim2.new(0, 120, 0, 40); ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); ToggleBtn.Text = "PARRY: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 60, 60); ToggleBtn.Font = "GothamBold"; ToggleBtn.TextSize = 12
local BtnCorner = Instance.new("UICorner", ToggleBtn); BtnCorner.CornerRadius = UDim.new(0, 8)
local BtnStroke = Instance.new("UIStroke", ToggleBtn); BtnStroke.Thickness = 2; BtnStroke.Color = Color3.fromRGB(255, 60, 60)
MakeDraggable(ToggleBtn)

-- 2. แผงสถานะ (Status Panel)
local StatusFrame = Instance.new("Frame", MainGui)
StatusFrame.Size = UDim2.new(0, 160, 0, 80); StatusFrame.Position = UDim2.new(0.05, 0, 0.5, 0)
StatusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); StatusFrame.BorderSizePixel = 0
local FrameCorner = Instance.new("UICorner", StatusFrame); FrameCorner.CornerRadius = UDim.new(0, 10)
local FrameStroke = Instance.new("UIStroke", StatusFrame); FrameStroke.Thickness = 1.5; FrameStroke.Color = Color3.fromRGB(60, 60, 60)
MakeDraggable(StatusFrame)

local function CreateLbl(parent, pos, color, size)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, -20, 0, 18); l.Position = pos; l.BackgroundTransparency = 1
    l.TextColor3 = color; l.Font = "GothamBold"; l.TextSize = size or 11; l.TextXAlignment = "Left"
    return l
end

local StatLbl = CreateLbl(StatusFrame, UDim2.new(0, 10, 0, 12), Color3.new(1,0,0), 12)
local CDLbl = CreateLbl(StatusFrame, UDim2.new(0, 10, 0, 32), Color3.new(1,1,1))
local DistLbl = CreateLbl(StatusFrame, UDim2.new(0, 10, 0, 52), Color3.new(0.8,0.8,0.8))

-- ============== CORE: EXECUTION ==============
local function Execute()
    if State.Cooldown then return end
    local char = LocalPlayer.Character
    local dagger = char and (char:FindFirstChild("Parrying Dagger") or LocalPlayer.Backpack:FindFirstChild("Parrying Dagger"))
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
        if remote then for i = 1, 8 do remote:FireServer() end end
        if dagger and dagger:IsA("Tool") then dagger:Activate() end
        NotifySuccess()
    end)
end

-- ============== SENSOR & LOGIC ==============
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

-- ============== UPDATER LOOP ==============
RunService.Heartbeat:Connect(function()
    -- Sync UI Text & Button
    ToggleBtn.Text = "PARRY: " .. (Config.Enabled and "ON" or "OFF")
    ToggleBtn.TextColor3 = Config.Enabled and Color3.fromRGB(80, 255, 150) or Color3.fromRGB(255, 60, 60)
    BtnStroke.Color = ToggleBtn.TextColor3
    
    StatLbl.Text = "SYSTEM: " .. (Config.Enabled and "ACTIVE" or "DISABLED")
    StatLbl.TextColor3 = ToggleBtn.TextColor3
    CDLbl.Text = State.Cooldown and string.format("COOLDOWN: %.1fs", State.CD_Time) or "COOLDOWN: READY"
    CDLbl.TextColor3 = State.Cooldown and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(80, 255, 150)

    -- Update Killer Dist & Sensor
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
    DistLbl.Text = string.format("KILLER DIST: %.1f m.", closest)
    DistLbl.TextColor3 = (closest <= Config.Radius) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(200, 200, 200)

    -- Ring Visual
    if Config.Enabled and root then
        if not State.Adornment or State.Adornment.Parent ~= root then
            if State.Adornment then State.Adornment:Destroy() end
            State.Adornment = Instance.new("CylinderHandleAdornment", root)
            State.Adornment.Height = 0.05; State.Adornment.Transparency = 0.25; State.Adornment.Adornee = root
        end
        State.Adornment.Radius = Config.Radius; State.Adornment.InnerRadius = Config.Radius - 0.15
        State.Adornment.CFrame = CFrame.new(0, -2.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
        State.Adornment.Color3 = State.Cooldown and Color3.fromRGB(255, 130, 0) or (Config.Aggressive and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 255))
    elseif State.Adornment then State.Adornment:Destroy(); State.Adornment = nil end
end)

-- Button Toggle Event
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
end)

-- Cooldown Listener
task.spawn(function()
    local res = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Parrying Dagger"):WaitForChild("parryResult")
    res.OnClientEvent:Connect(function(_, cd)
        State.CD_Time = tonumber(cd) or 0.6
        State.Cooldown = true
        while State.CD_Time > 0 do task.wait(0.1); State.CD_Time = State.CD_Time - 0.1 end
        State.Cooldown = false; State.CD_Time = 0
    end)
end)

print("HyperX Standalone Dual-UI Parry Loaded.")
