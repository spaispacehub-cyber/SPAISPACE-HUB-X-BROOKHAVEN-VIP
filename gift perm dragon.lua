local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Initial Config
getgenv().robux = 568228
local targetPlayer = ""

local Window = Fluent:CreateWindow({
    Title = "SPAISPACEHUBZZZ",
    SubTitle = "by Huy Vuong",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl 
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Main = Window:AddTab({ Title = "Fake Gift", Icon = "gift" }),
    Music = Window:AddTab({ Title = "Music", Icon = "music" }),
    VIP = Window:AddTab({ Title = "VIP Perks", Icon = "crown" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [[ TAB HOME ]]
Tabs.Home:AddParagraph({
    Title = "Welcome to SPAISPACEHUBZZZ",
    Content = "Hello Huy Vuong! System is ready to dominate."
})

Tabs.Home:AddButton({
    Title = "Copy Discord Link",
    Description = "Join for latest updates and support",
    Callback = function()
        setclipboard("https://discord.gg/spaispacehubzzz")
        Fluent:Notify({Title = "Discord", Content = "Link copied to clipboard!", Duration = 3})
    end
})

-- [[ TAB MAIN - FAKE GIFT ]]
local MainSection = Tabs.Main:AddSection("Troll Configuration")

Tabs.Main:AddInput("RobuxInput", {
    Title = "Custom Robux Amount",
    Default = "568228",
    Placeholder = "Enter Robux amount...",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        getgenv().robux = tonumber(Value) or 0
    end
})

Tabs.Main:AddInput("PlayerInput", {
    Title = "Target Username (Steal Skin)",
    Default = "",
    Placeholder = "Enter victim's name...",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        targetPlayer = Value
    end
})

Tabs.Main:AddButton({
    Title = "Execute Fake Gifter & Steal",
    Description = "Run GitHub script and copy character appearance",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/FakeGifterDragon.lua"))()
        
        if targetPlayer ~= "" then
            pcall(function()
                local id = game.Players:GetUserIdFromNameAsync(targetPlayer)
                game.Players.LocalPlayer.CharacterAppearanceId = id
                Fluent:Notify({Title = "Success", Content = "Identity stolen from " .. targetPlayer, Duration = 3})
            end)
        end
    end
})

-- [[ TAB MUSIC - YOUTUBE PLAYER ]]
Tabs.Music:AddParagraph({
    Title = "YouTube Music Player",
    Content = "Listen to your favorite tracks while trolling."
})

Tabs.Music:AddButton({
    Title = "Open Music Player",
    Description = "Launch the YouTube Music interface",
    Callback = function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua'),true))()
        Fluent:Notify({Title = "Music", Content = "YouTube Player Loaded!", Duration = 3})
    end
})

-- [[ TAB VIP - GIFT ALL & PRICE LIST ]]
Tabs.VIP:AddSection("VIP Exclusive Features")

Tabs.VIP:AddToggle("GiftAll", {Title = "Gift All Players (Global)", Default = false})

Tabs.VIP:AddButton({
    Title = "Execute VIP Gift All",
    Description = "Send fake gifts to everyone in the server",
    Callback = function()
        print("Executing Global Gift... (VIP Enabled)")
    end
})

local PriceSection = Tabs.VIP:AddSection("Price List & Contact")
Tabs.VIP:AddParagraph({
    Title = "Pricing Info",
    Content = "• Permanent VIP: $10\n• Weekly Access: $2\n• Custom Request: DM Huy Vuong"
})

Tabs.VIP:AddButton({
    Title = "Contact Support",
    Callback = function()
        setclipboard("https://discord.gg/spaispacehubzzz")
        Fluent:Notify({Title = "Support", Content = "Discord link copied!", Duration = 3})
    end
})

-- Managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("SPAISPACEHUBZZZ")
SaveManager:SetFolder("SPAISPACEHUBZZZ/HuyVuong")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "SPAISPACEHUBZZZ",
    Content = "Loaded Successfully. Welcome back, Huy Vuong!",
    Duration = 5
})
