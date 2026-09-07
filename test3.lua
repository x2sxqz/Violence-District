local v_u_1 = game:GetService("ReplicatedStorage")
local v_u_2 = game:GetService("UserInputService")
local v_u_3 = game:GetService("RunService")
local v_u_4 = game:GetService("Players")
local v_u_5 = game:GetService("CollectionService")
local v_u_6 = game:GetService("TweenService")
local v_u_7 = {}
v_u_7.__index = v_u_7
local v_u_8 = Color3.fromRGB(77, 77, 77)
local v_u_9 = Color3.fromRGB(255, 255, 255)
function v_u_7.new(p10) -- name: new
    -- upvalues: (copy) v_u_7, (copy) v_u_4, (copy) v_u_1, (copy) v_u_5
    assert(p10, "ParryClient config is required")
    local v11 = p10.tool
    assert(v11, "ParryClient requires config.tool")
    local v12 = p10.animationId
    assert(v12, "ParryClient requires config.animationId")
    local v13 = v_u_7
    local v14 = setmetatable({}, v13)
    v14.tool = p10.tool
    local v15 = p10.animationId
    v14.animationId = tostring(v15)
    local v16 = p10.lockDuration
    v14.lockDuration = tonumber(v16) or 0.8
    v14.debug = p10.debug == true
    v14.player = v_u_4.LocalPlayer
    v14.playerGui = v14.player:WaitForChild("PlayerGui")
    local v17 = v_u_1:WaitForChild("Remotes")
    v14.daggerFolder = v17:WaitForChild("Items"):WaitForChild("Parrying Dagger")
    v14.parryEvent = v14.daggerFolder:WaitForChild("parry")
    v14.parryResult = v14.daggerFolder:WaitForChild("parryResult")
    v14.slow = v17:WaitForChild("Mechanics"):WaitForChild("Slow")
    v14.character = nil
    v14.rootPart = nil
    v14.humanoid = nil
    v14.animator = nil
    v14.parryTrack = nil
    v14.gradients = {}
    v14.cooldownToken = 0
    v14.isSilenced = false
    v14.isParryOnCooldown = false
    v14.isParryResolving = false
    v14:_bindCharacter(v14.player.Character or v14.player.CharacterAdded:Wait())
    v14:_bindPcGradient()
    v14:_watchMobileGui()
    v14:_bindSignals()
    v14.isSilenced = v_u_5:HasTag(v14.character, "Silenced")
    v14:_refreshVisual()
    if v14.debug then
        print("[ParryClient] Ready for tool:", v14.tool:GetFullName(), "animation:", v14.animationId)
    end
    return v14
end
function v_u_7._log(p18, ...) -- name: _log
    if p18.debug then
        print("[ParryClient]", ...)
    end
end
function v_u_7._bindCharacter(p19, p20) -- name: _bindCharacter
    p19.character = p20
    p19.rootPart = p20:WaitForChild("HumanoidRootPart")
    p19.humanoid = p20:WaitForChild("Humanoid")
    p19.animator = p19.humanoid:WaitForChild("Animator")
    p19:_setupParryAnimation()
end
function v_u_7._setupParryAnimation(p21) -- name: _setupParryAnimation
    local v22 = Instance.new("Animation")
    v22.AnimationId = "rbxassetid://" .. p21.animationId
    p21.parryTrack = p21.animator:LoadAnimation(v22)
    p21.parryTrack.Priority = Enum.AnimationPriority.Action
end
function v_u_7._addGradient(p23, p24) -- name: _addGradient
    if p24 and p24:IsA("UIGradient") then
        for _, v25 in ipairs(p23.gradients) do
            if v25 == p24 then
                return
            end
        end
        p24.Offset = Vector2.new(0, 0.25)
        local v26 = p23.gradients
        table.insert(v26, p24)
    end
end
function v_u_7._bindPcGradient(p27) -- name: _bindPcGradient
    local v28 = p27.playerGui:FindFirstChild("Survivor") or p27.playerGui:FindFirstChild("Survivor-con")
    if v28 then
        local v29 = v28:FindFirstChild("Gen")
        if v29 then
            local v30 = v29:FindFirstChild("ItemFrame")
            if v30 then
                local v31 = v30:FindFirstChild("Gui")
                if v31 then
                    local v32 = v31:FindFirstChild("Bar")
                    if v32 then
                        local v33 = v32:FindFirstChild("UIGradient")
                        if v33 then
                            p27:_addGradient(v33)
                        end
                    end
                else
                    return
                end
            else
                return
            end
        else
            return
        end
    else
        return
    end
end
function v_u_7._setIconsColor(p34, p35) -- name: _setIconsColor
    for _, v36 in ipairs(p34.gradients) do
        if v36 and (v36.Parent and v36.Parent.Parent) then
            local v37 = v36.Parent.Parent
            local v38 = v37:FindFirstChild("icon")
            if v38 then
                v38.ImageColor3 = p35
            end
            local v39 = v37.Parent
            if v39 then
                local v40 = v39:FindFirstChild("Gui")
                if v40 then
                    v40.ImageColor3 = p35
                end
            end
        end
    end
end
function v_u_7._refreshVisual(p41) -- name: _refreshVisual
    -- upvalues: (copy) v_u_8, (copy) v_u_9
    if p41.isSilenced or (p41.isParryOnCooldown or p41.isParryResolving) then
        p41:_setIconsColor(v_u_8)
    else
        p41:_setIconsColor(v_u_9)
    end
end
function v_u_7._playCooldownTween(p_u_42, p43) -- name: _playCooldownTween
    -- upvalues: (copy) v_u_6
    for _, v44 in ipairs(p_u_42.gradients) do
        if v44 and v44.Parent then
            v44.Offset = Vector2.new(0, 0.75)
            local v45 = v_u_6:Create(v44, TweenInfo.new(p43, Enum.EasingStyle.Linear), {
                ["Offset"] = Vector2.new(0, 0.25)
            })
            v45:Play()
            v45.Completed:Connect(function()
                -- upvalues: (copy) p_u_42
                p_u_42:_refreshVisual()
            end)
        end
    end
end
function v_u_7._startCooldown(p_u_46, p47) -- name: _startCooldown
    p_u_46.cooldownToken = p_u_46.cooldownToken + 1
    local v_u_48 = p_u_46.cooldownToken
    p_u_46.isParryResolving = false
    p_u_46.isParryOnCooldown = true
    p_u_46:_refreshVisual()
    p_u_46:_playCooldownTween(p47)
    p_u_46:_log("Cooldown started:", p47)
    task.delay(p47, function()
        -- upvalues: (copy) p_u_46, (copy) v_u_48
        if p_u_46.cooldownToken == v_u_48 then
            p_u_46.isParryOnCooldown = false
            p_u_46:_refreshVisual()
            p_u_46:_log("Cooldown ended")
        end
    end)
end
function v_u_7._faceLookDirection(p_u_49) -- name: _faceLookDirection
    -- upvalues: (copy) v_u_6, (copy) v_u_3
    local v50 = workspace.CurrentCamera
    if v50 and (p_u_49.rootPart and p_u_49.rootPart.Parent) then
        local v51 = v50.CFrame.LookVector
        local v52 = v51.X
        local v53 = v51.Z
        local v_u_54 = Vector3.new(v52, 0, v53)
        if v_u_54.Magnitude > 0 then
            local v55 = {
                ["CFrame"] = CFrame.new(p_u_49.rootPart.Position, p_u_49.rootPart.Position + v_u_54.Unit)
            }
            local v56 = v_u_6:Create(p_u_49.rootPart, TweenInfo.new(0.2, Enum.EasingStyle.Linear), v55)
            v56:Play()
            v56.Completed:Connect(function()
                -- upvalues: (copy) p_u_49, (ref) v_u_3, (ref) v_u_54
                if p_u_49.humanoid and p_u_49.humanoid.Parent then
                    p_u_49.humanoid.AutoRotate = true
                    local v_u_57 = tick()
                    local v_u_58 = nil
                    v_u_58 = v_u_3.Heartbeat:Connect(function()
                        -- upvalues: (copy) v_u_57, (ref) p_u_49, (ref) v_u_58, (ref) v_u_54
                        if tick() - v_u_57 >= p_u_49.lockDuration then
                            v_u_58:Disconnect()
                            return
                        elseif p_u_49.rootPart and p_u_49.rootPart.Parent then
                            p_u_49.rootPart.CFrame = CFrame.new(p_u_49.rootPart.Position, p_u_49.rootPart.Position + v_u_54.Unit)
                        else
                            v_u_58:Disconnect()
                        end
                    end)
                end
            end)
        end
    else
        return
    end
end
function v_u_7._isBusy(p59) -- name: _isBusy
    -- upvalues: (copy) v_u_5
    if p59.player:GetAttribute("IsDead") then
        return true
    end
    if p59.character:GetAttribute("IsCarried") then
        return true
    end
    if p59.character:GetAttribute("IsHooked") then
        return true
    end
    if v_u_5:HasTag(p59.rootPart, "doing action") then
        return true
    end
    local v60 = p59.character:FindFirstChild("CheckInterractable")
    if v60 then
        for _, v61 in ipairs({
            "isVaulting",
            "isSliding",
            "isDroppingPallet",
            "isRepairing",
            "isHealing",
            "isUnhooking",
            "isExiting"
        }) do
            if v60:GetAttribute(v61) then
                return true
            end
        end
    end
    return false
end
function v_u_7._isLowHealth(p62) -- name: _isLowHealth
    return p62.humanoid.Health < p62.humanoid.MaxHealth * 0.5
end
function v_u_7._isEquipped(p63) -- name: _isEquipped
    local v64 = p63.tool and p63.character
    if v64 then
        v64 = p63.tool:IsDescendantOf(p63.character)
    end
    return v64
end
function v_u_7.CanUse(p65) -- name: CanUse
    if not p65:_isEquipped() then
        p65:_log("CanUse=false reason=not equipped toolParent=", p65.tool.Parent)
        return false
    end
    if p65.isSilenced then
        p65:_log("CanUse=false reason=silenced")
        return false
    end
    if p65.isParryOnCooldown then
        p65:_log("CanUse=false reason=cooldown")
        return false
    end
    if p65.isParryResolving then
        p65:_log("CanUse=false reason=resolving")
        return false
    end
    if p65:_isBusy() then
        p65:_log("CanUse=false reason=busy")
        return false
    end
    if not p65:_isLowHealth() then
        return true
    end
    p65:_log("CanUse=false reason=low health")
    return false
end
function v_u_7.Parry(p66) -- name: Parry
    -- upvalues: (copy) v_u_5
    if p66:CanUse() then
        p66:_log("Parry input accepted")
        p66.isParryResolving = true
        p66:_refreshVisual()
        p66.parryEvent:FireServer()
        p66:_log("Fired parryEvent")
        p66:_faceLookDirection()
        p66.humanoid.AutoRotate = false
        if p66.parryTrack then
            p66.parryTrack:Play()
        end
        v_u_5:AddTag(p66.rootPart, "doing action")
        p66.slow:Fire(0, 1, 0)
        if p66.parryTrack then
            p66.parryTrack.Stopped:Wait()
        end
        if p66.rootPart and p66.rootPart.Parent then
            v_u_5:RemoveTag(p66.rootPart, "doing action")
        end
    end
end
function v_u_7._bindMobileButton(p_u_67, p68) -- name: _bindMobileButton
    if p68:IsA("ImageButton") and p68.Name == "Gui-mob" then
        p_u_67:_addGradient((p68:WaitForChild("Bar"):WaitForChild("UIGradient")))
        p_u_67:_refreshVisual()
        p68.MouseButton1Down:Connect(function()
            -- upvalues: (copy) p_u_67
            if p_u_67:CanUse() then
                p_u_67:Parry()
            end
        end)
    end
end
function v_u_7._watchControlsFolder(p_u_69, p_u_70) -- name: _watchControlsFolder
    local v71 = p_u_70:FindFirstChild("Controls")
    if v71 then
        for _, v72 in ipairs(v71:GetChildren()) do
            p_u_69:_bindMobileButton(v72)
        end
        v71.ChildAdded:Connect(function(p73)
            -- upvalues: (copy) p_u_69
            p_u_69:_bindMobileButton(p73)
        end)
    else
        p_u_70.ChildAdded:Connect(function(p74)
            -- upvalues: (copy) p_u_69, (copy) p_u_70
            if p74.Name == "Controls" then
                p_u_69:_watchControlsFolder(p_u_70)
            end
        end)
    end
end
function v_u_7._watchMobileGui(p_u_75) -- name: _watchMobileGui
    local v76 = p_u_75.player:FindFirstChildOfClass("PlayerGui")
    if v76 then
        local v77 = v76:FindFirstChild("Survivor-mob")
        if v77 then
            p_u_75:_watchControlsFolder(v77)
        else
            v76.ChildAdded:Connect(function(p78)
                -- upvalues: (copy) p_u_75
                if p78.Name == "Survivor-mob" then
                    p_u_75:_watchControlsFolder(p78)
                end
            end)
        end
    else
        return
    end
end
function v_u_7._bindSignals(p_u_79) -- name: _bindSignals
    -- upvalues: (copy) v_u_2, (copy) v_u_5
    v_u_2.InputBegan:Connect(function(p80, p81)
        -- upvalues: (copy) p_u_79
        if not p81 then
            local v82 = p_u_79.player:GetAttribute("platform") or "PC"
            if v82 == "PC" then
                if p80.UserInputType == Enum.UserInputType.MouseButton2 then
                    p_u_79:_log("M2 detected")
                    if p_u_79:CanUse() then
                        p_u_79:Parry()
                        return
                    end
                end
            elseif v82 == "Console" and (p80.KeyCode == Enum.KeyCode.ButtonL2 and p_u_79:CanUse()) then
                p_u_79:Parry()
            end
        end
    end)
    p_u_79.parryResult.OnClientEvent:Connect(function(p83, p84)
        -- upvalues: (copy) p_u_79
        if p_u_79.isParryResolving then
            p_u_79:_log("Received parryResult success=", p83, "cooldown=", p84)
            local v85 = tonumber(p84)
            if v85 and v85 > 0 then
                p_u_79:_startCooldown(v85)
            else
                p_u_79.isParryResolving = false
                p_u_79:_refreshVisual()
            end
        else
            return
        end
    end)
    v_u_5:GetInstanceAddedSignal("Silenced"):Connect(function(p86)
        -- upvalues: (copy) p_u_79
        if p86 == p_u_79.character then
            p_u_79.isSilenced = true
            p_u_79:_refreshVisual()
            if p_u_79.parryTrack and p_u_79.parryTrack.IsPlaying then
                p_u_79.parryTrack:Stop()
            end
        end
    end)
    v_u_5:GetInstanceRemovedSignal("Silenced"):Connect(function(p87)
        -- upvalues: (copy) p_u_79
        if p87 == p_u_79.character then
            p_u_79.isSilenced = false
            p_u_79:_refreshVisual()
        end
    end)
    p_u_79.player.CharacterAdded:Connect(function(p88)
        -- upvalues: (copy) p_u_79, (ref) v_u_5
        p_u_79.character = p88
        p_u_79.rootPart = p_u_79.character:WaitForChild("HumanoidRootPart")
        p_u_79.humanoid = p_u_79.character:WaitForChild("Humanoid")
        p_u_79.animator = p_u_79.humanoid:WaitForChild("Animator")
        p_u_79:_setupParryAnimation()
        local v89 = p_u_79
        v89.cooldownToken = v89.cooldownToken + 1
        p_u_79.isParryOnCooldown = false
        p_u_79.isParryResolving = false
        p_u_79.isSilenced = v_u_5:HasTag(p_u_79.character, "Silenced")
        p_u_79:_refreshVisual()
    end)
end
return v_u_7

character:FindFirstChild("Lookscriptkiller", true)


139369275981139
121216847022485
78935059863801
74968262036854
82666958311998
78432063483146
132817836308238
111920872708571
138720291317243
130593238885843
106871536134254
109402730355822
