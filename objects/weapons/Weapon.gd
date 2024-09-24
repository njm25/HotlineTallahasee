extends Node2D
class_name Weapon

@export var has_recoil: bool = false
@export var has_projectile: bool = false
@export var recoil_force: float = 0.0  # Default recoil force
@export var speed: float = 0.0  # Default speed for projectiles
@export var is_continuous = false
@export var fire_rate = 0.2

var last_shot_time: float = 0.0  # Tracks the time when the last shot was fired

func _init() -> void:
	pass # Replace with function body.

func shoot(player: PlayerController, mouse_pos: Vector2):

	# Calculate the corrected direction from the player to the mouse position
	var corrected_direction = (mouse_pos - player.global_position).normalized()

	# If the weapon has a projectile, fire it
	if has_projectile:
		fire_projectile(player, mouse_pos, corrected_direction)

	# Apply recoil if the weapon has recoil
	if has_recoil:
		apply_recoil_to_player(player, -corrected_direction)

# Handle shooting with fire rate control
func shoot_with_fire_rate(player: PlayerController, mouse_pos: Vector2):
	# Check if enough time has passed since the last shot
	var current_time = Time.get_ticks_msec() / 1000.0  # Get the current time in seconds
	if current_time - last_shot_time >= fire_rate:
		shoot(player, mouse_pos)  # Shoot the weapon
		last_shot_time = current_time  # Update the last shot time

func apply_recoil_to_player(player: PlayerController, recoil_direction: Vector2):
	# Apply the recoil force to the player's velocity
	player.velocity += recoil_direction * recoil_force

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
	player.get_parent().add_child(projectile_instance)

	# Define the offset for the projectile relative to the player
	var offset = Vector2(26, 12)  # Example offset
	var rotated_offset = offset.rotated(corrected_direction.angle())

	# Set the projectile's starting position as player's position + offset
	var projectile_start_pos = player.global_position + rotated_offset
	projectile_instance.position = projectile_start_pos
 	
	
	corrected_direction = (mouse_pos - projectile_start_pos).normalized()
	# Ensure the projectile is visible

	# Get the rigid body and apply the force in the corrected direction
	if projectile_instance is CharacterBody2D:
		# Apply force in the corrected direction
		projectile_instance.velocity = corrected_direction * speed

		# Use move_and_slide() to move the projectile and allow it to interact with other bodies
		projectile_instance.move_and_slide()
		projectile_instance.set_visible(true)

func reload():
	print("reloading")

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
