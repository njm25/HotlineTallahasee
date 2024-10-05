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
	create_camera()
	spawn_enemies_in_circle()
	
func spawn_enemies_in_circle() -> void:
	for i in range(num_enemies):
		var angle = i * (PI * 2 / num_enemies)  # Calculate angle for each enemy
		var x = radius * cos(angle)  # X coordinate using cosine
		var y = radius * sin(angle)  # Y coordinate using sine
		
		# Alternate between Gremlin and Gromlin based on index
		var enemy_instance
		if i % 2 == 0:
			enemy_instance = gremlin_scene.instantiate()  # Spawn Gremlin for even indices
		else:
			enemy_instance = gromlin_scene.instantiate()  # Spawn Gromlin for odd indices
		
		enemy_instance.position = Vector2(x, y)  # Set position in a circle
		add_child(enemy_instance)

func _init() -> void:
	pass
