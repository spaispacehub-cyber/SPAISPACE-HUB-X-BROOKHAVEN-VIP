-- ============================================================
-- PART 1: CORE SETUP & FRUITS DATABASE
-- ============================================================
local Players            = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService   = game:GetService("UserInputService")
local localPlayer        = Players.LocalPlayer
local playerGui          = localPlayer:WaitForChild("PlayerGui")

local BLOX_LOGO = "rbxassetid://102325862990442" -- Default Icon

-- Cấu hình số dư và giao diện
_G.Config = {
    FakeBalance = 5000000,
    BgColor     = Color3.fromRGB(25, 25, 31),
    AccentColor = Color3.fromRGB(0, 115, 255),
    TextMain    = Color3.fromRGB(255, 255, 255),
    TextSub     = Color3.fromRGB(160, 160, 165)
}

-- Danh sách Trái Ác Quỷ (Cập nhật từ dữ liệu của bạn)
_G.FruitsTable = {
    {name="Bomb",    id=44669609, price=275,  icon=BLOX_LOGO},
    {name="Spike",   id=44669616, price=300,  icon=BLOX_LOGO},
    {name="Chop",    id=44669618, price=100,  icon=BLOX_LOGO},
    {name="Spring",  id=44669621, price=60,   icon=BLOX_LOGO},
    {name="Kilo",    id=44669613, price=70,   icon=BLOX_LOGO},
    {name="Smoke",   id=44669624, price=100,  icon=BLOX_LOGO},
    {name="Spin",    id=44669628, price=180,  icon=BLOX_LOGO},
    {name="Flame",   id=44669633, price=550,  icon=BLOX_LOGO},
    {name="Ice",     id=44669637, price=350,  icon=BLOX_LOGO},
    {name="Sand",    id=44669641, price=420,  icon=BLOX_LOGO},
    {name="Dark",    id=44669644, price=500,  icon=BLOX_LOGO},
    {name="Diamond", id=44669648, price=600,  icon=BLOX_LOGO},
    {name="Light",   id=44669651, price=650,  icon=BLOX_LOGO},
    {name="Rubber",  id=44669655, price=750,  icon=BLOX_LOGO},
    {name="Barrier", id=44669659, price=800,  icon=BLOX_LOGO},
    {name="Magma",   id=44669663, price=1300, icon="rbxthumb://type=Asset&id=111233020985043&w=150&h=150"},
    {name="Quake",   id=44669668, price=1000, icon=BLOX_LOGO},
    {name="Buddha",  id=44669672, price=1650, icon="rbxthumb://type=Asset&id=11337649787&w=150&h=150"},
    {name="Love",    id=44669676, price=1300, icon=BLOX_LOGO},
    {name="Spider",  id=44669679, price=1500, icon=BLOX_LOGO},
    {name="Sound",   id=44669683, price=1700, icon=BLOX_LOGO},
    {name="Phoenix", id=44669687, price=1800, icon=BLOX_LOGO},
    {name="Portal",  id=44669691, price=2000, icon="rbxthumb://type=Asset&id=12181754234&w=150&h=150"},
    {name="Paw",     id=44669694, price=2000, icon=BLOX_LOGO},
    {name="Gravity", id=44669697, price=2500, icon=BLOX_LOGO},
    {name="Dough",   id=44669701, price=2400, icon="rbxthumb://type=Asset&id=125845430464185&w=150&h=150"},
    {name="Shadow",  id=44669704, price=2900, icon=BLOX_LOGO},
    {name="Venom",   id=44669708, price=3000, icon=BLOX_LOGO},
    {name="Control", id=44669712, price=4000, icon="rbxthumb://type=Asset&id=11330851538&w=150&h=150"},
    {name="Spirit",  id=44669716, price=3400, icon=BLOX_LOGO},
    {name="Dragon",  id=44669720, price=5000, icon="rbxthumb://type=Asset&id=71929406555073&w=150&h=150"},
    {name="Leopard", id=44669724, price=3500, icon=BLOX_LOGO},
    {name="Kitsune", id=44669728, price=4000, icon="rbxthumb://type=Asset&id=102325862990442&w=150&h=150"},
    {name="Yeti",    id=44669730, price=3000, icon="rbxthumb://type=Asset&id=74056126745233&w=150&h=150"},
    {name="Gas",     id=44669749, price=2500, icon="rbxthumb://type=Asset&id=87151676586578&w=150&h=150"},
}

-- Hàm tiện ích
_G.GetFruitData = function(query)
    for _, f in ipairs(_G.FruitsTable) do
        if query == f.id or string.find(string.lower(query), string.lower(f.name)) then return f end
    end
    return {name = "Fruit", price = 2500, icon = BLOX_LOGO}
end

print("[HazeHub] Part 1 (DB) Loaded.")
-- ============================================================
-- PART 2: ADVANCED HOOK ENGINE
-- ============================================================
local HookData = { Recipient = "Unknown", Fruit = nil }

local function syncData()
    for _, v in ipairs(playerGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Visible and v.Text:find("Gifting") then
            HookData.Recipient = v.Text:match("%[(.-)%]") or HookData.Recipient
            local fName = v.Text:match("<Permanent%s+(.-)>") or v.Text:match("%]%s*(.+)$")
            if fName then HookData.Fruit = _G.GetFruitData(fName) end
        end
    end
end

-- Hook Namecall (Chặn bảng mua thật)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and self == MarketplaceService and method:find("Purchase") then
        syncData()
        local fruit = (args[2] and _G.GetFruitData(args[2])) or HookData.Fruit
        if fruit then
            task.defer(function() _G.ShowNativeModal(fruit, HookData.Recipient) end)
            return nil
        end
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- Overlay Hijack (Đè lên nút bấm shop)
task.spawn(function()
    while true do
        for _, b in ipairs(playerGui:GetDescendants()) do
            if (b:IsA("TextButton") or b:IsA("ImageButton")) and not b:FindFirstChild("_Haze") then
                if b.Text:match("%d%d%d+") or b.Name:lower():find("gift") then
                    local ov = Instance.new("TextButton", b)
                    ov.Name = "_Haze"; ov.Size = UDim2.fromScale(1,1); ov.BackgroundTransparency = 1; ov.Text = ""; ov.ZIndex = 999
                    ov.MouseButton1Click:Connect(function()
                        syncData()
                        _G.ShowNativeModal(HookData.Fruit or _G.GetFruitData("Kitsune"), HookData.Recipient)
                    end)
                end
            end
        end
        task.wait(1)
    end
end)
-- ============================================================
-- PART 3: NATIVE BUY MODAL UI
-- ============================================================
_G.ShowNativeModal = function(fruit, recipient)
    if playerGui:FindFirstChild("HazeModal") then playerGui.HazeModal:Destroy() end
    local sg = Instance.new("ScreenGui", playerGui); sg.Name = "HazeModal"; sg.DisplayOrder = 999
    
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.fromOffset(440, 260); f.Position = UDim2.fromScale(0.5, 0.45)
    f.AnchorPoint = Vector2.new(0.5, 0.5); f.BackgroundColor3 = _G.Config.BgColor
    local c = Instance.new("UICorner", f); c.CornerRadius = UDim.new(0, 12)

    -- Robux Info
    local bal = Instance.new("TextLabel", f)
    bal.Text = tostring(_G.Config.FakeBalance):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
    bal.Size = UDim2.fromOffset(100, 20); bal.Position = UDim2.new(1, -130, 0, 15)
    bal.TextColor3 = _G.Config.TextMain; bal.Font = "GothamBold"; bal.BackgroundTransparency = 1; bal.TextXAlignment = "Right"

    -- Item Info
    local img = Instance.new("ImageLabel", f)
    img.Size = UDim2.fromOffset(90, 90); img.Position = UDim2.fromOffset(30, 60); img.Image = fruit.icon
    Instance.new("UICorner", img).CornerRadius = UDim.new(0, 10)

    local txt = Instance.new("TextLabel", f)
    txt.Text = fruit.name; txt.Size = UDim2.fromOffset(200, 30); txt.Position = UDim2.fromOffset(135, 65)
    txt.TextColor3 = _G.Config.TextMain; txt.Font = "GothamBold"; txt.TextXAlignment = "Left"; txt.BackgroundTransparency = 1

    -- Button & Loading
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, -60, 0, 50); btn.Position = UDim2.new(0.5, 0, 1, -85)
    btn.AnchorPoint = Vector2.new(0.5, 0); btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.Text = ""; btn.Active = false; Instance.new("UICorner", btn)

    local fill = Instance.new("Frame", btn)
    fill.Size = UDim2.fromScale(0, 1); fill.BackgroundColor3 = _G.Config.AccentColor
    Instance.new("UICorner", fill)

    local bText = Instance.new("TextLabel", btn)
    bText.Text = "Confirm Purchase"; bText.Size = UDim2.fromScale(1,1); bText.TextColor3 = _G.Config.TextMain
    bText.Font = "GothamBold"; bText.BackgroundTransparency = 1; bText.ZIndex = 2

    local sub = Instance.new("TextLabel", f)
    sub.Text = "Gifting to ["..recipient.."]"; sub.Size = UDim2.new(1,0,0,20); sub.Position = UDim2.new(0,0,1,-25)
    sub.TextColor3 = _G.Config.TextSub; sub.BackgroundTransparency = 1

    local tw = TweenService:Create(fill, TweenInfo.new(3), {Size = UDim2.fromScale(1, 1)})
    tw:Play(); tw.Completed:Connect(function() btn.Active = true end)

    btn.MouseButton1Click:Connect(function()
        if btn.Active then _G.Config.FakeBalance -= fruit.price; sg:Destroy() end
    end)
end
-- ============================================================
-- PART 4: SETTINGS & ICON H
-- ============================================================
local sg = Instance.new("ScreenGui", playerGui); sg.ResetOnSpawn = false
local icon = Instance.new("TextButton", sg)
icon.Size = UDim2.fromOffset(50, 50); icon.Position = UDim2.new(0, 20, 0.5, 0)
icon.BackgroundColor3 = Color3.fromRGB(20, 20, 25); icon.Text = "H"; icon.TextColor3 = Color3.fromRGB(255, 30, 30)
icon.Font = "GothamBlack"; icon.TextSize = 25; Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 100)

local p = Instance.new("Frame", sg)
p.Size = UDim2.fromOffset(200, 130); p.Position = UDim2.fromOffset(80, 250)
p.BackgroundColor3 = _G.Config.BgColor; p.Visible = false; Instance.new("UICorner", p)

local box = Instance.new("TextBox", p)
box.Size = UDim2.new(1, -30, 0, 35); box.Position = UDim2.fromOffset(15, 40)
box.BackgroundColor3 = Color3.fromRGB(15, 15, 20); box.Text = tostring(_G.Config.FakeBalance)
box.TextColor3 = _G.Config.TextMain; Instance.new("UICorner", box)

local apply = Instance.new("TextButton", p)
apply.Size = UDim2.new(1, -30, 0, 35); apply.Position = UDim2.fromOffset(15, 85)
apply.BackgroundColor3 = Color3.fromRGB(255, 30, 30); apply.Text = "Apply"; Instance.new("UICorner", apply)

apply.MouseButton1Click:Connect(function()
    _G.Config.FakeBalance = tonumber(box.Text:gsub("%D", "")) or 0
    apply.Text = "Applied!"; task.wait(1); apply.Text = "Apply"
end)

icon.MouseButton1Click:Connect(function() p.Visible = not p.Visible end)

-- Kéo thả Icon
local drag = false; local start; local pos
icon.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; start = i.Position; pos = icon.Position end end)
UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then 
    local d = i.Position - start
    icon.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
end end)
icon.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
-- ============================================================
-- PART 5: SUCCESS NOTIFICATIONS (TOAST SYSTEM)
-- ============================================================

local function showGiftNotification(fruitName, recipient)
    local notificationGui = Instance.new("ScreenGui", playerGui)
    notificationGui.Name = "HazeHub_Notification"
    notificationGui.DisplayOrder = 2000

    -- Khung thông báo chính
    local toast = Instance.new("Frame", notificationGui)
    toast.Size = UDim2.fromOffset(400, 55)
    toast.Position = UDim2.new(0.5, 0, 0, -70) -- Bắt đầu từ ngoài màn hình (phía trên)
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    toast.BorderSizePixel = 0
    
    local c = Instance.new("UICorner", toast)
    c.CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", toast)
    stroke.Color = Color3.fromRGB(0, 255, 120) -- Màu xanh lá báo hiệu thành công
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Icon quà tặng
    local giftIcon = Instance.new("TextLabel", toast)
    giftIcon.Text = "🎁"
    giftIcon.Size = UDim2.fromOffset(50, 50)
    giftIcon.Position = UDim2.fromOffset(5, 2)
    giftIcon.BackgroundTransparency = 1
    giftIcon.TextSize = 25

    -- Nội dung văn bản
    local msg = Instance.new("TextLabel", toast)
    msg.Size = UDim2.new(1, -60, 1, 0)
    msg.Position = UDim2.fromOffset(55, 0)
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.GothamMedium
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.TextSize = 14
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.RichText = true
    msg.Text = "Đã gửi tặng <font color='rgb(0, 255, 150)'>" .. fruitName .. "</font> cho <b>" .. recipient .. "</b> thành công!"

    -- Hiệu ứng Tween (Trượt xuống rồi biến mất)
    local openTween = TweenService:Create(toast, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, 0, 0, 30)})
    local closeTween = TweenService:Create(toast, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, 0, 0, -80)})

    openTween:Play()
    
    -- Âm thanh thông báo (Tùy chọn)
    local sound = Instance.new("Sound", game.Workspace)
    sound.SoundId = "rbxassetid://1544485084" -- Tiếng 'ding' nhẹ
    sound:Play()

    task.delay(4, function()
        closeTween:Play()
        closeTween.Completed:Wait()
        notificationGui:Destroy()
        sound:Destroy()
    end)
end

-- Kết nối logic: Cập nhật lại hàm bấm nút ở Phần 3 để gọi hàm thông báo này
-- (Đảm bảo trong hàm MouseButton1Click ở Phần 3 có dòng: showGiftNotification(fruit.name, recipient))

print("[HazeHub] Part 5 (Notifications) Loaded. Full System Complete!")
