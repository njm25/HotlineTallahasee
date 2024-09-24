extends Node

@export var health = 100
@export var player_inventory = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var player_inventory = get_node("PlayerController/PlayerInventory")
	var player = get_node("PlayerController")
	var pistol = Pistol.new()
	var toolgun = ToolGun.new()
	var testgun = TestGun.new()
	
	player_inventory.create_weapon(pistol, player)
	player_inventory.create_weapon(toolgun, player)
	player_inventory.create_weapon(testgun, player)
	
	# Separate the assignment of the modifier dictionaries
	var weapon_add_mod = { "fire_rate": 0.2 }
	var weapon_mult_mod = { "recoil_strength": 2 }
	var weapon_modifiers = Modifier.new(weapon_add_mod, weapon_mult_mod)
	
	var player_add_mod = { "speed": 1000 }
	var player_mult_mod = { "friction": 0.8 }
	var player_modifiers = Modifier.new(player_add_mod, player_mult_mod)

	# Apply to player inventory and controller
	player_inventory.apply_modifier(weapon_modifiers)
	player.apply_modifier(player_modifiers)
	
	pass

func test_print():
	print("this works")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
