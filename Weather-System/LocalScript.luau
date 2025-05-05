--// SERVICES //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

--// VARIABLES //--
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local weatherChangeEvent = ReplicatedStorage:WaitForChild("setWeather")
local lightningEvent = ReplicatedStorage:WaitForChild("onLightningEvent")

local rainSound = Instance.new("Sound", SoundService)
rainSound.SoundId = "rbxassetid://1516791621"
rainSound.Volume = 0
rainSound.Looped = true
rainSound.Playing = true

local emitter = Instance.new("Part", workspace)
emitter.Size = Vector3.new(200, 1, 200)
emitter.Transparency = 1
emitter.Anchored = true
emitter.CanCollide = false
emitter.CanQuery = false

local generalEmitter = Instance.new("ParticleEmitter", emitter)
generalEmitter.Texture = "rbxassetid://1822883048"
generalEmitter.Rate = 0
generalEmitter.Transparency = NumberSequence.new(0.6)
generalEmitter.EmissionDirection = Enum.NormalId.Bottom
generalEmitter.Speed = NumberRange.new(75, 100)
generalEmitter.Lifetime = NumberRange.new(2, 2.5)
generalEmitter.VelocityInheritance = 1
generalEmitter.Size = NumberSequence.new(10)

local weatherState = "Other"
local isUnderRoof = false
local currentIntensity = 0
local isTweening = false
local partialEmitters = {}
local region3Offset = 5
local partialEmitterSize = 50
local partialEmitterHeight = 50

local lastCameraPosition = camera.CFrame.Position
local defaultRainVolume = 0.15

--// FUNCTIONS //-- 

local function tweenValue(obj, goal, info)
	local tween = TweenService:Create(obj, info, goal)
	tween:Play()
	return tween
end

local function tweenIntensity(goal)
	if goal == currentIntensity or isTweening then return end

	isTweening = true
	local holder = Instance.new("NumberValue")
	holder.Value = currentIntensity

	holder:GetPropertyChangedSignal("Value"):Connect(function()
		currentIntensity = holder.Value
	end)

	local tween = tweenValue(holder, {Value = goal}, TweenInfo.new(4, Enum.EasingStyle.Circular, Enum.EasingDirection.Out))
	tween.Completed:Wait()
	isTweening = false
end

local function tweenSound(up)
	tweenValue(rainSound, {Volume = up and defaultRainVolume or 0}, TweenInfo.new(4, Enum.EasingStyle.Linear))
end

local function updateEmitters(intensity)
	local camAngle = math.asin(camera.CFrame.LookVector.Y) * (180 / math.pi)

	if camAngle <= 50 and camAngle >= -50 then
		generalEmitter.Texture = "rbxassetid://1822883048"
		generalEmitter.Size = NumberSequence.new(10)
		generalEmitter.Transparency = NumberSequence.new(0.6)
	else
		generalEmitter.Texture = "rbxassetid://1822856633"
		generalEmitter.Size = NumberSequence.new(8)
		generalEmitter.Transparency = NumberSequence.new(0.7)
	end

	if isUnderRoof then
		generalEmitter.Rate = 0
		partialEmitterHeight = 50
		for _, part in ipairs(partialEmitters) do
			local ParticleEmitter = part:FindFirstChildOfClass("ParticleEmitter")
			if ParticleEmitter then
				local area = part.Size.X * part.Size.Z
				ParticleEmitter.Rate = (area * intensity) / (emitter.Size.X * emitter.Size.Z)
			end
		end
	else
		generalEmitter.Rate = intensity
		partialEmitterHeight = -20
		for _, part in ipairs(partialEmitters) do
			local emitter = part:FindFirstChildOfClass("ParticleEmitter")
			if emitter then emitter.Rate = 0 end
		end
	end
end

local function createPartialEmitters()
	for i = 1, 4 do
		local part = Instance.new("Part", workspace)
		part.Name = "PartialEmitter" .. i
		part.Size = Vector3.new(100, 1, 100)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false

		local emitter = generalEmitter:Clone()
		emitter.Rate = 0
		emitter.Parent = part

		table.insert(partialEmitters, part)
	end
end

local function updatePartialEmitters()
	local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local regionSize = Vector3.new(100, 100, 100)
	local regionCenter = root.Position + Vector3.new(0, (regionSize.Y / 2) + region3Offset, 0)
	local region = Region3.new(regionCenter - regionSize / 2, regionCenter + regionSize / 2):ExpandToGrid(4)

	local ignore = {localPlayer.Character, emitter, unpack(partialEmitters)}
	local parts = workspace:FindPartsInRegion3WithIgnoreList(region, ignore, math.huge)

	local minX, minZ, maxX, maxZ = math.huge, math.huge, -math.huge, -math.huge

	for _, p in ipairs(parts) do
		minX = math.min(minX, p.Position.X - p.Size.X / 2)
		minZ = math.min(minZ, p.Position.Z - p.Size.Z / 2)
		maxX = math.max(maxX, p.Position.X + p.Size.X / 2)
		maxZ = math.max(maxZ, p.Position.Z + p.Size.Z / 2)
	end

	local xSize = maxX - minX
	local zSize = maxZ - minZ
	
	partialEmitters[1].Position = Vector3.new(minX + xSize/2, partialEmitterHeight, maxZ + partialEmitterSize/2)
	partialEmitters[2].Position = Vector3.new(minX - partialEmitterSize/2, partialEmitterHeight, minZ + zSize/2)
	partialEmitters[3].Position = Vector3.new(minX + xSize/2, partialEmitterHeight, minZ - partialEmitterSize/2)
	partialEmitters[4].Position = Vector3.new(maxX + partialEmitterSize/2, partialEmitterHeight, minZ + zSize/2)

	partialEmitters[1].Size = Vector3.new(xSize + 2 * partialEmitterSize, 1, partialEmitterSize)
	partialEmitters[2].Size = Vector3.new(partialEmitterSize, 1, zSize)
	partialEmitters[3].Size = Vector3.new(xSize + 2 * partialEmitterSize, 1, partialEmitterSize)
	partialEmitters[4].Size = Vector3.new(partialEmitterSize, 1, zSize)
end

--// STARTUP //--
createPartialEmitters()
coroutine.wrap(function()
	while true do
		wait(1)
		updatePartialEmitters()
	end
end)()

--// MAIN LOOP //--
RunService.RenderStepped:Connect(function(dt)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {localPlayer.Character, emitter, unpack(partialEmitters)}

	local result = workspace:Raycast(camera.CFrame.Position, Vector3.new(0, 300, 0), rayParams)
	isUnderRoof = result and result.Instance or false

	if weatherState == "Rain" then
		if not isTweening then
			task.spawn(tweenIntensity, 78400)
			task.spawn(tweenSound, true)
		end
	elseif weatherState == "Thunderstorm" then
		if not isTweening then
			task.spawn(tweenIntensity, 156800)
			task.spawn(tweenSound, true)
		end
	else
		if not isTweening then
			task.spawn(tweenIntensity, 0)
			task.spawn(tweenSound, false)
		end
	end

	updateEmitters(currentIntensity)
end)

-- Rain follows camera movement + leads ahead
local lastCamPos = camera.CFrame.Position
RunService:BindToRenderStep("RainFollow", 201, function(delta)
	local camPos = camera.CFrame.Position
	local velocity = (camPos - lastCamPos) / delta
	lastCamPos = camPos

	local lookAhead = velocity.Magnitude > 0 and velocity.Unit * math.min(velocity.Magnitude * 0.15, 50) or Vector3.zero
	emitter.Position = camPos + lookAhead + Vector3.new(0, 30, 0)
end)

-- Remote weather updates
weatherChangeEvent.OnClientEvent:Connect(function(state)
	weatherState = (state == "None") and "Other" or state
end)

--thunder sound
lightningEvent.OnClientEvent:Connect(function(impactPos)
	local root = localPlayer.Character:WaitForChild("HumanoidRootPart")
	
	local distance = (impactPos - root.Position).Magnitude
	local timeDelay = distance / 343 --343 is in m/s and speed of sound
	
	local sound = Instance.new("Sound")
	sound.Parent = SoundService
	sound.SoundId = "rbxassetid://1079408535"
	sound.Volume = math.min(5 / distance, 0.1)
	sound.PlayOnRemove = true
	
	task.wait(timeDelay)
	sound:Destroy()
end)
