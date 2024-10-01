extends Enemy
class_name GromlinController

# Gremlin-specific variables set in _init
func _init():
	run_speed = 60.0  # Gremlin-specific roam speed
	roam_speed = 40.0
	turn_speed = 6.0  # Gremlin-specific turn speed
	roam_turn_speed = 3.0  # Gremlin-specific roam turn speed
	friction = 0.2  # Gremlin-specific friction
	health = 100
	player_damage = 50
	shoots_projectile = false
	# You can call the parent constructor if any initialization logic is added later
	super._init()
