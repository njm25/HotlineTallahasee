extends Node
class_name GameManager

# Variables to control round transitions and enemy spawning
var enemies_spawned = 0
var enemies_alive = []  # Track living enemies
@export var current_round_index: int = 1
@export var round_duration: float = 30.0  # Time for a round to complete
@onready var round_timer = Timer.new()
@export var start_round: Round = Round.new()  # Declare start_round to be set in the Map class
@export var spawn_distance: float = 100.0  # Distance from player where enemies spawn

var current_round: Round  # Hold the current round data
var player: PlayerController
var enemy_scenes = {}  # Dictionary to preload enemy scenes
var nav_area  # Reference to the navigation area
var spawn_timer: Timer = Timer.new()  # Reuse spawn timer between rounds

func _ready():
	# Get the navigation area from the map scene
	nav_area = get_parent().get_node("NavigationRegion2D")

	# Preload enemy scenes during initialization
	for enemy_type in start_round.dict_of_possible_enemies.keys():
		var enemy_scene_path = "res://objects/enemies/%s/%s.tscn" % [enemy_type, enemy_type]
		enemy_scenes[enemy_type] = load(enemy_scene_path)

	# Add spawn timer to the scene
	add_child(spawn_timer)
	spawn_timer.connect("timeout", self.spawn_enemy)

	# Start the first round
	current_round = start_round.duplicate()  # Use a copy of start_round to ensure data is carried over
	start_new_round(current_round)

func start_new_round(round: Round):
	if not round_timer.get_parent():
		add_child(round_timer)
	round_timer.start(round_duration)
	enemies_spawned = 0
	enemies_alive.clear()
	spawn_timer.start(round.spawning_rate)

func spawn_enemy():
	if enemies_spawned < current_round.max_enemies:
		var enemy_type = choose_enemy_type()
		var enemy_scene = enemy_scenes.get(enemy_type, null)
		if enemy_scene and is_instance_valid(player):
			var enemy_instance = enemy_scene.instantiate()
			var spawn_offset = Vector2(randf_range(-spawn_distance, spawn_distance), randf_range(-spawn_distance, spawn_distance))
			var spawn_position = player.global_position + spawn_offset
			enemy_instance.global_position = spawn_position
			add_child(enemy_instance)
			enemies_spawned += 1
			enemies_alive.append(enemy_instance)

	# Remove invalid instances from enemies_alive
	enemies_alive = enemies_alive.filter(is_instance_valid)

	# Check if all enemies have spawned and are defeated
	if enemies_spawned == current_round.max_enemies and enemies_alive.size() == 0:
		end_round()

func choose_enemy_type() -> String:
	var rand_value = randf()
	var cumulative_probability = 0.0
	for enemy in current_round.dict_of_possible_enemies.keys():
		cumulative_probability += current_round.dict_of_possible_enemies[enemy]
		if rand_value <= cumulative_probability:
			return enemy
	return current_round.dict_of_possible_enemies.keys()[-1]

func end_round():
	# Prepare to transition to the next round
	current_round_index += 1
	current_round = current_round.duplicate()  # Duplicate the current round to preserve changes
	apply_modifiers_to_next_round(current_round)
	start_new_round(current_round)

func apply_modifiers_to_next_round(round: Round):
	# Example modifiers to apply between rounds
	round.max_enemies += 5
	round.spawning_rate = max(0.5, round.spawning_rate - 0.1)  # Reduce the spawn rate up to a minimum
