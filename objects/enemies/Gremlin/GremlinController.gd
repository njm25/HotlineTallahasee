extends Enemy
class_name GremlinController

# Gremlin-specific variables set in _init
func _init():
	run_speed = 60.0  # Gremlin-specific roam speed
	roam_speed = 40.0
	turn_speed = 6.0  # Gremlin-specific turn speed
	roam_turn_speed = 3.0  # Gremlin-specific roam turn speed
	friction = 0.2  # Gremlin-specific friction
	health = 100
	player_damage = 50

	# You can call the parent constructor if any initialization logic is added later
	super._init()


func _on_area_body_exited(body):
	pass

# Override the handle_attacking function to use pathfinding
func handle_attacking(delta):
	if player_in_area:
		# Set the player's position as the target for the NavigationAgent2D
		navigation_agent.target_position = player_in_area.global_position
		
		# Check if navigation is finished
		if not navigation_agent.is_navigation_finished():
			# Move toward the next path position
			var next_position = navigation_agent.get_next_path_position()
			var direction = (next_position - global_position).normalized()
			
			# Apply force to move towards the next path position
			var force = direction * run_speed
			apply_central_impulse(force)
			
			# Rotate to face the direction of movement
			var target_angle = direction.angle()
			rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
