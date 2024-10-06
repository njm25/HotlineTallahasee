class_name PlayerController extends CharacterBody2D

@export var speed = 500
@export var sprint_speed = 500
@export var sneak_speed = 150
@export var default_friction = 0.1
@export var acceleration = 0.1
@export var sliding_acceleration = 0.05
@export var sliding_deceleration = 0.005
@export var push_force = 80
@export var no_friction = 0.2
@export var dash_speed = 800
@export var dash_duration = 0.3
@export var dash_friction = 0.05
@export var dash_cooldown = 1.25
@export var health = 100
@export var i_frame_time = 1.0  # Duration of i-frames
@onready var player_sprite: Sprite2D = $Sprite2D  # Ensure the path is correct
@export var flash_duration: float = 0.5
@export var flash_intensity: float = 0.5  # How much to increase the saturation
@export var invincibility: bool = true
var is_flashing: bool = false
var flash_timer: float = 0.0
var original_modulate: Color
var is_dead= false
var is_paused = false
var i_frame_timer = 0.0         # Timer to track i-frame duration
var is_invincible = false       # Flag to track invincibility status

var is_sliding = false
var is_dashing = false
var dash_timer = 0.0
var dash_direction = Vector2.ZERO
var current_friction = default_friction
var cooldown_timer = 0.0

# New variables for smooth dash
var current_dash_speed = 0.0
var target_friction = default_friction
signal player_died

func damage(amount: int):
	if not invincibility:
		if not is_invincible:  # Prevent damage if i-frames are active
			health -= amount
			if health <= 0:
				kill()
			else:
				activate_i_frames()  # Activate i-frames after taking damage
				start_flash()  # Start flashing effect
func start_flash():
	is_flashing = true
	flash_timer = flash_duration
	original_modulate = player_sprite.modulate  # Store the original color
	var h = original_modulate.h
	var s = min(original_modulate.s + flash_intensity, 1.0)  # Increase saturation
	var v = original_modulate.v
	player_sprite.modulate = Color.from_hsv(h, s, v, original_modulate.a)

func activate_i_frames():
	is_invincible = true
	i_frame_timer = i_frame_time


func heal(amount: int):
	health += amount

func kill():
	is_dead = true
	emit_signal("player_died")



# Modifiers for stacking
var speed_modifiers: Array = []
var friction_modifiers: Array = []

var default_values := {}
var modified_flags := {}
var applied_modifiers := []

# Store default values

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
	
func _unhandled_input(event):
	if !is_paused:
		var current_weapon = get_node("PlayerInventory").current_weapon
		if event.is_action_released("shoot"):
			if current_weapon is Weapon:
				current_weapon.stop_shooting()
			
func get_input():
	if !is_paused:
		var input = Vector2()
		var current_speed = speed  # Default walking speed
		
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
				elif Input.is_action_just_released('shoot'):
					current_weapon.stop_shooting()
			else:
				if Input.is_action_just_pressed('shoot'):
					current_weapon.shoot_with_fire_rate(self, mouse_global_pos)
				elif Input.is_action_just_released('shoot'):
					current_weapon.stop_shooting()
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
			if current_weapon is Weapon:
				current_weapon.reload(self)
		
		return input.normalized() * current_speed

# Function to cancel reloads and bursts
# Function to cancel reloads and bursts
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
	if is_dead == false:
		if !is_paused:
			look_at(get_global_mouse_position())
			# Existing i-frame logic
		if is_invincible:
			i_frame_timer -= delta
			if i_frame_timer <= 0:
				is_invincible = false

		# Handle the flashing effect
		if is_flashing:
			flash_timer -= delta
			if flash_timer <= 0:
				is_flashing = false
				player_sprite.modulate = original_modulate  # Restore original color
			else:
				# Interpolate the saturation back to original
				var t = 1 - (flash_timer / flash_duration)
				var current_s = player_sprite.modulate.s
				var original_s = original_modulate.s
				var new_s = lerp(current_s, original_s, t)
				player_sprite.modulate = Color.from_hsv(player_sprite.modulate.h, new_s, player_sprite.modulate.v, player_sprite.modulate.a)
		# Update the dash cooldown timer
		if cooldown_timer > 0:
			cooldown_timer -= delta


func _physics_process(delta):
	if is_dead == false:
		if is_dashing:
			dash_timer -= delta
			if dash_timer <= 0:
				is_dashing = false
				target_friction = default_friction if not is_sliding else sliding_acceleration
			else:
				# Gradually increase dash speed
				current_dash_speed = move_toward(current_dash_speed, dash_speed, dash_speed * 10 * delta)
				velocity = dash_direction * current_dash_speed
				target_friction = dash_friction
			
			# Smoothly interpolate friction
			current_friction = lerp(current_friction, target_friction, 10 * delta)
			
			move_and_slide()
			return

		var direction = get_input()
		if not direction:
			direction = Vector2.ZERO

		if Input.is_action_pressed('sneak'):
			target_friction = no_friction
		elif is_sliding:
			target_friction = sliding_acceleration if direction.length() > 0 else sliding_deceleration
		else:
			target_friction = default_friction

		# Smoothly interpolate friction
		current_friction = lerp(current_friction, target_friction, 10 * delta)

		# Gradually decrease dash speed when not dashing
		current_dash_speed = move_toward(current_dash_speed, 0, dash_speed * 5 * delta)

		if is_sliding:
			if direction.length() > 0:
				velocity = velocity.lerp(direction, sliding_acceleration)
			else:
				velocity = velocity.lerp(Vector2.ZERO, sliding_deceleration)
		else:
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
	if is_dead == false:
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
