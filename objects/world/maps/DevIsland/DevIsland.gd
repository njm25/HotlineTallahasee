extends Node2D

var player_scene = preload("res://objects/player/Player.tscn")
var player_instance
var player
var player_is_dead: bool = false

# Signal for respawn and death
signal player_respawned(new_player)
signal player_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_player()

func spawn_player():
	player_instance = player_scene.instantiate()
	add_child(player_instance)
	player = player_instance.get_node("Player/PlayerController")

	# Connect to the death signal from the player
	player.connect("player_died", self._on_player_died)

	# Emit signal when player respawns
	emit_signal("player_respawned", player)

# Called when the player dies
func _on_player_died():
	if is_instance_valid(player_instance):
		player_instance.queue_free()
		player = null
		player_instance = null
		spawn_player()
