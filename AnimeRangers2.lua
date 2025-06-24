-- Roblox UI Script with Teleporter
-- LocalScript - đặt trong StarterGui

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Config cho auto save
local configFileName = "TeleporterConfig"
local defaultConfig = {
    selectedMap = "Marines Fort",
    selectedAct = 1,
    autoStartEnabled = false
}

-- Load config
local function loadConfig()
    local success, result = pcall(function()
        local config = readfile(configFileName .. ".json")
        return game:GetService("HttpService"):JSONDecode(config)
    end)
    
    if success and result then
        return result
    else
        return defaultConfig
    end
end

-- Save config
local function saveConfig(config)
    pcall(function()
        local jsonConfig = game:GetService("HttpService"):JSONEncode(config)
        writefile(configFileName .. ".json", jsonConfig)
    end)
end

-- Load saved config
local currentConfig = loadConfig()

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleporterUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Corner cho main frame
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- Title text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -80, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Teleporter UI"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Map Selection
local mapLabel = Instance.new("TextLabel")
mapLabel.Name = "MapLabel"
mapLabel.Size = UDim2.new(1, 0, 0, 25)
mapLabel.Position = UDim2.new(0, 0, 0, 10)
mapLabel.BackgroundTransparency = 1
mapLabel.Text = "Select Map:"
mapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
mapLabel.TextScaled = true
mapLabel.Font = Enum.Font.Gotham
mapLabel.TextXAlignment = Enum.TextXAlignment.Left
mapLabel.Parent = contentFrame

local mapDropdown = Instance.new("TextButton")
mapDropdown.Name = "MapDropdown"
mapDropdown.Size = UDim2.new(1, 0, 0, 35)
mapDropdown.Position = UDim2.new(0, 0, 0, 40)
mapDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mapDropdown.BorderSizePixel = 0
mapDropdown.Text = currentConfig.selectedMap .. " ▼"
mapDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
mapDropdown.TextScaled = true
mapDropdown.Font = Enum.Font.Gotham
mapDropdown.Parent = contentFrame

local mapCorner = Instance.new("UICorner")
mapCorner.CornerRadius = UDim.new(0, 4)
mapCorner.Parent = mapDropdown

-- Act Selection
local actLabel = Instance.new("TextLabel")
actLabel.Name = "ActLabel"
actLabel.Size = UDim2.new(1, 0, 0, 25)
actLabel.Position = UDim2.new(0, 0, 0, 90)
actLabel.BackgroundTransparency = 1
actLabel.Text = "Select Act:"
actLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
actLabel.TextScaled = true
actLabel.Font = Enum.Font.Gotham
actLabel.TextXAlignment = Enum.TextXAlignment.Left
actLabel.Parent = contentFrame

local actDropdown = Instance.new("TextButton")
actDropdown.Name = "ActDropdown"
actDropdown.Size = UDim2.new(1, 0, 0, 35)
actDropdown.Position = UDim2.new(0, 0, 0, 120)
actDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
actDropdown.BorderSizePixel = 0
actDropdown.Text = "Act " .. currentConfig.selectedAct .. " ▼"
actDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
actDropdown.TextScaled = true
actDropdown.Font = Enum.Font.Gotham
actDropdown.Parent = contentFrame

local actCorner = Instance.new("UICorner")
actCorner.CornerRadius = UDim.new(0, 4)
actCorner.Parent = actDropdown

-- Auto Start Toggle
local autoStartToggle = Instance.new("TextButton")
autoStartToggle.Name = "AutoStartToggle"
autoStartToggle.Size = UDim2.new(1, 0, 0, 40)
autoStartToggle.Position = UDim2.new(0, 0, 0, 170)
autoStartToggle.BackgroundColor3 = currentConfig.autoStartEnabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
autoStartToggle.BorderSizePixel = 0
autoStartToggle.Text = "Auto Start: " .. (currentConfig.autoStartEnabled and "ON" or "OFF")
autoStartToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoStartToggle.TextScaled = true
autoStartToggle.Font = Enum.Font.GothamBold
autoStartToggle.Parent = contentFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 4)
toggleCorner.Parent = autoStartToggle

-- Teleport Button
local teleportButton = Instance.new("TextButton")
teleportButton.Name = "TeleportButton"
teleportButton.Size = UDim2.new(1, 0, 0, 40)
teleportButton.Position = UDim2.new(0, 0, 1, -50)
teleportButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
teleportButton.BorderSizePixel = 0
teleportButton.Text = "Teleport Now"
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.TextScaled = true
teleportButton.Font = Enum.Font.GothamBold
teleportButton.Parent = contentFrame

local teleportCorner = Instance.new("UICorner")
teleportCorner.CornerRadius = UDim.new(0, 4)
teleportCorner.Parent = teleportButton

-- Dropdown options
local mapOptions = {"Marines Fort", "Hell City", "Snowvy Capital", "Leaf Village", "Wanderniech", "Central City"}
local actOptions = {1, 2, 3, 4, 5, 6}

-- Create dropdown function
local function createDropdownList(parent, options, currentValue, callback)
    local dropdown = Instance.new("Frame")
    dropdown.Name = "DropdownList"
    dropdown.Size = UDim2.new(1, 0, 0, #options * 30)
    dropdown.Position = UDim2.new(0, 0, 1, 5)
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dropdown.BorderSizePixel = 0
    dropdown.ZIndex = 10
    dropdown.Parent = parent
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdown
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option" .. i
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        optionButton.BorderSizePixel = 0
        optionButton.Text = tostring(option)
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.TextScaled = true
        optionButton.Font = Enum.Font.Gotham
        optionButton.ZIndex = 11
        optionButton.Parent = dropdown
        
        optionButton.MouseButton1Click:Connect(function()
            callback(option)
            dropdown:Destroy()
        end)
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end)
    end
    
    return dropdown
end

-- Map dropdown functionality
mapDropdown.MouseButton1Click:Connect(function()
    -- Remove existing dropdown
    for _, child in pairs(mapDropdown:GetChildren()) do
        if child.Name == "DropdownList" then
            child:Destroy()
        end
    end
    
    createDropdownList(mapDropdown, mapOptions, currentConfig.selectedMap, function(selectedMap)
        currentConfig.selectedMap = selectedMap
        mapDropdown.Text = selectedMap .. " ▼"
        saveConfig(currentConfig)
    end)
end)

-- Act dropdown functionality
actDropdown.MouseButton1Click:Connect(function()
    -- Remove existing dropdown
    for _, child in pairs(actDropdown:GetChildren()) do
        if child.Name == "DropdownList" then
            child:Destroy()
        end
    end
    
    createDropdownList(actDropdown, actOptions, currentConfig.selectedAct, function(selectedAct)
        currentConfig.selectedAct = selectedAct
        actDropdown.Text = "Act " .. selectedAct .. " ▼"
        saveConfig(currentConfig)
    end)
end)

-- Auto Start Toggle functionality
autoStartToggle.MouseButton1Click:Connect(function()
    currentConfig.autoStartEnabled = not currentConfig.autoStartEnabled
    autoStartToggle.Text = "Auto Start: " .. (currentConfig.autoStartEnabled and "ON" or "OFF")
    autoStartToggle.BackgroundColor3 = currentConfig.autoStartEnabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
    saveConfig(currentConfig)
end)

-- Teleport function
local function teleportToMap()
    local mapName = currentConfig.selectedMap .. "(Map)"
    local actNumber = currentConfig.selectedAct
    
    pcall(function()
        ReplicatedStorage.Remotes.Teleporter.Interact:FireServer("Select", mapName, actNumber)
    end)
end

-- Auto Start function
local function autoStart()
    pcall(function()
        ReplicatedStorage.Remotes.Teleporter.Interact:FireServer("Skip")
    end)
end

-- Teleport button functionality
teleportButton.MouseButton1Click:Connect(function()
    teleportToMap()
end)

-- Close button functionality
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Auto Start loop
local autoStartConnection
local function startAutoStart()
    if autoStartConnection then
        autoStartConnection:Disconnect()
    end
    
    if currentConfig.autoStartEnabled then
        autoStartConnection = RunService.Heartbeat:Connect(function()
            if currentConfig.autoStartEnabled then
                autoStart()
                wait(0.1) -- Prevent spam
            end
        end)
    end
end

-- Start auto start if enabled
startAutoStart()

-- Update auto start when toggle changes
local previousAutoStart = currentConfig.autoStartEnabled
RunService.Heartbeat:Connect(function()
    if previousAutoStart ~= currentConfig.autoStartEnabled then
        previousAutoStart = currentConfig.autoStartEnabled
        startAutoStart()
    end
end)

-- Add hover effects
local function addHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor})
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor})
        tween:Play()
    end)
end

addHoverEffect(closeButton, Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 150, 150))
addHoverEffect(teleportButton, Color3.fromRGB(100, 150, 255), Color3.fromRGB(150, 180, 255))
