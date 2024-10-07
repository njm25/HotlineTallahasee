extends 'res://objects/maps/Map.gd'

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
