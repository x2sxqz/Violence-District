-- ========================================================
-- [TEST SYSTEM] MANUAL PARRY TESTER (SYNCED COOLDOWN) 2
-- ========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============== STATE ==============
local TestState = {
    IsCooldown = false,
    RemainingCD = 0
}

-- ============== UI CREATION (DRAGGABLE) ==============
local TestGui = Instance.new("ScreenGui", PlayerGui)
TestGui.Name = "ParryTestModule"
TestGui.ResetOnSpawn = false

local MainBtn = Instance.new("TextButton", TestGui)
MainBtn.Size = UDim2.new(0, 160, 0, 50)
MainBtn.Position = UDim2.new(0.5, -80, 0.2, 0)
MainBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainBtn.Text = "READY TO PARRY"
MainBtn.TextColor3 = Color3.fromRGB(80, 255, 150)
MainBtn.Font = Enum.Font.GothamBold
MainBtn.TextSize = 14

local UICorner = Instance.new("UICorner", MainBtn)
UICorner.CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", MainBtn)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(80, 255, 150)

-- ระบบลากปุ่ม
local dragging, dragStart, startPos
MainBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = MainBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart
        MainBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function() dragging = false end)

-- ============== CORE FUNCTIONS ==============

local function UpdateCDUI(duration)
    TestState.RemainingCD = tonumber(duration) or 0.6
    TestState.IsCooldown = true
    
    MainBtn.TextColor3 = Color3.fromRGB(255, 130, 0)
    UIStroke.Color = Color3.fromRGB(255, 130, 0)

    while TestState.RemainingCD > 0 do
        MainBtn.Text = string.format("COOLDOWN: %.1fs", TestState.RemainingCD)
        task.wait(0.1)
        TestState.RemainingCD = math.max(0, TestState.RemainingCD - 0.1)
    end

    TestState.IsCooldown = false
    MainBtn.Text = "READY TO PARRY"
    MainBtn.TextColor3 = Color3.fromRGB(80, 255, 150)
    UIStroke.Color = Color3.fromRGB(80, 255, 150)
end

local function ExecuteManualParry()
    if TestState.IsCooldown then return end

    local char = LocalPlayer.Character
    if not char then return end

    -- ค้นหาไอเท็ม Parrying Dagger ในตัวหรือในกระเป๋า
    local dagger = char:FindFirstChild("Parrying Dagger") or LocalPlayer.Backpack:FindFirstChild("Parrying Dagger")
    
    pcall(function()
        -- 1. เรียกใช้ Remote (ส่ง 8 ครั้งตามต้นฉบับ)
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
            :FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
            
        if remote then
            for i = 1, 8 do remote:FireServer() end
        end

        -- 2. บังคับใช้ไอเท็มจริง (เพื่อให้แอนิเมชั่นดาบขึ้น)
        if dagger and dagger:IsA("Tool") then
            if dagger.Parent ~= char then
                char.Humanoid:EquipTool(dagger)
            end
            dagger:Activate()
        end
    end)
end

-- ============== LISTENERS ==============

-- ฟังผลจากเซิร์ฟเวอร์เพื่อเริ่มคูลดาวน์จริง
task.spawn(function()
    local resRemote = ReplicatedStorage:WaitForChild("Remotes")
        :WaitForChild("Items"):WaitForChild("Parrying Dagger")
        :WaitForChild("parryResult")
        
    resRemote.OnClientEvent:Connect(function(success, cdTime)
        UpdateCDUI(cdTime)
    end)
end)

MainBtn.MouseButton1Click:Connect(function()
    ExecuteManualParry()
end)

print("HyperX: Parry Test Button Loaded.")
