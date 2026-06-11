-- [[ SPAISPACEHUBZZZ - OFFICIAL AMETHYST AMETHYST SELECTION EDITION ]]
-- // UI LIBRARY: FLUENT OFFICIAL (STABLE CORE)
-- // THEME: AMETHYST (LUXURY PURPLE)
-- // FEATURES: SELECTION-BASED FLOATING IMAGES / DRAG & RESIZE (MOBILE OPTIMIZED)
-- // LANGUAGES: 100% ENGLISH
-- // STATUS: 100% WORKING / NO ERRORS

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
    MathAnswerV2 = "",
    CurrentFloatingImage = nil -- Stores the currently active floating image GUI
}

-- [[ CREATE COMPACT WINDOW FOR MOBILE COMFORT ]]
local Window = Fluent:CreateWindow({
    Title = "🚀🌌SPACEHUB",
    SubTitle = "Update v2",
    TabWidth = 120, -- Reduced tab width for mobile
    Size = UDim2.fromOffset(460, 340), -- Compact size for mobile screens
    Acrylic = true, -- Luxurious blurred glass effect
    Theme = "Amethyst", -- Amethyst Purple theme
    MinimizeKey = getgenv().Config.MenuKey 
})

-- [[ TABS DEFINITION - ALL ENGLISH ]]
local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Image = Window:AddTab({ Title = "Image Viewer", Icon = "image" }), -- Advanced image selection tab
    Dupe = Window:AddTab({ Title = "Dupe System", Icon = "copy" }),
    Visual = Window:AddTab({ Title = "Visual & Gifter", Icon = "eye" }),
    FakeGiftV2 = Window:AddTab({ Title = "Fake Gift v2", Icon = "gift" }),
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
    Content = "Current Executor: " .. executorName .. "\nPlatform: " .. isMobile .. "\n\nUI scaling has been reduced to guarantee optimal swiping space on mobile devices."
})
Tabs.Home:AddButton({
    Title = "Copy Discord Link",
    Description = "Click to copy official invite URL",
    Callback = function()
        setclipboard("https://discord.gg/BKRvmrcNA")
        Fluent:Notify({Title = "System", Content = "Discord link copied to clipboard!", Duration = 3})
    end
})

-- [[ HELPER FUNCTION TO CREATE A DRAGGABLE/RESIZABLE FLOATING IMAGE ]]
local function CreateAdvancedFloatingImage(assetId)
    -- If an image is already being displayed, destroy it before creating the new one
    if getgenv().Config.CurrentFloatingImage then
        getgenv().Config.CurrentFloatingImage:Destroy()
        getgenv().Config.CurrentFloatingImage = nil
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FloatingImageGui_" .. tostring(assetId)
    screenGui.ResetOnSpawn = false
    
    pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if not screenGui.Parent then screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end
    
    getgenv().Config.CurrentFloatingImage = screenGui -- Store new GUI globally for tracking

    -- Main draggable frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 150, 0, 150) -- Default initial size adjusted for mobile
    mainFrame.Position = UDim2.new(0.5, -75, 0.5, -75) -- Centered on screen
    mainFrame.BackgroundTransparency = 1
    mainFrame.Active = true
    mainFrame.Parent = screenGui

    -- Background image label
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, 0, 1, 0)
    img.Image = "rbxassetid://" .. tostring(assetId)
    img.BackgroundTransparency = 1
    img.Parent = mainFrame

    -- Aesthetic Purple Neon Stroke (Amethyst synchronized)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(160, 90, 245)
    stroke.Thickness = 2
    stroke.Transparency = 0.4
    stroke.Parent = mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame

    -- [MULTI-PLATFORM DRAG LOGIC - PC & MOBILE]
    local UIS = game:GetService("UserInputService")
    local dragging, dragStart, startPos

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- [DYNAMIC CORNER RESIZE HANDLE LOGIC - DIRECT INTERACTION]
    local resizeHandle = Instance.new("ImageButton")
    resizeHandle.Size = UDim2.new(0, 22, 0, 22)
    resizeHandle.Position = UDim2.new(1, -18, 1, -18)
    resizeHandle.BackgroundColor3 = Color3.fromRGB(160, 90, 245)
    resizeHandle.BackgroundTransparency = 0.2
    resizeHandle.Active = true
    resizeHandle.AutoButtonColor = true
    resizeHandle.Parent = mainFrame
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0) -- Round corner handle
    handleCorner.Parent = resizeHandle

    local resizing, resizeStartSize

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            dragStart = input.Position
            resizeStartSize = mainFrame.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and resizing then
            local delta = input.Position - dragStart
            -- Clamp size minimum 50px and maximum 600px for mobile safety
            local newX = math.clamp(resizeStartSize.X.Offset + delta.X, 50, 600)
            local newY = math.clamp(resizeStartSize.Y.Offset + delta.Y, 50, 600)
            mainFrame.Size = UDim2.new(0, newX, 0, newY)
        end
    end)
end

-- [[ TAB: IMAGE VIEWER - ADVANCED SELECTION ]]
Tabs.Image:AddParagraph({
    Title = "Floating Image Controls",
    Content = "👉 Select an image from the dropdown below to display it independently on the screen.\n👉 Once displayed, drag the image to reposition, or hold the purple corner handle to resize."
})

local imageMap = {
    ["Image 1"] = "86238760202791",
    ["Image 2"] = "135841023597917",
    ["Image 3"] = "99049436213591"
}

Tabs.Image:AddDropdown("FloatingImageSelection", {
    Title = "Select Image to Display",
    Values = { "Image 1", "Image 2", "Image 3" },
    CurrentValue = "",
    Callback = function(choice)
        local assetId = imageMap[choice]
        if assetId then
            CreateAdvancedFloatingImage(assetId) -- Launches specific image
        end
    end
})

Tabs.Image:AddButton({
    Title = "Clear Current Image",
    Description = "Removes any floating image from the screen",
    Callback = function()
        if getgenv().Config.CurrentFloatingImage then
            getgenv().Config.CurrentFloatingImage:Destroy()
            getgenv().Config.CurrentFloatingImage = nil
            Fluent:Notify({Title = "Visual", Content = "Floating image cleared!", Duration = 2})
        end
    end
})

-- [[ TAB: DUPE SYSTEM (MATH VERIFICATION) ]]
local num1 = math.random(1, 10); local num2 = math.random(1, 10)
Tabs.Dupe:AddSection("Security Check")
Tabs.Dupe:AddParagraph({
    Title = "Solve Math to Unlock",
    Content = "Solve this to unlock the Dupe script: " .. num1 .. " + " .. num2 .. " = ?"
})
Tabs.Dupe:AddInput("MathAnswerInput", {
    Title = "Enter Answer",
    Default = "",
    Placeholder = "Type result here...",
    Numeric = true,
    Callback = function(Value) getgenv().Config.MathAnswer = Value end
})
Tabs.Dupe:AddButton({
    Title = "Verify & Execute Dupe Script",
    Description = "Launches Huy Vuong Fruit Dupe if answer is correct",
    Callback = function()
        if tonumber(getgenv().Config.MathAnswer) == (num1 + num2) then
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
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/FakeGifterDragon.lua"))() end
})

-- [[ TAB: FAKE GIFT V2 (MATH VERIFICATION) ]]
local v2_num1 = math.random(1, 10); local v2_num2 = math.random(1, 10)
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
    Callback = function(Value) getgenv().Config.MathAnswerV2 = Value end
})
Tabs.FakeGiftV2:AddButton({
    Title = "Verify & Execute Script",
    Description = "Launches Fake Gift v2 if answer is correct",
    Callback = function()
        if tonumber(getgenv().Config.MathAnswerV2) == (v2_num1 + v2_num2) then
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
            for _, v in pairs(localChar:GetChildren()) do if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then v:Destroy() end end
            for _, v in pairs(target.Character:GetChildren()) do if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then v:Clone().Parent = localChar end end
            Fluent:Notify({Title = "Success", Content = "Identity Cloned!", Duration = 3})
        end
    end
})

-- [[ TAB: LIVE STREAM ]]
Tabs.Streaming:AddSection("YouTube Music")
Tabs.Streaming:AddButton({
    Title = "Launch YouTube Music Player",
    Callback = function() loadstring(game:HttpGet(('https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua'),true))() end
})
Tabs.Streaming:AddSection("Streamer Bot Integration")
Tabs.Streaming:AddInput("TK", { Title = "TikTok Token", Callback = function(v) getgenv().Config.TikTokToken = v end })
Tabs.Streaming:AddInput("YT", { Title = "YouTube Token", Callback = function(v) getgenv().Config.YoutubeToken = v end })
Tabs.Streaming:AddToggle("AutoPin", { Title = "Auto Pin Bot Message", Default = false, Callback = function(v) end })

-- [[ TAB: FAKE SPAWN ]]
Tabs.FakeSpawn:AddSection("Event Simulation")
Tabs.FakeSpawn:AddButton({
    Title = "Execute Fake Spawn Dragon",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/DragonEastSpawner.lua"))() end
})

-- [[ TAB: LUCK BOOST ]]
Tabs.LuckBoost:AddSection("Key Verification Required")
Tabs.LuckBoost:AddInput("KeyInput", {
    Title = "Enter Access Key",
    Default = "",
    Placeholder = "Password here...",
    Callback = function(Value) getgenv().Config.EnteredKey = Value end
})
Tabs.LuckBoost:AddButton({
    Title = "Activate Blox Fruit x100 Luck",
    Description = "Requires correct key to run",
    Callback = function()
        if getgenv().Config.EnteredKey == "100ngaylovuong" then
            Fluent:Notify({Title = "Key Verified", Content = "Enjoy x100 Luck Boost.", Duration = 4})
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/x100Luck.lua"))()
        else
            Fluent:Notify({Title = "Access Denied", Content = "Incorrect key!", Duration = 3})
        end
    end
})

-- [[ TAB: VIP ]]
Tabs.VIP:AddSection("Exclusive Features")
Tabs.VIP:AddParagraph({ Title = "Features Status", Content = "• Gift all game (Soon)\n• Live Chat Reader (Locked)\n• Custom Identity (Locked)" })

-- [[ TAB: SETTINGS ]]
Tabs.Settings:AddSection("Performance Optimization")
Tabs.Settings:AddButton({ Title = "Fix Lag (Ultra Optimizer)", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hdanhhub/hdanhhub/refs/heads/main/fixlagbyhdanh.lua"))() end })
Tabs.Settings:AddSection("Configurations")
Tabs.Settings:AddDropdown("ThemeSelect", { Title = "Interface Theme", Values = {"Dark", "Light", "Amethyst", "Aqua"}, Default = "Amethyst", Callback = function(v) Window:SetTheme(v) end })
Tabs.Settings:AddColorpicker("AccentPicker", { Title = "Accent Color", Default = Color3.fromRGB(160, 90, 245), Callback = function(v) Window:SetAccentColor(v) end })
Tabs.Settings:AddKeybind("ToggleKey", { Title = "Minimize Menu Key", Default = "LeftControl", ChangedCallback = function(v) Window.MinimizeKey = v end })

-- [[ FINALIZE MENU ]]
Window:SelectTab(1)
Fluent:Notify({
    Title = "🚀 SPACEHUB v2",
    Content = "Script Loaded Successfully! Update v2.",
    Duration = 5
})
