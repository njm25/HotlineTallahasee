class_name	PlayerController extends CharacterBody2D

@export var speed = 400
@export var sprint_speed = 400
@export var sneak_speed = 150
@export var default_friction = 0.1
@export var sliding_friction = 0.01
@export var push_force = 80
@export var no_friction = 0.2
@export var dash_speed = 800
@export var dash_duration = 0.3
@export var dash_friction = 0.05
@export var dash_cooldown = 1.25
@export var health = 100

var is_sliding = false
var is_dashing = false
var dash_timer = 0.0
var dash_direction = Vector2.ZERO
var cooldown_timer = 0.0

var target_speed = speed
var current_speed = 0.0
var target_friction = default_friction
var current_friction = default_friction
var current_dash_speed = 0.0

# Modifiers for stacking
var speed_modifiers: Array = []
var friction_modifiers: Array = []

var default_values := {}
var modified_flags := {}
var applied_modifiers := []

func damage(amount: int):
	health -= amount
	if health <= 0:
		kill()

func heal(amount: int):
	health += amount

func kill():
	queue_free()

func apply_modifier(modifier: Modifier):
	# Store the modifier
	applied_modifiers.append({
		"add": modifier.add.duplicate(),
		"multiply": modifier.multiply.duplicate()
	})
	
	# Apply additive modifiers
	for key in modifier.add.keys():
		if not default_values.has(key):
			default_values[key] = get(key)  # Store the original value
		var old_value = get(key)
		set(key, old_value + modifier.add[key])
	
	# Apply multiplicative modifiers
	for key in modifier.multiply.keys():
		if not default_values.has(key):
			default_values[key] = get(key)  # Store the original value
		var old_value = get(key)
		set(key, old_value * modifier.multiply[key])

func remove_modifier(modifier: Modifier):
	# Apply the inverse of additive modifiers
	for key in modifier.add.keys():
		if key in self:
			var old_value = get(key)
			set(key, old_value - modifier.add[key])
	
	# Apply the inverse of multiplicative modifiers
	for key in modifier.multiply.keys():
		if key in self:
			if modifier.multiply[key] != 0:
				var old_value = get(key)
				set(key, old_value / modifier.multiply[key])
	
	# Remove the modifier from the list if it exists
	var modifiers_to_remove = []
	for i in range(applied_modifiers.size()):
		var stored_modifier = applied_modifiers[i]
		if stored_modifier["add"] == modifier.add and stored_modifier["multiply"] == modifier.multiply:
			modifiers_to_remove.append(i)
	
	# Reverse the list before removing items to avoid index errors
	modifiers_to_remove.reverse()
	for i in modifiers_to_remove:
		applied_modifiers.remove_at(i)

func restore_defaults():
	# Restore all variables to their stored defaults
	for key in default_values.keys():
		if key in self:
			set(key, default_values[key])
	
	# Clear the applied modifiers list
	applied_modifiers.clear()

func get_input():
	var input = Vector2()
	
	# Check for weapon switching
	if Input.is_action_just_pressed('nextweapon'):
		cancel_reload_burst()  # Cancel any ongoing reload or burst fire
		get_node("PlayerInventory").next_weapon()

	if Input.is_action_just_pressed('prevweapon'):
		cancel_reload_burst()  # Cancel any ongoing reload or burst fire
		get_node("PlayerInventory").prev_weapon()
	
	var current_weapon = get_node("PlayerInventory").current_weapon
	
	if Input.is_action_just_pressed('cycle'):
		if current_weapon is Weapon:
			get_node("PlayerInventory").current_weapon.cycle()
	var mouse_global_pos = get_global_mouse_position()
	if current_weapon is Weapon:
		if current_weapon.is_continuous:
			if Input.is_action_pressed('shoot'):
				current_weapon.shoot_with_fire_rate(self, mouse_global_pos)
		else:
			if Input.is_action_just_pressed('shoot'):
				current_weapon.shoot_with_fire_rate(self, mouse_global_pos)
	
	# Update target speed based on input
	if Input.is_action_pressed('run') and not Input.is_action_pressed('sneak'):
		target_speed = sprint_speed
	elif Input.is_action_pressed('sneak'):
		target_speed = sneak_speed
	else:
		target_speed = speed
	
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
		if current_weapon is Weapon:
			current_weapon.reload(self)
	
	return input.normalized()

func cancel_reload_burst():
	var current_weapon = get_node("PlayerInventory").current_weapon
	if current_weapon is Weapon:
		# Cancel reloading
		if current_weapon.is_reloading:
			current_weapon.is_reloading = false
			# Find and remove the reload timer
			for child in current_weapon.get_children():
				if child is Timer and child.get_name() == "ReloadTimer":
					child.stop()
					current_weapon.remove_child(child)
					child.queue_free()
			print("Reload canceled!")

		# Cancel burst fire
		if current_weapon.is_bursting:
			current_weapon.is_bursting = false
			# Find and remove the burst shot timer
			for child in current_weapon.get_children():
				if child is Timer and child.get_name() == "BurstShotTimer":
					child.stop()
					current_weapon.remove_child(child)
					child.queue_free()
			print("Burst fire canceled!")
			current_weapon.is_in_burst_delay = false  # Also clear any burst delay flag
			current_weapon.burst_shots_fired = 0  # Reset burst shot count

func _process(delta):
	look_at(get_global_mouse_position())

	# Update the dash cooldown timer
	if cooldown_timer > 0:
		cooldown_timer -= delta

func _physics_process(delta):
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		current_dash_speed = move_toward(current_dash_speed, dash_speed, dash_speed * 10 * delta)
		velocity = dash_direction * current_dash_speed
	else:
		current_dash_speed = move_toward(current_dash_speed, 0, dash_speed * 5 * delta)
		
		var direction = get_input()
		
		# Update target friction
		if is_sliding:
			target_friction = sliding_friction
		elif Input.is_action_pressed('sneak'):
			target_friction = no_friction
		else:
			target_friction = default_friction
		
		# Smoothly interpolate current friction
		current_friction = lerp(current_friction, target_friction, 10 * delta)
		
		# Set velocity directly based on target speed and direction without interpolation
		if direction.length() > 0:
			velocity = direction * target_speed
		else:
			# Apply friction when no input is given, reducing velocity smoothly
			velocity = velocity.lerp(Vector2.ZERO, current_friction)
	
	# Move the player using the calculated velocity
	move_and_slide()
	
	# Handle collisions
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

func _input(event):
	if event.is_action_pressed('dash') and not is_dashing and (cooldown_timer <= 0 or cooldown_timer == TYPE_NIL):
		is_dashing = true
		dash_timer = dash_duration
		cooldown_timer = dash_cooldown
		dash_direction = (get_global_mouse_position() - global_position).normalized()
		current_dash_speed = 0  # Start dash speed from 0
