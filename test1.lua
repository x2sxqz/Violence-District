--=========================
-- 🔥 Lib Load Screen Reaper Hub 16
--=========================
local Load = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2sxqz/Libwtf/refs/heads/main/libload2.lua"))() 
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2sxqz/Advanced/refs/heads/main/gui/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2sxqz/Advanced/refs/heads/main/gui/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2sxqz/Advanced/refs/heads/main/gui/InterfaceManager.lua"))()


local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local VU = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local lighting = Lighting
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local localPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")	
local DefaultZoom = LocalPlayer.CameraMaxZoomDistance
local LogService = game:GetService("LogService")
local LocalPlayer = Players.LocalPlayer
local LP = LocalPlayer
local Camera = workspace.CurrentCamera
local lp = LocalPlayer

local Window = Fluent:CreateWindow({
Title = "Reaper Hub",
SubTitle = "Violence District",
TabWidth = 160,
Size = UDim2.fromOffset(520, 360),
Theme = "ExtremeReaper",
MinimizeKey = Enum.KeyCode.RightControl
})

local icon = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2sxqz/Libwtf/refs/heads/main/Icon.lua"))()

--=========================
-- 🔥Tab
--=========================
local Tabs = {
Status = Window:AddTab({ Title = "Status", Icon = "signal-high" }),
Player = Window:AddTab({ Title = "Player", Icon = "user" }),
ESP = Window:AddTab({ Title = "ESP", Icon = "box" }),
Teleport = Window:AddTab({ Title = "Teleport", Icon = "menu" }),
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}


-- Key Time
local FIREBASE_BASE_URL = "https://keysystem-reaper-default-rtdb.asia-southeast1.firebasedatabase.app/keys"
local KEY_FILE = "reaper_saved_key.txt"

local ExpiryLabel = Tabs.Status:AddParagraph({
    Title = "Key Remaining Time",
    Content = "Fetching data..."
})

local function startKeyTimer()
    task.spawn(function()
        if not isfile(KEY_FILE) then 
            ExpiryLabel:SetDesc("Status: No key file found")
            return 
        end
        
        local rawKey = readfile(KEY_FILE)
        local savedKey = rawKey:gsub("%s+", "") 
        
        local success, response = pcall(function()
            return game:HttpGet(string.format("%s/%s.json", FIREBASE_BASE_URL, savedKey))
        end)

        if success and response and response ~= "null" then
            local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(response) end)
            
            if decodeSuccess and data and data.expiresAt then
                if data.hwid == "" or data.hwid == nil or data.hwid == gethwid() then
                    local targetTime = tonumber(data.expiresAt) / 1000 
                    
                    while true do
                        local timeLeft = targetTime - os.time()
                        
                        if timeLeft > 0 then
                            local d = math.floor(timeLeft / 86400)
                            local h = math.floor((timeLeft % 86400) / 3600)
                            local m = math.floor((timeLeft % 3600) / 60)
                            local s = math.floor(timeLeft % 60)
                            
                            local displayStr = ""
                            
                            -- [คงไว้ตามต้นฉบับของคุณเป๊ะๆ]
                            if d > 0 then
                                displayStr = string.format("%d Days : %d Hours : %d Minutes : %d s", d, h, m, s)
                            elseif h > 0 then
                                displayStr = string.format("%d Hours : %d Minutes : %d s", h, m, s)
                            elseif m > 0 then
                                displayStr = string.format("%d Minutes : %d s", m, s)
                            else
                                displayStr = string.format("%d s", s)
                            end
                            
                            ExpiryLabel:SetDesc(displayStr)
                        else
                            -- [ส่วนที่ปรับปรุง: เมื่อหมดเวลาให้ Rejoin รัวๆ]
                            ExpiryLabel:SetDesc("Status: Key Expired!")
                            while true do
                                pcall(function()
                                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                                end)
                                task.wait(0.5) -- ความเร็วในการพยายาม Rejoin (0.5 วินาที)
                            end
                            break
                        end
                        task.wait(1)
                    end
                    return
                end
            end
        end
        ExpiryLabel:SetDesc("Status: No Active Session")
    end)
end

startKeyTimer()

--player
local WSState = false
local WSValue = 16  
local DefaultWS = 16
local initialized = false

local function HookChar(char)
    local hum = char:WaitForChild("Humanoid")
    
    -- บันทึกค่าความเร็วปกติของเกมไว้แค่ครั้งเดียวตอนรันสคริปต์
    if not initialized then
        DefaultWS = hum.WalkSpeed
        initialized = true
    end
end

if LP.Character then HookChar(LP.Character) end
LP.CharacterAdded:Connect(HookChar)

RunService.RenderStepped:Connect(function()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- ทำงานเฉพาะตอนเปิด Toggle เท่านั้น
    if WSState then
        hum.WalkSpeed = WSValue
    end
end)

-- ช่องกรอกตัวเลขความเร็ว
Tabs.Player:AddInput("WSV", {
    Title = "Speed Value",
    Default = "16",
    Callback = function(v)
        WSValue = tonumber(v) or 16
    end
})

-- ปุ่มเปิด/ปิด
Tabs.Player:AddToggle("WS", {
    Title = "WalkSpeed",
    Default = false,
    Callback = function(v) 
        WSState = v 
        
        -- ถ้ากดปิด ให้คืนค่าความเร็วกลับเป็นค่าเริ่มต้นทันที
        if not v then 
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then 
                hum.WalkSpeed = DefaultWS 
            end 
        end
    end
})


--esp
local ESP_Config = {
    EnabledRoles = {}, 
    ShowBox = false,
    ShowHighlight = false,
    ShowTracer = false,
    Roles = {
        ["Survivors"] = Color3.fromRGB(0, 255, 0),
        ["Killer"] = Color3.fromRGB(255, 0, 0),
        ["Spectator"] = Color3.fromRGB(255, 255, 255)
    }
}


local RoleDropdown = Tabs.ESP:AddDropdown("ESPRoles", {
    Title = "Select Type",
    Values = {"Survivors", "Killer", "Spectator"},
    Multi = true,
    Default = {},
})

RoleDropdown:OnChanged(function(Value)
    ESP_Config.EnabledRoles = Value
end)

Tabs.ESP:AddToggle("HighlightToggle", {Title = "ESP Highlight", Default = false}):OnChanged(function(v)
    ESP_Config.ShowHighlight = v
end)

Tabs.ESP:AddToggle("BoxToggle", {Title = "ESP Box 3D", Default = false}):OnChanged(function(v)
    ESP_Config.ShowBox = v
end)

Tabs.ESP:AddToggle("TracerToggle", {Title = "ESP Line", Default = false}):OnChanged(function(v)
    ESP_Config.ShowTracer = v
end)

-- =========================
-- 🔥 Fixed ESP Logic (Box, Tracer, Highlight) - Version 2.1
-- =========================

local function GetRole(player)
    local team = player.Team and player.Team.Name or "None"
    local teamLower = team:lower()
    if string.find(teamLower, "killer") or string.find(teamLower, "murder") or string.find(teamLower, "beast") then return "Killer"
    elseif string.find(teamLower, "survivor") or string.find(teamLower, "innocent") or string.find(teamLower, "human") then return "Survivors" end
    return "Spectator"
end

local function CreateDrawingESP(player)
    if player == LocalPlayer then return end

    local ESP_Objects = {
        Lines = {},
        Tracer = nil
    }

    local function RemoveDrawing()
        for _, l in pairs(ESP_Objects.Lines) do pcall(function() l:Remove() end) end
        if ESP_Objects.Tracer then pcall(function() ESP_Objects.Tracer:Remove() end) end
        ESP_Objects.Lines = {}
        ESP_Objects.Tracer = nil
    end

    local function RefreshDrawing()
        if #ESP_Objects.Lines < 12 then
            for i = 1, 12 do
                local l = Drawing.new("Line")
                l.Thickness = 1.5
                l.Transparency = 1
                l.Visible = false
                table.insert(ESP_Objects.Lines, l)
            end
        end
        if not ESP_Objects.Tracer then
            local t = Drawing.new("Line")
            t.Thickness = 1.5
            t.Transparency = 1
            t.Visible = false
            ESP_Objects.Tracer = t
        end
    end

    local function ApplyESP(character)
        task.spawn(function()
            local hrp = character:WaitForChild("HumanoidRootPart", 10)
            local hum = character:WaitForChild("Humanoid", 10)
            if not hrp or not hum then return end

            RefreshDrawing()
            
            local highlight = character:FindFirstChild("R_Highlight") or Instance.new("Highlight")
            highlight.Name = "R_Highlight"
            highlight.Parent = character
            highlight.FillTransparency = 0.6
            highlight.OutlineTransparency = 0

            local connection
            connection = RunService.RenderStepped:Connect(function()
                -- ตรวจสอบว่าผู้เล่นหรือ Character ยังอยู่ไหม
                if not player or not player.Parent or not character or not character.Parent then
                    RemoveDrawing()
                    if highlight then highlight:Destroy() end
                    connection:Disconnect()
                    return
                end

                if hum.Health <= 0 then
                    for _, l in pairs(ESP_Objects.Lines) do l.Visible = false end
                    if ESP_Objects.Tracer then ESP_Objects.Tracer.Visible = false end
                    highlight.Enabled = false
                    return
                end

                local role = GetRole(player)
                local isRoleEnabled = ESP_Config.EnabledRoles[role]
                local roleColor = ESP_Config.Roles[role] or Color3.fromRGB(255, 255, 255)
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                -- 1. Highlight
                highlight.Enabled = (onScreen and isRoleEnabled and ESP_Config.ShowHighlight) or false
                highlight.FillColor = roleColor
                highlight.OutlineColor = roleColor

                -- 2. 3D Box
                if onScreen and isRoleEnabled and ESP_Config.ShowBox then
                    RefreshDrawing()
                    local size = Vector3.new(2, 3, 2)
                    local cf = hrp.CFrame
                    local vertices = {
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, size.Y, -size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, size.Y, -size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, size.Y, size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, size.Y, size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, -size.Y, -size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, -size.Y, -size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, -size.Y, size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, -size.Y, size.Z)).Position)
                    }
                    local conns = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
                    for i, conn in ipairs(conns) do
                        local l = ESP_Objects.Lines[i]
                        if l then
                            l.Visible = true
                            l.From = Vector2.new(vertices[conn[1]].X, vertices[conn[1]].Y)
                            l.To = Vector2.new(vertices[conn[2]].X, vertices[conn[2]].Y)
                            l.Color = roleColor
                        end
                    end
                else
                    for _, l in pairs(ESP_Objects.Lines) do l.Visible = false end
                end

                -- 3. Tracer
                if onScreen and isRoleEnabled and ESP_Config.ShowTracer then
                    RefreshDrawing()
                    if ESP_Objects.Tracer then
                        ESP_Objects.Tracer.Visible = true
                        ESP_Objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        ESP_Objects.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        ESP_Objects.Tracer.Color = roleColor
                    end
                else
                    if ESP_Objects.Tracer then ESP_Objects.Tracer.Visible = false end
                end
            end)
        end)
    end

    player.CharacterAdded:Connect(ApplyESP)
    if player.Character then ApplyESP(player.Character) end
end

-- ลบส่วน player.Removing ออก แล้วเปลี่ยนมาใช้ PlayerRemoving ของ Players แทน
Players.PlayerRemoving:Connect(function(player)
    -- ระบบจะจัดการผ่าน connection:Disconnect() ในลูป RenderStepped อยู่แล้ว
end)

task.spawn(function()
    for _, p in ipairs(Players:GetPlayers()) do CreateDrawingESP(p) end
    Players.PlayerAdded:Connect(CreateDrawingESP)
end)






_G.NameESPEnabled = false
_G.DistanceESPEnabled = false
local MaxDistance = 4000
local ESPCache = {}

local function CreateESP(Player)
    if Player == LP then return end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ReaperTag"
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    Billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local NameLabel = Instance.new("TextLabel", Billboard)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Size = UDim2.new(1, 0, 1, 0)
    NameLabel.Text = ""
    NameLabel.Font = Enum.Font.RobotoMono -- ฟอนต์ตามที่คุณใช้
    NameLabel.TextSize = 14
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextStrokeTransparency = 0
    NameLabel.RichText = true

    ESPCache[Player] = {
        Billboard = Billboard,
        NameLabel = NameLabel
    }
end

local function RemoveESP(Player)
    if ESPCache[Player] then
        if ESPCache[Player].Billboard then ESPCache[Player].Billboard:Destroy() end
        ESPCache[Player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for Player, ESP in pairs(ESPCache) do
        local Character = Player.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        local Hum = Character and Character:FindFirstChildOfClass("Humanoid")

        -- ตรวจสอบเงื่อนไข (ต้องมีตัวละคร, ไม่ตาย, อยู่ในระยะ)
        if not Character or not Root or not Hum or Hum.Health <= 0 then
            ESP.Billboard.Enabled = false
            continue
        end

        local Distance = (Camera.CFrame.Position - Root.Position).Magnitude
        local _, OnScreen = Camera:WorldToViewportPoint(Root.Position)

        -- ตรวจสอบระยะและตำแหน่งบนจอ
        if Distance > MaxDistance or not OnScreen then
            ESP.Billboard.Enabled = false
            continue
        end

        -- แสดงผล Name & Distance
        if _G.NameESPEnabled or _G.DistanceESPEnabled then
            ESP.Billboard.Enabled = true
            ESP.Billboard.Parent = Character:FindFirstChild("Head") or Root
            
            local NameTag = _G.NameESPEnabled and Player.Name or ""
            local DistTag = _G.DistanceESPEnabled and string.format(" <font color='#AAAAAA'>[ %dm ]</font>", math.floor(Distance)) or ""
            
            ESP.NameLabel.Text = NameTag .. DistTag
            -- ปรับขนาดตัวอักษรตามระยะทาง (ยิ่งไกลยิ่งเล็ก)
            ESP.NameLabel.TextSize = math.clamp(16 - (Distance / 150), 10, 16)
        else
            ESP.Billboard.Enabled = false
        end
    end
end)

-- เริ่มทำงานกับผู้เล่นในเซิร์ฟเวอร์
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

Tabs.ESP:AddToggle("NameESP", {
    Title = "ESP Name",
    Default = false,
    Callback = function(v) _G.NameESPEnabled = v end
})

Tabs.ESP:AddToggle("DistanceESP", {
    Title = "ESP Distance",
    Default = false,
    Callback = function(v) _G.DistanceESPEnabled = v end
})

--teleport
local selectedPlayer = nil
local teleportEnabled = false
local spectating = false

-- ฟังก์ชันดึงรายชื่อผู้เล่น (ยกเว้นตัวเอง)
local function getList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(list, p.Name)
        end
    end
    return list
end

-- สร้าง Dropdown สำหรับเลือกผู้เล่น
local Dropdown = Tabs.Teleport:AddDropdown("PlayerDropdown", {
    Title = "Select Player",
    Values = getList(),
    Multi = false,
    Default = nil
})

-- อัปเดตตัวแปรเมื่อมีการเลือกคนใน Dropdown
Dropdown:OnChanged(function(value)
    if value then
        selectedPlayer = Players:FindFirstChild(value)
        
        -- ถ้ากำลัง Spectate อยู่ ให้ย้ายกล้องไปหาคนใหม่ทันที
        if spectating and selectedPlayer and selectedPlayer.Character then
            local hum = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then Camera.CameraSubject = hum end
        end
    end
end)

-- ปุ่มรีเฟรชรายชื่อ
Tabs.Teleport:AddButton({
    Title = "Refresh Players",
    Callback = function()
        Dropdown:SetValues(getList())
    end
})

Tabs.Teleport:AddToggle("tp", {
    Title = "Teleport",
    Default = false,
    Callback = function(state)
        teleportEnabled = state

        if state then
            task.spawn(function()
                while teleportEnabled do
                    if selectedPlayer and selectedPlayer.Character then
                        local char = LP.Character
                        local target = selectedPlayer.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        local tRoot = target and target:FindFirstChild("HumanoidRootPart")

                        if root and tRoot then
                            -- ใช้ Tween เพื่อเคลื่อนที่ไปด้านบนหัวเป้าหมายเล็กน้อย
                            TweenService:Create(
                                root,
                                TweenInfo.new(0.4, Enum.EasingStyle.Linear),
                                {CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)}
                            ):Play()
                        end
                    end
                    task.wait(0.5) -- หน่วงเวลาเพื่อลดภาระเครื่อง
                end
            end)
        end
    end
})

Tabs.Teleport:AddToggle("spec", {
    Title = "Spectate Player",
    Default = false,
    Callback = function(state)
        spectating = state

        if state then
            -- ส่องเป้าหมาย
            if selectedPlayer and selectedPlayer.Character then
                local hum = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then Camera.CameraSubject = hum end
            end
        else
            -- กลับมาที่ตัวเรา
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then Camera.CameraSubject = hum end
        end
    end
})

---------------

InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)

InterfaceManager:SetFolder("ReaperHub")
SaveManager:SetFolder("ReaperHub/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)


if game.CoreGui:FindFirstChild("ToggleUI") then
    game.CoreGui.ToggleUI:Destroy()
end



local gui = Instance.new("ScreenGui")
gui.Name = "ToggleUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = game.CoreGui


local border = Instance.new("Frame")
border.Parent = gui
border.Size = UDim2.new(0,0,0,0)
border.BackgroundColor3 = Color3.fromRGB(0,0,0)
border.ZIndex = 1
border.AnchorPoint = Vector2.new(0,0)

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0,14)
borderCorner.Parent = border


local button = Instance.new("ImageButton")
button.Parent = gui
button.Size = UDim2.new(0,60,0,60)
button.Position = UDim2.new(0,60,0.2,0)
button.AnchorPoint = Vector2.new(0,0)

button.BackgroundTransparency = 1
button.ZIndex = 999999
button.AutoButtonColor = false

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = button

local imgOn = "rbxassetid://86279908104891"
local imgOff = "rbxassetid://86279908104891"

button.Image = imgOn
button.ScaleType = Enum.ScaleType.Fit


local function UpdateBorder()

    local offset = (border.Size.X.Offset - button.Size.X.Offset) / 2

    border.Position = UDim2.new(
        button.Position.X.Scale,
        button.Position.X.Offset - offset,
        button.Position.Y.Scale,
        button.Position.Y.Offset - offset
    )
end

UpdateBorder()


local dragging = false
local dragStart, startPos

button.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = button.Position
    end
end)

UIS.InputChanged:Connect(function(input)

    if dragging then

        local delta = input.Position - dragStart

        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

        UpdateBorder()
    end
end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)


local isOpen = true

button.MouseButton1Click:Connect(function()

    isOpen = not isOpen

    if Window then
        Window:Minimize(not isOpen)
    end

    button.Image = isOpen and imgOff or imgOn

end)


-- Load Success 
task.wait(0.5)
print("Reaper Hub Loaded")
