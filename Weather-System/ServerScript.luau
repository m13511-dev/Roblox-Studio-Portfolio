--// SERVICES //--
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--// VARIABLES //--
local dayWeatherOptions = {"Sunshine", "Light fog", "Heavy fog", "Rain", "Thunderstorm"}
local nightWeatherOptions = {"Sunshine", "Light fog", "Heavy fog", "Rain", "Thunderstorm", "Thunderstorm", "Thunderstorm"} -- higher thunderstorm chance at night
local lastWeatherChange = tick()
local lastThunderbolt = tick()
local nextThunderboltTime = math.random(200, 300) / 10
local weatherChangeInterval = 500 -- seconds between weather updates
local weatherSystemEnabled = true
local weatherState = "Sunshine"
local onWeatherChange = Instance.new("BindableEvent")

local atmosphere = Lighting:WaitForChild("Atmosphere")
local weatherSetEvent = ReplicatedStorage:WaitForChild("setWeather")
local lightningEvent = ReplicatedStorage:WaitForChild("onLightningEvent")
local colorCorrection = Lighting.ColorCorrection

--create the clouds
local clouds = Instance.new("Clouds")
clouds.Parent = workspace.Terrain
clouds.Cover = 0
clouds.Density = 0
clouds.Color = Color3.fromRGB(189, 189, 189)

--// CONSTANTS //--
local atmosphereTweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local cloudsTweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

--// FUNCTIONS //--

-- Utility to tween atmosphere properties
local function changeAtmosphereSettings(density, offset)
	TweenService:Create(atmosphere, atmosphereTweenInfo, {Density = density, Offset = offset}):Play()
end

local function changeCloudSettings(density, cover)
	TweenService:Create(clouds, cloudsTweenInfo, {Density = density, Cover = cover}):Play()
end

local function generateFlash()
	colorCorrection.Brightness = 0.15
	task.wait(0.1)
	colorCorrection.Brightness = 0.05
end

--create a part given 2 Vector3s
function createPartBetween(pointA, pointB)
	local midPoint = (pointA + pointB) / 2
	local distance = (pointA - pointB).Magnitude

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0.3, 0.3, distance)
	part.CFrame = CFrame.lookAt(midPoint, pointB)
	part.Parent = game.Workspace
	
	return part
end

local function generateLightningbolt(startPos : Vector3, endPos : Vector3)
	local interval_length = 20
	local max_offset = 5
	local y_difference = startPos.Y - endPos.Y
	local part_num = math.floor(y_difference / interval_length)
	
	local partList = {}
	local lastPos = startPos
	
	for i = 1, part_num do
		local created_segment
		if i == part_num then
			created_segment = createPartBetween(lastPos, endPos)
		else
			local currentPos = Vector3.new(
				startPos.X + math.random(-max_offset * 10, max_offset * 10) / 10,
				startPos.Y - interval_length * i,
				startPos.Z + math.random(-max_offset * 10, max_offset * 10) / 10)
			created_segment = createPartBetween(lastPos, currentPos)
			lastPos = currentPos
		end
		
		table.insert(partList, created_segment)
		created_segment.Color = Color3.new(1, 0.968627, 0)
		created_segment.Material = Enum.Material.Neon
	end
	
	task.wait(0.25)
	
	for _, part in pairs(partList) do
		part:Destroy()
	end
end

local function create_lightning_thunder()
	if tick() - lastThunderbolt > nextThunderboltTime then
		lastThunderbolt = tick()
		nextThunderboltTime = math.random(200, 300) / 10
		
		local players = Players:GetChildren()
		local random_player = players[math.random(1, #players)]
		local player_root = random_player.Character:WaitForChild("HumanoidRootPart")
		
		local x_pos = math.random(player_root.Position.X - 100, player_root.Position.X + 100)
		local z_pos = math.random(player_root.Position.Z - 100, player_root.Position.Z + 100)
		
		local rayResult = workspace:Raycast(Vector3.new(x_pos, 250, z_pos), Vector3.new(0, -300, 0))
		
		local y_pos		
		if rayResult and rayResult.Instance then
			y_pos = rayResult.Position.Y
		else
			y_pos = 0
		end

		task.spawn(generateFlash)
		lightningEvent:FireAllClients(Vector3.new(x_pos, y_pos, z_pos))
		generateLightningbolt(Vector3.new(x_pos, 250, z_pos), Vector3.new(x_pos, y_pos, z_pos))
	end
end

-- Weather functions
local function setWeather_Sunshine()
	weatherSetEvent:FireAllClients("None")
	changeAtmosphereSettings(0.28, 0)
	changeCloudSettings(0, 0)
end

local function setWeather_LightFog()
	weatherSetEvent:FireAllClients("None")
	changeAtmosphereSettings(0.45, 0.25)
	changeCloudSettings(0.3, 0.6)
end

local function setWeather_HeavyFog()
	weatherSetEvent:FireAllClients("None")
	changeAtmosphereSettings(0.65, 0.25)
	changeCloudSettings(0.3, 0.7)
end

local function setWeather_Rain()
	weatherSetEvent:FireAllClients("Rain")
	changeAtmosphereSettings(0.33, 0.25)
	changeCloudSettings(0.3, 0.8)
end

local function setWeather_Thunderstorm()
	weatherSetEvent:FireAllClients("Thunderstorm")
	changeAtmosphereSettings(0.45, 0.25)
	changeCloudSettings(0.5, 0.95)
	lastThunderbolt = tick()
end

-- Changes the weather to another random one in the array
local function changeWeather()
	local isNight = Lighting.ClockTime < 6 or Lighting.ClockTime > 18
	local options = isNight and nightWeatherOptions or dayWeatherOptions
	weatherState = options[math.random(1, #options)]
	onWeatherChange:Fire()
end

-- Weather loop coroutine
task.spawn(function()
	while true do
		if tick() - lastWeatherChange > weatherChangeInterval then
			lastWeatherChange = tick()
			changeWeather()
		end
		task.wait(0.1)
	end
end)

--// EVENT LISTENERS //--

-- Fire weather state to player on join
Players.PlayerAdded:Connect(function(player)
	weatherSetEvent:FireClient(player, weatherState)
end)

-- React to weather changes
onWeatherChange.Event:Connect(function()
	print("Weather changed to:", weatherState)
	if weatherState == "Sunshine" then
		setWeather_Sunshine()
	elseif weatherState == "Rain" then
		setWeather_Rain()
	elseif weatherState == "Light fog" then
		setWeather_LightFog()
	elseif weatherState == "Heavy fog" then
		setWeather_HeavyFog()
	elseif weatherState == "Thunderstorm" then
		setWeather_Thunderstorm()
	end
end)

-- Manual override
weatherSetEvent.OnServerEvent:Connect(function(player, weather)
	if weather == "Enabled" then
		lastWeatherChange = tick()
		weatherChangeInterval = 500
		weatherSystemEnabled = true
		print("Weather system status: Enabled")
	elseif weather == "Disabled" then
		weatherChangeInterval = math.huge
		weatherState = "Sunshine"
		lastWeatherChange = tick()
		onWeatherChange:Fire()
		weatherSystemEnabled = false
		print("Weather system status: Disabled")
	elseif weatherSystemEnabled == true then
		weatherState = weather
		lastWeatherChange = tick()
		onWeatherChange:Fire()
	end
end)

--//MAIN LOOP//--
RunService.Heartbeat:Connect(function()
	if weatherState == "Thunderstorm" then
		create_lightning_thunder()
	end
end)
