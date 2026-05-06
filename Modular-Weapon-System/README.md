# Modular weapon system
A third person style weapon system, focused on scalability, performace and separation of functions. The core of the system is a runtime based architecture, in which each weapon gets a dedicated runtime instance, containing all the weapon's information and behaviour such as firing logic, reloading and state changes without relying on other scripts. 
The system is composed of multiple specialized modules such as:    
- Runtime core and methods  
- Raycasting Module  
- Utility systems  
- Visual modules  
- Effect system (visuals, audio and animations)  
- Configuration modules, exclusive to each weapon  

The system supports multiple firemodes (semi, burst and auto), real time aim updating and client side visuals prediction, while maintaining the server's authority when it comes to critical calculations, blocking off the possibility of exploits based on system manipulation.


Next the main focus points will be shown and explained
## Runtime firing logic
Handles the validation, state updates and passes on the behaviour to the dedicated modules.

```lua
function RuntimeMethods:_fire(data)
	if self.Ammo <= 0 then
    self:_dryFire()
    return
  end
	if not self:_canFire() then return end
	
	if self.IsSprinting then
    self:_setWalking()
  end
	
	self.LastShot = os.clock()
	self.Ammo -= 1
  self.AnimState = "Fire"

	game.ReplicatedStorage.ARSENAL_ENGINE.WeaponStateEvent:FireClient(self.Player, {
		action = "AmmoUpdate",
		ammo = self.Ammo
	})
	
	local behaviour = self.Behaviour
	if behaviour then
		local shotData = behaviour:Fire(self, data)
		
		return shotData
	else
		warn("Behaviour not found")
	end
end
```

### Key characteristics
- A centralized firing validation and state control
- Moves on weapon specific logic through behaviour modules
- Synchronyzes state to client without trusting client input

## Predicted and replicated effect handling
Separates immediate client side effects from server replicated effects to avoid duplication and maintain responsiveness.

```lua

-- Server replication handler
EffectEvent.OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" then return end
	
	-- Identify if this event belongs to the local player
	data.isLocal = (data.player == player)
	
	EffectsController:HandleEffect(data)
end)

-- EffectController Module
function EffectController:HandleEffect(data)
	if not data or not data.config then return end

  -- Skip replicated effects for the local player
  -- (already handled through client side prediction)
	if data.isLocal then return end
	
	if data.action == "Equip" then
		self.AnimationController:CreateTracks(data)
		self.AnimationController:BindMovement(data)
	elseif data.action == "Unequip" then
		self.AnimationController:RemoveTracks(data)
	end

  -- Animations
	if data.config and data.config.Animations then
		self:_HandleAnimation(data)
	end
	
	-- Visual effects
	local visual = self.VisualRegistry:GetVisual(data.config.VisualsModuleName)
	if visual then
		if data.action == "Fire" then
			visual:Render(data.origin, data.hitPosition, data.config)
		end
  end

  -- Audio handling
	if data.config and data.config.SoundEffects then
		self:_HandleAudio(data)
	end
end
```

### Key characteristics
- Local player handles effects instantly through prediction
- Server replicates effects to all other clients after verification
- Local player ignores replicated events to prevent duplication
- Keeps responsiveness without sacrificing the server's authority
