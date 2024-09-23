extends Node2D
class_name Weapon

var _projectile = preload("res://objects/weapons/Projectile.tscn")

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

	# Create the projectile and set its position
	var projectile_instance = _projectile.instantiate()
	player.get_parent().add_child(projectile_instance)

	# Calculate the direction and set position as before
	var initial_direction = (mouse_pos - player.global_position).normalized()
	var offset = Vector2(36, 12)  # Offset to avoid collision with player
	var rotated_offset = offset.rotated(initial_direction.angle())
	var projectile_start_pos = player.global_position + rotated_offset
	projectile_instance.position = projectile_start_pos

	# Re-enable the player's collision after a short delay
	corrected_direction = (mouse_pos - projectile_start_pos).normalized()

	var gun_type = get_gun_type()
	var body = projectile_instance.get_node(gun_type)
	
	if body.get_parent() is Projectile:
		body.set_visible(true)
		body.velocity = corrected_direction * speed
		body.move_and_slide()
	

func set_wep(weapon):
	get_node(weapon).set_visible(true)

func clear_wep(weapon):
	get_node(weapon).set_visible(false)

func reload():
	print("reloading")

func get_gun_type():
	return "Weapon"

func test_print():
	print("test print")
