extends Enemy
class_name ManglerController

# Mangler-specific variables set in _init
func _init():
	enemy_type = "Mangler"
	run_speed = 180.0  # Mangler-specific high roam speed
	roam_speed = 150.0  # Mangler's quick movement speed when not alerted
	turn_speed = 10.0  # Mangler-specific high turn speed
	roam_turn_speed = 8.0  # Faster turn speed for better agility
	friction = 0.1  # Lower friction for smoother, quicker movements
	health = 50  # Lower health for the Mangler to balance its speed
	player_damage = 25  # Lower damage than Gremlin, but can be adjusted
	can_melee = true
	shoots_projectile = false
	# You can call the parent constructor if any initialization logic is added later
	super._init()
