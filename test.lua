local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- [ Configuration ]
local Config = {
    Enabled = false,
    Mode = "Legit" -- "Legit" หรือ "Instant"
}

local State = { busy = false }

-- [ UI Setup ]
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "HyperX_SkillCheck"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 150, 0, 100)
MainFrame.Position = UDim2.new(0.5, -75, 0.5, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "HYPERX AUTO SKILL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 25)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.Text = "Status: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.Gotham
local BtnCorner = Instance.new("UICorner", ToggleBtn)

-- Mode Button
local ModeBtn = Instance.new("TextButton", MainFrame)
ModeBtn.Size = UDim2.new(0.9, 0, 0, 25)
ModeBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
ModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ModeBtn.Text = "Mode: Legit"
ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.Font = Enum.Font.Gotham
local ModeCorner = Instance.new("UICorner", ModeBtn)

-- [ Logic ]
local function Trigger()
    if UserInputService.TouchEnabled then
        local ActionPath = "Survivor-mob.Controls.action.check"
        local b = PlayerGui
        for segment in string.gmatch(ActionPath, "[^%.]+") do
            b = b and b:FindFirstChild(segment)
        end
        if b and b:IsA("GuiObject") then
            local p, s = b.AbsolutePosition, b.AbsoluteSize
            local i = game:GetService("GuiService"):GetGuiInset()
            local cx, cy = p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y
            VirtualInputManager:SendTouchEvent(8822, 0, cx, cy)
            task.wait(0.01)
            VirtualInputManager:SendTouchEvent(8822, 2, cx, cy)
        end
    else
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "Status: ON" or "Status: OFF"
    ToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

ModeBtn.MouseButton1Click:Connect(function()
    Config.Mode = (Config.Mode == "Legit") and "Instant" or "Legit"
    ModeBtn.Text = "Mode: " .. Config.Mode
end)

RunService.RenderStepped:Connect(function()
    if not Config.Enabled or State.busy then return end
    
    local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
    local check = prompt and prompt:FindFirstChild("Check")
    if not check or not check.Visible then return end
    
    local line = check:FindFirstChild("Line")
    local goal = check:FindFirstChild("Goal")
    if not line or not goal then return end

    if Config.Mode == "Instant" then
        line.Rotation = goal.Rotation + 109
        State.busy = true
        task.spawn(function()
            Trigger()
            task.wait(0.2)
            State.busy = false
        end)
    else
        local lr = line.Rotation % 360
        local gr = goal.Rotation % 360
        local startRange = (gr + 102) % 360
        local endRange   = (gr + 116) % 360
        
        if (startRange > endRange and (lr >= startRange or lr <= endRange)) or (lr >= startRange and lr <= endRange) then
            State.busy = true
            task.spawn(function()
                Trigger()
                task.wait(0.1)
                State.busy = false
            end)
        end
    end
end)
