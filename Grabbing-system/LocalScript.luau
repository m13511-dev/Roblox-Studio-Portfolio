--// SERVICES //--
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// VARIABLES //--
local player: Player = script.Parent.Parent
local cam_update = ReplicatedStorage:WaitForChild("cam_update")
local remote_input = ReplicatedStorage:WaitForChild("remote_input")
local player_cam = WS.CurrentCamera

local grab_key = Enum.KeyCode.E
local distance = 6

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

--// FUNCTIONS //--
local function raycast()
	raycastParams.FilterDescendantsInstances = {player.Character or {}}

	local start = player_cam.CFrame.Position
	local direction = player_cam.CFrame.LookVector * 10

	return WS:Raycast(start, direction, raycastParams)
end

--// EVENT LISTENERS //--
UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == grab_key then
		local target = raycast()
		remote_input:FireServer(true, target and target.Instance or nil)
	end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == grab_key then
		remote_input:FireServer(false, nil)
	end
end)

RS.RenderStepped:Connect(function()
	local camCFrame = player_cam.CFrame
	cam_update:FireServer(camCFrame.Position + camCFrame.LookVector * distance)
end)
