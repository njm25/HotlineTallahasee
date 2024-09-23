extends 'res://objects/weapons/Weapon.gd'
class_name Pistol

var speed = 800

func get_gun_type():
	return "Pistol"

func shoot(player: PlayerController, mouse_pos):
	# Create a new projectile instance and add it to the scene
	var projectile_instance = _projectile.instantiate()
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
	var corrected_direction = (mouse_pos - projectile_start_pos).normalized()

	# Ensure the projectile is visible
	projectile_instance.get_node(get_gun_type()).set_visible(true)

	# Get the rigid body and apply the force in the corrected direction
	var gun_type = get_gun_type()
	var body = projectile_instance.get_node(gun_type)
	if body.get_parent() is Projectile:
		# Apply force in the corrected direction
		body.velocity = corrected_direction * speed

		# Use move_and_slide() to move the projectile and allow it to interact with other bodies
		body.move_and_slide()
