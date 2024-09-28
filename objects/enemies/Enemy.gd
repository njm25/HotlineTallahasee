extends RigidBody2D
class_name Enemy

enum EnemyState { UNALERT, ALERT }
var current_state = EnemyState.UNALERT
var player_in_area = null
@export var turn_speed = 5.0
@export var roam_turn_speed = 2.0
@export var roam_speed = 50.0
@export var friction = 0.1
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var roam_radius = 500.0
@export var roam_wait_time = 2.0
@export var health = 0
var roam_timer = 0.0
var target_position: Vector2

# New variables for damage flash effect
@onready var sprite: Sprite2D = $Sprite2D  # Make sure this path is correct
@export var flash_duration: float = 0.5
@export var flash_intensity: float = 0.5  # How much to increase the saturation
var is_flashing: bool = false
var flash_timer: float = 0.0
var original_modulate: Color

func _init() -> void:
	pass

func _ready():
	var area = get_node("Area2D")
	area.connect("body_entered", self._on_area_body_entered)
	area.connect("body_exited", self._on_area_body_exited)
	choose_random_roam_target()
	original_modulate = sprite.modulate

func damage(amount: int):
	health -= amount
	if health <= 0:
		kill()
	else:
		start_flash()

func start_flash():
	is_flashing = true
	flash_timer = flash_duration
	var h = original_modulate.h
	var s = min(original_modulate.s + flash_intensity, 1.0)  # Increase saturation
	var v = original_modulate.v
	sprite.modulate = Color.from_hsv(h, s, v, original_modulate.a)

func heal(amount: int):
	health += amount

func kill():
	queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity *= friction
	state.angular_velocity *= friction

func _on_area_body_entered(body):
	if body is PlayerController:
		player_in_area = body
		current_state = EnemyState.ALERT

func _on_area_body_exited(body):
	if body is PlayerController:
		player_in_area = null
		current_state = EnemyState.UNALERT
		choose_random_roam_target()

func _physics_process(delta):
	match current_state:
		EnemyState.ALERT:
			if player_in_area:
				var direction = (player_in_area.global_position - global_position).normalized()
				var target_angle = direction.angle()
				rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
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
