--//SERVICES//--
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--//VARIABLES//--
local local_player = Players.LocalPlayer
local default_volume = 0.05
local SoundToBeChanged = nil
local default_music = "rbxassetid://1841140365" --the default soundtrack that will play when the player isn't in any area
local area_music = { --insert here the music for each area. Important for the keys to be have the same name as the workspace parts
	["Area_1"] = "rbxassetid://1836175982",
	["Area_2"] = "rbxassetid://9042751141",
	["Area_3"] = "rbxassetid://131746159753220"
}
local amountOfAreas = 3 --¡¡¡VERY IMPORTANT!!! Have to change the number of areas there are if you add or remove an area

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local touchedAreas = {}

--//FUNCTIONS//--
local function loadSound()
	local sound = Instance.new("Sound")
	sound.Parent = SoundService
	sound.Volume = default_volume
	sound.Looped = true
	sound.Playing = false
end

local function playMusic(sound : Sound, songId)
	if songId ~= SoundToBeChanged then
		SoundToBeChanged = songId
		
		local tween = TweenService:Create(sound, tweenInfo, {Volume = 0})
		tween:Play()
		tween.Completed:Wait()
		sound.SoundId = SoundToBeChanged
		sound.TimePosition = 0
		sound.Playing = true
		local tween = TweenService:Create(sound, tweenInfo, {Volume = default_volume})
		tween:Play()
	end
end

--Returns the closest part to the local player
--Areas (Array) : A list of all parts to check
local function getClosestArea(Areas)
	local closestArea = nil
	local closestDist = math.huge
	local player_rootPart = local_player.Character:WaitForChild("HumanoidRootPart")
	for _, i in Areas do
		local distance = (player_rootPart.Position - i.Position).Magnitude
		if distance < closestDist then
			closestDist = distance
			closestArea = i
		end
	end
	
	return closestArea
end

--inserts the function to check if the part is touched
--Areas (Array) : A list of all parts to check
local function insertTouchFunction(Areas)
	for _, area in pairs(Areas) do
		area.Touched:Connect(function(otherPart)
			local player = Players:GetPlayerFromCharacter(otherPart.Parent)
			if player and player.Character:FindFirstChild("HumanoidRootPart") then
				table.insert(touchedAreas, area)
			end
		end)
		area.TouchEnded:Connect(function(otherPart)
			local player = Players:GetPlayerFromCharacter(otherPart.Parent)
			if player and player.Character:FindFirstChild("HumanoidRootPart") then
				for j = #touchedAreas, 1, -1 do
					if touchedAreas[j] == area then
						table.remove(touchedAreas, j)
						break
					end
				end
			end
		end)
	end
end

function waitForAreaParts(folder, amountOfParts)
	while #folder:GetChildren() ~= amountOfParts do
		task.wait(0.1)
	end
end

function loadCorrespondingMusic(touchedAreas)
	local musicId = nil
	if #touchedAreas >= 1 then
		musicId = area_music[getClosestArea(touchedAreas).Name]
	else
		musicId = default_music
	end
	
	local isCorrespondingTrackPlaying = false
	for _, i in pairs(SoundService:GetChildren()) do
		if i:IsA("Sound") and i.SoundId ~= musicId then
			playMusic(i, musicId)
			break
		end
	end
end

--//RUN FUNCTIONS//--
loadSound()
waitForAreaParts(game.Workspace.SoundAreas, amountOfAreas)
insertTouchFunction(game.Workspace.SoundAreas:GetChildren())


--//RUN SERVICE//--
RunService.RenderStepped:Connect(function()
	loadCorrespondingMusic(touchedAreas)
end)
