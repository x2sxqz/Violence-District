-- ========================================================
-- [HYPERX] MANUAL PARRY TESTER (STABLE VERSION) 3
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

-- ============== UI CREATION ==============
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

-- ลากปุ่ม
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
    if TestState.IsCooldown then return end
    
    TestState.RemainingCD = tonumber(duration) or 0.6
    TestState.IsCooldown = true
    
    MainBtn.TextColor3 = Color3.fromRGB(255, 130, 0)
    UIStroke.Color = Color3.fromRGB(255, 130, 0)

    while TestState.RemainingCD > 0 do
        MainBtn.Text = string.format("COOLDOWN: %.1fs", TestState.RemainingCD)
        task.wait(0.05)
        TestState.RemainingCD = math.max(0, TestState.RemainingCD - 0.05)
    end

    TestState.IsCooldown = false
    MainBtn.Text = "READY TO PARRY"
    MainBtn.TextColor3 = Color3.fromRGB(80, 255, 150)
    UIStroke.Color = Color3.fromRGB(80, 255, 150)
end

local function ExecuteManualParry()
    -- 1. เช็คคูลดาวน์ทาง UI
    if TestState.IsCooldown then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum or hum.Health <= 0 then return end

    -- 2. หาไอเท็ม
    local dagger = char:FindFirstChild("Parrying Dagger") or LocalPlayer.Backpack:FindFirstChild("Parrying Dagger")
    if not dagger then return end

    pcall(function()
        -- 3. บังคับสวมใส่และรอจนกว่าเซิร์ฟเวอร์จะรับทราบ
        if dagger.Parent ~= char then
            hum:EquipTool(dagger)
            local timeout = 0
            while dagger.Parent ~= char and timeout < 0.3 do
                timeout = timeout + task.wait()
            end
        end

        -- 4. หา Remote
        local remoteFolder = ReplicatedStorage:FindFirstChild("Remotes")
            :FindFirstChild("Items"):FindFirstChild("Parrying Dagger")
        
        local parryRemote = remoteFolder:FindFirstChild("parry")

        if parryRemote then
            -- สั่งใช้งานแอนิเมชั่นฝั่ง Client ทันที
            dagger:Activate()
            
            -- ส่งคำสั่งไปเซิร์ฟเวอร์ (ปรับเหลือ 5 ครั้งเพื่อความสม่ำเสมอ)
            for i = 1, 5 do
                parryRemote:FireServer()
            end
        end
    end)
end

-- ============== LISTENERS ==============

-- เชื่อมปุ่มกด
MainBtn.MouseButton1Click:Connect(function()
    ExecuteManualParry()
end)

-- ฟังผลจากเซิร์ฟเวอร์ (ตัวแก้ปัญหาหลัก: คูลดาวน์จะเริ่มเมื่อของทำงานจริงเท่านั้น)
task.spawn(function()
    local itemPath = ReplicatedStorage:WaitForChild("Remotes")
        :WaitForChild("Items"):WaitForChild("Parrying Dagger")
        
    local resRemote = itemPath:WaitForChild("parryResult")
        
    resRemote.OnClientEvent:Connect(function(success, cdTime)
        if success then
            -- เริ่มนับคูลดาวน์เฉพาะเมื่อเซิร์ฟเวอร์ยืนยันว่า Parry ทำงาน
            UpdateCDUI(cdTime)
        end
    end)
end)

print("HyperX: Manual Parry Synced & Optimized.")
