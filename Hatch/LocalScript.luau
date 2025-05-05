--//SERVICES//--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--//VARIABLES//--
local remoteEvent = ReplicatedStorage.toggleHatch
local local_player = Players.LocalPlayer
local control_gui = local_player.PlayerGui.hatch_control

--//EVENT LISTENERS//--
remoteEvent.OnClientEvent:Connect(function(text)
	control_gui.TextLabel.Text = "Hatch status: " .. text
end)

control_gui.TextButton.MouseButton1Click:Connect(function()
	remoteEvent:FireServer()
end)

RunService.RenderStepped:Connect(function()
	if local_player.Character:FindFirstChild("Hatch Control") then
		control_gui.Enabled = true
	else
		control_gui.Enabled = false
	end
end)
