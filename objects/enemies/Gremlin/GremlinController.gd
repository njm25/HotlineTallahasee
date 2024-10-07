extends Enemy
class_name GremlinController

# Gremlin-specific variables set in _init
func _init():
	enemy_type = "Gremlin"
	run_speed = 10.0  # Gremlin-specific roam speed
	roam_speed = 100.0
	turn_speed = 6.0  # Gremlin-specific turn speed
	roam_turn_speed = 3.0  # Gremlin-specific roam turn speed
	friction = 0.2  # Gremlin-specific friction
	health = 100
	player_damage = 50
	can_melee = true
	shoots_projectile = false
	penetratable=true
	# You can call the parent constructor if any initialization logic is added later
	super._init()
