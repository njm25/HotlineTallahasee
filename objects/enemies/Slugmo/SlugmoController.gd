extends Enemy
class_name SlugmoController

# Gremlin-specific variables set in _init
func _init():
	run_speed = 10.0  # Gremlin-specific roam speed
	roam_speed = 8.0
	turn_speed = 2.0  # Gremlin-specific turn speed
	roam_turn_speed = 1.0  # Gremlin-specific roam turn speed
	friction = 0.2  # Gremlin-specific friction
	health = 1000
	is_friendly = true
	# You can call the parent constructor if any initialization logic is added later
	super._init()
