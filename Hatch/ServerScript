--//SERVICES//--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

--//VARIABLES//--
local remoteEvent = ReplicatedStorage.toggleHatch
local hatch_is_open = false
local hatch_is_moving = false
local hatch_status = "closed"
local tweenInfo = TweenInfo.new(15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
local hatch_folder = game.Workspace.Hatch
local hatch_models = { --direction of each part of the hatch. Extremely improtant to set the primary part!
	[game.Workspace.Hatch.Hatch1] = 1,
	[game.Workspace.Hatch.Hatch2] = -1
}

--//FUNCTIONS//--
local function TweenModel(model)
	local 
end

local function on_hatch_toggle()
	if hatch_is_moving == false then
		if hatch_is_open == true then
			local tween
			for _, i in pairs(hatch_folder:GetChildren()) do
				tween = TweenService:Create(i.PrimaryPart, tweenInfo, {CFrame = i.PrimaryPart.CFrame - Vector3.new(i.PrimaryPart.Size.X * hatch_models[i], 0, 0)})
				tween:Play()
				hatch_status = "closing"
				remoteEvent:FireAllClients("closing")
				hatch_is_moving = true
			end
			tween.Completed:Wait()
			hatch_status = "closed"
			remoteEvent:FireAllClients("closed")
			hatch_is_moving = false
		else
			local tween
			for _, i in pairs(hatch_folder:GetChildren()) do
				tween = TweenService:Create(i.PrimaryPart, tweenInfo, {CFrame = i.PrimaryPart.CFrame + Vector3.new(i.PrimaryPart.Size.X * hatch_models[i], 0, 0)})
				tween:Play()
				hatch_status = "opening"
				remoteEvent:FireAllClients("opening")
				hatch_is_moving = true
			end
			tween.Completed:Wait()
			hatch_status = "open"
			remoteEvent:FireAllClients("open")
			hatch_is_moving = false
		end
		
		hatch_is_open = not hatch_is_open
	end
end

--//EVENT LISTENERS//--
--listen for when the player activates the hatch. Currently no limitation for players that can open the hatch
remoteEvent.OnServerEvent:Connect(function()
	task.spawn(on_hatch_toggle)
end)

Players.PlayerAdded:Connect(function(player)
	remoteEvent:FireClient(player, hatch_status)
end)
