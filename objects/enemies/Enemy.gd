extends RigidBody2D
class_name Enemy
@onready var death_scene: PackedScene = load("res://objects/enemies/EnemyPerish.tscn")
enum EnemyState { UNALERT, ALERT }
var current_state = EnemyState.UNALERT
var player_in_area = null
@export var turn_speed = 5.0
@export var roam_turn_speed = 2.0
@export var roam_speed = 50.0
@export var run_speed = 75.0
@export var friction = 0.1
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var roam_radius = 500.0
@export var roam_wait_time = 2.0
@export var health = 0
@export var player_damage = 0
@export var is_friendly: bool = false
@export var is_invincible: bool = false
var roam_timer = 0.0
var target_position: Vector2

# New variables for damage flash effect
@onready var sprite: Sprite2D = $Sprite2D  # Ensure the path is correct
@export var flash_duration: float = 0.5
@export var flash_intensity: float = 0.5  # How much to increase the saturation
var is_flashing: bool = false
var flash_timer: float = 0.0
var original_modulate: Color

@export var label_duration: float = 1.0  # Time for damage label to show

func _init() -> void:
	pass

func _ready():
	var area = get_node("Area2D")
	area.connect("body_entered", self._on_area_body_entered)
	area.connect("body_exited", self._on_area_body_exited)
	choose_random_roam_target()
	original_modulate = sprite.modulate

func damage(amount: int):
	if not is_invincible:
		health -= amount
		if health <= 0:
			kill()
		else:
			start_flash()
			show_damage_label(amount)

func start_flash():
	is_flashing = true
	flash_timer = flash_duration
	var h = original_modulate.h
	var s = min(original_modulate.s + flash_intensity, 1.0)  # Increase saturation
	var v = original_modulate.v
	sprite.modulate = Color.from_hsv(h, s, v, original_modulate.a)

# Updated function to use Godot 4.x Tween system with non-rotating label
func show_damage_label(damage_amount: int):
	var label_parent = Node2D.new()
	add_child(label_parent)
	
	var label = Label.new()
	label.text = str(damage_amount)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 14)  # Adjust font size as needed
	
	# Add random offset
	var random_offset = Vector2(
		randf_range(-10, 10),
		randf_range(-10, 10)
	)
	label.position = Vector2(-20, -sprite.texture.get_size().y / 2 - 20) + random_offset

	label_parent.add_child(label)

	# Create a new Tween using create_tween()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 30, label_duration)
	tween.tween_property(label, "modulate:a", 0, label_duration)

	# Connect the 'finished' signal to handle the cleanup after the animation ends
	tween.connect("finished", Callable(self, "_on_tween_finished").bind(label_parent))

	# Set up the label_parent to counteract the enemy's rotation
	set_process(true)

func _process(delta):
	for child in get_children():
		if child is Node2D and child.get_child_count() > 0 and child.get_child(0) is Label:
			child.global_rotation = 0

# Updated function to remove the label_parent after animation finishes
func _on_tween_finished(label_parent: Node2D):
	label_parent.queue_free()

func heal(amount: int):
	health += amount

func kill():
	# Instantiate the death scene
	var death_node = death_scene.instantiate()

	# Set its position to the enemy's position
	death_node.global_position = global_position
	
	# Add the death node to the scene tree
	get_parent().add_child(death_node)

	# Remove the enemy from the scene
	queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity *= friction
	state.angular_velocity *= friction

func _on_area_body_entered(body):
	if body is PlayerController:
		player_in_area = body
		current_state = EnemyState.ALERT

func _on_area_body_exited(body):
	if is_friendly:
		if body is PlayerController:
			player_in_area = null
			current_state = EnemyState.UNALERT
			choose_random_roam_target()

func _physics_process(delta):
	match current_state:
		EnemyState.ALERT:
			handle_attacking(delta)
		EnemyState.UNALERT:
			handle_roaming(delta)
	
	# Handle the flashing effect
	if is_flashing:
		flash_timer -= delta
		if flash_timer <= 0:
			is_flashing = false
			sprite.modulate = original_modulate
		else:
			# Interpolate the saturation back to original
			var t = 1 - (flash_timer / flash_duration)
			var current_s = sprite.modulate.s
			var original_s = original_modulate.s
			var new_s = lerp(current_s, original_s, t)
			sprite.modulate = Color.from_hsv(sprite.modulate.h, new_s, sprite.modulate.v, sprite.modulate.a)

func choose_random_roam_target():
	var random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * roam_radius
	var potential_target = global_position + random_offset
	navigation_agent.target_position = potential_target

func handle_attacking(delta):
	if is_friendly:
		
		if player_in_area:
			var direction = (player_in_area.global_position - global_position).normalized()
			var target_angle = direction.angle()
			rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	else:
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

func handle_roaming(delta):
	if navigation_agent.is_navigation_finished():
		roam_timer -= delta
		if roam_timer <= 0.0:
			roam_timer = roam_wait_time
			choose_random_roam_target()
	else:
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		var force = direction * roam_speed
		apply_central_impulse(force)
		var target_angle = direction.angle()
		rotation = lerp_angle(rotation, target_angle, roam_turn_speed * delta)
