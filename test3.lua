-- [[ HyperX Ultra Fast Auto Parry - 3D Ground Drawing ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Config = {
    Enabled = true,
    Range = 15,
    VisualEnabled = true,
    AttackAnimations = {
        ["139369275981139"] = true, ["121216847022485"] = true, ["78935059863801"] = true,
        ["74968262036854"] = true, ["82666958311998"] = true, ["78432063483146"] = true,
        ["132817836308238"] = true, ["111920872708571"] = true, ["138720291317243"] = true,
        ["130593238885843"] = true, ["106871536134254"] = true, ["109402730355822"] = true
    }
}

-- // สร้างเส้น 16 เส้นเพื่อประกอบเป็นวงกลม (3D Perspective)
local Segments = 16 
local Lines = {}
for i = 1, Segments do
    local L = Drawing.new("Line")
    L.Thickness = 1.5
    L.Transparency = 1
    Lines[i] = L
end

-- Caching Gui
local CachedGuiMob = nil
local function GetGuiMob()
    if CachedGuiMob and CachedGuiMob.Parent then return CachedGuiMob end
    local survivorMob = PlayerGui:FindFirstChild("Survivor-mob")
    local guiMob = survivorMob and survivorMob:FindFirstChild("Gui-mob", true)
    if guiMob then CachedGuiMob = guiMob end
    return guiMob
end

-- // ฟังก์ชันวาดวงกลม 3D บนพื้น
local function Update3DCircle(origin, radius, color)
    local step = (math.pi * 2) / Segments
    local points = {}

    for i = 0, Segments do
        local angle = i * step
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local worldPos = origin + offset
        local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
        points[i+1] = {Pos = Vector2.new(screenPos.X, screenPos.Y), Visible = onScreen}
    end

    for i = 1, Segments do
        local p1 = points[i]
        local p2 = points[i+1]
        local line = Lines[i]
        
        if p1.Visible and p2.Visible and Config.VisualEnabled then
            line.Visible = true
            line.From = p1.Pos
            line.To = p2.Pos
            line.Color = color
        else
            line.Visible = false
        end
    end
end

-- Core Loop
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local guiMob = GetGuiMob()
    local targetInAttack = false

    -- // ค้นหา Killer และเช็คการโจมตี
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and v ~= char and v:FindFirstChild("Lookscriptkiller", true) then
            local kRoot = v:FindFirstChild("HumanoidRootPart")
            local kHum = v:FindFirstChildOfClass("Humanoid")
            
            if kRoot and kHum and root then
                local dist = (root.Position - kRoot.Position).Magnitude
                if dist <= Config.Range then
                    local animator = kHum:FindFirstChildOfClass("Animator")
                    if animator then
                        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                            if Config.AttackAnimations[tostring(track.Animation.AnimationId):match("%d+")] then
                                targetInAttack = true
                                if Config.Enabled and guiMob then firesignal(guiMob.MouseButton1Down) end
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    -- // อัปเดตตำแหน่งวงกลมบนพื้น (ติดเท้า)
    if root then
        local color = targetInAttack and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        -- ยิง Raycast ลงพื้นเพื่อให้วงกลมแนบสนิทกับพื้นจริงๆ
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        local result = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), params)
        local groundPos = result and result.Position or (root.Position - Vector3.new(0, 3, 0))
        
        Update3DCircle(groundPos, Config.Range, color)
    else
        for _, l in pairs(Lines) do l.Visible = false end
    end
end)

-- UI System (เหมือนเดิม)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 190)
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "HYPERX PARRY 3D"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local function CreateToggle(name, prop, pos)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.BackgroundColor3 = Config[prop] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    btn.Text = name .. (Config[prop] and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        Config[prop] = not Config[prop]
        btn.BackgroundColor3 = Config[prop] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        btn.Text = name .. (Config[prop] and ": ON" or ": OFF")
    end)
end

CreateToggle("Auto Parry", "Enabled", 45)
CreateToggle("Range Visual", "VisualEnabled", 85)

local RangeLabel = Instance.new("TextLabel", Main)
RangeLabel.Size = UDim2.new(1, 0, 0, 20)
RangeLabel.Position = UDim2.new(0, 0, 0, 130)
RangeLabel.Text = "Range: " .. Config.Range
RangeLabel.TextColor3 = Color3.new(1, 1, 1)
RangeLabel.BackgroundTransparency = 1

local RangeSlider = Instance.new("TextButton", Main)
RangeSlider.Size = UDim2.new(0.9, 0, 0, 10)
RangeSlider.Position = UDim2.new(0.05, 0, 0, 155)
RangeSlider.Text = ""
RangeSlider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Instance.new("UICorner", RangeSlider)

local SliderPoint = Instance.new("Frame", RangeSlider)
SliderPoint.Size = UDim2.new(0, 10, 2, 0)
SliderPoint.Position = UDim2.new((Config.Range-1)/31, -5, -0.5, 0)
SliderPoint.BackgroundColor3 = Color3.new(1, 1, 1)

RangeSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local move = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation().X
            local relPos = math.clamp((mousePos - RangeSlider.AbsolutePosition.X) / RangeSlider.AbsoluteSize.X, 0, 1)
            Config.Range = math.floor(1 + (relPos * 31))
            SliderPoint.Position = UDim2.new(relPos, -5, -0.5, 0)
            RangeLabel.Text = "Range: " .. Config.Range
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then move:Disconnect() end
        end)
    end
end)
