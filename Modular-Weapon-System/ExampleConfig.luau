return {
	WeaponName = "M4A1",
	ToolName = "M4A1_Gun",
	ViewportModelName = "M4A1_Gun", -- used to display the weapon model in UI

	-- Core gameplay tuning
	BaseStats = {
		Damage = 20,
		HeadMultiplier = 1.5,
		LimbMultiplier = 0.75,

		Firerate = 600, -- RPM
		MagazineSize = 50,
		ReloadTime = 2
	},

	-- Movement modifiers applied while weapon is equipped
	MovementStats = {
		WalkingSpeed = 16,
		CrouchingSpeed = 10,
		SprintingSpeed = 24
	},

	-- Behaviour module selection
	Behaviour = "Rayshot",
	BehaviourStats = {
		Spread = 0
	},

	-- Fire mode
	FireMode = "Auto",

	-- Visual system config
	VisualsModuleName = "Laser",
	VisualsConfig = {
		Width = 0.08,
		Color = Color3.new(0, 0.65098, 1)
	},

	-- Animations used by runtime animation controller
	Animations = {
		Equip = {AnimationId = "...", Speed = 1},
		Idle = {AnimationId = "...", Speed = 1},
		Walk = {AnimationId = "...", Speed = 1},
		Sprint = {AnimationId = "...", Speed = 1},
		CrouchIdle = {AnimationId = "...", Speed = 1},
		CrouchWalk = {AnimationId = "...", Speed = 1},
		Fire = {AnimationId = "...", Speed = 1},
		Reload = {AnimationId = "...", Speed = 1.6}
	},

	-- Audio effects (handled by effect controller)
	SoundEffects = {
		Fire = "...",
		Reload = "..."
	}
}
