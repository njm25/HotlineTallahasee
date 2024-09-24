
class_name	PlayerController extends CharacterBody2D


@export var speed = 500
@export var sprint_speed = 500
@export var sneak_speed = 150  # Reduced speed when sneaking
@export var default_friction = 0.1  # Default friction
@export var acceleration = 0.1
@export var sliding_acceleration = 0.05  # Slower acceleration while sliding
@export var sliding_deceleration = 0.005  # Slower deceleration while sliding
@export var push_force = 80
@export var no_friction = 0.2  # No friction when sneaking
@export var dash_speed = 800  # Speed during dash
@export var dash_duration = 0.3  # Duration of the dash
@export var dash_friction = 0.05  # Friction during dash
@export var dash_cooldown = 1.25  # Cooldown time in seconds before dashing again

var is_sliding = false  # New sliding flag variable
var is_dashing = false
var dash_timer = 0.0
var dash_direction = Vector2.ZERO  # Direction for the dash
var current_friction = default_friction  # To keep track of the current friction
var cooldown_timer = 0.0  # Timer to track dash cooldown


# Modifiers for stacking
var speed_modifiers: Array = []
var friction_modifiers: Array = []

var default_values := {}
var modified_flags := {}

func apply_modifier(modifier: Modifier):
	# Apply additive modifiers dynamically
	for key in modifier.add.keys():
		# Initialize the flag if it doesn't exist
		if not modified_flags.has(key):
			modified_flags[key] = false

		# Store default value before modifying only if it hasn't been modified yet
		if not modified_flags[key]:
			default_values[key] = get(key)
			modified_flags[key] = true  # Mark this key as modified

		# Apply additive modifier
		if has_meta(key):
			set(key, get(key) + modifier.add[key])

	# Apply multiplicative modifiers dynamically
	for key in modifier.multiply.keys():
		# Initialize the flag if it doesn't exist
		if not modified_flags.has(key):
			modified_flags[key] = false

		# Store default value before modifying only if it hasn't been modified yet
		if not modified_flags[key]:
			default_values[key] = get(key)
			modified_flags[key] = true  # Mark this key as modified

		# Apply multiplicative modifier
		if has_meta(key):
			set(key, get(key) * modifier.multiply[key])

func restore_defaults():
	# Restore all variables to their stored defaults
	for key in default_values.keys():
		if has_meta(key):
			set(key, default_values[key])
			# Reset the modification flag so future modifications can work correctly
			modified_flags[key] = false
	# Recalculate final speed and friction if needed
func get_input():
	var input = Vector2()
	var current_speed = speed  # Default walking speed
	
	if Input.is_action_just_pressed('nextweapon'):
		get_node("PlayerInventory").next_weapon()

	if Input.is_action_just_pressed('prevweapon'):
		get_node("PlayerInventory").prev_weapon()
	
	var current_weapon = get_node("PlayerInventory").current_weapon
	
	var mouse_global_pos = get_global_mouse_position()
	if current_weapon is Weapon:
		if current_weapon.is_continuous:
			if Input.is_action_pressed('shoot'):
				current_weapon.shoot_with_fire_rate(self, mouse_global_pos)
		else:
			if Input.is_action_just_pressed('shoot'):
				current_weapon.shoot_with_fire_rate(self, mouse_global_pos)

			
		
	# Check for sprinting (cannot sprint and sneak at the same time)
	if Input.is_action_pressed('run') and not Input.is_action_pressed('sneak'):
		current_speed = sprint_speed
	# Check for sneaking
	elif Input.is_action_pressed('sneak'):
		current_speed = sneak_speed
	
	# Get directional input
	if Input.is_action_pressed('ui_right'):
		input.x += 1
	if Input.is_action_pressed('ui_left'):
		input.x -= 1
	if Input.is_action_pressed('ui_down'):
		input.y += 1
	if Input.is_action_pressed('ui_up'):
		input.y -= 1
	if Input.is_action_just_pressed('reload'):
		get_node("PlayerInventory").current_weapon.reload(self)
	
	return input.normalized() * current_speed

func _process(delta):
	look_at(get_global_mouse_position())

	# Update the dash cooldown timer
	if cooldown_timer > 0:
		cooldown_timer -= delta

func _physics_process(delta):
	# Handle dashing logic
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			# Only reset friction to default if not sliding
			if not is_sliding:
				current_friction = default_friction
		else:
			velocity = dash_direction * dash_speed  # Move in dash direction
			move_and_slide()  # Continue dash movement
		return  # Skip further movement logic during dash

	var direction = get_input()

	# If sneaking, override friction to no friction
	if Input.is_action_pressed('sneak'):
		current_friction = no_friction

	# Modify acceleration and deceleration behavior if sliding
	if is_sliding:
		# Slower control while sliding
		if direction.length() > 0:
			velocity = velocity.lerp(direction, sliding_acceleration)  # Reduced acceleration
		else:
			# Slower deceleration (inertia when no input)
			velocity = velocity.lerp(Vector2.ZERO, sliding_deceleration)
	else:
		# Regular behavior when not sliding
		if direction.length() > 0:
			velocity = velocity.lerp(direction, acceleration)
		else:
			velocity = velocity.lerp(Vector2.ZERO, current_friction)

	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

# New function to handle dash input and logic
func _input(event):
	# Only dash if the cooldown has finished and the player is not already dashing
	if event.is_action_pressed('dash') and not is_dashing and (cooldown_timer <= 0 || cooldown_timer == TYPE_NIL):
		is_dashing = true
		dash_timer = dash_duration
		cooldown_timer = dash_cooldown  # Start the cooldown timer

		# Only apply dash friction if the player is not sliding
		if not is_sliding:
			current_friction = dash_friction  # Temporarily reduce friction during dash
		
		# Calculate dash direction based on the mouse position
		dash_direction = (get_global_mouse_position() - global_position).normalized()
		
		velocity = dash_direction * dash_speed  # Apply dash in mouse direction
