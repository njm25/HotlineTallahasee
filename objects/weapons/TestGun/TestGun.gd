extends 'res://objects/weapons/Weapon.gd'
class_name TestGun

func _init() -> void:
	has_projectile = true
	
	projectile_spawn_offset = Vector2(26, 12)
	speed = 800
	fire_rate = 0.01
	is_continuous = true
	
	max_bounces = 0
	reload_time = 2
	has_recoil = false
	ammo_capacity = 99999
	current_ammo = 99999
	
	damage = 100
	#burst_fire =  true
	#burst_shot_delay = 0.00001
	#burst_delay = 0.9
	#burst_count = 8
	
	super._init()
	
func shoot(player: PlayerController, mouse_pos: Vector2):
	# Call the base weapon shoot method
	super.shoot(player, mouse_pos)

	# Add any Pistol-specific shoot logic here if needed
	# For example, different behavior for specific projectiles, sound effects, etc.

func get_gun_type():
	return "TestGun"
