extends Node2D
class_name Weapon

# Preload actual projectile scenes into the dictionary
var _projectile_scenes = {
	"Pistol": preload("res://objects/weapons/Pistol/PistolProjectile.tscn")
}

@export var has_recoil: bool = false
@export var has_projectile: bool = false
@export var recoil_force: float = 0.0  # Default recoil force
@export var speed: float = 0.0  # Default speed for projectiles

func _init() -> void:
	pass # Replace with function body.

# Generic shooting logic moved to Weapon class
func shoot(player: PlayerController, mouse_pos: Vector2):
	var corrected_direction = Vector2()  # Ensure this is declared before use

	if has_projectile:
		fire_projectile(player, mouse_pos, corrected_direction)

	# Apply recoil if the weapon has recoil
	if has_recoil:
		apply_recoil_to_player(player, -corrected_direction)

func apply_recoil_to_player(player: PlayerController, recoil_direction: Vector2):
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
	player.get_parent().add_child(projectile_instance)

	# Calculate the direction from player to the mouse position (ignoring offset for now)
	var initial_direction = (mouse_pos - player.global_position).normalized()

	# Define the offset for the projectile relative to the player
	var offset = Vector2(26, 12)  # Example offset
	var rotated_offset = offset.rotated(initial_direction.angle())

	# Set the projectile's starting position as player's position + offset
	var projectile_start_pos = player.global_position + rotated_offset
	projectile_instance.position = projectile_start_pos

	# Now calculate the direction from the projectile's new position to the mouse
	corrected_direction = (mouse_pos - projectile_start_pos).normalized()

	# Ensure the projectile is visible
	projectile_instance.set_visible(true)

	# Get the rigid body and apply the force in the corrected direction
	if projectile_instance is CharacterBody2D:
		# Apply force in the corrected direction
		projectile_instance.velocity = corrected_direction * speed

		# Use move_and_slide() to move the projectile and allow it to interact with other bodies
		projectile_instance.move_and_slide()

func reload():
	print("reloading")

func get_projectile_scene():
	# Return the projectile scene based on the weapon's name/class
	if _projectile_scenes.has(self.name):
		return _projectile_scenes[self.name]  # Return the preloaded PackedScene
	else:
		return null

# Leave get_gun_type unchanged so you can still have your custom logic
func get_gun_type():
	return "Weapon"
