-- ==================== HYPERX REMOTE SPY (STANDALONE) ====================

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Configuration
local IGNORED_REMOTES = {
    ["UpdateCharacterLook"] = true,
    ["CharacterLookUpdate"] = true
}

-- GUI Creation
local SpyGui = Instance.new("ScreenGui")
SpyGui.Name = "HyperX_RemoteSpy"
SpyGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
SpyGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SpyGui

local UICorner = Instance.new("UICorner", MainFrame)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(60, 60, 60)

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Header.Text = " REMOTE SPY - BY HYPERX"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Font = Enum.Font.GothamBold
Header.TextSize = 14
Header.Parent = MainFrame
Instance.new("UICorner", Header)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 3
Scroll.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding = UDim.new(0, 4)

-- Draggable Logic
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = obj.Position
        end
    end)
    obj.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end
MakeDraggable(MainFrame)

-- Add Log Function
local function NewRemoteLog(remote, args)
    local LogFrame = Instance.new("Frame")
    LogFrame.Size = UDim2.new(1, -5, 0, 45)
    LogFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    LogFrame.Parent = Scroll
    Instance.new("UICorner", LogFrame)

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0.65, 0, 1, 0)
    NameLabel.Position = UDim2.new(0, 10, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = remote.Name
    NameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextSize = 12
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.Parent = LogFrame

    local RunBtn = Instance.new("TextButton")
    RunBtn.Size = UDim2.new(0.25, 0, 0, 25)
    RunBtn.Position = UDim2.new(0.7, 0, 0.5, -12)
    RunBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    RunBtn.Text = "RUN"
    RunBtn.Font = Enum.Font.GothamBold
    RunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RunBtn.Parent = LogFrame
    Instance.new("UICorner", RunBtn)

    RunBtn.MouseButton1Click:Connect(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(args))
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(unpack(args))
        end
    end)

    Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end

-- Hook Metamethod
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        if not IGNORED_REMOTES[self.Name] then
            task.spawn(NewRemoteLog, self, args)
        end
    end
    return oldNamecall(self, ...)
end)
