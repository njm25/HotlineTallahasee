extends RigidBody2D

class_name GremlinController

enum EnemyState { UNALERT, ALERT }  # Define two modes
var current_state = EnemyState.UNALERT  # Start in unalert mode

var player_in_area = null  # Variable to hold reference to the player
@export var turn_speed = 5.0  # Adjust this value to change how quickly the enemy turns in alert mode
@export var roam_turn_speed = 2.0  # Adjust how quickly the enemy turns while roaming
@export var roam_speed = 50.0  # Reduced speed while roaming
@export var friction = 0.1  
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

@export var roam_radius = 500.0  # Radius within which the enemy roams
@export var roam_wait_time = 2.0  # Time to wait between random roams
var roam_timer = 0.0
var target_position: Vector2  # Target position for roaming

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Apply friction to the linear and angular velocity
	state.linear_velocity *= friction
	state.angular_velocity *= friction

func _ready():
	var area = get_node("Area2D")
	area.connect("body_entered", self._on_area_body_entered)
	area.connect("body_exited", self._on_area_body_exited)
	choose_random_roam_target()

func _on_area_body_entered(body):
	if body is PlayerController:
		player_in_area = body  # Store the player reference
		current_state = EnemyState.ALERT  # Switch to alert mode

func _on_area_body_exited(body):
	if body is PlayerController:
		player_in_area = null  # Clear the player reference when they exit the area
		current_state = EnemyState.UNALERT  # Switch back to unalert mode
		choose_random_roam_target()  # Start roaming again

func _physics_process(delta):
	match current_state:
		EnemyState.ALERT:
			if player_in_area:
				# Rotate towards the player and stop moving
				var direction = (player_in_area.global_position - global_position).normalized()
				var target_angle = direction.angle()
				rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
				# No movement in alert mode, only rotation
		EnemyState.UNALERT:
			handle_roaming(delta)

func choose_random_roam_target():
	# Generate a random point within the roam_radius
	while true:
		var random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * roam_radius
		var potential_target = global_position + random_offset
		
		# Set the generated point as the target for the NavigationAgent2D
		navigation_agent.target_position = potential_target
		break

func handle_roaming(delta):
	if navigation_agent.is_navigation_finished():
		# If the navigation is done, wait for some time, then pick a new target
		roam_timer -= delta
		if roam_timer <= 0.0:
			roam_timer = roam_wait_time
			choose_random_roam_target()
	else:
		# Calculate the force to apply towards the target using the navigation agent
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		
		# Apply the force to move the enemy at a slower speed while roaming
		var force = direction * roam_speed
		apply_central_impulse(force)

		# Make the enemy face the direction it is moving
		var target_angle = direction.angle()
		rotation = lerp_angle(rotation, target_angle, roam_turn_speed * delta)
