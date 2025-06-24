local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not success then
    warn("Lỗi khi tải thư viện Fluent: " .. tostring(err))
    -- Thử tải từ URL dự phòng
    pcall(function()
        Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua"))()
        SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)
end

-- Đợi đến khi Fluent được tải hoàn tất
if not Fluent then
    return
    warn("Không thể tải thư viện Fluent!")
end

-- Hệ thống lưu trữ cấu hình
local ConfigSystem = {}
ConfigSystem.FileName = "KaihonALSConfig_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    -- Map Settings
    SelectedMap = "Marines Fort",
    SelectedAct = 1,
    AutoJoinEnabled = false,
    AutoStartEnabled = false
}
ConfigSystem.CurrentConfig = {}

-- Hàm để lưu cấu hình
ConfigSystem.SaveConfig = function()
    local success, err = pcall(function()
        writefile(ConfigSystem.FileName, game:GetService("HttpService"):JSONEncode(ConfigSystem.CurrentConfig))
    end)
    if success then
        logPrint("Đã lưu cấu hình thành công!")
    else
        warn("Lưu cấu hình thất bại:", err)
    end
end

-- Hàm để tải cấu hình
ConfigSystem.LoadConfig = function()
    local success, content = pcall(function()
        if isfile(ConfigSystem.FileName) then
            return readfile(ConfigSystem.FileName)
        end
        return nil
    end)
    
    if success and content then
        local data = game:GetService("HttpService"):JSONDecode(content)
        ConfigSystem.CurrentConfig = data
        return true
    else
        ConfigSystem.CurrentConfig = table.clone(ConfigSystem.DefaultConfig)
        ConfigSystem.SaveConfig()
        return false
    end
end

-- Tải cấu hình khi khởi động
ConfigSystem.LoadConfig()

-- Biến lưu trạng thái Map
local selectedMap = ConfigSystem.CurrentConfig.SelectedMap or "Marines Fort"
local selectedAct = ConfigSystem.CurrentConfig.SelectedAct or 1
local autoJoinEnabled = ConfigSystem.CurrentConfig.AutoJoinEnabled or false
local autoStartEnabled = ConfigSystem.CurrentConfig.AutoStartEnabled or false

-- Thêm biến cho Auto Hide UI vào phần biến trạng thái Map
local autoHideUI = ConfigSystem.CurrentConfig.AutoHideUI or false

-- Thêm vào DefaultConfig
ConfigSystem.DefaultConfig.AutoHideUI = false

-- Thêm biến cho Log Console vào phần biến trạng thái Map
local logConsoleEnabled = ConfigSystem.CurrentConfig.LogConsoleEnabled or true

-- Thêm vào DefaultConfig
ConfigSystem.DefaultConfig.LogConsoleEnabled = true

-- Hàm để log có điều kiện
local function logPrint(message)
    if logConsoleEnabled then
        print(message)
    end
end

-- Tạo Window chính
local Window = Fluent:CreateWindow({
    Title = "Anime Last Stand Script",
    SubTitle = "by Duong Tuan",
    TabWidth = 140,
    Size = UDim2.fromOffset(450, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tạo Tab Main
local MainTab = Window:AddTab({
    Title = "Main",
    Icon = "home"
})

-- Tạo tab Settings
local SettingsTab = Window:AddTab({
    Title = "Settings",
    Icon = "settings"
})

-- Section Map trong tab Main
local MapSection = MainTab:AddSection("Map Settings")

-- Dropdown để chọn Map
MapSection:AddDropdown("MapDropdown", {
    Title = "Select Map",
    Values = {"Marines Fort", "Hell City", "Snowvy Capital", "Leaf Village", "Wanderniech", "Central City"},
    Multi = false,
    Default = selectedMap,
    Callback = function(Value)
        selectedMap = Value
        ConfigSystem.CurrentConfig.SelectedMap = Value
        ConfigSystem.SaveConfig()
        logPrint("Selected Map: " .. selectedMap)
    end
})

-- Dropdown để chọn Act
MapSection:AddDropdown("ActDropdown", {
    Title = "Select Act",
    Values = {"1", "2", "3", "4", "5", "6"},
    Multi = false,
    Default = tostring(selectedAct),
    Callback = function(Value)
        selectedAct = tonumber(Value)
        ConfigSystem.CurrentConfig.SelectedAct = selectedAct
        ConfigSystem.SaveConfig()
        logPrint("Selected Act: " .. selectedAct)
    end
})

-- Toggle để bật/tắt Auto Join Map
MapSection:AddToggle("AutoJoinToggle", {
    Title = "Auto Join Map",
    Default = ConfigSystem.CurrentConfig.AutoJoinEnabled or false,
    Callback = function(Value)
        autoJoinEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinEnabled = Value
        ConfigSystem.SaveConfig()
        
        if autoJoinEnabled then
            Fluent:Notify({
                Title = "Auto Join Enabled",
                Content = "Auto joining " .. selectedMap .. " (Act " .. selectedAct .. ")",
                Duration = 3
            })
            
            -- Tạo coroutine để tự động tham gia map
            spawn(function()
                while autoJoinEnabled and wait(10) do -- Lặp lại mỗi 10 giây
                    pcall(function()
                        game:GetService("ReplicatedStorage").Remotes.Teleporter.Interact:FireServer("Select", selectedMap, selectedAct)
                        logPrint("Attempting to join map: " .. selectedMap .. " Act " .. selectedAct)
                    end)
                end
            end)
        else
            Fluent:Notify({
                Title = "Auto Join Disabled",
                Content = "Stopped auto joining maps",
                Duration = 3
            })
        end
    end
})

-- Toggle để bật/tắt Auto Start
MapSection:AddToggle("AutoStartToggle", {
    Title = "Auto Start",
    Default = ConfigSystem.CurrentConfig.AutoStartEnabled or false,
    Callback = function(Value)
        autoStartEnabled = Value
        ConfigSystem.CurrentConfig.AutoStartEnabled = Value
        ConfigSystem.SaveConfig()
        
        if autoStartEnabled then
            Fluent:Notify({
                Title = "Auto Start Enabled",
                Content = "Will automatically start matches when ready",
                Duration = 3
            })
            
            -- Tạo coroutine để tự động bắt đầu match
            spawn(function()
                while autoStartEnabled and wait(15) do -- Lặp lại mỗi 15 giây
                    pcall(function()
                        game:GetService("ReplicatedStorage").Remotes.Teleporter.Interact:FireServer("Skip")
                        logPrint("Attempting to start match")
                    end)
                end
            end)
        else
            Fluent:Notify({
                Title = "Auto Start Disabled",
                Content = "Stopped auto starting matches",
                Duration = 3
            })
        end
    end
})

-- Manual Join Button
MapSection:AddButton({
    Title = "Join Map Now",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.Teleporter.Interact:FireServer("Select", selectedMap, selectedAct)
            
            Fluent:Notify({
                Title = "Joining Map",
                Content = "Attempting to join " .. selectedMap .. " (Act " .. selectedAct .. ")",
                Duration = 3
            })
        end)
    end
})

-- Manual Start Button
MapSection:AddButton({
    Title = "Start Match Now",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.Teleporter.Interact:FireServer("Skip")
            
            Fluent:Notify({
                Title = "Starting Match",
                Content = "Attempting to start match",
                Duration = 3
            })
        end)
    end
})

-- Thêm Toggle Auto Hide UI vào MapSection (sau nút Start Match Now)
MapSection:AddToggle("AutoHideToggle", {
    Title = "Auto Hide UI",
    Default = ConfigSystem.CurrentConfig.AutoHideUI or false,
    Callback = function(Value)
        autoHideUI = Value
        ConfigSystem.CurrentConfig.AutoHideUI = Value
        ConfigSystem.SaveConfig()
        
        if autoHideUI then
            Fluent:Notify({
                Title = "Auto Hide UI Enabled",
                Content = "UI will automatically hide when in game",
                Duration = 3
            })
            
            -- Tạo coroutine để tự động ẩn UI
            spawn(function()
                while autoHideUI and wait(2) do -- Kiểm tra mỗi 2 giây
                    pcall(function()
                        local player = game:GetService("Players").LocalPlayer
                        
                        -- Kiểm tra nếu player đang trong game (có character và không ở lobby)
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local currentPlace = player.Character.HumanoidRootPart.Position
                            
                            -- Kiểm tra nếu không ở lobby (tọa độ lobby thường khác với map)
                            -- Bạn có thể điều chỉnh điều kiện này tùy theo game
                            if math.abs(currentPlace.Y) > 50 or math.abs(currentPlace.X) > 1000 or math.abs(currentPlace.Z) > 1000 then
                                -- Ẩn UI khi đang trong map
                                Window:Minimize()
                                logPrint("Auto hiding UI - Player in game")
                            end
                        end
                    end)
                end
            end)
        else
            Fluent:Notify({
                Title = "Auto Hide UI Disabled",
                Content = "UI will not automatically hide",
                Duration = 3
            })
        end
    end
})

-- Thêm Toggle Log Console vào MapSection (sau nút Auto Hide UI)
MapSection:AddToggle("LogConsoleToggle", {
    Title = "Enable Console Log",
    Default = ConfigSystem.CurrentConfig.LogConsoleEnabled or true,
    Callback = function(Value)
        logConsoleEnabled = Value
        ConfigSystem.CurrentConfig.LogConsoleEnabled = Value
        ConfigSystem.SaveConfig()
        
        if logConsoleEnabled then
            Fluent:Notify({
                Title = "Console Log Enabled",
                Content = "Console logging is now enabled",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Console Log Disabled",
                Content = "Console logging is now disabled to reduce lag",
                Duration = 3
            })
        end
    end
})

-- Settings tab
local SettingsSection = SettingsTab:AddSection("Script Settings")

-- Integration with SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Thay đổi cách lưu cấu hình để sử dụng tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name
InterfaceManager:SetFolder("KaihonHubALS")
SaveManager:SetFolder("KaihonHubALS/" .. playerName)

-- Thêm thông tin vào tab Settings
SettingsTab:AddParagraph({
    Title = "Cấu hình tự động",
    Content = "Cấu hình của bạn đang được tự động lưu theo tên nhân vật: " .. playerName
})

SettingsTab:AddParagraph({
    Title = "Phím tắt",
    Content = "Nhấn LeftControl để ẩn/hiện giao diện"
})

-- Auto Save Config
local function AutoSaveConfig()
    spawn(function()
        while wait(5) do -- Lưu mỗi 5 giây
            pcall(function()
                ConfigSystem.SaveConfig()
            end)
        end
    end)
end

-- Thực thi tự động lưu cấu hình
AutoSaveConfig()

-- Thêm event listener để lưu ngay khi thay đổi giá trị
local function setupSaveEvents()
    for _, tab in pairs({MainTab, SettingsTab}) do
        if tab and tab._components then
            for _, element in pairs(tab._components) do
                if element and element.OnChanged then
                    element.OnChanged:Connect(function()
                        pcall(function()
                            ConfigSystem.SaveConfig()
                        end)
                    end)
                end
            end
        end
    end
end

-- Thiết lập events
setupSaveEvents()

-- Thêm hỗ trợ Logo khi minimize
repeat task.wait(0.25) until game:IsLoaded()
getgenv().Image = "rbxassetid://13099788281" -- ID tài nguyên hình ảnh logo
getgenv().ToggleUI = "LeftControl" -- Phím để bật/tắt giao diện

-- Tạo logo để mở lại UI khi đã minimize
task.spawn(function()
    local success, errorMsg = pcall(function()
        if not getgenv().LoadedMobileUI == true then 
            getgenv().LoadedMobileUI = true
            local OpenUI = Instance.new("ScreenGui")
            local ImageButton = Instance.new("ImageButton")
            local UICorner = Instance.new("UICorner")
            
            -- Kiểm tra môi trường
            if syn and syn.protect_gui then
                syn.protect_gui(OpenUI)
                OpenUI.Parent = game:GetService("CoreGui")
            elseif gethui then
                OpenUI.Parent = gethui()
            else
                OpenUI.Parent = game:GetService("CoreGui")
            end
            
            OpenUI.Name = "OpenUI"
            OpenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            ImageButton.Parent = OpenUI
            ImageButton.BackgroundColor3 = Color3.fromRGB(105,105,105)
            ImageButton.BackgroundTransparency = 0.8
            ImageButton.Position = UDim2.new(0.9,0,0.1,0)
            ImageButton.Size = UDim2.new(0,50,0,50)
            ImageButton.Image = getgenv().Image
            ImageButton.Draggable = true
            ImageButton.Transparency = 0.2
            
            UICorner.CornerRadius = UDim.new(0,200)
            UICorner.Parent = ImageButton
            
            -- Khi click vào logo sẽ mở lại UI
            ImageButton.MouseButton1Click:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true,getgenv().ToggleUI,false,game)
            end)
        end
    end)
    
    if not success then
        warn("Lỗi khi tạo nút Logo UI: " .. tostring(errorMsg))
    end
end)

-- Thông báo khi script đã tải xong
Fluent:Notify({
    Title = "Anime Last Stand đã sẵn sàng",
    Content = "Script đã tải thành công! Đã tải cấu hình cho " .. playerName,
    Duration = 3
})
