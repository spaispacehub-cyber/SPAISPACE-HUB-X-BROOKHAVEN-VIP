-- [[ SPAISPACEHUBZZZ - FLUENT ULTIMATE EDITION ]]
-- // UI LIBRARY: FLUENT
-- // STATUS: ADDED FAKE GIFT V2 WITH MATH VERIFICATION

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ SYSTEM INFO ]]
local executorName = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Unknown Executor"
local isMobile = game:GetService("UserInputService").TouchEnabled and "Mobile" or "PC"

-- [[ GLOBALS & CONFIG ]]
getgenv().robux = 10000
getgenv().Config = {
    TargetPlayer = "",
    TikTokToken = "",
    YoutubeToken = "",
    MenuKey = Enum.KeyCode.LeftControl,
    EnteredKey = "",
    MathAnswer = "",
    MathAnswerV2 = "" -- Biến lưu đáp án cho Fake Gift v2
}

-- [[ CREATE WINDOW ]]
local Window = Fluent:CreateWindow({
    Title = "SPAISPACEHUBZZZ",
    SubTitle = "Update v2",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = getgenv().Config.MenuKey 
})

-- [[ TABS DEFINITION ]]
local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Dupe = Window:AddTab({ Title = "Dupe System", Icon = "copy" }),
    Visual = Window:AddTab({ Title = "Visual & Gifter", Icon = "eye" }),
    FakeGiftV2 = Window:AddTab({ Title = "Fake Gift v2", Icon = "gift" }), -- Tab mới thêm
    Player = Window:AddTab({ Title = "Player Hub", Icon = "user" }),
    Streaming = Window:AddTab({ Title = "Live Stream", Icon = "monitor" }),
    FakeSpawn = Window:AddTab({ Title = "Fake Spawn", Icon = "box" }),
    LuckBoost = Window:AddTab({ Title = "Luck Boost", Icon = "sparkles" }),
    VIP = Window:AddTab({ Title = "VIP", Icon = "gem" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [[ TAB: HOME ]]
Tabs.Home:AddParagraph({
    Title = "User Information",
    Content = "Current Executor: " .. executorName .. "\nPlatform: " .. isMobile
})
Tabs.Home:AddButton({
    Title = "Copy Discord Link",
    Description = "Click to copy official invite URL",
    Callback = function()
        setclipboard("https://discord.gg/BKRvmrcNA")
        Fluent:Notify({Title = "System", Content = "Discord link copied to clipboard!", Duration = 3})
    end
})

-- [[ TAB: DUPE SYSTEM (MATH VERIFICATION) ]]
local num1 = math.random(1, 10)
local num2 = math.random(1, 10)
local correctResult = num1 + num2

Tabs.Dupe:AddSection("Math Verification")
Tabs.Dupe:AddParagraph({
    Title = "Security Check",
    Content = "Solve this to unlock the Dupe script: " .. num1 .. " + " .. num2 .. " = ?"
})

Tabs.Dupe:AddInput("MathAnswerInput", {
    Title = "Enter Answer",
    Default = "",
    Placeholder = "Type result here...",
    Numeric = true,
    Callback = function(Value)
        getgenv().Config.MathAnswer = Value
    end
})

Tabs.Dupe:AddButton({
    Title = "Verify & Execute Dupe Script",
    Description = "Launches Huy Vuong Fruit Dupe if answer is correct",
    Callback = function()
        local userAnswer = tonumber(getgenv().Config.MathAnswer)
        if userAnswer == correctResult then
            Fluent:Notify({Title = "Correct Answer!", Content = "Dupe script is launching...", Duration = 3})
            loadstring(game:HttpGet("https://raw.githubusercontent.com/spaispacehub-cyber/SPAISPACE-HUB-X-BROOKHAVEN-VIP/refs/heads/main/Huy%20Vuong%20dupe.lua"))()
        else
            Fluent:Notify({Title = "Wrong Answer!", Content = "Please check your math and try again.", Duration = 3})
        end
    end
})

-- [[ TAB: VISUAL & GIFTER (FAKE GIFT V1) ]]
Tabs.Visual:AddSection("Fake Gifter System v1")
Tabs.Visual:AddInput("RobuxVal", {
    Title = "Set Fake Robux Amount",
    Default = "10000",
    Numeric = true,
    Callback = function(v) getgenv().robux = tonumber(v) or 10000 end
})
Tabs.Visual:AddButton({
    Title = "Execute Fake Gifter Dragon",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/FakeGifterDragon.lua"))()
    end
})

-- [[ TAB: FAKE GIFT V2 (MATH VERIFICATION) ]]
local v2_num1 = math.random(1, 10)
local v2_num2 = math.random(1, 10)
local v2_correctResult = v2_num1 + v2_num2

Tabs.FakeGiftV2:AddSection("Math Verification")
Tabs.FakeGiftV2:AddParagraph({
    Title = "Security Check",
    Content = "Solve this to unlock Fake Gift v2: " .. v2_num1 .. " + " .. v2_num2 .. " = ?"
})

Tabs.FakeGiftV2:AddInput("MathAnswerInputV2", {
    Title = "Enter Answer",
    Default = "",
    Placeholder = "Type result here...",
    Numeric = true,
    Callback = function(Value)
        getgenv().Config.MathAnswerV2 = Value
    end
})

Tabs.FakeGiftV2:AddButton({
    Title = "Verify & Execute Script",
    Description = "Launches Fake Gift v2 if answer is correct",
    Callback = function()
        local userAnswer = tonumber(getgenv().Config.MathAnswerV2)
        if userAnswer == v2_correctResult then
            Fluent:Notify({Title = "Correct Answer!", Content = "Fake Gift v2 script is launching...", Duration = 3})
            loadstring(game:HttpGet("https://raw.githubusercontent.com/spaispacehub-cyber/SPAISPACE-HUB-X-BROOKHAVEN-VIP/refs/heads/main/fakegiftv2.lua"))()
        else
            Fluent:Notify({Title = "Wrong Answer!", Content = "Please check your math and try again.", Duration = 3})
        end
    end
})

-- [[ TAB: PLAYER HUB ]]
Tabs.Player:AddSection("Identity Stealer")
Tabs.Player:AddInput("TargetPlayer", {
    Title = "Target Username",
    Default = "",
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
            Fluent:Notify({Title = "Success", Content = "Identity Cloned!", Duration = 3})
        end
    end
})

-- [[ TAB: LIVE STREAM ]]
Tabs.Streaming:AddSection("YouTube Music")
Tabs.Streaming:AddButton({
    Title = "Launch YouTube Music Player",
    Callback = function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua'),true))()
    end
})
Tabs.Streaming:AddSection("Streamer Bot Integration")
Tabs.Streaming:AddInput("TK", { Title = "TikTok Token", Callback = function(v) getgenv().Config.TikTokToken = v end })
Tabs.Streaming:AddInput("YT", { Title = "YouTube Token", Callback = function(v) getgenv().Config.YoutubeToken = v end })
Tabs.Streaming:AddToggle("AutoPin", { Title = "Auto Pin Bot Message", Default = false, Callback = function(v) end })

-- [[ TAB: FAKE SPAWN ]]
Tabs.FakeSpawn:AddSection("Event Simulation")
Tabs.FakeSpawn:AddButton({
    Title = "Execute Fake Spawn Dragon",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/DragonEastSpawner.lua"))()
    end
})

-- [[ TAB: LUCK BOOST (KEY SYSTEM) ]]
Tabs.LuckBoost:AddSection("Key Verification Required")
Tabs.LuckBoost:AddInput("KeyInput", {
    Title = "Enter Access Key",
    Default = "",
    Placeholder = "Password here...",
    Callback = function(Value)
        getgenv().Config.EnteredKey = Value
        if Value == "100ngaylovuong" then
            Fluent:Notify({Title = "Key Verified", Content = "Access Granted! Enjoy x100 Luck.", Duration = 4})
        end
    end
})
Tabs.LuckBoost:AddButton({
    Title = "Activate Blox Fruit x100 Luck",
    Description = "Requires correct key to run",
    Callback = function()
        if getgenv().Config.EnteredKey == "100ngaylovuong" then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/x100Luck.lua"))()
        else
            Fluent:Notify({Title = "Access Denied", Content = "You must enter the correct key first!", Duration = 3})
        end
    end
})

-- [[ TAB: VIP ]]
Tabs.VIP:AddSection("Exclusive Features")
Tabs.VIP:AddParagraph({
    Title = "Features Status",
    Content = "• Gift all game (Soon)\n• Live Chat Reader (Locked)\n• Custom Identity (Locked)"
})

-- [[ TAB: SETTINGS ]]
Tabs.Settings:AddSection("Performance Optimization")
Tabs.Settings:AddButton({
    Title = "Fix Lag (Ultra Optimizer)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hdanhhub/hdanhhub/refs/heads/main/fixlagbyhdanh.lua"))()
    end
})

Tabs.Settings:AddSection("Configurations")
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
    Title = "Minimize Menu Key",
    Default = "LeftControl",
    ChangedCallback = function(v) Window.MinimizeKey = v end
})

-- [[ FINALIZE MENU ]]
Window:SelectTab(1)
Fluent:Notify({
    Title = "SPAISPACEHUBZZZ",
    Content = "SPAISPACEHUBZZZ Loaded Successfully!",
    Duration = 4
})
