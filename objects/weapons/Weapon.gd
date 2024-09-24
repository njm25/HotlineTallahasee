extends Node2D
class_name Weapon

@export var has_recoil: bool = false
@export var has_projectile: bool = false
@export var recoil_force: float = 0.0  # Default recoil force
@export var speed: float = 0.0  # Default speed for projectiles
@export var is_continuous = false
@export var fire_rate = 0.2
@export var max_bounces = 0 
@export var accept_modifiers = true
@export var ammo_capacity: int = 30  # Max ammo capacity
@export var current_ammo: int = 30  # Current ammo count
@export var reload_time: float = 2.0  # Time it takes to reload (in seconds)

# Burst fire-related variables
@export var burst_fire: bool = false  # Toggle burst fire mode
@export var burst_count: int = 3  # Number of shots in a burst
@export var burst_shot_delay: float = 0.1  # Delay between shots in a burst
@export var burst_delay: float = 0.5  # Delay between bursts

var is_reloading: bool = false  # To prevent shooting while reloading
var is_bursting: bool = false  # To prevent firing while in burst fire mode
var is_in_burst_delay: bool = false  # To prevent firing between bursts
var last_shot_time: float = 0.0  # Tracks the time when the last shot was fired
var burst_shots_fired: int = 0  # Tracks how many shots have been fired in the current burst
var current_player = null  # Stores the player reference during burst
var current_mouse_pos = Vector2.ZERO  # Stores the mouse position during burst

func _init() -> void:
	pass  # Replace with function body.

# Fires the projectile from the player in the given direction
func fire_projectile(player, mouse_pos, corrected_direction):
	# Get the projectile scene for the current gun type
	var projectile_scene = get_projectile_scene()

	# Ensure the scene exists
	if projectile_scene == null:
		print("Error: No projectile scene found for this gun type.")
		return

	# Create a new projectile instance and add it to the scene
	var projectile_instance = projectile_scene.instantiate()
	projectile_instance.set_visible(false)
	projectile_instance.set_max_bounces(max_bounces)
	player.get_parent().add_child(projectile_instance)

	# Define the offset for the projectile relative to the player
	var offset = Vector2(26, 12)  # Example offset
	var rotated_offset = offset.rotated(corrected_direction.angle())

	# Set the projectile's starting position as player's position + offset
	var projectile_start_pos = player.global_position + rotated_offset
	projectile_instance.position = projectile_start_pos
	
	corrected_direction = (mouse_pos - projectile_start_pos).normalized()

	# Get the rigid body and apply the force in the corrected direction
	if projectile_instance is CharacterBody2D:
		# Apply force in the corrected direction
		projectile_instance.velocity = corrected_direction * speed

		# Use move_and_slide() to move the projectile and allow it to interact with other bodies
		projectile_instance.move_and_slide()
		projectile_instance.set_visible(true)

# Apply recoil to the player based on the direction of fire
func apply_recoil_to_player(player: PlayerController, recoil_direction: Vector2):
	# Apply the recoil force to the player's velocity
	player.velocity += recoil_direction * recoil_force

# Main shoot function that checks conditions and fires projectiles
# Main shoot function that checks conditions and fires projectiles
func shoot(player: PlayerController, mouse_pos: Vector2):
	# Check if the weapon is currently reloading or in burst delay
	if is_reloading or is_bursting or is_in_burst_delay:
		print("Weapon is reloading, bursting, or in burst delay, cannot shoot!")
		return

	# Check if there's enough ammo
	if current_ammo > 0:
		# Calculate the corrected direction from the player to the mouse position
		var corrected_direction = (mouse_pos - player.global_position).normalized()

		# If the weapon has a projectile, fire it
		if has_projectile:
			fire_projectile(player, mouse_pos, corrected_direction)

		# Apply recoil if the weapon has recoil
		if has_recoil:
			apply_recoil_to_player(player, -corrected_direction)

		# Decrease ammo count after shooting
		current_ammo -= 1
	else:
		print("Out of ammo! Reload required.")

# Handle shooting with fire rate control and burst fire
func shoot_with_fire_rate(player: PlayerController, mouse_pos: Vector2):
	# Check if enough time has passed since the last shot
	var current_time = Time.get_ticks_msec() / 1000.0  # Get the current time in seconds
	if current_time - last_shot_time >= fire_rate:
		if burst_fire:
			# Handle burst fire mode
			start_burst(player, mouse_pos)
		else:
			# Regular single shot mode
			shoot(player, mouse_pos)  # Shoot the weapon
			last_shot_time = current_time  # Update the last shot time

# Handle burst fire mode with a timer
func start_burst(player: PlayerController, mouse_pos: Vector2):
	if not is_bursting and not is_in_burst_delay and current_ammo > 0:
		is_bursting = true
		burst_shots_fired = 0  # Reset the shot counter for the burst
		current_player = player  # Store the player reference
		current_mouse_pos = mouse_pos  # Store the mouse position for the burst

		# Start the first shot in the burst
		fire_burst_shot()

# Fires one shot and sets up a timer for the next one
func fire_burst_shot():
	if burst_shots_fired < burst_count and current_ammo > 0 and current_player:
		# Recalculate the direction for each shot
		var corrected_direction = (current_mouse_pos - current_player.global_position).normalized()

		# Fire the projectile
		fire_projectile(current_player, current_mouse_pos, corrected_direction)

		# Decrease ammo count after each shot
		current_ammo -= 1

		# Apply recoil if the weapon has recoil
		if has_recoil:
			apply_recoil_to_player(current_player, -corrected_direction)

		# Increment the burst shot counter
		burst_shots_fired += 1

		# Check if ammo runs out during the burst
		if current_ammo <= 0:
			print("Out of ammo during burst!")
			is_bursting = false
			start_burst_delay()  # Start burst delay even if ammo runs out
			return

		# Create a timer for the next shot in the burst
		var burst_shot_timer = Timer.new()
		burst_shot_timer.wait_time = burst_shot_delay
		burst_shot_timer.one_shot = true
		current_player.add_child(burst_shot_timer)  # Add the timer to the scene

		# Connect the timer's timeout signal to fire the next shot
		burst_shot_timer.connect("timeout", self._on_burst_shot_timeout)
		burst_shot_timer.start()
	else:
		# End the burst if all shots are fired or out of ammo
		print("Burst complete!")
		is_bursting = false

		# Start the burst delay timer before allowing another burst
		start_burst_delay()

# This function is called after each burst shot delay
func _on_burst_shot_timeout():
	# Fire the next shot in the burst
	fire_burst_shot()

# This function handles the burst delay (time between bursts)
func start_burst_delay():
	is_in_burst_delay = true

	# Create a timer for the burst delay
	var burst_delay_timer = Timer.new()
	burst_delay_timer.wait_time = burst_delay
	burst_delay_timer.one_shot = true
	current_player.add_child(burst_delay_timer)  # Add the timer to the scene

	# Connect the timer's timeout signal to reset burst delay
	burst_delay_timer.connect("timeout", self._on_burst_delay_timeout)
	burst_delay_timer.start()

# This function is called after the burst delay is over
func _on_burst_delay_timeout():
	is_in_burst_delay = false  # Allow firing again

# Reload with a delay
func reload(player):
	# Start the reloading process if not already reloading
	if not is_reloading and ammo_capacity != current_ammo:
		is_reloading = true  # Set reloading flag
		print("Reloading...")

		# Create a Timer node to handle the reload delay
		var reload_timer = Timer.new()
		reload_timer.wait_time = reload_time  # Set the wait time to the reload_time variable
		reload_timer.one_shot = true  # Make sure the timer runs only once
		
		# Add the timer to the scene before starting it
		player.add_child(reload_timer)  

		# Connect the timeout signal to the function that completes the reload
		reload_timer.connect("timeout", self._on_reload_timeout)
		
		# Now start the timer
		reload_timer.start()

# This function will be called when the reload timer completes
func _on_reload_timeout():
	# Reload the weapon to restore ammo capacity
	current_ammo = ammo_capacity
	print("Reload complete!")

	# Reset reloading flag
	is_reloading = false

func get_projectile_scene():
	# Dynamically create the path based on the gun type
	var gun_type = get_gun_type()
	var scene_path = "res://objects/weapons/%s/%sProjectile.tscn" % [gun_type, gun_type]

	# Load and return the PackedScene
	var projectile_scene = load(scene_path)

	# Check if the scene is valid
	if projectile_scene:
		return projectile_scene
	else:
		print("Error: Could not load projectile scene for gun type: %s" % gun_type)
		return null

# Leave get_gun_type unchanged so you can still have your custom logic
func get_gun_type():
	return "Weapon"
