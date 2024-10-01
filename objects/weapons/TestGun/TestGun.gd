extends 'res://objects/weapons/Weapon.gd'
class_name TestGun

func _init() -> void:
	has_projectile = true
	
	projectile_spawn_offset = Vector2(26, 12)
	speed = 300
	fire_rate = 0.01
	is_continuous = true
	
	max_bounces = 0
	reload_time = 2
	has_recoil = false
	recoil_force = 15
	ammo_capacity = 99999
	current_ammo = 99999
	#burst_fire =  true
	#burst_shot_delay = 0.00001
	#burst_delay = 0.9
	#burst_count = 8
	has_bloom = true
	max_bloom = 1
	bloom_reset_time = 0.001
	bloom_increase_rate = 0.01
	bloom_decrease_rate = 0.1
	
	
	spread = 0
	damage = 35
	super._init()
	
func shoot(player: PlayerController, mouse_pos: Vector2):
	# Call the base weapon shoot method
	super.shoot(player, mouse_pos)

	# Add any Pistol-specific shoot logic here if needed
	# For example, different behavior for specific projectiles, sound effects, etc.

func get_gun_type():
	return "TestGun"
