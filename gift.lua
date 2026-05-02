-- // ========================================================== //
-- //   PROJECT: SPAISPACE HUB V12 - FIXED & COMPLETED
-- //   ARCHITECT: Huy Vuong | SYSTEM: SHΔDØW CORE
-- // ========================================================== //

local Config = {
    Key = "test_2hours",
    -- Hết hạn lúc 24:59 ngày 02/05/2026
    Expiry = os.time({
        year = 2026, 
        month = 5, 
        day = 2, 
        hour = 24, 
        min = 59, 
        sec = 0
    })
}

repeat wait() until game:IsLoaded()

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Xóa bản cũ nếu đang chạy để tránh chồng chéo
if CoreGui:FindFirstChild("SpaiSpaceHuyVuong") then 
    CoreGui.SpaiSpaceHuyVuong:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "SpaiSpaceHuyVuong"
ScreenGui.IgnoreGuiInset = true

-- // GIAO DIỆN CHÍNH //
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
MainFrame.ClipsDescendants = true -- Quan trọng để trượt menu
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0, 255, 255)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.Text = "SPAISPACE HUB | BY HUY VUONG"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextSize = 18

-- // KHUNG NHẬP KEY (Giao diện ban đầu) //
local KeyGroup = Instance.new("Frame", MainFrame)
KeyGroup.Size = UDim2.new(1, 0, 1, -50)
KeyGroup.Position = UDim2.new(0, 0, 0, 50)
KeyGroup.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox", KeyGroup)
KeyInput.Size = UDim2.new(0, 280, 0, 45)
KeyInput.Position = UDim2.new(0.5, -140, 0, 20)
KeyInput.PlaceholderText = "Nhập Key (test_2hours)"
KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Text = "" -- Để trống ban đầu
Instance.new("UICorner", KeyInput)

local VerifyBtn = Instance.new("TextButton", KeyGroup)
VerifyBtn.Size = UDim2.new(0, 280, 0, 45)
VerifyBtn.Position = UDim2.new(0.5, -140, 0, 80)
VerifyBtn.Text = "XÁC MINH KEY"
VerifyBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", VerifyBtn)

-- // KHUNG HUB CHÍNH (Giao diện sau khi nhập đúng key) //
local HubFrame = Instance.new("Frame", MainFrame)
HubFrame.Size = UDim2.new(1, 0, 1, -50)
HubFrame.Position = UDim2.new(1.2, 0, 0, 50) -- Đặt ở ngoài màn hình để trượt vào
HubFrame.BackgroundTransparency = 1

local RobuxInput = Instance.new("TextBox", HubFrame)
RobuxInput.Size = UDim2.new(0, 240, 0, 40)
RobuxInput.Position = UDim2.new(0.5, -120, 0, 20)
RobuxInput.Text = "100000"
RobuxInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
RobuxInput.TextColor3 = Color3.fromRGB(0, 255, 127)
Instance.new("UICorner", RobuxInput)

local ExecBtn = Instance.new("TextButton", HubFrame)
ExecBtn.Size = UDim2.new(0, 240, 0, 45)
ExecBtn.Position = UDim2.new(0.5, -120, 0, 75)
ExecBtn.Text = "CHẠY FAKE GIFTER"
ExecBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
ExecBtn.Font = Enum.Font.GothamBold
ExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", ExecBtn)

-- // LOGIC XỬ LÝ CHÍNH //
VerifyBtn.MouseButton1Click:Connect(function()
    -- Xóa khoảng trắng dư thừa trong lúc nhập
    local Input = KeyInput.Text:gsub("%s+", "")
    local CurrentTime = os.time()
    
    -- Kiểm tra hết hạn
    if CurrentTime > Config.Expiry then
        VerifyBtn.Text = "KEY HẾT HẠN!"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        return
    end
    
    -- Kiểm tra Key đúng hay sai
    if Input == Config.Key then
        VerifyBtn.Text = "THÀNH CÔNG!"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
        
        task.wait(0.5)
        
        -- Hiệu ứng trượt menu cực mượt
        local TInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
        TweenService:Create(KeyGroup, TInfo, {Position = UDim2.new(-1.2, 0, 0, 50)}):Play()
        TweenService:Create(HubFrame, TInfo, {Position = UDim2.new(0, 0, 0, 50)}):Play()
    else
        VerifyBtn.Text = "SAI KEY! NHẬP LẠI"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1.5)
        VerifyBtn.Text = "XÁC MINH KEY"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end
end)

ExecBtn.MouseButton1Click:Connect(function()
    getgenv().robux = tonumber(RobuxInput.Text) or 100000
    ExecBtn.Text = "ĐANG KÍCH HOẠT..."
    
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/FakeGifterDragon.lua"))()
    end)
    
    task.wait(1)
    ExecBtn.Text = "DONE! ĐÃ CHẠY"
    task.wait(2)
    ExecBtn.Text = "CHẠY FAKE GIFTER"
end)

-- Hiệu ứng kéo khung (Drag) cho điện thoại và máy tính
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
