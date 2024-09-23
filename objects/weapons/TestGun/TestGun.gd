extends 'res://objects/weapons/Weapon.gd'
class_name TestGun

func _init() -> void:
	has_projectile = true
	speed = 10000
	
	
	super._init()
	
func shoot(player: PlayerController, mouse_pos: Vector2):
	# Call the base weapon shoot method
	super.shoot(player, mouse_pos)

	# Add any Pistol-specific shoot logic here if needed
	# For example, different behavior for specific projectiles, sound effects, etc.

func get_gun_type():
	return "TestGun"
