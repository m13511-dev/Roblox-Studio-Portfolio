local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote_input = ReplicatedStorage:WaitForChild("remote_input")
local cam_update = ReplicatedStorage:WaitForChild("cam_update")

local maxForce = 50
local targetPart
local lastTarget

local function highlight(part)
	local highlight = part:FindFirstChild("Highlight") or Instance.new("Highlight")
	highlight.Name = "Highlight"
	highlight.OutlineColor = Color3.fromRGB(26, 125, 255)
	highlight.FillColor = Color3.fromRGB(26, 125, 255)
	highlight.Parent = part
end

local function apply_force(part, target_direction, maxForce)
	local attachment = part:FindFirstChild("Attachment") or Instance.new("Attachment")
	attachment.Name = "Attachment"
	attachment.Parent = part

	local linearVelocity = part:FindFirstChild("LinearVelocity") or Instance.new("LinearVelocity")
	linearVelocity.Name = "LinearVelocity"
	linearVelocity.Attachment0 = attachment
	linearVelocity.MaxForce = math.huge
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.Parent = part

	local displacement = target_direction - part.Position
	local distance = displacement.Magnitude

	if distance > 0 then
		local force = math.min(maxForce, distance * 50)
		linearVelocity.VectorVelocity = displacement.Unit * force
	else
		linearVelocity.VectorVelocity = Vector3.zero
	end
end

remote_input.OnServerEvent:Connect(function(player, grab, targetParts)
	targetPart = grab and targetParts or nil
	if targetParts then
		lastTarget = targetParts
	end
end)

cam_update.OnServerEvent:Connect(function(player, target_direction)
	if targetPart then
		apply_force(targetPart, target_direction, maxForce)
		highlight(targetPart)
	elseif lastTarget then
		for _, name in ipairs({"Attachment", "LinearVelocity", "Highlight"}) do
			local obj = lastTarget:FindFirstChild(name)
			if obj then obj:Destroy() end
		end
	end
end)
