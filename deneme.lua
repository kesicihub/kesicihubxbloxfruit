local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local uiTarget = LocalPlayer:WaitForChild("PlayerGui", 5)
if not uiTarget then return end

for _, v in pairs(uiTarget:GetChildren()) do if v.Name == "KesiciHubLite" then v:Destroy() end end
pcall(function() if game:GetService("CoreGui"):FindFirstChild("KesiciHubLite") then game:GetService("CoreGui").KesiciHubLite:Destroy() end end)

local Settings = {
    AutoFruit = false
}

local function SmartTween(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    
    -- Hızlı ama stabil uçuş
    local t = TweenService:Create(hrp, TweenInfo.new(dist/300, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    t:Play(); t.Completed:Wait()
end

local KesiciUI = Instance.new("ScreenGui")
KesiciUI.Name = "KesiciHubLite"
KesiciUI.ResetOnSpawn = false
KesiciUI.Parent = uiTarget 

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 120) 
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = KesiciUI

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "RAW PHYSICS TEST"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = MainFrame

local function CreateToggle(name, yPos, action)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name .. ": OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
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

CreateToggle("Auto Fruit (Physics)", 50, function(state) Settings.AutoFruit = state end)

-- ==========================================
-- DÜMDÜZ FİZİKSEL TEMAS (FIRETOUCHINTEREST YOK)
-- ==========================================
task.spawn(function()
    while task.wait(0.2) do
        if Settings.AutoFruit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(workspace:GetDescendants()) do
                -- Meyve ismini bul
                if string.find(string.lower(obj.Name), "fruit") and (obj:IsA("Tool") or obj:IsA("Model")) then
                    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if handle then
                        -- Yanına Uç
                        SmartTween(handle.CFrame)
                        
                        local attempts = 0
                        -- Meyve silinene kadar milimetrik hareketlerle üstünde sürtün (Fiziksel touched tetikleyici)
                        while obj and obj.Parent and obj:IsDescendantOf(workspace) and attempts < 25 and Settings.AutoFruit do
                            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then 
                                -- X ve Z ekseninde çok hafif titreyerek doğal çarpmayı sağlar
                                hrp.CFrame = handle.CFrame * CFrame.new(math.random(-1, 1) * 0.2, 0, math.random(-1, 1) * 0.2)
                            end
                            task.wait(0.15)
                            attempts = attempts + 1
                        end
                    end
                end
            end
        end
    end
end)
