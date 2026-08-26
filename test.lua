--2local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============== CONFIGURATION ==============
local Config = {
    Enabled = false,
    Radius = 15,          -- ระยะทำงาน (ปรับได้)
    FaceSensitivity = 0.7, -- ความไวการหันหน้า
    Aggressive = false,   -- โหมดโหด (ไม่สนทิศทาง)
    ShowCircle = true     -- เปิด/ปิด วงกลมที่พื้น
}

local State = {
    Cooldown = false,
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

-- ============== UI NOTIFICATION ==============
local function NotifyParry()
    task.spawn(function()
        local gui = Instance.new("ScreenGui", PlayerGui)
        local lbl = Instance.new("TextLabel", gui)
        lbl.Size = UDim2.new(0, 300, 0, 50)
        lbl.Position = UDim2.new(0.5, -150, 0.4, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "⚡ PARRY SUCCESS ⚡"
        lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = 25
        lbl.TextStrokeTransparency = 0
        
        local t = TweenService:Create(lbl, TweenInfo.new(0.6), {Position = UDim2.new(0.5, -150, 0.3, 0), TextTransparency = 1, TextStrokeTransparency = 1})
        t:Play()
        t.Completed:Connect(function() gui:Destroy() end)
    end)
end

-- ============== PARRY EXECUTION ==============
local function ExecuteParry()
    if State.Cooldown then return end
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
        if remote then 
            for i = 1, 10 do remote:FireServer() end 
            NotifyParry()
        end
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    end)
end

-- ============== SENSOR LOGIC ==============
local function AttachSensor(kChar)
    if not kChar or State.Attached[kChar] then return end
    local hum = kChar:WaitForChild("Humanoid", 10)
    local animator = hum and hum:WaitForChild("Animator", 10)
    if not animator then return end
    
    State.Attached[kChar] = true
    animator.AnimationPlayed:Connect(function(track)
        if not Config.Enabled or State.Cooldown then return end
        local id = track.Animation.AnimationId:match("%d+")
        if not id or not VALID_PARRY_IDS[id] then return end

        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end

        local dist = (myHRP.Position - kHRP.Position).Magnitude
        if dist <= Config.Radius then
            if Config.Aggressive then
                ExecuteParry()
            else
                local dot = kHRP.CFrame.LookVector:Dot((myHRP.Position - kHRP.Position).Unit)
                if dot >= Config.FaceSensitivity then ExecuteParry() end
            end
        end
    end)
end

-- ============== DRAGGABLE BUTTON UI ==============
local MainGui = Instance.new("ScreenGui", PlayerGui)
MainGui.Name = "HyperX_ParryUI"
MainGui.ResetOnSpawn = false

local Btn = Instance.new("TextButton", MainGui)
Btn.Size = UDim2.new(0, 130, 0, 45)
Btn.Position = UDim2.new(0.1, 0, 0.5, 0)
Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Btn.Text = "PARRY: OFF"
Btn.TextColor3 = Color3.fromRGB(255, 70, 70)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 13
local Corner = Instance.new("UICorner", Btn); Corner.CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", Btn); Stroke.Thickness = 2; Stroke.Color = Color3.fromRGB(255, 70, 70)

-- Dragging Logic
local dragStart, startPos, dragging
Btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = i.Position; startPos = Btn.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart; Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

Btn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    Btn.Text = Config.Enabled and "PARRY: ON" or "PARRY: OFF"
    Btn.TextColor3 = Config.Enabled and Color3.fromRGB(80, 255, 150) or Color3.fromRGB(255, 70, 70)
    Stroke.Color = Btn.TextColor3
end)

-- ============== VISUAL CIRCLE ==============
RunService.RenderStepped:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Config.ShowCircle and Config.Enabled and hrp then
        if not State.Adornment or State.Adornment.Parent ~= hrp then
            if State.Adornment then State.Adornment:Destroy() end
            State.Adornment = Instance.new("CylinderHandleAdornment", hrp)
            State.Adornment.Height = 0.05
            State.Adornment.Transparency = 0.4
            State.Adornment.Adornee = hrp
        end
        State.Adornment.Radius = Config.Radius
        State.Adornment.CFrame = CFrame.new(0, -2.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
        State.Adornment.Color3 = State.Cooldown and Color3.fromRGB(255, 150, 0) or (Config.Aggressive and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 255))
    elseif State.Adornment then State.Adornment:Destroy(); State.Adornment = nil end
end)

-- ============== INITIALIZE ==============
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Team and p.Team.Name == "Killer" and p.Character then AttachSensor(p.Character) end
        end
        task.wait(1)
    end
end)

-- Cooldown Listener
task.spawn(function()
    local res = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Parrying Dagger"):WaitForChild("parryResult")
    res.OnClientEvent:Connect(function(_, cd) State.Cooldown = true; task.wait(tonumber(cd) or 0.6); State.Cooldown = false end)
end)

print("HyperX: Standalone Auto Parry Loaded Successfully.")
