extends 'res://objects/maps/Map.gd'

var gremlin_scene = preload("res://objects/enemies/Gremlin/Gremlin.tscn")
var gromlin_scene = preload("res://objects/enemies/Gromlin/Gromlin.tscn")
var num_enemies = 8  # Total number of enemies to spawn (Gremlins + Gromlins)
var radius = 150  # Radius of the circle

func spawn_player():
	super.spawn_player()
	if is_instance_valid(player_instance):
		var player_inventory = player.get_node("PlayerInventory")  # Ensure you're getting the correct node
		var pistol = Pistol.new()
		player_inventory.create_weapon(pistol, player)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()

func _init() -> void:
	pass
