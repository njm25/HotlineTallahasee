extends 'res://objects/weapons/Weapon.gd'
class_name TestGun

func _init() -> void:
	has_projectile = true
	speed = 600
	
	is_continuous = true
	
	max_bounces = 10
	reload_time = 2
	has_recoil = true
	recoil_force = 5
	ammo_capacity = 11
	current_ammo = 11
	burst_fire =  true
	burst_shot_delay = 0.1
	burst_delay = 0.9
	burst_count = 3
	accuracy = 0.1
	super._init()
	
func shoot(player: PlayerController, mouse_pos: Vector2):
	# Call the base weapon shoot method
	super.shoot(player, mouse_pos)

	# Add any Pistol-specific shoot logic here if needed
	# For example, different behavior for specific projectiles, sound effects, etc.

func get_gun_type():
	return "TestGun"
