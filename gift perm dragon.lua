-- [[ SPAISPACEHUBZZZ - ULTIMATE KEY SYSTEM EDITION ]]
-- // UI: FLUENT LIBRARY
-- // STATUS: FULLY OPTIMIZED / MULTI-PLATFORM / EXTENDED TABS

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ EXECUTOR DETECTOR ]]
local executorName = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Unknown / Mobile Executor"

-- [[ GLOBALS & CONFIG ]]
getgenv().robux = 10000
getgenv().Config = {
    TargetPlayer = "",
    TikTokToken = "",
    YoutubeToken = "",
    MenuKey = Enum.KeyCode.LeftControl,
    EnteredKey = "" -- Lưu key người dùng nhập
}

local Window = Fluent:CreateWindow({
    Title = "SPAISPACEHUBZZZ",
    SubTitle = "Extreme Streamer Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 520),
    Acrylic = false, -- Tắt Acrylic giúp mượt mà trên Mobile
    Theme = "Dark",
    MinimizeKey = getgenv().Config.MenuKey 
})

-- [[ TABS DEFINITION ]]
local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Visual = Window:AddTab({ Title = "Visual & Gifter", Icon = "eye" }),
    Player = Window:AddTab({ Title = "Player Hub", Icon = "user" }),
    Streaming = Window:AddTab({ Title = "Live Stream", Icon = "broadcast" }),
    FakeSpawn = Window:AddTab({ Title = "Fake Spawn", Icon = "box" }), -- Tab 1 mới thêm
    LuckBoost = Window:AddTab({ Title = "Luck Boost", Icon = "clover" }), -- Tab 2 mới thêm (Cần Key)
    VIP = Window:AddTab({ Title = "VIP", Icon = "gem" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [[ TAB: HOME ]]
Tabs.Home:AddParagraph({
    Title = "User Information",
    Content = "Current Executor: " .. executorName .. "\nPlatform: " .. (game:GetService("UserInputService").TouchEnabled and "Mobile" or "PC")
})

Tabs.Home:AddButton({
    Title = "Copy Discord Link",
    Description = "https://discord.gg/BKRvmrcNA",
    Callback = function()
        setclipboard("https://discord.gg/BKRvmrcNA")
        Fluent:Notify({Title = "Success", Content = "Discord link copied!"})
    end
})

-- [[ TAB: VISUAL & GIFTER ]]
Tabs.Visual:AddSection("Fake Gifter")
Tabs.Visual:AddInput("RobuxVal", {
    Title = "Set Fake Robux Amount",
    Default = "10000",
    Numeric = true,
    Callback = function(v) getgenv().robux = tonumber(v) end
})

Tabs.Visual:AddButton({
    Title = "Execute Fake Gifter Dragon",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/FakeGifterDragon.lua"))()
    end
})

-- [[ TAB: PLAYER HUB (GET SKIN) ]]
Tabs.Player:AddSection("Identity Stealer")
Tabs.Player:AddInput("TargetPlayer", {
    Title = "Target Username",
    Callback = function(v) getgenv().Config.TargetPlayer = v end
})

Tabs.Player:AddButton({
    Title = "Steal Outfit",
    Callback = function()
        local target = game.Players:FindFirstChild(getgenv().Config.TargetPlayer)
        local localChar = game.Players.LocalPlayer.Character
        if target and target.Character and localChar then
            for _, v in pairs(localChar:GetChildren()) do
                if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then v:Destroy() end
            end
            for _, v in pairs(target.Character:GetChildren()) do
                if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then v:Clone().Parent = localChar end
            end
            Fluent:Notify({Title = "Success", Content = "Identity Cloned!"})
        end
    end
})

-- [[ TAB: LIVE STREAM ]]
Tabs.Streaming:AddSection("YouTube Music")
Tabs.Streaming:AddButton({
    Title = "Launch YouTube Music",
    Callback = function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua'),true))()
    end
})

Tabs.Streaming:AddSection("Stream Bot")
Tabs.Streaming:AddInput("TK", { Title = "TikTok Token", Callback = function(v) getgenv().Config.TikTokToken = v end })
Tabs.Streaming:AddInput("YT", { Title = "YouTube Token", Callback = function(v) getgenv().Config.YoutubeToken = v end })

Tabs.Streaming:AddToggle("AutoPin", {
    Title = "Auto Pin Bot Message",
    Default = false,
    Callback = function(v) end
})

Tabs.Streaming:AddParagraph({ Title = "Live Chat", Content = "[VIP ONLY] Chat display restricted." })


-- [[ TAB 1: FAKE SPAWN (NÚT ẤN) ]]
Tabs.FakeSpawn:AddSection("Dragon Spawner System")
Tabs.FakeSpawn:AddButton({
    Title = "Execute Fake Spawn Dragon",
    Description = "Spawns a visual fake dragon east event",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/DragonEastSpawner.lua"))()
    end
})


-- [[ TAB 2: LUCK BOOST (HỆ THỐNG KHÓA KEY) ]]
Tabs.LuckBoost:AddSection("Key Verification Required")

local KeyParagraph = Tabs.LuckBoost:AddParagraph({
    Title = "Status: Locked",
    Content = "Please enter the correct key to unlock the Blox Fruit x100 Luck Boost features."
})

local LuckButton -- Biến để quản lý nút ẩn/hiện

Tabs.LuckBoost:AddInput("KeyInput", {
    Title = "Enter Key Here",
    Placeholder = "Enter password...",
    Callback = function(Value)
        getgenv().Config.EnteredKey = Value
        if Value == "takaboyskibiditoletmocbuomkhongchedumaanhbiettakaboythichditnhauma" then
            KeyParagraph:SetTitle("Status: Unlocked ✅")
            KeyParagraph:SetText("Correct key! You can now use the feature below.")
            if LuckButton then LuckButton.Visible = true end
            Fluent:Notify({Title = "Key System", Content = "Access Granted! Enjoy x100 Luck.", Duration = 4})
        else
            KeyParagraph:SetTitle("Status: Locked ❌")
            KeyParagraph:SetText("Incorrect key! Access denied.")
            if LuckButton then LuckButton.Visible = false end
        end
    end
})

Tabs.LuckBoost:AddSection("Luck Features")
LuckButton = Tabs.LuckBoost:AddButton({
    Title = "Activate Blox Fruit x100 Luck Boost",
    Description = "Improves your luck by x100 times",
    Callback = function()
        if getgenv().Config.EnteredKey == "100ngaylovuong" then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/x100Luck.lua"))()
        else
            Fluent:Notify({Title = "Error", Content = "You must enter the correct key first!", Duration = 3})
        end
    end
})
LuckButton.Visible = false -- Mặc định ẩn nút khi chưa nhập key đúng


-- [[ TAB: VIP ]]
Tabs.VIP:AddSection("VIP Membership")
Tabs.VIP:AddParagraph({
    Title = "Exclusive Features",
    Content = "• Gift all game (Soon)\n• Live Chat Reader\n• Custom Identity"
})
Tabs.VIP:AddParagraph({
    Title = "Access Status",
    Content = "Status: SOON"
})

-- [[ TAB: SETTINGS ]]
Tabs.Settings:AddSection("Menu Customization")
Tabs.Settings:AddDropdown("ThemeSelect", {
    Title = "Interface Theme",
    Values = {"Dark", "Light", "Amethyst", "Aqua"},
    Default = "Dark",
    Callback = function(v) Window:SetTheme(v) end
})

Tabs.Settings:AddColorpicker("AccentPicker", {
    Title = "Accent Color",
    Default = Color3.fromRGB(0, 120, 255),
    Callback = function(v) Window:SetAccentColor(v) end
})

Tabs.Settings:AddKeybind("ToggleKey", {
    Title = "Menu Keybind",
    Default = "LeftControl",
    ChangedCallback = function(v) Window.MinimizeKey = v end
})

Tabs.Settings:AddSection("Performance")
Tabs.Settings:AddButton({
    Title = "Fix Lag (Ultra)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hdanhhub/hdanhhub/refs/heads/main/fixlagbyhdanh.lua"))()
    end
})

Window:SelectTab(1)
Fluent:Notify({
    Title = "SPAISPACEHUBZZZ",
    Content = "Script Loaded with Security Integration!",
    Duration = 5
})
