pcall(function()
local Luna = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true)

)()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LogService = game:GetService("LogService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ClientRuntime = require(ReplicatedStorage.Shared.ClientRuntime)

local function safeBridgeCall(method, ...)
	local results = table.pack(pcall(method, ...))

	return results[1], results[2], results[3]
end

local function callBoolResponse(method, ...)
	local luaOk, success, response = safeBridgeCall(method, ...)

	if not luaOk then return false, false, success end

	return true, success, response
end

local function callValue(method, ...)
	local luaOk, value = safeBridgeCall(method, ...)

	if not luaOk then return nil end

	return value
end

local STUDS_PER_BLOCK = (function()
	local v = callValue(function() return ClientRuntime.StudsPerBlock end)

	return type(v) == "number" and v or 3
end)()

local function snapToGrid(position)
	return Vector3.new(
		math.round(position.X / STUDS_PER_BLOCK) * STUDS_PER_BLOCK,
		math.round(position.Y / STUDS_PER_BLOCK) * STUDS_PER_BLOCK,
		math.round(position.Z / STUDS_PER_BLOCK) * STUDS_PER_BLOCK

	)
end

local State = {
	target = "",
	packets = 0,
	errors = 0,
	lastAck = "none",
	autoAttack = false,
	autoAttackCPS = 10,
	killAura = false,
	killAuraRange = 3,
	killAuraCPS = 10,
	killAuraMulti = false,
	killAuraTeamCheck = false,
	killAuraShowRange = false,
	killAuraNPCs = true,
	killAuraPlayers = true,
	combatReach = callValue(ClientRuntime.GetCombatReach) or 3,
	blockReach = callValue(ClientRuntime.GetBlockReach) or 5,
	aimlock = false,
	aimlockActive = false,
	aimlockKey = Enum.KeyCode.Q,
	aimlockFOV = 250,
	aimlockSmoothing = 1,
	aimlockPart = "Head",
	aimlockTeamCheck = false,
	aimlockShowFOV = false,
	aimlockNPCs = false,
	triggerBot = false,
	triggerBotCPS = 10,
	triggerBotRange = 15,
	criticals = false,
	espEnabled = false,
	espHighlight = true,
	espNames = true,
	espHealth = true,
	espDistance = true,
	espTracers = false,
	espTeamCheck = false,
	espNPCs = false,
	espFillColor = Color3.fromRGB(255, 0, 0),
	espOutlineColor = Color3.fromRGB(255, 255, 255),
	espFillTransparency = 0.75,
	espOutlineTransparency = 0,
	velocityEnabled = false,
	velocityWalkSpeed = 16,
	velocityJumpPower = 50,
	noclip = false,
	fly = false,
	flySpeed = 50,
	infiniteJump = false,
	antiKick = true,
	antiKB = false,
	antiKBPercent = 100,
	stepEnabled = false,
	stepHeight = 3,
	spider = false,
	spiderSpeed = 10,
	longJump = false,
	longJumpBoost = 1.5,
	autoWalk = false,
	nuker = false,
	nukerCPS = 5,
	nukerRange = 1,
	scaffold = false,
	scaffoldCPS = 10,
	scaffoldBlock = "Stone",
	tower = false,
	towerCPS = 5,
	towerBlock = "Stone",
	autoBridge = false,
	autoBridgeCPS = 8,
	autoBridgeBlock = "Stone",
	freecam = false,
	freecamSpeed = 50,
	fullbright = false,
	noFog = false,
	customFOV = false,
	fovValue = 70,
	coordsEnabled = false,
	breadcrumbs = false,
	breadcrumbColor = Color3.fromRGB(255, 255, 0),
	autoRespawn = false,
}

local HIDDEN_CLASSES = {
	BodyVelocity = true, BodyGyro = true, BodyForce = true, BodyPosition = true,
	BodyAngularVelocity = true, BodyThrust = true, LinearVelocity = true,
	AlignOrientation = true, VectorForce = true,
}

local SUPPRESSED_STATES = {
	[Enum.HumanoidStateType.PlatformStanding] = true,
	[Enum.HumanoidStateType.StrafingNoPhysics] = true,
	[Enum.HumanoidStateType.Physics] = true,
}

local HiddenInstances = {}

local StateHookConnections = {}

local espCache = {}

local fovCircle = nil
local flyBodyVelocity = nil
local flyBodyGyro = nil
local currentAimlockTarget = nil
local killAuraThread = nil
local autoAttackThread = nil
local nukerThread = nil
local scaffoldThread = nil
local towerThread = nil
local autoBridgeThread = nil
local triggerBotThread = nil
local killAuraToken = 0
local autoAttackToken = 0
local nukerToken = 0
local scaffoldToken = 0
local towerToken = 0
local autoBridgeToken = 0
local triggerBotToken = 0
local killAuraVisualPart = nil
local statsParagraph
local npcCache = {}

local npcCacheTick = 0
local NPC_CACHE_INTERVAL = 0.5
local espUpdateTick = 0
local ESP_UPDATE_INTERVAL = 0.1
local uiUpdateTick = 0
local UI_UPDATE_INTERVAL = 0.5
local originalCameraType = nil
local originalLighting = {}

local originalFog = {}

local coordsGui = nil
local coordsLabel = nil
local breadcrumbParts = {}

local lastBreadcrumbPos = nil
local BREADCRUMB_SPACING = 2
local blinkPositions = {}

local longJumpApplied = false
local lastConfigSave = 0

local function registerHidden(inst) if inst then HiddenInstances[inst] = true end end

local function unregisterHidden(inst) if inst then HiddenInstances[inst] = nil end end

local function isHidden(inst) return HiddenInstances[inst] == true end

local function isOurCharDescendant(inst)
	local char = LocalPlayer and LocalPlayer.Character

	if not char or typeof(inst) ~= "Instance" then return false end

	local s, r = pcall(function() return inst == char or inst:IsDescendantOf(char) end)

	return s and r
end

local function isExternalCaller()
	if typeof(checkcaller) == "function" then return not checkcaller() end

	return false
end

pcall(function()
	if typeof(hookmetamethod) ~= "function" or typeof(getnamecallmethod) ~= "function" then return end

	local oldNamecall

	oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local s, r = pcall(function(...)
			local method = getnamecallmethod()
			local args = {...}

			if method == "Kick" and State.antiKick and self == LocalPlayer then return nil end

			if (method == "FindFirstChildOfClass" or method == "FindFirstChildWhichIsA") and args[1] and HIDDEN_CLASSES[args[1]] and isOurCharDescendant(self) and isExternalCaller() then return nil end
			if (method == "GetChildren" or method == "GetDescendants") and isOurCharDescendant(self) and isExternalCaller() then
				local results = oldNamecall(self, ...)
				local filtered = {}

				for _, v in ipairs(results) do if not isHidden(v) then filtered[#filtered+1] = v end end

				return filtered
			end

			return oldNamecall(self, ...)
		end, ...)

		if s then return r end

		return oldNamecall(self, ...)
	end)
end)

pcall(function()
	if typeof(hookmetamethod) ~= "function" then return end

	local oldIndex

	oldIndex = hookmetamethod(game, "__index", function(self, key)
		local s, r = pcall(function()
			if isExternalCaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and isOurCharDescendant(self) then
				if key == "WalkSpeed" and State.velocityEnabled then return 16 end
				if key == "JumpPower" and State.velocityEnabled then return 50 end
				if key == "JumpHeight" and State.velocityEnabled then return 7.2 end
				if key == "PlatformStand" and State.fly then return false end
			end

			return oldIndex(self, key)
		end)

		if s then return r end

		return oldIndex(self, key)
	end)
end)

pcall(function()
	if typeof(hookmetamethod) ~= "function" then return end

	local oldNewindex

	oldNewindex = hookmetamethod(game, "__newindex", function(self, key, value)
		pcall(function()
			if isExternalCaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and isOurCharDescendant(self) then
				if key == "WalkSpeed" and State.velocityEnabled then oldNewindex(self, key, State.velocityWalkSpeed); return end
				if key == "JumpPower" and State.velocityEnabled then oldNewindex(self, key, State.velocityJumpPower); return end
				if key == "PlatformStand" and State.fly then return end
			end

			oldNewindex(self, key, value)
		end)
	end)
end)

pcall(function()
	if typeof(getconnections) ~= "function" then return end
	for _, c in ipairs(getconnections(LogService.MessageOut)) do pcall(function() c:Disable() end) end

	for _, c in ipairs(getconnections(LocalPlayer.Idled)) do pcall(function() c:Disable() end) end
end)

local function hookCharacterStateChanges(char)
	pcall(function()
		if not char then return end
		for _, c in ipairs(StateHookConnections) do pcall(function() c:Disconnect() end) end
		StateHookConnections = {}

		local humanoid = char:WaitForChild("Humanoid", 5)

		if not humanoid then return end
		StateHookConnections[#StateHookConnections+1] = humanoid.StateChanged:Connect(function(_, newState)
			pcall(function()
				if not State.fly and SUPPRESSED_STATES[newState] then humanoid:ChangeState(Enum.HumanoidStateType.Running) end
			end)
		end)

		local rootPart = char:WaitForChild("HumanoidRootPart", 5)

		if rootPart then
			StateHookConnections[#StateHookConnections+1] = rootPart.ChildAdded:Connect(function(child)
				pcall(function() if HIDDEN_CLASSES[child.ClassName] and not isHidden(child) then child:Destroy() end end)
			end)
		end

		if State.autoRespawn then
			humanoid.Died:Connect(function()
				if State.autoRespawn then task.wait(0.5); pcall(function()
					local remote = ReplicatedStorage:FindFirstChild("Respawn", true)

					if remote and remote:IsA("RemoteEvent") then remote:FireServer() end
					if remote and remote:IsA("RemoteFunction") then remote:InvokeServer() end
				end) end
			end)
		end
	end)
end

pcall(function()
	if LocalPlayer.Character then hookCharacterStateChanges(LocalPlayer.Character) end

	LocalPlayer.CharacterAdded:Connect(function(char) pcall(hookCharacterStateChanges, char) end)
end)

local function notify(title, content)
	pcall(function() Luna:Notification({ Title = title, Content = content }) end)
end

local function updateUi()
	pcall(function()
		if not statsParagraph then return end

		local bridgeOk, bridgeReady = safeBridgeCall(ClientRuntime.IsReady)
		local bridgeStatus = (bridgeOk and bridgeReady == true and "Ready") or (bridgeOk and "Not Ready") or "N/A"

		statsParagraph:Set({
			Title = "Runtime Stats",
			Text = "Target: " .. tostring(State.target)
				.. "\nPackets: " .. tostring(State.packets)
				.. "\nErrors: " .. tostring(State.errors)
				.. "\nLast Ack: " .. tostring(State.lastAck)
				.. "\nBridge: " .. bridgeStatus
				.. "\nKA/TB/AA: " .. (State.killAura and "ON" or "OFF") .. "/" .. (State.triggerBot and "ON" or "OFF") .. "/" .. (State.autoAttack and "ON" or "OFF")
				.. "\nNuker/Scaffold/Tower: " .. (State.nuker and "ON" or "OFF") .. "/" .. (State.scaffold and "ON" or "OFF") .. "/" .. (State.tower and "ON" or "OFF")
				.. "\nReach: " .. tostring(State.combatReach) .. " / " .. tostring(State.blockReach),
		})
	end)
end

local function findTargetPlayer(name)
	if type(name) ~= "string" or name == "" then return nil end

	local low = string.lower(name)

	for _, p in ipairs(Players:GetPlayers()) do if string.lower(p.Name) == low then return p end end

	for _, p in ipairs(Players:GetPlayers()) do if string.sub(string.lower(p.Name), 1, #low) == low then return p end end

	return nil
end

local function getCharacter(player)
	if not player then return nil end

	local char = player.Character

	if not char then return nil end

	local hum = char:FindFirstChildOfClass("Humanoid")

	if not hum or hum.Health <= 0 then return nil end

	return char
end

local function getLocalRoot()
	local char = LocalPlayer.Character

	return char and char:FindFirstChild("HumanoidRootPart")
end

local function getLocalHumanoid()
	local char = LocalPlayer.Character

	return char and char:FindFirstChildOfClass("Humanoid")
end

local function refreshNPCCache()
	local now = os.clock()

	if now - npcCacheTick < NPC_CACHE_INTERVAL then return npcCache end
	npcCacheTick = now

	local list = {}
	local playerChars = {}

	for _, p in ipairs(Players:GetPlayers()) do if p.Character then playerChars[p.Character] = true end end

	local function scanChildren(parent)
		for _, obj in ipairs(parent:GetChildren()) do
			pcall(function()
				if obj:IsA("Model") and not playerChars[obj] then
					local hum = obj:FindFirstChildOfClass("Humanoid")

					if hum and hum.Health > 0 then
						local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")

						if root then list[#list+1] = obj end
					end
				end
			end)
		end
	end

	scanChildren(Workspace)

	for _, folder in ipairs(Workspace:GetChildren()) do
		pcall(function() if folder:IsA("Folder") then scanChildren(folder) end end)
	end

	npcCache = list

	return list
end

local function runtimeAttack(target)
	local luaOk, success, response = callBoolResponse(ClientRuntime.Attack, target)

	if luaOk and success then
		State.packets += 1

		return true, response
	end

	State.errors += 1

	return false, response
end

local breakVisualPool = {}

local MAX_BREAK_VISUALS = 8

local function spawnBreakVisual(position)
	local snapped = snapToGrid(position)

	if #breakVisualPool >= MAX_BREAK_VISUALS then
		local oldest = table.remove(breakVisualPool, 1)

		pcall(function() oldest:Destroy() end)
	end

	local part = Instance.new("Part")

	part.Size = Vector3.new(STUDS_PER_BLOCK, STUDS_PER_BLOCK, STUDS_PER_BLOCK)
	part.Position = snapped
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.6
	part.Material = Enum.Material.ForceField
	part.Color = Color3.fromRGB(255, 60, 60)
	part.CastShadow = false
	part.Parent = Workspace
	breakVisualPool[#breakVisualPool + 1] = part

	task.spawn(function()
		local steps = 10
		local shrinkTime = 0.3
		local startSize = part.Size

		for i = 1, steps do
			if not part or not part.Parent then break end

			local alpha = i / steps

			part.Size = startSize * (1 - alpha * 0.9)
			part.Transparency = 0.6 + alpha * 0.4

			task.wait(shrinkTime / steps)
		end

		pcall(function() part:Destroy() end)

		for idx, pooled in ipairs(breakVisualPool) do
			if pooled == part then table.remove(breakVisualPool, idx); break end
		end
	end)
end

local function runtimeBreakAt(position)
	local payload = { action = "breakBlock" }

	if position then payload.blockPosition = snapToGrid(position) end

	local luaOk, success, response = callBoolResponse(ClientRuntime.Execute, payload)

	if luaOk and success then
		State.packets += 1

		if position then task.spawn(spawnBreakVisual, position) end

		return true, response
	end

	State.errors += 1

	return false, response
end

local function runtimePlaceAt(position, options)
	options = options or {}

	local snapped = snapToGrid(position)
	local payload = {
		action = "placeBlock",
		position = snapped,
		blockType = options.blockType or "Stone",
	}

	if options.hand then payload.hand = options.hand end
	if options.normal then payload.normal = options.normal end
	if options.placementFace then payload.placementFace = options.placementFace end

	local luaOk, success, response = callBoolResponse(ClientRuntime.Execute, payload)

	if luaOk and success then
		State.packets += 1

		return true, response
	end

	State.errors += 1

	return false, response
end

local function runtimePlaceSimple(options)
	options = options or {}

	local payload = {
		action = "placeBlock",
		blockType = options.blockType or "Stone",
	}

	if options.forceOffhand then payload.forceOffhand = true end

	local luaOk, success, response = callBoolResponse(ClientRuntime.Execute, payload)

	if luaOk and success then
		State.packets += 1

		return true, response
	end

	State.errors += 1

	return false, response
end

local function runtimeScaffold(length, options)
	options = options or {}
	length = length or 10

	local blockType = options.blockType or State.scaffoldBlock
	local underFeet = options.underFeet ~= false
	local stepDelay = options.stepDelay or 0.03
	local root = getLocalRoot()

	if not root then return false, 0 end

	local lookFlat = root.CFrame.LookVector * Vector3.new(1, 0, 1)

	if lookFlat.Magnitude < 0.01 then lookFlat = Vector3.new(1, 0, 0) else lookFlat = lookFlat.Unit end

	local yOffset = underFeet and -STUDS_PER_BLOCK or 0
	local startPos = root.Position + Vector3.new(0, yOffset, 0)
	local placed = 0

	for i = 0, length - 1 do
		local targetPos = startPos + lookFlat * (i * STUDS_PER_BLOCK)
		local ok = runtimePlaceAt(targetPos, { blockType = blockType })

		if ok then placed += 1 end
		if stepDelay > 0 and i < length - 1 then task.wait(stepDelay) end
	end

	return true, placed
end

local function attackTarget(target, sourceTag)
	if State.criticals then
		pcall(function()
			local hum = getLocalHumanoid()

			if hum and hum.FloorMaterial ~= Enum.Material.Air then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)

				task.wait(0.08)
			end
		end)
	end

	local ok, response = runtimeAttack(target)

	if ok then
		pcall(function()
			if typeof(target) == "Instance" then
				State.lastAck = (sourceTag or "atk") .. ":" .. target.Name
			else
				State.lastAck = (sourceTag or "atk") .. ":sent"
			end
		end)

		return true
	end

	State.lastAck = (sourceTag or "atk") .. ":err:" .. tostring(response or "")

	return false
end

local function attackByName(sourceTag)
	local tp = findTargetPlayer(State.target)

	if not tp then State.errors += 1; State.lastAck = "invalid_target"; return false end

	return attackTarget(tp, sourceTag or "manual")
end

local function doBreakBlock(sourceTag, position)
	local ok, response = runtimeBreakAt(position)

	if ok then State.lastAck = (sourceTag or "break") .. ":ok"; return true end
	State.lastAck = (sourceTag or "break") .. ":err:" .. tostring(response or "")

	return false
end

local function doPlaceBlock(sourceTag, position, options)
	if position then
		local ok, response = runtimePlaceAt(position, options)

		if ok then State.lastAck = (sourceTag or "place") .. ":ok"; return true end
		State.lastAck = (sourceTag or "place") .. ":err:" .. tostring(response or "")

		return false
	end

	local ok, response = runtimePlaceSimple(options or {})

	if ok then State.lastAck = (sourceTag or "place") .. ":ok"; return true end
	State.lastAck = (sourceTag or "place") .. ":err:" .. tostring(response or "")

	return false
end

local function applyReach()
	local ok1, s1 = callBoolResponse(ClientRuntime.SetCombatReach, State.combatReach)

	if ok1 and s1 then State.packets += 1 else State.errors += 1 end

	local ok2, s2 = callBoolResponse(ClientRuntime.SetBlockReach, State.blockReach)

	if ok2 and s2 then State.packets += 1 else State.errors += 1 end
	State.lastAck = "reach:" .. tostring(State.combatReach) .. "/" .. tostring(State.blockReach)

	pcall(updateUi)
	notify("Reach", "Applied combat=" .. tostring(State.combatReach) .. " block=" .. tostring(State.blockReach))
end

local function resetReach()
	local ok1, s1 = callBoolResponse(ClientRuntime.ResetCombatReach)

	if ok1 and s1 then State.packets += 1 else State.errors += 1 end

	local ok2, s2 = callBoolResponse(ClientRuntime.ResetBlockReach)

	if ok2 and s2 then State.packets += 1 else State.errors += 1 end
	State.combatReach = callValue(ClientRuntime.GetCombatReach) or 3
	State.blockReach = callValue(ClientRuntime.GetBlockReach) or 5
	State.lastAck = "reach_reset"; pcall(updateUi); notify("Reach", "Reset to defaults")
end

local function syncReach()
	local cr = callValue(ClientRuntime.GetCombatReach)
	local br = callValue(ClientRuntime.GetBlockReach)

	if type(cr) == "number" then State.combatReach = cr end
	if type(br) == "number" then State.blockReach = br end
	State.lastAck = "reach_synced"; pcall(updateUi)
end

local function getKillAuraTargets()
	local localRoot = getLocalRoot()

	if not localRoot then return {} end

	local rangeStuds = State.killAuraRange * STUDS_PER_BLOCK
	local localPos = localRoot.Position
	local targets = {}

	if State.killAuraPlayers then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and not (State.killAuraTeamCheck and player.Team and player.Team == LocalPlayer.Team) then
				local char = getCharacter(player)

				if char then
					local root = char:FindFirstChild("HumanoidRootPart")

					if root then
						local dist = (root.Position - localPos).Magnitude

						if dist <= rangeStuds then targets[#targets+1] = { target = player, distance = dist } end
					end
				end
			end
		end
	end

	if State.killAuraNPCs then
		for _, npc in ipairs(refreshNPCCache()) do
			pcall(function()
				local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")

				if root then
					local hum = npc:FindFirstChildOfClass("Humanoid")

					if hum and hum.Health > 0 then
						local dist = (root.Position - localPos).Magnitude

						if dist <= rangeStuds then targets[#targets+1] = { target = npc, distance = dist } end
					end
				end
			end)
		end
	end

	table.sort(targets, function(a, b) return a.distance < b.distance end)

	return targets
end

local function startKillAura()
	if killAuraThread then return end
	killAuraToken += 1

	local token = killAuraToken

	killAuraThread = task.spawn(function()
		while State.killAura and token == killAuraToken do
			local targets = getKillAuraTargets()

			if #targets > 0 then
				if State.killAuraMulti then
					for i = 1, #targets do attackTarget(targets[i].target, "ka") end
				else
					attackTarget(targets[1].target, "ka")
				end
			end

			task.wait(1 / math.max(State.killAuraCPS, 1))
		end

		if token == killAuraToken then killAuraThread = nil end
	end)
end

local function stopKillAura()
	State.killAura = false
	killAuraToken += 1
	killAuraThread = nil
end

local function startAutoAttack()
	if autoAttackThread then return end
	autoAttackToken += 1

	local token = autoAttackToken

	autoAttackThread = task.spawn(function()
		while State.autoAttack and token == autoAttackToken do
			local tp = findTargetPlayer(State.target)

			if tp and getCharacter(tp) then attackTarget(tp, "auto") end

			task.wait(1 / math.max(State.autoAttackCPS, 1))
		end

		if token == autoAttackToken then autoAttackThread = nil end
	end)
end

local function stopAutoAttack()
	State.autoAttack = false
	autoAttackToken += 1
	autoAttackThread = nil
end

local function getTriggerBotTarget()
	local mouse = LocalPlayer:GetMouse()

	if not mouse or not mouse.Target then return nil end

	local target = mouse.Target
	local model = target:FindFirstAncestorOfClass("Model")

	if not model then return nil end

	local hum = model:FindFirstChildOfClass("Humanoid")

	if not hum or hum.Health <= 0 then return nil end

	local localRoot = getLocalRoot()
	local targetRoot = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")

	if not localRoot or not targetRoot then return nil end

	if (targetRoot.Position - localRoot.Position).Magnitude > State.triggerBotRange * STUDS_PER_BLOCK then return nil end

	local player = Players:GetPlayerFromCharacter(model)

	if player and player == LocalPlayer then return nil end
	if player and State.killAuraTeamCheck and player.Team and player.Team == LocalPlayer.Team then return nil end

	return player or model
end

local function startTriggerBot()
	if triggerBotThread then return end
	triggerBotToken += 1

	local token = triggerBotToken

	triggerBotThread = task.spawn(function()
		while State.triggerBot and token == triggerBotToken do
			local target = getTriggerBotTarget()

			if target then attackTarget(target, "tb") end

			task.wait(1 / math.max(State.triggerBotCPS, 1))
		end

		if token == triggerBotToken then triggerBotThread = nil end
	end)
end

local function stopTriggerBot()
	State.triggerBot = false
	triggerBotToken += 1
	triggerBotThread = nil
end

local function startNuker()
	if nukerThread then return end
	nukerToken += 1

	local token = nukerToken

	nukerThread = task.spawn(function()
		while State.nuker and token == nukerToken do
			local root = getLocalRoot()

			if root and State.nukerRange > 0 then
				local center = snapToGrid(root.Position)
				local r = State.nukerRange
				local breakCount = 0

				for x = -r, r do for y = -r, r do for z = -r, r do
					if token ~= nukerToken then break end

					local pos = center + Vector3.new(x, y, z) * STUDS_PER_BLOCK

					runtimeBreakAt(pos)

					breakCount += 1

					if breakCount % 3 == 0 then task.wait() end
				end end end
			else
				doBreakBlock("nuker")
			end

			task.wait(1 / math.clamp(State.nukerCPS, 1, 10))
		end

		if token == nukerToken then nukerThread = nil end
	end)
end

local function stopNuker()
	State.nuker = false
	nukerToken += 1
	nukerThread = nil
end

local function startScaffold()
	if scaffoldThread then return end
	scaffoldToken += 1

	local token = scaffoldToken

	scaffoldThread = task.spawn(function()
		while State.scaffold and token == scaffoldToken do
			local root = getLocalRoot()

			if root then
				runtimePlaceSimple({ blockType = State.scaffoldBlock })
			end

			task.wait(1 / math.clamp(State.scaffoldCPS, 1, 10))
		end

		if token == scaffoldToken then scaffoldThread = nil end
	end)
end

local function stopScaffold()
	State.scaffold = false
	scaffoldToken += 1
	scaffoldThread = nil
end

local function startTower()
	if towerThread then return end
	towerToken += 1

	local token = towerToken

	towerThread = task.spawn(function()
		while State.tower and token == towerToken do
			local root = getLocalRoot()
			local hum = getLocalHumanoid()

			if root and hum then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)

				task.wait(0.3)

				if root and root.Parent and token == towerToken then
					local belowPos = root.Position - Vector3.new(0, STUDS_PER_BLOCK, 0)

					runtimePlaceAt(belowPos, { blockType = State.towerBlock })
				end

				task.wait(0.2)

			else
				task.wait(0.1)
			end

			task.wait(1 / math.max(State.towerCPS, 1))
		end

		if token == towerToken then towerThread = nil end
	end)
end

local function stopTower()
	State.tower = false
	towerToken += 1
	towerThread = nil
end

local function startAutoBridge()
	if autoBridgeThread then return end
	autoBridgeToken += 1

	local token = autoBridgeToken

	autoBridgeThread = task.spawn(function()
		while State.autoBridge and token == autoBridgeToken do
			local root = getLocalRoot()

			if root then
				local hum = getLocalHumanoid()

				if hum and hum.MoveDirection.Magnitude > 0.1 then
					local moveDir = Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z)

					if moveDir.Magnitude > 0 then
						local dir = moveDir.Unit

						for i = 0, 2 do
							local pos = root.Position + dir * (i * STUDS_PER_BLOCK) - Vector3.new(0, STUDS_PER_BLOCK, 0)

							runtimePlaceAt(pos, { blockType = State.autoBridgeBlock })
						end
					end
				else
					local belowPos = root.Position - Vector3.new(0, STUDS_PER_BLOCK, 0)

					runtimePlaceAt(belowPos, { blockType = State.autoBridgeBlock })
				end
			end

			task.wait(1 / math.max(State.autoBridgeCPS, 1))
		end

		if token == autoBridgeToken then autoBridgeThread = nil end
	end)
end

local function stopAutoBridge()
	State.autoBridge = false
	autoBridgeToken += 1
	autoBridgeThread = nil
end

local function updateKillAuraVisual()
	if State.killAura and State.killAuraShowRange then
		local localRoot = getLocalRoot()

		if localRoot then
			if not killAuraVisualPart or not killAuraVisualPart.Parent then
				killAuraVisualPart = Instance.new("Part")
				killAuraVisualPart.Shape = Enum.PartType.Ball
				killAuraVisualPart.Anchored = true
				killAuraVisualPart.CanCollide = false
				killAuraVisualPart.Material = Enum.Material.ForceField
				killAuraVisualPart.Color = Color3.fromRGB(255, 50, 50)
				killAuraVisualPart.Transparency = 0.85
				killAuraVisualPart.CastShadow = false
				killAuraVisualPart.Parent = Workspace
			end

			local r = State.killAuraRange * STUDS_PER_BLOCK

			killAuraVisualPart.Size = Vector3.new(r*2, r*2, r*2)
			killAuraVisualPart.Position = localRoot.Position
		end
	else
		if killAuraVisualPart then pcall(function() killAuraVisualPart:Destroy() end); killAuraVisualPart = nil end
	end
end

local function getAimlockTarget()
	local closest, closestDist = nil, State.aimlockFOV
	local mousePos = UserInputService:GetMouseLocation()

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and not (State.aimlockTeamCheck and player.Team and player.Team == LocalPlayer.Team) then
			local char = getCharacter(player)

			if char then
				local part = char:FindFirstChild(State.aimlockPart) or char:FindFirstChild("Head")

				if part then
					local sp, on = Camera:WorldToScreenPoint(part.Position)

					if on then
						local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude

						if dist < closestDist then closestDist = dist; closest = char end
					end
				end
			end
		end
	end

	if State.aimlockNPCs then
		for _, npc in ipairs(refreshNPCCache()) do
			pcall(function()
				local part = npc:FindFirstChild(State.aimlockPart) or npc:FindFirstChild("Head")

				if part then
					local sp, on = Camera:WorldToScreenPoint(part.Position)

					if on then
						local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude

						if dist < closestDist then closestDist = dist; closest = npc end
					end
				end
			end)
		end
	end

	return closest
end

local function removeESP(key)
	local cache = espCache[key]

	if not cache then return end

	pcall(function() if cache.highlight then cache.highlight:Destroy() end end)
	pcall(function() if cache.billboard then cache.billboard:Destroy() end end)
	pcall(function() if cache.tracer then cache.tracer:Remove() end end)

	if cache.charAddedConn then pcall(function() cache.charAddedConn:Disconnect() end) end
	espCache[key] = nil
end

local function createESP(key, isNPCTarget)
	if not isNPCTarget and key == LocalPlayer then return end

	removeESP(key)

	local cache = { isNPC = isNPCTarget or false }

	espCache[key] = cache

	cache.highlight = Instance.new("Highlight")
	cache.highlight.FillColor = State.espFillColor
	cache.highlight.OutlineColor = State.espOutlineColor
	cache.highlight.FillTransparency = State.espFillTransparency
	cache.highlight.OutlineTransparency = State.espOutlineTransparency
	cache.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	cache.billboard = Instance.new("BillboardGui")
	cache.billboard.Size = UDim2.new(0, 200, 0, 60)
	cache.billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	cache.billboard.AlwaysOnTop = true
	cache.billboard.LightInfluence = 0

	cache.nameLabel = Instance.new("TextLabel")
	cache.nameLabel.Size = UDim2.new(1, 0, 0.35, 0)
	cache.nameLabel.BackgroundTransparency = 1
	cache.nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	cache.nameLabel.TextStrokeTransparency = 0
	cache.nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	cache.nameLabel.Font = Enum.Font.GothamBold
	cache.nameLabel.TextSize = 13
	cache.nameLabel.Parent = cache.billboard

	cache.healthBg = Instance.new("Frame")
	cache.healthBg.Size = UDim2.new(0.8, 0, 0.12, 0)
	cache.healthBg.Position = UDim2.new(0.1, 0, 0.4, 0)
	cache.healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	cache.healthBg.BorderSizePixel = 1
	cache.healthBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
	cache.healthBg.Parent = cache.billboard

	cache.healthBar = Instance.new("Frame")
	cache.healthBar.Size = UDim2.new(1, 0, 1, 0)
	cache.healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	cache.healthBar.BorderSizePixel = 0
	cache.healthBar.Parent = cache.healthBg

	cache.distLabel = Instance.new("TextLabel")
	cache.distLabel.Size = UDim2.new(1, 0, 0.3, 0)
	cache.distLabel.Position = UDim2.new(0, 0, 0.6, 0)
	cache.distLabel.BackgroundTransparency = 1
	cache.distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	cache.distLabel.TextStrokeTransparency = 0
	cache.distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	cache.distLabel.Font = Enum.Font.Gotham
	cache.distLabel.TextSize = 11
	cache.distLabel.Parent = cache.billboard

	pcall(function()
		cache.tracer = Drawing.new("Line")
		cache.tracer.Thickness = 1; cache.tracer.Color = State.espFillColor; cache.tracer.Transparency = 1; cache.tracer.Visible = false
	end)

	if not isNPCTarget and typeof(key) == "Instance" and key:IsA("Player") then
		cache.charAddedConn = key.CharacterAdded:Connect(function() task.wait(0.5); if espCache[key] then pcall(createESP, key, false) end end)
	end
end

local function refreshAllESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then if State.espEnabled then createESP(player, false) else removeESP(player) end end
	end

	if State.espEnabled and State.espNPCs then for _, npc in ipairs(refreshNPCCache()) do createESP(npc, true) end end
end

local function clearAllESP() for key in pairs(espCache) do removeESP(key) end end

local function updateESP()
	if not State.espEnabled then return end
	if State.espNPCs then
		for _, npc in ipairs(refreshNPCCache()) do if not espCache[npc] then pcall(createESP, npc, true) end end
	end

	local localRoot = getLocalRoot()

	for key, cache in pairs(espCache) do
		pcall(function()
			if not key or (typeof(key) == "Instance" and not key.Parent) then removeESP(key); return end

			local char, displayName

			if cache.isNPC then
				char = key; displayName = "[NPC] " .. key.Name

				if not State.espNPCs then cache.highlight.Parent = nil; cache.billboard.Enabled = false; if cache.tracer then cache.tracer.Visible = false end; return end
			else
				if State.espTeamCheck and key.Team and key.Team == LocalPlayer.Team then cache.highlight.Parent = nil; cache.billboard.Enabled = false; if cache.tracer then cache.tracer.Visible = false end; return end
				char = key.Character; displayName = key.DisplayName .. " [@" .. key.Name .. "]"
			end

			if not char or not char.Parent then cache.highlight.Parent = nil; cache.billboard.Enabled = false; if cache.tracer then cache.tracer.Visible = false end; return end

			local hum = char:FindFirstChildOfClass("Humanoid")
			local rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
			local head = char:FindFirstChild("Head")

			if not hum or not rootPart or hum.Health <= 0 then cache.highlight.Parent = nil; cache.billboard.Enabled = false; if cache.tracer then cache.tracer.Visible = false end; return end
			if State.espHighlight then
				cache.highlight.FillColor = State.espFillColor; cache.highlight.OutlineColor = State.espOutlineColor
				cache.highlight.FillTransparency = State.espFillTransparency; cache.highlight.OutlineTransparency = State.espOutlineTransparency
				cache.highlight.Adornee = char; cache.highlight.Parent = char
			else cache.highlight.Parent = nil end

			local adorn = head or rootPart

			cache.billboard.Adornee = adorn; cache.billboard.Parent = adorn; cache.billboard.Enabled = true
			cache.nameLabel.Visible = State.espNames; cache.nameLabel.Text = displayName
			cache.healthBg.Visible = State.espHealth

			local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

			cache.healthBar.Size = UDim2.new(ratio, 0, 1, 0)
			cache.healthBar.BackgroundColor3 = Color3.fromRGB(255*(1-ratio), 255*ratio, 0)
			cache.distLabel.Visible = State.espDistance

			if localRoot then cache.distLabel.Text = math.floor((rootPart.Position - localRoot.Position).Magnitude) .. " studs"
			else cache.distLabel.Text = "? studs" end

			if cache.tracer and State.espTracers then
				local sp, on = Camera:WorldToScreenPoint(rootPart.Position)

				if on then cache.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); cache.tracer.To = Vector2.new(sp.X, sp.Y); cache.tracer.Color = State.espFillColor; cache.tracer.Visible = true
				else cache.tracer.Visible = false end
			elseif cache.tracer then cache.tracer.Visible = false end
		end)
	end
end

local function startFly()
	pcall(function()
		if State.freecam then State.freecam = false; Camera.CameraType = originalCameraType or Enum.CameraType.Custom end

		local char = LocalPlayer.Character; if not char then return end
		local rootPart = char:FindFirstChild("HumanoidRootPart"); if not rootPart then return end
		local hum = char:FindFirstChildOfClass("Humanoid")

		if flyBodyVelocity then unregisterHidden(flyBodyVelocity); pcall(function() flyBodyVelocity:Destroy() end) end
		if flyBodyGyro then unregisterHidden(flyBodyGyro); pcall(function() flyBodyGyro:Destroy() end) end

		flyBodyVelocity = Instance.new("BodyVelocity"); flyBodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge); flyBodyVelocity.Velocity = Vector3.zero; flyBodyVelocity.Parent = rootPart; registerHidden(flyBodyVelocity)
		flyBodyGyro = Instance.new("BodyGyro"); flyBodyGyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge); flyBodyGyro.D = 200; flyBodyGyro.P = 10000; flyBodyGyro.Parent = rootPart; registerHidden(flyBodyGyro)

		if hum then hum.PlatformStand = true end
	end)
end

local function stopFly()
	pcall(function()
		if flyBodyVelocity then unregisterHidden(flyBodyVelocity); pcall(function() flyBodyVelocity:Destroy() end); flyBodyVelocity = nil end
		if flyBodyGyro then unregisterHidden(flyBodyGyro); pcall(function() flyBodyGyro:Destroy() end); flyBodyGyro = nil end

		local char = LocalPlayer.Character

		if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand = false end end
	end)
end

local function startFreecam()
	if State.fly then State.fly = false; pcall(stopFly) end
	State.aimlockActive = false; currentAimlockTarget = nil
	originalCameraType = Camera.CameraType
	Camera.CameraType = Enum.CameraType.Scriptable
end

local function stopFreecam()
	Camera.CameraType = originalCameraType or Enum.CameraType.Custom

	pcall(function()
		local hum = getLocalHumanoid()

		if hum then Camera.CameraSubject = hum end
	end)
end

local function enableFullbright()
	originalLighting.Ambient = Lighting.Ambient
	originalLighting.Brightness = Lighting.Brightness
	originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
	Lighting.Ambient = Color3.fromRGB(200, 200, 200)
	Lighting.Brightness = 2
	Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)

	for _, effect in ipairs(Lighting:GetChildren()) do
		pcall(function()
			if effect:IsA("Atmosphere") then
				originalLighting[effect] = { Density = effect.Density, Color = effect.Color }
				effect.Density = 0
			elseif effect:IsA("ColorCorrectionEffect") then
				originalLighting[effect] = { Enabled = effect.Enabled }
				effect.Enabled = false
			end
		end)
	end
end

local function disableFullbright()
	pcall(function() if originalLighting.Ambient then Lighting.Ambient = originalLighting.Ambient end end)
	pcall(function() if originalLighting.Brightness then Lighting.Brightness = originalLighting.Brightness end end)
	pcall(function() if originalLighting.OutdoorAmbient then Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient end end)

	for inst, props in pairs(originalLighting) do
		if typeof(inst) == "Instance" and type(props) == "table" then
			pcall(function() for k, v in pairs(props) do inst[k] = v end end)
		end
	end

	originalLighting = {}
end

local function enableNoFog()
	originalFog.FogEnd = Lighting.FogEnd
	originalFog.FogStart = Lighting.FogStart
	Lighting.FogEnd = 9999999
	Lighting.FogStart = 9999999

	for _, effect in ipairs(Lighting:GetChildren()) do
		pcall(function()
			if effect:IsA("Atmosphere") then
				originalFog[effect] = effect.Density
				effect.Density = 0
			end
		end)
	end
end

local function disableNoFog()
	pcall(function() if originalFog.FogEnd then Lighting.FogEnd = originalFog.FogEnd end end)
	pcall(function() if originalFog.FogStart then Lighting.FogStart = originalFog.FogStart end end)

	for inst, val in pairs(originalFog) do
		if typeof(inst) == "Instance" then pcall(function() inst.Density = val end) end
	end

	originalFog = {}
end

local function createCoordsHUD()
	if coordsGui then return end

	pcall(function()
		coordsGui = Instance.new("ScreenGui")
		coordsGui.Name = "CoordsHUD"
		coordsGui.ResetOnSpawn = false

		coordsLabel = Instance.new("TextLabel")
		coordsLabel.Size = UDim2.new(0, 350, 0, 24)
		coordsLabel.Position = UDim2.new(0.5, -175, 1, -35)
		coordsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		coordsLabel.BackgroundTransparency = 0.5
		coordsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		coordsLabel.Font = Enum.Font.RobotoMono
		coordsLabel.TextSize = 14
		coordsLabel.Parent = coordsGui

		local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if pg then coordsGui.Parent = pg end
	end)
end

local function destroyCoordsHUD()
	if coordsGui then pcall(function() coordsGui:Destroy() end); coordsGui = nil; coordsLabel = nil end
end

local function updateCoords()
	if not State.coordsEnabled then if coordsGui then destroyCoordsHUD() end; return end
	if not coordsGui then createCoordsHUD() end
	if not coordsLabel then return end

	local root = getLocalRoot()

	if root then
		local p = root.Position
		local blockPos = snapToGrid(p) / STUDS_PER_BLOCK

		coordsLabel.Text = string.format("XYZ: %.1f / %.1f / %.1f  Block: %d, %d, %d", p.X, p.Y, p.Z, blockPos.X, blockPos.Y, blockPos.Z)
		coordsLabel.Visible = true
	else
		coordsLabel.Text = "XYZ: - / - / -"
	end
end

local function clearBreadcrumbs()
	for _, p in ipairs(breadcrumbParts) do pcall(function() p:Destroy() end) end
	breadcrumbParts = {}
	lastBreadcrumbPos = nil
end

local function updateBreadcrumbs()
	if not State.breadcrumbs then return end

	local root = getLocalRoot()

	if not root then return end

	local pos = root.Position

	if lastBreadcrumbPos and (pos - lastBreadcrumbPos).Magnitude < BREADCRUMB_SPACING then return end
	lastBreadcrumbPos = pos

	local part = Instance.new("Part")

	part.Size = Vector3.new(0.4, 0.4, 0.4)
	part.Position = pos - Vector3.new(0, 2.5, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = State.breadcrumbColor
	part.Transparency = 0.3
	part.CastShadow = false
	part.Shape = Enum.PartType.Ball
	part.Parent = Workspace
	breadcrumbParts[#breadcrumbParts+1] = part

	if #breadcrumbParts > 300 then
		pcall(function() breadcrumbParts[1]:Destroy() end)
		table.remove(breadcrumbParts, 1)
	end
end

local function blinkSave()
	local root = getLocalRoot()

	if root then
		blinkPositions[#blinkPositions+1] = root.CFrame

		notify("Blink", "Saved #" .. #blinkPositions)
	end
end

local function blinkLoad()
	if #blinkPositions == 0 then notify("Blink", "No saved positions"); return end

	local root = getLocalRoot()

	if root then
		root.CFrame = blinkPositions[#blinkPositions]

		table.remove(blinkPositions)
		notify("Blink", "Loaded (" .. #blinkPositions .. " remaining)")
	end
end

local function blinkForward(distance)
	local root = getLocalRoot()

	if root then root.CFrame = root.CFrame + root.CFrame.LookVector * (distance or 10); notify("Blink", "Forward " .. (distance or 10)) end
end

local function doPhase()
	local root = getLocalRoot()

	if not root then return end

	local params = RaycastParams.new()

	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {LocalPlayer.Character}

	local dir = root.CFrame.LookVector
	local result = Workspace:Raycast(root.Position, dir * 30, params)

	if result then
		root.CFrame = CFrame.new(result.Position + dir * 4, result.Position + dir * 10)

		notify("Phase", "Clipped through")
	end
end

local function doHandshake()
	local luaOk, success, response = callBoolResponse(ClientRuntime.Handshake, { session = "luna", ts = os.clock() })

	if luaOk and success then
		State.packets += 1; State.lastAck = "handshake_ok"; pcall(updateUi); notify("Handshake", "Sent")
	else
		State.errors += 1; State.lastAck = "handshake_err:" .. tostring(response or ""); pcall(updateUi); notify("Handshake", "Failed: " .. tostring(response or "unknown"))
	end
end

local function doPulse()
	local luaOk, success, response = callBoolResponse(ClientRuntime.Pulse, { ts = os.clock() })

	if luaOk and success then State.packets += 1; State.lastAck = "pulse_ok"
	else State.errors += 1; State.lastAck = "pulse_err:" .. tostring(response or "") end

	pcall(updateUi)
end

local function doPanic()
	State.killAura = false; State.autoAttack = false; State.aimlock = false; State.aimlockActive = false
	State.triggerBot = false; State.criticals = false
	State.fly = false; State.noclip = false; State.velocityEnabled = false; State.infiniteJump = false
	State.antiKB = false; State.stepEnabled = false; State.spider = false; State.longJump = false; State.autoWalk = false
	State.nuker = false; State.scaffold = false; State.tower = false; State.autoBridge = false
	State.freecam = false; State.fullbright = false; State.noFog = false; State.customFOV = false
	State.coordsEnabled = false; State.breadcrumbs = false; State.espEnabled = false
	killAuraToken += 1; autoAttackToken += 1; triggerBotToken += 1
	nukerToken += 1; scaffoldToken += 1; towerToken += 1; autoBridgeToken += 1
	killAuraThread = nil; autoAttackThread = nil; nukerThread = nil; scaffoldThread = nil
	towerThread = nil; autoBridgeThread = nil; triggerBotThread = nil; currentAimlockTarget = nil

	pcall(stopFly); pcall(stopFreecam); pcall(disableFullbright); pcall(disableNoFog)
	pcall(clearAllESP); pcall(clearBreadcrumbs); pcall(destroyCoordsHUD)

	if killAuraVisualPart then pcall(function() killAuraVisualPart:Destroy() end); killAuraVisualPart = nil end

	pcall(function() Camera.FieldOfView = 70 end)

	if LocalPlayer.Character then
		local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

		if h then h.WalkSpeed = 16; h.JumpPower = 50 end
	end

	pcall(resetReach)

	State.packets = 0; State.errors = 0; State.lastAck = "panic"

	notify("PANIC", "All features disabled")
end

pcall(function()
	fovCircle = Drawing.new("Circle"); fovCircle.Color = Color3.fromRGB(255,255,255); fovCircle.Thickness = 1; fovCircle.NumSides = 64; fovCircle.Filled = false; fovCircle.Transparency = 0.7; fovCircle.Visible = false
end)

pcall(function()
	Players.PlayerAdded:Connect(function(player)
		if State.espEnabled then pcall(createESP, player, false) end
	end)
end)

pcall(function() Players.PlayerRemoving:Connect(function(player) pcall(removeESP, player) end) end)
pcall(function()
	LocalPlayer.CharacterAdded:Connect(function(char)
		pcall(hookCharacterStateChanges, char)

		if State.fly then task.wait(0.5); pcall(startFly) end
	end)
end)

pcall(function()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end

		pcall(function()
			if input.KeyCode == State.aimlockKey and State.aimlock and not State.freecam then
				State.aimlockActive = not State.aimlockActive

				if State.aimlockActive then currentAimlockTarget = getAimlockTarget() else currentAimlockTarget = nil end
			end

			if State.infiniteJump and input.KeyCode == Enum.KeyCode.Space then
				local hum = getLocalHumanoid()

				if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
			end

						if input.KeyCode == Enum.KeyCode.P then doPanic() end
			if input.KeyCode == Enum.KeyCode.B and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then blinkSave() end
			if input.KeyCode == Enum.KeyCode.V and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then blinkLoad() end
		end)
	end)
end)

pcall(function()
	RunService.Stepped:Connect(function()
		pcall(function()
			if State.noclip and LocalPlayer.Character then
				for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)

		pcall(function()
			if State.antiKB and LocalPlayer.Character then
				local root = getLocalRoot()

				if root then
					for _, child in ipairs(root:GetChildren()) do
						if (child:IsA("BodyVelocity") or child:IsA("BodyForce") or child:IsA("LinearVelocity") or child:IsA("VectorForce")) and not isHidden(child) then
							if State.antiKBPercent >= 100 then
								child:Destroy()

							else
								pcall(function()
									if child:IsA("BodyVelocity") then
										child.Velocity = child.Velocity * (1 - State.antiKBPercent / 100)
									end
								end)
							end
						end
					end
				end
			end
		end)

		pcall(function()
			if State.stepEnabled and LocalPlayer.Character then
				local hum = getLocalHumanoid()

				if hum then hum.HipHeight = State.stepHeight end
			end
		end)

		pcall(function()
			if State.spider and LocalPlayer.Character then
				local root = getLocalRoot()
				local hum = getLocalHumanoid()

				if root and hum then
					local params = RaycastParams.new()

					params.FilterType = Enum.RaycastFilterType.Exclude
					params.FilterDescendantsInstances = {LocalPlayer.Character}

					local directions = {root.CFrame.RightVector, -root.CFrame.RightVector, root.CFrame.LookVector, -root.CFrame.LookVector}

					for _, dir in ipairs(directions) do
						local result = Workspace:Raycast(root.Position, dir * 2, params)

						if result then
							root.Velocity = Vector3.new(root.Velocity.X, State.spiderSpeed, root.Velocity.Z)
							break
						end
					end
				end
			end
		end)

		pcall(function()
			if State.autoWalk then
				local hum = getLocalHumanoid()

				if hum then hum:Move(Vector3.new(0, 0, -1)) end
			end
		end)
	end)
end)

pcall(function()
	RunService.RenderStepped:Connect(function()
		pcall(function()
			if State.aimlock and State.aimlockActive and not State.freecam then
				if currentAimlockTarget and currentAimlockTarget.Parent then
					local hum = currentAimlockTarget:FindFirstChildOfClass("Humanoid")

					if hum and hum.Health > 0 then
						local part = currentAimlockTarget:FindFirstChild(State.aimlockPart) or currentAimlockTarget:FindFirstChild("Head")

						if part then
							local goal = CFrame.lookAt(Camera.CFrame.Position, part.Position)

							if State.aimlockSmoothing <= 1 then Camera.CFrame = goal
							else Camera.CFrame = Camera.CFrame:Lerp(goal, 1 / State.aimlockSmoothing) end
						end

					else currentAimlockTarget = getAimlockTarget() end
				else currentAimlockTarget = getAimlockTarget() end
			end
		end)

		pcall(function()
			if fovCircle then
				fovCircle.Position = UserInputService:GetMouseLocation(); fovCircle.Radius = State.aimlockFOV
				fovCircle.Visible = State.aimlockShowFOV and State.aimlock
			end
		end)

		pcall(function()
			if State.fly and flyBodyVelocity and flyBodyGyro then
				local dir = Vector3.zero

				if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
				if dir.Magnitude > 0 then dir = dir.Unit end
				flyBodyVelocity.Velocity = dir * State.flySpeed; flyBodyGyro.CFrame = Camera.CFrame
			end
		end)

		pcall(function()
			if State.freecam then
				local speed = State.freecamSpeed
				local dir = Vector3.zero

				if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.E) then speed = speed * 2 end
				if dir.Magnitude > 0 then dir = dir.Unit end
				Camera.CFrame = Camera.CFrame + dir * speed * (1/60)
			end
		end)

		pcall(function()
			if State.velocityEnabled and LocalPlayer.Character then
				local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

				if hum then hum.WalkSpeed = State.velocityWalkSpeed; hum.JumpPower = State.velocityJumpPower end
			end
		end)

		pcall(function()
			if State.longJump then
				local hum = getLocalHumanoid()
				local root = getLocalRoot()

				if hum and root and hum:GetState() == Enum.HumanoidStateType.Freefall then
					if not longJumpApplied then
						longJumpApplied = true
						root.Velocity = Vector3.new(
							root.Velocity.X * State.longJumpBoost,
							root.Velocity.Y,
							root.Velocity.Z * State.longJumpBoost
						)
					end
				else
					longJumpApplied = false
				end
			end
		end)

		pcall(function()
			if State.customFOV then Camera.FieldOfView = State.fovValue end
		end)

		pcall(updateKillAuraVisual)
		pcall(updateCoords)
		pcall(updateBreadcrumbs)

		local now = os.clock()

		if now - espUpdateTick >= ESP_UPDATE_INTERVAL then espUpdateTick = now; pcall(updateESP) end
		if now - uiUpdateTick >= UI_UPDATE_INTERVAL then uiUpdateTick = now; pcall(updateUi) end
	end)
end)

local Window = Luna:CreateWindow({
	Name = "LunaClient",
	Subtitle = "ClientRuntime Bridge",
	LoadingEnabled = true,
	LoadingTitle = "LunaClient",
	LoadingSubtitle = "Initializing runtime",
	ConfigSettings = { RootFolder = "LunaClient", ConfigFolder = "RuntimeControl" },
	KeySystem = false,
})

local CombatTab = Window:CreateTab({ Name = "Combat", ShowTitle = true })
local WorldTab = Window:CreateTab({ Name = "World", ShowTitle = true })
local ESPTab = Window:CreateTab({ Name = "ESP", ShowTitle = true })
local MovementTab = Window:CreateTab({ Name = "Movement", ShowTitle = true })
local RenderTab = Window:CreateTab({ Name = "Render", ShowTitle = true })
local MiscTab = Window:CreateTab({ Name = "Misc", ShowTitle = true })
local SessionTab = Window:CreateTab({ Name = "Session", ShowTitle = true })

CombatTab:CreateSection("Targeting")
CombatTab:CreateInput({ Name = "Target", PlaceholderText = "PlayerName", CurrentValue = "", Numeric = false, MaxCharacters = 32, Enter = false, Callback = function(t) State.target = tostring(t or "") end }, "RuntimeTarget")
CombatTab:CreateButton({ Name = "Attack Target", Description = "Send one attack via Bridge", Callback = function() pcall(function() if attackByName("manual") then notify("Attack", "Sent") end end) end })
CombatTab:CreateButton({ Name = "Burst x5", Callback = function() pcall(function() local s=0; for _=1,5 do if attackByName("burst") then s+=1 end end; notify("Burst", s.." sent") end) end })
CombatTab:CreateToggle({ Name = "Auto Attack", Description = "Continuously attack set target", CurrentValue = false, Callback = function(v) State.autoAttack = v; if v then startAutoAttack() else stopAutoAttack() end end }, "AutoAttackToggle")
CombatTab:CreateSlider({ Name = "Auto Attack CPS", Range = {1, 20}, Increment = 1, CurrentValue = 10, Callback = function(v) State.autoAttackCPS = v end }, "AutoAttackCPS")
CombatTab:CreateSection("KillAura")
CombatTab:CreateToggle({ Name = "Enable KillAura", Description = "Auto-attack entities in range", CurrentValue = false, Callback = function(v) State.killAura = v; if v then startKillAura() else stopKillAura() end end }, "KillAuraToggle")
CombatTab:CreateSlider({ Name = "Range (blocks)", Description = "1 block = "..STUDS_PER_BLOCK.." studs", Range = {1, 10}, Increment = 0.5, CurrentValue = 3, Callback = function(v) State.killAuraRange = v end }, "KillAuraRange")
CombatTab:CreateSlider({ Name = "KillAura CPS", Range = {1, 20}, Increment = 1, CurrentValue = 10, Callback = function(v) State.killAuraCPS = v end }, "KillAuraCPS")
CombatTab:CreateToggle({ Name = "Multi-Target", CurrentValue = false, Callback = function(v) State.killAuraMulti = v end }, "KillAuraMulti")
CombatTab:CreateToggle({ Name = "Target Players", CurrentValue = true, Callback = function(v) State.killAuraPlayers = v end }, "KillAuraPlayers")
CombatTab:CreateToggle({ Name = "Target NPCs", CurrentValue = true, Callback = function(v) State.killAuraNPCs = v end }, "KillAuraNPCs")
CombatTab:CreateToggle({ Name = "Team Check", CurrentValue = false, Callback = function(v) State.killAuraTeamCheck = v end }, "KillAuraTeamCheck")
CombatTab:CreateToggle({ Name = "Show Range", CurrentValue = false, Callback = function(v) State.killAuraShowRange = v end }, "KillAuraShowRange")
CombatTab:CreateSection("TriggerBot")
CombatTab:CreateToggle({ Name = "Enable TriggerBot", Description = "Attack what you look at", CurrentValue = false, Callback = function(v) State.triggerBot = v; if v then startTriggerBot() else stopTriggerBot() end end }, "TriggerBotToggle")
CombatTab:CreateSlider({ Name = "TriggerBot CPS", Range = {1, 20}, Increment = 1, CurrentValue = 10, Callback = function(v) State.triggerBotCPS = v end }, "TriggerBotCPS")
CombatTab:CreateSlider({ Name = "TriggerBot Range (blocks)", Range = {1, 20}, Increment = 1, CurrentValue = 15, Callback = function(v) State.triggerBotRange = v end }, "TriggerBotRange")
CombatTab:CreateSection("Criticals")
CombatTab:CreateToggle({ Name = "Criticals", Description = "Jump before each hit for extra damage", CurrentValue = false, Callback = function(v) State.criticals = v end }, "CriticalsToggle")
CombatTab:CreateSection("Anti-KB")
CombatTab:CreateToggle({ Name = "Anti-Knockback", Description = "Reduce or negate knockback", CurrentValue = false, Callback = function(v) State.antiKB = v end }, "AntiKBToggle")
CombatTab:CreateSlider({ Name = "KB Reduction %", Range = {0, 100}, Increment = 10, CurrentValue = 100, Callback = function(v) State.antiKBPercent = v end }, "AntiKBPercent")
CombatTab:CreateSection("Reach")
CombatTab:CreateSlider({ Name = "Combat Reach", Range = {1, 10}, Increment = 0.5, CurrentValue = State.combatReach, Callback = function(v) State.combatReach = v end }, "CombatReach")
CombatTab:CreateSlider({ Name = "Block Reach", Range = {1, 10}, Increment = 0.5, CurrentValue = State.blockReach, Callback = function(v) State.blockReach = v end }, "BlockReach")
CombatTab:CreateButton({ Name = "Apply Reach", Callback = function() pcall(applyReach) end })
CombatTab:CreateButton({ Name = "Reset Reach", Callback = function() pcall(resetReach) end })
CombatTab:CreateButton({ Name = "Sync Reach", Description = "Read current values from bridge", Callback = function() pcall(syncReach) end })
CombatTab:CreateSection("Aimlock")
CombatTab:CreateToggle({ Name = "Enable Aimlock", Description = "Press Q to toggle", CurrentValue = false, Callback = function(v) State.aimlock = v; if not v then State.aimlockActive = false; currentAimlockTarget = nil end end }, "AimlockToggle")
CombatTab:CreateToggle({ Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) State.aimlockShowFOV = v end }, "FOVCircleToggle")
CombatTab:CreateSlider({ Name = "FOV Radius", Range = {50, 800}, Increment = 10, CurrentValue = 250, Callback = function(v) State.aimlockFOV = v end }, "FOVRadius")
CombatTab:CreateSlider({ Name = "Smoothing", Range = {1, 20}, Increment = 1, CurrentValue = 1, Callback = function(v) State.aimlockSmoothing = v end }, "AimlockSmoothing")
CombatTab:CreateDropdown({ Name = "Aim Part", Options = {"Head","HumanoidRootPart","UpperTorso","LowerTorso"}, CurrentOption = "Head", Callback = function(o) State.aimlockPart = o end }, "AimPart")
CombatTab:CreateToggle({ Name = "Aimlock Team Check", CurrentValue = false, Callback = function(v) State.aimlockTeamCheck = v end }, "AimlockTeamCheck")
CombatTab:CreateToggle({ Name = "Aimlock NPCs", CurrentValue = false, Callback = function(v) State.aimlockNPCs = v end }, "AimlockNPCs")
WorldTab:CreateSection("Nuker")
WorldTab:CreateToggle({ Name = "Enable Nuker", Description = "Continuously break blocks", CurrentValue = false, Callback = function(v) State.nuker = v; if v then startNuker() else stopNuker() end end }, "NukerToggle")
WorldTab:CreateSlider({ Name = "Nuker CPS", Range = {1, 20}, Increment = 1, CurrentValue = 5, Callback = function(v) State.nukerCPS = v end }, "NukerCPS")
WorldTab:CreateSlider({ Name = "Nuker Range (blocks)", Range = {0, 5}, Increment = 1, CurrentValue = 1, Callback = function(v) State.nukerRange = v end }, "NukerRange")
WorldTab:CreateButton({ Name = "Break Block (once)", Callback = function() pcall(function() doBreakBlock("manual") end) end })
WorldTab:CreateSection("Scaffold")
WorldTab:CreateToggle({ Name = "Enable Scaffold", Description = "Place blocks under feet while moving", CurrentValue = false, Callback = function(v) State.scaffold = v; if v then startScaffold() else stopScaffold() end end }, "ScaffoldToggle")
WorldTab:CreateSlider({ Name = "Scaffold CPS", Range = {1, 20}, Increment = 1, CurrentValue = 10, Callback = function(v) State.scaffoldCPS = v end }, "ScaffoldCPS")
WorldTab:CreateDropdown({ Name = "Block Type", Options = {"Stone","Dirt","Oak Planks","Cobblestone","Glass","Brick","Sand","Gravel","Oak Log"}, CurrentOption = "Stone", Callback = function(o) State.scaffoldBlock = o end }, "ScaffoldBlock")
WorldTab:CreateButton({ Name = "Scaffold Line (10)", Description = "Place 10 blocks ahead", Callback = function() pcall(function()
	local ok, count = runtimeScaffold(10, { blockType = State.scaffoldBlock })

	notify("Scaffold", ok and ("Placed " .. count .. " blocks") or "Failed")

end) end })

WorldTab:CreateButton({ Name = "Scaffold Line (25)", Callback = function() pcall(function()
	local ok, count = runtimeScaffold(25, { blockType = State.scaffoldBlock })

	notify("Scaffold", ok and ("Placed " .. count .. " blocks") or "Failed")

end) end })

WorldTab:CreateSection("Tower")
WorldTab:CreateToggle({ Name = "Enable Tower", Description = "Build upward by jumping", CurrentValue = false, Callback = function(v) State.tower = v; if v then startTower() else stopTower() end end }, "TowerToggle")
WorldTab:CreateSlider({ Name = "Tower CPS", Range = {1, 10}, Increment = 1, CurrentValue = 5, Callback = function(v) State.towerCPS = v end }, "TowerCPS")
WorldTab:CreateDropdown({ Name = "Tower Block", Options = {"Stone","Dirt","Oak Planks","Cobblestone","Glass","Brick"}, CurrentOption = "Stone", Callback = function(o) State.towerBlock = o end }, "TowerBlock")
WorldTab:CreateSection("AutoBridge")
WorldTab:CreateToggle({ Name = "Enable AutoBridge", Description = "Place blocks in movement direction", CurrentValue = false, Callback = function(v) State.autoBridge = v; if v then startAutoBridge() else stopAutoBridge() end end }, "AutoBridgeToggle")
WorldTab:CreateSlider({ Name = "AutoBridge CPS", Range = {1, 20}, Increment = 1, CurrentValue = 8, Callback = function(v) State.autoBridgeCPS = v end }, "AutoBridgeCPS")
WorldTab:CreateDropdown({ Name = "AutoBridge Block", Options = {"Stone","Dirt","Oak Planks","Cobblestone","Glass","Brick"}, CurrentOption = "Stone", Callback = function(o) State.autoBridgeBlock = o end }, "AutoBridgeBlock")
WorldTab:CreateSection("Place/Break")
WorldTab:CreateButton({ Name = "Place Block (once)", Callback = function() pcall(function() doPlaceBlock("manual") end) end })
WorldTab:CreateButton({ Name = "Place Offhand", Callback = function() pcall(function() doPlaceBlock("manual", nil, { forceOffhand = true }) end) end })
WorldTab:CreateButton({ Name = "Place At Feet", Callback = function() pcall(function()
	local root = getLocalRoot()

	if root then
		runtimePlaceAt(root.Position - Vector3.new(0, STUDS_PER_BLOCK, 0), { blockType = State.scaffoldBlock })
	end

end) end })

WorldTab:CreateButton({ Name = "Break At Look", Callback = function() pcall(function()
	local mouse = LocalPlayer:GetMouse()

	if mouse and mouse.Hit then doBreakBlock("manual", mouse.Hit.Position) end
end) end })

ESPTab:CreateSection("Player ESP")
ESPTab:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Callback = function(v) State.espEnabled = v; if v then refreshAllESP() else clearAllESP() end end }, "ESPToggle")
ESPTab:CreateToggle({ Name = "Highlight", CurrentValue = true, Callback = function(v) State.espHighlight = v end }, "ESPHighlight")
ESPTab:CreateToggle({ Name = "Names", CurrentValue = true, Callback = function(v) State.espNames = v end }, "ESPNames")
ESPTab:CreateToggle({ Name = "Health Bar", CurrentValue = true, Callback = function(v) State.espHealth = v end }, "ESPHealth")
ESPTab:CreateToggle({ Name = "Distance", CurrentValue = true, Callback = function(v) State.espDistance = v end }, "ESPDistance")
ESPTab:CreateToggle({ Name = "Tracers", CurrentValue = false, Callback = function(v) State.espTracers = v end }, "ESPTracers")
ESPTab:CreateToggle({ Name = "Team Check", CurrentValue = false, Callback = function(v) State.espTeamCheck = v end }, "ESPTeamCheck")
ESPTab:CreateToggle({ Name = "Show NPCs", CurrentValue = false, Callback = function(v) State.espNPCs = v; if State.espEnabled then refreshAllESP() end end }, "ESPNPCs")
ESPTab:CreateSection("Appearance")
ESPTab:CreateSlider({ Name = "Fill Transparency", Range = {0, 100}, Increment = 5, CurrentValue = 75, Callback = function(v) State.espFillTransparency = v/100 end }, "ESPFillTransparency")
ESPTab:CreateSlider({ Name = "Outline Transparency", Range = {0, 100}, Increment = 5, CurrentValue = 0, Callback = function(v) State.espOutlineTransparency = v/100 end }, "ESPOutlineTransparency")
ESPTab:CreateButton({ Name = "Color: Red", Callback = function() State.espFillColor = Color3.fromRGB(255,0,0); State.espOutlineColor = Color3.fromRGB(255,255,255) end })
ESPTab:CreateButton({ Name = "Color: Purple", Callback = function() State.espFillColor = Color3.fromRGB(170,0,255); State.espOutlineColor = Color3.fromRGB(255,255,255) end })
ESPTab:CreateButton({ Name = "Color: Cyan", Callback = function() State.espFillColor = Color3.fromRGB(0,255,255); State.espOutlineColor = Color3.fromRGB(255,255,255) end })
ESPTab:CreateButton({ Name = "Color: Green", Callback = function() State.espFillColor = Color3.fromRGB(0,255,0); State.espOutlineColor = Color3.fromRGB(255,255,255) end })
MovementTab:CreateSection("Speed")
MovementTab:CreateToggle({ Name = "Speed Override", CurrentValue = false, Callback = function(v) State.velocityEnabled = v; if not v and LocalPlayer.Character then local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=16; h.JumpPower=50 end end end }, "VelocityToggle")
MovementTab:CreateSlider({ Name = "Walk Speed", Range = {0, 500}, Increment = 1, CurrentValue = 16, Callback = function(v) State.velocityWalkSpeed = v end }, "WalkSpeed")
MovementTab:CreateSlider({ Name = "Jump Power", Range = {0, 500}, Increment = 1, CurrentValue = 50, Callback = function(v) State.velocityJumpPower = v end }, "JumpPower")
MovementTab:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Callback = function(v) State.infiniteJump = v end }, "InfiniteJump")
MovementTab:CreateSection("Flight")
MovementTab:CreateToggle({ Name = "Fly", Description = "WASD+Space/LShift", CurrentValue = false, Callback = function(v) State.fly = v; if v then startFly() else stopFly() end end }, "FlyToggle")
MovementTab:CreateSlider({ Name = "Fly Speed", Range = {10, 500}, Increment = 5, CurrentValue = 50, Callback = function(v) State.flySpeed = v end }, "FlySpeed")
MovementTab:CreateSection("Movement Mods")
MovementTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) State.noclip = v end }, "NoclipToggle")
MovementTab:CreateToggle({ Name = "Step", Description = "Auto-step up blocks", CurrentValue = false, Callback = function(v) State.stepEnabled = v; if not v then pcall(function() local h = getLocalHumanoid(); if h then h.HipHeight = 0 end end) end end }, "StepToggle")
MovementTab:CreateSlider({ Name = "Step Height", Range = {1, 10}, Increment = 0.5, CurrentValue = 3, Callback = function(v) State.stepHeight = v end }, "StepHeight")
MovementTab:CreateToggle({ Name = "Spider", Description = "Climb walls", CurrentValue = false, Callback = function(v) State.spider = v end }, "SpiderToggle")
MovementTab:CreateSlider({ Name = "Spider Speed", Range = {1, 50}, Increment = 1, CurrentValue = 10, Callback = function(v) State.spiderSpeed = v end }, "SpiderSpeed")
MovementTab:CreateToggle({ Name = "Long Jump", Description = "Boost horizontal while airborne", CurrentValue = false, Callback = function(v) State.longJump = v end }, "LongJumpToggle")
MovementTab:CreateSlider({ Name = "LJ Boost", Range = {1, 3}, Increment = 0.1, CurrentValue = 1.5, Callback = function(v) State.longJumpBoost = v end }, "LJBoost")
MovementTab:CreateToggle({ Name = "Auto Walk", CurrentValue = false, Callback = function(v) State.autoWalk = v end }, "AutoWalkToggle")
MovementTab:CreateSection("Teleport")
MovementTab:CreateButton({ Name = "Blink Forward 10", Callback = function() pcall(blinkForward, 10) end })
MovementTab:CreateButton({ Name = "Blink Forward 25", Callback = function() pcall(blinkForward, 25) end })
MovementTab:CreateButton({ Name = "Blink Save (Ctrl+B)", Callback = function() pcall(blinkSave) end })
MovementTab:CreateButton({ Name = "Blink Load (Ctrl+V)", Callback = function() pcall(blinkLoad) end })
MovementTab:CreateButton({ Name = "Phase Through Wall", Callback = function() pcall(doPhase) end })
RenderTab:CreateSection("Camera")
RenderTab:CreateToggle({ Name = "Freecam", Description = "Detached camera movement", CurrentValue = false, Callback = function(v) State.freecam = v; if v then startFreecam() else stopFreecam() end end }, "FreecamToggle")
RenderTab:CreateSlider({ Name = "Freecam Speed", Range = {10, 500}, Increment = 5, CurrentValue = 50, Callback = function(v) State.freecamSpeed = v end }, "FreecamSpeed")
RenderTab:CreateToggle({ Name = "Custom FOV", CurrentValue = false, Callback = function(v) State.customFOV = v; if not v then pcall(function() Camera.FieldOfView = 70 end) end end }, "CustomFOVToggle")
RenderTab:CreateSlider({ Name = "FOV Value", Range = {30, 140}, Increment = 5, CurrentValue = 70, Callback = function(v) State.fovValue = v end }, "FOVValue")
RenderTab:CreateSection("World Render")
RenderTab:CreateToggle({ Name = "Fullbright", Description = "Remove darkness", CurrentValue = false, Callback = function(v) State.fullbright = v; if v then enableFullbright() else disableFullbright() end end }, "FullbrightToggle")
RenderTab:CreateToggle({ Name = "No Fog", Description = "Remove fog effects", CurrentValue = false, Callback = function(v) State.noFog = v; if v then enableNoFog() else disableNoFog() end end }, "NoFogToggle")
RenderTab:CreateSection("HUD")
RenderTab:CreateToggle({ Name = "Coordinates", Description = "Show XYZ + block position", CurrentValue = false, Callback = function(v) State.coordsEnabled = v; if not v then destroyCoordsHUD() end end }, "CoordsToggle")
RenderTab:CreateToggle({ Name = "Breadcrumbs", Description = "Leave a trail of markers", CurrentValue = false, Callback = function(v) State.breadcrumbs = v; if not v then clearBreadcrumbs() end end }, "BreadcrumbsToggle")
RenderTab:CreateButton({ Name = "Clear Breadcrumbs", Callback = function() clearBreadcrumbs() end })
MiscTab:CreateSection("Safety")
MiscTab:CreateToggle({ Name = "Anti-Kick", CurrentValue = true, Callback = function(v) State.antiKick = v end }, "AntiKickToggle")
MiscTab:CreateToggle({ Name = "Auto Respawn", CurrentValue = false, Callback = function(v) State.autoRespawn = v end }, "AutoRespawnToggle")
MiscTab:CreateButton({ Name = "PANIC (P key)", Description = "Disable ALL features instantly", Callback = function() pcall(doPanic) end })
MiscTab:CreateSection("Config")
MiscTab:CreateButton({ Name = "Save Config", Description = "Save all settings to file", Callback = function() pcall(saveConfig); notify("Config", "Saved") end })
MiscTab:CreateButton({ Name = "Load Config", Description = "Load settings from file", Callback = function() pcall(loadConfig) end })
MiscTab:CreateButton({ Name = "Reset Config", Description = "Delete saved config file", Callback = function()
	pcall(function()
		if typeof(delfile) == "function" and typeof(isfile) == "function" and isfile("LunaClient/config.json") then
			delfile("LunaClient/config.json")
			notify("Config", "Config file deleted")
		end
	end)

end })

SessionTab:CreateSection("Stats")

statsParagraph = SessionTab:CreateParagraph({ Title = "Runtime Stats", Text = "Initializing..." })

SessionTab:CreateSection("Bridge")
SessionTab:CreateButton({ Name = "Init Bridge", Description = "Call ClientRuntime.Init()", Callback = function() pcall(function() local luaOk, r = safeBridgeCall(ClientRuntime.Init); notify("Init", luaOk and r and "Success" or "Failed") end) end })
SessionTab:CreateButton({ Name = "Check Ready", Callback = function() pcall(function() local luaOk, r = safeBridgeCall(ClientRuntime.IsReady); notify("Ready", luaOk and tostring(r) or "Error") end) end })
SessionTab:CreateButton({ Name = "Check Bridge", Callback = function() pcall(function() local luaOk, a, e = safeBridgeCall(ClientRuntime.IsBridgeAvailable); notify("Bridge", luaOk and (tostring(a) .. " " .. tostring(e or "")) or "Error") end) end })
SessionTab:CreateButton({ Name = "Handshake", Callback = function() pcall(doHandshake) end })
SessionTab:CreateButton({ Name = "Pulse", Callback = function() pcall(doPulse) end })
SessionTab:CreateButton({ Name = "Sync Reach", Callback = function() pcall(function() syncReach(); notify("Sync", "State synced") end) end })
SessionTab:CreateButton({ Name = "Get All Values", Callback = function() pcall(function()
	local vals = callValue(ClientRuntime.GetAll)

	if not vals then notify("Values", "Failed"); return end

	local txt = ""

	for k, v in pairs(vals) do txt = txt .. k .. "=" .. tostring(v) .. " " end

	notify("Values", txt == "" and "empty" or txt)

end) end })

SessionTab:CreateButton({ Name = "Get Overrides", Callback = function() pcall(function()
	local ov = callValue(ClientRuntime.GetOverrides)

	if not ov then notify("Overrides", "Failed"); return end

	local txt = ""

	for k, v in pairs(ov) do txt = txt .. k .. "=" .. tostring(v) .. " " end

	notify("Overrides", txt == "" and "none" or txt)

end) end })

SessionTab:CreateSection("Subscriptions")
SessionTab:CreateButton({ Name = "Watch Combat Reach", Callback = function() pcall(function()
	ClientRuntime.OnChanged("combatReach", function(newVal) State.combatReach = newVal; pcall(updateUi) end)
	notify("Subscribe", "Watching combatReach")

end) end })

SessionTab:CreateButton({ Name = "Watch Block Reach", Callback = function() pcall(function()
	ClientRuntime.OnChanged("blockReach", function(newVal) State.blockReach = newVal; pcall(updateUi) end)
	notify("Subscribe", "Watching blockReach")

end) end })

SessionTab:CreateSection("Cleanup")
SessionTab:CreateButton({ Name = "Reset Counters", Callback = function() State.packets=0; State.errors=0; State.lastAck="none" end })
SessionTab:CreateButton({ Name = "Destroy All ESP", Callback = function() clearAllESP(); State.espEnabled=false end })
SessionTab:CreateButton({ Name = "Stop All Combat", Callback = function()
	State.killAura=false; State.autoAttack=false; State.aimlock=false; State.aimlockActive=false; State.triggerBot=false; State.criticals=false; State.antiKB=false
	killAuraToken+=1; autoAttackToken+=1; triggerBotToken+=1
	killAuraThread=nil; autoAttackThread=nil; triggerBotThread=nil; currentAimlockTarget=nil

	if killAuraVisualPart then pcall(function() killAuraVisualPart:Destroy() end); killAuraVisualPart=nil end
end })

SessionTab:CreateButton({ Name = "Stop All World", Callback = function()
	State.nuker=false; State.scaffold=false; State.tower=false; State.autoBridge=false
	nukerToken+=1; scaffoldToken+=1; towerToken+=1; autoBridgeToken+=1
	nukerThread=nil; scaffoldThread=nil; towerThread=nil; autoBridgeThread=nil
end })

SessionTab:CreateButton({ Name = "Stop All Movement", Callback = function()
	State.fly=false; State.noclip=false; State.velocityEnabled=false; State.infiniteJump=false
	State.stepEnabled=false; State.spider=false; State.longJump=false; State.autoWalk=false; State.freecam=false

	pcall(stopFly); pcall(stopFreecam)

	if LocalPlayer.Character then local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=16; h.JumpPower=50; h.HipHeight=0 end end
end })

SessionTab:CreateButton({ Name = "PANIC / Full Reset", Callback = function() pcall(doPanic) end })

pcall(updateUi)

local CONFIG_FOLDER = "LunaClient"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"
local CONFIG_AUTO_SAVE_INTERVAL = 30
local SAVEABLE_KEYS = {
	"autoAttackCPS", "killAuraRange", "killAuraCPS", "killAuraMulti",
	"killAuraTeamCheck", "killAuraShowRange", "killAuraNPCs", "killAuraPlayers",
	"triggerBotCPS", "triggerBotRange", "criticals", "antiKB", "antiKBPercent",
	"combatReach", "blockReach", "aimlock", "aimlockFOV", "aimlockSmoothing",
	"aimlockPart", "aimlockTeamCheck", "aimlockNPCs", "aimlockShowFOV",
	"nukerCPS", "nukerRange", "scaffoldCPS", "scaffoldBlock",
	"towerCPS", "towerBlock", "autoBridgeCPS", "autoBridgeBlock",
	"velocityWalkSpeed", "velocityJumpPower", "flySpeed",
	"stepHeight", "spiderSpeed", "longJumpBoost",
	"freecamSpeed", "fovValue", "antiKick",
	"espHighlight", "espNames", "espHealth", "espDistance", "espTracers",
	"espTeamCheck", "espNPCs", "espFillTransparency", "espOutlineTransparency",
}
saveConfig = function()
	pcall(function()
		if typeof(writefile) ~= "function" or typeof(isfile) ~= "function" or typeof(makefolder) ~= "function" then return end
		if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end

		local data = {}

		for _, key in ipairs(SAVEABLE_KEYS) do
			local val = State[key]

			if val ~= nil then
				if typeof(val) == "Color3" then
					data[key] = { _type = "Color3", r = math.floor(val.R * 255), g = math.floor(val.G * 255), b = math.floor(val.B * 255) }
				else
					data[key] = val
				end
			end
		end

		local HttpService = game:GetService("HttpService")

		writefile(CONFIG_FILE, HttpService:JSONEncode(data))

		lastConfigSave = os.clock()
	end)
end

loadConfig = function()
	pcall(function()
		if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then return end
		if not isfile(CONFIG_FILE) then return end

		local HttpService = game:GetService("HttpService")
		local raw = readfile(CONFIG_FILE)
		local data = HttpService:JSONDecode(raw)

		if type(data) ~= "table" then return end
		for _, key in ipairs(SAVEABLE_KEYS) do
			local val = data[key]

			if val ~= nil then
				if type(val) == "table" and val._type == "Color3" then
					State[key] = Color3.fromRGB(val.r or 255, val.g or 255, val.b or 255)
				else
					State[key] = val
				end
			end
		end

		notify("Config", "Settings loaded")
	end)
end

pcall(loadConfig)

task.spawn(function()
	while true do
		task.wait(CONFIG_AUTO_SAVE_INTERVAL)

		pcall(saveConfig)
	end
end)

local luaOk, bridgeAvailable = safeBridgeCall(ClientRuntime.IsBridgeAvailable)

if luaOk and bridgeAvailable then
	notify("LunaClient", "Bridge available")

else
	local initOk, initResult = safeBridgeCall(ClientRuntime.Init)

	if initOk and initResult then
		notify("LunaClient", "Bridge initialized")

	else
		notify("LunaClient", "Bridge init failed")
	end
end
end)
