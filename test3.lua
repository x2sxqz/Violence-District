-- [[ REAPER AUTO PARRY - MAXIMUM SPEED VERSION ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Config = {
    AutoParry = true,
    ParryRange = 8, -- ค่าที่แนะนำ 7-9
    ShowVisual = true,
    Cooldown = 0, -- ปรับเป็น 0 ตามคำขอ
    AttackAnimations = {
        ["139369275981139"] = true, ["121216847022485"] = true, ["78935059863801"] = true,
        ["74968262036854"] = true, ["82666958311998"] = true, ["78432063483146"] = true,
        ["132817836308238"] = true, ["111920872708571"] = true, ["138720291317243"] = true,
        ["130593238885843"] = true, ["106871536134254"] = true, ["109402730355822"] = true
    }
}

local lastParryTick = 0

local function GetGuiMob()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    local mobGui = pGui and pGui:FindFirstChild("Survivor-mob")
    local controls = mobGui and mobGui:FindFirstChild("Controls")
    return controls and controls:FindFirstChild("Gui-mob")
end

-- Visualizer
local RangeCircle = Instance.new("Part")
RangeCircle.Shape = Enum.PartType.Cylinder
RangeCircle.Material = Enum.Material.ForceField
RangeCircle.Transparency = 1
RangeCircle.CanCollide = false
RangeCircle.Anchored = true
RangeCircle.Rotation = Vector3.new(0, 0, 90)
RangeCircle.Parent = workspace

local function GetKiller()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Lookscriptkiller", true) then
            return p.Character
        end
    end
    return nil
end

-- ใช้ RenderStepped เพื่อความเร็วสูงสุดในการเช็ค (ก่อนเรนเดอร์เฟรม)
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not Config.AutoParry or not root then 
        RangeCircle.Transparency = 1 
        return 
    end

    RangeCircle.Transparency = Config.ShowVisual and 0.5 or 1
    RangeCircle.Size = Vector3.new(0.1, Config.ParryRange * 2, Config.ParryRange * 2)
    RangeCircle.Position = root.Position - Vector3.new(0, 2.5, 0)
    RangeCircle.Color = Color3.fromRGB(255, 0, 0)

    local killerChar = GetKiller()
    if killerChar then
        local kRoot = killerChar:FindFirstChild("HumanoidRootPart")
        local kHum = killerChar:FindFirstChildOfClass("Humanoid")
        local kAnimator = kHum and kHum:FindFirstChildOfClass("Animator")

        if kRoot and kAnimator then
            local dist = (root.Position - kRoot.Position).Magnitude
            if dist <= Config.ParryRange then
                for _, track in ipairs(kAnimator:GetPlayingAnimationTracks()) do
                    local animId = tostring(track.Animation.AnimationId):match("%d+")
                    if Config.AttackAnimations[animId] then
                        RangeCircle.Color = Color3.fromRGB(0, 255, 0)
                        
                        -- Execute Parry
                        if tick() - lastParryTick >= Config.Cooldown then
                            local guiMob = GetGuiMob()
                            if guiMob then
                                lastParryTick = tick()
                                firesignal(guiMob.MouseButton1Down)
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end)

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 180, 0, 140)
Frame.Position = UDim2.new(0.1, 0, 0.5, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true
Frame.Draggable = true

local Label = Instance.new("TextLabel", Frame)
Label.Size = UDim2.new(1, 0, 0, 30)
Label.Text = "HYPERX PARRY (CD: 0)"
Label.TextColor3 = Color3.new(1,1,1)
Label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local function AddButton(text, yPos, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

AddButton("Auto Parry: ON", 40, function(b)
    Config.AutoParry = not Config.AutoParry
    b.Text = "Auto Parry: " .. (Config.AutoParry and "ON" or "OFF")
    b.BackgroundColor3 = Config.AutoParry and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(100, 50, 50)
end).BackgroundColor3 = Color3.fromRGB(50, 100, 50)

AddButton("Visual: ON", 75, function(b)
    Config.ShowVisual = not Config.ShowVisual
    b.Text = "Visual: " .. (Config.ShowVisual and "ON" or "OFF")
end)

AddButton("Range: " .. Config.ParryRange, 110, function(b)
    Config.ParryRange = Config.ParryRange + 1
    if Config.ParryRange > 12 then Config.ParryRange = 5 end
    b.Text = "Range: " .. Config.ParryRange
end)
