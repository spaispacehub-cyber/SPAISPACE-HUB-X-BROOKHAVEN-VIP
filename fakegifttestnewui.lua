--[[
███████╗██████╗  █████╗ ██╗███████╗██████╗  █████╗  ██████╗███████╗
██╔════╝██╔══██╗██╔══██╗██║██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝
███████╗██████╔╝███████║██║███████╗██████╔╝███████║██║     █████╗
╚════██║██╔═══╝ ██╔══██║██║╚════██║██╔═══╝ ██╔══██║██║     ██╔══╝
███████║██║     ██║  ██║██║███████║██║     ██║  ██║╚██████╗███████╗
╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝╚══════╝

██████╗ ██╗   ██╗██████╗ ███████╗███████╗███████╗███████╗███████╗
╚════██╗██║   ██║╚════██╗╚══███╔╝╚══███╔╝╚══███╔╝╚══███╔╝╚══███╔╝
 █████╔╝██║   ██║ █████╔╝  ███╔╝   ███╔╝   ███╔╝   ███╔╝   ███╔╝
██╔═══╝ ██║   ██║██╔═══╝  ███╔╝   ███╔╝   ███╔╝   ███╔╝   ███╔╝
███████╗╚██████╔╝███████╗███████╗███████╗███████╗███████╗███████╗
╚══════╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝

SPAISPACEHUBZZZ fake gift v2
--]]

local Players            = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService   = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

-- ============================================================
--  CONFIG
-- ============================================================
local Config = {
    FakeBalance   = 5000000,
    BuyAccent     = Color3.fromRGB(0,   110, 255),
    BuyAccentDark = Color3.fromRGB(0,   60,  160),
    BgDark        = Color3.fromRGB(18,  18,  24),
    BgMid         = Color3.fromRGB(28,  28,  38),
    BgLight       = Color3.fromRGB(48,  48,  62),
    TextMain      = Color3.fromRGB(240, 240, 255),
    TextSub       = Color3.fromRGB(160, 160, 190),
    PanelRed      = Color3.fromRGB(180, 20,  20),
    PanelRedDark  = Color3.fromRGB(30,  8,   8),
}

-- ============================================================
--  FRUIT DATABASE
-- ============================================================
local BLOX_LOGO = "rbxassetid://2804185542"

local Fruits = {
    {name="Bomb",    id=44669609, price=220,  icon="rbxthumb://type=Asset&id=72369528696047&w=150&h=150", outline=Color3.fromRGB(80,80,80)    },
    {name="Spike",   id=44669616, price=380,  icon="rbxthumb://type=Asset&id=131167693319825&w=150&h=150", outline=Color3.fromRGB(80,80,80)    },
    {name="blade",    id=44669618, price=100,  icon="rbxthumb://type=Asset&id=116884668999743&w=150&h=150", outline=Color3.fromRGB(80,80,80)    },
    {name="Spring",  id=44669621, price=180,   icon="rbxthumb://type=Asset&id=131259631046573&w=150&h=150", outline=Color3.fromRGB(80,80,80)    },
    {name="rocket",    id=44669613, price=50,   icon="rbxthumb://type=Asset&id=138286042637253&w=150&h=150", outline=Color3.fromRGB(80,80,80)    },
    {name="Smoke",   id=44669624, price=250,  icon="rbxthumb://type=Asset&id=82043762754488&w=150&h=150", outline=Color3.fromRGB(180,180,180) },
    {name="Spin",    id=44669628, price=75,  icon="rbxthumb://type=Asset&id=132896972664540&w=150&h=150", outline=Color3.fromRGB(80,80,80)    },
    {name="Flame",   id=44669633, price=550,  icon="rbxthumb://type=Asset&id=108831553026356&w=150&h=150", outline=Color3.fromRGB(220,80,20)   },
    {name="Ice",     id=44669637, price=750,  icon="rbxthumb://type=Asset&id=74875972194260&w=150&h=150", outline=Color3.fromRGB(160,220,255) },
    {name="Sand",    id=44669641, price=850,  icon="rbxthumb://type=Asset&id=106977568354230&w=150&h=150", outline=Color3.fromRGB(200,170,80)  },
    {name="Dark",    id=44669644, price=950,  icon="rbxthumb://type=Asset&id=102350616725604&w=150&h=150", outline=Color3.fromRGB(80,20,120)   },
    {name="Diamond", id=44669648, price=1000,  icon="rbxthumb://type=Asset&id=73956493227615&w=150&h=150", outline=Color3.fromRGB(160,220,255) },
    {name="Light",   id=44669651, price=1100,  icon="rbxthumb://type=Asset&id=82087340639683&w=150&h=150", outline=Color3.fromRGB(240,220,100) },
    {name="Rubber",  id=44669655, price=1200,  icon="rbxthumb://type=Asset&id=130679323833459&w=150&h=150", outline=Color3.fromRGB(220,60,60)   },
    {name="Creation", id=44669659, price=1750,  icon="rbxthumb://type=Asset&id=95414926547178&w=150&h=150", outline=Color3.fromRGB(180,180,220) },
    {name="Magma",   id=44669663, price=1300, icon="rbxthumb://type=Asset&id=111233020985043&w=150&h=150", outline=Color3.fromRGB(200,60,20)},
    {name="Quake",   id=44669668, price=1500, icon="rbxthumb://type=Asset&id=122826264224872&w=150&h=150", outline=Color3.fromRGB(160,140,100) },
    {name="Buddha",  id=44669672, price=1650,
        icon    = "rbxthumb://type=Asset&id=11337649787&w=150&h=150",
        outline = Color3.fromRGB(220,180,20)
    },
    {name="Love",    id=44669676, price=1700, icon="rbxthumb://type=Asset&id=113290491848534&w=150&h=150", outline=Color3.fromRGB(255,100,160) },
    {name="Spider",  id=44669679, price=1800, icon="rbxthumb://type=Asset&id=76759665031963&w=150&h=150", outline=Color3.fromRGB(60,60,60)    },
    {name="Sound",   id=44669683, price=1900, icon="rbxthumb://type=Asset&id=83607585966959&w=150&h=150", outline=Color3.fromRGB(180,100,220) },
    {name="Phoenix", id=44669687, price=2100, icon="rbxthumb://type=Asset&id=74573221561916&w=150&h=150", outline=Color3.fromRGB(220,120,20)  },
    {name="Portal",  id=44669691, price=2000,
        icon    = "rbxthumb://type=Asset&id=12181754234&w=150&h=150",
        outline = Color3.fromRGB(100,180,255)
    },
    {name="Pain",     id=44669694, price=2200, icon="rbxthumb://type=Asset&id=73742359616995&w=150&h=150", outline=Color3.fromRGB(220,100,140) },
    {name="Gravity", id=44669697, price=2300, icon="rbxthumb://type=Asset&id=99762032764913&w=150&h=150", outline=Color3.fromRGB(140,60,200)  },
    {name="Dough",   id=44669701, price=2400,  icon="rbxthumb://type=Asset&id=125845430464185&w=150&h=150", outline=Color3.fromRGB(220,180,100)},
    {name="Shadow",  id=44669704, price=2425, icon="rbxthumb://type=Asset&id=90578079260600&w=150&h=150", outline=Color3.fromRGB(80,20,120)   },
    {name="Venom",   id=44669708, price=2450, icon="rbxthumb://type=Asset&id=98654395812215&w=150&h=150", outline=Color3.fromRGB(60,180,40)   },
    {name="Control", id=44669712, price=4000,
        icon    = "rbxthumb://type=Asset&id=114700721050665&w=150&h=150",
        outline = Color3.fromRGB(40,180,255)
    },
    {name="Spirit",  id=44669716, price=2550, icon="rbxthumb://type=Asset&id=90235152191021&w=150&h=150", outline=Color3.fromRGB(255,220,80)  },
    {name="Dragon",  id=44669720, price=5000,
        icon    = "rbxthumb://type=Asset&id=133280182324260&w=150&h=150",
        outline = Color3.fromRGB(180,60,20)
    },
    {name="tiger", id=44669724, price=3000, icon        = "rbxthumb://type=Asset&id=106563484423236&w=150&h=150", outline=Color3.fromRGB(200,160,20)  },
    {name="Kitsune", id=44669728, price=4000,
        icon    = "rbxthumb://type=Asset&id=124061211172749&w=150&h=150",
        outline = Color3.fromRGB(20,100,220)
    },
    {name="Yeti",    id=44669730, price=3000, icon="rbxthumb://type=Asset&id=94927024877593&w=150&h=150", outline=Color3.fromRGB(160,220,255) },
    {name="Gas",     id=44669749, price=2500, icon="rbxthumb://type=Asset&id=87151676586578&w=150&h=150", outline=Color3.fromRGB(180,220,100)},
}

-- ============================================================
--  UTILITIES
-- ============================================================
local function fmtComma(n)
    local s = tostring(math.floor(n))
    local k
    repeat s, k = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2") until k == 0
    return s
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function stroke(p, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color        = col   or Color3.new(1,1,1)
    s.Thickness    = thick or 1.5
    s.Transparency = trans or 0.5
    s.Parent = p
    return s
end

local function lbl(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font           = props.Font  or Enum.Font.GothamBold
    l.TextSize       = props.Size  or 14
    l.TextColor3     = props.Color or Config.TextMain
    l.Text           = props.Text  or ""
    l.TextXAlignment = props.Align or Enum.TextXAlignment.Left
    l.Position       = props.Pos   or UDim2.new(0,0,0,0)
    l.Size           = props.FS    or UDim2.new(1,0,1,0)
    l.TextWrapped    = props.Wrap  or false
    l.ZIndex         = props.Z     or 3
    l.Parent         = parent
    return l
end

local function robuxIcon(parent, size, pos, z)
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Image    = "rbxasset://textures/ui/common/robux@3x.png"
    img.Size     = UDim2.fromOffset(size, size)
    img.Position = pos or UDim2.new(0,0,0,0)
    img.ZIndex   = z or 3
    img.Parent   = parent
    return img
end

-- ============================================================
--  PURCHASE COMPLETED MODAL
-- ============================================================
-- ============================================================
--  SENDING GIFT NOTIFICATION  (top screen slide)
-- ============================================================
local function showGiftNotification(fruitName, recipient)
    local cleanName = fruitName:match("^Permanent (.+)$") or fruitName

    local gui = Instance.new("ScreenGui")
    gui.DisplayOrder   = 1002
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent         = playerGui

    local container = Instance.new("Frame")
    container.Size                   = UDim2.fromOffset(620, 60)
    container.AnchorPoint            = Vector2.new(0.5, 0)
    container.Position               = UDim2.new(0.5, 0, 0, -80)
    container.BackgroundTransparency = 1
    container.BorderSizePixel        = 0
    container.Parent                 = gui

    local line1 = Instance.new("TextLabel")
    line1.Size                   = UDim2.new(1, 0, 0, 28)
    line1.Position               = UDim2.fromOffset(0, 0)
    line1.BackgroundTransparency = 1
    line1.Font                   = Enum.Font.GothamBold
    line1.TextSize               = 30
    line1.TextColor3             = Color3.fromRGB(255, 255, 255)
    line1.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    line1.TextStrokeTransparency = 0.4
    line1.TextXAlignment         = Enum.TextXAlignment.Center
    line1.RichText               = true
    line1.Text                   = 'Sending gift <font color="rgb(255,200,50)">&lt;Permanent ' .. cleanName .. '&gt;</font> to ' .. recipient .. '...'
    line1.Parent                 = container

    local line2 = Instance.new("TextLabel")
    line2.Size                   = UDim2.new(1, 0, 0, 28)
    line2.Position               = UDim2.fromOffset(0, -30)
    line2.BackgroundTransparency = 1
    line2.Font                   = Enum.Font.GothamBold
    line2.TextSize               = 30
    line2.TextColor3             = Color3.fromRGB(80, 220, 120)
    line2.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    line2.TextStrokeTransparency = 0.4
    line2.TextXAlignment         = Enum.TextXAlignment.Center
    line2.TextTransparency       = 1
    line2.Text                   = 'Gift sent successfully!'
    line2.Parent                 = container

    local slideIn  = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local slideOut = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    TweenService:Create(container, slideIn, { Position = UDim2.new(0.5, 0, 0, 4) }):Play()

    task.delay(2.0, function()
        if not line2.Parent then return end
        line2.TextTransparency = 0
        TweenService:Create(line2, slideIn, { Position = UDim2.fromOffset(0, 30) }):Play()
    end)

    task.delay(6.0, function()
        if not container.Parent then return end
        TweenService:Create(container, slideOut, { Position = UDim2.new(0.5, 0, 0, -80) }):Play()
        task.delay(0.6, function() gui:Destroy() end)
    end)
end

local function showPurchaseDone(productInfo, recipient)
    recipient = recipient or "Unknown"

    local MODAL_W = 560
    local MODAL_H = 210

    local gui = Instance.new("ScreenGui")
    gui.DisplayOrder   = 999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent         = playerGui

    -- Dark backdrop
    local backdrop = Instance.new("Frame")
    backdrop.Size                   = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.5
    backdrop.BorderSizePixel        = 0
    backdrop.ZIndex                 = 1
    backdrop.Parent                 = gui

    local modal = Instance.new("Frame")
    modal.Size             = UDim2.fromOffset(MODAL_W, MODAL_H)
    modal.Position         = UDim2.fromScale(0.5, 0.5)
    modal.AnchorPoint      = Vector2.new(0.5, 0.5)
    modal.BackgroundColor3 = Config.BgMid
    modal.BorderSizePixel  = 0
    modal.ZIndex           = 2
    modal.Parent           = gui
    corner(modal, 16)
    stroke(modal, Color3.fromRGB(80, 80, 95), 1.5, 0.2)

    -- Title
    lbl(modal, {
        Text  = "Purchase Completed",
        Size  = 18,
        Pos   = UDim2.fromOffset(22, 16),
        FS    = UDim2.new(1, -60, 0, 28),
        Align = Enum.TextXAlignment.Left,
        Z     = 3,
    })

    -- X close button
    local xBtn = Instance.new("TextButton")
    xBtn.Position            = UDim2.new(1, -12, 0, 12)
    xBtn.AnchorPoint         = Vector2.new(1, 0)
    xBtn.Size                = UDim2.fromOffset(26, 26)
    xBtn.BackgroundTransparency = 1
    xBtn.Text                = "×"
    xBtn.Font                = Enum.Font.GothamBold
    xBtn.TextSize            = 24
    xBtn.TextColor3          = Config.TextSub
    xBtn.ZIndex              = 10
    xBtn.Parent              = modal

    -- Divider line
    local divider = Instance.new("Frame")
    divider.Size             = UDim2.new(1, 0, 0, 1)
    divider.Position         = UDim2.fromOffset(0, 50)
    divider.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    divider.BorderSizePixel  = 0
    divider.ZIndex           = 3
    divider.Parent           = modal

    -- Checkmark circle (centered in the body area)
    local ch = Instance.new("Frame")
    ch.Size        = UDim2.fromOffset(54, 54)
    ch.Position    = UDim2.new(0.5, 0, 0, 68)
    ch.AnchorPoint = Vector2.new(0.5, 0)
    ch.BackgroundTransparency = 1
    ch.ZIndex      = 3
    ch.Parent      = modal

    local circ = Instance.new("Frame")
    circ.Size                   = UDim2.fromScale(1, 1)
    circ.BackgroundTransparency = 1
    circ.ZIndex                 = 3
    circ.Parent                 = ch
    corner(circ, 100)
    stroke(circ, Color3.fromRGB(200, 200, 215), 2.5, 0)

    local chk = Instance.new("ImageLabel")
    chk.Size                   = UDim2.fromScale(0.68, 0.68)
    chk.Position               = UDim2.fromScale(0.5, 0.5)
    chk.AnchorPoint            = Vector2.new(0.5, 0.5)
    chk.BackgroundTransparency = 1
    chk.Image                  = "rbxassetid://3944680095"
    chk.ImageColor3            = Color3.fromRGB(220, 220, 230)
    chk.ZIndex                 = 4
    chk.Parent                 = ch

    -- Sub-text
    lbl(modal, {
        Text  = "You purchased " .. productInfo.Name .. ".",
        Size  = 14,
        Color = Config.TextSub,
        Pos   = UDim2.new(0, 20, 0, 128),
        FS    = UDim2.new(1, -40, 0, 22),
        Wrap  = false,
        Align = Enum.TextXAlignment.Center,
        Font  = Enum.Font.GothamMedium,
        Z     = 3,
    })

    -- OK button — full width, short
    local ok = Instance.new("TextButton")
    ok.Size             = UDim2.new(1, -40, 0, 38)
    ok.Position         = UDim2.fromOffset(20, 158)
    ok.BackgroundColor3 = Config.BuyAccent
    ok.Text             = "OK"
    ok.Font             = Enum.Font.GothamBold
    ok.TextSize         = 15
    ok.TextColor3       = Color3.new(1, 1, 1)
    ok.AutoButtonColor  = false
    ok.ZIndex           = 4
    ok.Parent           = modal
    corner(ok, 10)

    -- Hover effect on OK
    ok.MouseEnter:Connect(function()
        TweenService:Create(ok, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(60, 140, 255)}):Play()
    end)
    ok.MouseLeave:Connect(function()
        TweenService:Create(ok, TweenInfo.new(0.12), {BackgroundColor3 = Config.BuyAccent}):Play()
    end)

    -- Animate modal in
    modal.Position = UDim2.fromScale(0.5, 0.58)
    modal:TweenPosition(UDim2.fromScale(0.5, 0.5), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.38, true)

    -- Checkmark pop in
    ch.Size = UDim2.fromOffset(0, 0)
    task.delay(0.28, function()
        if not ch.Parent then return end
        TweenService:Create(ch, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.fromOffset(54, 54)}):Play()
    end)

    local function finish()
        gui:Destroy()
    end
    ok.MouseButton1Click:Connect(finish)
    xBtn.MouseButton1Click:Connect(finish)
end

-- ============================================================
--  BUY ITEM MODAL
-- ============================================================
local function showBuyModal(productInfo, recipient)
    recipient = recipient or "Unknown"
    local price      = productInfo.PriceInRobux or 0
    local newBalance = math.max(Config.FakeBalance - price, 0)

    local MODAL_W = 560
    local MODAL_H = 210

    local old = playerGui:FindFirstChild("HazeHub_BuyModal")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name           = "HuyVuong_BuyModal"
    gui.DisplayOrder   = 999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent         = playerGui

    -- Dark backdrop
    local backdrop = Instance.new("Frame")
    backdrop.Size                   = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.5
    backdrop.BorderSizePixel        = 0
    backdrop.ZIndex                 = 1
    backdrop.Parent                 = gui

    local modal = Instance.new("Frame")
    modal.Size             = UDim2.fromOffset(MODAL_W, MODAL_H)
    modal.Position         = UDim2.fromScale(0.5, 0.42)
    modal.AnchorPoint      = Vector2.new(0.5, 0.5)
    modal.BackgroundColor3 = Config.BgMid
    modal.BorderSizePixel  = 0
    modal.ZIndex           = 2
    modal.Parent           = gui
    corner(modal, 16)
    stroke(modal, Color3.fromRGB(80, 80, 95), 1.5, 0.2)

    -- Title "Buy Item"
    lbl(modal, {
        Text  = "Buy Item",
        Size  = 18,
        Pos   = UDim2.fromOffset(22, 16),
        FS    = UDim2.new(1, -150, 0, 28),
        Align = Enum.TextXAlignment.Left,
        Z     = 3,
    })

    -- X close button
    local xBtn = Instance.new("TextButton")
    xBtn.Position            = UDim2.new(1, -12, 0, 12)
    xBtn.AnchorPoint         = Vector2.new(1, 0)
    xBtn.Size                = UDim2.fromOffset(26, 26)
    xBtn.BackgroundTransparency = 1
    xBtn.Text                = "×"
    xBtn.Font                = Enum.Font.GothamBold
    xBtn.TextSize            = 24
    xBtn.TextColor3          = Config.TextSub
    xBtn.ZIndex              = 25
    xBtn.Parent              = modal
    xBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Balance display (top-right, next to X)
    local balFrame = Instance.new("Frame")
    balFrame.Position          = UDim2.new(1, -44, 0, 16)
    balFrame.AnchorPoint       = Vector2.new(1, 0)
    balFrame.Size              = UDim2.fromOffset(0, 22)
    balFrame.AutomaticSize     = Enum.AutomaticSize.X
    balFrame.BackgroundTransparency = 1
    balFrame.ZIndex            = 5
    balFrame.Parent            = modal
    robuxIcon(balFrame, 16, UDim2.fromOffset(0, 3), 5)
    local balTxt = Instance.new("TextLabel")
    balTxt.BackgroundTransparency = 1
    balTxt.Position    = UDim2.fromOffset(20, 0)
    balTxt.Size        = UDim2.new(0, 0, 1, 0)
    balTxt.AutomaticSize = Enum.AutomaticSize.X
    balTxt.Text        = fmtComma(Config.FakeBalance)
    balTxt.Font        = Enum.Font.GothamBold
    balTxt.TextSize    = 14
    balTxt.TextColor3  = Config.TextMain
    balTxt.ZIndex      = 5
    balTxt.Parent      = balFrame

    -- Divider line
    local divider = Instance.new("Frame")
    divider.Size             = UDim2.new(1, 0, 0, 1)
    divider.Position         = UDim2.fromOffset(0, 50)
    divider.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    divider.BorderSizePixel  = 0
    divider.ZIndex           = 3
    divider.Parent           = modal

    -- Item row (icon + name + price)
    local row = Instance.new("Frame")
    row.Position             = UDim2.fromOffset(20, 60)
    row.Size                 = UDim2.new(1, -40, 0, 74)
    row.BackgroundTransparency = 1
    row.ZIndex               = 3
    row.Parent               = modal

    -- Icon frame with colored outline
    local iconFrame = Instance.new("Frame")
    iconFrame.Size             = UDim2.fromOffset(66, 66)
    iconFrame.BackgroundColor3 = Config.BgDark
    iconFrame.BorderSizePixel  = 0
    iconFrame.ZIndex           = 3
    iconFrame.Parent           = row
    corner(iconFrame, 10)
    stroke(iconFrame, productInfo.Outline or Color3.fromRGB(100,100,100), 2, 0.1)

    local iconImg = Instance.new("ImageLabel")
    iconImg.Size                   = UDim2.fromOffset(58, 58)
    iconImg.AnchorPoint            = Vector2.new(0.5, 0.5)
    iconImg.Position               = UDim2.fromScale(0.5, 0.5)
    iconImg.BackgroundTransparency = 1
    iconImg.Image                  = productInfo.Icon or BLOX_LOGO
    iconImg.ScaleType              = Enum.ScaleType.Fit
    iconImg.ZIndex                 = 4
    iconImg.Parent                 = iconFrame

    -- Text column
    local textCol = Instance.new("Frame")
    textCol.Position             = UDim2.fromOffset(82, 0)
    textCol.Size                 = UDim2.new(1, -82, 1, 0)
    textCol.BackgroundTransparency = 1
    textCol.ZIndex               = 3
    textCol.Parent               = row

    lbl(textCol, {
        Text  = productInfo.Name,
        Size  = 16,
        Pos   = UDim2.fromOffset(0, 8),
        FS    = UDim2.new(1, 0, 0, 24),
        Align = Enum.TextXAlignment.Left,
        Z     = 3,
    })

    local priceRow = Instance.new("Frame")
    priceRow.Position             = UDim2.fromOffset(0, 40)
    priceRow.Size                 = UDim2.fromOffset(160, 22)
    priceRow.BackgroundTransparency = 1
    priceRow.ZIndex               = 3
    priceRow.Parent               = textCol
    robuxIcon(priceRow, 18, UDim2.fromOffset(0, 2), 3)
    lbl(priceRow, {
        Text  = fmtComma(price),
        Size  = 15,
        Pos   = UDim2.fromOffset(22, 0),
        FS    = UDim2.new(1, -22, 1, 0),
        Align = Enum.TextXAlignment.Left,
        Z     = 3,
    })

    -- Buy button — full width, short, with fill animation
    local buyBtn = Instance.new("TextButton")
    buyBtn.Position         = UDim2.fromOffset(20, 154)
    buyBtn.Size             = UDim2.new(1, -40, 0, 38)
    buyBtn.BackgroundColor3 = Config.BuyAccentDark
    buyBtn.AutoButtonColor  = false
    buyBtn.Text             = ""
    buyBtn.Active           = false
    buyBtn.ZIndex           = 3
    buyBtn.Parent           = modal
    corner(buyBtn, 10)

    local fillBar = Instance.new("Frame")
    fillBar.Size             = UDim2.new(0, 0, 1, 0)
    fillBar.BackgroundColor3 = Config.BuyAccent
    fillBar.BorderSizePixel  = 0
    fillBar.ZIndex           = 4
    fillBar.Parent           = buyBtn
    corner(fillBar, 10)

    lbl(buyBtn, {
        Text  = "Buy",
        Size  = 15,
        Z     = 5,
        Align = Enum.TextXAlignment.Center,
    })

    -- Footer (gifting label)
    local footer = Instance.new("Frame")
    footer.Size             = UDim2.new(1, 0, 0, 0)
    footer.BackgroundTransparency = 1
    footer.ZIndex           = 4
    footer.Parent           = modal

    -- Animate modal in
    modal:TweenPosition(UDim2.fromScale(0.5, 0.5), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.42, true)

    -- Fill bar animation
    task.spawn(function()
        task.wait(0.5)
        if not fillBar or not fillBar.Parent then return end
        TweenService:Create(fillBar,
            TweenInfo.new(2.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(1, 0, 1, 0)}):Play()
    end)
    task.delay(0.5, function()
        if buyBtn and buyBtn.Parent then buyBtn.Active = true end
    end)

    -- Hover effects
    buyBtn.MouseEnter:Connect(function()
        if not buyBtn.Active then return end
        TweenService:Create(buyBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30, 100, 220)}):Play()
    end)
    buyBtn.MouseLeave:Connect(function()
        TweenService:Create(buyBtn, TweenInfo.new(0.12), {BackgroundColor3 = Config.BuyAccentDark}):Play()
    end)

    buyBtn.MouseButton1Click:Connect(function()
        if not buyBtn.Active then return end
        Config.FakeBalance = newBalance
        gui:Destroy()
        showGiftNotification(productInfo.Name, recipient)
        task.defer(function()
            showPurchaseDone(productInfo, recipient)
        end)
    end)
end

-- ============================================================
--  HELPERS
-- ============================================================
local function findFruitByName(text)
    if not text then return nil end

    -- First try to extract the fruit name from the exact BF label format:
    -- "Gifting [username] <Permanent FruitName>" or "Permanent FruitName"
    -- This avoids matching fruit names that appear inside usernames

    -- Extract from <Permanent FruitName> pattern
    local fromTag = text:match("<Permanent%s+(.-)>") or text:match("Permanent%s+(%a+)")
    if fromTag then
        local clean = fromTag:match("^%s*(.-)%s*$") -- trim
        for _, f in ipairs(Fruits) do
            if f.name:lower() == clean:lower() then return f end
        end
    end

    -- Fallback: only match if fruit name appears as a whole word (surrounded by
    -- non-alpha chars or string boundaries) — prevents "ice" matching "iceoirea34"
    local lower = text:lower()
    for _, f in ipairs(Fruits) do
        local fname = f.name:lower()
        -- Use word boundary pattern: fruit name must NOT be preceded or followed by a letter/number
        local pattern = "(^|[^%a%d])" .. fname .. "([^%a%d]|$)"
        if lower:match("[^%a%d]" .. fname .. "[^%a%d]")
            or lower:match("^" .. fname .. "[^%a%d]")
            or lower:match("[^%a%d]" .. fname .. "$")
            or lower:match("^" .. fname .. "$") then
            return f
        end
    end
    return nil
end

local function findFruitById(id)
    for _, f in ipairs(Fruits) do
        if f.id == id then return f end
    end
    return nil
end

local function fruitToProductInfo(fruit)
    return {
        Name         = "Permanent " .. fruit.name,
        AssetId      = fruit.id,
        PriceInRobux = fruit.price,
        Icon         = fruit.icon,
        Outline      = fruit.outline,
    }
end

-- ============================================================
--  SETTINGS GUI
-- ============================================================
local PANEL_W, PANEL_H = 240, 160
local ISLAND_X_OFF = 16
local ISLAND_Y_OFF = -28

local settingsGui = Instance.new("ScreenGui")
settingsGui.Name           = "HuyVuong_setting"
settingsGui.DisplayOrder   = 998
settingsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
settingsGui.ResetOnSpawn   = false
settingsGui.Parent         = playerGui

local island = Instance.new("TextButton")
island.Size             = UDim2.fromOffset(56, 56)
island.Position         = UDim2.new(0, ISLAND_X_OFF, 0.5, ISLAND_Y_OFF)
island.BackgroundColor3 = Color3.fromRGB(14,14,20)
island.Text             = ""
island.AutoButtonColor  = false
island.ZIndex           = 30
island.Parent           = settingsGui
corner(island, 100)

local glow = Instance.new("ImageLabel")
glow.Size               = UDim2.fromOffset(80,80)
glow.AnchorPoint        = Vector2.new(0.5,0.5)
glow.Position           = UDim2.fromScale(0.5,0.5)
glow.BackgroundTransparency = 1
glow.Image              = "rbxassetid://5028857084"
glow.ImageColor3        = Color3.fromRGB(255,38,38)
glow.ImageTransparency  = 0.4
glow.ZIndex             = 29
glow.Parent             = island

lbl(island, {Text="H", Size=28, Font=Enum.Font.GothamBlack,
    Color=Color3.fromRGB(255,38,38), Align=Enum.TextXAlignment.Center, Z=31})

local ring = Instance.new("UIStroke")
ring.Color        = Color3.fromRGB(255,38,38)
ring.Thickness    = 2.5
ring.Transparency = 0.3
ring.Parent       = island

task.spawn(function()
    while island.Parent do
        TweenService:Create(ring, TweenInfo.new(0.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.8}):Play()
        task.wait(0.6)
        TweenService:Create(ring, TweenInfo.new(0.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.1}):Play()
        task.wait(0.6)
    end
end)

local panel = Instance.new("Frame")
panel.Size             = UDim2.fromOffset(PANEL_W, PANEL_H)
panel.BackgroundColor3 = Config.BgMid
panel.BorderSizePixel  = 0
panel.Visible          = false
panel.ZIndex           = 20
panel.Parent           = settingsGui
corner(panel, 12)
stroke(panel, Color3.fromRGB(255,38,38), 1.5, 0.6)

local function updatePanelPos()
    local ix = island.Position.X.Offset
    local iy = island.Position.Y.Offset
    panel.Position = UDim2.new(0, ix + 64, 0.5, iy - PANEL_H/2 + 28)
end
updatePanelPos()

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.fromOffset(40,40)
hideBtn.Position = UDim2.new(0,80,0.5,-28)
hideBtn.BackgroundColor3 = Color3.fromRGB(255,38,38)
hideBtn.Text = "X"
hideBtn.TextColor3 = Color3.new(1,1,1)
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 18
hideBtn.ZIndex = 100
hideBtn.Parent = settingsGui
corner(hideBtn,100)

hideBtn.MouseButton1Click:Connect(function()
	if panel and panel.Parent then
		panel:Destroy()
	end

	if island and island.Parent then
		island:Destroy()
	end

	hideBtn:Destroy()
end)

local ph = Instance.new("Frame")
ph.Size             = UDim2.new(1,0,0,40)
ph.BackgroundColor3 = Config.PanelRedDark

local ph = Instance.new("Frame")
ph.Size             = UDim2.new(1,0,0,40)
ph.BackgroundColor3 = Config.PanelRedDark
ph.BorderSizePixel  = 0
ph.ZIndex           = 21
ph.Parent           = panel
corner(ph, 12)
local phFix = Instance.new("Frame")
phFix.Size             = UDim2.new(1,0,0.5,0)
phFix.Position         = UDim2.new(0,0,0.5,0)
phFix.BackgroundColor3 = Config.PanelRedDark
phFix.BorderSizePixel  = 0
phFix.ZIndex           = 21
phFix.Parent           = ph

lbl(ph, {Text="SPAISPACEHUB  •  Blox Fruits", Size=13, Font=Enum.Font.GothamBlack,
    Color=Color3.fromRGB(255,38,38), Pos=UDim2.fromOffset(12,0), Z=22})

local panelClose = Instance.new("TextButton")
panelClose.Size               = UDim2.fromOffset(36,20)
panelClose.Position           = UDim2.new(1,-40,0.5,0)
panelClose.AnchorPoint        = Vector2.new(0,0.5)
panelClose.BackgroundTransparency = 1
panelClose.Text               = "close"
panelClose.Font               = Enum.Font.Gotham
panelClose.TextSize           = 11
panelClose.TextColor3         = Config.TextSub
panelClose.ZIndex             = 22
panelClose.Parent             = ph

lbl(panel, {Text="Robux  FAKE BALANCE", Size=10, Color=Config.TextSub,
    Pos=UDim2.fromOffset(16,50), FS=UDim2.new(1,-32,0,14), Z=22})

local balBox = Instance.new("TextBox")
balBox.Size               = UDim2.new(1,-32,0,32)
balBox.Position           = UDim2.fromOffset(16,66)
balBox.BackgroundColor3   = Config.BgDark
balBox.BorderSizePixel    = 0
balBox.Text               = tostring(Config.FakeBalance)
balBox.PlaceholderText    = "e.g. 5000000"
balBox.Font               = Enum.Font.GothamMedium
balBox.TextSize           = 13
balBox.TextColor3         = Config.TextMain
balBox.PlaceholderColor3  = Config.TextSub
balBox.ClearTextOnFocus   = false
balBox.ZIndex             = 22
balBox.Parent             = panel
corner(balBox, 6)
stroke(balBox, Color3.fromRGB(255,38,38), 1, 0.65)

local applyBtn = Instance.new("TextButton")
applyBtn.Size             = UDim2.new(1,-32,0,32)
applyBtn.Position         = UDim2.fromOffset(16,108)
applyBtn.BackgroundColor3 = Config.PanelRed
applyBtn.Text             = "✔  Apply"
applyBtn.Font             = Enum.Font.GothamBlack
applyBtn.TextSize         = 13
applyBtn.TextColor3       = Color3.new(1,1,1)
applyBtn.AutoButtonColor  = false
applyBtn.ZIndex           = 22
applyBtn.Parent           = panel
corner(applyBtn, 8)

local applyDebounce = false
applyBtn.MouseButton1Click:Connect(function()
    if applyDebounce then return end
    applyDebounce = true
    local raw = balBox.Text:gsub("[,%s]","")
    local v = tonumber(raw)
    if v and v > 0 then Config.FakeBalance = v end
    applyBtn.Text             = "✔  Applied!"
    applyBtn.BackgroundColor3 = Color3.fromRGB(20,180,80)
    task.delay(1.5, function()
        if not applyBtn or not applyBtn.Parent then return end
        applyBtn.Text             = "✔  Apply"
        applyBtn.BackgroundColor3 = Config.PanelRed
        applyDebounce = false
    end)
end)

local panelOpen = false
local dragMoved = false

do
    local dragging  = false
    local dragStart = nil
    local startPos  = nil

    island.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragMoved = false
            dragStart = i.Position
            startPos  = island.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then
                dragMoved = true
                island.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
                updatePanelPos()
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

island.MouseButton1Click:Connect(function()
    if dragMoved then return end
    if not panelOpen then
        panelOpen = true
        updatePanelPos()
        panel.Size    = UDim2.fromOffset(0,0)
        panel.Visible = true
        TweenService:Create(panel, TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Size=UDim2.fromOffset(PANEL_W,PANEL_H)}):Play()
    end
end)

panelClose.MouseButton1Click:Connect(function()
    panelOpen = false
    TweenService:Create(panel, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.fromOffset(0,0)}):Play()
    task.delay(0.25, function() panel.Visible = false end)
end)

-- ============================================================
--  HOOK
-- ============================================================
local hookedBtns    = {}
local lastFruit     = nil
local lastRecipient = ""

local function scanGiftingLabel()
    for _, desc in ipairs(playerGui:GetDescendants()) do
        if (desc:IsA("TextLabel") or desc:IsA("TextButton")) then
            local t = desc.Text or ""
            if t:find("Gifting") and t:find("Permanent") then
                -- Extract username first
                local u = t:match("%[(.-)%]")
                if u and u ~= "" then lastRecipient = u end

                -- Extract fruit name ONLY from the part after the username bracket
                -- This prevents matching fruit names inside the username itself
                -- BF format: "Gifting [username] <Permanent FruitName>"
                local afterBracket = t:match("%]%s*(.+)$") or t
                local f = findFruitByName(afterBracket)
                if f then lastFruit = f end
            end
        end
    end
end

-- LAYER 1: hookmetamethod
pcall(function()
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if self == MarketplaceService and
           (method == "PromptGamePassPurchase" or
            method == "PromptProductPurchase"  or
            method == "PromptPurchase") then
            scanGiftingLabel()
            local id    = tonumber(select(2, ...))
            local fruit = (id and findFruitById(id)) or lastFruit
            if fruit then
                local r = lastRecipient ~= "" and lastRecipient or "Unknown"
                task.defer(function() showBuyModal(fruitToProductInfo(fruit), r) end)
                return
            end
        end
        return old(self, ...)
    end))
end)

-- LAYER 2: nuke Roblox purchase prompt GUIs
local ROBLOX_PURCHASE_GUIS = {
    ["RobloxPromptGui"] = true,
    ["PurchasePrompt"]  = true,
    ["RobuxPurchase"]   = true,
}
task.spawn(function()
    while true do
        task.wait(0.05)
        for _, sg in ipairs(playerGui:GetChildren()) do
            if sg:IsA("ScreenGui") and ROBLOX_PURCHASE_GUIS[sg.Name] then
                scanGiftingLabel()
                local fruit = lastFruit
                local r     = lastRecipient ~= "" and lastRecipient or "Unknown"
                sg:Destroy()
                if fruit then
                    task.defer(function() showBuyModal(fruitToProductInfo(fruit), r) end)
                end
            end
        end
    end
end)

-- LAYER 3: overlay on gift confirm buttons
local function hookConfirmButton(btn)
    if not (btn:IsA("TextButton") or btn:IsA("ImageButton")) then return end
    if hookedBtns[btn] then return end
    if btn:IsDescendantOf(settingsGui) then return end
    local sg = btn:FindFirstAncestorWhichIsA("ScreenGui")
    if sg and sg.Name:find("HazeHub") then return end
    if btn:FindFirstChild("_HazeOverlay") then return end

    local text = (btn.Text or ""):lower()
    local name = (btn.Name or ""):lower()

    local isInsideGiftModal = false
    local p = btn.Parent
    for _ = 1, 8 do
        if not p then break end
        if p:IsA("TextLabel") or p:IsA("TextButton") then
            local t = (p.Text or ""):lower()
            if t:find("send a gift") or t:find("gifting") then
                isInsideGiftModal = true; break
            end
        end
        for _, c in ipairs(p:GetChildren()) do
            if (c:IsA("TextLabel") or c:IsA("TextButton")) then
                local t = (c.Text or ""):lower()
                if t:find("send a gift") or t:find("gifting") then
                    isInsideGiftModal = true; break
                end
            end
        end
        if isInsideGiftModal then break end
        p = p.Parent
    end

    local isConfirm      = text:find("🎁") and text:match("%d%d%d+")
    local isNamedConfirm = name:find("buy") or name:find("confirm") or name:find("purchase") or name:find("gift")

    if not (isInsideGiftModal or isConfirm or isNamedConfirm) then return end

    hookedBtns[btn] = true
    btn.MouseEnter:Connect(function() scanGiftingLabel() end)

    local overlay = Instance.new("TextButton")
    overlay.Name = "_HazeOverlay"
    overlay.Size = UDim2.fromScale(1,1)
    overlay.BackgroundTransparency = 1
    overlay.Text = ""
    overlay.ZIndex = (btn.ZIndex or 1) + 50
    overlay.Parent = btn

    pcall(function()
        if getconnections then
            for _,c in ipairs(getconnections(btn.MouseButton1Click)) do pcall(function() c:Disable() end) end
            for _,c in ipairs(getconnections(btn.Activated))         do pcall(function() c:Disable() end) end
        end
    end)

    overlay.MouseButton1Click:Connect(function()
        scanGiftingLabel()
        local fruit = lastFruit
        local r     = lastRecipient ~= "" and lastRecipient or "Unknown"
        if fruit then showBuyModal(fruitToProductInfo(fruit), r) end
    end)
end

for _, v in ipairs(playerGui:GetDescendants()) do
    task.defer(function() if v and v.Parent then hookConfirmButton(v) end end)
end

playerGui.DescendantAdded:Connect(function(d)
    task.delay(0.05, function()
        if d and d.Parent then hookConfirmButton(d) end
        if (d:IsA("TextLabel") or d:IsA("TextButton")) then
            local t = d.Text or ""
            if t:find("Gifting") and t:find("Permanent") then scanGiftingLabel() end
        end
    end)
end)

task.spawn(function()
    while true do task.wait(0.3); scanGiftingLabel() end
end)

print("[SPAISPACEHUBZZZ] Loaded! Dough now has its own icon. Go to Permanent Fruit Shop → Gift → pick user → click price button.")
