--=========================
-- 🔥 Lib Load Screen Reaper Hub 7
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
SubTitle = "test",
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
ESP = Window:AddTab({ Title = "ESP", Icon = "box" }),
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}


--esp
--=========================
-- ⚙️ ESP CONFIGURATION
--=========================
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

--=========================
-- 🖱️ UI ELEMENTS (Dropdown & Toggles)
--=========================
local RoleDropdown = Tabs.ESP:AddDropdown("ESPRoles", {
    Title = "Select Roles to Display",
    Values = {"Survivors", "Killer", "Spectator"},
    Multi = true,
    Default = {},
})

RoleDropdown:OnChanged(function(Value)
    ESP_Config.EnabledRoles = Value
end)

Tabs.ESP:AddToggle("HighlightToggle", {Title = "Enable Highlight (Chams)", Default = false}):OnChanged(function(v)
    ESP_Config.ShowHighlight = v
end)

Tabs.ESP:AddToggle("BoxToggle", {Title = "Enable ESP Box (3D Wireframe)", Default = false}):OnChanged(function(v)
    ESP_Config.ShowBox = v
end)

Tabs.ESP:AddToggle("TracerToggle", {Title = "Enable Tracers (Line)", Default = false}):OnChanged(function(v)
    ESP_Config.ShowTracer = v
end)

--=========================
-- 🛠️ MASTER ESP ENGINE (3-IN-1: Chams, 3D Box, Tracer)
--=========================
local function GetRole(player)
    local team = player.Team and player.Team.Name or "None"
    local teamLower = team:lower()
    if string.find(teamLower, "killer") or string.find(teamLower, "murder") or string.find(teamLower, "beast") then return "Killer"
    elseif string.find(teamLower, "survivor") or string.find(teamLower, "innocent") or string.find(teamLower, "human") then return "Survivors" end
    return "Spectator"
end

local function CreateESP(player)
    if player == LocalPlayer then return end

    -- 1. 3D Wireframe Box (ใช้ SelectionBox เพื่อให้เป็นกรอบเส้นมองทะลุได้)
    local Box = Instance.new("SelectionBox")
    Box.Name = "R_SelectionBox"
    Box.Adornee = nil
    Box.LineThickness = 0.05
    Box.Transparency = 0 -- ความชัดของเส้นกรอบ
    Box.Parent = CoreGui

    -- 2. 2D Tracer (เส้นลาก)
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Thickness = 1.5
    Tracer.Transparency = 1

    local function ApplyESP(character)
        local hrp = character:WaitForChild("HumanoidRootPart", 10)
        local hum = character:WaitForChild("Humanoid", 10)
        
        -- 3. Chams (Highlight - ปรับให้ Fill ใสเพื่อให้มองทะลุเห็นตัวละคร)
        local highlight = character:FindFirstChild("R_Highlight") or Instance.new("Highlight")
        highlight.Name = "R_Highlight"
        highlight.Parent = character
        highlight.Enabled = false
        highlight.FillTransparency = 0.6 -- ปรับความใสของ Chams (0=ทึบ, 1=ใส)
        highlight.OutlineTransparency = 0

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not character or not character.Parent or not hrp.Parent or hum.Health <= 0 then
                Box.Adornee = nil
                Tracer.Visible = false
                highlight.Enabled = false
                if not player or not player.Parent then
                    Box:Destroy(); Tracer:Remove(); connection:Disconnect()
                end
                return
            end

            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local role = GetRole(player)
            local isRoleEnabled = ESP_Config.EnabledRoles[role]
            local roleColor = ESP_Config.Roles[role] or Color3.fromRGB(255, 255, 255)

            if onScreen and isRoleEnabled then
                -- อัปเดต Highlight (Chams)
                highlight.Enabled = ESP_Config.ShowHighlight
                highlight.FillColor = roleColor

                -- อัปเดต 3D Box (SelectionBox)
                if ESP_Config.ShowBox then
                    Box.Adornee = character
                    Box.Color3 = roleColor
                else 
                    Box.Adornee = nil 
                end

                -- อัปเดต Tracer (Line)
                if ESP_Config.ShowTracer then
                    Tracer.Visible = true
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    Tracer.Color = roleColor
                else 
                    Tracer.Visible = false 
                end
            else
                Box.Adornee = nil
                Tracer.Visible = false
                highlight.Enabled = false
            end
        end)
    end

    player.CharacterAdded:Connect(ApplyESP)
    if player.Character then task.spawn(ApplyESP, player.Character) end
end

-- เริ่มระบบ ESP
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)









--=========================
-- ⚙ SETTINGS TAB
--=========================

InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)

InterfaceManager:SetFolder("ReaperHub")
SaveManager:SetFolder("ReaperHub/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig() -- 🔥 ตัวนี้แหละ

Window:SelectTab(1)
-- Lib Toggle
--=========================
-- TOGGLE BUTTON
--=========================
if game.CoreGui:FindFirstChild("ToggleUI") then
    game.CoreGui.ToggleUI:Destroy()
end


--=========================
-- GUI
--=========================
local gui = Instance.new("ScreenGui")
gui.Name = "ToggleUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = game.CoreGui

--=========================
-- BORDER
--=========================
local border = Instance.new("Frame")
border.Parent = gui
border.Size = UDim2.new(0,0,0,0)
border.BackgroundColor3 = Color3.fromRGB(0,0,0)
border.ZIndex = 1
border.AnchorPoint = Vector2.new(0,0)

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0,14)
borderCorner.Parent = border

--=========================
-- BUTTON
--=========================
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

--=========================
-- IMAGE
--=========================
local imgOn = "rbxassetid://86279908104891"
local imgOff = "rbxassetid://86279908104891"

button.Image = imgOn
button.ScaleType = Enum.ScaleType.Fit

--=========================
-- AUTO ALIGN
--=========================
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

--=========================
-- DRAG SYSTEM
--=========================
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

--=========================
-- TOGGLE
--=========================
local isOpen = true

button.MouseButton1Click:Connect(function()

    isOpen = not isOpen

    if Window then
        Window:Minimize(not isOpen)
    end

    button.Image = isOpen and imgOff or imgOn

end)




-- Load Success 
task.wait(2)
print("Reaper Hub Loaded")
