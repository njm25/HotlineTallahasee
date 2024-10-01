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
@export var has_ammo = true
@export var spread: float = 0.08  # Controls the spread; lower values are more accurate, higher values are less accurate
@export var projectile_spawn_offset = Vector2(0, 0)
@export var burst_fire: bool = false  # Toggle burst fire mode
@export var burst_count: int = 3  # Number of shots in a burst
@export var burst_shot_delay: float = 0.1  # Delay between shots in a burst
@export var burst_delay: float = 0.5  # Delay between bursts
@export var damage: int = 0

# Bloom-related variables
@export var has_bloom: bool = false
@export var max_bloom: float = 0.5
@export var bloom_reset_time: float = 1.0
@export var bloom_increase_rate: float = 0.1  # New variable to control how quickly bloom increases

var is_reloading: bool = false  # To prevent shooting while reloading
var is_bursting: bool = false  # To prevent firing while in burst fire mode
var is_in_burst_delay: bool = false  # To prevent firing between bursts
var last_shot_time: float = 0.0  # Tracks the time when the last shot was fired
var burst_shots_fired: int = 0  # Tracks how many shots have been fired in the current burst
var current_player = null  # Stores the player reference during burst
var current_mouse_pos = Vector2.ZERO  # Stores the mouse position during burst

# Bloom-related variables
var current_bloom: float = 0.0
var bloom_reset_timer: float = 0.0

func _init() -> void:
	pass  # Replace with function body.

func _process(delta):
	# Handle bloom reset
	if has_bloom and current_bloom > 0:
		bloom_reset_timer += delta
		if bloom_reset_timer >= bloom_reset_time:
			current_bloom = 0.0
		else:
			# Gradual bloom reduction
			current_bloom = max(0, current_bloom - (max_bloom / bloom_reset_time) * delta)

func cycle():
	pass

# Fires the projectile from the player in the given direction, adjusted by accuracy
func fire_projectile(player, mouse_pos, corrected_direction):
	var projectile_scene = get_projectile_scene()

	if projectile_scene == null:
		print("Error: No projectile scene found for this gun type.")
		return

	var projectile_instance = projectile_scene.instantiate()
	projectile_instance.set_visible(false)
	projectile_instance.set_max_bounces(max_bounces)
	projectile_instance.set_damage(damage)
	player.get_parent().add_child(projectile_instance)

	var offset = projectile_spawn_offset
	var rotated_offset = offset.rotated(corrected_direction.angle())

	var projectile_start_pos = player.global_position + rotated_offset
	projectile_instance.position = projectile_start_pos

	var final_direction = (mouse_pos - projectile_start_pos).normalized()

	# Apply accuracy to the final firing direction, including bloom
	var total_spread = spread + (current_bloom if has_bloom else 0)
	var accuracy_deviation = randf_range(-total_spread, total_spread)
	var inaccurate_direction = final_direction.rotated(accuracy_deviation)

	if projectile_instance is CharacterBody2D:
		projectile_instance.velocity = inaccurate_direction * speed
		projectile_instance.move_and_slide()
		projectile_instance.set_visible(true)

# Apply recoil to the player based on the direction of fire
func apply_recoil_to_player(player: PlayerController, recoil_direction: Vector2):
	player.velocity += recoil_direction * recoil_force

# Main shoot function that checks conditions and fires projectiles
func shoot(player: PlayerController, mouse_pos: Vector2):
	if is_reloading or is_bursting or is_in_burst_delay:
		return

	if current_ammo > 0:
		var corrected_direction = (mouse_pos - player.global_position).normalized()

		if has_projectile:
			fire_projectile(player, mouse_pos, corrected_direction)

		if has_recoil:
			apply_recoil_to_player(player, -corrected_direction)

		current_ammo -= 1

		# Apply bloom gradually
		if has_bloom:
			current_bloom = min(current_bloom + (max_bloom * bloom_increase_rate), max_bloom)
			bloom_reset_timer = 0.0

# Handle shooting with fire rate control and burst fire
func shoot_with_fire_rate(player: PlayerController, mouse_pos: Vector2):
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_shot_time >= fire_rate:
		if burst_fire:
			start_burst(player, mouse_pos)
		else:
			shoot(player, mouse_pos)
			last_shot_time = current_time

# Handle burst fire mode with a timer
func start_burst(player: PlayerController, mouse_pos: Vector2):
	if not is_bursting and not is_in_burst_delay and current_ammo > 0:
		is_bursting = true
		burst_shots_fired = 0
		current_player = player
		current_mouse_pos = mouse_pos
		fire_burst_shot()

# Fires one shot and sets up a timer for the next one
func fire_burst_shot():
	if burst_shots_fired < burst_count and current_ammo > 0 and current_player:
		var corrected_direction = (current_mouse_pos - current_player.global_position).normalized()
		fire_projectile(current_player, current_mouse_pos, corrected_direction)
		current_ammo -= 1

		if has_recoil:
			apply_recoil_to_player(current_player, -corrected_direction)

		# Apply bloom gradually for burst fire
		if has_bloom:
			current_bloom = min(current_bloom + (max_bloom * bloom_increase_rate), max_bloom)
			bloom_reset_timer = 0.0

		burst_shots_fired += 1

		if current_ammo <= 0:
			is_bursting = false
			start_burst_delay()
			return

		var burst_shot_timer = Timer.new()
		burst_shot_timer.name = "BurstShotTimer"
		burst_shot_timer.wait_time = burst_shot_delay
		burst_shot_timer.one_shot = true
		current_player.add_child(burst_shot_timer)
		burst_shot_timer.connect("timeout", self._on_burst_shot_timeout)
		burst_shot_timer.start()
	else:
		is_bursting = false
		start_burst_delay()

func _on_burst_shot_timeout():
	if not is_bursting:
		return
	fire_burst_shot()

func start_burst_delay():
	is_in_burst_delay = true
	var burst_delay_timer = Timer.new()
	burst_delay_timer.wait_time = burst_delay
	burst_delay_timer.one_shot = true
	current_player.add_child(burst_delay_timer)
	burst_delay_timer.connect("timeout", self._on_burst_delay_timeout)
	burst_delay_timer.start()

func _on_burst_delay_timeout():
	if not is_in_burst_delay:
		return
	is_in_burst_delay = false

func reload(player):
	if not is_reloading and ammo_capacity != current_ammo:
		is_reloading = true
		print("Reloading...")
		var reload_timer = Timer.new()
		reload_timer.name = "ReloadTimer"
		reload_timer.wait_time = reload_time
		reload_timer.one_shot = true
		player.add_child(reload_timer)
		reload_timer.connect("timeout", self._on_reload_timeout)
		reload_timer.start()

func _on_reload_timeout():
	if not is_reloading:
		return
	current_ammo = ammo_capacity
	print("Reload complete!")
	is_reloading = false

func get_projectile_scene():
	var gun_type = get_gun_type()
	var scene_path = "res://objects/weapons/%s/%sProjectile.tscn" % [gun_type, gun_type]
	var projectile_scene = load(scene_path)
	if projectile_scene:
		return projectile_scene
	else:
		print("Error: Could not load projectile scene for gun type: %s" % gun_type)
		return null

func get_gun_type():
	return "Weapon"
