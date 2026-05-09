--[[
    =========================================================
    PROJECT: KESICI HUB v26 - BLOX FRUITS (PURE PHYSICS)
    DEVELOPER: Deniz Kesici
    FIXES: Removed ALL firetouchinterest calls. Native Physics only.
    =========================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local uiTarget = LocalPlayer:WaitForChild("PlayerGui", 5)
if not uiTarget then return end

for _, v in pairs(uiTarget:GetChildren()) do if v.Name == "KesiciHubLite" then v:Destroy() end end
pcall(function() if game:GetService("CoreGui"):FindFirstChild("KesiciHubLite") then game:GetService("CoreGui").KesiciHubLite:Destroy() end end)

local Settings = {
    FruitESP = false,
    ChestESP = false,
    PlayerESP = false,
    AutoChest = false,
    AutoFruit = false,
    AutoFarm = false,
    Misc = { Noclip = false }
}

local IgnoredFruits = {}

-- ==========================================
-- SMART FLIGHT ENGINE
-- ==========================================
local function SmartTween(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local targetPos = targetCFrame.Position
    local dist = (hrp.Position - targetPos).Magnitude
    local speed = 300 
    
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    if dist > 150 then
        local skyPos = CFrame.new(hrp.Position.X, math.max(hrp.Position.Y, targetPos.Y) + 300, hrp.Position.Z)
        local t1 = TweenService:Create(hrp, TweenInfo.new((hrp.Position - skyPos.Position).Magnitude/speed, Enum.EasingStyle.Linear), {CFrame = skyPos})
        t1:Play(); t1.Completed:Wait()

        local overTarget = CFrame.new(targetPos.X, skyPos.Position.Y, targetPos.Z)
        local t2 = TweenService:Create(hrp, TweenInfo.new((skyPos.Position - overTarget.Position).Magnitude/speed, Enum.EasingStyle.Linear), {CFrame = overTarget})
        t2:Play(); t2.Completed:Wait()
        
        local t3 = TweenService:Create(hrp, TweenInfo.new((overTarget.Position - targetPos).Magnitude/speed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        t3:Play(); t3.Completed:Wait()
    else
        local t = TweenService:Create(hrp, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        t:Play(); t.Completed:Wait()
    end
    
    if bv then bv:Destroy() end
end

-- ==========================================
-- LITE MENU UI 
-- ==========================================
local KesiciUI = Instance.new("ScreenGui")
KesiciUI.Name = "KesiciHubLite"
KesiciUI.ResetOnSpawn = false
KesiciUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KesiciUI.Parent = uiTarget 

local MenuToggleBtn = Instance.new("TextButton")
MenuToggleBtn.Size = UDim2.new(0, 50, 0, 50)
MenuToggleBtn.Position = UDim2.new(0, 10, 0.5, -60)
MenuToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuToggleBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
MenuToggleBtn.Text = "⚓"
MenuToggleBtn.TextSize = 25
MenuToggleBtn.Visible = true 
MenuToggleBtn.Parent = KesiciUI
Instance.new("UICorner", MenuToggleBtn).CornerRadius = UDim.new(1, 0)
local Stroke = Instance.new("UIStroke", MenuToggleBtn)
Stroke.Color = Color3.fromRGB(0, 150, 255)
Stroke.Thickness = 1.5

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 280) 
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
MainFrame.Visible = false 
MainFrame.Parent = KesiciUI
MainFrame.Active = true
MainFrame.Draggable = true 

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "KESICI HUB - v26"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = MainFrame

MenuToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function CreateToggle(name, yPos, action)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name .. ": OFF"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
        action(state)
    end)
end

CreateToggle("Chest ESP", 40, function(state) Settings.ChestESP = state end)
CreateToggle("Fruit ESP", 75, function(state) Settings.FruitESP = state end)
CreateToggle("Player ESP", 110, function(state) Settings.PlayerESP = state end)
CreateToggle("Auto Chest Farm", 155, function(state) Settings.AutoChest = state end)
CreateToggle("Auto Fruit Sniper", 190, function(state) Settings.AutoFruit = state end)
CreateToggle("Auto Farm (Nearest)", 235, function(state) Settings.AutoFarm = state end)

-- ==========================================
-- ENGINE LOOPS
-- ==========================================

-- ESP SYSTEM
local function GetHighlight(parent, name, color)
    local hl = parent:FindFirstChild(name)
    if not hl then hl = Instance.new("Highlight"); hl.Name = name; hl.Parent = parent; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0.2 end
    hl.FillColor = color; hl.OutlineColor = color
    return hl
end

task.spawn(function()
    while task.wait(1) do
        for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then local hl = v.Character:FindFirstChild("KesiciESP"); if Settings.PlayerESP then GetHighlight(v.Character, "KesiciESP", Color3.fromRGB(255, 0, 0)) elseif hl then hl:Destroy() end end end
        
        for _, obj in pairs(workspace:GetDescendants()) do
            local n = string.lower(obj.Name)
            local hl = obj:FindFirstChild("KesiciObjESP")
            
            if Settings.ChestESP and string.find(n, "chest") then 
                GetHighlight(obj, "KesiciObjESP", Color3.fromRGB(255, 255, 0))
            elseif Settings.FruitESP and string.find(n, "fruit") and (obj:IsA("Tool") or obj:IsA("Model")) then 
                GetHighlight(obj, "KesiciObjESP", Color3.fromRGB(255, 0, 255))
            elseif hl then 
                hl:Destroy() 
            end
        end
    end
end)

-- AUTO CHEST (SAF FİZİK MOTORU)
task.spawn(function()
    while task.wait(0.5) do
        if Settings.AutoChest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local chests = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Part") and string.find(string.lower(obj.Name), "chest") then table.insert(chests, obj) end
            end
            for _, chest in pairs(chests) do
                if not Settings.AutoChest then break end
                if chest and chest.Parent then 
                    SmartTween(chest.CFrame)
                    local timeout = 0
                    while chest and chest.Parent and timeout < 20 and Settings.AutoChest do
                        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then 
                            -- Sandığın tam üstüne ufak titreşimlerle oturarak oyunun doğal dokunma hissini tetikler
                            hrp.CFrame = chest.CFrame * CFrame.new(math.random(-1, 1) * 0.1, 0, math.random(-1, 1) * 0.1)
                        end 
                        task.wait(0.1)
                        timeout = timeout + 1
                    end
                end
            end
        end
    end
end)

-- AUTO FRUIT SNIPER (SAF FİZİK MOTORU VE SOY AĞACI KORUMASI)
task.spawn(function()
    while task.wait(0.5) do
        if Settings.AutoFruit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            
            for _, obj in ipairs(workspace:GetDescendants()) do
                if not Settings.AutoFruit then break end
                
                if IgnoredFruits[obj] then continue end
                
                local name = string.lower(obj.Name)
                if string.find(name, "fruit") then
                    local handle = obj:FindFirstChild("Handle") or (obj:IsA("BasePart") and obj)
                    
                    if handle and handle:IsA("BasePart") then
                        -- Shop masalarındaki veya oyuncuların elindeki meyveleri engellemek için güvenlik duvarı
                        local isSafe = true
                        local parentCheck = obj.Parent
                        while parentCheck and parentCheck ~= game do
                            if parentCheck:FindFirstChild("Humanoid") then
                                isSafe = false
                                break
                            end
                            parentCheck = parentCheck.Parent
                        end

                        if isSafe then
                            SmartTween(handle.CFrame)
                            
                            local attempts = 0
                            while obj and obj.Parent and obj:IsDescendantOf(workspace) and attempts < 25 and Settings.AutoFruit do
                                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then 
                                    -- firetouchinterest YOK. 
                                    -- Karakteri meyvenin merkezinde milimetrik olarak hareket ettirip fizik motorunu (Touched event) uyandırıyoruz.
                                    hrp.CFrame = handle.CFrame * CFrame.new(math.random(-1, 1) * 0.2, 0, math.random(-1, 1) * 0.2)
                                end
                                task.wait(0.15)
                                attempts = attempts + 1
                            end
                            
                            if attempts >= 25 then
                                IgnoredFruits[obj] = true
                            end
                        end
                    end
                end
            end
            
        end
    end
end)

-- AUTO FARM (NEAREST MOB)
task.spawn(function()
    while task.wait(0.15) do 
        if Settings.AutoFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local char = LocalPlayer.Character
            local hrp = char.HumanoidRootPart
            local targetMob = nil
            local shortestDist = math.huge

            if workspace:FindFirstChild("Enemies") then
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                    local mobHum = mob:FindFirstChild("Humanoid")
                    if mobHrp and mobHum and mobHum.Health > 0 then
                        local dist = (hrp.Position - mobHrp.Position).Magnitude
                        if dist < shortestDist then shortestDist = dist; targetMob = mob end
                    end
                end
            end

            if targetMob then
                local mobHrp = targetMob:FindFirstChild("HumanoidRootPart")
                if mobHrp then
                    local targetCFrame = mobHrp.CFrame * CFrame.new(0, 7, 0) 
                    if shortestDist > 40 then 
                        SmartTween(targetCFrame) 
                    else 
                        hrp.CFrame = targetCFrame 
                        hrp.CFrame = CFrame.lookAt(hrp.Position, mobHrp.Position)
                        
                        if not char:FindFirstChildOfClass("Tool") then
                            pcall(function()
                                VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                                task.wait(0.05)
                                VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                            end)
                        end
                        
                        if char:FindFirstChildOfClass("Tool") then
                            pcall(function()
                                local camX = Camera.ViewportSize.X / 2
                                local camY = Camera.ViewportSize.Y / 2
                                VIM:SendMouseButtonEvent(camX, camY, 0, true, game, 1)
                                task.wait(0.05)
                                VIM:SendMouseButtonEvent(camX, camY, 0, false, game, 1)
                            end)
                        end
                    end
                end
            end
        end
    end
end)
