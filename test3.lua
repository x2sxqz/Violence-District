-- [[ HyperX Ultra God-Speed Parry ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Config = {
    Enabled = true,
    Range = 12,
    VisualEnabled = true,
    Segments = 24,
    PreFireBuffer = 5, -- ระยะเผื่อสำหรับการกดล่วงหน้า
    AttackAnimations = {
        ["139369275981139"] = true, ["121216847022485"] = true, ["78935059863801"] = true,
        ["74968262036854"] = true, ["82666958311998"] = true, ["78432063483146"] = true,
        ["132817836308238"] = true, ["111920872708571"] = true, ["138720291317243"] = true,
        ["130593238885843"] = true, ["106871536134254"] = true, ["109402730355822"] = true
    }
}

-- [ Procedural Visual Circle ]
local Attachments = {}
local Beams = {}
for i = 1, Config.Segments do
    Attachments[i] = Instance.new("Attachment", workspace.Terrain)
    Beams[i] = Instance.new("Beam", workspace.Terrain)
    Beams[i].Width0 = 0.4
    Beams[i].Width1 = 0.4
    Beams[i].FaceCamera = true
    Beams[i].Transparency = NumberSequence.new(0.1)
end

for i = 1, Config.Segments do
    Beams[i].Attachment0 = Attachments[i]
    Beams[i].Attachment1 = Attachments[i == Config.Segments and 1 or i + 1]
end

-- [ Pre-emptive Logic ]
local function GetParryButton()
    local mob = PlayerGui:FindFirstChild("Survivor-mob")
    return mob and mob:FindFirstChild("Gui-mob", true)
end

local function PerformAction(kRoot)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not kRoot then return end

    -- Snap Face Target ทันที
    root.CFrame = CFrame.lookAt(root.Position, Vector3.new(kRoot.Position.X, root.Position.Y, kRoot.Position.Z))

    -- Burst Fire Parry
    local btn = GetParryButton()
    if btn then
        firesignal(btn.MouseButton1Down)
        task.spawn(function()
            for i = 1, 2 do
                firesignal(btn.MouseButton1Down)
                task.wait()
            end
        end)
    end
end

local function ConnectKiller(killer)
    local hum = killer:WaitForChild("Humanoid", 10)
    local animator = hum and hum:WaitForChild("Animator", 10)
    
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            if not Config.Enabled then return end
            
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            if Config.AttackAnimations[animId] then
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local kRoot = killer:FindFirstChild("HumanoidRootPart")
                
                if root and kRoot then
                    local dist = (root.Position - kRoot.Position).Magnitude
                    -- กดล่วงหน้าทันทีเมื่อ Animation เริ่มในระยะ
                    if dist <= (Config.Range + Config.PreFireBuffer) then
                        PerformAction(kRoot)
                    end
                end
            end
        end)
    end
end

-- [ Killer Scanner ]
local KillerModel = nil
task.spawn(function()
    while true do
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Model") and v ~= LocalPlayer.Character and v:FindFirstChild("Lookscriptkiller", true) then
                if KillerModel ~= v then
                    KillerModel = v
                    ConnectKiller(v)
                end
            end
        end
        task.wait(0.2)
    end
end)

-- [ Loop Update ]
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root and Config.VisualEnabled then
        local basePos = root.Position - Vector3.new(0, 2.9, 0)
        local inDanger = false
        
        if KillerModel and KillerModel:FindFirstChild("HumanoidRootPart") then
            if (root.Position - KillerModel.HumanoidRootPart.Position).Magnitude <= Config.Range then
                inDanger = true
            end
        end
        
        local color = inDanger and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(255, 20, 20)
        
        for i = 1, Config.Segments do
            local angle = (i - 1) * (math.pi * 2 / Config.Segments)
            local offset = Vector3.new(math.cos(angle) * Config.Range, 0, math.sin(angle) * Config.Range)
            Attachments[i].Position = basePos + offset
            Beams[i].Enabled = true
            Beams[i].Color = ColorSequence.new(color)
        end
    else
        for i = 1, Config.Segments do Beams[i].Enabled = false end
    end
end)
