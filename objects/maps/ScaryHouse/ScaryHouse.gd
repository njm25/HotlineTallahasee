extends 'res://objects/maps/Map.gd'

var gremlin_scene = preload("res://objects/enemies/Gremlin/Gremlin.tscn")
var num_gremlins = 8  # Number of Gremlins to spawn
var radius = 150  # Radius of the circle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_camera()
	spawn_player()
	spawn_gremlins_in_circle()
	var player_inventory = player.get_node("PlayerInventory")  # Ensure you're getting the correct node
		
	var pistol = Pistol.new()
		
	player_inventory.create_weapon(pistol, player)
	
func spawn_gremlins_in_circle() -> void:
	for i in range(num_gremlins):
		var angle = i * (PI * 2 / num_gremlins)  # Calculate angle for each gremlin
		var x = radius * cos(angle)  # X coordinate using cosine
		var y = radius * sin(angle)  # Y coordinate using sine
		var gremlin_instance = gremlin_scene.instantiate()
		gremlin_instance.position = Vector2(x, y)  # Set position in a circle
		add_child(gremlin_instance)

func _init() -> void:
	pass
