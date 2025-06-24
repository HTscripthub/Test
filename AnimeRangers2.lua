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
ConfigSystem.FileName = "KaihonAVConfig_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    SelectedMap = "Marines Fort",
    SelectedAct = 1,
    AutoStartEnabled = false
}
ConfigSystem.CurrentConfig = {}

-- Hàm để lưu cấu hình
ConfigSystem.SaveConfig = function()
    local success, err = pcall(function()
        writefile(ConfigSystem.FileName, game:GetService("HttpService"):JSONEncode(ConfigSystem.CurrentConfig))
    end)
    if success then
        print("Đã lưu cấu hình thành công!")
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

-- Cấu hình UI
local Window = Fluent:CreateWindow({
    Title = "Kaihon Hub | Anime Last Stand",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tạo tab Main duy nhất
local MainTab = Window:AddTab({ Title = "Map", Icon = "rbxassetid://13311802307" })

-- Integration with SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Thay đổi cách lưu cấu hình để sử dụng tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name
InterfaceManager:SetFolder("KaihonHubAV")
SaveManager:SetFolder("KaihonHubAV/" .. playerName)

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
    for _, tab in pairs({MainTab, SummonTab, MapsTab, SettingsTab}) do
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
    Title = "Kaihon Hub đã sẵn sàng",
    Content = "Script đã tải thành công! Đã tải cấu hình cho " .. playerName,
    Duration = 3
})

-- === Thêm Dropdown và Toggle cho Auto Start Map ===
local mapList = {"Marines Fort", "Hell City", "Snowvy Capital", "Leaf Village", "Wanderniech", "Central City"}
local actList = {1, 2, 3, 4, 5, 6}

-- Giá trị mặc định
ConfigSystem.DefaultConfig.SelectedMap = mapList[1]
ConfigSystem.DefaultConfig.SelectedAct = actList[1]
ConfigSystem.DefaultConfig.AutoStartEnabled = false

ConfigSystem.CurrentConfig.SelectedMap = ConfigSystem.CurrentConfig.SelectedMap or ConfigSystem.DefaultConfig.SelectedMap
ConfigSystem.CurrentConfig.SelectedAct = ConfigSystem.CurrentConfig.SelectedAct or ConfigSystem.DefaultConfig.SelectedAct
ConfigSystem.CurrentConfig.AutoStartEnabled = ConfigSystem.CurrentConfig.AutoStartEnabled or ConfigSystem.DefaultConfig.AutoStartEnabled

-- Dropdown chọn map
local mapDropdown = MainTab:AddDropdown("SelectMapDropdown", {
    Title = "Select Map",
    Values = mapList,
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SelectedMap,
    Callback = function(value)
        ConfigSystem.CurrentConfig.SelectedMap = value
        ConfigSystem.SaveConfig()
    end
})

-- Dropdown chọn act
local actDropdown = MainTab:AddDropdown("SelectActDropdown", {
    Title = "Select Act",
    Values = actList,
    Multi = false,
    Default = ConfigSystem.CurrentConfig.SelectedAct,
    Callback = function(value)
        ConfigSystem.CurrentConfig.SelectedAct = value
        ConfigSystem.SaveConfig()
    end
})

-- Toggle Auto Start
local autoStartToggle
local autoStartThread
local function doAutoStart()
    while ConfigSystem.CurrentConfig.AutoStartEnabled do
        local map = ConfigSystem.CurrentConfig.SelectedMap or mapList[1]
        local act = ConfigSystem.CurrentConfig.SelectedAct or actList[1]
        -- Gửi lệnh chọn map và act
        local mapArg = map
        if map == "Central City" then
            mapArg = "Central City(Map)" -- Đúng format yêu cầu
        end
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.Teleporter.Interact:FireServer("Select", mapArg, act)
            wait(1)
            game:GetService("ReplicatedStorage").Remotes.Teleporter.Interact:FireServer("Skip")
        end)
        -- Lặp lại sau 5 giây
        wait(5)
    end
end

autoStartToggle = MainTab:AddToggle("AutoStartToggle", {
    Title = "Auto Start",
    Default = ConfigSystem.CurrentConfig.AutoStartEnabled,
    Callback = function(state)
        ConfigSystem.CurrentConfig.AutoStartEnabled = state
        ConfigSystem.SaveConfig()
        if state then
            if autoStartThread == nil or coroutine.status(autoStartThread) == "dead" then
                autoStartThread = coroutine.create(doAutoStart)
                coroutine.resume(autoStartThread)
            end
        end
    end
})
