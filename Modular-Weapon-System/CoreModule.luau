local WeaponSystem = {}

-- Stores registered weapon configs
WeaponSystem.Registry = {
	Weapons = {}
}

-- Behaviour modules (different firing logic)
WeaponSystem.Behaviours = {}

-- Runtime instances per player
WeaponSystem.Runtimes = {}

-- Currently equipped weapon per player
WeaponSystem.ActiveRuntime = {}

local RuntimeMethods = require(script.Parent["Runtime Methods [MODULE]"])

-----------------------------------------------------------------------------
-- REGISTRY
-----------------------------------------------------------------------------

function WeaponSystem.Registry:Register(config)
	-- Registers weapon configuration (data-driven design)
	self.Weapons[config.WeaponName] = config
end

function WeaponSystem.Registry:GetConfig(weaponName)
	return self.Weapons[weaponName]
end

-----------------------------------------------------------------------------
-- BEHAVIOURS
-----------------------------------------------------------------------------

function WeaponSystem:RegisterBehaviour(name, module)
	-- Allows different weapons to define custom behavior
	self.Behaviours[name] = module
end

-----------------------------------------------------------------------------
-- RUNTIME CREATION
-----------------------------------------------------------------------------

function WeaponSystem:CreateRuntime(weaponName, player, tool)
	local config = self.Registry:GetConfig(weaponName)
	if not config or not tool then
		error("Invalid runtime creation: " .. tostring(weaponName))
	end
	
	-- Ensure per-player runtime container
	self.Runtimes[player] = self.Runtimes[player] or {}
	
	-- Reuse runtime if it already exists
	if self.Runtimes[player][weaponName] then
		return self.Runtimes[player][weaponName]
	end
	
	-- Runtime = state + behaviour of a weapon
	local runtime = {
		Player = player,
		Tool = tool,
		Config = config,
		
		-- State
		Ammo = config.BaseStats.MagazineSize,
		LastShot = 0,
		Reloading = false,
		Equipped = false,
		
		-- Behaviour injection
		Behaviour = WeaponSystem.Behaviours[config.Behaviour],
		
		-- Movement / state flags
		IsSprinting = false,
		IsFiring = false,
		
		AnimState = nil
	}
	
	-- Attach shared runtime methods (acts like a class)
	setmetatable(runtime, {__index = RuntimeMethods})
	
	self.Runtimes[player][weaponName] = runtime
	
	return runtime
end

-----------------------------------------------------------------------------
-- RUNTIME MANAGEMENT
-----------------------------------------------------------------------------

function WeaponSystem:GetRuntime(player, weaponName)
	return self.Runtimes[player] and self.Runtimes[player][weaponName]
end

function WeaponSystem:RemoveRuntime(player, weaponName)
	if not self.Runtimes[player] then return end
	
	self.Runtimes[player][weaponName] = nil
	
	-- Cleanup empty player table
	if next(self.Runtimes[player]) == nil then
		self.Runtimes[player] = nil
	end
	
	-- Clear active weapon if needed
	if self.ActiveRuntime[player] == weaponName then
		self.ActiveRuntime[player] = nil
	end
end

-----------------------------------------------------------------------------
-- ACTIVE WEAPON CONTROL
-----------------------------------------------------------------------------

function WeaponSystem:SetActiveWeapon(player, weaponName)
	local runtime = self:GetRuntime(player, weaponName)
	if not runtime then return end
	
	-- Unequip current weapon
	local current = self.ActiveRuntime[player]
	if current then
		local currentRuntime = self:GetRuntime(player, current)
		if currentRuntime then
			currentRuntime:Unequip()
		end
	end
	
	-- Equip new weapon
	self.ActiveRuntime[player] = weaponName
	runtime:Equip()
end

-----------------------------------------------------------------------------
-- WEAPON INSTANCE CREATION
-----------------------------------------------------------------------------

function WeaponSystem:CreateWeaponInstance(weaponName, player)
	local config = self.Registry:GetConfig(weaponName)
	if not config then return end
	
	-- Clone tool (details removed for clarity)
	local tool = Instance.new("Tool")
	
	-- Create runtime tied to this tool
	local runtime = self:CreateRuntime(weaponName, player, tool)
	
	return tool, runtime
end

return WeaponSystem
