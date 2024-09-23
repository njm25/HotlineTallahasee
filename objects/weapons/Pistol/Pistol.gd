extends 'res://objects/weapons/Weapon.gd'
class_name Pistol

func _init() -> void:
	has_recoil = true
	has_projectile = true
	recoil_force = 50.0  # Specific recoil force for the Pistol
	speed = 800
	
	  # Specific speed for the Pistol projectile
	super._init()  # Call parent _init()

func shoot(player: PlayerController, mouse_pos: Vector2):
	# Call the base weapon shoot method
	super.shoot(player, mouse_pos)

	# Add any Pistol-specific shoot logic here if needed
	# For example, different behavior for specific projectiles, sound effects, etc.

func get_gun_type():
	return "Pistol"
