extends RigidBody2D
class_name Enemy
@onready var death_scene: PackedScene = load("res://objects/enemies/EnemyPerish.tscn")
enum EnemyState { UNALERT, ALERT }
var current_state = EnemyState.UNALERT
var player_in_area = null
@export var enemy_type = ""
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
@export var shoots_projectile = false
@export var can_melee = false
@export var fire_rate: float = 1.0  # Time between projectile shots
@export var melee_fire_rate: float = 1.0  # Time between melee attacks
@export var use_last_position: bool = false  # Flag to determine behavior


var last_known_player_position: Vector2 = Vector2()  # To store last known position
var player_reference = null  # To store the player reference
var roam_timer = 0.0
var target_position: Vector2
var shoot_timer: float = 0.0
var melee_timer: float = 0.0
var is_melee_attacking: bool = false

# New variables for damage flash effect
@onready var sprite: Sprite2D = $Sprite2D  # Ensure the path is correct
@export var flash_duration: float = 0.5
@export var flash_intensity: float = 0.5  # How much to increase the saturation
var is_flashing: bool = false
var flash_timer: float = 0.0
var original_modulate: Color

@export var label_duration: float = 1.0  # Time for damage label to show

# New variable for melee range detection
@onready var melee_range_area: Area2D = $MeleeRange
var player_in_melee_range = false

func _init() -> void:
	pass

func _ready():
	var area = get_node("Area2D")
	area.connect("body_entered", self._on_area_body_entered)
	area.connect("body_exited", self._on_area_body_exited)
	choose_random_roam_target()
	original_modulate = sprite.modulate

	# Enable contact monitoring
	contact_monitor = true
	max_contacts_reported = 4  # Adjust this value based on your needs

	# Connect signals for melee range
	melee_range_area.connect("body_entered", self._on_melee_range_body_entered)
	melee_range_area.connect("body_exited", self._on_melee_range_body_exited)

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
	if player_in_area:
		if player_in_area.is_dead:
			player_in_area = null
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
		player_reference = body  # Store player reference if needed
		if not player_in_area.is_connected("player_died", self._on_player_death):
			player_in_area.connect("player_died", self._on_player_death)
		current_state = EnemyState.ALERT

func _on_player_death():
	current_state = EnemyState.UNALERT

func _on_area_body_exited(body):
	if body is PlayerController:
		player_in_area = null
		last_known_player_position = body.global_position  # Save last known position
		if is_friendly:
			current_state = EnemyState.UNALERT
			choose_random_roam_target()
		else:
			# Use the last known position if use_last_position is true
			if use_last_position:
				navigation_agent.target_position = last_known_player_position
			else:
				navigation_agent.target_position = body.global_position
				player_reference = body  # Store the player reference to follow

func _on_melee_range_body_entered(body):
	if body is PlayerController:
		player_in_melee_range = true
		is_melee_attacking = true
		melee_timer = melee_fire_rate  # Start the melee timer

func _on_melee_range_body_exited(body):
	if body is PlayerController:
		player_in_melee_range = false
		is_melee_attacking = false

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
	if player_in_area:
		if is_friendly:
			# If the enemy is friendly, stop moving and just look at the player
			var direction = (player_in_area.global_position - global_position).normalized()
			var target_angle = direction.angle()
			rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
		else:
			if shoots_projectile:
				# Player is within the Area2D (shooting range)
				var direction = (player_in_area.global_position - global_position).normalized()
				var target_angle = direction.angle()
				rotation = lerp_angle(rotation, target_angle, turn_speed * delta)

				# Shoot projectile if cooldown is over
				shoot_timer -= delta
				if shoot_timer <= 0:
					shoot_projectile(player_in_area)
					shoot_timer = fire_rate
			else:
				# If the enemy can melee, check for melee attack
				if can_melee and is_melee_attacking:
					melee_timer -= delta
					if player_in_melee_range and melee_timer <= 0:
						melee_attack(player_in_area)
						melee_timer = melee_fire_rate

				# Chase the player
				navigation_agent.target_position = player_in_area.global_position
				if not navigation_agent.is_navigation_finished():
					var next_position = navigation_agent.get_next_path_position()
					var direction = (next_position - global_position).normalized()
					var force = direction * run_speed
					apply_central_impulse(force)

					var target_angle = direction.angle()
					rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	else:
		# Player is outside the Area2D (chase the player or their last known position)
		if shoots_projectile or can_melee:
			if use_last_position:
				# Move towards the last known position of the player
				navigation_agent.target_position = last_known_player_position
			elif player_reference and is_instance_valid(player_reference):
				# Move towards the player's current position
				navigation_agent.target_position = player_reference.global_position

			if not navigation_agent.is_navigation_finished():
				var next_position = navigation_agent.get_next_path_position()
				var direction = (next_position - global_position).normalized()
				var force = direction * run_speed
				apply_central_impulse(force)

				var target_angle = direction.angle()
				rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
			else:
				# Update to keep pursuing the target
				if use_last_position:
					navigation_agent.target_position = last_known_player_position
				elif player_reference and is_instance_valid(player_reference):
					navigation_agent.target_position = player_reference.global_position
			
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

func get_enemy_projectile_scene() -> PackedScene:
	var scene_path = "res://objects/enemies/%s/%sProjectile.tscn" % [enemy_type, enemy_type]
	var projectile_scene = load(scene_path)
	if projectile_scene:
		return projectile_scene
	else:
		print("Error: Could not load projectile scene for enemy type: %s" % enemy_type)
		return null

func shoot_projectile(player: PlayerController):
	# Get the projectile scene for the enemy based on enemy_type
	var projectile_scene = get_enemy_projectile_scene()
	if projectile_scene == null:
		print("Error: Could not load projectile scene for enemy type: %s" % enemy_type)
		return

	# Instantiate the projectile
	var projectile_instance = projectile_scene.instantiate()

	# Set projectile properties like bounces, damage, etc.
	projectile_instance.set_max_bounces(0)  # You can modify or expose this property
	projectile_instance.set_damage(player_damage)  # Assuming player_damage is the projectile damage

	# Calculate the direction towards the player
	var direction_to_player = (player.global_position - global_position).normalized()

	# Set the projectile's position with a slight offset, if necessary
	var offset = Vector2(10, 0)  # Customize this offset as needed
	var rotated_offset = offset.rotated(direction_to_player.angle())
	projectile_instance.position = global_position + rotated_offset

	# Set the projectile's velocity based on the direction to the player
	projectile_instance.velocity = direction_to_player * 300.0  # 300 is an example speed, can be adjusted

	# Add the projectile to the scene tree
	get_parent().add_child(projectile_instance)

func melee_attack(player: PlayerController):
	player.damage(player_damage)
	pass
