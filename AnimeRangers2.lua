print("Kaihon Hub | Anime Rangers X đang khởi động, vui lòng đợi 15 giây...")
wait(15)
print("Đang tải script...")

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
    warn("Không thể tải thư viện Fluent!")
    return
end

-- Hệ thống lưu trữ cấu hình
local ConfigSystem = {}
ConfigSystem.FileName = "KaihonALSConfig_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    -- Map Settings
    SelectedMap = "Marines Fort",
    SelectedAct = 1,
    AutoJoinEnabled = false,
    AutoStartEnabled = false,
    -- Console Settings
    ConsoleLogEnabled = true
}
ConfigSystem.CurrentConfig = {}

-- Hàm để lưu cấu hình
ConfigSystem.SaveConfig = function()
    local success, err = pcall(function()
        writefile(ConfigSystem.FileName, game:GetService("HttpService"):JSONEncode(ConfigSystem.CurrentConfig))
    end)
    if success then
        safeLog("Đã lưu cấu hình thành công!")
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
local consoleLogEnabled = ConfigSystem.CurrentConfig.ConsoleLogEnabled ~= false -- Mặc định true

-- Hàm log có điều kiện
local function safeLog(message)
    if consoleLogEnabled then
        print(message)
    end
end

-- Biến để kiểm soát coroutines
local autoJoinCoroutine = nil
local autoStartCoroutine = nil

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

-- Danh sách map và tìm index của map đã chọn
local mapList = {"Marines Fort", "Hell City", "Snowvy Capital", "Leaf Village", "Wanderniech", "Central City"}
local actList = {"1", "2", "3", "4", "5", "6"}

-- Tìm index của map đã lưu
local selectedMapIndex = 1
for i, map in ipairs(mapList) do
    if map == selectedMap then
        selectedMapIndex = i
        break
    end
end

-- Tìm index của act đã lưu
local selectedActIndex = selectedAct

-- Dropdown để chọn Map với giá trị mặc định từ config
MapSection:AddDropdown("MapDropdown", {
    Title = "Select Map",
    Values = mapList,
    Multi = false,
    Default = selectedMapIndex, -- Sử dụng index thay vì value
    Callback = function(Value)
        selectedMap = Value
        ConfigSystem.CurrentConfig.SelectedMap = Value
        ConfigSystem.SaveConfig()
        safeLog("Selected Map: " .. selectedMap)
    end
})

-- Dropdown để chọn Act với giá trị mặc định từ config
MapSection:AddDropdown("ActDropdown", {
    Title = "Select Act",
    Values = actList,
    Multi = false,
    Default = selectedActIndex, -- Sử dụng index thay vì value
    Callback = function(Value)
        selectedAct = tonumber(Value)
        ConfigSystem.CurrentConfig.SelectedAct = selectedAct
        ConfigSystem.SaveConfig()
        safeLog("Selected Act: " .. selectedAct)
    end
})

-- Toggle Auto Join Map
MapSection:AddToggle("AutoJoinToggle", {
    Title = "Auto Join Map",
    Default = autoJoinEnabled, -- Sử dụng biến đã load từ config
    Callback = function(Value)
        autoJoinEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinEnabled = Value
        ConfigSystem.SaveConfig()
        
        if autoJoinEnabled then
            Fluent:Notify({
                Title = "Auto Join Enabled",
                Content = "Auto joining " .. selectedMap .. " Act " .. selectedAct,
                Duration = 3
            })
            
            -- Tạo coroutine để tự động join map
            autoJoinCoroutine = coroutine.create(function()
                while autoJoinEnabled do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Remotes.Teleporter.Interact:FireServer("Select", selectedMap, selectedAct)
                        safeLog("Attempting to join: " .. selectedMap .. " Act " .. selectedAct)
                    end)
                    
                    -- Chờ 60 giây trước khi thử lại
                    for i = 1, 60 do
                        if not autoJoinEnabled then break end
                        wait(1)
                    end
                end
            end)
            
            coroutine.resume(autoJoinCoroutine)
        else
            Fluent:Notify({
                Title = "Auto Join Disabled",
                Content = "Stopped auto joining maps",
                Duration = 3
            })
            
            -- Dừng coroutine
            if autoJoinCoroutine then
                autoJoinCoroutine = nil
            end
        end
    end
})

-- Toggle Auto Start
MapSection:AddToggle("AutoStartToggle", {
    Title = "Auto Start",
    Default = autoStartEnabled, -- Sử dụng biến đã load từ config
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
            
            -- Tạo coroutine để tự động start
            autoStartCoroutine = coroutine.create(function()
                while autoStartEnabled do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Remotes.Teleporter.Interact:FireServer("Skip")
                        safeLog("Attempting to start match")
                    end)
                    
                    -- Chờ 60 giây trước khi thử lại
                    for i = 1, 60 do
                        if not autoStartEnabled then break end
                        wait(1)
                    end
                end
            end)
            
            coroutine.resume(autoStartCoroutine)
        else
            Fluent:Notify({
                Title = "Auto Start Disabled",
                Content = "Stopped auto starting matches",
                Duration = 3
            })
            
            -- Dừng coroutine
            if autoStartCoroutine then
                autoStartCoroutine = nil
            end
        end
    end
})

-- Settings tab
local SettingsSection = SettingsTab:AddSection("Script Settings")

-- Toggle Console Log
SettingsSection:AddToggle("ConsoleLogToggle", {
    Title = "Console Log",
    Description = "Bật/tắt log console để giảm lag",
    Default = consoleLogEnabled,
    Callback = function(Value)
        consoleLogEnabled = Value
        ConfigSystem.CurrentConfig.ConsoleLogEnabled = Value
        ConfigSystem.SaveConfig()
        
        if consoleLogEnabled then
            print("Console log đã được bật")
        else
            print("Console log đã được tắt - giảm lag")
        end
    end
})

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

-- Debug button để kiểm tra config hiện tại
SettingsSection:AddButton({
    Title = "Debug Config",
    Description = "Hiển thị cấu hình hiện tại",
    Callback = function()
        if consoleLogEnabled then
            print("=== CONFIG DEBUG ===")
            print("Selected Map:", ConfigSystem.CurrentConfig.SelectedMap)
            print("Selected Act:", ConfigSystem.CurrentConfig.SelectedAct)
            print("Auto Join:", ConfigSystem.CurrentConfig.AutoJoinEnabled)
            print("Auto Start:", ConfigSystem.CurrentConfig.AutoStartEnabled)
            print("Console Log:", ConfigSystem.CurrentConfig.ConsoleLogEnabled)
            print("File exists:", isfile(ConfigSystem.FileName))
        end
        
        Fluent:Notify({
            Title = "Debug Config",
            Content = "Map: " .. tostring(ConfigSystem.CurrentConfig.SelectedMap) .. " | Act: " .. tostring(ConfigSystem.CurrentConfig.SelectedAct) .. " | Log: " .. tostring(consoleLogEnabled),
            Duration = 5
        })
    end
})

-- Auto Save Config - chạy ít thường xuyên hơn
local function AutoSaveConfig()
    spawn(function()
        while wait(10) do -- Lưu mỗi 10 giây thay vì 5 giây
            pcall(function()
                ConfigSystem.SaveConfig()
            end)
        end
    end)
end

-- Thực thi tự động lưu cấu hình
AutoSaveConfig()

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
wait(1) -- Đợi một chút để UI render xong
Fluent:Notify({
    Title = "Anime Last Stand đã sẵn sàng",
    Content = "Script đã tải thành công! Map: " .. selectedMap .. " | Act: " .. selectedAct,
    Duration = 5
})

-- Debug: In ra config đã load (chỉ khi console log bật)
if consoleLogEnabled then
    print("=== LOADED CONFIG ===")
    print("Map:", selectedMap)
    print("Act:", selectedAct)
    print("Auto Join:", autoJoinEnabled)
    print("Auto Start:", autoStartEnabled)
    print("Console Log:", consoleLogEnabled)
end
