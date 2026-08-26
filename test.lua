-- ========================================================
-- [TEST SYSTEM] STABLE PARRY BUTTON + LIVE COOLDOWN
-- ========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============== STATE ==============
local TestState = {
    IsCooldown = false,
    RemainingCD = 0
}

-- ============== UI CREATION ==============
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "ParryTestUI"

local TestBtn = Instance.new("TextButton", ScreenGui)
TestBtn.Size = UDim2.new(0, 150, 0, 50)
TestBtn.Position = UDim2.new(0.5, -75, 0.2, 0) -- อยู่ตรงกลางบน
TestBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TestBtn.Text = "READY TO PARRY"
TestBtn.TextColor3 = Color3.fromRGB(80, 255, 150)
TestBtn.Font = Enum.Font.GothamBold
TestBtn.TextSize = 14

local UICorner = Instance.new("UICorner", TestBtn)
UICorner.CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", TestBtn)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(80, 255, 150)

-- ============== CORE FUNCTIONS ==============
local function StartCooldown(duration)
    TestState.RemainingCD = tonumber(duration) or 0.6
    TestState.IsCooldown = true
    
    TestBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TestBtn.TextColor3 = Color3.fromRGB(255, 150, 0)
    UIStroke.Color = Color3.fromRGB(255, 150, 0)

    while TestState.RemainingCD > 0 do
        TestBtn.Text = string.format("COOLDOWN: %.1fs", TestState.RemainingCD)
        task.wait(0.1)
        TestState.RemainingCD = math.max(0, TestState.RemainingCD - 0.1)
    end

    -- Reset UI เมื่อหมด CD
    TestState.IsCooldown = false
    TestBtn.Text = "READY TO PARRY"
    TestBtn.TextColor3 = Color3.fromRGB(80, 255, 150)
    TestBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    UIStroke.Color = Color3.fromRGB(80, 255, 150)
end

local function UseParry()
    if TestState.IsCooldown then return end

    local char = LocalPlayer.Character
    local dagger = char and (char:FindFirstChild("Parrying Dagger") or LocalPlayer.Backpack:FindFirstChild("Parrying Dagger"))
    
    pcall(function()
        -- 1. สั่งรัน Remote ของดาบ (ยิง 8 ครั้งเพื่อความเสถียรตามโค้ดต้นฉบับ)
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
            :FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
            
        if remote then
            for i = 1, 8 do remote:FireServer() end
        end

        -- 2. Activate Tool เพื่อให้แอนิเมชั่นดาบกางออก
        if dagger and dagger:IsA("Tool") then
            if dagger.Parent ~= char then
                char.Humanoid:EquipTool(dagger)
            end
            dagger:Activate()
        end
    end)
end

-- ============== LISTENERS ==============

-- ฟังค่าคูลดาวน์จริงจาก Server
task.spawn(function()
    local res = ReplicatedStorage:WaitForChild("Remotes")
        :WaitForChild("Items"):WaitForChild("Parrying Dagger")
        :WaitForChild("parryResult")
        
    res.OnClientEvent:Connect(function(_, cd)
        StartCooldown(cd)
    end)
end)

TestBtn.MouseButton1Click:Connect(function()
    if not TestState.IsCooldown then
        UseParry()
    end
end)

-- ทำให้ปุ่มลากได้
local dragging, dragStart, startPos
TestBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = TestBtn.Position
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart
        TestBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
game:GetService("UserInputService").InputEnded:Connect(function() dragging = false end)

print("HyperX: Parry Test Button Loaded.")
