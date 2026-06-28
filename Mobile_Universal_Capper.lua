-- [[ MAIN GUI SETUP ]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Safe PlayerModule retrieval (Prevents script hanging during mobile execution layout phases)
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
mainFrame.Visible = false -- Starts hidden so it can toggle with the mobile button safely
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- [[ MOBILE TOGGLE MENU BUTTON ]]
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

-- Dragging Implementation (Touch & Mobile Screen Optimized)
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

-- Bottom Utilities Frame container
local utilsContainer = Instance.new("Frame")
utilsContainer.Name = "UtilsContainer"
utilsContainer.Size = UDim2.new(1, 0, 0, 90)
utilsContainer.BackgroundTransparency = 1
utilsContainer.LayoutOrder = 999 
utilsContainer.Parent = tabBar

local utilsLayout = Instance.new("UIListLayout")
utilsLayout.FillDirection = Enum.FillDirection.Vertical
utilsLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
utilsLayout.Padding = UDim.new(0, 5)
utilsLayout.Parent = utilsContainer

-- Green Rejoin Button
local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Name = "RejoinButton"
rejoinBtn.Size = UDim2.new(1, -10, 0, 35)
rejoinBtn.Position = UDim2.new(0, 5, 0, 0)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87) 
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.Text = "Rejoin Server"
rejoinBtn.Font = Enum.Font.SourceSansBold
rejoinBtn.TextSize = 14
rejoinBtn.Parent = utilsContainer
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 4)

-- Red Serverhop Button
local serverHopBtn = Instance.new("TextButton")
serverHopBtn.Name = "ServerHopButton"
serverHopBtn.Size = UDim2.new(1, -10, 0, 35)
serverHopBtn.Position = UDim2.new(0, 5, 0, 0)
serverHopBtn.BackgroundColor3 = Color3.fromRGB(178, 34, 34) 
serverHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
serverHopBtn.Text = "Serverhop"
serverHopBtn.Font = Enum.Font.SourceSansBold
serverHopBtn.TextSize = 14
serverHopBtn.Parent = utilsContainer
Instance.new("UICorner", serverHopBtn).CornerRadius = UDim.new(0, 4)

-- Content Container
local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Name = "UniversalContent"
contentContainer.Size = UDim2.new(1, -170, 1, -50)
contentContainer.Position = UDim2.new(0, 160, 0, 45)
contentContainer.BackgroundTransparency = 1
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 680)
contentContainer.ScrollBarThickness = 6
contentContainer.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 15)
contentLayout.Parent = contentContainer

-- [[ STATE VARIABLES ]]
-- Cleaned of heavy background physical keyboard binder variables to ensure mobile performance
local states = {
    Fly = { Enabled = false, Value = 150, Min = 1, Max = 500 },
    Speed = { Enabled = false, Value = 76, Min = 1, Max = 500 },
    JumpPower = { Enabled = false, Value = 100, Min = 1, Max = 500 },
    ESP = { Enabled = false },
    Fling = { Enabled = false }
}

local teleportState = {
    Target = nil,
    IsRandomMode = false
}

local flingThread = nil

if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
    local detection = Instance.new("Decal")
    detection.Name = "juisdfj0i32i0eidsuf0iok"
    detection.Parent = ReplicatedStorage
end

-- [[ TELEPORT FUNCTIONS ]]
rejoinBtn.MouseButton1Click:Connect(function()
    if #Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, localPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
    end
end)

serverHopBtn.MouseButton1Click:Connect(function()
    serverHopBtn.Text = "Hopping..."
    TeleportService:Teleport(game.PlaceId, localPlayer)
end)

-- [[ UI CREATION HELPER FUNCTIONS ]]
local function createToggleAndBind(name, labelText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = contentContainer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0) -- Widened slightly to cleanly match single labels
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

    local runFlingLogic 

    local function updateToggleVisual()
        toggleBtn.Text = states[name].Enabled and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = states[name].Enabled and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75)
        
        if name == "ESP" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local highlight = p.Character:FindFirstChild("CapperESP")
                    if highlight then highlight.Enabled = states.ESP.Enabled end
                    local billboard = p.Character:FindFirstChild("CapperESPTag")
                    if billboard then billboard.Enabled = states.ESP.Enabled end
                end
            end
        elseif name == "Fling" then
            runFlingLogic()
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        states[name].Enabled = not states[name].Enabled
        updateToggleVisual()
    end)
    
    states[name].RefreshToggleVisual = updateToggleVisual

    runFlingLogic = function()
        if states.Fling.Enabled then
            if flingThread and coroutine.status(flingThread) ~= "dead" then return end
            
            flingThread = coroutine.create(function()
                local movel = 0.1
                while states.Fling.Enabled do
                    RunService.Heartbeat:Wait()
                    local c = localPlayer.Character
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        local vel = hrp.Velocity
                        hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                        RunService.RenderStepped:Wait()
                        hrp.Velocity = vel
                        RunService.Stepped:Wait()
                        hrp.Velocity = vel + Vector3.new(0, movel, 0)
                        movel = -movel
                    end
                end
            end)
            coroutine.resume(flingThread)
        end
    end
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

    -- RESTORED: Original UI Left Arrow Button
    local leftArrow = Instance.new("TextButton")
    leftArrow.Size = UDim2.new(0, 25, 0, 20)
    leftArrow.Position = UDim2.new(0, 0, 0, 22)
    leftArrow.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    leftArrow.Text = "<"
    leftArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftArrow.Font = Enum.Font.SourceSansBold
    leftArrow.TextSize = 16
    leftArrow.Parent = frame
    Instance.new("UICorner", leftArrow).CornerRadius = UDim.new(0, 4)

    -- RESTORED: Original UI Right Arrow Button
    local rightArrow = Instance.new("TextButton")
    rightArrow.Size = UDim2.new(0, 25, 0, 22)
    rightArrow.Position = UDim2.new(1, -25, 0, 22)
    rightArrow.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    rightArrow.Text = ">"
    rightArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightArrow.Font = Enum.Font.SourceSansBold
    rightArrow.TextSize = 16
    rightArrow.Parent = frame
    Instance.new("UICorner", rightArrow).CornerRadius = UDim.new(0, 4)

    local sliderBackground = Instance.new("Frame")
    sliderBackground.Size = UDim2.new(1, -60, 0, 10)
    sliderBackground.Position = UDim2.new(0, 30, 0, 27)
    sliderBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBackground.Parent = frame
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((states[name].Value - states[name].Min) / (states[name].Max - states[name].Min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBackground

    local function refreshSliderVisual()
        local percentage = math.clamp((states[name].Value - states[name].Min) / (states[name].Max - states[name].Min), 0, 1)
        label.Text = labelText .. ": " .. states[name].Value
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    end

    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
        local newValue = math.round(states[name].Min + (percentage * (states[name].Max - states[name].Min)))
        states[name].Value = newValue
        refreshSliderVisual()
    end

    -- Hooked Tap Logic back into arrows perfectly for mobile executors
    leftArrow.MouseButton1Click:Connect(function()
        states[name].Value = math.clamp(states[name].Value - 10, states[name].Min, states[name].Max)
        refreshSliderVisual()
    end)

    rightArrow.MouseButton1Click:Connect(function()
        states[name].Value = math.clamp(states[name].Value + 10, states[name].Min, states[name].Max)
        refreshSliderVisual()
    end)

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

    states[name].RefreshVisual = refreshSliderVisual
end

-- [[ BUILD UNIVERSAL INTERFACE WITH YOUR SPECIFIC RE-LABEL SPECIFICATIONS ]]
createToggleAndBind("Fly", "Fly")
createSlider("Fly", "Fly speed")
createToggleAndBind("Speed", "Speed")
createSlider("Speed", "Speed")
createToggleAndBind("JumpPower", "Jump")
createSlider("JumpPower", "Jump")
createToggleAndBind("ESP", "ESP")
createToggleAndBind("Fling", "Touch Fling")

-- [[ TELEPORT INTERFACE ]]
local tpSelectionFrame = Instance.new("Frame")
tpSelectionFrame.Size = UDim2.new(1, -10, 0, 65)
tpSelectionFrame.BackgroundTransparency = 1
tpSelectionFrame.Parent = contentContainer

local tpLabel = Instance.new("TextLabel")
tpLabel.Size = UDim2.new(1, 0, 0, 20)
tpLabel.Text = "Teleport Target (Type Name or 'random')"
tpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
tpLabel.Font = Enum.Font.SourceSans
tpLabel.TextSize = 14
tpLabel.TextXAlignment = Enum.TextXAlignment.Left
tpLabel.BackgroundTransparency = 1
tpLabel.Parent = tpSelectionFrame

local tpTextBox = Instance.new("TextBox")
tpTextBox.Size = UDim2.new(0.95, 0, 0, 35)
tpTextBox.Position = UDim2.new(0, 0, 0, 25)
tpTextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
tpTextBox.BorderColor3 = Color3.fromRGB(60, 60, 60)
tpTextBox.Font = Enum.Font.SourceSans
tpTextBox.TextSize = 16
tpTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
tpTextBox.PlaceholderText = "Search player name or type 'random'..."
tpTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
tpTextBox.Text = ""
tpTextBox.ClearTextOnFocus = true 
tpTextBox.Parent = tpSelectionFrame
Instance.new("UICorner", tpTextBox).CornerRadius = UDim.new(0, 4)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 15)
statusLabel.Position = UDim2.new(0, 0, 0, 62)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "No target selected"
statusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
statusLabel.Font = Enum.Font.SourceSansItalic
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = tpSelectionFrame

-- Target input evaluation engine
local function scanForTarget()
    local searchString = string.lower(tpTextBox.Text)
    if searchString == "" then
        teleportState.Target = nil
        teleportState.IsRandomMode = false
        statusLabel.Text = "No target selected"
        statusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
        return
    end

    if searchString == "random" then
        teleportState.Target = nil
        teleportState.IsRandomMode = true
        statusLabel.Text = "Random Loop Mode Enabled (Picks fresh target every TP)"
        statusLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
        return
    end

    teleportState.IsRandomMode = false
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local userName = string.lower(p.Name)
            local displayName = string.lower(p.DisplayName)
            
            if string.find(userName, searchString) or string.find(displayName, searchString) then
                teleportState.Target = p
                statusLabel.Text = "Target Locked: " .. p.DisplayName .. " (@" .. p.Name .. ")"
                statusLabel.TextColor3 = Color3.fromRGB(75, 255, 75)
                return
            end
        end
    end
    
    teleportState.Target = nil
    statusLabel.Text = "No player found matching search"
    statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
end

tpTextBox:GetPropertyChangedSignal("Text"):Connect(scanForTarget)

Players.PlayerRemoving:Connect(function(player)
    if teleportState.Target == player then
        teleportState.Target = nil
        scanForTarget()
    end
end)
Players.PlayerAdded:Connect(scanForTarget)

local tpActionFrame = Instance.new("Frame")
tpActionFrame.Size = UDim2.new(1, -10, 0, 35)
tpActionFrame.BackgroundTransparency = 1
tpActionFrame.Parent = contentContainer

local tpExecuteBtn = Instance.new("TextButton")
tpExecuteBtn.Size = UDim2.new(0.5, 0, 1, 0) -- Scaled up to cover original PC keyboard bind area
tpExecuteBtn.Position = UDim2.new(0.25, 0, 0, 0)
tpExecuteBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
tpExecuteBtn.Text = "Teleport"
tpExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpExecuteBtn.Font = Enum.Font.SourceSansBold
tpExecuteBtn.TextSize = 14
tpExecuteBtn.Parent = tpActionFrame
Instance.new("UICorner", tpExecuteBtn).CornerRadius = UDim.new(0, 4)

local function executeTeleport()
    local targetPlayer = teleportState.Target
    
    if teleportState.IsRandomMode then
        local targetPool = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer then
                table.insert(targetPool, p)
            end
        end
        
        if #targetPool > 0 then
            targetPlayer = targetPool[math.random(1, #targetPool)]
        end
    end

    if targetPlayer and targetPlayer.Parent then
        local targetChar = targetPlayer.Character
        local localChar = localPlayer.Character
        
        if targetChar and localChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            
            -- Detect target torso (Handles both R6 and R15 layouts cleanly)
            local targetTorso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso")
            
            if targetRoot and localRoot then
                if states.Fling.Enabled and targetTorso then
                    localRoot.CFrame = targetTorso.CFrame
                else
                    localRoot.CFrame = targetRoot.CFrame 
                end
            end
        end
    end
end

tpExecuteBtn.MouseButton1Click:Connect(executeTeleport)

-- [[ ESP LOGIC ]]
local function applyESP(player)
    if player == localPlayer then return end
    
    local function setupHighlight(character)
        if not character then return end
        
        for _, obj in ipairs(character:GetChildren()) do
            if obj.Name == "CapperESP" or obj.Name == "CapperESPTag" then
                obj:Destroy()
            end
        end
        
        local head = character:WaitForChild("Head", 5)
        if not head then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "CapperESP"
        highlight.FillColor = Color3.fromRGB(255, 140, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0.1
        highlight.Adornee = character
        highlight.Enabled = states.ESP.Enabled
        highlight.Parent = character

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "CapperESPTag"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Enabled = states.ESP.Enabled
        billboard.Parent = character
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = player.DisplayName .. " | 0"
        textLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 14
        textLabel.Parent = billboard
    end

    if player.Character then task.spawn(setupHighlight, player.Character) end
    player.CharacterAdded:Connect(function(char)
        task.spawn(setupHighlight, char)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

task.spawn(function()
    while task.wait(0.1) do
        if states.ESP.Enabled then
            local localChar = localPlayer.Character
            local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer and p.Character then
                    local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    local billboard = p.Character:FindFirstChild("CapperESPTag")
                    
                    if targetRoot and billboard then
                        local textLabel = billboard:FindFirstChildOfClass("TextLabel")
                        if textLabel then
                            if localRoot then
                                local distance = math.round((localRoot.Position - targetRoot.Position).Magnitude)
                                textLabel.Text = p.DisplayName .. " | " .. distance
                            else
                                textLabel.Text = p.DisplayName .. " | -"
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- [[ MOBILE COMPATIBLE PHYSICAL VECTOR LOOPS ]]
RunService.Heartbeat:Connect(function()
    local character = localPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    -- Fetch clean directional coordinates directly from the mobile on-screen joystick layout
    local moveVector = Vector3.new(0, 0, 0)
    if PlayerModule and PlayerModule.GetControls then
        moveVector = PlayerModule:GetControls():GetMoveVector()
    end

    -- 1. Anti-Overwrite WalkSpeed Bypass (Bypasses Blox Fruits custom property checks)
    if states.Speed.Enabled and not states.Fly.Enabled then
        if moveVector.Magnitude > 0 then
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            local moveDirection = ((forward * -moveVector.Z) + (right * moveVector.X))
            moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
            
            rootPart.AssemblyLinearVelocity = Vector3.new(
                moveDirection.X * states.Speed.Value,
                rootPart.AssemblyLinearVelocity.Y,
                moveDirection.Z * states.Speed.Value
            )
        end
    end

    -- 2. Anti-Overwrite JumpPower Bypass
    if states.JumpPower.Enabled then
        -- Simulates direct explosive jumps via velocity hooks if touch screen jump buttons trigger an action state
        if humanoid.FloorMaterial ~= Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, states.JumpPower.Value, rootPart.AssemblyLinearVelocity.Z)
        end
    end

    -- 3. Advanced Blox Fruits Flying Vessel Engine
    if states.Fly.Enabled then
        if humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end

        local targetPhysicsPart = rootPart
        local isSitting = humanoid.Sit and humanoid.SeatPart
        
        if isSitting then
            local vehicleModel = humanoid.SeatPart:FindFirstAncestorOfClass("Model")
            if vehicleModel then
                -- Locates whatever specific physical asset the vessel uses as its primary physics target
                targetPhysicsPart = vehicleModel.PrimaryPart 
                    or vehicleModel:FindFirstChild("MainPart") 
                    or vehicleModel:FindFirstChild("Body") 
                    or humanoid.SeatPart
                
                -- ANTI-EJECT SYSTEM: Strips collisions dynamically so Blox Fruits' seat boundary fails to trip
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                
                -- Dynamic vessel activation block
                for _, part in ipairs(vehicleModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        if part.Anchored then part.Anchored = false end -- Forces full structural physics un-anchor
                    end
                end
            end
        end

        targetPhysicsPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        local flyDirection = Vector3.new(0, 0, 0)
        
        -- Link flying vectors straight into your mobile thumb stick controls
        if moveVector.Magnitude > 0 then
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            flyDirection = (forward * -moveVector.Z) + (right * moveVector.X)
        end

        if flyDirection.Magnitude > 0 then
            flyDirection = flyDirection.Unit
            targetPhysicsPart.AssemblyLinearVelocity = flyDirection * states.Fly.Value
        else
            -- Absolute hover engine state lock: Stops gravity from sinking your boat when idling controls
            targetPhysicsPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    else
        if humanoid:GetState() == Enum.HumanoidStateType.Physics and not states.Fling.Enabled then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)
