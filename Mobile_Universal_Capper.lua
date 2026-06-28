-- [[ MAIN GUI SETUP ]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Safe PlayerModule retrieval (Bypasses the mobile loading screen trap seamlessly)
local PlayerModule
task.spawn(function()
    local playerScripts = localPlayer:WaitForChild("PlayerScripts", 10)
    if playerScripts then
        pcall(function()
            PlayerModule = require(playerScripts:WaitForChild("PlayerModule", 5))
        end)
    end
end)

-- Core ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CapperGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 570, 0, 480)
mainFrame.Position = UDim2.new(0.5, -285, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- [[ MOBILE TOGGLE BUTTON ]]
local mobileToggleBtn = Instance.new("TextButton")
mobileToggleBtn.Name = "MobileMenuToggle"
mobileToggleBtn.Size = UDim2.new(0, 60, 0, 60)
mobileToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
mobileToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mobileToggleBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
mobileToggleBtn.Text = "Menu"
mobileToggleBtn.Font = Enum.Font.SourceSansBold
mobileToggleBtn.TextSize = 16
mobileToggleBtn.Active = true
mobileToggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 30)
toggleCorner.Parent = mobileToggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(0, 150, 255)
toggleStroke.Thickness = 2
toggleStroke.Parent = mobileToggleBtn

mobileToggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Dragging Implementation (Optimized perfectly for Mobile/Touch)
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Top Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Capper"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.Parent = mainFrame

-- Left Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(0, 150, 1, -40)
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Vertical
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabBar

-- Universal Tab Button
local universalTabBtn = Instance.new("TextButton")
universalTabBtn.Name = "UniversalTab"
universalTabBtn.Size = UDim2.new(1, 0, 0, 40)
universalTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
universalTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
universalTabBtn.Text = "Universal"
universalTabBtn.Font = Enum.Font.SourceSans
universalTabBtn.TextSize = 18
universalTabBtn.BorderSizePixel = 0
universalTabBtn.LayoutOrder = 1
universalTabBtn.Parent = tabBar

-- Content Container
local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Name = "UniversalContent"
contentContainer.Size = UDim2.new(1, -170, 1, -50)
contentContainer.Position = UDim2.new(0, 160, 0, 45)
contentContainer.BackgroundTransparency = 1
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 600)
contentContainer.ScrollBarThickness = 6
contentContainer.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 15)
contentLayout.Parent = contentContainer

-- [[ STATE VARIABLES ]]
local states = {
    Fly = { Enabled = false, Value = 150, Min = 1, Max = 500 },
    Speed = { Enabled = false, Value = 76, Min = 1, Max = 500 },
    JumpPower = { Enabled = false, Value = 100, Min = 1, Max = 500 },
    ESP = { Enabled = false }
}

-- [[ UI CREATION HELPER FUNCTIONS ]]
local function createToggleAndBind(name, labelText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = contentContainer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.35, 0, 1, 0)
    toggleBtn.Position = UDim2.new(0.65, 0, 0, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = frame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)

    local function updateToggleVisual()
        toggleBtn.Text = states[name].Enabled and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = states[name].Enabled and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75)
        
        if name == "ESP" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local highlight = p.Character:FindFirstChild("CapperESP")
                    if highlight then highlight.Enabled = states.ESP.Enabled end
                end
            end
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        states[name].Enabled = not states[name].Enabled
        updateToggleVisual()
    end)
end

local function createSlider(name, labelText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundTransparency = 1
    frame.Parent = contentContainer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = labelText .. ": " .. states[name].Value
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local sliderBackground = Instance.new("Frame")
    sliderBackground.Size = UDim2.new(1, -10, 0, 15)
    sliderBackground.Position = UDim2.new(0, 0, 0, 22)
    sliderBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBackground.Parent = frame
    Instance.new("UICorner", sliderBackground).CornerRadius = UDim.new(0, 4)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((states[name].Value - states[name].Min) / (states[name].Max - states[name].Min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBackground
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 4)

    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
        local newValue = math.round(states[name].Min + (percentage * (states[name].Max - states[name].Min)))
        states[name].Value = newValue
        label.Text = labelText .. ": " .. states[name].Value
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    end

    local draggingSlider = false
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            updateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
end

-- [[ BUILD INTERFACE ]]
createToggleAndBind("Fly", "Fly Mode")
createSlider("Fly", "Fly Speed")
createToggleAndBind("Speed", "WalkSpeed Alternative")
createSlider("Speed", "Speed Value")
createToggleAndBind("JumpPower", "Jump Alternative")
createSlider("JumpPower", "Jump Height")
createToggleAndBind("ESP", "ESP")

-- [[ ESP LOGIC ]]
local function applyESP(player)
    if player == localPlayer then return end
    local function setupHighlight(character)
        if not character then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "CapperESP"
        highlight.FillColor = Color3.fromRGB(255, 140, 0)
        highlight.Adornee = character
        highlight.Enabled = states.ESP.Enabled
        highlight.Parent = character
    end
    if player.Character then setupHighlight(player.Character) end
    player.CharacterAdded:Connect(setupHighlight)
end
for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- [[ ADVANCED BLOX FRUITS MOBILE VELOCITY OVERRIDE LOOP ]]
RunService.Heartbeat:Connect(function()
    local character = localPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    -- Safe retrieval of Mobile Joystick Vector values
    local moveVector = Vector3.new(0,0,0)
    if PlayerModule and PlayerModule.GetControls then
        moveVector = PlayerModule:GetControls():GetMoveVector()
    end

    -- 1. Anti-Overwrite WalkSpeed Bypass
    if states.Speed.Enabled and not states.Fly.Enabled then
        if moveVector.Magnitude > 0 then
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            local calculatedDir = ((forward * -moveVector.Z) + (right * moveVector.X))
            calculatedDir = Vector3.new(calculatedDir.X, 0, calculatedDir.Z).Unit
            
            -- Injecting absolute artificial horizontal momentum directly into the physics engine
            rootPart.AssemblyLinearVelocity = Vector3.new(
                calculatedDir.X * states.Speed.Value, 
                rootPart.AssemblyLinearVelocity.Y, 
                calculatedDir.Z * states.Speed.Value
            )
        end
    end

    -- 2. Anti-Overwrite JumpPower Bypass 
    if states.JumpPower.Enabled then
        -- Instead of messing with humanoid values, we detect active jumps and push the root assembly up safely
        if humanoid.FloorMaterial ~= Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, states.JumpPower.Value, rootPart.AssemblyLinearVelocity.Z)
        end
    end

    -- 3. Blox Fruits Flying Vessel Engine
    if states.Fly.Enabled then
        if humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end

        local targetPhysicsPart = rootPart
        
        -- Safe Boat Tracking Module
        if humanoid.Sit and humanoid.SeatPart then
            local vehicleModel = humanoid.SeatPart:FindFirstAncestorOfClass("Model")
            if vehicleModel then
                targetPhysicsPart = vehicleModel.PrimaryPart 
                    or vehicleModel:FindFirstChild("MainPart") 
                    or vehicleModel:FindFirstChild("Body") 
                    or humanoid.SeatPart
                
                -- Crucial: Prevents Blox Fruits anti-cheat from un-sitting or ejecting you mid-air
                for _, p in ipairs(character:GetChildren()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
                
                -- Keeps the vehicle parts awake and matching your physics assembly smoothly
                for _, part in ipairs(vehicleModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        if part.Anchored then part.Anchored = false end
                    end
                end
            end
        end

        targetPhysicsPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        local flyDirection = Vector3.new(0, 0, 0)
        
        if moveVector.Magnitude > 0 then
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            flyDirection = (forward * -moveVector.Z) + (right * moveVector.X)
        end

        if flyDirection.Magnitude > 0 then
            flyDirection = flyDirection.Unit
            targetPhysicsPart.AssemblyLinearVelocity = flyDirection * states.Fly.Value
        else
            -- Locked Hover state prevents gravity drops while waiting on joystick inputs
            targetPhysicsPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    else
        if humanoid:GetState() == Enum.HumanoidStateType.Physics then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)
