-- [[ HyperX Full ESP System ]] --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local TargetName = ""
local ESP_Enabled = false

-- [[ UI Construction ]] --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
local UICorner = Instance.new("UICorner", MainFrame)
local UIStroke = Instance.new("UIStroke", MainFrame)
local Title = Instance.new("TextLabel", MainFrame)
local NameInput = Instance.new("TextBox", MainFrame)
local ToggleBtn = Instance.new("TextButton", MainFrame)

MainFrame.Size = UDim2.new(0, 260, 0, 180)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
UIStroke.Color = Color3.fromRGB(255, 0, 0) -- Red Accent
UIStroke.Thickness = 1.5
UICorner.CornerRadius = UDim.new(0, 8)

Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "HYPERX ESP OVERLAY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1

NameInput.Size = UDim2.new(0, 220, 0, 35)
NameInput.Position = UDim2.new(0.5, -110, 0.35, 0)
NameInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
NameInput.PlaceholderText = "Enter Mob Name..."
NameInput.Text = ""
NameInput.TextColor3 = Color3.new(1, 1, 1)
local InpCorner = Instance.new("UICorner", NameInput)

ToggleBtn.Size = UDim2.new(0, 220, 0, 40)
ToggleBtn.Position = UDim2.new(0.5, -110, 0.65, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Text = "STATUS: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
local BtnCorner = Instance.new("UICorner", ToggleBtn)

-- [[ Draggable Logic ]] --
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- [[ Full ESP Logic ]] --
local function CreateESP(model)
    if not model:FindFirstChild("HX_Highlight") then
        -- 1. Highlight (Red)
        local hl = Instance.new("Highlight")
        hl.Name = "HX_Highlight"
        hl.Parent = model
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.4
        
        -- 2. Tag (Name & Distance)
        local bill = Instance.new("BillboardGui")
        bill.Name = "HX_Tag"
        bill.Adornee = model:FindFirstChild("Head") or model.PrimaryPart
        bill.Size = UDim2.new(0, 100, 0, 50)
        bill.StudsOffset = Vector3.new(0, 3, 0)
        bill.AlwaysOnTop = true
        bill.Parent = model
        
        local text = Instance.new("TextLabel", bill)
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.new(1, 1, 1)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 12
        text.TextStrokeTransparency = 0
        
        task.spawn(function()
            while model:FindFirstChild("HX_Tag") and ESP_Enabled do
                local dist = math.floor((workspace.CurrentCamera.CFrame.Position - model.PrimaryPart.Position).Magnitude)
                text.Text = string.format("%s\n[%d m]", model.Name, dist)
                task.wait(0.1)
            end
        end)
    end
end

local function CleanESP()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "HX_Highlight" or v.Name == "HX_Tag" then v:Destroy() end
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    TargetName = NameInput.Text:lower()
    if ESP_Enabled then
        ToggleBtn.Text = "STATUS: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    else
        ToggleBtn.Text = "STATUS: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        CleanESP()
    end
end)

-- Main Loop (Optimized Search)
RunService.Heartbeat:Connect(function()
    if ESP_Enabled and TargetName ~= "" then
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.PrimaryPart and string.find(obj.Name:lower(), TargetName) then
                CreateESP(obj)
            end
        end
    end
end)
