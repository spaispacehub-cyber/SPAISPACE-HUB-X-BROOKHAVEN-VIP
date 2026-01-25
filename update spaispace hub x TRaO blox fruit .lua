if (game:GetService("CoreGui")):FindFirstChild("RTaO") and (game:GetService("CoreGui")):FindFirstChild("ScreenGui") then
	(game:GetService("CoreGui")).RTaO:Destroy();
	(game:GetService("CoreGui")).ScreenGui:Destroy();
end;
_G.Primary = Color3.fromRGB(100, 100, 100);
_G.Dark = Color3.fromRGB(22, 22, 26);
_G.Third = Color3.fromRGB(255, 0, 0);
function CreateRounded(Parent, Size)
	local Rounded = Instance.new("UICorner");
	Rounded.Name = "Rounded";
	Rounded.Parent = Parent;
	Rounded.CornerRadius = UDim.new(0, Size);
end;
local UserInputService = game:GetService("UserInputService");
local TweenService = game:GetService("TweenService");
function MakeDraggable(topbarobject, object)
	local Dragging = nil;
	local DragInput = nil;
	local DragStart = nil;
	local StartPosition = nil;
	local function Update(input)
		local Delta = input.Position - DragStart;
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y);
		local Tween = TweenService:Create(object, TweenInfo.new(0.15), {
			Position = pos
		});
		Tween:Play();
	end;
	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true;
			DragStart = input.Position;
			StartPosition = object.Position;
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false;
				end;
			end);
		end;
	end);
	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input;
		end;
	end);
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input);
		end;
	end);
end;
local ScreenGui = Instance.new("ScreenGui");
ScreenGui.Parent = game.CoreGui;
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
local OutlineButton = Instance.new("Frame");
OutlineButton.Name = "OutlineButton";
OutlineButton.Parent = ScreenGui;
OutlineButton.ClipsDescendants = true;
OutlineButton.BackgroundColor3 = _G.Dark;
OutlineButton.BackgroundTransparency = 0;
OutlineButton.Position = UDim2.new(0, 10, 0, 15);
OutlineButton.Size = UDim2.new(0, 50, 0, 50);
CreateRounded(OutlineButton, 12);
local ImageButton = Instance.new("ImageButton");
ImageButton.Parent = OutlineButton;
ImageButton.Position = UDim2.new(0.5, 0, 0.5, 0);
ImageButton.Size = UDim2.new(0, 40, 0, 40);
ImageButton.AnchorPoint = Vector2.new(0.5, 0.5);
ImageButton.BackgroundColor3 = _G.Dark;
ImageButton.ImageColor3 = Color3.fromRGB(250, 250, 250);
ImageButton.ImageTransparency = 0;
ImageButton.BackgroundTransparency = 0;
ImageButton.Image = "rbxassetid://13940080072";
ImageButton.AutoButtonColor = false;
MakeDraggable(ImageButton, OutlineButton);
CreateRounded(ImageButton, 10);
ImageButton.MouseButton1Click:connect(function()
	(game.CoreGui:FindFirstChild("RTaO")).Enabled = not (game.CoreGui:FindFirstChild("RTaO")).Enabled;
end);
local NotificationFrame = Instance.new("ScreenGui");
NotificationFrame.Name = "NotificationFrame";
NotificationFrame.Parent = game.CoreGui;
NotificationFrame.ZIndexBehavior = Enum.ZIndexBehavior.Global;
local NotificationList = {};
local function RemoveOldestNotification()
	if #NotificationList > 0 then
		local removed = table.remove(NotificationList, 1);
		removed[1]:TweenPosition(UDim2.new(0.5, 0, -0.2, 0), "Out", "Quad", 0.4, true, function()
			removed[1]:Destroy();
		end);
	end;
end;
spawn(function()
	while wait() do
		if #NotificationList > 0 then
			wait(2);
			RemoveOldestNotification();
		end;
	end;
end);
local Update = {};
function Update:Notify(desc)
	local Frame = Instance.new("Frame");
	local Image = Instance.new("ImageLabel");
	local Title = Instance.new("TextLabel");
	local Desc = Instance.new("TextLabel");
	local OutlineFrame = Instance.new("Frame");
	OutlineFrame.Name = "OutlineFrame";
	OutlineFrame.Parent = NotificationFrame;
	OutlineFrame.ClipsDescendants = true;
	OutlineFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
	OutlineFrame.AnchorPoint = Vector2.new(0.5, 1);
	OutlineFrame.BackgroundTransparency = 0.4;
	OutlineFrame.Position = UDim2.new(0.5, 0, -0.2, 0);
	OutlineFrame.Size = UDim2.new(0, 412, 0, 72);
	Frame.Name = "Frame";
	Frame.Parent = OutlineFrame;
	Frame.ClipsDescendants = true;
	Frame.AnchorPoint = Vector2.new(0.5, 0.5);
	Frame.BackgroundColor3 = _G.Dark;
	Frame.BackgroundTransparency = 0.1;
	Frame.Position = UDim2.new(0.5, 0, 0.5, 0);
	Frame.Size = UDim2.new(0, 400, 0, 60);
	Image.Name = "Icon";
	Image.Parent = Frame;
	Image.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	Image.BackgroundTransparency = 1;
	Image.Position = UDim2.new(0, 8, 0, 8);
	Image.Size = UDim2.new(0, 45, 0, 45);
	Image.Image = "rbxassetid://92582199877885";
	Title.Parent = Frame;
	Title.BackgroundColor3 = _G.Primary;
	Title.BackgroundTransparency = 1;
	Title.Position = UDim2.new(0, 55, 0, 14);
	Title.Size = UDim2.new(0, 10, 0, 20);
	Title.Font = Enum.Font.GothamBold;
	Title.Text = "RTaO";
	Title.TextColor3 = Color3.fromRGB(255, 255, 255);
	Title.TextSize = 16;
	Title.TextXAlignment = Enum.TextXAlignment.Left;
	Desc.Parent = Frame;
	Desc.BackgroundColor3 = _G.Primary;
	Desc.BackgroundTransparency = 1;
	Desc.Position = UDim2.new(0, 55, 0, 33);
	Desc.Size = UDim2.new(0, 10, 0, 10);
	Desc.Font = Enum.Font.GothamSemibold;
	Desc.TextTransparency = 0.3;
	Desc.Text = desc;
	Desc.TextColor3 = Color3.fromRGB(200, 200, 200);
	Desc.TextSize = 12;
	Desc.TextXAlignment = Enum.TextXAlignment.Left;
	CreateRounded(Frame, 10);
	CreateRounded(OutlineFrame, 12);
	OutlineFrame:TweenPosition(UDim2.new(0.5, 0, 0.1 + (#NotificationList) * 0.1, 0), "Out", "Quad", 0.4, true);
	table.insert(NotificationList, {
		OutlineFrame,
		title
	});
end;
function Update:StartLoad()
	local Loader = Instance.new("ScreenGui");
	Loader.Parent = game.CoreGui;
	Loader.ZIndexBehavior = Enum.ZIndexBehavior.Global;
	Loader.DisplayOrder = 1000;
	local LoaderFrame = Instance.new("Frame");
	LoaderFrame.Name = "LoaderFrame";
	LoaderFrame.Parent = Loader;
	LoaderFrame.ClipsDescendants = true;
	LoaderFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5);
	LoaderFrame.BackgroundTransparency = 0;
	LoaderFrame.AnchorPoint = Vector2.new(0.5, 0.5);
	LoaderFrame.Position = UDim2.new(0.5, 0, 0.5, 0);
	LoaderFrame.Size = UDim2.new(1.5, 0, 1.5, 0);
	LoaderFrame.BorderSizePixel = 0;
	local MainLoaderFrame = Instance.new("Frame");
	MainLoaderFrame.Name = "MainLoaderFrame";
	MainLoaderFrame.Parent = LoaderFrame;
	MainLoaderFrame.ClipsDescendants = true;
	MainLoaderFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5);
	MainLoaderFrame.BackgroundTransparency = 0;
	MainLoaderFrame.AnchorPoint = Vector2.new(0.5, 0.5);
	MainLoaderFrame.Position = UDim2.new(0.5, 0, 0.5, 0);
	MainLoaderFrame.Size = UDim2.new(0.5, 0, 0.5, 0);
	MainLoaderFrame.BorderSizePixel = 0;
	local TitleLoader = Instance.new("TextLabel");
	TitleLoader.Parent = MainLoaderFrame;
	TitleLoader.Text = "RTaO Dev";
	TitleLoader.Font = Enum.Font.FredokaOne;
	TitleLoader.TextSize = 50;
	TitleLoader.TextColor3 = Color3.fromRGB(255, 255, 255);
	TitleLoader.BackgroundTransparency = 1;
	TitleLoader.AnchorPoint = Vector2.new(0.5, 0.5);
	TitleLoader.Position = UDim2.new(0.5, 0, 0.3, 0);
	TitleLoader.Size = UDim2.new(0.8, 0, 0.2, 0);
	TitleLoader.TextTransparency = 0;
	local DescriptionLoader = Instance.new("TextLabel");
	DescriptionLoader.Parent = MainLoaderFrame;
	DescriptionLoader.Text = "Loading..";
	DescriptionLoader.Font = Enum.Font.Gotham;
	DescriptionLoader.TextSize = 15;
	DescriptionLoader.TextColor3 = Color3.fromRGB(255, 255, 255);
	DescriptionLoader.BackgroundTransparency = 1;
	DescriptionLoader.AnchorPoint = Vector2.new(0.5, 0.5);
	DescriptionLoader.Position = UDim2.new(0.5, 0, 0.6, 0);
	DescriptionLoader.Size = UDim2.new(0.8, 0, 0.2, 0);
	DescriptionLoader.TextTransparency = 0;
	local LoadingBarBackground = Instance.new("Frame");
	LoadingBarBackground.Parent = MainLoaderFrame;
	LoadingBarBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50);
	LoadingBarBackground.AnchorPoint = Vector2.new(0.5, 0.5);
	LoadingBarBackground.Position = UDim2.new(0.5, 0, 0.7, 0);
	LoadingBarBackground.Size = UDim2.new(0.7, 0, 0.05, 0);
	LoadingBarBackground.ClipsDescendants = true;
	LoadingBarBackground.BorderSizePixel = 0;
	LoadingBarBackground.ZIndex = 2;
	local LoadingBar = Instance.new("Frame");
	LoadingBar.Parent = LoadingBarBackground;
	LoadingBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0);
	LoadingBar.Size = UDim2.new(0, 0, 1, 0);
	LoadingBar.ZIndex = 3;
	CreateRounded(LoadingBarBackground, 20);
	CreateRounded(LoadingBar, 20);
	local tweenService = game:GetService("TweenService");
	local dotCount = 0;
	local running = true;
	local barTweenInfoPart1 = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
	local barTweenPart1 = tweenService:Create(LoadingBar, barTweenInfoPart1, {
		Size = UDim2.new(0.25, 0, 1, 0)
	});
	local barTweenInfoPart2 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
	local barTweenPart2 = tweenService:Create(LoadingBar, barTweenInfoPart2, {
		Size = UDim2.new(1, 0, 1, 0)
	});
	barTweenPart1:Play();
	function Update:Loaded()
		barTweenPart2:Play();
	end;
	barTweenPart1.Completed:Connect(function()
		running = true;
		barTweenPart2.Completed:Connect(function()
			wait(1);
			running = false;
			DescriptionLoader.Text = "Loaded!";
			wait(0.5);
			Loader:Destroy();
		end);
	end);
	spawn(function()
		while running do
			dotCount = (dotCount + 1) % 4;
			local dots = string.rep(".", dotCount);
			DescriptionLoader.Text = "Please wait" .. dots;
			wait(0.5);
		end;
	end);
end;
local SettingsLib = {
	SaveSettings = true,
	LoadAnimation = true
};
(getgenv()).LoadConfig = function()
	if readfile and writefile and isfile and isfolder then
		if not isfolder("RTaO") then
			makefolder("RTaO");
		end;
		if not isfolder("RTaO/Library/") then
			makefolder("RTaO/Library/");
		end;
		if not isfile(("RTaO/Library/" .. game.Players.LocalPlayer.Name .. ".json")) then
			writefile("RTaO/Library/" .. game.Players.LocalPlayer.Name .. ".json", (game:GetService("HttpService")):JSONEncode(SettingsLib));
		else
			local Decode = (game:GetService("HttpService")):JSONDecode(readfile("RTaO/Library/" .. game.Players.LocalPlayer.Name .. ".json"));
			for i, v in pairs(Decode) do
				SettingsLib[i] = v;
			end;
		end;
		print("Library Loaded!");
	else
		return warn("Status : Undetected Executor");
	end;
end;
(getgenv()).SaveConfig = function()
	if readfile and writefile and isfile and isfolder then
		if not isfile(("RTaO/Library/" .. game.Players.LocalPlayer.Name .. ".json")) then
			(getgenv()).Load();
		else
			local Decode = (game:GetService("HttpService")):JSONDecode(readfile("RTaO/Library/" .. game.Players.LocalPlayer.Name .. ".json"));
			local Array = {};
			for i, v in pairs(SettingsLib) do
				Array[i] = v;
			end;
			writefile("RTaO/Library/" .. game.Players.LocalPlayer.Name .. ".json", (game:GetService("HttpService")):JSONEncode(Array));
		end;
	else
		return warn("Status : Undetected Executor");
	end;
end;
(getgenv()).LoadConfig();
function Update:SaveSettings()
	if SettingsLib.SaveSettings then
		return true;
	end;
	return false;
end;
function Update:LoadAnimation()
	if SettingsLib.LoadAnimation then
		return true;
	end;
	return false;
end;
function Update:Window(Config)
	assert(Config.SubTitle, "v4");
	local WindowConfig = {
		Size = Config.Size,
		TabWidth = Config.TabWidth
	};
	local osfunc = {};
	local uihide = false;
	local abc = false;
	local currentpage = "";
	local keybind = keybind or Enum.KeyCode.RightControl;
	local yoo = string.gsub(tostring(keybind), "Enum.KeyCode.", "");
	local RTaO = Instance.new("ScreenGui");
	RTaO.Name = "SPAISPACE X RTaO";
	RTaO.Parent = game.CoreGui;
	RTaO.DisplayOrder = 999;
	local OutlineMain = Instance.new("Frame");
	OutlineMain.Name = "OutlineMain";
	OutlineMain.Parent = RTaO;
	OutlineMain.ClipsDescendants = true;
	OutlineMain.AnchorPoint = Vector2.new(0.5, 0.5);
	OutlineMain.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
	OutlineMain.BackgroundTransparency = 0.4;
	OutlineMain.Position = UDim2.new(0.5, 0, 0.45, 0);
	OutlineMain.Size = UDim2.new(0, 0, 0, 0);
	CreateRounded(OutlineMain, 15);
	local Main = Instance.new("Frame");
	Main.Name = "Main";
	Main.Parent = OutlineMain;
	Main.ClipsDescendants = true;
	Main.AnchorPoint = Vector2.new(0.5, 0.5);
	Main.BackgroundColor3 = Color3.fromRGB(24, 24, 26);
	Main.BackgroundTransparency = 0;
	Main.Position = UDim2.new(0.5, 0, 0.5, 0);
	Main.Size = WindowConfig.Size;
	OutlineMain:TweenSize(UDim2.new(0, WindowConfig.Size.X.Offset + 15, 0, WindowConfig.Size.Y.Offset + 15), "Out", "Quad", 0.4, true);
	CreateRounded(Main, 12);
	local BtnStroke = Instance.new("UIStroke");
	local DragButton = Instance.new("Frame");
	DragButton.Name = "DragButton";
	DragButton.Parent = Main;
	DragButton.Position = UDim2.new(1, 5, 1, 5);
	DragButton.AnchorPoint = Vector2.new(1, 1);
	DragButton.Size = UDim2.new(0, 15, 0, 15);
	DragButton.BackgroundColor3 = _G.Primary;
	DragButton.BackgroundTransparency = 1;
	DragButton.ZIndex = 10;
	local mouse = game.Players.LocalPlayer:GetMouse();
	local uis = game:GetService("UserInputService");
	local CircleDragButton = Instance.new("UICorner");
	CircleDragButton.Name = "CircleDragButton";
	CircleDragButton.Parent = DragButton;
	CircleDragButton.CornerRadius = UDim.new(0, 99);
	local Top = Instance.new("Frame");
	Top.Name = "Top";
	Top.Parent = Main;
	Top.BackgroundColor3 = Color3.fromRGB(10, 10, 10);
	Top.Size = UDim2.new(1, 0, 0, 40);
	Top.BackgroundTransparency = 1;
	CreateRounded(Top, 5);
	local NameHub = Instance.new("TextLabel");
	NameHub.Name = "NameHub";
	NameHub.Parent = Top;
	NameHub.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	NameHub.BackgroundTransparency = 1;
	NameHub.RichText = true;
	NameHub.Position = UDim2.new(0, 15, 0.5, 0);
	NameHub.AnchorPoint = Vector2.new(0, 0.5);
	NameHub.Size = UDim2.new(0, 1, 0, 25);
	NameHub.Font = Enum.Font.GothamBold;
	NameHub.Text = "SPAISPACE X RTaO";
	NameHub.TextSize = 20;
	NameHub.TextColor3 = Color3.fromRGB(255, 255, 255);
	NameHub.TextXAlignment = Enum.TextXAlignment.Left;
	local nameHubSize = (game:GetService("TextService")):GetTextSize(NameHub.Text, NameHub.TextSize, NameHub.Font, Vector2.new(math.huge, math.huge));
	NameHub.Size = UDim2.new(0, nameHubSize.X, 0, 25);
	local SubTitle = Instance.new("TextLabel");
	SubTitle.Name = "SubTitle";
	SubTitle.Parent = NameHub;
	SubTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	SubTitle.BackgroundTransparency = 1;
	SubTitle.Position = UDim2.new(0, nameHubSize.X + 8, 0.5, 0);
	SubTitle.Size = UDim2.new(0, 1, 0, 20);
	SubTitle.Font = Enum.Font.Cartoon;
	SubTitle.AnchorPoint = Vector2.new(0, 0.5);
	SubTitle.Text = Config.SubTitle;
	SubTitle.TextSize = 15;
	SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150);
	local SubTitleSize = (game:GetService("TextService")):GetTextSize(SubTitle.Text, SubTitle.TextSize, SubTitle.Font, Vector2.new(math.huge, math.huge));
	SubTitle.Size = UDim2.new(0, SubTitleSize.X, 0, 25);
	local CloseButton = Instance.new("ImageButton");
	CloseButton.Name = "CloseButton";
	CloseButton.Parent = Top;
	CloseButton.BackgroundColor3 = _G.Primary;
	CloseButton.BackgroundTransparency = 1;
	CloseButton.AnchorPoint = Vector2.new(1, 0.5);
	CloseButton.Position = UDim2.new(1, -15, 0.5, 0);
	CloseButton.Size = UDim2.new(0, 20, 0, 20);
	CloseButton.Image = "rbxassetid://7743878857";
	CloseButton.ImageTransparency = 0;
	CloseButton.ImageColor3 = Color3.fromRGB(245, 245, 245);
	CreateRounded(CloseButton, 3);
	CloseButton.MouseButton1Click:connect(function()
		(game.CoreGui:FindFirstChild("RTaO")).Enabled = not (game.CoreGui:FindFirstChild("RTaO")).Enabled;
	end);
	local ResizeButton = Instance.new("ImageButton");
	ResizeButton.Name = "ResizeButton";
	ResizeButton.Parent = Top;
	ResizeButton.BackgroundColor3 = _G.Primary;
	ResizeButton.BackgroundTransparency = 1;
	ResizeButton.AnchorPoint = Vector2.new(1, 0.5);
	ResizeButton.Position = UDim2.new(1, -50, 0.5, 0);
	ResizeButton.Size = UDim2.new(0, 20, 0, 20);
	ResizeButton.Image = "rbxassetid://10734886735";
	ResizeButton.ImageTransparency = 0;
	ResizeButton.ImageColor3 = Color3.fromRGB(245, 245, 245);
	CreateRounded(ResizeButton, 3);
	local BackgroundSettings = Instance.new("Frame");
	BackgroundSettings.Name = "BackgroundSettings";
	BackgroundSettings.Parent = OutlineMain;
	BackgroundSettings.ClipsDescendants = true;
	BackgroundSettings.Active = true;
	BackgroundSettings.AnchorPoint = Vector2.new(0, 0);
	BackgroundSettings.BackgroundColor3 = Color3.fromRGB(10, 10, 10);
	BackgroundSettings.BackgroundTransparency = 0.3;
	BackgroundSettings.Position = UDim2.new(0, 0, 0, 0);
	BackgroundSettings.Size = UDim2.new(1, 0, 1, 0);
	BackgroundSettings.Visible = false;
	CreateRounded(BackgroundSettings, 15);
	local SettingsFrame = Instance.new("Frame");
	SettingsFrame.Name = "SettingsFrame";
	SettingsFrame.Parent = BackgroundSettings;
	SettingsFrame.ClipsDescendants = true;
	SettingsFrame.AnchorPoint = Vector2.new(0.5, 0.5);
	SettingsFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 26);
	SettingsFrame.BackgroundTransparency = 0;
	SettingsFrame.Position = UDim2.new(0.5, 0, 0.5, 0);
	SettingsFrame.Size = UDim2.new(0.7, 0, 0.7, 0);
	CreateRounded(SettingsFrame, 15);
	local CloseSettings = Instance.new("ImageButton");
	CloseSettings.Name = "CloseSettings";
	CloseSettings.Parent = SettingsFrame;
	CloseSettings.BackgroundColor3 = _G.Primary;
	CloseSettings.BackgroundTransparency = 1;
	CloseSettings.AnchorPoint = Vector2.new(1, 0);
	CloseSettings.Position = UDim2.new(1, -20, 0, 15);
	CloseSettings.Size = UDim2.new(0, 20, 0, 20);
	CloseSettings.Image = "rbxassetid://10747384394";
	CloseSettings.ImageTransparency = 0;
	CloseSettings.ImageColor3 = Color3.fromRGB(245, 245, 245);
	CreateRounded(CloseSettings, 3);
	CloseSettings.MouseButton1Click:connect(function()
		BackgroundSettings.Visible = false;
	end);
	local SettingsButton = Instance.new("ImageButton");
	SettingsButton.Name = "SettingsButton";
	SettingsButton.Parent = Top;
	SettingsButton.BackgroundColor3 = _G.Primary;
	SettingsButton.BackgroundTransparency = 1;
	SettingsButton.AnchorPoint = Vector2.new(1, 0.5);
	SettingsButton.Position = UDim2.new(1, -85, 0.5, 0);
	SettingsButton.Size = UDim2.new(0, 20, 0, 20);
	SettingsButton.Image = "rbxassetid://10734950020";
	SettingsButton.ImageTransparency = 0;
	SettingsButton.ImageColor3 = Color3.fromRGB(245, 245, 245);
	CreateRounded(SettingsButton, 3);
	SettingsButton.MouseButton1Click:connect(function()
		BackgroundSettings.Visible = true;
	end);
	local TitleSettings = Instance.new("TextLabel");
	TitleSettings.Name = "TitleSettings";
	TitleSettings.Parent = SettingsFrame;
	TitleSettings.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	TitleSettings.BackgroundTransparency = 1;
	TitleSettings.Position = UDim2.new(0, 20, 0, 15);
	TitleSettings.Size = UDim2.new(1, 0, 0, 20);
	TitleSettings.Font = Enum.Font.GothamBold;
	TitleSettings.AnchorPoint = Vector2.new(0, 0);
	TitleSettings.Text = "Library Settings";
	TitleSettings.TextSize = 20;
	TitleSettings.TextColor3 = Color3.fromRGB(245, 245, 245);
	TitleSettings.TextXAlignment = Enum.TextXAlignment.Left;
	local SettingsMenuList = Instance.new("Frame");
	SettingsMenuList.Name = "SettingsMenuList";
	SettingsMenuList.Parent = SettingsFrame;
	SettingsMenuList.ClipsDescendants = true;
	SettingsMenuList.AnchorPoint = Vector2.new(0, 0);
	SettingsMenuList.BackgroundColor3 = Color3.fromRGB(24, 24, 26);
	SettingsMenuList.BackgroundTransparency = 1;
	SettingsMenuList.Position = UDim2.new(0, 0, 0, 50);
	SettingsMenuList.Size = UDim2.new(1, 0, 1, -70);
	CreateRounded(SettingsMenuList, 15);
	local ScrollSettings = Instance.new("ScrollingFrame");
	ScrollSettings.Name = "ScrollSettings";
	ScrollSettings.Parent = SettingsMenuList;
	ScrollSettings.Active = true;
	ScrollSettings.BackgroundColor3 = Color3.fromRGB(10, 10, 10);
	ScrollSettings.Posi