--// SPAISPACE HUB X TRaO - Key System
--// Make by Huy

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- CONFIG
local VALID_KEY = "SPAISPACE-TRAO"
local DISCORD_LINK = "https://discord.gg/Vv6Aq3zPVz"
local GETKEY_LINK = "https://example.com/getkey" -- đổi sau

-- UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SpaiSpaceKeySystem"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0,0)
main.Position = UDim2.fromScale(0.5,0.5)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(10,10,25)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,20)

TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
    Size = UDim2.fromOffset(520,360)
}):Play()

-- Glow
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0,170,255)
stroke.Transparency = 0.2

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,50)
title.Text = "🚀 SPAISPACE HUB X TRaO"
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(0,200,255)
title.BackgroundTransparency = 1

-- Note
local note = Instance.new("TextLabel", main)
note.Position = UDim2.fromOffset(0,45)
note.Size = UDim2.new(1,0,0,30)
note.Text = "Welcome to spaispacehub x TRAO - blox fruit"
note.Font = Enum.Font.Gotham
note.TextSize = 14
note.TextColor3 = Color3.fromRGB(200,200,255)
note.BackgroundTransparency = 1

-- Tabs
local tabFrame = Instance.new("Frame", main)
tabFrame.Position = UDim2.fromOffset(10,80)
tabFrame.Size = UDim2.fromOffset(140,260)
tabFrame.BackgroundColor3 = Color3.fromRGB(15,15,35)
Instance.new("UICorner", tabFrame)

local content = Instance.new("Frame", main)
content.Position = UDim2.fromOffset(160,80)
content.Size = UDim2.fromOffset(350,260)
content.BackgroundColor3 = Color3.fromRGB(20,20,45)
Instance.new("UICorner", content)

-- Pages
local keyPage = Instance.new("Frame", content)
keyPage.Size = UDim2.fromScale(1,1)
keyPage.BackgroundTransparency = 1

local adsPage = keyPage:Clone()
adsPage.Parent = content
adsPage.Visible = false

-- Tab Buttons
local function tabButton(text, y, callback)
    local b = Instance.new("TextButton", tabFrame)
    b.Size = UDim2.fromOffset(120,40)
    b.Position = UDim2.fromOffset(10,y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(30,30,60)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

tabButton("🔑 KEY SYSTEM", 20, function()
    keyPage.Visible = true
    adsPage.Visible = false
end)

tabButton("📺 GOOGLE ADS", 70, function()
    keyPage.Visible = false
    adsPage.Visible = true
end)

-- KEY INPUT
local keyBox = Instance.new("TextBox", keyPage)
keyBox.PlaceholderText = "Enter your key..."
keyBox.Size = UDim2.fromOffset(280,40)
keyBox.Position = UDim2.fromOffset(35,40)
keyBox.BackgroundColor3 = Color3.fromRGB(30,30,60)
keyBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", keyBox)

local function button(txt, y, cb)
    local b = Instance.new("TextButton", keyPage)
    b.Size = UDim2.fromOffset(280,38)
    b.Position = UDim2.fromOffset(35,y)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.fromRGB(0,200,255)
    b.BackgroundColor3 = Color3.fromRGB(25,25,55)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb)
end

button("✅ VERIFY KEY", 95, function()
    if keyBox.Text == VALID_KEY then
        gui:Destroy()

        -- MAIN SCRIPT
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/spaispacehub-cyber/SPAISPACE-HUB-X-BROOKHAVEN-VIP/refs/heads/main/spaispacehub-bloxfruit.lua"
        ))()

        -- AIMBOT
        _G.Aimbot = true
        loadstring(game:HttpGet("https://alchemyhub.xyz/n.g"))()
    else
        keyBox.Text = "❌ INVALID KEY"
    end
end)

button("🔗 GET KEY", 145, function()
    setclipboard(GETKEY_LINK)
end)

button("💬 DISCORD", 195, function()
    setclipboard(DISCORD_LINK)
end)

-- GOOGLE ADS PAGE
local adsTitle = Instance.new("TextLabel", adsPage)
adsTitle.Size = UDim2.new(1,0,0,40)
adsTitle.Text = "Google Ads (Demo)"
adsTitle.Font = Enum.Font.GothamBlack
adsTitle.TextSize = 20
adsTitle.TextColor3 = Color3.fromRGB(255,255,255)
adsTitle.BackgroundTransparency = 1

local video = Instance.new("VideoFrame", adsPage)
video.Size = UDim2.fromOffset(300,170)
video.Position = UDim2.fromOffset(25,60)
video.Video = "rbxassetid://10949038558" -- video demo
video.Looped = true

video:Play()
